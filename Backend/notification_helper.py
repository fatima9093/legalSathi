"""
Backend notification creation helper for LegalSathi
Place this in Backend/ folder alongside other services
"""

from supabase_client import supabase


class NotificationHelper:
    """Helper to create notifications from backend"""

    @staticmethod
    def create_notification(
        user_id: str,
        title: str,
        message: str,
        action_type: str = None,
        action_id: str = None,
    ) -> dict:
        """
        Create a notification for a user
        
        Args:
            user_id: UUID of the user
            title: Notification title
            message: Notification message
            action_type: Type of action (e.g., 'complaint', 'document', 'message')
            action_id: ID of the related entity
        
        Returns:
            Response from Supabase or error dict
        """
        try:
            data = {
                "user_id": user_id,
                "title": title,
                "message": message,
                "action_type": action_type,
                "action_id": action_id,
                "is_read": False,
            }
            
            response = supabase.table("notifications").insert(data).execute()
            return {"success": True, "data": response.data}
        except Exception as e:
            return {"success": False, "error": str(e)}

    @staticmethod
    def notify_complaint_submitted(user_id: str, complaint_id: str) -> dict:
        """Notify user when complaint is submitted"""
        return NotificationHelper.create_notification(
            user_id=user_id,
            title="Complaint Submitted",
            message="Your complaint has been successfully submitted for review.",
            action_type="complaint",
            action_id=complaint_id,
        )

    @staticmethod
    def notify_document_ready(
        user_id: str, 
        document_id: str, 
        document_type: str
    ) -> dict:
        """Notify user when document is ready"""
        return NotificationHelper.create_notification(
            user_id=user_id,
            title="Document Ready",
            message=f"Your {document_type} has been generated and is ready.",
            action_type="document",
            action_id=document_id,
        )

    @staticmethod
    def notify_evidence_processed(user_id: str, complaint_id: str) -> dict:
        """Notify user when evidence is processed"""
        return NotificationHelper.create_notification(
            user_id=user_id,
            title="Evidence Processed",
            message="Your evidence has been analyzed and processed.",
            action_type="complaint",
            action_id=complaint_id,
        )

    @staticmethod
    def notify_message_received(user_id: str, sender_name: str) -> dict:
        """Notify user of new message"""
        return NotificationHelper.create_notification(
            user_id=user_id,
            title="New Message",
            message=f"You have a new message from {sender_name}.",
            action_type="message",
        )

    @staticmethod
    def get_user_notifications(user_id: str, unread_only: bool = False) -> dict:
        """Fetch notifications for a user"""
        try:
            query = supabase.table("notifications").select("*").eq("user_id", user_id)
            
            if unread_only:
                query = query.eq("is_read", False)
            
            response = query.order("created_at", desc=True).execute()
            return {"success": True, "data": response.data}
        except Exception as e:
            return {"success": False, "error": str(e)}

    @staticmethod
    def mark_notification_read(notification_id: str) -> dict:
        """Mark notification as read"""
        try:
            response = (
                supabase.table("notifications")
                .update({"is_read": True})
                .eq("id", notification_id)
                .execute()
            )
            return {"success": True, "data": response.data}
        except Exception as e:
            return {"success": False, "error": str(e)}

    @staticmethod
    def mark_all_read_for_user(user_id: str) -> dict:
        """Mark all notifications as read for a given user"""
        try:
            response = (
                supabase.table("notifications")
                .update({"is_read": True})
                .eq("user_id", user_id)
                .eq("is_read", False)
                .execute()
            )
            return {"success": True, "data": response.data}
        except Exception as e:
            return {"success": False, "error": str(e)}


# Usage Examples:
if __name__ == "__main__":
    # Create notification when complaint is submitted
    result = NotificationHelper.notify_complaint_submitted(
        user_id="user-uuid-here",
        complaint_id="complaint-uuid-here",
    )
    print(result)

    # Get user's notifications
    result = NotificationHelper.get_user_notifications(
        user_id="user-uuid-here",
        unread_only=True,
    )
    print(result)
