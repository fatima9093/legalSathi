import os
import re
from pathlib import Path
from datetime import datetime, timezone
# Disable ChromaDB telemetry (stops "Failed to send telemetry event" messages)
os.environ["ANONYMIZED_TELEMETRY"] = "false"

# Configure OpenAI Agents SDK to use Groq before any agent is imported.
import groq_config  # noqa: F401 — side-effects: sets default Groq client

import json
from fastapi import FastAPI, HTTPException, Request as FastAPIRequest
from fastapi.responses import StreamingResponse
from fastapi.middleware.cors import CORSMiddleware
from typing import Any, AsyncIterator, Dict, List, Optional, Union
from pydantic import BaseModel, Field
import chromadb
from chromadb.utils import embedding_functions
from groq import Groq
from dotenv import load_dotenv

# Agent orchestrator — imported lazily so the existing RAG path is unaffected
# if the openai-agents package is not installed.
try:
    from agent_orchestrator import OrchestratorError, OrchestratorResponse, run_orchestrator
    _AGENTS_AVAILABLE = True
except ImportError:
    _AGENTS_AVAILABLE = False
    print("⚠️  agent_orchestrator not found — /api/ask/agent endpoint will be unavailable.")

try:
    from verification_agent import run_verification_agent
    _VERIFICATION_AVAILABLE = True
except ImportError:
    _VERIFICATION_AVAILABLE = False
    print("⚠️  verification_agent not found — strict freshness verification will be limited.")

# Load environment variables from Backend/.env regardless of cwd
BASE_DIR = Path(__file__).resolve().parent
load_dotenv(dotenv_path=BASE_DIR / ".env")

app = FastAPI(title="Legal Sathi RAG API")

# CORS configuration for Flutter web
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # For development - restrict in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize ChromaDB
print("🔄 Loading ChromaDB...")
BASE_DIR = Path(__file__).resolve().parent
CHROMA_DB_PATH = BASE_DIR / "chroma_db"
client = chromadb.PersistentClient(path=str(CHROMA_DB_PATH))
embedding_function = embedding_functions.SentenceTransformerEmbeddingFunction(
    model_name="all-MiniLM-L6-v2"
)

try:
    collection = client.get_collection(
        name="legal_documents",
        embedding_function=embedding_function
    )
    print(f"✅ ChromaDB loaded! Total chunks: {collection.count()}")
except Exception as e:
    print(f"❌ Error loading ChromaDB: {e}")
    if "no such column" in str(e).lower() or "topic" in str(e).lower():
        print(f"   → Your DB was created with a different ChromaDB version. Delete folder '{CHROMA_DB_PATH}' and run: python create_vectordb.py")
    collection = None

# Initialize Groq
GROQ_API_KEY = os.getenv("GROQ_API_KEY")
groq_client = None
try:
    groq_client = Groq(api_key=GROQ_API_KEY)
except Exception as e:
    print(f"❌ Error initializing Groq: {e}")
    print("   → Try: pip install 'httpx>=0.24,<0.28'")

# Check OpenAI API key (required for the multi-agent pipeline)
GROQ_API_KEY_FOR_AGENTS = os.getenv("GROQ_API_KEY")
if _AGENTS_AVAILABLE and not GROQ_API_KEY_FOR_AGENTS:
    print("⚠️  GROQ_API_KEY not set — multi-agent /api/ask/agent endpoint will be unavailable.")
elif _AGENTS_AVAILABLE:
    print("✅ GROQ_API_KEY found — multi-agent pipeline enabled (powered by Groq).")

# Request/Response models
class ConversationTurn(BaseModel):
    role: str
    content: str


class QuestionRequest(BaseModel):
    question: str
    module: Optional[str] = None       # Optional: filter by specific module
    language: str = "English"          # Target language for agent responses
    use_agents: bool = False           # Set True to invoke the multi-agent pipeline
    conversation_id: Optional[str] = None
    conversation_history: List[ConversationTurn] = Field(default_factory=list)
    response_length: Optional[str] = None  # "short" | "detailed" | "bullets"

