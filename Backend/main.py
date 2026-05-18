import base64
import os
import re
from pathlib import Path
from datetime import datetime, timezone
# Disable ChromaDB telemetry (stops "Failed to send telemetry event" messages)
os.environ["ANONYMIZED_TELEMETRY"] = "false"

# Configure OpenAI Agents SDK to use Groq before any agent is imported.
import groq_config  # noqa: F401 — side-effects: sets default Groq client

import json
from fastapi import FastAPI, File, Form, HTTPException, Request as FastAPIRequest, UploadFile
from fastapi.responses import StreamingResponse
from fastapi.middleware.cors import CORSMiddleware
from typing import Any, AsyncIterator, Dict, List, Optional, Union
from pydantic import BaseModel, Field
import chromadb
from chromadb.utils import embedding_functions
from groq import Groq
from dotenv import load_dotenv
# Notifications helper
try:
    from notification_helper import NotificationHelper
    _NOTIFICATIONS_AVAILABLE = True
except Exception:
    _NOTIFICATIONS_AVAILABLE = False


# Agent orchestrator — imported lazily so the existing RAG path is unaffected
# if the openai-agents package is not installed.
_AGENTS_IMPORT_ERROR: Optional[str] = None
try:
    from agent_orchestrator import OrchestratorError, OrchestratorResponse, run_orchestrator
    _AGENTS_AVAILABLE = True
except ImportError as exc:
    _AGENTS_AVAILABLE = False
    _AGENTS_IMPORT_ERROR = str(exc)
    print(
        "⚠️  agent_orchestrator import failed — /api/ask/agent endpoint will be unavailable."
        f"\n   → Import error: {_AGENTS_IMPORT_ERROR}"
    )

try:
    from verification_agent import run_verification_agent
    _VERIFICATION_AVAILABLE = True
except ImportError:
    _VERIFICATION_AVAILABLE = False
    print("⚠️  verification_agent not found — strict freshness verification will be limited.")

# Import Supabase client for language preference management
try:
    from supabase_client import (
        get_user_language,
        set_user_language,
        get_user_profile,
        check_languages_available,
    )
    _SUPABASE_AVAILABLE = check_languages_available()
except ImportError:
    _SUPABASE_AVAILABLE = False
    print("⚠️  supabase_client not found — language persistence will be unavailable.")

# Import documents helper for dynamic document management
try:
    from documents_helper import (
        get_all_documents,
        get_documents_by_module,
        add_document_to_module,
        remove_document,
        AllDocuments,
        ModuleDocuments,
    )
    _DOCUMENTS_HELPER_AVAILABLE = True
except ImportError as exc:
    _DOCUMENTS_HELPER_AVAILABLE = False
    print(f"⚠️  documents_helper not found: {exc}")

# Import user documents helper
try:
    from user_documents_helper import (
        UserDocument,
        UserDocumentsResponse,
        DocumentUploadRequest,
        get_document_icon,
        get_document_color,
        get_document_display_name,
        format_file_size,
    )
    _USER_DOCUMENTS_HELPER_AVAILABLE = True
except ImportError as exc:
    _USER_DOCUMENTS_HELPER_AVAILABLE = False
    print(f"⚠️  user_documents_helper not found: {exc}")

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
embedding_function = embedding_functions.DefaultEmbeddingFunction()

