"""Run once to write all rewritten agent files."""
import pathlib, textwrap

BASE = pathlib.Path(__file__).parent

# ============================================================
FILES = {}
# ============================================================

FILES["law_retrieval_agent.py"] = '''\
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
    return "\\n".join(parts)[:max_chars]

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
'''

# ============================================================

FILES["verification_agent.py"] = '''\
"""
verification_agent.py
=====================
Cross-checks retrieved chunks, assigns confidence + recency scores,
and filters out low-quality content before passing to explanation stage.
"""
from __future__ import annotations

import json, logging, re
from datetime import datetime, timezone
from typing import Any, Dict, List, Optional

from openai import AsyncOpenAI
from pydantic import BaseModel

import groq_config  # noqa: F401
from groq_config import GROQ_MODEL_FAST, _GROQ_API_KEY, _GROQ_BASE_URL

logger  = logging.getLogger(__name__)
_CLIENT = AsyncOpenAI(api_key=_GROQ_API_KEY, base_url=_GROQ_BASE_URL)

_SOURCE_SCORE: Dict[str, float] = {"official_web": 0.95, "local": 0.75, "unknown": 0.40}
_RECENCY_DECAY_YEARS = 5

# ---------------------------------------------------------------------------
class VerifiedChunk(BaseModel):
    content:          str
    source_url:       str
    source_type:      str
    module:           Optional[str]
    filename:         Optional[str]
    last_updated:     Optional[str]
    confidence_score: float
    recency_score:    float
    relevance_score:  float
    overall_score:    float
    flagged:          bool = False
    flag_reason:      Optional[str] = None

class VerificationReport(BaseModel):
    verified:           List[VerifiedChunk]
    discarded:          List[VerifiedChunk]
    overall_confidence: float
    last_updated:       Optional[str]

class VerificationError(Exception):
    pass

# ---------------------------------------------------------------------------
def _source_confidence(source_type: str, source_url: str) -> float:
    base = _SOURCE_SCORE.get(source_type, 0.4)
    if ".gov.pk" in source_url:
        base = max(base, 0.95)
    return base

def _recency_score(last_updated: Optional[str]) -> float:
    if not last_updated:
        return 0.5
    try:
        dt = datetime.fromisoformat(last_updated)
        if dt.tzinfo is None:
            dt = dt.replace(tzinfo=timezone.utc)
        age_years = (datetime.now(timezone.utc) - dt).days / 365.25
        return max(0.0, 1.0 - age_years / _RECENCY_DECAY_YEARS)
    except Exception:
        return 0.5

def _most_recent(chunks: List[VerifiedChunk]) -> Optional[str]:
    dates = [c.last_updated for c in chunks if c.last_updated]
    return max(dates, default=None)

def _strip_json(text: str) -> Any:
    text = re.sub(r"```(?:json)?", "", text).strip().rstrip("`").strip()
    return json.loads(text)

async def _llm_relevance(query: str, chunks: List[Dict[str, Any]]) -> List[float]:
    if not chunks:
        return []
    numbered = "\\n\\n".join(f"[{i+1}] {c[\'content\'][:600]}" for i, c in enumerate(chunks))
    system = (
        "You are a legal relevance evaluator for Pakistani law. "
        "Given a user query and numbered document snippets, return a JSON object "
        "with a single key \\"scores\\" whose value is a list of floats 0.0-1.0 "
        "(one per snippet, higher = more relevant). Respond with ONLY valid JSON."
    )
    try:
        resp = await _CLIENT.chat.completions.create(
            model=GROQ_MODEL_FAST,
            messages=[{"role":"system","content":system},
                      {"role":"user","content":f"Query: {query}\\n\\nSnippets:\\n{numbered}"}],
            response_format={"type":"json_object"},
            temperature=0.0, max_tokens=256,
        )
        data   = _strip_json(resp.choices[0].message.content or "{}")
        scores = [float(s) for s in data.get("scores", [])]
        while len(scores) < len(chunks):
            scores.append(0.5)
        return scores[:len(chunks)]
    except Exception as exc:
        logger.warning("LLM relevance failed: %s", exc)
        return [0.5] * len(chunks)

# ---------------------------------------------------------------------------
async def run_verification_agent(
    query: str,
    raw_chunks: List[Dict[str, Any]],
    min_overall_score: float = 0.35,
) -> VerificationReport:
    if not raw_chunks:
        return VerificationReport(verified=[], discarded=[], overall_confidence=0.0, last_updated=None)

    pre_scored = [
        (c, _source_confidence(c.get("source_type","unknown"), c.get("source_url","")),
         _recency_score(c.get("last_updated")))
        for c in raw_chunks
    ]
    relevance_scores = await _llm_relevance(query, raw_chunks)

    verified: List[VerifiedChunk]  = []
    discarded: List[VerifiedChunk] = []

    for (chunk, src_conf, rec_score), rel_score in zip(pre_scored, relevance_scores):
        overall = round(0.50 * rel_score + 0.30 * src_conf + 0.20 * rec_score, 4)
        flag    = overall < min_overall_score
        vc = VerifiedChunk(
            content=chunk.get("content",""), source_url=chunk.get("source_url",""),
            source_type=chunk.get("source_type","unknown"), module=chunk.get("module"),
            filename=chunk.get("filename"), last_updated=chunk.get("last_updated"),
            confidence_score=src_conf, recency_score=rec_score,
            relevance_score=rel_score, overall_score=overall,
            flagged=flag, flag_reason=f"low score ({overall:.2f})" if flag else None,
        )
        (discarded if flag else verified).append(vc)

    verified.sort(key=lambda c: c.overall_score, reverse=True)
    avg = round(sum(c.overall_score for c in verified) / len(verified), 4) if verified else 0.0
    logger.info("[Verification] %d verified / %d discarded  avg=%.2f", len(verified), len(discarded), avg)

    return VerificationReport(verified=verified, discarded=discarded,
                              overall_confidence=avg, last_updated=_most_recent(verified))

__all__ = ["VerificationError", "VerificationReport", "VerifiedChunk", "run_verification_agent"]
'''

