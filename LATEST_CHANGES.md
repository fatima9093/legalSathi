# Legal Sathi — Latest Changes Summary

_Last updated: 2026-03-15_

## 1) Multi-Agent Backend Overhaul

### New/rewritten agent modules
- `Backend/law_retrieval_agent.py`
  - Rebuilt retrieval pipeline for local ChromaDB + official web sources.
  - Added module inference, query expansion, lexical/semantic alignment, trusted-domain filtering.
  - Added `retrieval_score` and stronger dedup/ranking logic.
- `Backend/verification_agent.py`
  - Added stricter verification model with:
    - confidence, recency, relevance, overall scoring
    - trusted source ratio
    - freshness status (`current` / `mixed` / `stale`)
    - official confirmation requirement flag
    - verification note for user-facing safety.
- `Backend/explanation_agent.py`
  - Improved prompt and query-focus enforcement.
  - Filters generic drift and keeps answers tied to user intent.
  - Better fallback behavior when documents are not available.
- `Backend/guidance_agent.py`
  - Improved step-by-step guidance generation and practical output.
  - Uses verified official links per module.
- `Backend/agent_orchestrator.py`
  - Expanded orchestration across retrieval → verification → explanation → guidance.
  - Added context-aware query handling via `conversation_context`.
  - Added second retrieval pass for weak-evidence cases.
  - Rich response now includes verification/freshness/relevance metadata.

### New context module
- `Backend/conversation_context.py`
  - Builds standalone legal queries using conversation history + memory summary.
  - Includes in-memory session cache with TTL and cleanup.

### Groq configuration centralization
- `Backend/groq_config.py`
  - Central constants and API setup for all agent modules.

## 2) Backend API Enhancements

### `Backend/main.py`
- Added agent pipeline availability checks and graceful fallback behavior.
- Extended request/response models with:
  - `conversation_id`, `conversation_history`
  - verification/freshness/relevance fields
  - `response_length` control.
- Added endpoints:
  - `POST /api/ask/agent` (dedicated multi-agent endpoint)
  - `POST /api/ask/stream` (SSE token streaming endpoint)
- Improved RAG routing logic:
  - stronger threshold handling
  - automatic escalation to agent pipeline on weak/uncertain evidence.

## 3) Retrieval & DB Utility Updates

- `Backend/create_vectordb.py`
  - Path handling now uses absolute script-relative `chroma_db` path.
- `Backend/query_vectordb.py`
  - Same absolute path update for reliability.
- ChromaDB storage artifacts changed in `Backend/chroma_db/` (index/data binaries refreshed).

## 4) Frontend Chat System Major Upgrade

### Main chat screen
- `frontend/lib/chat_screen.dart`
  - Added streaming response UX with stop-generation support.
  - Added message actions: copy, edit/resend, regenerate, share, delete, rating.
  - Added prompt templates and quick prompts.
  - Added file attachment UX chips and export chat support.
  - Added response length modes: short / detailed / bullets.
  - Added dynamic query insights + suggested follow-up actions.
  - Added multi-agent stage indicator integration.
  - Reworked chat history behavior:
    - save current conversation snapshots
    - load from sidebar
    - delete active history safely.
  - Dark mode code paths removed as requested (light-theme-only behavior retained).

### New/updated frontend services
- `frontend/lib/services/agent_service.dart`
  - Typed multi-agent request/response models and stage transitions.
- `frontend/lib/services/llm_service.dart`
  - Added SSE stream parser (`sendMessageStream`) with event types:
    - token, meta, error, done.
  - Added conversation history and response length payload support.
- `frontend/lib/widgets/agent_status_widget.dart`
  - New multi-agent progress UI and structured agent response card.

### Chat history model
- `frontend/lib/models/chat_history_model.dart`
  - Made `title` mutable for rename support.
  - Message snapshots now dynamic to avoid circular imports.
  - Removed duplicate conflicting `ChatMessage` model definition.

## 5) Dependency & Plugin Updates

### Backend deps
- `Backend/requirements.txt`
  - Updated `pydantic` to `>=2.12.2,<3`
  - Added `openai-agents`
  - Added `beautifulsoup4`.

### Frontend deps
- `frontend/pubspec.yaml`
  - Added `flutter_markdown`
  - Added `share_plus`.
- `frontend/pubspec.lock`
  - Lockfile updated for new packages/transitives.
- Generated platform plugin updates:
  - `frontend/macos/Flutter/GeneratedPluginRegistrant.swift`
  - `frontend/windows/flutter/generated_plugin_registrant.cc`
  - `frontend/windows/flutter/generated_plugins.cmake`.

## 6) Verification/Health Notes

- Analyzer checks completed successfully on key updated Dart files (`chat_screen.dart`, `agent_service.dart`, `llm_service.dart`).
- Core chat UX and agent orchestration paths are now integrated end-to-end.

## 7) Current Known Limitation

- Chat history is currently in-memory/session-based on the frontend and is not yet persisted to local storage or backend database across app restarts.

---

If needed, I can also prepare a second file with a **commit-ready changelog format** (`Added/Changed/Fixed`) for release notes.