class AnswerResponse(BaseModel):
    """Legacy RAG response — preserved for backward compatibility."""
    answer: str
    source: str  # "vector_db" or "groq_fallback"
    confidence: float
    relevance_score: float = 0.0
    module: Optional[str] = None
    file: Optional[str] = None
    last_updated: Optional[str] = None
    verification_status: str = "unverified"
    verification_note: Optional[str] = None
    requires_official_confirmation: bool = True
    trusted_source_ratio: float = 0.0
    freshness_status: str = "unknown"

class AgentAnswerResponse(BaseModel):
    """Rich structured response produced by the multi-agent pipeline."""
    # Core fields aligned with AnswerResponse for drop-in frontend compatibility
    answer: str
    source: str = "agent_pipeline"
    confidence: float = 1.0
    relevance_score: float = 0.0
    module: Optional[str] = None
    file: Optional[str] = None
    # Extended agent fields
    summary: str = ""
    key_points: List[str] = []
    steps: List[Dict[str, Any]] = []
    required_documents: List[str] = []
    references: List[str] = []
    official_links: Dict[str, str] = {}
    notes: Optional[str] = None
    query: str = ""
    elapsed_seconds: float = 0.0
    confidence_score: float = 0.0
    last_updated: Optional[str] = None
    verification_status: str = "unverified"
    verification_note: Optional[str] = None
    requires_official_confirmation: bool = True
    trusted_source_ratio: float = 0.0
    freshness_status: str = "unknown"

# Module mapping
MODULE_NAMES = {
    "women_harassment": "Women Harassment",
    "labour_rights": "Labour Rights", 
    "cyber_law": "Cyber Law",
    "road_laws": "Road Laws"
}

MODULE_DATA_DIRS = {
    "women_harassment": BASE_DIR / "data" / "women_harassment",
    "labour_rights": BASE_DIR / "data" / "Labour_rights",
    "cyber_law": BASE_DIR / "data" / "cyber_law",
    "road_laws": BASE_DIR / "data" / "road_laws",
}

_LEGAL_INTENT_TERMS = {
    "law", "legal", "rights", "court", "judge", "fir", "complaint", "case", "notice",
    "harassment", "harass", "blackmail", "cyber", "peca", "termination", "terminated",
    "salary", "wage", "overtime", "contract", "employer", "employee", "police",
    "challan", "traffic", "license", "licence", "accident", "crime", "criminal",
    "arrest", "bail", "evidence", "lawyer", "act", "ordinance", "petition",
}

_HIGH_PRIORITY_TERMS = {
    "urgent", "emergency", "immediately", "threat", "threatened", "blackmail", "stalk",
    "harassment", "fired", "terminated", "assault", "violence", "abuse", "police",
}

_CASUAL_PHRASES = {
    "hi", "hello", "hey", "salam", "assalam", "assalam o alaikum", "how are you",
    "what's up", "whats up", "good morning", "good evening", "thanks", "thank you",
    "ok", "okay", "bye", "good night", "joke",
}


def _tokenize(text: str) -> List[str]:
    return re.findall(r"[a-zA-Z']+", (text or "").lower())


def _count_hits(tokens: List[str], terms: set[str]) -> int:
    return sum(1 for token in tokens if token in terms)


def _looks_like_small_talk(question: str) -> bool:
    q = (question or "").strip().lower()
    if not q:
        return True

    if q in _CASUAL_PHRASES:
        return True

    for phrase in _CASUAL_PHRASES:
        if phrase in q and len(_tokenize(q)) <= 8:
            return True

    return False


def _should_activate_agents_automatically(
    question: str,
    module: Optional[str],
    has_results: bool,
    best_distance: Optional[float],
) -> bool:
    if module in MODULE_NAMES:
        return True

    tokens = _tokenize(question)
    legal_hits = _count_hits(tokens, _LEGAL_INTENT_TERMS)
    priority_hits = _count_hits(tokens, _HIGH_PRIORITY_TERMS)

    if priority_hits > 0:
        return True

    if _looks_like_small_talk(question) and legal_hits == 0:
        return False

    if legal_hits >= 2:
        return True

    if legal_hits == 1:
        if best_distance is None:
            return True
        return best_distance >= 0.50

    # For non-legal random/general chat, avoid expensive agent orchestration.
    return False


