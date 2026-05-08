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


def _strip_json(text: str) -> Any:
    text = re.sub(r"```(?:json)?", "", text).strip().rstrip("`").strip()
    return json.loads(text)


# =========================================================================
# ENHANCEMENT 4B: Local Resource Mapping
# =========================================================================

_LOCAL_RESOURCES: Dict[str, Dict[str, Dict[str, str]]] = {
    "women_harassment": {
        "lahore": {
            "Punjab Women Protection Cell": "https://lahore.gov.pk/women-protection",
            "Aurat Aman Project": "https://www.aurataman.com",
            "Legal Aid Authority (Lahore)": "https://laa.org.pk",
        },
        "karachi": {
            "Karachi Women Shelter": "https://sindh.gov.pk/women-services",
            "Karachi Bar Association (Gender Cell)": "https://kba.org.pk",
            "Sindh Commission on Rights of Child": "https://scrc.gov.pk",
        },
        "islamabad": {
            "Federal Legal Aid": "https://fld.gov.pk",
            "Capital Police Women Desk": "https://islamabad.police.gov.pk",
        },
        "peshawar": {
            "Khyber Pakhtunkhwa Women Protection Center": "https://kp.gov.pk/women",
            "KP Legal Aid Authority": "https://kplaa.gov.pk",
        }
    },
    "labour_rights": {
        "lahore": {
            "Punjab Labour Court": "https://punjablabourcourt.gov.pk",
            "Punjab Workers Union": "Contact: 031-1234-5678",
            "EOBI Lahore Office": "https://eobi.gov.pk",
        },
        "karachi": {
            "Sindh Labour Court": "https://sindhlabourtribunal.gov.pk",
            "Karachi Chamber of Commerce": "https://kcci.com.pk",
        },
        "islamabad": {
            "Federal Labour Court": "https://flc.org.pk",
        }
    },
    "cyber_law": {
        "lahore": {
            "FIA Cyber Crime Wing (Lahore)": "https://fia.gov.pk/en/cybercrime",
            "Punjab IT Board": "https://pitb.gov.pk",
        },
        "karachi": {
            "FIA Cyber Crime Wing (Karachi)": "https://fia.gov.pk/en/cybercrime",
        },
        "islamabad": {
            "FIA Headquarters": "https://fia.gov.pk",
            "PTA": "https://pta.gov.pk",
        }
    },
    "road_laws": {
        "lahore": {
            "Lahore Traffic Police": "https://traffic.punjabpolice.gov.pk",
            "Lahore High Court (Transport Bench)": "https://lhc.gov.pk",
        },
        "karachi": {
            "Karachi Traffic Police": "https://www.ktp.gov.pk",
        },
        "islamabad": {
            "Islamabad Police Traffic": "https://islamabad.police.gov.pk",
        }
    }
}


def _get_links(module: Optional[str], location: Optional[str] = None) -> Dict[str, str]:
    """Get official links, optionally merged with local resources."""
    official = dict(_OFFICIAL_LINKS.get(module or "_general", _OFFICIAL_LINKS["_general"]))
    
    # ENHANCEMENT 4B: Add local resources if location specified
    if location and location.lower() in _LOCAL_RESOURCES.get(module or "", {}):
        local = _LOCAL_RESOURCES[module or ""][location.lower()]
        official.update(local)
        logger.info(f"[Local Resources] Added {len(local)} local resources for {module} in {location}")
    
    return official


# =========================================================================
# ENHANCEMENT 4A: Context-Aware Personalization
# =========================================================================

class UserContext(BaseModel):
    """User context for personalized guidance."""
    location: Optional[str] = None  # city/province
    tech_level: Optional[str] = "medium"  # low, medium, high
    education: Optional[str] = "high_school"  # primary, high_school, bachelor, master
    language_preference: str = "English"
    urgency: Optional[str] = "normal"  # normal, urgent, emergency


