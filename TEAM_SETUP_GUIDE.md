# Legal Sathi - Team Setup Guide

Welcome to the Legal Sathi project! This guide will help you set up the project on your local machine.

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.0 or higher) - [Install Flutter](https://flutter.dev/docs/get-started/install)
- **Python** (3.8 or higher) - [Install Python](https://www.python.org/downloads/)
- **Git** - [Install Git](https://git-scm.com/downloads)
- **Android Studio** or **VS Code** with Flutter extensions

---

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/fatima9093/legalSathi.git
cd legalSathi/fyp-project-code
```

---

## 📱 Frontend Setup (Flutter)

### Step 1: Navigate to Frontend Directory

```bash
cd frontend
```

### Step 2: Install Flutter Dependencies

```bash
flutter pub get
```

### Step 3: Install FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

### Step 4: Generate Firebase Configuration

**Important:** The `firebase_options.dart` file is not included in the repository for security reasons. You need to generate it:

```bash
flutterfire configure --project=legal-sathi-f6009
```

This command will:
- Automatically create `lib/firebase_options.dart`
- Configure Firebase for all platforms (Android, iOS, Web, Windows, macOS)

### Step 5: Run the Flutter App

```bash
flutter run
```

Or select your device in VS Code/Android Studio and click Run.

---

## 🔧 Backend Setup (Python + FastAPI)

### Step 1: Navigate to Backend Directory

```bash
cd Backend
```

### Step 2: Create a Virtual Environment

**Windows:**
```bash
python -m venv venv
venv\Scripts\activate
```

**Mac/Linux:**
```bash
python3 -m venv venv
source venv/bin/activate
```

### Step 3: Install Python Dependencies

```bash
pip install -r requirements.txt
```

### Step 4: Create Environment File

Create a `.env` file in the Backend directory:

```bash
# .env file content
GROQ_API_KEY=your_groq_api_key_here
```

**To get a Groq API key:**
1. Go to [Groq Console](https://console.groq.com/)
2. Sign up or log in
3. Generate an API key
4. Replace `your_groq_api_key_here` with your actual key

### Step 5: Set Up Vector Database

```bash
python create_vectordb.py
```

This will process all legal documents and create the ChromaDB vector database.

### Step 6: Start the Backend Server

**Windows:**
```bash
start_server.bat
```

**Mac/Linux:**
```bash
./start_server.sh
```

Or manually:
```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

The API will be available at: `http://localhost:8000`
API Documentation: `http://localhost:8000/docs`

---

## 🗂️ Project Structure

```
fyp-project-code/
├── Backend/
│   ├── main.py              # FastAPI server
│   ├── create_vectordb.py   # Vector DB creation script
│   ├── query_vectordb.py    # Query functions
│   ├── requirements.txt     # Python dependencies
│   ├── .env                 # Environment variables (not in git)
│   └── data/                # Legal documents
│
└── frontend/
    ├── lib/
    │   ├── main.dart
    │   ├── firebase_options.dart  # Generated (not in git)
    │   └── ...
    └── pubspec.yaml
```

---

## 🔒 Security Notes

### Files NOT Included in Git (You Must Create Them):

1. **Backend/.env** - Contains API keys
2. **frontend/lib/firebase_options.dart** - Contains Firebase configuration

These files are excluded for security reasons. Follow the setup steps above to generate them.

---

## 🐛 Troubleshooting

### Flutter Issues

**Problem:** `firebase_options.dart not found`
- **Solution:** Run `flutterfire configure --project=legal-sathi-f6009`

**Problem:** Flutter packages not found
- **Solution:** Run `flutter pub get`

**Problem:** Android SDK issues
- **Solution:** Run `flutter doctor` and follow instructions

### Backend Issues

**Problem:** `GROQ_API_KEY not found`
- **Solution:** Create `.env` file with your Groq API key

**Problem:** ChromaDB errors
- **Solution:** Delete `chroma_db` folder and run `python create_vectordb.py` again

**Problem:** Port 8000 already in use
- **Solution:** Kill the process using port 8000 or change the port in `main.py`

---

## 🧪 Testing the Setup

### Test Backend API

```bash
cd Backend
python test_api.py
```

Or visit: `http://localhost:8000/docs` for interactive API testing

### Test Flutter App

```bash
cd frontend
flutter run
```

---

## 📞 Need Help?

If you encounter any issues:
1. Check the [Troubleshooting](#-troubleshooting) section
2. Ask in the team chat
3. Check existing issues on GitHub

---

## 🎉 You're All Set!

Once both frontend and backend are running:
- Backend API: `http://localhost:8000`
- Flutter App: Running on your device/emulator

Happy coding! 🚀
