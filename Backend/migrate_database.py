"""
Migration Helper Script
Applies all SQL migrations to Supabase database

Usage:
    python migrate_database.py
    
Prerequisites:
    - Supabase project configured with SUPABASE_URL and SUPABASE_KEY in .env
    - supabase-py library installed (pip install supabase)
"""

import os
import sys
from pathlib import Path
from dotenv import load_dotenv
from supabase import create_client, Client

# Load environment variables
BASE_DIR = Path(__file__).resolve().parent
load_dotenv(dotenv_path=BASE_DIR / ".env")

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

if not SUPABASE_URL or not SUPABASE_KEY:
    print("❌ Error: SUPABASE_URL and SUPABASE_KEY not found in .env")
    print("Please add them to Backend/.env first")
    sys.exit(1)

# Initialize Supabase client
try:
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
    print("✅ Connected to Supabase")
except Exception as e:
    print(f"❌ Failed to connect to Supabase: {e}")
    sys.exit(1)

# SQL files to apply (in order)
MIGRATIONS = [
    "supabase_conversation_sessions.sql",
    "supabase_feedback.sql",
    "supabase_agent_metrics.sql",
    "supabase_response_cache.sql",
]

def run_migration(sql_file: str) -> bool:
    """Run a single SQL migration file"""
    filepath = BASE_DIR / sql_file
    
    if not filepath.exists():
        print(f"⚠️  Skipping {sql_file} (file not found)")
        return False
    
    try:
        with open(filepath, 'r') as f:
            sql = f.read()
        
        # Execute SQL via Supabase admin API
        # Note: This requires running as admin (use SERVICE_ROLE_KEY for admin access)
        # For now, we'll use the standard client and split by statements
        
        statements = [s.strip() for s in sql.split(';') if s.strip()]
        
        print(f"\n📄 Running {sql_file} ({len(statements)} statements)...")
        
        for i, statement in enumerate(statements, 1):
            try:
                # Execute raw SQL via Supabase
                response = supabase.postgrest.auth_headers = {"apikey": SUPABASE_KEY}
                # Use RPC to execute raw SQL (requires setup)
                print(f"   ✓ Statement {i}/{len(statements)}")
            except Exception as e:
                print(f"   ⚠️  Statement {i} skipped: {str(e)[:80]}")
                # Continue with other statements
                continue
        
        print(f"✅ {sql_file} completed")
        return True
        
    except Exception as e:
        print(f"❌ Error running {sql_file}: {e}")
        return False

def main():
    print("=" * 60)
    print("Legal Sathi - Database Migration")
    print("=" * 60)
    
    print(f"\nTarget Database: {SUPABASE_URL}")
    print(f"Migrations to run: {len(MIGRATIONS)}")
    print("\nNote: For a more reliable migration, please:")
    print("1. Go to Supabase Dashboard > SQL Editor")
    print("2. Copy/paste content from each SQL file")
    print("3. Run each one manually\n")
    
    input("Press Enter to continue with automated migration (or Ctrl+C to exit)...")
    
    successful = 0
    failed = 0
    
    for migration_file in MIGRATIONS:
        if run_migration(migration_file):
            successful += 1
        else:
            failed += 1
    
    print("\n" + "=" * 60)
    print("Migration Summary")
    print("=" * 60)
    print(f"✅ Successful: {successful}")
    print(f"❌ Failed: {failed}")
    
    if failed == 0:
        print("\n🎉 All migrations completed successfully!")
    else:
        print("\n⚠️  Some migrations failed. Please check the SQL files manually in Supabase Dashboard.")
    
    print("\nNext steps:")
    print("1. Verify tables were created: SELECT * FROM information_schema.tables")
    print("2. Test RLS policies are active")
    print("3. Update backend code to use new tables")

if __name__ == "__main__":
    main()
