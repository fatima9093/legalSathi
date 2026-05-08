"""
feedback_collection.py
======================
User feedback collection for continuous improvement.

ENHANCEMENT 8A & 8B: Feedback System
- Track helpful/unhelpful responses
- Collect user ratings and comments
- Enable feedback endpoint in FastAPI
- Store in Supabase for analysis
"""
from __future__ import annotations

import logging
from datetime import datetime
from typing import Any, Dict, List, Optional

from pydantic import BaseModel, Field

logger = logging.getLogger(__name__)


class FeedbackRating(BaseModel):
    """Individual feedback section rating."""
    
    section: str = Field(..., description="Section name (e.g., 'explanation', 'steps', 'resources')")
    helpful: bool = Field(..., description="Whether section was helpful")
    clarity: int = Field(
        default=3,
        ge=1, le=5,
        description="Clarity rating 1-5 (1=unclear, 5=very clear)"
    )
    relevance: int = Field(
        default=3,
        ge=1, le=5,
        description="Relevance rating 1-5 (1=not relevant, 5=very relevant)"
    )


class QueryFeedback(BaseModel):
    """Complete feedback for a query response."""
    
    query_id: str = Field(..., description="Unique query identifier")
    query: str = Field(..., description="Original user query")
    module: Optional[str] = Field(default=None, description="Legal module")
    
    # Overall feedback
    overall_helpful: bool = Field(..., description="Was the response helpful overall?")
    overall_rating: int = Field(
        default=3,
        ge=1, le=5,
        description="Overall satisfaction 1-5"
    )
    
    # Section feedback
    section_ratings: List[FeedbackRating] = Field(
        default_factory=list,
        description="Ratings for specific sections"
    )
    
    # User comment
    user_comment: Optional[str] = Field(default=None, description="Optional user comment")
    
    # Metadata
    user_id: Optional[str] = Field(default=None, description="User identifier")
    language: str = Field(default="English", description="Response language")
    timestamp: datetime = Field(default_factory=datetime.utcnow, description="Feedback timestamp")
    
    # Diagnostic info
    response_time_seconds: Optional[float] = Field(default=None, description="API response time")
    has_official_links: bool = Field(default=False, description="Response included official links")
    guidance_steps_count: Optional[int] = Field(default=None, description="Number of guidance steps")


class FeedbackSummary(BaseModel):
    """Summary statistics for feedback."""
    
    total_feedback: int = Field(default=0)
    helpful_count: int = Field(default=0)
    unhelpful_count: int = Field(default=0)
    helpful_percent: float = Field(default=0.0)
    
    avg_overall_rating: float = Field(default=0.0)
    avg_clarity: float = Field(default=0.0)
    avg_relevance: float = Field(default=0.0)
    
    most_helpful_sections: Dict[str, int] = Field(default_factory=dict)
    least_helpful_sections: Dict[str, int] = Field(default_factory=dict)
    
    common_issues: List[str] = Field(default_factory=list)


