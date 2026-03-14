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
from conversation_context import build_contextual_query
from law_retrieval_agent  import LawRetrievalError,  run_law_retrieval_agent
from verification_agent   import VerificationReport,  run_verification_agent
from explanation_agent    import ExplanationError,    run_explanation_agent
from guidance_agent       import GuidanceError,       run_guidance_agent

logger = logging.getLogger(__name__)

_VALID_MODULES = frozenset({"women_harassment","labour_rights","cyber_law","road_laws"})

_MODULE_HINTS = {
    "women_harassment": ["harass", "sexual harassment", "stalking", "workplace harassment", "blackmail"],
    "labour_rights": ["salary", "wage", "employer", "employee", "termination", "resign", "resignation", "probation", "contract", "leave", "overtime"],
    "cyber_law": ["cyber", "online", "hack", "hacking", "social media", "fake account", "identity", "fraud", "whatsapp", "facebook"],
    "road_laws": ["traffic", "driving", "license", "licence", "vehicle", "challan", "fine", "speeding", "accident"],
}

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
    relevance_score:    float                = 0.0
    last_updated:       Optional[str]        = None
    verification_status: str                 = "unverified"
    verification_note:   Optional[str]       = None
    requires_official_confirmation: bool     = True
    trusted_source_ratio: float              = 0.0
    freshness_status: str                    = "unknown"

class OrchestratorError(Exception):
    pass

# ---------------------------------------------------------------------------
def _build_answer(
    query: str,
    summary: str,
    key_points: List[str],
    steps: List[Dict[str, Any]],
    confidence_score: float,
    verification_note: Optional[str] = None,
    requires_official_confirmation: bool = True,
) -> str:
    q = (query or "").lower()
    is_sensitive = any(k in q for k in [
        "harass", "abuse", "violence", "assault", "threat", "scared", "urgent", "fired", "termination"
    ])

    parts: List[str] = []
    if is_sensitive:
        parts.append("I understand this situation can feel stressful. You deserve clear support, and I’ll keep this practical.")

    if summary:
        parts.append(summary)

    if key_points:
        highlights = "\n".join(f"- {p}" for p in key_points[:2])
        parts.append(f"Most relevant points for your question:\n{highlights}")

    if steps:
        step_lines: List[str] = []
        for idx, step in enumerate(steps[:2], 1):
            title = (step.get("title") or "").strip()
            desc = (step.get("description") or "").strip()
            if title and desc:
                step_lines.append(f"{idx}. {title}: {desc}")
            elif desc:
                step_lines.append(f"{idx}. {desc}")
        if step_lines:
            parts.append("What to do next:\n" + "\n".join(step_lines))

    if confidence_score < 0.45:
        parts.append(
            "To make this more precise, share a few details (province/city, timeline, and your role in the case)."
        )

    if verification_note:
        parts.append(f"Verification status: {verification_note}")

    if requires_official_confirmation:
        parts.append(
            "Before final legal action, confirm with latest official gazette/department notification or a licensed lawyer."
        )

    return "\n\n".join(parts) or "Please consult a qualified legal professional."

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


def _merge_chunks(primary: List[Dict[str, Any]], secondary: List[Dict[str, Any]], max_items: int = 30) -> List[Dict[str, Any]]:
    out: List[Dict[str, Any]] = []
    seen: set = set()
    for item in (primary or []) + (secondary or []):
        text = " ".join((item.get("content") or "").split()).lower()[:700]
        src = (item.get("source_url") or "").strip().lower()
        key = f"{src}|{text}"
        if not text or key in seen:
            continue
        seen.add(key)
        out.append(item)
        if len(out) >= max_items:
            break
    return out


def _select_context_chunks(report: VerificationReport) -> List[Dict[str, Any]]:
    if report.verified:
        return [c.model_dump() for c in report.verified]
    if report.discarded:
        top_discarded = sorted(report.discarded, key=lambda c: c.overall_score, reverse=True)[:3]
        return [c.model_dump() for c in top_discarded]
    return []


def _resolve_module(explicit_module: Optional[str], chunks: List[Dict[str, Any]]) -> Optional[str]:
    if explicit_module:
        return explicit_module
    for c in chunks:
        m = c.get("module")
        if isinstance(m, str) and m in _VALID_MODULES:
            return m
    return None


def _infer_module_from_query(query: str) -> Optional[str]:
    q = (query or "").lower()
    if not q:
        return None
    best_module: Optional[str] = None
    best_score = 0
    for module_name, hints in _MODULE_HINTS.items():
        score = sum(1 for h in hints if h in q)
        if score > best_score:
            best_score = score
            best_module = module_name
    return best_module if best_score > 0 else None

