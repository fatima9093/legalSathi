"""
Test script for Legal Sathi RAG API
Run this to test if your backend is working correctly
"""

import requests
import json

BASE_URL = "http://localhost:8000"

def test_health_check():
    """Test if server is running"""
    print("\n" + "="*60)
    print("1️⃣ Testing Health Check...")
    print("="*60)
    
    try:
        response = requests.get(f"{BASE_URL}/")
        print(f"✅ Status: {response.status_code}")
        data = response.json()
        print(f"📊 Vector DB loaded: {data.get('vector_db_loaded')}")
        print(f"📄 Total documents: {data.get('total_documents')}")
        return True
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def test_stats():
    """Test statistics endpoint"""
    print("\n" + "="*60)
    print("2️⃣ Testing Statistics Endpoint...")
    print("="*60)
    
    try:
        response = requests.get(f"{BASE_URL}/api/stats")
        data = response.json()
        print(f"✅ Total chunks: {data.get('total_chunks')}")
        print(f"📚 Modules:")
        for module, count in data.get('modules', {}).items():
            print(f"   - {module}: {count} chunks")
        return True
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def test_question(question, module=None):
    """Test asking a question"""
    print("\n" + "="*60)
    print(f"3️⃣ Testing Question: '{question}'")
    if module:
        print(f"   Module filter: {module}")
    print("="*60)
    
    try:
        payload = {"question": question}
        if module:
            payload["module"] = module
            
        response = requests.post(
            f"{BASE_URL}/api/ask",
            json=payload,
            headers={"Content-Type": "application/json"}
        )
        
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"\n📝 Answer:")
            print(f"{data['answer']}\n")
            print(f"🔍 Source: {data['source']}")
            print(f"📊 Confidence: {data['confidence']:.2f}")
            if data.get('module'):
                print(f"📚 Module: {data['module']}")
                print(f"📄 File: {data['file']}")
            return True
        else:
            print(f"❌ Error: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def main():
    print("\n" + "="*60)
    print("🧪 Legal Sathi RAG API Test Suite")
    print("="*60)
    
    # Test 1: Health check
    if not test_health_check():
        print("\n❌ Server is not running!")
        print("Please start the server first: python main.py")
        return
    
    # Test 2: Stats
    test_stats()
    
    # Test 3: Sample questions
    test_questions = [
        ("What is workplace harassment?", "women_harassment"),
        ("What are the penalties for cyberstalking?", "cyber_law"),
        ("What is the minimum wage for workers?", "labour_rights"),
        ("What are traffic violation fines?", "road_laws"),
        ("What is FIR?", None),  # Test fallback
    ]
    
    for question, module in test_questions:
        test_question(question, module)
    
    print("\n" + "="*60)
    print("✅ Test suite completed!")
    print("="*60 + "\n")

if __name__ == "__main__":
    main()
