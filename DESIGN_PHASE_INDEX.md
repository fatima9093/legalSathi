# LegalSathi - Design Phase Documentation Index

## 📋 Overview

This document collection provides comprehensive architectural documentation for the **LegalSathi** legal assistance application. These diagrams and documents follow the **Design Phase** methodology and include multiple perspectives of the system architecture.

---

## 📁 Documents in This Collection

### 1. **ARCHITECTURE_DIAGRAM.md** ⭐ START HERE
**Purpose:** Visual representation of the complete system architecture

**Contains:**
- Main system architecture with 6 layers
- Color-coded layer separation
- Component grouping and relationships
- Data flow connections

**Best for:** Quick understanding of overall structure

**Key Diagrams:**
```
PRESENTATION LAYER → APPLICATION LAYER → API LAYER → BUSINESS LOGIC LAYER → DATA LAYER → EXTERNAL SERVICES
```

---

### 2. **DESIGN_PHASE_DOCUMENTATION.md** 📖 COMPREHENSIVE GUIDE
**Purpose:** Detailed textual documentation of architecture, layers, and flows

**Contains:**
- 10 major sections with comprehensive descriptions
- Layer-by-layer breakdown (2.1 - 2.6)
- Three detailed data flow diagrams (user query, document upload, authentication)
- Technology stack table
- Security considerations
- Scalability strategies
- Deployment architecture
- Development workflow
- Future enhancements

**Best for:** Deep understanding, technical decision-making, team onboarding

**Key Sections:**
- Section 2: Layer Descriptions (most detailed)
- Section 3: Data Flow Diagrams (user journeys)
- Section 4: Technology Stack (tech choices)
- Section 5: Security & Section 6: Scalability (production concerns)

---

### 3. **COMPONENT_INTERACTION_DIAGRAM.md** 🔄 DETAILED INTERACTIONS
**Purpose:** Component-level detail and interaction patterns

**Contains:**
- Detailed component dependency graph (Mermaid)
- Sequence diagram for query processing
- Module classification flow
- Architecture Decision Records (ADRs)
- Component dependency matrix
- Performance metrics and SLOs
- Error handling architecture
- Deployment checklist

**Best for:** Implementation details, debugging, performance optimization

**Key Sections:**
- Component Dependency & Interaction Map (visual reference)
- Data Flow: Query Processing (sequence diagram)
- Module Classification Flow (how queries are routed)
- Architecture Decision Records (design rationale)

---

## 🏗️ Architecture Layers Explained

### Layer 1: PRESENTATION LAYER (Flutter)
```
What: User Interface
Where: Mobile (iOS/Android), Web
Components: Screens, Widgets, Navigation
Technologies: Flutter, Material Design 3, Provider

Key Screens:
├── Home Screen - Dashboard & categories
├── Chat Screen - AI conversation
├── Module Screens - Domain-specific interfaces
│   ├── Traffic Module
│   ├── Cyber Law Module  
│   ├── Labour Rights Module
│   └── Women Harassment Module
├── Profile Screen - User settings
├── Notifications Screen - Alerts
└── Settings Screen - App preferences

Responsibility: Render UI, handle user input, display data
```

### Layer 2: APPLICATION LAYER
```
What: Services & State Management
Where: Flutter Frontend
Components: Services, Providers, Models
Technologies: Provider, Supabase Flutter SDK

Key Services:
├── AuthService - User authentication, session management
├── RecentActivityService - Track user actions
├── LocalizationService - Multi-language support
└── CacheService - Local data caching

Responsibility: Bridge UI and backend, manage app state
```

### Layer 3: API LAYER (FastAPI)
```
What: REST API Endpoints
Where: Python Backend (Port 8000)
Technologies: FastAPI, Uvicorn, Pydantic

Key Endpoint Categories:
├── Query APIs - /api/ask, /api/ask/agent, /api/ask/stream
├── Document APIs - /api/documents/upload, /api/challan/extract-text
├── User APIs - /api/user/{id}/language, profile
├── Notification APIs - /api/notifications
└── Document Metadata APIs - /api/documents, /api/documents/{module_id}

Responsibility: Accept requests, validate, route to business logic
```