# ---------------------------------------------------------------------------
async def run_orchestrator(
    query: str,
    module: Optional[str]            = None,
    language: str                    = "English",
    retrieval_limit: int             = 5,
    max_key_points: int              = 8,
    max_steps: int                   = 10,
    official_links_hint: Optional[Dict[str, str]] = None,
    conversation_id: Optional[str]   = None,
    conversation_history: Optional[List[Dict[str, Any]]] = None,
) -> OrchestratorResponse:
    query = (query or "").strip()
    if not query:
        raise OrchestratorError("Query must not be empty.")
    if module is not None and module not in _VALID_MODULES:
        raise OrchestratorError(f"Invalid module \"{module}\".")

    context_result = await build_contextual_query(
        query=query,
        conversation_id=conversation_id,
        conversation_history=conversation_history,
    )
    resolved_query = (context_result.standalone_query or query).strip() or query

    inferred_module = _infer_module_from_query(resolved_query)
    effective_module = module or inferred_module

    retrieval_limit = max(1, min(20, retrieval_limit))
    max_key_points  = max(1, min(20, max_key_points))
    max_steps       = max(1, min(20, max_steps))
    start           = time.monotonic()

    # ---- Stage 1: Retrieval -----------------------------------------------
    logger.info(
        "[Orchestrator] Stage 1: retrieval query=%r resolved=%r module=%s",
        query,
        resolved_query,
        effective_module,
    )
    try:
        raw_chunks = await run_law_retrieval_agent(query=resolved_query, module=effective_module, limit=retrieval_limit)
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
            query=resolved_query, raw_chunks=raw_chunks
        )
    except Exception as exc:
        logger.exception("[Orchestrator] Verification error: %s — using all raw chunks", exc)
        from verification_agent import VerifiedChunk, VerificationReport as VR
        report = VR(verified=[], discarded=[], overall_confidence=0.5, last_updated=None)

    verified_dicts: List[Dict[str, Any]] = _select_context_chunks(report)

    needs_research_pass = (len(report.verified) < 2) or (report.overall_confidence < 0.55)
    if needs_research_pass:
        logger.info(
            "[Orchestrator] Low evidence detected (verified=%d, conf=%.2f). Running second retrieval pass.",
            len(report.verified), report.overall_confidence
        )
        try:
            extra_raw = await run_law_retrieval_agent(
                query=resolved_query,
                module=effective_module,
                limit=min(20, retrieval_limit + 5),
            )
            merged_raw = _merge_chunks(raw_chunks, extra_raw, max_items=30)
            if len(merged_raw) > len(raw_chunks):
                raw_chunks = merged_raw
                report = await run_verification_agent(
                    query=resolved_query,
                    raw_chunks=raw_chunks,
                    min_overall_score=0.30 if report.overall_confidence < 0.40 else 0.35,
                )
                verified_dicts = _select_context_chunks(report)
                logger.info(
                    "[Orchestrator] Second pass improved evidence: verified=%d conf=%.2f",
                    len(report.verified), report.overall_confidence
                )
        except Exception as exc:
            logger.warning("[Orchestrator] Second retrieval pass failed: %s", exc)

    logger.info("[Orchestrator] Stage 2 complete: %d verified  conf=%.2f",
                len(report.verified), report.overall_confidence)

    # ---- Stage 3: Explanation ---------------------------------------------
    logger.info("[Orchestrator] Stage 3: explanation")
    try:
        explanation = await run_explanation_agent(
            chunks=verified_dicts, language=language,
            max_key_points=max_key_points, query=resolved_query,
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
            explanation=explanation, module=effective_module, language=language,
            max_steps=max_steps, official_links_hint=official_links_hint,
            query=resolved_query,
        )
    except GuidanceError as exc:
        raise OrchestratorError(f"Guidance failed: {exc}") from exc
    except Exception as exc:
        logger.exception("[Orchestrator] Guidance error: %s", exc)
        raise OrchestratorError("Guidance encountered an unexpected error.") from exc

    # ---- Assemble ---------------------------------------------------------
    steps   = _coerce_steps(guidance)
    elapsed = round(time.monotonic() - start, 3)

    resolved_module = _resolve_module(effective_module, verified_dicts)

    response = OrchestratorResponse(
        answer=_build_answer(
            query=query,
            summary=explanation.summary,
            key_points=explanation.key_points or [],
            steps=steps,
            confidence_score=report.overall_confidence,
            verification_note=report.verification_note,
            requires_official_confirmation=report.requires_official_confirmation,
        ),
        summary=explanation.summary or "",
        key_points=explanation.key_points or [],
        steps=steps,
        required_documents=guidance.required_documents or [],
        references=_collect_refs(verified_dicts),
        official_links=guidance.official_links or {},
        notes=(
            f"{guidance.notes}\n\nVerification: {report.verification_note}"
            if guidance.notes and report.verification_note
            else (guidance.notes or report.verification_note)
        ),
        module=resolved_module,
        query=query,
        elapsed_seconds=elapsed,
        confidence_score=round(report.overall_confidence, 4),
        relevance_score=round(report.average_relevance_score, 4),
        last_updated=report.last_updated,
        verification_status=(
            "verified"
            if not report.requires_official_confirmation
            else "needs_confirmation"
        ),
        verification_note=report.verification_note,
        requires_official_confirmation=report.requires_official_confirmation,
        trusted_source_ratio=round(report.trusted_source_ratio, 4),
        freshness_status=report.freshness_status,
    )

    logger.info("[Orchestrator] Done in %.3fs  conf=%.2f  steps=%d  kp=%d",
                elapsed, response.confidence_score, len(steps), len(response.key_points))
    return response

__all__ = ["OrchestratorError", "OrchestratorResponse", "run_orchestrator"]
