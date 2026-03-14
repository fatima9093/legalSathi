"""
conversation_context.py
=======================
Builds a context-aware standalone query from prior chat turns.
Uses a lightweight in-memory session cache plus a fast Groq model rewrite pass.
"""
from __future__ import annotations

import json
import logging
import re
import time
from typing import Any, Dict, List, Optional

from openai import AsyncOpenAI
from pydantic import BaseModel

import groq_config  # noqa: F401
from groq_config import GROQ_MODEL_FAST, _GROQ_API_KEY, _GROQ_BASE_URL

logger = logging.getLogger(__name__)
_CLIENT = AsyncOpenAI(api_key=_GROQ_API_KEY, base_url=_GROQ_BASE_URL)

_MAX_TURNS = 10
_MAX_SESSIONS = 500
_SESSION_TTL_SECONDS = 60 * 60 * 6  # 6 hours


class ContextualizedQuery(BaseModel):
    standalone_query: str
    memory_summary: str = ""
    used_history: bool = False


_SESSION_MEMORY: Dict[str, Dict[str, Any]] = {}


def _strip_json(text: str) -> Any:
    cleaned = re.sub(r"```(?:json)?", "", text or "").strip().rstrip("`").strip()
    return json.loads(cleaned or "{}")


def _cleanup_sessions() -> None:
    if not _SESSION_MEMORY:
        return
    now = time.time()
    expired = [sid for sid, payload in _SESSION_MEMORY.items() if now - payload.get("updated_at", now) > _SESSION_TTL_SECONDS]
    for sid in expired:
        _SESSION_MEMORY.pop(sid, None)
    if len(_SESSION_MEMORY) <= _MAX_SESSIONS:
        return
    oldest = sorted(_SESSION_MEMORY.items(), key=lambda kv: kv[1].get("updated_at", 0.0))
    for sid, _ in oldest[: max(0, len(_SESSION_MEMORY) - _MAX_SESSIONS)]:
        _SESSION_MEMORY.pop(sid, None)


def _sanitize_turns(history: Optional[List[Dict[str, Any]]]) -> List[Dict[str, str]]:
    out: List[Dict[str, str]] = []
    for turn in history or []:
        role = str(turn.get("role") or "").strip().lower()
        content = str(turn.get("content") or "").strip()
        if not content:
            continue
        if role not in {"user", "assistant"}:
            continue
        out.append({"role": role, "content": content})
    if len(out) > _MAX_TURNS:
        out = out[-_MAX_TURNS:]
    return out


def _history_block(turns: List[Dict[str, str]]) -> str:
    if not turns:
        return "(no history)"
    lines = []
    for idx, turn in enumerate(turns, 1):
        lines.append(f"[{idx}] {turn['role'].upper()}: {turn['content']}")
    return "\n".join(lines)


async def build_contextual_query(
    query: str,
    conversation_id: Optional[str] = None,
    conversation_history: Optional[List[Dict[str, Any]]] = None,
) -> ContextualizedQuery:
    raw_query = (query or "").strip()
    if not raw_query:
        return ContextualizedQuery(standalone_query="", memory_summary="", used_history=False)

    _cleanup_sessions()
    turns = _sanitize_turns(conversation_history)

    memory_summary = ""
    if conversation_id and conversation_id in _SESSION_MEMORY:
        memory_summary = str(_SESSION_MEMORY[conversation_id].get("summary") or "").strip()

    if not turns and not memory_summary:
        return ContextualizedQuery(
            standalone_query=raw_query,
            memory_summary="",
            used_history=False,
        )

    system_prompt = (
        "You rewrite Pakistani legal follow-up questions into standalone queries. "
        "Use prior turns only when relevant. Do not change legal meaning. "
        "Return ONLY JSON with keys: standalone_query, memory_summary, used_history."
    )

    user_prompt = (
        f"Current user query:\n{raw_query}\n\n"
        f"Existing memory summary:\n{memory_summary or '(none)'}\n\n"
        f"Conversation turns:\n{_history_block(turns)}\n\n"
        "Instructions:\n"
        "1) If query depends on previous turns (pronouns like it/that/this case), rewrite as standalone.\n"
        "2) If query is new topic, keep it as-is.\n"
        "3) Memory summary should be 1-2 short lines of the current case context.\n"
    )

    try:
        resp = await _CLIENT.chat.completions.create(
            model=GROQ_MODEL_FAST,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt},
            ],
            response_format={"type": "json_object"},
            temperature=0.0,
            max_tokens=220,
        )
        data = _strip_json(resp.choices[0].message.content or "{}")
        standalone_query = str(data.get("standalone_query") or raw_query).strip() or raw_query
        updated_memory = str(data.get("memory_summary") or memory_summary).strip()
        used_history = bool(data.get("used_history"))
    except Exception as exc:
        logger.warning("Context rewrite failed: %s", exc)
        standalone_query = raw_query
        updated_memory = memory_summary
        used_history = bool(turns or memory_summary)

    if conversation_id:
        _SESSION_MEMORY[conversation_id] = {
            "summary": updated_memory,
            "updated_at": time.time(),
        }

    return ContextualizedQuery(
        standalone_query=standalone_query,
        memory_summary=updated_memory,
        used_history=used_history,
    )


__all__ = ["ContextualizedQuery", "build_contextual_query"]