def _to_agent_answer_response(orch_result: OrchestratorResponse, source: str = "agent_pipeline") -> AgentAnswerResponse:
    return AgentAnswerResponse(
        answer=orch_result.answer,
        source=source,
        confidence=orch_result.confidence_score or 1.0,
        relevance_score=orch_result.relevance_score,
        module=orch_result.module,
        file=None,
        summary=orch_result.summary,
        key_points=orch_result.key_points,
        steps=orch_result.steps,
        required_documents=orch_result.required_documents,
        references=orch_result.references,
        official_links=orch_result.official_links,
        notes=orch_result.notes,
        query=orch_result.query,
        elapsed_seconds=orch_result.elapsed_seconds,
        confidence_score=orch_result.confidence_score,
        last_updated=orch_result.last_updated,
        verification_status=orch_result.verification_status,
        verification_note=orch_result.verification_note,
        requires_official_confirmation=orch_result.requires_official_confirmation,
        trusted_source_ratio=orch_result.trusted_source_ratio,
        freshness_status=orch_result.freshness_status,
    )


def _local_file_last_updated(module: Optional[str], filename: Optional[str]) -> Optional[str]:
    if not module or not filename:
        return None
    base = MODULE_DATA_DIRS.get(module)
    if base is None or not base.exists():
        return None
    for path in base.rglob("*"):
        if path.is_file() and path.name == filename:
            return datetime.fromtimestamp(path.stat().st_mtime, tz=timezone.utc).isoformat()
    return None

@app.get("/")
async def root():
    """Health check endpoint"""
    return {
        "status": "running",
        "message": "Legal Sathi RAG API",
        "vector_db_loaded": collection is not None,
        "total_documents": collection.count() if collection else 0
    }