try:
    collection = client.get_or_create_collection(
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
    attachment_name: Optional[str] = None
    attachment_data_base64: Optional[str] = None

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


def _to_agent_answer_response(orch_result: "OrchestratorResponse", source: str = "agent_pipeline") -> AgentAnswerResponse:
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


@app.post("/api/challan/extract-text")
async def extract_challan_text(file: UploadFile = File(...)):
    """
    Extract plain text from a traffic challan PDF (text layer) or image.
    PDF uses pypdf. Images use Pillow + optional pytesseract if installed.
    """
    import io

    raw = await file.read()
    if not raw:
        return {"text": ""}

    # PDF by magic bytes (works even if filename is wrong)
    if len(raw) >= 4 and raw[:4] == b"%PDF":
        try:
            from pypdf import PdfReader

            reader = PdfReader(io.BytesIO(raw))
            parts: List[str] = []
            for page in reader.pages:
                parts.append(page.extract_text() or "")
            return {"text": "\n".join(parts).strip()}
        except Exception as e:
            raise HTTPException(status_code=400, detail=f"Could not read PDF: {e}") from e

    # Raster image: try OCR if Pillow (+ optional Tesseract) available
    try:
        from PIL import Image

        img = Image.open(io.BytesIO(raw))
        if img.mode not in ("RGB", "L"):
            img = img.convert("RGB")
        try:
            import pytesseract

            text = pytesseract.image_to_string(img) or ""
            return {"text": text.strip()}
        except ImportError:
            # Pillow without Tesseract — no OCR on server
            return {"text": ""}
    except Exception:
        return {"text": ""}


def _extract_text_from_bytes(raw: bytes, file_name: str = "") -> str:
    """Extract text from PDF, text, DOCX, or image bytes."""
    import io
    import zipfile
    import xml.etree.ElementTree as ET

    lower_name = (file_name or "").lower()

    def _try_text_decode() -> str:
        try:
            text = raw.decode("utf-8").strip()
            if len(text) >= 10:
                return text
        except Exception:
            pass
        try:
            return raw.decode("latin-1", errors="ignore").strip()
        except Exception:
            return ""

    if lower_name.endswith(".pdf") or (len(raw) >= 4 and raw[:4] == b"%PDF"):
        try:
            from pypdf import PdfReader

            reader = PdfReader(io.BytesIO(raw))
            parts: List[str] = []
            for page in reader.pages:
                parts.append(page.extract_text() or "")
            return "\n".join(parts).strip()
        except Exception:
            return ""

    if lower_name.endswith((".txt", ".md", ".csv", ".log", ".json")):
        return _try_text_decode()

    if lower_name.endswith(".docx") or (len(raw) >= 2 and raw[:2] == b"PK"):
        try:
            with zipfile.ZipFile(io.BytesIO(raw)) as zf:
                with zf.open("word/document.xml") as xml_file:
                    xml_bytes = xml_file.read()
            root = ET.fromstring(xml_bytes)
            namespaces = {"w": "http://schemas.openxmlformats.org/wordprocessingml/2006/main"}
            parts = [node.text for node in root.findall('.//w:t', namespaces) if node.text]
            text = " ".join(parts).strip()
            if text:
                return text
        except Exception:
            return ""

    try:
        from PIL import Image

        img = Image.open(io.BytesIO(raw))
        if img.mode not in ("RGB", "L"):
            img = img.convert("RGB")
        try:
            import pytesseract

            text = pytesseract.image_to_string(img) or ""
            return text.strip()
        except ImportError:
            return ""
    except Exception:
        return _try_text_decode()


def _build_attachment_context(attachment_name: Optional[str], attachment_data_base64: Optional[str]) -> str:
    if not attachment_data_base64:
        return ""

    try:
        raw = base64.b64decode(attachment_data_base64)
    except Exception:
        return ""

    text = _extract_text_from_bytes(raw, attachment_name or "").strip()
    if not text:
        return ""

    max_chars = 12000
    if len(text) > max_chars:
        text = text[:max_chars] + "\n...[truncated]"

    title = attachment_name or "uploaded file"
    return (
        f"Uploaded file: {title}\n"
        "Use this file as temporary evidence context for the current answer only.\n\n"
        f"{text}"
    )


class EvidenceAnalyzeRequest(BaseModel):
    """OCR or pasted text from a screenshot / document for domain classification."""
    text: str = Field(..., min_length=1)
    user_id: Optional[str] = None
    complaint_id: Optional[str] = None


class EvidenceAnalyzeResponse(BaseModel):
    classified_domain: str
    tags: List[str]
    relevant_laws: List[str]
    summary: str = ""


class EvidenceUploadResponse(BaseModel):
    success: bool
    evidence_id: Optional[str] = None
    file_name: Optional[str] = None
    storage_path: Optional[str] = None
    public_url: Optional[str] = None
    message: str = ""


def _parse_llm_json_object(raw: str) -> Optional[Dict[str, Any]]:
    """Best-effort parse of JSON from an LLM reply (may include markdown fences)."""
    t = (raw or "").strip()
    if not t:
        return None
    if t.startswith("```"):
        lines = t.split("\n")
        if len(lines) >= 2:
            inner = "\n".join(lines[1:])
            if inner.rstrip().endswith("```"):
                inner = inner.rstrip()[:-3].rstrip()
            t = inner.strip()
    try:
        obj = json.loads(t)
        return obj if isinstance(obj, dict) else None
    except json.JSONDecodeError:
        pass
    m = re.search(r"\{[\s\S]*\}", t)
    if m:
        try:
            obj = json.loads(m.group(0))
            return obj if isinstance(obj, dict) else None
        except json.JSONDecodeError:
            return None
    return None


def _fallback_evidence_analysis(text: str) -> EvidenceAnalyzeResponse:
    lower = (text or "").lower()
    domain = "General legal / administrative document"
    tags = ["Extracted text", "Review recommended"]
    laws: List[str] = [
        "Cross-check facts with the applicable Act, Rules, or notification in force.",
        "For Pakistan: verify provincial labour / cyber / criminal statutes as relevant.",
    ]
    if any(k in lower for k in ("salary", "wage", "payroll", "overtime", "leave", "employer", "termination")):
        domain = "Labour / employment-related"
        tags = ["Employment", "Workplace", "Wages or terms"]
        laws = [
            "Provincial Shops and Establishments / Industrial Relations laws (as applicable).",
            "Payment of Wages and minimum wage notifications — confirm current rates.",
        ]
    elif any(k in lower for k in ("peca", "cyber", "online", "facebook", "whatsapp", "harass", "blackmail", "fia")):
        domain = "Cyber law / online conduct"
        tags = ["Digital evidence", "PECA context"]
        laws = [
            "Prevention of Electronic Crimes Act, 2016 (PECA) — relevant sections depend on facts.",
        ]
    elif any(k in lower for k in ("traffic", "challan", "license", "motor vehicle")):
        domain = "Road / motor vehicle matter"
        tags = ["Traffic", "Regulatory"]
        laws = [
            "Provincial Motor Vehicles Ordinance / rules — verify against the alleged violation.",
        ]
    elif any(k in lower for k in ("harassment", "workplace", "committee", "complaint", "female")):
        domain = "Workplace conduct / harassment (context-dependent)"
        tags = ["Workplace", "Conduct"]
        laws = [
            "Protection Against Harassment of Women at the Workplace Act, 2010 — if applicable.",
        ]
    snippet = text.strip().replace("\n", " ")
    if len(snippet) > 220:
        snippet = snippet[:217] + "..."
    summary = f"Heuristic classification from extracted text. Preview: {snippet}"
    return EvidenceAnalyzeResponse(
        classified_domain=domain,
        tags=tags[:8],
        relevant_laws=laws[:6],
        summary=summary,
    )


@app.post("/api/evidence/analyze-text", response_model=EvidenceAnalyzeResponse)
async def analyze_evidence_text(request: EvidenceAnalyzeRequest):
    """
    Classify OCR text from a screenshot: legal domain, tags, and indicative laws (not legal advice).
    Uses Groq when configured; otherwise keyword fallback.
    """
    text = request.text.strip()
    if len(text) < 15:
        raise HTTPException(
            status_code=400,
            detail="Extracted text is too short. Provide a clearer image or paste text.",
        )

    if groq_client and GROQ_API_KEY:
        try:
            response = groq_client.chat.completions.create(
                model="llama-3.1-8b-instant",
                messages=[
                    {
                        "role": "system",
                        "content": """You analyze short text extracted from screenshots or documents for a Pakistani legal assistance app.
Respond with ONE JSON object only, no markdown, no extra text. Keys:
- "classified_domain": string, a short label (e.g. "Labour - wage dispute", "Cyber - online harassment").
- "tags": array of 2-6 short strings for UI chips.
- "relevant_laws": array of 2-5 strings naming relevant Pakistani laws, acts, or topics (e.g. PECA 2016, provincial labour law). Be conservative; say "verify with current statute" if unsure.
- "summary": one or two sentences describing what the excerpt suggests.

Rules: Output valid JSON only. English. Not legal advice — indicative references only.""",
                    },
                    {
                        "role": "user",
                        "content": f"Extracted text follows:\n\n{text[:8000]}",
                    },
                ],
                temperature=0.2,
                max_tokens=700,
            )
            raw = (response.choices[0].message.content or "").strip()
            parsed = _parse_llm_json_object(raw)
            if parsed:
                domain = str(parsed.get("classified_domain") or "").strip() or "Unclassified document"
                tags = parsed.get("tags") or []
                laws = parsed.get("relevant_laws") or []
                summary = str(parsed.get("summary") or "").strip()
                if not isinstance(tags, list):
                    tags = []
                if not isinstance(laws, list):
                    laws = []
                tags = [str(x).strip() for x in tags if str(x).strip()][:8]
                laws = [str(x).strip() for x in laws if str(x).strip()][:8]
                if not laws:
                    laws = ["Verify applicable statute with a qualified lawyer or official source."]
                result = EvidenceAnalyzeResponse(
                    classified_domain=domain,
                    tags=tags if tags else ["Document review"],
                    relevant_laws=laws,
                    summary=summary,
                )
                if _NOTIFICATIONS_AVAILABLE and request.user_id:
                    try:
                        target_id = request.complaint_id or request.user_id
                        NotificationHelper.notify_evidence_processed(request.user_id, target_id)
                    except Exception:
                        pass
                return result
        except Exception as exc:
            print(f"⚠️ evidence analyze LLM failed, using fallback: {exc}")

    fallback = _fallback_evidence_analysis(text)
    if _NOTIFICATIONS_AVAILABLE and request.user_id:
        try:
            target_id = request.complaint_id or request.user_id
            NotificationHelper.notify_evidence_processed(request.user_id, target_id)
        except Exception:
            pass
    return fallback


@app.post("/api/documents/upload", response_model=EvidenceUploadResponse)
async def upload_evidence_file(
    file: UploadFile = File(...),
    user_id: str = Form(...),
    complaint_id: Optional[str] = Form(None),
    source_module: Optional[str] = Form(None),
    file_type: Optional[str] = Form(None),
):
    """Upload an evidence/document file to Supabase Storage and save metadata."""
    if not _SUPABASE_AVAILABLE:
        raise HTTPException(status_code=501, detail="Supabase storage is not configured")

    raw = await file.read()
    if not raw:
        raise HTTPException(status_code=400, detail="Empty file upload")

    max_bytes = int(os.getenv("MAX_FILE_SIZE", str(10 * 1024 * 1024)))
    if len(raw) > max_bytes:
        raise HTTPException(status_code=413, detail="File exceeds the maximum allowed size")

    try:
        import uuid

        evidence_id = str(uuid.uuid4())
        safe_name = re.sub(r"[^a-zA-Z0-9._-]", "_", file.filename or "evidence")
        storage_path = f"evidence_files/{user_id}/{evidence_id}_{safe_name}"

        public_url = None
        try:
            from supabase_client import get_supabase_client

            client = get_supabase_client()
            if client is None:
                raise RuntimeError("Supabase client not available")

            bucket = client.storage.from_("evidence_files")
            bucket.upload(storage_path, raw, file_options={"content-type": file.content_type or "application/octet-stream"})
            try:
                public_url = bucket.get_public_url(storage_path)
            except Exception:
                public_url = None

            row = {
                "id": evidence_id,
                "user_id": user_id,
                "complaint_id": complaint_id,
                "file_name": file.filename or safe_name,
                "file_type": file_type or (file.content_type or "application/octet-stream"),
                "mime_type": file.content_type or "application/octet-stream",
                "storage_path": storage_path,
                "public_url": public_url,
                "file_size": len(raw),
                "source_module": source_module,
                "uploaded_at": datetime.now(timezone.utc).isoformat(),
            }
            client.table("evidence_files").insert(row).execute()
        except Exception as storage_exc:
            print(f"⚠️ evidence storage failed, saving metadata only: {storage_exc}")
            if _SUPABASE_AVAILABLE:
                from supabase_client import get_supabase_client

                client = get_supabase_client()
                if client is not None:
                    client.table("evidence_files").insert({
                        "id": evidence_id,
                        "user_id": user_id,
                        "complaint_id": complaint_id,
                        "file_name": file.filename or safe_name,
                        "file_type": file_type or (file.content_type or "application/octet-stream"),
                        "mime_type": file.content_type or "application/octet-stream",
                        "storage_path": storage_path,
                        "public_url": None,
                        "file_size": len(raw),
                        "source_module": source_module,
                        "uploaded_at": datetime.now(timezone.utc).isoformat(),
                    }).execute()

        if _NOTIFICATIONS_AVAILABLE:
            try:
                NotificationHelper.create_notification(
                    user_id=user_id,
                    title="Evidence Uploaded",
                    message=f"Your file '{file.filename or safe_name}' was uploaded successfully.",
                    action_type="evidence",
                    action_id=complaint_id or evidence_id,
                )
            except Exception:
                pass

        return EvidenceUploadResponse(
            success=True,
            evidence_id=evidence_id,
            file_name=file.filename or safe_name,
            storage_path=storage_path,
            public_url=public_url,
            message="Evidence uploaded successfully",
        )
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"Failed to upload evidence: {exc}") from exc


