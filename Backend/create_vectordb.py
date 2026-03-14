import os
import shutil
import warnings
from pathlib import Path

# Disable ChromaDB telemetry (stops "Failed to send telemetry event" messages)
os.environ["ANONYMIZED_TELEMETRY"] = "false"

from pypdf import PdfReader
import chromadb
from chromadb.utils import embedding_functions

print("Starting vector database creation...")

# Remove old chroma_db folder if it exists (fixes schema mismatch from different ChromaDB versions)
BASE_DIR = Path(__file__).resolve().parent
chroma_path = BASE_DIR / "chroma_db"
if chroma_path.exists():
    print("Removing old chroma_db folder (different schema)...")
    shutil.rmtree(chroma_path)

# Initialize ChromaDB
client = chromadb.PersistentClient(path=str(chroma_path))

# Use sentence transformers for embeddings
embedding_function = embedding_functions.SentenceTransformerEmbeddingFunction(
    model_name="all-MiniLM-L6-v2"
)

# Create collection (delete if exists for fresh start)
try:
    client.delete_collection("legal_documents")
except:
    pass

collection = client.create_collection(
    name="legal_documents",
    embedding_function=embedding_function
)

# Define modules
modules = {
    "women_harassment": "data/women_harassment",
    "labour_rights": "data/Labour_rights",
    "cyber_law": "data/cyber_law",
    "road_laws": "data/road_laws"
}

def extract_text_from_pdf(pdf_path):
    """Extract text from PDF file"""
    try:
        with warnings.catch_warnings():
            warnings.simplefilter("ignore")  # Suppress "Multiple definitions in dictionary" from pypdf
            reader = PdfReader(pdf_path)
        full_text = ""
        for page in reader.pages:
            text = page.extract_text()
            if text:
                full_text += text + "\n"
        return full_text
    except Exception as e:
        print(f"Error reading {pdf_path}: {e}")
        return ""

def chunk_text(text, chunk_size=1000, overlap=200):
    """Split text into overlapping chunks"""
    chunks = []
    start = 0
    while start < len(text):
        end = start + chunk_size
        chunks.append(text[start:end])
        start = end - overlap
    return chunks

# Process all PDFs
total_docs = 0
total_chunks = 0

for module_name, folder_path in modules.items():
    if os.path.exists(folder_path):
        print(f"\n📁 Processing module: {module_name}")
        
        # Find all PDFs recursively (including subfolders)
        for pdf_file in Path(folder_path).rglob("*.pdf"):
            print(f"  → {pdf_file.name}")
            
            # Extract text
            text = extract_text_from_pdf(str(pdf_file))
            
            if not text.strip():
                print(f"    ⚠️ No text extracted, skipping")
                continue
            
            # Chunk text
            chunks = chunk_text(text)
            
            # Add to ChromaDB
            for i, chunk in enumerate(chunks):
                collection.add(
                    documents=[chunk],
                    metadatas=[{
                        "module": module_name,
                        "file": pdf_file.name,
                        "chunk_id": i,
                        "total_chunks": len(chunks)
                    }],
                    ids=[f"{module_name}_{pdf_file.stem}_{i}"]
                )
            
            total_chunks += len(chunks)
            total_docs += 1
            print(f"    ✓ Added {len(chunks)} chunks")

print(f"\n{'='*50}")
print(f"✅ SUCCESS!")
print(f"📄 Processed documents: {total_docs}")
print(f"📦 Total chunks in database: {collection.count()}")
print(f"{'='*50}")