@app.post("/api/ask", response_model=Union[AgentAnswerResponse, AnswerResponse])
async def ask_question(request: QuestionRequest):
    """
    Main endpoint for asking legal questions.

    Behaviour depends on the ``use_agents`` flag in the request body:

    * ``use_agents=False`` (default) — original RAG path using ChromaDB +
      Groq LLM.  Fully backward compatible.
    * ``use_agents=True`` — multi-agent pipeline: Law Retrieval → Explanation
      → Guidance.  Returns an :class:`AgentAnswerResponse` with rich
      structured output.  Falls back to the RAG path if the agent pipeline
      is unavailable or raises an unrecoverable error.
    """

    # ------------------------------------------------------------------ #
    # Multi-agent branch                                                   #
    # ------------------------------------------------------------------ #
    if request.use_agents:
        if not _AGENTS_AVAILABLE:
            raise HTTPException(
                status_code=501,
                detail="Multi-agent pipeline is not installed. "
                       "Run: pip install openai-agents beautifulsoup4",
            )
        if not GROQ_API_KEY_FOR_AGENTS:
            raise HTTPException(
                status_code=501,
                detail="GROQ_API_KEY is not configured on the server. "
                       "Set it in your .env file to enable the agent pipeline.",
            )

        question = request.question.strip()
        if not question:
            raise HTTPException(status_code=400, detail="Question cannot be empty")

        try:
            print(f"\n🤖 [Agent Pipeline] Query: {question}")
            orch_result: OrchestratorResponse = await run_orchestrator(
                query=question,
                module=request.module if request.module in MODULE_NAMES else None,
                language=request.language,
                conversation_id=request.conversation_id,
                conversation_history=[turn.model_dump() for turn in request.conversation_history],
            )
            print(f"✅ [Agent Pipeline] Completed in {orch_result.elapsed_seconds}s")
            return _to_agent_answer_response(orch_result, source="agent_pipeline")
        except OrchestratorError as exc:
            print(f"❌ [Agent Pipeline] OrchestratorError: {exc}")
            raise HTTPException(status_code=422, detail=str(exc))
        except HTTPException:
            raise
        except Exception as exc:
            print(f"❌ [Agent Pipeline] Unexpected error: {exc} — falling back to RAG")
            # Graceful degradation: fall through to the existing RAG path below.
            request = QuestionRequest(
                question=request.question,
                module=request.module,
                language=request.language,
                use_agents=False,
                conversation_id=request.conversation_id,
                conversation_history=request.conversation_history,
            )
    
    question = request.question.strip()
    if not question:
        raise HTTPException(status_code=400, detail="Question cannot be empty")

    agent_module = request.module if request.module in MODULE_NAMES else None
    can_use_agents = _AGENTS_AVAILABLE and bool(GROQ_API_KEY_FOR_AGENTS)
    best_distance: Optional[float] = None
    has_results = False

    # ------------------------------------------------------------------ #
    # Original RAG path (default)                                         #
    # ------------------------------------------------------------------ #
    if not collection or not groq_client:
        should_auto_activate = _should_activate_agents_automatically(
            question=question,
            module=agent_module,
            has_results=False,
            best_distance=None,
        )
        if can_use_agents and should_auto_activate:
            print("⚠️ RAG backend not fully available, using agent pipeline fallback...")
            try:
                orch_result: OrchestratorResponse = await run_orchestrator(
                    query=question,
                    module=agent_module,
                    language=request.language,
                    conversation_id=request.conversation_id,
                    conversation_history=[turn.model_dump() for turn in request.conversation_history],
                )
                return _to_agent_answer_response(orch_result, source="agent_pipeline_fallback")
            except Exception as exc:
                print(f"❌ Agent fallback failed: {exc}")
        if not collection:
            raise HTTPException(status_code=500, detail="Vector database not loaded")
        raise HTTPException(status_code=500, detail="Groq client not initialized")
    
    try:
        # Step 1: Search Vector DB
        print(f"\n🔍 Query: {question}")
        
        # Build filter if module specified
        where_filter = None
        if agent_module:
            where_filter = {"module": agent_module}
        
        results = collection.query(
            query_texts=[question],
            n_results=5,  # Get top 5 results
            where=where_filter,
            include=["documents", "metadatas", "distances"]
        )
        has_results = bool(results.get('documents')) and len(results['documents'][0]) > 0
        
        # Check if we have results
        if has_results:
            best_distance = results['distances'][0][0]
            confidence = 1 - best_distance  # Convert distance to confidence
            
            print(f"📊 Best match distance: {best_distance:.4f} (confidence: {confidence:.4f})")
            
            # Step 2: If strong RAG match found, answer from RAG context.
            if best_distance < 0.55:
                # Build candidate chunks for freshness/verification checks.
                raw_chunks_for_verification: List[Dict[str, Any]] = []
                for doc, metadata in zip(results['documents'][0][:5], results['metadatas'][0][:5]):
                    module_name = metadata.get('module', 'unknown')
                    file_name = metadata.get('file', 'unknown')
                    raw_chunks_for_verification.append({
                        "content": doc,
                        "source_url": f"chroma://{module_name}/{file_name}",
                        "source_type": "local",
                        "module": module_name,
                        "filename": file_name,
                        "last_updated": metadata.get("last_updated") or _local_file_last_updated(module_name, file_name),
                    })

                verification_status = "unverified"
                verification_note = "Verification agent unavailable; result is based on local indexed documents."
                requires_official_confirmation = True
                trusted_source_ratio = 0.0
                freshness_status = "unknown"
                relevance_score = 0.0
                verified_for_context: List[Dict[str, Any]] = raw_chunks_for_verification[:3]
                last_updated: Optional[str] = None

                if _VERIFICATION_AVAILABLE:
                    verification_report = await run_verification_agent(
                        query=question,
                        raw_chunks=raw_chunks_for_verification,
                        min_overall_score=0.40,
                    )
                    verification_status = (
                        "verified"
                        if not verification_report.requires_official_confirmation
                        else "needs_confirmation"
                    )
                    verification_note = verification_report.verification_note
                    requires_official_confirmation = verification_report.requires_official_confirmation
                    trusted_source_ratio = verification_report.trusted_source_ratio
                    freshness_status = verification_report.freshness_status
                    relevance_score = verification_report.average_relevance_score
                    last_updated = verification_report.last_updated

                    if verification_report.verified:
                        verified_for_context = [c.model_dump() for c in verification_report.verified[:3]]

                    if can_use_agents and verification_report.requires_official_confirmation:
                        print("⚠️ Local RAG evidence needs confirmation, escalating to agent pipeline for fresher verification...")
                        try:
                            orch_result: OrchestratorResponse = await run_orchestrator(
                                query=question,
                                module=agent_module,
                                language=request.language,
                                conversation_id=request.conversation_id,
                                conversation_history=[turn.model_dump() for turn in request.conversation_history],
                            )
                            return _to_agent_answer_response(orch_result, source="agent_pipeline_fallback")
                        except Exception as exc:
                            print(f"❌ Agent escalation failed, continuing with verified local RAG: {exc}")

                context_chunks = []
                for chunk in verified_for_context[:3]:
                    context_chunks.append(f"[{chunk.get('filename') or 'document'}]\n{chunk.get('content', '')}")

                context = "\n\n---\n\n".join(context_chunks)

                # Get module info from best match
                best_metadata = results['metadatas'][0][0]
                module_name = best_metadata.get('module', 'unknown')
                file_name = best_metadata.get('file', 'unknown')

                print(f"✅ Using Vector DB (Module: {module_name}, File: {file_name})")
                
                # Use Groq to generate a natural answer from the context
                response = groq_client.chat.completions.create(
                    model="llama-3.1-8b-instant",
                    messages=[
                        {
                            "role": "system",
                            "content": f"""You are Legal Sathi, an AI assistant for Pakistani law.

Answer the question using ONLY the following context from legal documents:

{context}

Guidelines:
- Answer ONLY the user's exact question; do not add unrelated legal discussion.
- Answer in a clear, professional manner
- If the context contains the answer, provide it with relevant details
- If the context doesn't fully answer the question, say "Based on the available documents..." and provide what you can
- If the context is not sufficiently relevant, clearly say the available context is insufficient for this exact question.
- Cite the relevant law/act name if mentioned in the context
- Keep answers concise but informative
- Do NOT make up information not in the context"""
                        },
                        {
                            "role": "user",
                            "content": question
                        }
                    ],
                    temperature=0.3,  # Lower temperature for more factual responses
                    max_tokens=500
                )
                
                return AnswerResponse(
                    answer=response.choices[0].message.content,
                    source="vector_db",
                    confidence=confidence,
                    relevance_score=relevance_score,
                    module=module_name,
                    file=file_name,
                    last_updated=last_updated,
                    verification_status=verification_status,
                    verification_note=verification_note,
                    requires_official_confirmation=requires_official_confirmation,
                    trusted_source_ratio=trusted_source_ratio,
                    freshness_status=freshness_status,
                )

            # Weak RAG signal -> escalate to richer multi-agent pipeline first.
            should_auto_activate = _should_activate_agents_automatically(
                question=question,
                module=agent_module,
                has_results=has_results,
                best_distance=best_distance,
            )
            if can_use_agents and should_auto_activate:
                print("⚠️ Weak Vector DB match, escalating to agent pipeline...")
                try:
                    orch_result: OrchestratorResponse = await run_orchestrator(
                        query=question,
                        module=agent_module,
                        language=request.language,
                        conversation_id=request.conversation_id,
                        conversation_history=[turn.model_dump() for turn in request.conversation_history],
                    )
                    return _to_agent_answer_response(orch_result, source="agent_pipeline_fallback")
                except Exception as exc:
                    print(f"❌ Agent escalation failed, continuing with Groq fallback: {exc}")
        
        # Step 3: No good RAG match - prefer agent pipeline, then generic Groq fallback
        print("⚠️ No good match in Vector DB, using Groq fallback...")

        should_auto_activate = _should_activate_agents_automatically(
            question=question,
            module=agent_module,
            has_results=has_results,
            best_distance=best_distance,
        )
        if can_use_agents and should_auto_activate:
            try:
                orch_result: OrchestratorResponse = await run_orchestrator(
                    query=question,
                    module=agent_module,
                    language=request.language,
                    conversation_id=request.conversation_id,
                    conversation_history=[turn.model_dump() for turn in request.conversation_history],
                )
                return _to_agent_answer_response(orch_result, source="agent_pipeline_fallback")
            except Exception as exc:
                print(f"❌ Agent fallback failed, using generic Groq fallback: {exc}")
        
        response = groq_client.chat.completions.create(
            model="llama-3.1-8b-instant",
            messages=[
                {
                    "role": "system",
                    "content": """You are Legal Sathi, an AI assistant specializing in Pakistani law.

You help with questions about:
- Women Harassment (PAHAW 2010)
- Labour Rights (worker rights, wages, contracts)
- Cyber Law (cybercrime, online harassment)
- Road Laws (traffic rules, violations)

Guidelines:
- Only answer questions related to Pakistani law in these 4 areas
- If question is outside these topics, politely say: "I can only help with questions about Women Harassment, Labour Rights, Cyber Law, and Road Laws in Pakistan."
- Provide accurate, helpful legal information
- Suggest consulting a lawyer for specific legal cases
- Keep answers clear and concise"""
                },
                {
                    "role": "user",
                    "content": question
                }
            ],
            temperature=0.7,
            max_tokens=500
        )
        
        return AnswerResponse(
            answer=response.choices[0].message.content,
            source="groq_fallback",
            confidence=0.5,
            relevance_score=0.0,
            module=None,
            file=None,
            last_updated=None,
            verification_status="unverified",
            verification_note="No verified legal document context was available. This is general legal information.",
            requires_official_confirmation=True,
            trusted_source_ratio=0.0,
            freshness_status="unknown",
        )
        
    except Exception as e:
        print(f"❌ Error: {e}")
        raise HTTPException(status_code=500, detail=f"Error processing question: {str(e)}")

