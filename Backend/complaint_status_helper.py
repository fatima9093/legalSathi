"""
Complaint Status Management helper for LegalSathi backend
Place this in Backend/ folder
"""


from supabase_client import supabase

try:
    from notification_helper import NotificationHelper
except Exception:
    NotificationHelper = None

class ComplaintStatusHelper:
    """Helper to manage complaint statuses from backend"""

    # Status constants
    STATUS_SUBMITTED = "submitted"
    STATUS_UNDER_REVIEW = "under_review"
    STATUS_IN_PROGRESS = "in_progress"
    STATUS_RESOLVED = "resolved"

    ALL_STATUSES = [
        STATUS_SUBMITTED,
        STATUS_UNDER_REVIEW,
        STATUS_IN_PROGRESS,
        STATUS_RESOLVED,
    ]

    @staticmethod
    def get_complaint_status(complaint_id: str) -> dict:
        """Get current status of a complaint"""
        try:
            response = supabase.table("complaints").select("status").eq(
                "complaint_id", complaint_id
            ).single().execute()
            return {"success": True, "status": response.data["status"]}
        except Exception as e:
            return {"success": False, "error": str(e)}

    @staticmethod
    def update_complaint_status(
        complaint_id: str,
        new_status: str,
        changed_by: str = None,
        notes: str = None,
    ) -> dict:
        """Update complaint status and add to history"""
        if new_status not in ComplaintStatusHelper.ALL_STATUSES:
            return {
                "success": False,
                "error": f"Invalid status: {new_status}",
            }

        try:
            # Attempt to fetch complaint to identify the owner (user_id)
            user_id = None
            try:
                _resp = (
                    supabase.table("complaints").select("user_id").eq(
                        "complaint_id", complaint_id
                    ).single().execute()
                )
                if _resp and getattr(_resp, 'data', None):
                    user_id = _resp.data.get("user_id")
            except Exception:
                user_id = None

            # Update status
            supabase.table("complaints").update({"status": new_status}).eq(
                "complaint_id", complaint_id
            ).execute()

            # Add to history
            supabase.table("complaint_status_history").insert({
                "complaint_id": complaint_id,
                "status": new_status,
                "changed_by": changed_by,
                "notes": notes,
                "changed_at": str(__import__("datetime").datetime.now(
                    __import__("datetime").timezone.utc
                ).isoformat()),
            }).execute()

            # Create a notification for the user when possible
            try:
                if NotificationHelper and user_id:
                    if new_status == ComplaintStatusHelper.STATUS_SUBMITTED:
                        NotificationHelper.notify_complaint_submitted(user_id, complaint_id)
                    else:
                        # Generic status change notification
                        title = "Complaint Status Updated"
                        message = f"Your complaint status changed to {new_status}."
                        NotificationHelper.create_notification(
                            user_id=user_id,
                            title=title,
                            message=message,
                            action_type="complaint",
                            action_id=complaint_id,
                        )
            except Exception:
                # Don't fail status update if notification creation fails
                pass

            return {"success": True, "status": new_status}
        except Exception as e:
            return {"success": False, "error": str(e)}

    @staticmethod
    def get_status_history(complaint_id: str) -> dict:
        """Get status history for a complaint"""
        try:
            response = (
                supabase.table("complaint_status_history")
                .select("*")
                .eq("complaint_id", complaint_id)
                .order("changed_at", desc=True)
                .execute()
            )
            return {"success": True, "history": response.data}
        except Exception as e:
            return {"success": False, "error": str(e)}

    @staticmethod
    def submit_complaint(complaint_id: str, user_id: str = None) -> dict:
        """Submit a complaint (transition from draft to submitted)"""
        return ComplaintStatusHelper.update_complaint_status(
            complaint_id=complaint_id,
            new_status=ComplaintStatusHelper.STATUS_SUBMITTED,
            changed_by=user_id,
            notes="Complaint submitted",
        )

    @staticmethod
    def start_review(complaint_id: str, reviewer_id: str = None) -> dict:
        """Start review of a complaint"""
        return ComplaintStatusHelper.update_complaint_status(
            complaint_id=complaint_id,
            new_status=ComplaintStatusHelper.STATUS_UNDER_REVIEW,
            changed_by=reviewer_id,
            notes="Under review",
        )

    @staticmethod
    def mark_in_progress(complaint_id: str, handler_id: str = None) -> dict:
        """Mark complaint as in progress"""
        return ComplaintStatusHelper.update_complaint_status(
            complaint_id=complaint_id,
            new_status=ComplaintStatusHelper.STATUS_IN_PROGRESS,
            changed_by=handler_id,
            notes="In progress",
        )

    @staticmethod
    def resolve_complaint(
        complaint_id: str,
        resolution: str = None,
        handler_id: str = None,
    ) -> dict:
        """Resolve a complaint"""
        return ComplaintStatusHelper.update_complaint_status(
            complaint_id=complaint_id,
            new_status=ComplaintStatusHelper.STATUS_RESOLVED,
            changed_by=handler_id,
            notes=resolution,
        )

    @staticmethod
    def get_user_complaints_by_status(
        user_id: str,
        status: str,
    ) -> dict:
        """Get all complaints for a user with specific status"""
        try:
            response = (
                supabase.table("complaints")
                .select("*")
                .eq("user_id", user_id)
                .eq("status", status)
                .order("created_at", desc=True)
                .execute()
            )
            return {
                "success": True,
                "complaints": response.data,
            }
        except Exception as e:
            return {"success": False, "error": str(e)}

    @staticmethod
    def get_status_statistics(user_id: str = None) -> dict:
        """Get count of complaints by status"""
        try:
            stats = {}

            for status in ComplaintStatusHelper.ALL_STATUSES:
                query = supabase.table("complaints").select("complaint_id").eq(
                    "status", status
                )

                if user_id:
                    query = query.eq("user_id", user_id)

                response = query.execute()
                stats[status] = len(response.data)

            return {"success": True, "statistics": stats}
        except Exception as e:
            return {"success": False, "error": str(e)}


# Usage Examples:
if __name__ == "__main__":
    # Submit a complaint
    result = ComplaintStatusHelper.submit_complaint(
        complaint_id="complaint-uuid-here",
        user_id="user-uuid-here",
    )
    print(result)

    # Update to under review
    result = ComplaintStatusHelper.start_review(
        complaint_id="complaint-uuid-here",
        reviewer_id="reviewer-uuid-here",
    )
    print(result)

    # Get status history
    result = ComplaintStatusHelper.get_status_history(
        complaint_id="complaint-uuid-here"
    )
    print(result)

    # Get statistics
    result = ComplaintStatusHelper.get_status_statistics(user_id="user-uuid-here")
    print(result)