### Layer 4: BUSINESS LOGIC LAYER (AI Agents)
```
What: Intelligent Analysis Pipeline
Where: Python Backend
Technologies: Groq API, OpenAI Agents SDK, LLMs

Four-Agent Pipeline:
1. Law Retrieval Agent
   └─→ Search ChromaDB + web sources
   
2. Verification Agent (filters & scores)
   └─→ Credibility, recency, relevance assessment
   
3. Explanation Agent (summarizes)
   └─→ Plain language, key points extraction
   
4. Guidance Agent (actionable steps)
   └─→ Step-by-step procedures, required documents

Support Modules:
├── Conversation Context Manager
├── Semantic Module Detector
├── Document Helper
└── User Documents Helper

Responsibility: Intelligent analysis, reasoning, response generation
```

### Layer 5: DATA LAYER
```
What: Persistent Storage
Where: Cloud Services

Components:
├── Supabase PostgreSQL
│   ├── Users table - Authentication & profiles
│   ├── Chat messages - Conversation history
│   ├── Complaints - User-filed complaints
│   ├── Notifications - System alerts
│   ├── User documents - Uploaded evidence
│   ├── Language preferences - User settings
│   └── Response cache - Query results
│
├── ChromaDB (Vector Database)
│   ├── Legal documents collection
│   ├── Case studies collection
│   └── Procedures collection
│
└── Response Cache (In-memory/Redis)
    ├── Query results
    └── Session data

Responsibility: Data persistence, vector search, caching
```

### Layer 6: EXTERNAL SERVICES
```
What: Third-Party Integrations
Where: Cloud Services

Services:
├── Groq API
│   └─ LLM Inference (llama2-70b model)
│
├── Google OAuth 2.0
│   └─ User authentication & identity verification
│
└── Tesseract OCR
    └─ Text extraction from images (challans, documents)

Responsibility: Specialized services beyond app control
```

---

## 🔄 Key Data Flows

### Flow 1: User Query Processing
```
User types question
        ↓
Frontend validates & authenticates user
        ↓
POST /api/ask/agent with query
        ↓
API receives & validates request
        ↓
Orchestrator checks response cache
        ├─ CACHE HIT → Return immediately
        └─ CACHE MISS → Continue
        ↓
Law Retrieval Agent searches ChromaDB
        ↓
Verification Agent scores & filters results
        ↓
Explanation Agent summarizes content
        ↓
Guidance Agent generates step-by-step procedures
        ↓
Orchestrator compiles final response
        ↓
Store in cache for future queries
        ↓
Return OrchestratorResponse to frontend
        ↓
Frontend displays formatted answer to user
```

### Flow 2: User Document Upload
```
User selects file from device
        ↓
Frontend validates file (size, type)
        ↓
POST /api/documents/upload with FormData
        ↓
Backend stores file in Supabase Storage
        ↓
If image → Extract text with Tesseract OCR
        ↓
Store metadata in Supabase database
        ↓
Return file_id and url to frontend
        ↓
Frontend displays uploaded document
        ↓
Document available for evidence in complaints
```

### Flow 3: User Authentication
```
User opens app
        ↓
Check Supabase session
        ├─ Session exists → Show home screen
        └─ No session → Show login
        ↓
User clicks "Sign in with Google"
        ↓
Google OAuth flow (browser/webview)
        ↓
User signs in & grants consent
        ↓
Google returns auth token
        ↓
Supabase verifies token & creates session
        ↓
Create user profile in database
        ↓
Frontend receives user data
        ↓
Navigation to home screen
        ↓
Periodic token refresh to maintain session
```

---

## 🛠️ Technology Stack at a Glance

