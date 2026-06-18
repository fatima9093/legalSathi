"""Email service using Gmail SMTP to send complaints and notifications"""

import os
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from typing import Optional, List
from datetime import datetime


class EmailService:
    """Send emails using Gmail SMTP"""

    def __init__(self):
        self.sender_email = os.getenv("GMAIL_ADDRESS", "dinomaryam99@gmail.com")
        self.sender_password = os.getenv("GMAIL_PASSWORD", "")
        self.smtp_server = "smtp.gmail.com"
        self.smtp_port = 587
        self.recipient_email = os.getenv("COMPLAINT_RECIPIENT_EMAIL", "dinomaryam99@gmail.com")

    def send_complaint_email(
        self,
        complaint_id: str,
        full_name: str,
        email: str,
        phone: str,
        workplace: str,
        designation: str,
        city: str,
        incident_date: str,
        description: str,
        cnic: str,
        accused_name: Optional[str] = None,
        harassment_types: Optional[List[str]] = None,
        accused_designation: Optional[str] = None,
    ) -> dict:
        """Send complaint email to configured recipient (dinomaryam99@gmail.com)"""
        
        if not self.sender_password:
            return {
                "success": False,
                "message": "Email service not configured - GMAIL_PASSWORD not set"
            }

        try:
            harassment_types_str = ", ".join(harassment_types) if harassment_types else "Not specified"

            email_body = f"""
<html>
<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
    <div style="max-width: 600px; margin: 0 auto; border: 1px solid #ddd; border-radius: 8px; overflow: hidden;">
        <div style="background-color: #00401A; color: white; padding: 20px; text-align: center;">
            <h2 style="margin: 0;">Legal Sathi - Harassment Complaint</h2>
        </div>
        <div style="padding: 20px;">
            <h3 style="color: #00401A; border-bottom: 2px solid #00401A; padding-bottom: 10px;">
                Complaint ID: {complaint_id}
            </h3>
            
            <h4 style="color: #00401A; margin-top: 20px;">Complainant Information</h4>
            <table style="width: 100%; border-collapse: collapse;">
                <tr style="background-color: #f5f5f5;">
                    <td style="padding: 8px; font-weight: bold; width: 30%;">Name:</td>
                    <td style="padding: 8px;">{full_name}</td>
                </tr>
                <tr>
                    <td style="padding: 8px; font-weight: bold;">Email:</td>
                    <td style="padding: 8px;">{email}</td>
                </tr>
                <tr style="background-color: #f5f5f5;">
                    <td style="padding: 8px; font-weight: bold;">Phone:</td>
                    <td style="padding: 8px;">{phone}</td>
                </tr>
                <tr>
                    <td style="padding: 8px; font-weight: bold;">CNIC:</td>
                    <td style="padding: 8px;">{cnic}</td>
                </tr>
                <tr style="background-color: #f5f5f5;">
                    <td style="padding: 8px; font-weight: bold;">Workplace:</td>
                    <td style="padding: 8px;">{workplace}</td>
                </tr>
                <tr>
                    <td style="padding: 8px; font-weight: bold;">Designation:</td>
                    <td style="padding: 8px;">{designation}</td>
                </tr>
                <tr style="background-color: #f5f5f5;">
                    <td style="padding: 8px; font-weight: bold;">City:</td>
                    <td style="padding: 8px;">{city}</td>
                </tr>
            </table>
            
            <h4 style="color: #00401A; margin-top: 20px;">Incident Details</h4>
            <table style="width: 100%; border-collapse: collapse;">
                <tr style="background-color: #f5f5f5;">
                    <td style="padding: 8px; font-weight: bold; width: 30%;">Date of Incident:</td>
                    <td style="padding: 8px;">{incident_date}</td>
                </tr>
                <tr>
                    <td style="padding: 8px; font-weight: bold;">Harassment Type(s):</td>
                    <td style="padding: 8px;">{harassment_types_str}</td>
                </tr>
                <tr style="background-color: #f5f5f5;">
                    <td style="padding: 8px; font-weight: bold;">Accused Name:</td>
                    <td style="padding: 8px;">{accused_name or 'Not specified'}</td>
                </tr>
                <tr>
                    <td style="padding: 8px; font-weight: bold;">Accused Designation:</td>
                    <td style="padding: 8px;">{accused_designation or 'Not specified'}</td>
                </tr>
            </table>
            
            <h4 style="color: #00401A; margin-top: 20px;">Description</h4>
            <div style="background-color: #f9f9f9; padding: 12px; border-left: 4px solid #00401A; border-radius: 4px;">
                {description or 'No description provided'}
            </div>
            
            <div style="margin-top: 20px; padding-top: 20px; border-top: 1px solid #ddd; font-size: 12px; color: #666;">
                <p>Submitted on: {datetime.now().strftime('%d/%m/%Y %H:%M:%S')}</p>
                <p>This is an automated email from Legal Sathi. Please do not reply to this address.</p>
            </div>
        </div>
    </div>
</body>
</html>
"""

            # Send email to configured recipient
            self._send_smtp_email(
                to_address=self.recipient_email,
                subject=f"Legal Sathi: Harassment Complaint Submission - {complaint_id}",
                html_body=email_body
            )

            # Also send confirmation to complainant
            confirmation_body = f"""
<html>
<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
    <div style="max-width: 600px; margin: 0 auto; border: 1px solid #ddd; border-radius: 8px; overflow: hidden;">
        <div style="background-color: #00401A; color: white; padding: 20px; text-align: center;">
            <h2 style="margin: 0;">Complaint Confirmation - Legal Sathi</h2>
        </div>
        <div style="padding: 20px;">
            <p>Dear {full_name},</p>
            
            <p>Your harassment complaint has been successfully registered with Legal Sathi.</p>
            
            <h4 style="color: #00401A;">Complaint Details:</h4>
            <p><strong>Complaint ID:</strong> {complaint_id}</p>
            <p><strong>Submitted on:</strong> {datetime.now().strftime('%d/%m/%Y %H:%M:%S')}</p>
            
            <h4 style="color: #00401A;">Next Steps:</h4>
            <ol>
                <li>Download your complaint PDF from Legal Sathi app</li>
                <li>Submit the complaint to the appropriate authority (Ombudsperson, Workplace Committee, etc.)</li>
                <li>Keep your complaint ID for future reference: <strong>{complaint_id}</strong></li>
            </ol>
            
            <p style="background-color: #f0f0f0; padding: 12px; border-radius: 4px; border-left: 4px solid #00401A;">
                <strong>Support:</strong> If you need assistance, please contact us through the Legal Sathi app.
            </p>
            
            <p style="margin-top: 20px; font-size: 12px; color: #666; border-top: 1px solid #ddd; padding-top: 20px;">
                This is an automated confirmation email. Please do not reply to this address.
            </p>
        </div>
    </div>
</body>
</html>
"""
            
            # Send confirmation to complainant
            self._send_smtp_email(
                to_address=email,
                subject=f"Your Legal Sathi Complaint - Reference ID: {complaint_id}",
                html_body=confirmation_body
            )

            return {
                "success": True,
                "message": f"Complaint email sent successfully to {self.recipient_email} and confirmation sent to {email}",
                "complaint_id": complaint_id
            }
            
        except Exception as e:
            print(f"Error sending complaint email: {str(e)}")
            return {
                "success": False,
                "message": f"Failed to send complaint email: {str(e)}"
            }

    def _send_smtp_email(self, to_address: str, subject: str, html_body: str) -> bool:
        """Send email via Gmail SMTP"""
        try:
            # Create message
            message = MIMEMultipart("alternative")
            message["Subject"] = subject
            message["From"] = self.sender_email
            message["To"] = to_address

            # Create HTML part
            part = MIMEText(html_body, "html")
            message.attach(part)

            # Send email
            with smtplib.SMTP(self.smtp_server, self.smtp_port) as server:
                server.starttls()
                server.login(self.sender_email, self.sender_password)
                server.sendmail(self.sender_email, to_address, message.as_string())

            print(f"Email sent successfully to {to_address}")
            return True
            
        except Exception as e:
            print(f"SMTP error sending to {to_address}: {str(e)}")
            raise


# Singleton instance
_email_service = None


def get_email_service() -> EmailService:
    """Get singleton email service instance"""
    global _email_service
    if _email_service is None:
        _email_service = EmailService()
    return _email_service