@app.post("/api/ask/agent", response_model=AgentAnswerResponse)
async def ask_question_agent(request: QuestionRequest):
    """
    Dedicated multi-agent endpoint.

    Equivalent to calling ``/api/ask`` with ``use_agents=True`` but returns
    :class:`AgentAnswerResponse` directly, making the richer schema explicit
    for clients that always want the full structured guidance output.

    Requires ``OPENAI_API_KEY`` to be configured in the server environment.
    """
    if not _AGENTS_AVAILABLE:
        raise HTTPException(
            status_code=501,
            detail="Multi-agent pipeline is not installed. "
                   "Run: pip install openai-agents beautifulsoup4",
        )
    if not GROQ_API_KEY_FOR_AGENTS:
        raise HTTPException(
            status_code=501,
            detail="GROQ_API_KEY is not configured. Set it in .env to enable the agent pipeline.",
        )

    question = request.question.strip()
    if not question:
        raise HTTPException(status_code=400, detail="Question cannot be empty")

    try:
        print(f"\n🤖 [/api/ask/agent] Query: {question}")
        orch_result: OrchestratorResponse = await run_orchestrator(
            query=question,
            module=request.module if request.module in MODULE_NAMES else None,
            language=request.language,
            conversation_id=request.conversation_id,
            conversation_history=[turn.model_dump() for turn in request.conversation_history],
        )
        print(f"✅ [/api/ask/agent] Completed in {orch_result.elapsed_seconds}s")
        return _to_agent_answer_response(orch_result, source="agent_pipeline")
    except OrchestratorError as exc:
        print(f"❌ [/api/ask/agent] OrchestratorError: {exc}")
        raise HTTPException(status_code=422, detail=str(exc))
    except HTTPException:
        raise
    except Exception as exc:
        print(f"❌ [/api/ask/agent] Unexpected error: {exc}")
        raise HTTPException(status_code=500, detail=f"Agent pipeline error: {str(exc)}")