| **Layer** | **Component** | **Technology** | **Version** |
|-----------|---------------|----------------|------------|
| **Presentation** | Frontend Framework | Flutter | 3.x |
| | UI Framework | Material Design | 3 |
| | State Management | Provider | Latest |
| | Localization | intl package | Latest |
| **Application** | Authentication | Supabase Flutter | Latest |
| | HTTP Client | dio/http | Latest |
| | Local Cache | shared_preferences/hive | Latest |
| **API** | Backend Framework | FastAPI | 0.100+ |
| | ASGI Server | Uvicorn | Latest |
| | Validation | Pydantic | v2+ |
| **Business Logic** | LLM Provider | Groq API | llama2-70b |
| | Agent Framework | OpenAI Agents SDK | Latest |
| | Async Runtime | asyncio | Built-in |
| **Data** | Primary Database | Supabase (PostgreSQL) | 14+ |
| | Vector Database | ChromaDB | Latest |
| | Embeddings | Sentence Transformers | Latest |
| | File Storage | Supabase Storage | - |
| **External** | OCR Engine | Tesseract | 5+ |
| | Identity Provider | Google OAuth 2.0 | - |
| | LLM API | Groq | - |

---

## 📊 Document Structure Matrix

| Document | Audience | Depth | Format | Best For |
|----------|----------|-------|--------|----------|
| ARCHITECTURE_DIAGRAM.md | Everyone | Overview | Visual Diagrams | Quick understanding |
| DESIGN_PHASE_DOCUMENTATION.md | Developers, Architects | Deep | Detailed Text + Diagrams | Decision-making, onboarding |
| COMPONENT_INTERACTION_DIAGRAM.md | Developers, QA | Detailed | Visual + Text | Implementation, testing |

---

## 🎯 Use Cases for Each Document

### **When to use ARCHITECTURE_DIAGRAM.md:**
- First introduction to the system
- Quick system overview in a meeting
- Understanding layer separation
- Explaining project to stakeholders

### **When to use DESIGN_PHASE_DOCUMENTATION.md:**
- Detailed system design review
- Technical decision-making
- New developer onboarding
- API documentation reference
- Security & scalability planning

### **When to use COMPONENT_INTERACTION_DIAGRAM.md:**
- Deep diving into specific components
- Understanding detailed data flows
- Decision Records (why we chose X over Y)
- Performance optimization
- Deployment planning

---

## 🔍 Key Architectural Patterns

### 1. **Layered Architecture**
Clear separation between Presentation, Application, API, Business Logic, and Data layers

### 2. **Multi-Agent Pipeline**
Sequential AI agents, each specializing in one task (Retrieval → Verification → Explanation → Guidance)

### 3. **Service-Oriented**
Services encapsulate specific concerns (Auth, Activity, Localization, Cache)

### 4. **Provider Pattern (Flutter)**
State management using the Provider package for reactive UI updates

### 5. **Vector-Semantic Search**
ChromaDB for semantic similarity of legal documents

### 6. **Caching Strategy**
Multi-level caching: local cache, response cache, session cache for performance

### 7. **Async-First Backend**
Python async/await throughout for scalability

### 8. **REST API Design**
Standard HTTP methods, proper status codes, JSON responses

---

## 🚀 Quick Navigation Guide

**For System Overview:**
1. Read ARCHITECTURE_DIAGRAM.md (5 min)
2. Skim DESIGN_PHASE_DOCUMENTATION.md sections 1-2 (10 min)

**For Implementation:**
1. Review COMPONENT_INTERACTION_DIAGRAM.md (15 min)
2. Read relevant API endpoints in DESIGN_PHASE_DOCUMENTATION.md section 2.3 (10 min)
3. Study data flows in DESIGN_PHASE_DOCUMENTATION.md section 3 (15 min)

**For Deployment:**
1. Review deployment architecture in DESIGN_PHASE_DOCUMENTATION.md section 7
2. Check deployment checklist in COMPONENT_INTERACTION_DIAGRAM.md

**For Performance Optimization:**
1. Review SLOs in COMPONENT_INTERACTION_DIAGRAM.md
2. Read scalability section in DESIGN_PHASE_DOCUMENTATION.md section 6

**For Security Review:**
1. Read security section in DESIGN_PHASE_DOCUMENTATION.md section 5
2. Review error handling in COMPONENT_INTERACTION_DIAGRAM.md

---

## 📝 Design Decisions Documented

