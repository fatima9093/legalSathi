"""
law_retrieval_agent.py
======================
Retrieves legal content from ChromaDB (local PDF chunks) and official
Pakistani government websites. No LLM / agents SDK required.
"""
from __future__ import annotations

import asyncio
import datetime as _dt
import email.utils as _email_utils
import io
import logging
import os
import re
from pathlib import Path
from typing import Any, Dict, List, Optional
from urllib.parse import urljoin, urlparse

os.environ.setdefault("ANONYMIZED_TELEMETRY", "false")

import chromadb
import httpx
from bs4 import BeautifulSoup
from chromadb.utils import embedding_functions
from pydantic import BaseModel
from pypdf import PdfReader

logger = logging.getLogger(__name__)

BASE_DIR        = Path(__file__).resolve().parent
CHROMA_DB_PATH  = BASE_DIR / "chroma_db"
COLLECTION_NAME = "legal_documents"
DATA_ROOT       = BASE_DIR / "data"

MODULE_DIRS: Dict[str, Path] = {
    "women_harassment": DATA_ROOT / "women_harassment",
    "labour_rights":    DATA_ROOT / "Labour_rights",
    "cyber_law":        DATA_ROOT / "cyber_law",
    "road_laws":        DATA_ROOT / "road_laws",
}

_SEED_URLS: Dict[str, List[str]] = {
    "women_harassment": [
        "https://ncsw.gov.pk/publications",
        "https://molaw.gov.pk/laws",
    ],
    "labour_rights": [
        "https://labour.punjab.gov.pk/laws",
        "https://molaw.gov.pk/laws",
    ],
    "cyber_law": [
        "https://pta.gov.pk/en/media-center/single-media/legal-framework",
        "https://fia.gov.pk/en/laws",
    ],
    "road_laws": [
        "https://molaw.gov.pk/laws",
        "https://na.gov.pk/en/legislation.php",
    ],
    "_general": [
        "https://molaw.gov.pk/laws",
        "https://na.gov.pk/en/legislation.php",
        "https://senate.gov.pk/en/acts.php",
    ],
}

_TRUSTED_DOMAINS = {
    "gov.pk",
    "ncsw.gov.pk",
    "na.gov.pk",
    "senate.gov.pk",
    "punjabpolice.gov.pk",
    "eobi.gov.pk",
    "pessi.gov.pk",
}

_STOPWORDS = {
    "the", "and", "for", "with", "from", "that", "this", "what", "how", "are", "was", "were",
    "your", "you", "have", "has", "had", "can", "could", "should", "about", "under", "into",
    "pakistan", "law", "legal", "rights", "help", "need", "want", "please", "where", "when",
}

# ---------------------------------------------------------------------------
# Public data model
# ---------------------------------------------------------------------------

class LawDocumentResult(BaseModel):
    content:      str
    source_url:   str
    source_type:  str = "local"
    module:       Optional[str] = None
    filename:     Optional[str] = None
    last_updated: Optional[str] = None
    chunk_id:     Optional[int] = None
    retrieval_score: Optional[float] = None


class LawRetrievalError(Exception):
    pass


# ---------------------------------------------------------------------------
# ChromaDB singleton
# ---------------------------------------------------------------------------

def _init_collection() -> Optional[chromadb.Collection]:
    try:
        client = chromadb.PersistentClient(path=str(CHROMA_DB_PATH))
        ef     = embedding_functions.SentenceTransformerEmbeddingFunction(
                     model_name="all-MiniLM-L6-v2"
                 )
        col = client.get_collection(name=COLLECTION_NAME, embedding_function=ef)
        logger.info("ChromaDB loaded: %d chunks", col.count())
        return col
    except Exception as exc:
        logger.exception("ChromaDB init failed: %s", exc)
        return None


_COLLECTION: Optional[chromadb.Collection] = None  # lazy-initialised on first use

_MODULE_KEYWORDS: Dict[str, List[str]] = {
    "women_harassment": [
        "harassment", "workplace harassment", "sexual harassment", "stalking", "blackmail", "helpline", "complaint committee"
    ],
    "labour_rights": [
        "salary", "wage", "minimum wage", "overtime", "factory", "termination", "resignation", "leave", "eobi", "pessi"
    ],
    "cyber_law": [
        "cyber", "online", "hack", "hacking", "fraud", "social media", "fia", "peca", "data breach", "identity theft"
    ],
    "road_laws": [
        "traffic", "driving", "license", "licence", "challan", "vehicle", "road", "fine", "speeding", "accident"
    ],
}


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _file_mtime(module: Optional[str], filename: Optional[str]) -> Optional[str]:
    if not module or not filename:
        return None
    base = MODULE_DIRS.get(module)
    if base is None or not base.exists():
        return None
    for p in base.rglob("*"):
        if p.name == filename:
            return _dt.datetime.fromtimestamp(
                p.stat().st_mtime, tz=_dt.timezone.utc
            ).isoformat()
    return None