@app.get("/api/stats")
async def get_stats():
    """Get database statistics"""
    if not collection:
        raise HTTPException(status_code=500, detail="Vector database not loaded")
    
    # Get count per module
    module_counts = {}
    for module_key in MODULE_NAMES.keys():
        try:
            rows = collection.get(where={"module": module_key}, include=[])
            module_counts[MODULE_NAMES[module_key]] = len(rows.get("ids", []) or [])
        except Exception:
            module_counts[MODULE_NAMES[module_key]] = 0
    
    return {
        "total_chunks": collection.count(),
        "modules": module_counts
    }


@app.post("/api/ask/stream")
async def ask_question_stream(request: QuestionRequest, raw_request: FastAPIRequest):
    """
    Streaming SSE endpoint.  Identical RAG/agent routing as ``/api/ask``
    but tokens are yielded one-by-one via Server-Sent Events so the frontend
    can render a typewriter effect.

    Client should read ``text/event-stream``; each line is:
      data: {"token": "..."}\n\n
    and the final line is:
      data: [DONE]\n\n
    On error:
      data: {"error": "..."}\n\n
      data: [DONE]\n\n
    """

    async def _event_stream() -> AsyncIterator[str]:
        try:
            question = (request.question or "").strip()
            if not question:
                yield f"data: {json.dumps({'error': 'Question cannot be empty'})}\n\n"
                yield "data: [DONE]\n\n"
                return

            # ---------- metadata helper ---------------------------------
            meta: Dict[str, Any] = {
                "source": "groq_fallback",
                "confidence": 0.5,
                "relevance_score": 0.0,
                "module": None,
                "file": None,
                "verification_status": "unverified",
                "freshness_status": "unknown",
                "requires_official_confirmation": True,
                "trusted_source_ratio": 0.0,
                "verification_note": None,
                "last_updated": None,
            }

            system_prompt = (
                "You are Legal Sathi, a helpful AI assistant for Pakistani law. "
                "Answer ONLY the user's exact question concisely. "
                "Cite relevant acts/sections when available."
            )
            chat_messages: List[Dict[str, str]] = []
            for turn in (request.conversation_history or []):
                chat_messages.append({"role": turn.role, "content": turn.content})

            # ---------- try RAG context ---------------------------------
            if collection and groq_client:
                agent_module = request.module if request.module in MODULE_NAMES else None
                where_filter = {"module": agent_module} if agent_module else None
                results = collection.query(
                    query_texts=[question],
                    n_results=5,
                    where=where_filter,
                    include=["documents", "metadatas", "distances"],
                )
                has_results = bool(results.get("documents")) and len(results["documents"][0]) > 0
                if has_results:
                    best_distance = results["distances"][0][0]
                    if best_distance < 0.55:
                        best_metadata = results["metadatas"][0][0]
                        module_name = best_metadata.get("module", "unknown")
                        file_name = best_metadata.get("file", "unknown")
                        context_chunks = [
                            f"[{results['metadatas'][0][i].get('file', 'doc')}]\n{doc}"
                            for i, doc in enumerate(results["documents"][0][:3])
                        ]
                        context = "\n\n---\n\n".join(context_chunks)
                        system_prompt = f"""You are Legal Sathi, an AI assistant for Pakistani law.
Answer the question using ONLY the following context from legal documents:

{context}

Answer ONLY the user's exact question in clear professional language.
Cite the relevant law/act if mentioned. Keep answers concise but informative."""
                        meta["source"] = "vector_db"
                        meta["confidence"] = round(1 - best_distance, 4)
                        meta["module"] = module_name
                        meta["file"] = file_name

            if not groq_client:
                yield f"data: {json.dumps({'error': 'Groq client not initialised'})}\n\n"
                yield "data: [DONE]\n\n"
                return

            # Send metadata first so the frontend can render source/confidence
            yield f"data: {json.dumps({'meta': meta})}\n\n"

            # ---------- stream Groq tokens ------------------------------
            chat_messages.append({"role": "user", "content": question})
            max_tok = {"short": 200, "bullets": 300, "detailed": 800}.get(
                getattr(request, "response_length", None) or "detailed", 500
            )
            stream = groq_client.chat.completions.create(
                model="llama-3.1-8b-instant",
                messages=[{"role": "system", "content": system_prompt}] + chat_messages,
                temperature=0.35,
                max_tokens=max_tok,
                stream=True,
            )

            async def _disconnected() -> bool:
                try:
                    return await raw_request.is_disconnected()
                except Exception:
                    return False

            for chunk in stream:
                if await _disconnected():
                    break
                delta = chunk.choices[0].delta
                if delta and delta.content:
                    yield f"data: {json.dumps({'token': delta.content})}\n\n"

        except Exception as exc:
            yield f"data: {json.dumps({'error': str(exc)})}\n\n"
        finally:
            yield "data: [DONE]\n\n"

    return StreamingResponse(
        _event_stream(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "X-Accel-Buffering": "no",
        },
    )


if __name__ == "__main__":
    import uvicorn
    print("\n🚀 Starting Legal Sathi RAG API...")
    print("📍 API will be available at: http://localhost:8000")
    print("📖 Docs available at: http://localhost:8000/docs")
    uvicorn.run(app, host="0.0.0.0", port=8000)
