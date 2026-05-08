"""
Helper module for managing dynamic documents across modules.
Each module can define its own documents (PDFs, text, links).
"""

from typing import List, Dict, Optional, Any
from pydantic import BaseModel
from datetime import datetime


class DocumentLink(BaseModel):
    """Link-type document"""
    title: str
    url: str
    description: Optional[str] = None


class DocumentFile(BaseModel):
    """File-type document (PDF, text, etc.)"""
    title: str
    file_type: str  # "PDF", "Text", "Word", etc.
    size: str  # e.g., "245 KB"
    url: str  # Link to download
    description: Optional[str] = None


class Document(BaseModel):
    """Unified document model"""
    id: str
    title: str
    type: str  # "link", "pdf", "text"
    description: Optional[str] = None
    url: str
    size: Optional[str] = None  # Only for files
    icon: str  # Icon name or emoji
    module: str  # Which module this document belongs to


class DocumentCategory(BaseModel):
    """Category of documents within a module"""
    category_name: str
    description: Optional[str] = None
    documents: List[Document]


class ModuleDocuments(BaseModel):
    """All documents for a specific module"""
    module_id: str
    module_name: str
    categories: List[DocumentCategory]
    total_count: int


class AllDocuments(BaseModel):
    """Response model for all documents across modules"""
    modules: List[ModuleDocuments]
    total_count: int


# ============================================================================
# MODULE DOCUMENTS REGISTRY
# ============================================================================
# Each module can register its own documents here.
# Documents are categorized by module for organized presentation.

