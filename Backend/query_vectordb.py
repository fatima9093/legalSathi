import chromadb
from pathlib import Path
from chromadb.utils import embedding_functions

# Connect to database
BASE_DIR = Path(__file__).resolve().parent
CHROMA_DB_PATH = BASE_DIR / "chroma_db"
client = chromadb.PersistentClient(path=str(CHROMA_DB_PATH))
embedding_function = embedding_functions.SentenceTransformerEmbeddingFunction(
    model_name="all-MiniLM-L6-v2"
)

collection = client.get_collection(
    name="legal_documents",
    embedding_function=embedding_function
)

print(f"📊 Database loaded! Total chunks: {collection.count()}\n")

# Example queries
queries = [
    "What are the penalties for cybercrime?",
    "workplace harassment complaint procedure",
    "minimum wage for workers",
    "traffic violation fines"
]

for query in queries:
    print(f"🔍 Query: {query}")
    print("-" * 60)
    
    results = collection.query(
        query_texts=[query],
        n_results=3
    )
    
    for i, (doc, metadata) in enumerate(zip(results['documents'][0], results['metadatas'][0]), 1):
        print(f"\n  Result {i}:")
        print(f"  Module: {metadata['module']}")
        print(f"  File: {metadata['file']}")
        print(f"  Content: {doc[:150]}...")
    
    print("\n" + "="*60 + "\n")