# ============================================================

FILES["explanation_agent.py"] = '''\
"""
explanation_agent.py
====================
Summarises verified legal chunks into plain-language explanation.
Direct Groq API call — no agents SDK output_type to avoid json+tools conflict.
"""
from __future__ import annotations

import json, logging, re, textwrap
from typing import Any, Dict, List, Optional

from openai import AsyncOpenAI
from pydantic import BaseModel

import groq_config  # noqa: F401
from groq_config import GROQ_MODEL_STRONG, _GROQ_API_KEY, _GROQ_BASE_URL

logger  = logging.getLogger(__name__)
_CLIENT = AsyncOpenAI(api_key=_GROQ_API_KEY, base_url=_GROQ_BASE_URL)

_MAX_CONTEXT = 12_000

# ---------------------------------------------------------------------------
class ExplanationOutput(BaseModel):
    summary:    str
    key_points: List[str]
    references: Dict[str, str]

class ExplanationError(Exception):
    pass

# ---------------------------------------------------------------------------
def _build_context(chunks: List[Dict[str, Any]]) -> str:
    parts: List[str] = []
    total = 0
    for i, c in enumerate(chunks, 1):
        text = (c.get("content") or "").strip()
        src  = (c.get("source_url") or "unknown").strip()
        if not text:
            continue
        entry = f"[Document {i}] Source: {src}\\n{text}"
        remaining = _MAX_CONTEXT - total
        if remaining <= 0:
            break
        if len(entry) > remaining:
            entry = entry[:remaining].rstrip() + " [truncated]"
        parts.append(entry)
        total += len(entry)
    return "\\n\\n---\\n\\n".join(parts)

def _build_refs(chunks: List[Dict[str, Any]]) -> Dict[str, str]:
    refs: Dict[str, str] = {}
    for i, c in enumerate(chunks, 1):
        src = (c.get("source_url") or "unknown").strip()
        lu  = c.get("last_updated")
        refs[f"Document {i}"] = f"{src} (last updated: {lu})" if lu else src
    return refs

def _strip_json(text: str) -> Any:
    text = re.sub(r"```(?:json)?", "", text).strip().rstrip("`").strip()
    return json.loads(text)

def _system_prompt(language: str, max_key_points: int) -> str:
    return textwrap.dedent(f"""
        You are a senior Pakistani legal analyst.
        Produce a structured explanation in **{language}** of the legal text provided.

        Return ONLY a valid JSON object with exactly these keys:
        {{
            "summary": "<3-6 sentence plain-language summary>",
            "key_points": ["<up to {max_key_points} key legal points, each a single sentence>"],
            "references": {{}}
        }}

        Rules:
        - If documents are provided, base your answer on them.
        - If NO documents are provided, answer from your general knowledge of Pakistani law
          and note you are using general knowledge.
        - Do not refuse to answer.
        - No markdown outside the JSON.
    """).strip()

# ---------------------------------------------------------------------------
async def run_explanation_agent(
    chunks: List[Dict[str, Any]],
    language: str = "English",
    max_key_points: int = 8,
    query: str = "",
) -> ExplanationOutput:
    max_key_points = max(1, min(20, max_key_points))
    context_block  = _build_context(chunks) if chunks else ""

    if context_block.strip():
        user_msg = f"Explain these legal document excerpts:\\n\\n{context_block}"
    else:
        q = query.strip() or "the legal question"
        user_msg = (
            f"No local documents were retrieved. Answer from your general knowledge "
            f"of Pakistani law:\\n\\n{q}"
        )

    try:
        resp = await _CLIENT.chat.completions.create(
            model=GROQ_MODEL_STRONG,
            messages=[{"role":"system","content":_system_prompt(language, max_key_points)},
                      {"role":"user","content":user_msg}],
            response_format={"type":"json_object"},
            temperature=0.2,
        )
        data   = _strip_json(resp.choices[0].message.content or "{}")
        output = ExplanationOutput(**data)
    except Exception as exc:
        logger.exception("Explanation agent failed: %s", exc)
        raise ExplanationError("Explanation agent failed.") from exc

    if not output.references:
        output = ExplanationOutput(summary=output.summary, key_points=output.key_points,
                                   references=_build_refs(chunks))
    return output

__all__ = ["ExplanationError", "ExplanationOutput", "run_explanation_agent"]
'''

