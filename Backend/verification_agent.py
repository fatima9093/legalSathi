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
_RECENCY_DECAY_YEARS = 8
_HARD_STALE_YEARS = 15

_CURRENCY_WARNING_PATTERNS = [
    re.compile(r"\brepeal(?:ed|s)?\b", re.IGNORECASE),
    re.compile(r"\bsupersed(?:ed|es)\b", re.IGNORECASE),
    re.compile(r"\brescinded\b", re.IGNORECASE),
    re.compile(r"\bwithdrawn\b", re.IGNORECASE),
    re.compile(r"\bno longer in force\b", re.IGNORECASE),
]

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
    average_relevance_score: float = 0.0
    last_updated:       Optional[str]
    trusted_source_ratio: float = 0.0
    freshness_status: str = "unknown"
    requires_official_confirmation: bool = True
    verification_note: Optional[str] = None

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


def _age_years(last_updated: Optional[str]) -> Optional[float]:
    if not last_updated:
        return None
    try:
        dt = datetime.fromisoformat(last_updated)
        if dt.tzinfo is None:
            dt = dt.replace(tzinfo=timezone.utc)
        return (datetime.now(timezone.utc) - dt).days / 365.25
    except Exception:
        return None


def _currency_warning(content: str) -> Optional[str]:
    text = (content or "")[:3000]
    for pattern in _CURRENCY_WARNING_PATTERNS:
        if pattern.search(text):
            return f"possible outdated/repealed reference detected ({pattern.pattern})"
    return None


def _trusted_ratio(chunks: List[VerifiedChunk]) -> float:
    if not chunks:
        return 0.0
    trusted = 0
    for c in chunks:
        if c.source_type == "official_web" or ".gov.pk" in (c.source_url or ""):
            trusted += 1
    return round(trusted / len(chunks), 4)


def _freshness_status(chunks: List[VerifiedChunk]) -> str:
    if not chunks:
        return "unknown"
    recency_values = [c.recency_score for c in chunks]
    if all(v >= 0.60 for v in recency_values):
        return "current"
    if all(v < 0.20 for v in recency_values):
        return "stale"
    return "mixed"


def _verification_note(
    verified: List[VerifiedChunk],
    discarded: List[VerifiedChunk],
    confidence: float,
    trusted_ratio: float,
    freshness_status: str,
    requires_confirmation: bool,
) -> str:
    if not verified:
        return "No strong verified legal sources were found for this query. Please verify with latest official notifications."
    if requires_confirmation:
        return (
            f"Verification is partial (confidence {confidence:.2f}, trusted sources {trusted_ratio:.0%}, "
            f"freshness: {freshness_status}). Confirm with latest official gazette/department update before acting."
        )
    return (
        f"Verified against trusted/current sources (confidence {confidence:.2f}, trusted sources {trusted_ratio:.0%}, "
        f"freshness: {freshness_status})."
    )

def _most_recent(chunks: List[VerifiedChunk]) -> Optional[str]:
    dates = [c.last_updated for c in chunks if c.last_updated]
    return max(dates, default=None)

def _strip_json(text: str) -> Any:
    text = re.sub(r"```(?:json)?", "", text).strip().rstrip("`").strip()
    return json.loads(text)

async def _llm_relevance(query: str, chunks: List[Dict[str, Any]]) -> List[float]:
    if not chunks:
        return []
    numbered = "\n\n".join(f"[{i+1}] {c['content'][:600]}" for i, c in enumerate(chunks))
    system = (
        "You are a legal relevance evaluator for Pakistani law. "
        "Given a user query and numbered document snippets, return a JSON object "
        "with a single key \"scores\" whose value is a list of floats 0.0-1.0 "
        "(one per snippet, higher = more relevant). Respond with ONLY valid JSON."
    )
    try:
        resp = await _CLIENT.chat.completions.create(
            model=GROQ_MODEL_FAST,
            messages=[{"role":"system","content":system},
                      {"role":"user","content":f"Query: {query}\n\nSnippets:\n{numbered}"}],
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
        flag_reasons: List[str] = []
        if overall < min_overall_score:
            flag_reasons.append(f"low score ({overall:.2f})")

        age_years = _age_years(chunk.get("last_updated"))
        if age_years is not None and age_years > _HARD_STALE_YEARS and chunk.get("source_type") != "official_web":
            flag_reasons.append(f"source appears too old ({age_years:.1f} years)")

        warning = _currency_warning(chunk.get("content", ""))
        if warning:
            flag_reasons.append(warning)

        flag = len(flag_reasons) > 0
        vc = VerifiedChunk(
            content=chunk.get("content",""), source_url=chunk.get("source_url",""),
            source_type=chunk.get("source_type","unknown"), module=chunk.get("module"),
            filename=chunk.get("filename"), last_updated=chunk.get("last_updated"),
            confidence_score=src_conf, recency_score=rec_score,
            relevance_score=rel_score, overall_score=overall,
            flagged=flag, flag_reason=("; ".join(flag_reasons) if flag else None),
        )
        (discarded if flag else verified).append(vc)

    verified.sort(key=lambda c: c.overall_score, reverse=True)
    avg = round(sum(c.overall_score for c in verified) / len(verified), 4) if verified else 0.0
    avg_relevance = (
        round(sum(c.relevance_score for c in verified) / len(verified), 4)
        if verified
        else 0.0
    )
    trusted_ratio = _trusted_ratio(verified)
    freshness_status = _freshness_status(verified)
    requires_confirmation = (
        not verified
        or avg < 0.65
        or avg_relevance < 0.55
        or trusted_ratio < 0.60
        or freshness_status != "current"
    )
    note = _verification_note(
        verified=verified,
        discarded=discarded,
        confidence=avg,
        trusted_ratio=trusted_ratio,
        freshness_status=freshness_status,
        requires_confirmation=requires_confirmation,
    )
    logger.info(
        "[Verification] %d verified / %d discarded  avg=%.2f rel=%.2f",
        len(verified),
        len(discarded),
        avg,
        avg_relevance,
    )

    return VerificationReport(verified=verified, discarded=discarded,
                              overall_confidence=avg,
                              average_relevance_score=avg_relevance,
                              last_updated=_most_recent(verified),
                              trusted_source_ratio=trusted_ratio,
                              freshness_status=freshness_status,
                              requires_official_confirmation=requires_confirmation,
                              verification_note=note)

__all__ = ["VerificationError", "VerificationReport", "VerifiedChunk", "run_verification_agent"]