The COMPONENT_INTERACTION_DIAGRAM.md includes Architecture Decision Records (ADRs) for:

1. **ADR-1:** Four-Agent Pipeline Architecture
2. **ADR-2:** Separate Vector DB (ChromaDB)  
3. **ADR-3:** Groq API for LLM
4. **ADR-4:** Flutter for Cross-Platform
5. **ADR-5:** Supabase for Auth & Realtime

Each ADR includes Context, Decision, Rationale, and Consequences.

---

## 🔐 Security Architecture

All documents address security in different ways:

| Document | Security Focus |
|----------|-----------------|
| ARCHITECTURE_DIAGRAM.md | HTTPS connections, layer isolation |
| DESIGN_PHASE_DOCUMENTATION.md | Authentication, authorization, data protection, API security |
| COMPONENT_INTERACTION_DIAGRAM.md | Error handling, gradual degradation |

---

## 📈 Scalability Considerations

**Horizontal Scaling:**
- Multiple FastAPI instances behind load balancer
- Async request handling

**Vertical Scaling:**
- Larger database instances
- Increased ChromaDB memory

**Caching Layer:**
- Response cache for frequent queries
- Local client-side caching

**Database Optimization:**
- Indexed queries
- Proper foreign keys
- Vector index optimization

---

## 🧪 Testing Considerations

Based on the architecture, test coverage should include:

| Layer | Test Type | Examples |
|-------|-----------|----------|
| Presentation | Widget Tests, Integration Tests | UI rendering, user interactions |
| Application | Unit Tests | Service logic, state management |
| API | API Tests, Contract Tests | Endpoint behavior, error responses |
| Business Logic | Unit Tests, Integration Tests | Agent behavior, pipeline orchestration |
| Data | Integration Tests | Database queries, vector search |

---

## 📞 Support & Questions

For questions about specific aspects:

- **System Overview?** → See ARCHITECTURE_DIAGRAM.md
- **How does X work?** → Search DESIGN_PHASE_DOCUMENTATION.md
- **Component relationships?** → See COMPONENT_INTERACTION_DIAGRAM.md
- **Why was Y chosen?** → Check ADRs in COMPONENT_INTERACTION_DIAGRAM.md

---

## 📅 Document Versioning

- **Version:** 1.0
- **Date:** [Current Date]
- **Status:** Active
- **Last Updated:** [Current Date]

**Future Updates Should Track:**
- New endpoints added
- Architecture changes
- Technology upgrades
- Performance improvements
- Security enhancements

---

## ✅ Validation Checklist

Before using this documentation:

- [ ] All three documents are present in workspace
- [ ] Mermaid diagrams render correctly
- [ ] Table formatting displays properly
- [ ] Cross-references between documents are valid
- [ ] Code samples are syntactically correct
- [ ] Technology versions are current

---

## 🎓 Learning Path Recommendations

### **Beginner (New to project):**
1. ARCHITECTURE_DIAGRAM.md - Layer overview
2. DESIGN_PHASE_DOCUMENTATION.md - Sections 1-2
3. COMPONENT_INTERACTION_DIAGRAM.md - Main diagram only

### **Intermediate (Implementing features):**
1. DESIGN_PHASE_DOCUMENTATION.md - Full read
2. COMPONENT_INTERACTION_DIAGRAM.md - Sequence diagrams
3. ARCHITECTURE_DIAGRAM.md - Reference for integration points

### **Advanced (System design, optimization):**
1. All documents - thorough review
2. Focus on ADRs and design patterns
3. Review performance metrics & deployment architecture

---

## 🔗 Related Documents

Additional project documentation may include:
- API Documentation (OpenAPI/Swagger)
- Database Schema Documentation
- Deployment Guide
- Security Policy
- Contributing Guidelines
- Code of Conduct

---

**Total Documentation Scope:**
- **3 Core Architecture Documents**
- **10+ Detailed Sections**
- **15+ Mermaid Diagrams**
- **Multiple Data Flow Sequences**
- **Deployment & Testing Guidance**

This comprehensive documentation provides a 360-degree view of the LegalSathi architecture for development, deployment, and maintenance.

