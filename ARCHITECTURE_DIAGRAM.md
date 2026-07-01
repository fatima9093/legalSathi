# LegalSathi Project - Design Phase Architecture Diagram

## System Architecture Overview

```mermaid
graph TB
    subgraph "PRESENTATION LAYER - Flutter Frontend"
        direction TB
        UI["🎨 UI Components"]
        UI --> HomeScreen["Home Screen"]
        UI --> ChatScreen["Chat Screen"]
        UI --> TrafficModule["Traffic Module"]
        UI --> CyberModule["Cyber Law Module"]
        UI --> LabourModule["Labour Rights Module"]
        UI --> WomenModule["Women Harassment Module"]
        UI --> ProfileScreen["Profile Screen"]
        UI --> NotifyScreen["Notifications Screen"]
        UI --> SettingsScreen["Settings Screen"]
    end

    subgraph "APPLICATION LAYER - Services & State Management"
        direction TB
        Services["🔧 Core Services"]
        AuthService["AuthService<br/>- Supabase Auth<br/>- Google Sign-In<br/>- Session Management"]
        ActivityService["RecentActivityService<br/>- Activity Tracking<br/>- User Actions"]
        LocalService["Localization Service<br/>- Multi-language Support"]
        CacheService["Cache Service<br/>- Response Caching<br/>- Data Persistence"]
        
        Providers["📊 State Management"]
        LanguageProvider["Language Provider"]
        ThemeProvider["Theme Provider"]
        AuthProvider["Auth State Provider"]
        
        Services -.-> AuthService
        Services -.-> ActivityService
        Services -.-> LocalService
        Services -.-> CacheService
        Services -.-> Providers
    end

    subgraph "BUSINESS LOGIC LAYER - AI Agents"
        direction TB
        Agents["🤖 Agent Orchestrator Pipeline"]
        
        Agent1["1️⃣ Law Retrieval Agent<br/>- Search ChromaDB<br/>- Fetch Web Content<br/>- Document Ranking"]
        Agent2["2️⃣ Verification Agent<br/>- Credibility Scoring<br/>- Recency Check<br/>- Relevance Filter"]
        Agent3["3️⃣ Explanation Agent<br/>- Content Summarization<br/>- Plain Language<br/>- Key Points Extract"]
        Agent4["4️⃣ Guidance Agent<br/>- Step-by-Step Procedures<br/>- Document Requirements<br/>- Action Guidance"]
        
        Agents --> Agent1
        Agents --> Agent2 --> Agent1
        Agents --> Agent3 --> Agent2
        Agents --> Agent4 --> Agent3
        
        Utils["🛠️ Support Modules"]
        ConvContext["Conversation Context<br/>- Query Building<br/>- Context Management"]
        SemanticDetector["Semantic Detector<br/>- Module Detection<br/>- Intent Classification"]
        DocumentHelper["Document Helper<br/>- Document Management"]
        UserDocHelper["User Documents Helper<br/>- Upload Handling<br/>- File Management"]
        
        Agents -.-> Utils
        Utils -.-> ConvContext
        Utils -.-> SemanticDetector
        Utils -.-> DocumentHelper
        Utils -.-> UserDocHelper
    end

    subgraph "API LAYER - FastAPI Endpoints"
        direction TB
        API["⚡ REST API Endpoints"]
        
        AskAPI["POST /api/ask<br/>- Standard RAG Query"]
        AgentAPI["POST /api/ask/agent<br/>- Agent Pipeline Query"]
        StreamAPI["POST /api/ask/stream<br/>- Streaming Responses"]
        
        DocAPI["Document APIs"]
        UploadAPI["POST /api/documents/upload<br/>- File Upload"]
        OCRExtract["POST /api/challan/extract-text<br/>- OCR Processing"]
        AnalyzeText["POST /api/evidence/analyze-text<br/>- Text Analysis"]
        
        LanguageAPI["Language APIs"]
        GetLang["GET /api/user/{id}/language"]
        SetLang["POST /api/user/{id}/language"]
        
        NotifyAPI["Notification APIs"]
        GetNotify["GET /api/user/{id}/notifications"]
        MarkRead["POST /api/notifications/{id}/mark_read"]
        
        API --> AskAPI
        API --> AgentAPI
        API --> StreamAPI
        API --> DocAPI
        API --> LanguageAPI
        API --> NotifyAPI
    end

    subgraph "DATA LAYER"
        direction TB
        DB["🗄️ Database & Storage"]
        
        Supabase["Supabase PostgreSQL"]
        UserAuth["Users Table<br/>- Credentials<br/>- Profile"]
        ChatHistory["Chat Messages<br/>- Conversation History"]
        Complaints["Complaints Table<br/>- FIA, Traffic,<br/>- Labour, Harassment"]
        Notifications["Notifications<br/>- User Alerts"]
        UserDocs["User Documents<br/>- Uploads"]
        LangPref["Language Preferences"]
        
        VectorDB["ChromaDB - Vector DB"]
        EmbeddingIndex["Embedding Index<br/>- Law Documents<br/>- Case Studies<br/>- Precedents"]
        
        Cache["Response Cache<br/>- Query Cache<br/>- Recent Answers"]
        
        Supabase -.-> UserAuth
        Supabase -.-> ChatHistory
        Supabase -.-> Complaints
        Supabase -.-> Notifications
        Supabase -.-> UserDocs
        Supabase -.-> LangPref
        
        DB --> Supabase
        DB --> VectorDB
        DB --> Cache
    end

    subgraph "EXTERNAL SERVICES & INFRASTRUCTURE"
        direction TB
        External["☁️ Third-Party Services"]
        
        GroqAI["Groq API<br/>- LLM Processing<br/>- AI Inference<br/>- Model: llama2-70b"]
        GoogleAuth["Google Sign-In<br/>- OAuth 2.0<br/>- Account Verification"]
        Tesseract["Tesseract OCR<br/>- Text Extraction<br/>- Document Scanning"]
        
        External --> GroqAI
        External --> GoogleAuth
        External --> Tesseract
    end

    %% CONNECTIONS BETWEEN LAYERS
    UI -->|HTTP Requests| API
    Services -->|State Updates| UI
    AuthService -->|Auth Token| API
    API -->|Orchestrate| Agents
    Agents -->|Query| VectorDB
    Agents -->|Fetch| Supabase
    Agents -->|Check| Cache
    Agents -->|API Calls| GroqAI
    AuthService -->|OAuth| GoogleAuth
    UserDocHelper -->|OCR| Tesseract
    
    style UI fill:#E1F5FF
    style Services fill:#F3E5F5
    style Agents fill:#FFF3E0
    style API fill:#FCE4EC
    style DB fill:#E8F5E9
    style External fill:#FFF9C4
