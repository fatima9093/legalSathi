#!/bin/bash

echo "========================================"
echo "  Legal Sathi RAG Backend Server"
echo "========================================"
echo ""

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python not found! Please install Python 3.8+ first."
    exit 1
fi

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv venv
    echo "✅ Virtual environment created!"
    echo ""
fi

# Activate virtual environment
echo "🔄 Activating virtual environment..."
source venv/bin/activate

# Check if dependencies are installed
if ! python -c "import fastapi" &> /dev/null; then
    echo "📦 Installing dependencies..."
    pip install -r requirements.txt
    echo "✅ Dependencies installed!"
    echo ""
fi

# Check if ChromaDB exists
if [ ! -f "chroma_db/chroma.sqlite3" ]; then
    echo "⚠️ WARNING: ChromaDB not found!"
    echo "Please run: python create_vectordb.py first"
    echo ""
    exit 1
fi

# Start the server
echo "🚀 Starting Legal Sathi RAG API..."
echo ""
echo "📍 API: http://localhost:8000"
echo "📖 Docs: http://localhost:8000/docs"
echo ""
echo "Press Ctrl+C to stop the server"
echo "========================================"
echo ""

python main.py