# ============================================================

FILES["guidance_agent.py"] = '''\
"""
guidance_agent.py
=================
Produces step-by-step legal guidance from a verified explanation.
Direct Groq API call — no agents SDK.
"""
from __future__ import annotations

import json, logging, re, textwrap
from typing import Any, Dict, List, Optional

from openai import AsyncOpenAI
from pydantic import BaseModel

import groq_config  # noqa: F401
from groq_config import GROQ_MODEL_STRONG, _GROQ_API_KEY, _GROQ_BASE_URL
from explanation_agent import ExplanationOutput

logger  = logging.getLogger(__name__)
_CLIENT = AsyncOpenAI(api_key=_GROQ_API_KEY, base_url=_GROQ_BASE_URL)

# ---------------------------------------------------------------------------
_OFFICIAL_LINKS: Dict[str, Dict[str, str]] = {
    "women_harassment": {
        "NCSW Helpline (1099)":        "https://ncsw.gov.pk",
        "FIA Cyber Crime Wing":        "https://fia.gov.pk/en/cybercrime",
        "Ministry of Law":             "https://molaw.gov.pk",
        "Punjab Ombudsman":            "https://ombudsmanpunjab.gov.pk",
    },
    "labour_rights": {
        "Punjab Labour Dept":          "https://labour.punjab.gov.pk",
        "Ministry of Law":             "https://molaw.gov.pk",
        "EOBI":                        "https://eobi.gov.pk",
        "PESSI":                       "https://pessi.gov.pk",
    },
    "cyber_law": {
        "PTA Legal Framework":         "https://pta.gov.pk/en/media-center/single-media/legal-framework",
        "FIA Cyber Crime Wing":        "https://fia.gov.pk/en/cybercrime",
        "Ministry of Law":             "https://molaw.gov.pk",
    },
    "road_laws": {
        "National Assembly Acts":      "https://na.gov.pk/en/legislation.php",
        "Ministry of Law":             "https://molaw.gov.pk",
        "Punjab Traffic Police":       "https://traffic.punjabpolice.gov.pk",
    },
    "_general": {
        "Ministry of Law":             "https://molaw.gov.pk",
        "National Assembly":           "https://na.gov.pk/en/legislation.php",
        "Senate of Pakistan":          "https://senate.gov.pk/en/acts.php",
    },
}

def _get_links(module: Optional[str]) -> Dict[str, str]:
    return dict(_OFFICIAL_LINKS.get(module or "_general", _OFFICIAL_LINKS["_general"]))

# ---------------------------------------------------------------------------
class GuidanceStep(BaseModel):
    step_number: int
    title:       str
    description: str
    tips:        Optional[str] = None

class GuidanceOutput(BaseModel):
    steps:              List[GuidanceStep]
    required_documents: List[str]
    official_links:     Dict[str, str]
    notes:              Optional[str] = None

class GuidanceError(Exception):
    pass

# ---------------------------------------------------------------------------
def _strip_json(text: str) -> Any:
    text = re.sub(r"```(?:json)?", "", text).strip().rstrip("`").strip()
    return json.loads(text)

def _system_prompt(language: str, max_steps: int, module: Optional[str],
                   official_links: Dict[str, str]) -> str:
    module_hint = {
        "women_harassment": "workplace or public harassment under Pakistani law",
        "labour_rights":    "labour rights and employment disputes in Pakistan",
        "cyber_law":        "cybercrime and digital offences under Pakistani law",
        "road_laws":        "road traffic laws and violations in Pakistan",
    }.get(module or "", "a Pakistani legal matter")

    links_block = "\\n".join(f"  - {k}: {v}" for k, v in official_links.items())

    return textwrap.dedent(f"""
        You are an expert Pakistani legal advisor producing step-by-step guidance for a citizen.
        The legal concern relates to: **{module_hint}**.

        Return ONLY a valid JSON object conforming to this schema:
        {{
            "steps": [
                {{"step_number": 1, "title": "...", "description": "...", "tips": "..."}}
            ],
            "required_documents": ["..."],
            "official_links": {{"label": "url"}},
            "notes": "..."
        }}

        Rules:
        1. Up to {max_steps} procedural steps, ordered logically.
        2. Each step must be specific and actionable.
        3. Populate official_links ONLY from the verified list below.
        4. No markdown outside the JSON.

        VERIFIED OFFICIAL LINKS (use only these):
        {links_block}
    """).strip()

def _input_block(explanation: ExplanationOutput) -> str:
    kp = "\\n".join(f"- {p}" for p in (explanation.key_points or []))
    return f"Summary:\\n{explanation.summary}\\n\\nKey Points:\\n{kp}"

# ---------------------------------------------------------------------------
async def run_guidance_agent(
    explanation: ExplanationOutput,
    module: Optional[str] = None,
    language: str = "English",
    max_steps: int = 10,
    official_links_hint: Optional[Dict[str, str]] = None,
) -> GuidanceOutput:
    if not explanation.summary and not explanation.key_points:
        raise GuidanceError("Explanation has no content to generate guidance from.")

    max_steps      = max(1, min(20, max_steps))
    official_links = _get_links(module)
    if official_links_hint:
        official_links.update(official_links_hint)

    try:
        resp = await _CLIENT.chat.completions.create(
            model=GROQ_MODEL_STRONG,
            messages=[
                {"role":"system","content":_system_prompt(language, max_steps, module, official_links)},
                {"role":"user","content":f"Produce guidance from this explanation:\\n\\n{_input_block(explanation)}"},
            ],
            response_format={"type":"json_object"},
            temperature=0.15,
        )
        data   = _strip_json(resp.choices[0].message.content or "{}")
        # Coerce steps list to GuidanceStep objects
        raw_steps = data.get("steps") or []
        steps = []
        for s in raw_steps:
            if isinstance(s, dict):
                steps.append(GuidanceStep(**{k: v for k, v in s.items()
                                             if k in GuidanceStep.model_fields}))
        output = GuidanceOutput(
            steps=steps,
            required_documents=data.get("required_documents") or [],
            official_links=data.get("official_links") or official_links,
            notes=data.get("notes"),
        )
    except GuidanceError:
        raise
    except Exception as exc:
        logger.exception("Guidance agent failed: %s", exc)
        raise GuidanceError("Guidance agent failed.") from exc

    # Backfill official_links with verified links if empty
    if not output.official_links:
        output = GuidanceOutput(steps=output.steps, required_documents=output.required_documents,
                                official_links=official_links, notes=output.notes)
    return output

__all__ = ["GuidanceError", "GuidanceOutput", "GuidanceStep", "run_guidance_agent"]
'''