class FeedbackCollector:
    """
    Manages user feedback collection and analysis.
    """
    
    def __init__(self):
        self.feedback_buffer: List[QueryFeedback] = []
        self.max_buffer_size = 100
    
    def record_feedback(self, feedback: QueryFeedback) -> bool:
        """
        Record user feedback for a response.
        
        ENHANCEMENT 8A: Feedback Recording
        
        Args:
            feedback: QueryFeedback object
        
        Returns:
            True if recorded successfully
        """
        try:
            self.feedback_buffer.append(feedback)
            
            # Log feedback
            helpful_str = "helpful" if feedback.overall_helpful else "unhelpful"
            logger.info(
                f"[Feedback] Recorded: query_id={feedback.query_id} | "
                f"module={feedback.module} | {helpful_str} | "
                f"rating={feedback.overall_rating}/5 | "
                f"sections={len(feedback.section_ratings)}"
            )
            
            # Auto-flush if buffer full
            if len(self.feedback_buffer) >= self.max_buffer_size:
                logger.info(f"[Feedback] Buffer full ({self.max_buffer_size}), should flush to database")
            
            return True
        
        except Exception as exc:
            logger.error(f"Failed to record feedback: {exc}")
            return False
    
    def create_feedback(
        self,
        query_id: str,
        query: str,
        overall_helpful: bool,
        overall_rating: int = 3,
        module: Optional[str] = None,
        user_comment: Optional[str] = None,
        user_id: Optional[str] = None,
        language: str = "English",
        response_time_seconds: Optional[float] = None,
        has_official_links: bool = False,
        guidance_steps_count: Optional[int] = None,
    ) -> QueryFeedback:
        """
        Convenience function to create and record feedback.
        
        Args:
            query_id: Unique query identifier
            query: Original query text
            overall_helpful: Whether response was helpful
            overall_rating: 1-5 rating
            module: Legal module if known
            user_comment: Optional comment
            user_id: User identifier
            language: Response language
            response_time_seconds: API response time
            has_official_links: Whether response had official links
            guidance_steps_count: Number of guidance steps in response
        
        Returns:
            QueryFeedback object
        """
        feedback = QueryFeedback(
            query_id=query_id,
            query=query,
            overall_helpful=overall_helpful,
            overall_rating=overall_rating,
            module=module,
            user_comment=user_comment,
            user_id=user_id,
            language=language,
            response_time_seconds=response_time_seconds,
            has_official_links=has_official_links,
            guidance_steps_count=guidance_steps_count,
        )
        
        self.record_feedback(feedback)
        return feedback
    
    def add_section_rating(
        self,
        query_id: str,
        section: str,
        helpful: bool,
        clarity: int = 3,
        relevance: int = 3
    ):
        """
        Add rating for a specific response section.
        
        Args:
            query_id: Query identifier to update
            section: Section name (e.g., 'explanation', 'steps')
            helpful: Was section helpful?
            clarity: 1-5 clarity rating
            relevance: 1-5 relevance rating
        """
        # Find matching feedback entry
        for fb in reversed(self.feedback_buffer):
            if fb.query_id == query_id:
                rating = FeedbackRating(
                    section=section,
                    helpful=helpful,
                    clarity=clarity,
                    relevance=relevance
                )
                fb.section_ratings.append(rating)
                logger.debug(f"[Feedback] Added section rating: {section} for query {query_id}")
                return
        
        logger.warning(f"[Feedback] Query {query_id} not found in buffer for section rating")
    
    def get_summary(self) -> FeedbackSummary:
        """
        Generate summary statistics from collected feedback.
        
        ENHANCEMENT 8B: Analysis
        """
        if not self.feedback_buffer:
            return FeedbackSummary()
        
        helpful_count = sum(1 for fb in self.feedback_buffer if fb.overall_helpful)
        total = len(self.feedback_buffer)
        
        # Average ratings
        ratings = [fb.overall_rating for fb in self.feedback_buffer]
        clarity_ratings = []
        relevance_ratings = []
        
        section_helpful = {}
        section_unhelpful = {}
        
        for fb in self.feedback_buffer:
            for sr in fb.section_ratings:
                key = sr.section
                if sr.helpful:
                    section_helpful[key] = section_helpful.get(key, 0) + 1
                else:
                    section_unhelpful[key] = section_unhelpful.get(key, 0) + 1
                
                clarity_ratings.append(sr.clarity)
                relevance_ratings.append(sr.relevance)
        
        # Extract common issues from comments
        common_issues = []
        issue_keywords = ["unclear", "confusing", "difficult", "missing", "irrelevant", "wrong"]
        for fb in self.feedback_buffer:
            if fb.user_comment and not fb.overall_helpful:
                for keyword in issue_keywords:
                    if keyword.lower() in fb.user_comment.lower():
                        common_issues.append(keyword)
        
        return FeedbackSummary(
            total_feedback=total,
            helpful_count=helpful_count,
            unhelpful_count=total - helpful_count,
            helpful_percent=round(helpful_count / total * 100, 1) if total > 0 else 0,
            avg_overall_rating=round(sum(ratings) / len(ratings), 2) if ratings else 0,
            avg_clarity=round(sum(clarity_ratings) / len(clarity_ratings), 2) if clarity_ratings else 0,
            avg_relevance=round(sum(relevance_ratings) / len(relevance_ratings), 2) if relevance_ratings else 0,
            most_helpful_sections=dict(sorted(section_helpful.items(), key=lambda x: -x[1])[:5]),
            least_helpful_sections=dict(sorted(section_unhelpful.items(), key=lambda x: -x[1])[:5]),
            common_issues=list(set(common_issues)),
        )
    
    def get_feedback_for_module(self, module: str) -> List[QueryFeedback]:
        """Get all feedback for a specific module."""
        return [fb for fb in self.feedback_buffer if fb.module == module]
    
    def clear_buffer(self) -> int:
        """Clear feedback buffer and return count of cleared items."""
        count = len(self.feedback_buffer)
        self.feedback_buffer.clear()
        logger.info(f"[Feedback] Cleared {count} feedback entries from buffer")
        return count


# Global feedback collector
_feedback_collector = FeedbackCollector()


def get_feedback_collector() -> FeedbackCollector:
    """Get the global feedback collector instance."""
    return _feedback_collector


__all__ = [
    "FeedbackRating",
    "QueryFeedback",
    "FeedbackSummary",
    "FeedbackCollector",
    "get_feedback_collector",
]
