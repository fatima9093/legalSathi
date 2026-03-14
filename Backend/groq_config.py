"""
groq_config.py
==============
Exports Groq API credentials and model constants used by all agent modules.
All agents use direct AsyncOpenAI calls pointed at Groq's OpenAI-compatible
endpoint — no OpenAI Agents SDK required.

Usage in agent files:
    from groq_config import _GROQ_API_KEY, _GROQ_BASE_URL, GROQ_MODEL_STRONG, GROQ_MODEL_FAST
"""

from __future__ import annotations

import logging
import os
from pathlib import Path

from dotenv import load_dotenv

load_dotenv(dotenv_path=Path(__file__).resolve().parent / ".env")

logger = logging.getLogger(__name__)

_GROQ_API_KEY  = os.getenv("GROQ_API_KEY", "")
_GROQ_BASE_URL = "https://api.groq.com/openai/v1"

# Strong model: best structured-output reliability, higher latency / cost.
GROQ_MODEL_STRONG = "llama-3.3-70b-versatile"

# Fast model: lower latency, suitable for retrieval / simple tasks.
GROQ_MODEL_FAST = "llama-3.1-8b-instant"

if not _GROQ_API_KEY:
    logger.warning(
        "[groq_config] GROQ_API_KEY is not set. "
        "All Groq API calls will fail until it is provided."
    )
else:
    logger.debug("[groq_config] GROQ_API_KEY loaded. Base URL: %s", _GROQ_BASE_URL)
