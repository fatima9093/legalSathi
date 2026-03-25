# Multi-Language Support Implementation Guide

## Overview

Legal Sathi now supports **3 languages** for complete multi-language UI and content delivery:
- 🇬🇧 **English**
- 🇵🇰 **اردو (Urdu)**
- 🇵🇰 **Roman Urdu** (Latin script)

Language preference is persisted per user in Supabase and applied across all API responses.

---

## Architecture

### Frontend (Already Implemented)
- ✅ Flutter intl package for localization
- ✅ ARB files for translations (app_en.arb, app_ur.arb, app_ru.arb)
- ✅ Provider pattern for global language state
- ✅ Language selection screen post-login
- ✅ Settings page to change language anytime

### Backend (New Implementation)

#### 1. **Database Schema**
Added `language` column to Supabase `profiles` table:
```sql
ALTER TABLE public.profiles 
ADD COLUMN language text default 'English' 
  check (language in ('English', 'Urdu', 'Roman Urdu'));
```

#### 2. **New Supabase Client** (`supabase_client.py`)
Isolated module for language preference management:
- `get_user_language(user_id)` - Fetch user's language preference
- `set_user_language(user_id, language)` - Update user's language preference
- `get_user_profile(user_id)` - Fetch complete user profile
- `check_languages_available()` - Check Supabase connectivity

#### 3. **ChromaDB Language Metadata**
Updated document creation in `create_vectordb.py`:
```python
# Each document now includes language metadata
metadatas=[{
    "module": module_name,
    "file": pdf_file.name,
    "chunk_id": i,
    "total_chunks": len(chunks),
    "language": "English"  # NEW: Language metadata
}]
```

#### 4. **Language-Aware API Queries**
Updated all ChromaDB queries in `main.py` to filter by language:
```python
# Smart filtering: only applies if language != "English"
# (ensures backward compatibility with existing documents)
where_filter = {}
if agent_module:
    where_filter["module"] = agent_module
if request.language and request.language != "English":
    where_filter["language"] = request.language

results = collection.query(
    query_texts=[question],
    n_results=5,
    where=where_filter,
    include=["documents", "metadatas", "distances"]
)
```

---

## New API Endpoints

### 1. Get User's Language Preference
```http
GET /api/user/{user_id}/language
```

**Response:**
```json
{
  "user_id": "550e8400-e29b-41d4-a716-446655440000",
  "language": "Urdu",
  "message": "Language preference fetched: Urdu"
}
```

**Default:** "English" (if not set or Supabase unavailable)

---

### 2. Update User's Language Preference
```http
POST /api/user/{user_id}/language
Content-Type: application/json

{
  "language": "Urdu"
}
```

**Valid languages:** "English", "Urdu", "Roman Urdu"

**Response:**
```json
{
  "user_id": "550e8400-e29b-41d4-a716-446655440000",
  "language": "Urdu",
  "message": "Language updated successfully: Urdu"
}
```

**Error Response (invalid language):**
```json
{
  "detail": "Language must be \"English\", \"Urdu\", or \"Roman Urdu\""
}
```

---

### 3. Get Supported Languages
```http
GET /api/languages
```

**Response:**
```json
{
  "supported_languages": [
    {
      "code": "English",
      "name": "English",
      "native_name": "English",
      "rtl": false
    },
    {
      "code": "Urdu",
      "name": "Urdu",
      "native_name": "اردو",
      "rtl": true
    },
    {
      "code": "Roman Urdu",
      "name": "Roman Urdu",
      "native_name": "Urdu (Roman)",
      "rtl": false
    }
  ],
  "default_language": "English"
}
```

---

## Modified Existing Endpoints

### QuestionRequest Model
Now includes optional `language` parameter (default: "English"):
```python
class QuestionRequest(BaseModel):
    question: str
    module: Optional[str] = None
    language: str = "English"  # ← NEW
    use_agents: bool = False
    conversation_id: Optional[str] = None
    conversation_history: List[ConversationTurn] = []
    response_length: Optional[str] = None
```

### /api/ask (and /api/ask/stream, /api/ask/agent)
Now automatically filters ChromaDB by user's language preference:

**Request:**
```json
{
  "question": "کیا میں کم از کم تنخواہ حاصل کر سکتا ہوں؟",
  "module": "labour_rights",
  "language": "Urdu"
}
```

**Behavior:**
1. ✅ Fetches user's language preference from Supabase
2. ✅ Filters ChromaDB query by language
3. ✅ If language-specific content not found → Falls back to English
4. ✅ Returns answer (translated or in original language)
5. ✅ Includes language metadata in response

---

## Setup Instructions

### Step 1: Update .env File
Create a `.env` file in the `Backend/` directory (or copy from `.env.example`):

```bash
# Required
GROQ_API_KEY=your_groq_api_key_here

# For language persistence (optional but recommended)
SUPABASE_URL=https://ghwvezmgxpwwfxaeeriy.supabase.co
SUPABASE_SERVICE_KEY=your_supabase_service_role_key
```

