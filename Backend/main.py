import os
# Disable ChromaDB telemetry (stops "Failed to send telemetry event" messages)
os.environ["ANONYMIZED_TELEMETRY"] = "false"

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from typing import Optional
from pydantic import BaseModel
import chromadb
from chromadb.utils import embedding_functions
from groq import Groq
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

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
client = chromadb.PersistentClient(path="./chroma_db")
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
        print("   → Your DB was created with a different ChromaDB version. Delete folder 'chroma_db' and run: python create_vectordb.py")
    collection = None

# Initialize Groq
GROQ_API_KEY = os.getenv("GROQ_API_KEY")
groq_client = None
try:
    groq_client = Groq(api_key=GROQ_API_KEY)
except Exception as e:
    print(f"❌ Error initializing Groq: {e}")
    print("   → Try: pip install 'httpx>=0.24,<0.28'")

# Request/Response models
class QuestionRequest(BaseModel):
    question: str
    module: Optional[str] = None  # Optional: filter by specific module

class AnswerResponse(BaseModel):
    answer: str
    source: str  # "vector_db" or "groq_fallback"
    confidence: float
    module: Optional[str] = None
    file: Optional[str] = None

# Module mapping
MODULE_NAMES = {
    "women_harassment": "Women Harassment",
    "labour_rights": "Labour Rights", 
    "cyber_law": "Cyber Law",
    "road_laws": "Road Laws"
}

@app.get("/")
async def root():
    """Health check endpoint"""
    return {
        "status": "running",
        "message": "Legal Sathi RAG API",
        "vector_db_loaded": collection is not None,
        "total_documents": collection.count() if collection else 0
    }

@app.post("/api/ask", response_model=AnswerResponse)
async def ask_question(request: QuestionRequest):
    """
    Main endpoint for asking questions
    1. Searches vector DB first
    2. Falls back to Groq if no good match found
    """
    
    if not collection:
        raise HTTPException(status_code=500, detail="Vector database not loaded")
    if not groq_client:
        raise HTTPException(status_code=500, detail="Groq client not initialized")
    
    question = request.question.strip()
    if not question:
        raise HTTPException(status_code=400, detail="Question cannot be empty")
    
    try:
        # Step 1: Search Vector DB
        print(f"\n🔍 Query: {question}")
        
        # Build filter if module specified
        where_filter = None
        if request.module and request.module in MODULE_NAMES.keys():
            where_filter = {"module": request.module}
        
        results = collection.query(
            query_texts=[question],
            n_results=5,  # Get top 5 results
            where=where_filter,
            include=["documents", "metadatas", "distances"]
        )
        
        # Check if we have results
        if results['documents'] and len(results['documents'][0]) > 0:
            best_distance = results['distances'][0][0]
            confidence = 1 - best_distance  # Convert distance to confidence
            
            print(f"📊 Best match distance: {best_distance:.4f} (confidence: {confidence:.4f})")
            
            # Step 2: If good match found (distance < 0.7 = confidence > 0.3)
            if best_distance < 0.7:
                # Combine top results as context
                context_chunks = []
                for doc, metadata in zip(results['documents'][0][:3], results['metadatas'][0][:3]):
                    context_chunks.append(f"[{metadata['file']}]\n{doc}")
                
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
- Answer in a clear, professional manner
- If the context contains the answer, provide it with relevant details
- If the context doesn't fully answer the question, say "Based on the available documents..." and provide what you can
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
                    module=module_name,
                    file=file_name
                )
        
        # Step 3: No good match - use Groq fallback
        print("⚠️ No good match in Vector DB, using Groq fallback...")
        
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
            module=None,
            file=None
        )
        
    except Exception as e:
        print(f"❌ Error: {e}")
        raise HTTPException(status_code=500, detail=f"Error processing question: {str(e)}")

@app.get("/api/stats")
async def get_stats():
    """Get database statistics"""
    if not collection:
        raise HTTPException(status_code=500, detail="Vector database not loaded")
    
    # Get count per module
    module_counts = {}
    for module_key in MODULE_NAMES.keys():
        count = collection.count(where={"module": module_key})
        module_counts[MODULE_NAMES[module_key]] = count
    
    return {
        "total_chunks": collection.count(),
        "modules": module_counts
    }

if __name__ == "__main__":
    import uvicorn
    print("\n🚀 Starting Legal Sathi RAG API...")
    print("📍 API will be available at: http://localhost:8000")
    print("📖 Docs available at: http://localhost:8000/docs")
    uvicorn.run(app, host="0.0.0.0", port=8000)