async def _personalize_system_prompt(
    base_prompt: str,
    user_context: Optional[UserContext]
) -> str:
    """Adapt system prompt based on user context."""
    if not user_context:
        return base_prompt
    
    customizations = []
    
    if user_context.tech_level == "low":
        customizations.append("- Avoid technical jargon. Explain each step simply.")
        customizations.append("- Provide phone numbers and offline alternatives.")
    elif user_context.tech_level == "high":
        customizations.append("- Include technical details and legal references.")
        customizations.append("- Mention procedures available through online portals.")
    
    if user_context.location and user_context.location.lower() in ["rural", "village", "countryside"]:
        customizations.append("- Prioritize offline and in-person methods.")
        customizations.append("- Include nearest government office locations.")
        customizations.append("- Suggest local NGO support where available.")
    
    if user_context.urgency == "urgent":
        customizations.append("- Prioritize immediate steps for evidence preservation.")
        customizations.append("- Emphasize time-sensitive deadlines.")
    elif user_context.urgency == "emergency":
        customizations.append("- Start with emergency safety measures.")
        customizations.append("- Provide 24/7 helpline numbers prominently.")
    
    if customizations:
        return base_prompt + "\n\nUSER-SPECIFIC CUSTOMIZATIONS:\n" + "\n".join(customizations)
    
    return base_prompt


def _system_prompt(language: str, max_steps: int, module: Optional[str],
                   official_links: Dict[str, str], user_context: Optional[UserContext] = None) -> str:
    module_hint = {
        "women_harassment": "workplace or public harassment under Pakistani law",
        "labour_rights":    "labour rights and employment disputes in Pakistan",
        "cyber_law":        "cybercrime and digital offences under Pakistani law",
        "road_laws":        "road traffic laws and violations in Pakistan",
    }.get(module or "", "a Pakistani legal matter")

    links_block = "\n".join(f"  - {k}: {v}" for k, v in official_links.items())

    base_prompt = textwrap.dedent(f"""
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
    
    # Would be called as: await _personalize_system_prompt(base_prompt, user_context)
    # For now, we'll add it synchronously
    return base_prompt


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
    user_context: Optional[UserContext] = None,
) -> GuidanceOutput:
    """
    Generate step-by-step guidance with optional personalization.
    ENHANCEMENTS:
    - Context-aware (urban/rural, tech level)
    - Local resource mapping
    """
    if not explanation.summary and not explanation.key_points:
        raise GuidanceError("Explanation has no content to generate guidance from.")

    max_steps      = max(1, min(20, max_steps))
    
    # Get official links and merge with local resources
    official_links = _get_links(module, user_context.location if user_context else None)
    if official_links_hint:
        official_links.update(official_links_hint)

    try:
        system_msg = _system_prompt(language, max_steps, module, official_links, user_context)
        
        # Personalize if user context provided
        if user_context:
            system_msg = await _personalize_system_prompt(system_msg, user_context)
        
        resp = await _CLIENT.chat.completions.create(
            model=GROQ_MODEL_STRONG,
            messages=[
                {"role":"system","content":system_msg},
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
    
    logger.info(
        "[Guidance] Generated %d steps | Location: %s | Tech level: %s",
        len(output.steps),
        user_context.location if user_context else "not specified",
        user_context.tech_level if user_context else "not specified"
    )
    
    return output


async def run_guidance_agent_personalized(
    explanation: ExplanationOutput,
    module: Optional[str] = None,
    language: str = "English",
    location: Optional[str] = None,
    tech_level: str = "medium",
    education: str = "high_school",
    urgency: str = "normal",
    query: str = "",
) -> GuidanceOutput:
    """
    Convenience wrapper for run_guidance_agent with user context.
    """
    user_context = UserContext(
        location=location,
        tech_level=tech_level,
        education=education,
        language_preference=language,
        urgency=urgency
    )
    
    return await run_guidance_agent(
        explanation=explanation,
        module=module,
        language=language,
        user_context=user_context,
        query=query
    )


__all__ = [
    "GuidanceError",
    "GuidanceOutput",
    "GuidanceStep",
    "UserContext",
    "run_guidance_agent",
    "run_guidance_agent_personalized",
]
