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

    links_block = "\n".join(f"  - {k}: {v}" for k, v in official_links.items())

    return textwrap.dedent(f"""
        You are Legal Sathi, an empathetic Pakistani legal advisor producing step-by-step guidance for a citizen.
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
        2. Each step must be specific, practical, and relevant to the exact user question.
        3. Keep language simple and supportive; avoid harsh or judgmental tone.
        4. If matter seems urgent/safety-sensitive, put immediate safety and evidence-preservation first.
        5. Populate official_links ONLY from the verified list below.
        6. No markdown outside the JSON.

        VERIFIED OFFICIAL LINKS (use only these):
        {links_block}
    """).strip()

def _input_block(explanation: ExplanationOutput, query: str = "") -> str:
    kp = "\n".join(f"- {p}" for p in (explanation.key_points or []))
    user_question = query.strip() or "(not provided)"
    return f"User Question:\n{user_question}\n\nSummary:\n{explanation.summary}\n\nKey Points:\n{kp}"

# ---------------------------------------------------------------------------
async def run_guidance_agent(
    explanation: ExplanationOutput,
    module: Optional[str] = None,
    language: str = "English",
    max_steps: int = 10,
    official_links_hint: Optional[Dict[str, str]] = None,
    query: str = "",
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
                {"role":"user","content":f"Produce guidance from this explanation:\n\n{_input_block(explanation, query)}"},
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
