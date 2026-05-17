"""
law_retrieval_agent.py
======================
Fetches legal content from ChromaDB (local PDF chunks) and official
Pakistani government websites. No agents SDK / LLM required.
"""
from __future__ import annotations

import asyncio, datetime as _dt, email.utils as _email_utils
import io, logging, os
from pathlib import Path
from typing import Any, Dict, List, Optional
from urllib.parse import urlparse

os.environ.setdefault("ANONYMIZED_TELEMETRY", "false")

import chromadb, httpx
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
    "women_harassment": ["https://ncsw.gov.pk/publications", "https://molaw.gov.pk/laws"],
    "labour_rights":    ["https://labour.punjab.gov.pk/laws", "https://molaw.gov.pk/laws"],
    "cyber_law":        ["https://pta.gov.pk/en/media-center/single-media/legal-framework", "https://fia.gov.pk/en/laws"],
    "road_laws":        ["https://molaw.gov.pk/laws", "https://na.gov.pk/en/legislation.php"],
    "_general":         ["https://molaw.gov.pk/laws", "https://na.gov.pk/en/legislation.php", "https://senate.gov.pk/en/acts.php"],
}

# ---------------------------------------------------------------------------
class LawDocumentResult(BaseModel):
    content:      str
    source_url:   str
    source_type:  str = "local"
    module:       Optional[str] = None
    filename:     Optional[str] = None
    last_updated: Optional[str] = None
    chunk_id:     Optional[int] = None

class LawRetrievalError(Exception):
    pass

# ---------------------------------------------------------------------------
def _init_collection() -> Optional[chromadb.Collection]:
    try:
        client = chromadb.PersistentClient(path=str(CHROMA_DB_PATH))
        ef = embedding_functions.SentenceTransformerEmbeddingFunction(model_name="all-MiniLM-L6-v2")
        col = client.get_collection(name=COLLECTION_NAME, embedding_function=ef)
        logger.info("ChromaDB loaded: %d chunks", col.count())
        return col
    except Exception as exc:
        logger.exception("ChromaDB init failed: %s", exc)
        return None

_COLLECTION: Optional[chromadb.Collection] = _init_collection()

# ---------------------------------------------------------------------------
def _file_mtime(module: Optional[str], filename: Optional[str]) -> Optional[str]:
    if not module or not filename:
        return None
    base = MODULE_DIRS.get(module)
    if base is None or not base.exists():
        return None
    for p in base.rglob("*"):
        if p.name == filename:
            return _dt.datetime.fromtimestamp(p.stat().st_mtime, tz=_dt.timezone.utc).isoformat()
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
    soup = BeautifulSoup(html, "html.parser")
    for tag in soup(["script","style","noscript","header","footer","nav"]):
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

# ---------------------------------------------------------------------------
async def _fetch_url(url: str, timeout: float = 12.0) -> Optional[LawDocumentResult]:
    try:
        async with httpx.AsyncClient(timeout=timeout, follow_redirects=True,
                                     headers={"User-Agent": "LegalSathi/2.0"}) as client:
            resp = await client.get(url)
    except Exception as exc:
        logger.warning("Fetch failed %s: %s", url, exc)
        return None
    if resp.status_code >= 400:
        return None
    ct   = (resp.headers.get("content-type") or "").lower()
    text = _pdf_to_text(resp.content) if ("application/pdf" in ct or url.lower().endswith(".pdf")) else _html_to_text(resp.text)
    if not text.strip():
        return None
    return LawDocumentResult(content=text, source_url=url, source_type="official_web",
                             last_updated=_header_mtime(resp.headers))

async def _fetch_official(module: Optional[str], limit: int) -> List[LawDocumentResult]:
    urls  = _SEED_URLS.get(module or "_general", _SEED_URLS["_general"])[:limit * 2]
    raws  = await asyncio.gather(*[_fetch_url(u) for u in urls], return_exceptions=True)
    out: List[LawDocumentResult] = []
    for r in raws:
        if isinstance(r, LawDocumentResult):
            out.append(r)
            if len(out) >= limit:
                break
    return out

def _chroma_search(query: str, module: Optional[str], limit: int) -> List[LawDocumentResult]:
    if _COLLECTION is None:
        return []
    where: Optional[Dict[str, Any]] = {"module": module} if module else None
    try:
        raw = _COLLECTION.query(query_texts=[query], n_results=limit, where=where,
                                include=["documents","metadatas","distances"])
    except Exception as exc:
        logger.exception("ChromaDB query failed: %s", exc)
        return []
    docs  = (raw.get("documents") or [[]])[0]
    metas = (raw.get("metadatas") or [[]])[0]
    out: List[LawDocumentResult] = []
    seen: set = set()
    for doc, meta in zip(docs, metas):
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
        src   = f"chroma://{mod}/{fname}#chunk={cid}" if cid is not None else f"chroma://{mod}/{fname}"
        out.append(LawDocumentResult(content=text, source_url=src, source_type="local",
                                     module=mod, filename=fname,
                                     chunk_id=int(cid) if cid is not None else None,
                                     last_updated=_file_mtime(mod, fname)))
    return out

# ---------------------------------------------------------------------------
async def run_law_retrieval_agent(
    query: str, module: Optional[str] = None, limit: int = 5,
) -> List[Dict[str, Any]]:
    """Retrieve relevant legal chunks. Returns list of plain dicts."""
    query = (query or "").strip()
    if not query:
        raise LawRetrievalError("Query must not be empty.")
    loop = asyncio.get_event_loop()
    local_results, web_results = await asyncio.gather(
        loop.run_in_executor(None, _chroma_search, query, module, limit),
        _fetch_official(module, max(1, limit // 2)),
    )
    combined: List[LawDocumentResult] = []
    seen: set = set()
    for item in list(local_results) + list(web_results):
        key = " ".join(item.content.split()).lower()[:512]
        if key not in seen:
            seen.add(key)
            combined.append(item)
    logger.info("[Retrieval] %d local + %d web for query=%r", len(local_results), len(web_results), query)
    return [item.model_dump() for item in combined]

__all__ = ["LawDocumentResult", "LawRetrievalError", "run_law_retrieval_agent"]