# ----------------------------
# Notifications endpoints
# ----------------------------


@app.post("/api/notifications/{notification_id}/mark_read")
async def api_mark_notification_read(notification_id: str):
    """Mark a single notification as read (best-effort)."""
    if not _NOTIFICATIONS_AVAILABLE:
        raise HTTPException(status_code=500, detail="Notifications subsystem unavailable")

    try:
        result = NotificationHelper.mark_notification_read(notification_id)
        if not result.get("success"):
            raise HTTPException(status_code=500, detail=result.get("error") or "Could not mark read")
        return {"success": True, "notification_id": notification_id}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e)) from e


@app.post("/api/notifications/user/{user_id}/mark_all_read")
async def api_mark_all_notifications_read(user_id: str):
    """Mark all notifications as read for a user (best-effort)."""
    if not _NOTIFICATIONS_AVAILABLE:
        raise HTTPException(status_code=500, detail="Notifications subsystem unavailable")

    try:
        result = NotificationHelper.mark_all_read_for_user(user_id)
        if not result.get("success"):
            raise HTTPException(status_code=500, detail=result.get("error") or "Could not mark all read")
        return {"success": True, "user_id": user_id}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e)) from e


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
                       "Run: pip install -r Backend/requirements.txt"
                       + (f" | Import error: {_AGENTS_IMPORT_ERROR}" if _AGENTS_IMPORT_ERROR else ""),
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

        attachment_context = _build_attachment_context(
            request.attachment_name,
            request.attachment_data_base64,
        )
        query_with_attachment = question
        if attachment_context:
            query_with_attachment = f"{question}\n\n{attachment_context}"

        try:
            print(f"\n🤖 [Agent Pipeline] Query: {question}")
            orch_result: OrchestratorResponse = await run_orchestrator(
                query=query_with_attachment,
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

    attachment_context = _build_attachment_context(
        request.attachment_name,
        request.attachment_data_base64,
    )
    query_with_attachment = question
    if attachment_context:
        query_with_attachment = f"{question}\n\n{attachment_context}"

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
                    query=query_with_attachment,
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
        print(f"🌐 Language: {request.language}")
        
        # Build filter for module and language
        where_filter = None
        if agent_module or (request.language and request.language != "English"):
            where_filter = {}
            if agent_module:
                where_filter["module"] = agent_module
            # Only filter by language if it's not the default (English)
            # This ensures backward compatibility with existing documents
            if request.language and request.language != "English":
                where_filter["language"] = request.language
        
        # DEBUG: log computed filters and request for runtime diagnosis
        try:
            print("DBG /api/ask: module=", agent_module, ", language=", request.language, ", where_filter=", where_filter, ", request=", request.model_dump())
        except Exception:
            # Best-effort logging — don't fail the request because of logging
            print("DBG /api/ask: (failed to serialize request)", "module=", agent_module, "language=", request.language, "where_filter=", where_filter)

        results = collection.query(
            query_texts=[query_with_attachment],
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
                        query=query_with_attachment,
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
                                query=query_with_attachment,
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
                            "content": query_with_attachment
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
                        query=query_with_attachment,
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
                    query=query_with_attachment,
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
                    "content": query_with_attachment
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

    Requires ``GROQ_API_KEY`` to be configured in the server environment.
    """
    if not _AGENTS_AVAILABLE:
        raise HTTPException(
            status_code=501,
            detail="Multi-agent pipeline is not installed. "
                   "Run: pip install -r Backend/requirements.txt"
                   + (f" | Import error: {_AGENTS_IMPORT_ERROR}" if _AGENTS_IMPORT_ERROR else ""),
        )
    if not GROQ_API_KEY_FOR_AGENTS:
        raise HTTPException(
            status_code=501,
            detail="GROQ_API_KEY is not configured. Set it in .env to enable the agent pipeline.",
        )

    question = request.question.strip()
    if not question:
        raise HTTPException(status_code=400, detail="Question cannot be empty")

    attachment_context = _build_attachment_context(
        request.attachment_name,
        request.attachment_data_base64,
    )
    query_with_attachment = question
    if attachment_context:
        query_with_attachment = f"{question}\n\n{attachment_context}"

    try:
        print(f"\n🤖 [/api/ask/agent] Query: {question}")
        orch_result: OrchestratorResponse = await run_orchestrator(
            query=query_with_attachment,
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

            attachment_context = _build_attachment_context(
                request.attachment_name,
                request.attachment_data_base64,
            )
            query_with_attachment = question
            if attachment_context:
                query_with_attachment = f"{question}\n\n{attachment_context}"

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

            # Send an early SSE byte so the connection stays open while retrieval runs.
            yield ": keepalive\n\n"

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
                where_filter = None
                if agent_module or (request.language and request.language != "English"):
                    where_filter = {}
                    if agent_module:
                        where_filter["module"] = agent_module
                    if request.language and request.language != "English":
                        where_filter["language"] = request.language
                
                # DEBUG: log computed filters and request for runtime diagnosis (streaming)
                try:
                    print("DBG /api/ask/stream: module=", agent_module, ", language=", request.language, ", where_filter=", where_filter, ", request=", request.model_dump())
                except Exception:
                    print("DBG /api/ask/stream: (failed to serialize request)", "module=", agent_module, "language=", request.language, "where_filter=", where_filter)

                results = collection.query(
                    query_texts=[query_with_attachment],
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
            chat_messages.append({"role": "user", "content": query_with_attachment})
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


# ============================================================================
# Language Preference Endpoints
# ============================================================================

class LanguagePreferenceRequest(BaseModel):
    """Request model for setting language preference"""
    language: str  # "English", "Urdu", or "Roman Urdu"

class LanguagePreferenceResponse(BaseModel):
    """Response model for language operations"""
    user_id: str
    language: str
    message: str

@app.get("/api/user/{user_id}/language")
async def get_user_language_endpoint(user_id: str) -> LanguagePreferenceResponse:
    """
    Fetch user's language preference from Supabase.
    
    Args:
        user_id: UUID of the user
        
    Returns:
        Language preference: "English", "Urdu", or "Roman Urdu"
        Defaults to "English" if not set or Supabase unavailable
    """
    if not _SUPABASE_AVAILABLE:
        print(f"⚠️ Supabase unavailable — returning default language")
        return LanguagePreferenceResponse(
            user_id=user_id,
            language="English",
            message="Supabase not configured. Using default language."
        )
    
    try:
        language = get_user_language(user_id)
        return LanguagePreferenceResponse(
            user_id=user_id,
            language=language,
            message=f"Language preference fetched: {language}"
        )
    except Exception as e:
        print(f"❌ Error fetching language: {e}")
        return LanguagePreferenceResponse(
            user_id=user_id,
            language="English",
            message="Error fetching preference. Using default: English"
        )

@app.post("/api/user/{user_id}/language")
async def set_user_language_endpoint(user_id: str, request: LanguagePreferenceRequest) -> LanguagePreferenceResponse:
    """
    Update user's language preference in Supabase.
    
    Args:
        user_id: UUID of the user
        request: LanguagePreferenceRequest with language field
        
    Returns:
        Updated language preference and status message
    """
    # Validate language
    if request.language not in ["English", "Urdu", "Roman Urdu"]:
        raise HTTPException(
            status_code=400,
            detail='Language must be "English", "Urdu", or "Roman Urdu"'
        )
    
    if not _SUPABASE_AVAILABLE:
        print(f"⚠️ Supabase unavailable — language preference not persisted")
        return LanguagePreferenceResponse(
            user_id=user_id,
            language=request.language,
            message="Supabase not configured. Language not persisted."
        )
    
    try:
        success, message = set_user_language(user_id, request.language)
        if success:
            return LanguagePreferenceResponse(
                user_id=user_id,
                language=request.language,
                message=message
            )
        else:
            print(f"❌ Error setting language: {message}")
            raise HTTPException(
                status_code=400,
                detail=message
            )
    except HTTPException:
        raise
    except Exception as e:
        error_msg = str(e)
        print(f"❌ Unexpected error setting language: {error_msg}")
        raise HTTPException(
            status_code=500,
            detail=f"Error updating language: {error_msg}"
        )

@app.get("/api/languages")
async def get_supported_languages():
    """
    Get list of supported languages.
    
    Returns:
        List of supported languages with their display names
    """
    return {
        "supported_languages": [
            {
                "code": "English",
                "name": "English",
                "native_name": "English",
                "rtl": False
            },
            {
                "code": "Urdu",
                "name": "Urdu",
                "native_name": "اردو",
                "rtl": True
            },
            {
                "code": "Roman Urdu",
                "name": "Roman Urdu",
                "native_name": "Urdu (Roman)",
                "rtl": False
            }
        ],
        "default_language": "English"
    }


# ============================================================================
# Notifications Endpoints
# ============================================================================


class NotificationCreateRequest(BaseModel):
    user_id: str
    title: str
    message: str
    action_type: Optional[str] = None
    action_id: Optional[str] = None


class NotificationMarkReadRequest(BaseModel):
    notification_id: str


@app.post("/api/notifications")
async def create_notification_endpoint(request: NotificationCreateRequest):
    """Create a notification for a specific user."""
    if not _NOTIFICATIONS_AVAILABLE:
        raise HTTPException(status_code=501, detail="Notifications helper not available")

    res = NotificationHelper.create_notification(
        user_id=request.user_id,
        title=request.title,
        message=request.message,
        action_type=request.action_type,
        action_id=request.action_id,
    )
    if not res.get("success"):
        raise HTTPException(status_code=500, detail=res.get("error") or "Failed to create notification")
    return {"success": True, "notification": res.get("data")}


@app.get("/api/user/{user_id}/notifications")
async def get_user_notifications_endpoint(user_id: str, unread_only: bool = False):
    """Fetch notifications for a user. Set `unread_only=true` to fetch only unread."""
    if not _NOTIFICATIONS_AVAILABLE:
        raise HTTPException(status_code=501, detail="Notifications helper not available")

    res = NotificationHelper.get_user_notifications(user_id=user_id, unread_only=unread_only)
    if not res.get("success"):
        raise HTTPException(status_code=500, detail=res.get("error") or "Failed to fetch notifications")
    return {"success": True, "notifications": res.get("data")}


@app.post("/api/notifications/{notification_id}/mark_read")
async def mark_notification_read_endpoint(notification_id: str):
    """Mark a notification as read by id."""
    if not _NOTIFICATIONS_AVAILABLE:
        raise HTTPException(status_code=501, detail="Notifications helper not available")

    res = NotificationHelper.mark_notification_read(notification_id=notification_id)
    if not res.get("success"):
        raise HTTPException(status_code=500, detail=res.get("error") or "Failed to mark notification as read")
    return {"success": True, "updated": res.get("data")}


@app.get("/api/user/{user_id}/notifications/count")
async def get_unread_count_endpoint(user_id: str):
    """Return unread notifications count for a user."""
    if not _NOTIFICATIONS_AVAILABLE:
        raise HTTPException(status_code=501, detail="Notifications helper not available")

    res = NotificationHelper.get_user_notifications(user_id=user_id, unread_only=True)
    if not res.get("success"):
        raise HTTPException(status_code=500, detail=res.get("error") or "Failed to fetch notifications")
    data = res.get("data") or []
    return {"success": True, "unread_count": len(data)}


# ============================================================================
# Documents Endpoints
# ============================================================================

@app.get("/api/documents", response_model=AllDocuments)
async def get_all_documents_endpoint():
    """
    Get all documents across all legal modules.
    
    Documents are organized by:
    - Module (Women Harassment, Cyber Law, Labour Rights, Road Laws)
    - Category within each module (Guidelines, Legal Resources, Contacts)
    
    Each document can be:
    - PDF file
    - Text file
    - External link
    
    Returns:
        AllDocuments with all modules, categories, and documents
    """
    if not _DOCUMENTS_HELPER_AVAILABLE:
        raise HTTPException(
            status_code=500,
            detail="Documents helper not available"
        )
    
    try:
        documents = get_all_documents()
        return documents
    except Exception as e:
        print(f"❌ Error fetching documents: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Error fetching documents: {str(e)}"
        )


@app.get("/api/documents/{module_id}", response_model=ModuleDocuments)
async def get_module_documents(module_id: str):
    """
    Get documents for a specific module.
    
    Args:
        module_id: Module identifier (women_harassment, cyber_law, labour_rights, road_laws)
    
    Returns:
        ModuleDocuments with categories and documents for the specified module
    """
    if not _DOCUMENTS_HELPER_AVAILABLE:
        raise HTTPException(
            status_code=500,
            detail="Documents helper not available"
        )
    
    # Normalize module_id (convert from underscore to match registry keys)
    normalized_id = module_id.lower().replace("-", "_")
    
    try:
        documents = get_documents_by_module(normalized_id)
        if not documents:
            raise HTTPException(
                status_code=404,
                detail=f"Module '{module_id}' not found. Available modules: "
                        "women_harassment, cyber_law, labour_rights, road_laws"
            )
        return documents
    except HTTPException:
        raise
    except Exception as e:
        print(f"❌ Error fetching documents for module {module_id}: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Error fetching documents: {str(e)}"
        )


@app.post("/api/documents/{module_id}/add")
async def add_document_endpoint(module_id: str, document: Dict[str, Any]):
    """
    Add a new document to a module (for administrative use).
    Allows modules to dynamically register their own documents.
    
    Args:
        module_id: Module to add document to
        document: Document data with keys: id, title, type, url, size?, description?, category?
    
    Returns:
        Success message
    """
    if not _DOCUMENTS_HELPER_AVAILABLE:
        raise HTTPException(
            status_code=500,
            detail="Documents helper not available"
        )
    
    normalized_id = module_id.lower().replace("-", "_")
    category = document.get("category", "Other")
    
    try:
        success = add_document_to_module(
            normalized_id,
            category,
            document
        )
        if not success:
            raise HTTPException(
                status_code=404,
                detail=f"Module '{module_id}' not found"
            )
        return {
            "success": True,
            "message": f"Document added to {normalized_id}/{category}",
            "document_id": document.get("id")
        }
    except HTTPException:
        raise
    except Exception as e:
        print(f"❌ Error adding document: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Error adding document: {str(e)}"
        )


@app.delete("/api/documents/{module_id}/{document_id}")
async def remove_document_endpoint(module_id: str, document_id: str):
    """
    Remove a document from a module.
    
    Args:
        module_id: Module containing the document
        document_id: ID of the document to remove
    
    Returns:
        Success message
    """
    if not _DOCUMENTS_HELPER_AVAILABLE:
        raise HTTPException(
            status_code=500,
            detail="Documents helper not available"
        )
    
    normalized_id = module_id.lower().replace("-", "_")
    
    try:
        success = remove_document(normalized_id, document_id)
        if not success:
            raise HTTPException(
                status_code=404,
                detail=f"Document '{document_id}' not found in module '{module_id}'"
            )
        return {
            "success": True,
            "message": f"Document '{document_id}' removed from {normalized_id}"
        }
    except HTTPException:
        raise
    except Exception as e:
        print(f"❌ Error removing document: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Error removing document: {str(e)}"
        )


# ============================================================================
# User Documents Endpoints - Personal/Generated Documents
# ============================================================================

@app.get("/api/user/{user_id}/documents", response_model=UserDocumentsResponse)
async def get_user_documents(user_id: str):
    """
    Get all documents belonging to a specific user.
    
    Documents are personal files that users generate, download, or upload:
    - Complaint generator outputs
    - Filled templates
    - Generated PDFs
    - Uploaded evidence files
    
    Args:
        user_id: UUID of the user
    
    Returns:
        UserDocumentsResponse with list of documents and storage info
    """
    if not _USER_DOCUMENTS_HELPER_AVAILABLE:
        raise HTTPException(
            status_code=500,
            detail="User documents helper not available"
        )
    
    if not _SUPABASE_AVAILABLE:
        # Return empty list if Supabase not configured
        print(f"⚠️  Supabase unavailable for user documents")
        return UserDocumentsResponse(
            user_id=user_id,
            documents=[],
            total_count=0,
            used_bytes=0
        )
    
    try:
        from supabase_client import supabase_client
        
        # Query user's documents
        response = supabase_client.table("user_documents").select(
            "*"
        ).eq(
            "user_id", user_id
        ).eq(
            "is_deleted", False
        ).order(
            "created_at", desc=True
        ).execute()
        
        documents = []
        total_used_bytes = 0
        
        for row in response.data:
            doc = UserDocument(
                id=row['id'],
                user_id=row['user_id'],
                filename=row['filename'],
                title=row.get('title'),
                description=row.get('description'),
                document_type=row['document_type'],
                file_url=row['file_url'],
                file_size=row.get('file_size'),
                mime_type=row.get('mime_type'),
                source_module=row.get('source_module'),
                related_complaint_id=row.get('related_complaint_id'),
                tags=row.get('tags'),
                created_at=row['created_at'],
                updated_at=row.get('updated_at'),
                is_deleted=row.get('is_deleted', False)
            )
            documents.append(doc)
            if row.get('file_size'):
                total_used_bytes += row['file_size']
        
        return UserDocumentsResponse(
            user_id=user_id,
            documents=documents,
            total_count=len(documents),
            used_bytes=total_used_bytes
        )
    except Exception as e:
        print(f"❌ Error fetching user documents: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Error fetching documents: {str(e)}"
        )


@app.post("/api/user/{user_id}/documents", response_model=Dict[str, Any])
async def save_user_document(user_id: str, request: DocumentUploadRequest):
    """
    Save a new document for a user.
    
    Used when:
    - User generates a complaint PDF
    - User downloads a template
    - User uploads evidence files
    - App generates a document
    
    Args:
        user_id: UUID of the user
        request: Document metadata
    
    Returns:
        Document info and file URL
    """
    if not _USER_DOCUMENTS_HELPER_AVAILABLE:
        raise HTTPException(
            status_code=500,
            detail="User documents helper not available"
        )
    
    if not _SUPABASE_AVAILABLE:
        raise HTTPException(
            status_code=501,
            detail="Document storage not configured"
        )
    
    # Validate document type
    from user_documents_helper import DOCUMENT_TYPES
    if request.document_type not in DOCUMENT_TYPES:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid document type. Must be one of: {', '.join(DOCUMENT_TYPES.keys())}"
        )
    
    try:
        from supabase_client import supabase_client
        import uuid
        
        # Generate document ID
        doc_id = str(uuid.uuid4())
        
        # Prepare storage path
        storage_path = f"user_documents/{user_id}/{doc_id}/{request.filename}"
        
        # Note: Actual file upload would happen separately with the file content
        # This endpoint just saves the metadata
        
        # Insert into database
        response = supabase_client.table("user_documents").insert({
            "id": doc_id,
            "user_id": user_id,
            "filename": request.filename,
            "title": request.title,
            "description": request.description,
            "document_type": request.document_type,
            "storage_path": storage_path,
            "file_url": f"/documents/{doc_id}/{request.filename}",
            "file_size": request.file_size,
            "mime_type": request.mime_type,
            "source_module": request.source_module,
            "related_complaint_id": request.related_complaint_id,
            "tags": request.tags or [],
            "created_at": datetime.now(timezone.utc).isoformat(),
        }).execute()
        
        if response.data:
            doc_data = response.data[0]
            # Notify user that document is ready (best-effort, don't fail on errors)
            try:
                if _NOTIFICATIONS_AVAILABLE:
                    try:
                        NotificationHelper.notify_document_ready(user_id, doc_id, request.document_type)
                    except Exception as _:
                        pass
            except Exception:
                pass
            return {
                "success": True,
                "document_id": doc_id,
                "filename": request.filename,
                "document_type": request.document_type,
                "file_url": doc_data['file_url'],
                "storage_path": storage_path,
                "message": f"Document '{request.filename}' saved successfully"
            }
        else:
            raise Exception("Failed to save document to database")
            
    except HTTPException:
        raise
    except Exception as e:
        print(f"❌ Error saving user document: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Error saving document: {str(e)}"
        )


@app.delete("/api/user/{user_id}/documents/{document_id}")
async def delete_user_document(user_id: str, document_id: str):
    """
    Soft-delete a user's document.
    
    Args:
        user_id: UUID of the user
        document_id: UUID of the document to delete
    
    Returns:
        Success message
    """
    if not _USER_DOCUMENTS_HELPER_AVAILABLE:
        raise HTTPException(
            status_code=500,
            detail="User documents helper not available"
        )
    
    if not _SUPABASE_AVAILABLE:
        raise HTTPException(
            status_code=501,
            detail="Document storage not configured"
        )
    
    try:
        from supabase_client import supabase_client
        
        # Soft delete: mark as deleted
        response = supabase_client.table("user_documents").update({
            "is_deleted": True,
            "deleted_at": datetime.now(timezone.utc).isoformat()
        }).eq(
            "id", document_id
        ).eq(
            "user_id", user_id
        ).execute()
        
        if response.data:
            return {
                "success": True,
                "message": f"Document deleted successfully",
                "document_id": document_id
            }
        else:
            raise HTTPException(
                status_code=404,
                detail="Document not found or already deleted"
            )
            
    except HTTPException:
        raise
    except Exception as e:
        print(f"❌ Error deleting user document: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Error deleting document: {str(e)}"
        )


@app.get("/api/user/{user_id}/documents/stats")
async def get_user_documents_stats(user_id: str):
    """
    Get storage statistics for a user's documents.
    
    Args:
        user_id: UUID of the user
    
    Returns:
        Storage usage and quota information
    """
    if not _USER_DOCUMENTS_HELPER_AVAILABLE:
        raise HTTPException(
            status_code=500,
            detail="User documents helper not available"
        )
    
    if not _SUPABASE_AVAILABLE:
        return {
            "user_id": user_id,
            "total_documents": 0,
            "total_size_bytes": 0,
            "quota_bytes": 100 * 1024 * 1024,
            "used_percentage": 0,
            "documents_by_type": {}
        }
    
    try:
        from supabase_client import supabase_client
        
        # Get documents for user
        response = supabase_client.table("user_documents").select(
            "id, document_type, file_size"
        ).eq(
            "user_id", user_id
        ).eq(
            "is_deleted", False
        ).execute()
        
        total_size = 0
        docs_by_type = {}
        
        for row in response.data:
            doc_type = row['document_type']
            size = row.get('file_size', 0)
            
            total_size += size
            docs_by_type[doc_type] = docs_by_type.get(doc_type, 0) + 1
        
        quota = 100 * 1024 * 1024  # 100 MB
        used_percentage = (total_size / quota * 100) if quota > 0 else 0
        
        return {
            "user_id": user_id,
            "total_documents": len(response.data),
            "total_size_bytes": total_size,
            "quota_bytes": quota,
            "used_percentage": round(used_percentage, 2),
            "documents_by_type": docs_by_type,
            "quota_warning": used_percentage > 80
        }
        
    except Exception as e:
        print(f"❌ Error getting document stats: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Error getting stats: {str(e)}"
        )


if __name__ == "__main__":
    import uvicorn
    print("\n🚀 Starting Legal Sathi RAG API...")
    print("📍 API will be available at: http://localhost:8000")
    print("📖 Docs available at: http://localhost:8000/docs")
    uvicorn.run(app, host="0.0.0.0", port=8000)