**To get Supabase credentials:**
1. Go to [app.supabase.com](https://app.supabase.com)
2. Select your project
3. Go to **Settings → API**
4. Copy:
   - **Project URL** → SUPABASE_URL
   - **Service Role Key** → SUPABASE_SERVICE_KEY
   - ⚠️ Keep the service key SECRET!

### Step 2: Install Supabase Python Package (Optional)
Language persistence requires the Supabase Python client:

```bash
pip install supabase-py
```

If not installed, the backend will run with a warning, and language persistence will be unavailable.

### Step 3: Update Supabase Schema
Run the SQL migration in Supabase Dashboard → **SQL Editor**:

```sql
-- Add language column to profiles table
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS language text default 'English' 
  check (language in ('English', 'Urdu', 'Roman Urdu'));

-- Update auto-create trigger to set default language
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, email, language, created_at, last_login)
  VALUES (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', ''),
    new.email,
    'English',
    now(),
    now()
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### Step 4: Restart Backend Server
```bash
python main.py
```

You should see:
```
✅ Supabase client initialized
```

---

## Future Development: Multilingual Content

### Current State
- ✅ Language column in database
- ✅ Language filtering in queries
- ✅ API endpoints for language management
- ⏳ Content in other languages (English only for now)

### To Add Urdu/Roman Urdu Content
1. Translate legal documents to Urdu/Roman Urdu
2. Store in `data/women_harassment/`, `data/labour_rights/`, etc.
3. Update ChromaDB metadata with correct language:
   ```python
   metadatas=[{
       "module": module_name,
       "file": pdf_file.name,
       "chunk_id": i,
       "total_chunks": len(chunks),
       "language": "Urdu"  # or "Roman Urdu"
   }]
   ```
4. Recreate vector database: `python create_vectordb.py`

---

## Backward Compatibility

✅ **Non-breaking implementation:**
- Default language: "English"
- Existing queries work without language parameter
- If Supabase unavailable → Falls back to English
- ChromaDB queries filtered only for non-English languages
- Existing documents treated as "English" automatically

---

## Testing

### Test Language Endpoints
```bash
# Get supported languages
curl http://localhost:8000/api/languages

# Get user's language (initially "English")
curl http://localhost:8000/api/user/550e8400-e29b-41d4-a716-446655440000/language

# Update user's language
curl -X POST http://localhost:8000/api/user/550e8400-e29b-41d4-a716-446655440000/language \
  -H "Content-Type: application/json" \
  -d '{"language": "Urdu"}'

# Ask question in Urdu
curl -X POST http://localhost:8000/api/ask \
  -H "Content-Type: application/json" \
  -d '{
    "question": "کیا میں کم از کم تنخواہ حاصل کر سکتا ہوں؟",
    "module": "labour_rights",
    "language": "Urdu"
  }'
```

---

## Error Handling

### Supabase Unavailable
If Supabase is not configured or unreachable:
- ✅ Backend continues to work
- ⚠️ Language preference not persisted
- 🔄 Default to "English" for all queries
- 📝 Warning logged: "⚠️ SUPABASE_URL or SUPABASE_SERVICE_KEY not found in .env"

### Invalid Language
```json
{
  "detail": "Language must be \"English\", \"Urdu\", or \"Roman Urdu\""
}
```

### Language-Specific Content Not Found
- ✅ Backend searches for content in requested language
- ✅ If not found, falls back to English
- 📝 No error thrown (graceful degradation)

---

## RTL (Right-to-Left) Support

For Urdu text rendering on frontend:
- ✅ `/api/languages` endpoint returns `"rtl": true` for Urdu
- ✅ Frontend can use this flag to set text direction
- ✅ Flutter supports RTL via `Directionality` widget

**Frontend usage:**
```dart
// In chat_screen.dart or response display
bool isRTL = response.language == "Urdu";
Directionality(
  textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
  child: Text(response.answer),
)
```

---

## Summary of Changes

| File | Change | Impact |
|------|--------|--------|
| `supabase_schema.sql` | Added `language` column to profiles | ✅ Schema updated |
| `supabase_client.py` | New file - Supabase client | ✅ Language persistence |
| `create_vectordb.py` | Added language metadata to docs | ✅ Language filtering ready |
| `main.py` | Language filtering in queries + 3 new endpoints | ✅ Full language support |
| `.env.example` | Added Supabase config instructions | ✅ Setup guide |
| This file | Documentation | ✅ Developer reference |

---

## Next Steps

1. ✅ **Copy `.env.example` to `.env`** and add your credentials
2. ✅ **Run Supabase SQL migration** in dashboard
3. ✅ **Restart backend** and verify "✅ Supabase client initialized" message
4. ✅ **Test endpoints** using curl or Postman
5. ✅ **Frontend calls** `/api/user/{user_id}/language` to fetch/update preference
6. ✅ **Frontend sends** `language` parameter in `/api/ask` requests

---

## Questions?

- Check the main `Backend/README.md` for general backend setup
- Check `Frontend/FIREBASE_TO_SUPABASE_MIGRATION.md` for frontend-Supabase integration
- Review agent documentation for multi-language agent responses