def _header_mtime(headers: httpx.Headers) -> Optional[str]:
    raw = headers.get("Last-Modified") or headers.get("last-modified")
    if not raw:
        return None
    try:
        dt = _email_utils.parsedate_to_datetime(raw)
        if dt.tzinfo is None:
            dt = dt.replace(tzinfo=_dt.timezone.utc)
        return dt.astimezone(_dt.timezone.utc).isoformat()
    except Exception:
        return None


def _html_to_text(html: str, max_chars: int = 8000) -> str:
    from bs4 import BeautifulSoup
    soup = BeautifulSoup(html, "html.parser")
    for tag in soup(["script", "style", "noscript", "header", "footer", "nav"]):
        tag.decompose()
    return " ".join(soup.get_text(separator=" ", strip=True).split())[:max_chars]


def _pdf_to_text(data: bytes, max_chars: int = 8000) -> str:
    try:
        reader = PdfReader(io.BytesIO(data))
    except Exception:
        return ""
    parts: List[str] = []
    for page in reader.pages:
        try:
            parts.append(page.extract_text() or "")
        except Exception:
            pass
        if sum(len(p) for p in parts) >= max_chars:
            break
    return "\n".join(parts)[:max_chars]


def _infer_module_from_query(query: str) -> Optional[str]:
    q = (query or "").lower()
    if not q:
        return None
    best_module: Optional[str] = None
    best_score = 0
    for module_name, keywords in _MODULE_KEYWORDS.items():
        score = sum(1 for kw in keywords if kw in q)
        if score > best_score:
            best_score = score
            best_module = module_name
    return best_module if best_score > 0 else None


def _expand_queries(query: str, module: Optional[str]) -> List[str]:
    base = (query or "").strip()
    if not base:
        return []

    module_hint = {
        "women_harassment": "Protection against Harassment of Women at the Workplace Act Pakistan",
        "labour_rights": "Pakistan labour rights law wages termination benefits",
        "cyber_law": "PECA cyber crime law Pakistan FIA complaint procedure",
        "road_laws": "Pakistan traffic law driving licence challan fines",
    }.get(module or "", "Pakistan law legal rights procedure")

    candidates = [
        base,
        f"{base} {module_hint}",
        f"{base} Pakistan law",
    ]

    out: List[str] = []
    seen: set = set()
    for c in candidates:
        key = " ".join(c.lower().split())
        if key and key not in seen:
            seen.add(key)
            out.append(c)
    return out[:3]


def _query_terms(query: str, max_terms: int = 10) -> List[str]:
    tokens = re.findall(r"[a-zA-Z][a-zA-Z0-9_-]{2,}", (query or "").lower())
    out: List[str] = []
    seen: set = set()
    for tok in tokens:
        if tok in _STOPWORDS or tok in seen:
            continue
        seen.add(tok)
        out.append(tok)
        if len(out) >= max_terms:
            break
    return out


def _text_relevance(text: str, query_terms: List[str]) -> float:
    if not text:
        return 0.0
    if not query_terms:
        return 0.5
    lowered = text.lower()
    hits = sum(1 for t in query_terms if t in lowered)
    return round(min(1.0, hits / max(1, len(query_terms))), 4)


def _align_to_query(
    items: List[LawDocumentResult],
    query: str,
    keep: int,
    min_lexical_relevance: float = 0.10,
) -> List[LawDocumentResult]:
    if not items:
        return []

    query_terms = _query_terms(query)
    if not query_terms:
        items.sort(
            key=lambda x: x.retrieval_score if x.retrieval_score is not None else -1.0,
            reverse=True,
        )
        return items[: max(1, keep)]

    aligned: List[LawDocumentResult] = []
    for item in items:
        lexical = _text_relevance(item.content, query_terms)
        semantic = item.retrieval_score if item.retrieval_score is not None else 0.0
        blended = round((0.60 * semantic) + (0.40 * lexical), 4)

        # Keep only chunks that are semantically strong or lexically aligned.
        if lexical >= min_lexical_relevance or semantic >= 0.45:
            item.retrieval_score = max(item.retrieval_score or 0.0, blended)
            aligned.append(item)

    if not aligned:
        # Fallback: keep best semantic chunks so we still return something useful.
        items.sort(
            key=lambda x: x.retrieval_score if x.retrieval_score is not None else -1.0,
            reverse=True,
        )
        return items[: max(1, min(keep, 3))]

    aligned.sort(
        key=lambda x: x.retrieval_score if x.retrieval_score is not None else -1.0,
        reverse=True,
    )
    return aligned[: max(1, keep)]


