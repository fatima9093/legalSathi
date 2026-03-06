@echo off
echo ========================================
echo   Legal Sathi RAG Backend Server
echo ========================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python not found! Please install Python 3.8+ first.
    pause
    exit /b 1
)

REM Check if virtual environment exists
if not exist "venv" (
    echo 📦 Creating virtual environment...
    python -m venv venv
    echo ✅ Virtual environment created!
    echo.
)

REM Activate virtual environment
echo 🔄 Activating virtual environment...
call venv\Scripts\activate.bat

REM Check if dependencies are installed
python -c "import fastapi" >nul 2>&1
if errorlevel 1 (
    echo 📦 Installing dependencies...
    pip install -r requirements.txt
    echo ✅ Dependencies installed!
    echo.
)

REM Check if ChromaDB exists
if not exist "chroma_db\chroma.sqlite3" (
    echo ⚠️ WARNING: ChromaDB not found!
    echo Please run: python create_vectordb.py first
    echo.
    pause
    exit /b 1
)

REM Start the server
echo 🚀 Starting Legal Sathi RAG API...
echo.
echo 📍 API: http://localhost:8000
echo 📖 Docs: http://localhost:8000/docs
echo.
echo Press Ctrl+C to stop the server
echo ========================================
echo.

python main.py

pause