_DOCUMENTS_REGISTRY: Dict[str, Dict[str, Any]] = {
    "women_harassment": {
        "module_name": "Women Harassment",
        "categories": {
            "Guidelines & Procedures": [
                {
                    "id": "wh_001",
                    "title": "FIR Draft - Women Harassment",
                    "type": "pdf",
                    "description": "Template for filing a formal complaint under PAHAW 2010",
                    "url": "assets/documents/women_harassment/FIR_Draft_Women_Harassment.pdf",
                    "size": "245 KB",
                    "icon": "📄"
                },
                {
                    "id": "wh_002",
                    "title": "PECA Complaint Template",
                    "type": "pdf",
                    "description": "Template for cybercrime complaints related to harassment",
                    "url": "assets/documents/women_harassment/PECA_Complaint_Template.pdf",
                    "size": "189 KB",
                    "icon": "📄"
                },
                {
                    "id": "wh_003",
                    "title": "Workplace Harassment Policy Guide",
                    "type": "text",
                    "description": "Guidelines on workplace harassment prevention (PAHAW 2010)",
                    "url": "assets/documents/women_harassment/Workplace_Harassment_Guide.txt",
                    "size": "156 KB",
                    "icon": "📋"
                },
            ],
            "Legal Resources": [
                {
                    "id": "wh_004",
                    "title": "Protection Against Harassment of Women at the Workplace Act, 2010",
                    "type": "pdf",
                    "description": "Full text of PAHAW 2010 - The main law protecting women",
                    "url": "assets/documents/women_harassment/PAHAW_2010_Full_Text.pdf",
                    "size": "312 KB",
                    "icon": "⚖️"
                },
                {
                    "id": "wh_005",
                    "title": "Your Rights & Remedies",
                    "type": "text",
                    "description": "Summary of rights and available remedies under law",
                    "url": "assets/documents/women_harassment/Rights_and_Remedies.txt",
                    "size": "124 KB",
                    "icon": "✅"
                },
            ],
            "Contact & Support": [
                {
                    "id": "wh_006",
                    "title": "Harassment Hotlines & Contacts",
                    "type": "link",
                    "description": "Emergency helplines and support contacts",
                    "url": "https://www.punjab.gov.pk/women-protection-cell",
                    "icon": "📞"
                },
                {
                    "id": "wh_007",
                    "title": "Legal Aid Organizations",
                    "type": "link",
                    "description": "Organizations providing free legal assistance",
                    "url": "https://laa.org.pk",
                    "icon": "🤝"
                },
            ]
        }
    },
    "cyber_law": {
        "module_name": "Cyber Law",
        "categories": {
            "Guidelines & Procedures": [
                {
                    "id": "cl_001",
                    "title": "PECA Complaint Filing Guide",
                    "type": "pdf",
                    "description": "Step-by-step guide to file a cybercrime complaint",
                    "url": "assets/documents/cyber_law/PECA_Complaint_Guide.pdf",
                    "size": "267 KB",
                    "icon": "📄"
                },
                {
                    "id": "cl_002",
                    "title": "Evidence Collection Checklist",
                    "type": "text",
                    "description": "What evidence to collect for cyber complaints",
                    "url": "assets/documents/cyber_law/Evidence_Checklist.txt",
                    "size": "98 KB",
                    "icon": "📋"
                },
            ],
            "Legal Resources": [
                {
                    "id": "cl_003",
                    "title": "Prevention of Electronic Crimes Act, 2016",
                    "type": "pdf",
                    "description": "Full text of PECA - Pakistan's cybercrime law",
                    "url": "assets/documents/cyber_law/PECA_2016_Full_Text.pdf",
                    "size": "401 KB",
                    "icon": "⚖️"
                },
                {
                    "id": "cl_004",
                    "title": "Types of Cybercrime & Penalties",
                    "type": "text",
                    "description": "Common cyber offenses and their legal consequences",
                    "url": "assets/documents/cyber_law/Cybercrime_Types_Penalties.txt",
                    "size": "187 KB",
                    "icon": "⚠️"
                },
            ],
            "Contact & Support": [
                {
                    "id": "cl_005",
                    "title": "FIA Cyber Crime Wing",
                    "type": "link",
                    "description": "Official FIA cybercrime reporting portal",
                    "url": "https://www.fia.gov.pk/en/cybercrime",
                    "icon": "🚨"
                },
            ]
        }
    },
    "labour_rights": {
        "module_name": "Labour Rights",
        "categories": {
            "Guidelines & Procedures": [
                {
                    "id": "lr_001",
                    "title": "Wage Dispute Resolution Guide",
                    "type": "pdf",
                    "description": "How to resolve wage disputes with employers",
                    "url": "assets/documents/labour_rights/Wage_Dispute_Guide.pdf",
                    "size": "289 KB",
                    "icon": "📄"
                },
                {
                    "id": "lr_002",
                    "title": "Labour Rights Checklist",
                    "type": "text",
                    "description": "Essential checklist of your basic labour rights",
                    "url": "assets/documents/labour_rights/Labour_Rights_Checklist.txt",
                    "size": "156 KB",
                    "icon": "📋"
                },
            ],
            "Legal Resources": [
                {
                    "id": "lr_003",
                    "title": "Industrial Relations Ordinance 2002",
                    "type": "pdf",
                    "description": "Main labour law governing employer-employee relations",
                    "url": "assets/documents/labour_rights/IRO_2002.pdf",
                    "size": "512 KB",
                    "icon": "⚖️"
                },
                {
                    "id": "lr_004",
                    "title": "Minimum Wage Information",
                    "type": "text",
                    "description": "Current minimum wage rates by province",
                    "url": "assets/documents/labour_rights/Minimum_Wage_Info.txt",
                    "size": "143 KB",
                    "icon": "💰"
                },
            ],
            "Contact & Support": [
                {
                    "id": "lr_005",
                    "title": "Labour Court Information",
                    "type": "link",
                    "description": "Information on filing cases in labour courts",
                    "url": "https://www.punjablabourcourt.gov.pk",
                    "icon": "⚖️"
                },
            ]
        }
    },
    "road_laws": {
        "module_name": "Road Laws & Traffic",
        "categories": {
            "Guidelines & Procedures": [
                {
                    "id": "rl_001",
                    "title": "Challan Appeal Guide",
                    "type": "pdf",
                    "description": "How to appeal a traffic challan/ticket",
                    "url": "assets/documents/road_laws/Challan_Appeal_Guide.pdf",
                    "size": "234 KB",
                    "icon": "📄"
                },
                {
                    "id": "rl_002",
                    "title": "Road Accident Procedures",
                    "type": "text",
                    "description": "What to do immediately after a road accident",
                    "url": "assets/documents/road_laws/Accident_Procedures.txt",
                    "size": "167 KB",
                    "icon": "📋"
                },
            ],
            "Legal Resources": [
                {
                    "id": "rl_003",
                    "title": "Motor Vehicles Ordinance 1979",
                    "type": "pdf",
                    "description": "Complete text of Pakistan's motor vehicle law",
                    "url": "assets/documents/road_laws/Motor_Vehicles_Ordinance.pdf",
                    "size": "623 KB",
                    "icon": "⚖️"
                },
                {
                    "id": "rl_004",
                    "title": "Common Traffic Violations & Fines",
                    "type": "text",
                    "description": "List of traffic offenses and penalty amounts",
                    "url": "assets/documents/road_laws/Traffic_Violations_Fines.txt",
                    "size": "201 KB",
                    "icon": "⚠️"
                },
            ],
            "Contact & Support": [
                {
                    "id": "rl_005",
                    "title": "Traffic Police Helpline",
                    "type": "link",
                    "description": "Contact information for traffic police",
                    "url": "https://www.traffic.punjabpolice.gov.pk",
                    "icon": "🚓"
                },
            ]
        }
    }
}


