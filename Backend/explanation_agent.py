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
_RELEVANCE_STOPWORDS = {
    "the", "and", "for", "with", "from", "this", "that", "what", "how", "when", "where",
    "about", "your", "you", "are", "was", "were", "can", "could", "should", "would",
    "law", "legal", "pakistan", "rights", "help", "please",
}

# ---------------------------------------------------------------------------
class ExplanationOutput(BaseModel):
    summary:    str
    key_points: List[str]
    references: Dict[str, str]


# =========================================================================
# ENHANCEMENT 3A: Structured Knowledge Extraction
# =========================================================================

class StructuredExplanation(BaseModel):
    """Enhanced explanation with machine-readable structured fields."""
    summary:           str
    key_points:        List[str]
    definitions:       Dict[str, str]  # Legal terms defined
    citations:         List[Dict[str, str]]  # Act/Section references
    procedures:        List[str]  # Step-by-step procedures
    exceptions:        List[str]  # Important exceptions
    penalties:         List[Dict[str, str]]  # Penalties if violated
    references:        Dict[str, str]
    language:          str = "English"


async def _extract_structured_knowledge(
    summary: str,
    key_points: List[str],
    query: str,
    language: str = "English"
) -> Dict[str, Any]:
    """
    Extract machine-readable structured knowledge from explanation.
    Useful for app to display as cards/sections.
    """
    extraction_prompt = f"""Extract structured legal knowledge from this content:

Summary: {summary}

Key Points:
{chr(10).join(f"- {kp}" for kp in key_points[:5])}

Query: {query}

Respond with ONLY valid JSON with these fields:
- definitions: dict of legal terms used (term: definition)
- citations: list of acts/sections referenced (each with 'act', 'section', 'description')
- procedures: list of procedural steps
- exceptions: list of important exceptions
- penalties: list of penalties (each with 'violation', 'penalty')

Example response:
{{
  "definitions": {{"harassment": "Unwanted conduct creating hostile environment"}},
  "citations": [{{"act": "Protection against Harassment of Women at Workplace Act 2010", "section": "Section 3", "description": "Definition of harassment"}}],
  "procedures": ["Step 1: Document incidents", "Step 2: Report to committee"],
  "exceptions": ["If complaint is false"],
  "penalties": [{{"violation": "Making false complaint", "penalty": "Fine up to Rs 50,000"}}]
}}
"""
    
    try:
        resp = await _CLIENT.chat.completions.create(
            model=GROQ_MODEL_STRONG,
            messages=[{"role": "user", "content": extraction_prompt}],
            temperature=0.1,
            max_tokens=1500
        )
        
        data = _strip_json(resp.choices[0].message.content or "{}")
        return {
            "definitions": data.get("definitions", {}),
            "citations": data.get("citations", []),
            "procedures": data.get("procedures", []),
            "exceptions": data.get("exceptions", []),
            "penalties": data.get("penalties", [])
        }
    except Exception as exc:
        logger.warning(f"Structured knowledge extraction failed: {exc}")
        return {
            "definitions": {},
            "citations": [],
            "procedures": [],
            "exceptions": [],
            "penalties": []
        }


async def run_explanation_agent_structured(
    chunks: List[Dict[str, Any]],
    language: str = "English",
    max_key_points: int = 8,
    query: str = "",
) -> StructuredExplanation:
    """
    Generate structured explanation with definitions, citations, and procedures.
    Better for mobile app UI - can display as cards/sections.
    """
    # First: Get plain-language explanation
    base_explanation = await run_explanation_agent(chunks, language, max_key_points, query)
    
    # Second: Extract structured knowledge
    structured = await _extract_structured_knowledge(
        base_explanation.summary,
        base_explanation.key_points,
        query,
        language
    )
    
    return StructuredExplanation(
        summary=base_explanation.summary,
        key_points=base_explanation.key_points,
        definitions=structured["definitions"],
        citations=structured["citations"],
        procedures=structured["procedures"],
        exceptions=structured["exceptions"],
        penalties=structured["penalties"],
        references=base_explanation.references,
        language=language
    )


# =========================================================================
# ENHANCEMENT 3B: Multilingual Support
# =========================================================================

LANGUAGE_CONFIGS = {
    "English": {
        "name": "English",
        "legal_terms": ["Act", "Section", "Clause", "Provision", "Right"]
    },
    "Urdu": {
        "name": "اردو",
        "legal_terms": ["آرڈیننس", "شق", "حکم", "حق"]
    },
    "Punjabi": {
        "name": "پنجابی",
        "legal_terms": ["قانون", "حصہ", "حکم"]
    }
}