def _is_trusted_url(url: str) -> bool:
    try:
        host = (urlparse(url).netloc or "").lower()
    except Exception:
        return False
    if not host:
        return False
    return any(host == d or host.endswith(f".{d}") for d in _TRUSTED_DOMAINS)


def _discover_candidate_links(seed_url: str, html: str, query_terms: List[str], max_links: int = 20) -> List[str]:
    soup = BeautifulSoup(html, "html.parser")
    scored: List[tuple] = []
    seen: set = set()
    for tag in soup.find_all("a", href=True):
        href = (tag.get("href") or "").strip()
        if not href or href.startswith("#") or href.startswith("mailto:") or href.startswith("javascript:"):
            continue
        url = urljoin(seed_url, href)
        if not url.startswith("http") or url in seen:
            continue
        if not _is_trusted_url(url):
            continue
        seen.add(url)

        anchor = (tag.get_text(" ", strip=True) or "").lower()
        lower_url = url.lower()
        score = sum(1 for t in query_terms if t in anchor or t in lower_url)
        if ".pdf" in lower_url:
            score += 1
        if any(k in anchor or k in lower_url for k in ["law", "act", "rules", "ordinance", "policy", "complaint"]):
            score += 1
        if score > 0:
            scored.append((score, url))

    scored.sort(key=lambda x: x[0], reverse=True)
    return [u for _, u in scored[:max_links]]


# ---------------------------------------------------------------------------
# Async fetch
# ---------------------------------------------------------------------------

async def _fetch_url(url: str, query_terms: Optional[List[str]] = None, timeout: float = 12.0) -> Optional[LawDocumentResult]:
    try:
        async with httpx.AsyncClient(
            timeout=timeout,
            follow_redirects=True,
            headers={"User-Agent": "LegalSathi/2.0"},
        ) as client:
            resp = await client.get(url)
    except Exception as exc:
        logger.warning("Fetch failed %s: %s", url, exc)
        return None

    if resp.status_code >= 400:
        return None

    ct = (resp.headers.get("content-type") or "").lower()
    text = _pdf_to_text(resp.content) if ("application/pdf" in ct or url.lower().endswith(".pdf")) else _html_to_text(resp.text)
    if not text.strip():
        return None

    rel = _text_relevance(text, query_terms or [])
    if query_terms and rel < 0.05:
        return None

    return LawDocumentResult(
        content=text,
        source_url=url,
        source_type="official_web",
        last_updated=_header_mtime(resp.headers),
        retrieval_score=rel,
    )


async def _fetch_seed_and_links(url: str, query_terms: List[str], timeout: float = 12.0) -> tuple:
    try:
        async with httpx.AsyncClient(
            timeout=timeout,
            follow_redirects=True,
            headers={"User-Agent": "LegalSathi/2.0"},
        ) as client:
            resp = await client.get(url)
    except Exception as exc:
        logger.warning("Seed fetch failed %s: %s", url, exc)
        return None, []

    if resp.status_code >= 400:
        return None, []

    ct = (resp.headers.get("content-type") or "").lower()
    is_pdf = ("application/pdf" in ct or url.lower().endswith(".pdf"))
    text = _pdf_to_text(resp.content) if is_pdf else _html_to_text(resp.text)
    if not text.strip():
        return None, []

    links = [] if is_pdf else _discover_candidate_links(url, resp.text, query_terms, max_links=16)
    rel = _text_relevance(text, query_terms)
    doc = LawDocumentResult(
        content=text,
        source_url=url,
        source_type="official_web",
        last_updated=_header_mtime(resp.headers),
        retrieval_score=rel,
    )
    return doc, links