# ============================================================

FILES["agent_orchestrator.py"] = '''\
"""
agent_orchestrator.py
=====================
Coordinates the 4-agent pipeline:
  1. Law Retrieval   — fetches local DB + official web content
  2. Verification    — scores credibility, recency, relevance; filters low-quality
  3. Explanation     — summarises verified content in plain language
  4. Guidance        — produces step-by-step procedural guidance

Returns the full structured OrchestratorResponse.
"""
from __future__ import annotations

import logging, time
from typing import Any, Dict, List, Optional

from pydantic import BaseModel

import groq_config  # noqa: F401
from law_retrieval_agent  import LawRetrievalError,  run_law_retrieval_agent
from verification_agent   import VerificationReport,  run_verification_agent
from explanation_agent    import ExplanationError,    run_explanation_agent
from guidance_agent       import GuidanceError,       run_guidance_agent

logger = logging.getLogger(__name__)

_VALID_MODULES = frozenset({"women_harassment","labour_rights","cyber_law","road_laws"})

# ---------------------------------------------------------------------------
class OrchestratorResponse(BaseModel):
    answer:             str
    summary:            str
    key_points:         List[str]
    steps:              List[Dict[str, Any]]
    required_documents: List[str]
    references:         List[str]
    official_links:     Dict[str, str]
    notes:              Optional[str]        = None
    module:             Optional[str]        = None
    query:              str                  = ""
    elapsed_seconds:    float                = 0.0
    confidence_score:   float                = 0.0
    last_updated:       Optional[str]        = None

class OrchestratorError(Exception):
    pass

# ---------------------------------------------------------------------------
def _build_answer(summary: str, steps: List[Dict[str, Any]]) -> str:
    parts = []
    if summary:
        parts.append(summary)
    if steps:
        first = steps[0]
        title = first.get("title","")
        desc  = first.get("description","")
        if title and desc:
            parts.append(f"To get started: **{title}** — {desc}")
        elif desc:
            parts.append(f"First step: {desc}")
    return "\\n\\n".join(parts) or "Please consult a qualified legal professional."

def _collect_refs(chunks: List[Dict[str, Any]]) -> List[str]:
    seen: set = set()
    refs: List[str] = []
    for c in chunks:
        url = (c.get("source_url") or "").strip()
        if url and url not in seen:
            seen.add(url)
            refs.append(url)
    return refs

def _coerce_steps(guidance) -> List[Dict[str, Any]]:
    out: List[Dict[str, Any]] = []
    for s in guidance.steps or []:
        if isinstance(s, dict):
            out.append(s)
        else:
            out.append({"step_number": s.step_number, "title": s.title,
                        "description": s.description, "tips": s.tips})
    return out

# ---------------------------------------------------------------------------
async def run_orchestrator(
    query: str,
    module: Optional[str]            = None,
    language: str                    = "English",
    retrieval_limit: int             = 5,
    max_key_points: int              = 8,
    max_steps: int                   = 10,
    official_links_hint: Optional[Dict[str, str]] = None,
) -> OrchestratorResponse:
    query = (query or "").strip()
    if not query:
        raise OrchestratorError("Query must not be empty.")
    if module is not None and module not in _VALID_MODULES:
        raise OrchestratorError(f"Invalid module \\"{module}\\".")

    retrieval_limit = max(1, min(20, retrieval_limit))
    max_key_points  = max(1, min(20, max_key_points))
    max_steps       = max(1, min(20, max_steps))
    start           = time.monotonic()

    # ---- Stage 1: Retrieval -----------------------------------------------
    logger.info("[Orchestrator] Stage 1: retrieval  query=%r  module=%s", query, module)
    try:
        raw_chunks = await run_law_retrieval_agent(query=query, module=module, limit=retrieval_limit)
    except LawRetrievalError as exc:
        raise OrchestratorError(f"Retrieval failed: {exc}") from exc
    except Exception as exc:
        logger.exception("[Orchestrator] Unexpected retrieval error: %s", exc)
        raise OrchestratorError("Retrieval encountered an unexpected error.") from exc

    if not raw_chunks:
        logger.warning("[Orchestrator] No documents found — will use LLM general knowledge.")

    # ---- Stage 2: Verification --------------------------------------------
    logger.info("[Orchestrator] Stage 2: verification  %d raw chunks", len(raw_chunks))
    try:
        report: VerificationReport = await run_verification_agent(
            query=query, raw_chunks=raw_chunks
        )
    except Exception as exc:
        logger.exception("[Orchestrator] Verification error: %s — using all raw chunks", exc)
        from verification_agent import VerifiedChunk, VerificationReport as VR
        report = VR(verified=[], discarded=[], overall_confidence=0.5, last_updated=None)

    verified_dicts: List[Dict[str, Any]] = [
        c.model_dump() for c in report.verified
    ] if report.verified else raw_chunks   # fallback: use raw if verification has no results

    logger.info("[Orchestrator] Stage 2 complete: %d verified  conf=%.2f",
                len(report.verified), report.overall_confidence)

    # ---- Stage 3: Explanation ---------------------------------------------
    logger.info("[Orchestrator] Stage 3: explanation")
    try:
        explanation = await run_explanation_agent(
            chunks=verified_dicts, language=language,
            max_key_points=max_key_points, query=query,
        )
    except ExplanationError as exc:
        raise OrchestratorError(f"Explanation failed: {exc}") from exc
    except Exception as exc:
        logger.exception("[Orchestrator] Explanation error: %s", exc)
        raise OrchestratorError("Explanation encountered an unexpected error.") from exc

    # ---- Stage 4: Guidance ------------------------------------------------
    logger.info("[Orchestrator] Stage 4: guidance")
    try:
        guidance = await run_guidance_agent(
            explanation=explanation, module=module, language=language,
            max_steps=max_steps, official_links_hint=official_links_hint,
        )
    except GuidanceError as exc:
        raise OrchestratorError(f"Guidance failed: {exc}") from exc
    except Exception as exc:
        logger.exception("[Orchestrator] Guidance error: %s", exc)
        raise OrchestratorError("Guidance encountered an unexpected error.") from exc

    # ---- Assemble ---------------------------------------------------------
    steps   = _coerce_steps(guidance)
    elapsed = round(time.monotonic() - start, 3)

    response = OrchestratorResponse(
        answer=_build_answer(explanation.summary, steps),
        summary=explanation.summary or "",
        key_points=explanation.key_points or [],
        steps=steps,
        required_documents=guidance.required_documents or [],
        references=_collect_refs(verified_dicts),
        official_links=guidance.official_links or {},
        notes=guidance.notes,
        module=module,
        query=query,
        elapsed_seconds=elapsed,
        confidence_score=round(report.overall_confidence, 4),
        last_updated=report.last_updated,
    )

    logger.info("[Orchestrator] Done in %.3fs  conf=%.2f  steps=%d  kp=%d",
                elapsed, response.confidence_score, len(steps), len(response.key_points))
    return response

__all__ = ["OrchestratorError", "OrchestratorResponse", "run_orchestrator"]
'''

# ============================================================
# Write all files
for name, content in FILES.items():
    path = BASE / name
    path.write_text(content, encoding="utf-8")
    print(f"✅ Written: {name}  ({path.stat().st_size} bytes)")

print("\nAll agent files written successfully.")