async def run_explanation_agent_multilingual(
    chunks: List[Dict[str, Any]],
    languages: List[str] = None,
    max_key_points: int = 8,
    query: str = "",
) -> Dict[str, ExplanationOutput]:
    """
    Generate explanations in multiple languages simultaneously.
    Supports English, Urdu, Punjabi.
    """
    if languages is None:
        languages = ["English"]  # Default
    
    results: Dict[str, ExplanationOutput] = {}
    
    for lang in languages:
        try:
            if lang not in LANGUAGE_CONFIGS:
                logger.warning(f"Language {lang} not configured, skipping")
                continue
            
            explanation = await run_explanation_agent(chunks, lang, max_key_points, query)
            results[lang] = explanation
            logger.info(f"[Multilingual] Generated explanation in {lang}")
        except Exception as exc:
            logger.warning(f"Multilingual explanation for {lang} failed: {exc}")
    
    return results


class ExplanationError(Exception):
    pass


# =========================================================================
# Original Functions
# =========================================================================


# ---------------------------------------------------------------------------
def _build_context(chunks: List[Dict[str, Any]]) -> str:
    parts: List[str] = []
    total = 0
    for i, c in enumerate(chunks, 1):
        text = (c.get("content") or "").strip()
        src  = (c.get("source_url") or "unknown").strip()
        if not text:
            continue
        entry = f"[Document {i}] Source: {src}\n{text}"
        remaining = _MAX_CONTEXT - total
        if remaining <= 0:
            break
        if len(entry) > remaining:
            entry = entry[:remaining].rstrip() + " [truncated]"
        parts.append(entry)
        total += len(entry)
    return "\n\n---\n\n".join(parts)

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


def _query_terms(query: str, max_terms: int = 12) -> List[str]:
    tokens = re.findall(r"[a-zA-Z][a-zA-Z0-9_-]{2,}", (query or "").lower())
    terms: List[str] = []
    seen: set = set()
    for token in tokens:
        if token in _RELEVANCE_STOPWORDS or token in seen:
            continue
        seen.add(token)
        terms.append(token)
        if len(terms) >= max_terms:
            break
    return terms


def _contains_query_signal(text: str, query_terms: List[str]) -> bool:
    if not text.strip() or not query_terms:
        return True
    lowered = text.lower()
    return any(term in lowered for term in query_terms)


def _enforce_query_focus(output: ExplanationOutput, query: str) -> ExplanationOutput:
    query_terms = _query_terms(query)
    if not query_terms:
        return output

    filtered_points = [
        point for point in output.key_points if _contains_query_signal(point, query_terms)
    ]
    if not filtered_points and output.key_points:
        filtered_points = output.key_points[:2]

    summary = output.summary.strip()
    if not _contains_query_signal(summary, query_terms):
        query_label = query.strip() or "your legal issue"
        summary = (
            f"For your question about '{query_label}', I need one or two specific details "
            "(city/province, exact timeline, and document/evidence you currently have) "
            "to give a fully precise answer. Based on available information, the guidance below is the most relevant legal direction."
        )

    return ExplanationOutput(
        summary=summary,
        key_points=filtered_points,
        references=output.references,
    )

def _system_prompt(language: str, max_key_points: int) -> str:
    return textwrap.dedent(f"""
                You are Legal Sathi, an empathetic Pakistani legal assistant.
                Produce a structured explanation in **{language}** that is grounded in the user's exact question.

        Return ONLY a valid JSON object with exactly these keys:
        {{
                        "summary": "<4-8 sentence plain-language answer tailored to the exact user question>",
            "key_points": ["<up to {max_key_points} key legal points, each a single sentence>"],
            "references": {{}}
        }}

        Rules:
                - Start summary by directly answering the user's question in 1-2 sentences.
                - Keep tone calm, respectful, and supportive (especially for distressing topics).
                - Use plain language and explain legal terms briefly where needed.
                - If documents are provided, base your answer on them.
        - Every sentence must stay directly relevant to the user question; do not drift to unrelated legal topics.
        - If documents are mixed, prioritize the passages most connected to the question and ignore unrelated passages.
        - If NO documents are provided, answer from your general knowledge of Pakistani law
                    and clearly state that it is general legal information.
                - Avoid generic textbook content not relevant to the user's query.
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
    q = query.strip() or "the legal question"

    if context_block.strip():
        user_msg = (
            f"User question: {q}\n\n"
            "Use the excerpts below to answer this exact question. "
            "If excerpts are partially relevant, still answer directly and say what is uncertain."
            f"\n\nDocument excerpts:\n\n{context_block}"
        )
    else:
        user_msg = (
            f"No local documents were retrieved. Answer from your general knowledge "
            f"of Pakistani law:\n\n{q}"
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
    return _enforce_query_focus(output, q)


__all__ = [
    "ExplanationError",
    "ExplanationOutput",
    "StructuredExplanation",
    "run_explanation_agent",
    "run_explanation_agent_structured",
    "run_explanation_agent_multilingual",
]
