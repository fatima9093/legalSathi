"""
supabase_client.py
==================
Supabase client for managing user language preferences and database operations.
Isolated module to avoid breaking existing RAG functionality.
"""

import sys
import os

# Fix Windows charmap encoding errors for emoji/unicode in print statements
if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')
from typing import Optional, Dict, Any
from dotenv import load_dotenv
from pathlib import Path

# Load environment variables
BASE_DIR = Path(__file__).resolve().parent
load_dotenv(dotenv_path=BASE_DIR / ".env")

# Supabase credentials from .env
SUPABASE_URL = os.getenv("SUPABASE_URL", "").strip()
SUPABASE_SERVICE_KEY = os.getenv("SUPABASE_SERVICE_KEY", "").strip()

_supabase_client = None
_initialized = False

def _init_supabase():
    """Lazy initialization of Supabase client."""
    global _supabase_client, _initialized
    
    if _initialized:
        return _supabase_client
    
    _initialized = True
    
    if not SUPABASE_URL or not SUPABASE_SERVICE_KEY:
        print("⚠️  SUPABASE_URL or SUPABASE_SERVICE_KEY not found in .env")
        print("   → Language persistence will be unavailable")
        return None
    
    try:
        from supabase import create_client
        _supabase_client = create_client(SUPABASE_URL, SUPABASE_SERVICE_KEY)
        print("✅ Supabase client initialized")
        return _supabase_client
    except ImportError:
        print("⚠️  supabase-py not installed")
        print("   → Install with: pip install supabase-py")
        return None
    except Exception as e:
        print(f"❌ Error initializing Supabase: {e}")
        return None

def get_user_language(user_id: str) -> str:
    """
    Fetch user's language preference from Supabase.
    
    Args:
        user_id: UUID of the user
        
    Returns:
        Language preference: "English", "Urdu", or "Roman Urdu" (defaults to "English")
    """
    client = _init_supabase()
    if not client:
        return "English"
    
    try:
        response = client.table("profiles").select("language").eq("id", user_id).maybe_single().execute()
        if response.data and response.data.get("language"):
            return response.data["language"]
        return "English"
    except Exception as e:
        print(f"⚠️  Error fetching language for user {user_id}: {e}")
        return "English"

def set_user_language(user_id: str, language: str) -> tuple:
    """
    Update user's language preference in Supabase.
    
    Args:
        user_id: UUID of the user
        language: Language to set ("English", "Urdu", or "Roman Urdu")
        
    Returns:
        Tuple of (success: bool, message: str)
    """
    if language not in ["English", "Urdu", "Roman Urdu"]:
        print(f"❌ Invalid language: {language}")
        return False, f"Invalid language: {language}"
    
    client = _init_supabase()
    if not client:
        return False, "Supabase client not initialized"
    
    try:
        # Directly update without checking first (since GET works, profile must exist)
        # Using proper request format
        result = client.table("profiles").update({"language": language}).eq("id", user_id).execute()
        
        # Check if update was successful
        if result.data:
            print(f"✅ Language updated for user {user_id}: {language}")
            return True, f"Language updated successfully: {language}"
        else:
            # If no data returned, might still be successful with upsert, try to verify
            print(f"⚠️  Update returned empty, verifying...")
            verify = client.table("profiles").select("language").eq("id", user_id).maybe_single().execute()
            if verify.data and verify.data.get("language") == language:
                print(f"✅ Language verified: {language}")
                return True, f"Language updated successfully: {language}"
            else:
                return False, "Update failed - could not verify language change"
                
    except Exception as e:
        error_msg = str(e)
        print(f"❌ Error updating language for user {user_id}: {error_msg}")
        # Try alternative: upsert instead of update
        try:
            print(f"   ↻ Trying upsert method...")
            client.table("profiles").upsert({"id": user_id, "language": language}).execute()
            print(f"✅ Language updated via upsert for user {user_id}: {language}")
            return True, f"Language updated successfully: {language}"
        except Exception as e2:
            return False, f"Supabase error: {str(e2)}"

def get_user_profile(user_id: str) -> Optional[Dict[str, Any]]:
    """
    Fetch complete user profile from Supabase.
    
    Args:
        user_id: UUID of the user
        
    Returns:
        User profile dict or None if not found
    """
    client = _init_supabase()
    if not client:
        return None
    
    try:
        response = client.table("profiles").select("*").eq("id", user_id).maybe_single().execute()
        return response.data
    except Exception as e:
        print(f"⚠️  Error fetching profile for user {user_id}: {e}")
        return None

def check_languages_available() -> bool:
    """
    Check if Supabase is configured and accessible.
    
    Returns:
        True if Supabase is configured and reachable
    """
    client = _init_supabase()
    return client is not None


# Expose a module-level `supabase` client for simpler imports from other helpers.
# This will initialize lazily when the module is imported.
supabase = _init_supabase()


def get_supabase_client():
    """Return the active supabase client or initialize it."""
    return _init_supabase()