async def _fetch_official(module: Optional[str], limit: int, query: str = "") -> List[LawDocumentResult]:
    query_terms = _query_terms(query)
    seed_urls = _SEED_URLS.get(module or "_general", _SEED_URLS["_general"])[: max(2, limit * 2)]

    seed_tasks = [_fetch_seed_and_links(u, query_terms) for u in seed_urls]
    seed_raw = await asyncio.gather(*seed_tasks, return_exceptions=True)

    out: List[LawDocumentResult] = []
    candidate_links: List[str] = []
    seen_links: set = set()

    for item in seed_raw:
        if not isinstance(item, tuple):
            continue
        doc, links = item
        if isinstance(doc, LawDocumentResult):
            out.append(doc)
        for link in (links or []):
            if link not in seen_links:
                seen_links.add(link)
                candidate_links.append(link)

    link_tasks = [_fetch_url(u, query_terms=query_terms) for u in candidate_links[: max(6, limit * 5)]]
    link_raw = await asyncio.gather(*link_tasks, return_exceptions=True)
    for item in link_raw:
        if isinstance(item, LawDocumentResult):
            out.append(item)

    out.sort(key=lambda x: x.retrieval_score if x.retrieval_score is not None else -1.0, reverse=True)
    return out[: max(1, limit)]


# ---------------------------------------------------------------------------
# Sync ChromaDB search
# ---------------------------------------------------------------------------

def _chroma_search(query: str, module: Optional[str], limit: int) -> List[LawDocumentResult]:
    global _COLLECTION
    if _COLLECTION is None:
        _COLLECTION = _init_collection()
    if _COLLECTION is None:
        return []
    where: Optional[Dict[str, Any]] = {"module": module} if module else None
    try:
        raw = _COLLECTION.query(
            query_texts=[query],
            n_results=limit,
            where=where,
            include=["documents", "metadatas", "distances"],
        )
    except Exception as exc:
        logger.exception("ChromaDB query failed: %s", exc)
        return []

    docs      = (raw.get("documents")  or [[]])[0]
    metas     = (raw.get("metadatas")  or [[]])[0]
    dists     = (raw.get("distances")  or [[]])[0]

    out: List[LawDocumentResult] = []
    seen: set = set()
    for idx, (doc, meta) in enumerate(zip(docs, metas)):
        text = (doc or "").strip()
        if not text:
            continue
        key = " ".join(text.split()).lower()[:512]
        if key in seen:
            continue
        seen.add(key)
        mod   = str(meta.get("module") or "unknown")
        fname = str(meta.get("file")   or "unknown")
        cid   = meta.get("chunk_id")
        dist  = dists[idx] if idx < len(dists) else None
        src   = f"chroma://{mod}/{fname}#chunk={cid}" if cid is not None else f"chroma://{mod}/{fname}"
        out.append(LawDocumentResult(
            content=text, source_url=src, source_type="local",
            module=mod, filename=fname,
            chunk_id=int(cid) if cid is not None else None,
            last_updated=_file_mtime(mod, fname),
            retrieval_score=max(0.0, 1.0 - float(dist)) if dist is not None else None,
        ))
    return out


# ---------------------------------------------------------------------------
# Public entry point
# ---------------------------------------------------------------------------

async def run_law_retrieval_agent(
    query: str,
    module: Optional[str] = None,
    limit: int = 5,
) -> List[Dict[str, Any]]:
    """Retrieve relevant legal chunks. Returns list of plain dicts."""
    query = (query or "").strip()
    if not query:
        raise LawRetrievalError("Query must not be empty.")

    inferred_module = module or _infer_module_from_query(query)
    query_variants = _expand_queries(query, inferred_module)

    loop = asyncio.get_event_loop()
    local_tasks = [
        loop.run_in_executor(None, _chroma_search, q, inferred_module, limit)
        for q in (query_variants or [query])
    ]
    web_task = _fetch_official(inferred_module, max(2, limit), query=query)
    local_lists, web_results = await asyncio.gather(asyncio.gather(*local_tasks), web_task)

    local_results: List[LawDocumentResult] = []
    for group in local_lists:
        local_results.extend(group)

    local_results.sort(key=lambda x: x.retrieval_score if x.retrieval_score is not None else -1.0, reverse=True)

    combined: List[LawDocumentResult] = []
    seen: set = set()
    for item in list(local_results) + list(web_results):
        key = " ".join(item.content.split()).lower()[:512]
        if key not in seen:
            seen.add(key)
            combined.append(item)

    combined.sort(key=lambda x: x.retrieval_score if x.retrieval_score is not None else -1.0, reverse=True)
    combined = _align_to_query(combined, query=query, keep=max(1, limit * 2))

    logger.info(
        "[Retrieval] %d local + %d web for query=%r module=%s",
        len(local_results), len(web_results), query, inferred_module
    )
    return [item.model_dump() for item in combined]


__all__ = ["LawDocumentResult", "LawRetrievalError", "run_law_retrieval_agent"]