def get_all_documents() -> AllDocuments:
    """Get all documents across all modules"""
    all_modules = []
    total_docs = 0
    
    for module_id, module_data in _DOCUMENTS_REGISTRY.items():
        categories = []
        module_doc_count = 0
        
        for cat_name, docs in module_data["categories"].items():
            documents = []
            for doc in docs:
                document = Document(
                    id=doc["id"],
                    title=doc["title"],
                    type=doc["type"],
                    description=doc.get("description"),
                    url=doc["url"],
                    size=doc.get("size"),
                    icon=doc.get("icon", "📄"),
                    module=module_id
                )
                documents.append(document)
                module_doc_count += 1
            
            categories.append(DocumentCategory(
                category_name=cat_name,
                documents=documents
            ))
        
        all_modules.append(ModuleDocuments(
            module_id=module_id,
            module_name=module_data["module_name"],
            categories=categories,
            total_count=module_doc_count
        ))
        
        total_docs += module_doc_count
    
    return AllDocuments(
        modules=all_modules,
        total_count=total_docs
    )


def get_documents_by_module(module_id: str) -> Optional[ModuleDocuments]:
    """Get documents for a specific module"""
    if module_id not in _DOCUMENTS_REGISTRY:
        return None
    
    module_data = _DOCUMENTS_REGISTRY[module_id]
    categories = []
    module_doc_count = 0
    
    for cat_name, docs in module_data["categories"].items():
        documents = []
        for doc in docs:
            document = Document(
                id=doc["id"],
                title=doc["title"],
                type=doc["type"],
                description=doc.get("description"),
                url=doc["url"],
                size=doc.get("size"),
                icon=doc.get("icon", "📄"),
                module=module_id
            )
            documents.append(document)
            module_doc_count += 1
        
        categories.append(DocumentCategory(
            category_name=cat_name,
            documents=documents
        ))
    
    return ModuleDocuments(
        module_id=module_id,
        module_name=module_data["module_name"],
        categories=categories,
        total_count=module_doc_count
    )


def add_document_to_module(
    module_id: str,
    category_name: str,
    document: Dict[str, Any]
) -> bool:
    """
    Dynamically add a document to a module's category.
    Used by modules to register their own documents.
    
    Args:
        module_id: The module to add to (e.g., "women_harassment")
        category_name: The category within the module
        document: Document dict with keys: id, title, type, url, size?, description?
    
    Returns:
        True if successful, False if module doesn't exist
    """
    if module_id not in _DOCUMENTS_REGISTRY:
        return False
    
    if category_name not in _DOCUMENTS_REGISTRY[module_id]["categories"]:
        _DOCUMENTS_REGISTRY[module_id]["categories"][category_name] = []
    
    _DOCUMENTS_REGISTRY[module_id]["categories"][category_name].append(document)
    return True


def remove_document(module_id: str, document_id: str) -> bool:
    """Remove a document from a module"""
    if module_id not in _DOCUMENTS_REGISTRY:
        return False
    
    for categories in _DOCUMENTS_REGISTRY[module_id]["categories"].values():
        for i, doc in enumerate(categories):
            if doc["id"] == document_id:
                categories.pop(i)
                return True
    
    return False
