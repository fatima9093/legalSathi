# Legal Sathi RAG Backend

Backend API for Legal Sathi mobile app with RAG (Retrieval Augmented Generation) using ChromaDB and Groq.

## 🎯 Features

- **RAG System**: Searches vector database first, falls back to Groq LLM
- **4 Legal Modules**: Women Harassment, Labour Rights, Cyber Law, Road Laws
- **Smart Fallback**: Uses Groq when no relevant documents found
- **REST API**: Easy integration with Flutter app

## 📦 Installation

### 1. Install Python Dependencies

```bash
cd backend
pip install -r requirements.txt
```

### 2. Verify Vector Database

Make sure `chroma_db` folder exists with your legal documents already embedded.

To recreate the database:
```bash
python create_vectordb.py
```

### 3. Set Groq API Key

Edit `.env` file and add your Groq API key:
```
GROQ_API_KEY=your_groq_api_key_here
```

## 🚀 Running the Server

### Start the API server:
```bash
python main.py
```

Or using uvicorn directly:
```bash
uvicorn main:app --reload --port 8000
```

The API will be available at:
- **API**: http://localhost:8000
- **Docs**: http://localhost:8000/docs
- **Health Check**: http://localhost:8000/

## 📡 API Endpoints

### 1. Ask Question
```http
POST /api/ask
Content-Type: application/json

{
  "question": "What is the penalty for workplace harassment?",
  "module": "women_harassment"  // optional: filter by module
}
```

Response:
```json
{
  "answer": "According to PAHAW 2010...",
  "source": "vector_db",
  "confidence": 0.85,
  "module": "women_harassment",
  "file": "PAHAW 2010.pdf"
}
```

### 2. Get Statistics
```http
GET /api/stats
```

### 3. Health Check
```http
GET /
```

## 🔧 How It Works

1. **User asks question** → Sent to `/api/ask`
2. **Search Vector DB** → ChromaDB finds similar legal documents
3. **Check confidence** → If match found (confidence > 0.3):
   - ✅ Use document context + Groq to generate answer
   - Source: `"vector_db"`
4. **Fallback** → If no good match:
   - ⚠️ Use Groq general knowledge (limited to 4 modules)
   - Source: `"groq_fallback"`
5. **Return answer** → With source, confidence, and metadata

## 📊 Modules

- `women_harassment`: PAHAW 2010, workplace harassment
- `labour_rights`: Minimum wage, worker rights, contracts
- `cyber_law`: Cybercrime, online harassment, PECA
- `road_laws`: Traffic rules, violations, fines

## 🧪 Testing

Test with curl:
```bash
curl -X POST http://localhost:8000/api/ask \
  -H "Content-Type: application/json" \
  -d '{"question": "What is cyberstalking?"}'
```

Or visit http://localhost:8000/docs for interactive API testing.

## 🔒 Security Notes

- For production, update CORS settings in `main.py`
- Store API keys in environment variables
- Use HTTPS in production
- Implement rate limiting

## 📝 File Structure

```
backend/
├── main.py                 # FastAPI server
├── requirements.txt        # Python dependencies
├── .env                    # Environment variables
├── chroma_db/             # Vector database
├── data/                  # Original PDF files
│   ├── women_harassment/
│   ├── Labour_rights/
│   ├── cyber_law/
│   └── road_laws/
├── create_vectordb.py     # Script to rebuild DB
├── query_vectordb.py      # Test queries
└── README.md              # This file
```

## 🐛 Troubleshooting

**Issue**: ChromaDB not loading
- Run `python create_vectordb.py` to recreate database

**Issue**: Groq API errors
- Check API key in `.env`
- Verify rate limits (14,400 requests/day on free tier)

**Issue**: CORS errors from Flutter
- Check CORS settings in `main.py`
- Ensure server is running on correct port

## 📞 Support

For issues, check the main project README or contact the development team.
