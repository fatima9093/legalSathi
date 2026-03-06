# ⚡ Quick Start - Legal Sathi RAG Backend

## 🎯 In 3 Steps

### 1️⃣ Install Dependencies (First Time Only)

```bash
cd E:\legalSathi-mobileApp\backend
pip install -r requirements.txt
```

### 2️⃣ Start Backend

**Option A: Double-click**
```
start_server.bat
```

**Option B: Terminal**
```bash
python main.py
```

### 3️⃣ Run Flutter App

```bash
cd E:\legalSathi-mobileApp\fyp-project-code
flutter run -d chrome
```

---

## ✅ Verify It's Working

1. **Backend running?**
   - Open: http://localhost:8000
   - Should see: `{"status": "running"}`

2. **Test with curl** (optional):
   ```bash
   curl -X POST http://localhost:8000/api/ask -H "Content-Type: application/json" -d "{\"question\": \"What is workplace harassment?\"}"
   ```

3. **Test in Flutter app**:
   - Open Chat screen
   - Ask: "What is cybercrime?"
   - Should get answer with 📚 source indicator

---

## 🐛 Common Issues

| Problem | Fix |
|---------|-----|
| ❌ `ModuleNotFoundError` | Run `pip install -r requirements.txt` |
| ❌ Backend won't start | Check if port 8000 is free: `netstat -an \| findstr "8000"` |
| ❌ Flutter can't connect | Make sure backend is running first |
| ❌ "Vector DB not loaded" | Run `python create_vectordb.py` |

---

## 📊 API Endpoints

- Health: `GET http://localhost:8000/`
- Ask: `POST http://localhost:8000/api/ask`
- Stats: `GET http://localhost:8000/api/stats`
- Docs: `http://localhost:8000/docs` 👈 Interactive!

---

## 🔧 Configuration

**Change Groq API Key**: Edit `backend/.env`

**Change Backend URL in Flutter**: Edit `fyp-project-code/lib/services/llm_service.dart`

---

## 📝 Test Questions

Try these in your app:

✓ "What is workplace harassment?"  
✓ "What are cybercrime penalties?"  
✓ "What is minimum wage in Pakistan?"  
✓ "What are traffic violation fines?"  
✓ "How to file a complaint?"  

---

## 🎯 What This Does

```
Your Question
     ↓
1. Search Vector DB (your PDFs) 📚
     ↓
   Found? → Answer from documents ✅
     ↓ No
2. Use Groq fallback 🤖
     ↓
Answer returned
```

---

## 📞 Need Detailed Help?

See: `E:\legalSathi-mobileApp\SETUP_GUIDE.md`

---

**That's it! Start coding! 🚀**
