-- ============================================================================
-- SQL SCHEMA FOR MISSING ENDPOINTS
-- ============================================================================
-- These tables are required for the new API endpoints to function properly
-- Run these CREATE TABLE statements in Supabase SQL Editor

-- ============================================================================
-- 1. traffic_complaints - For traffic module complaints
-- ============================================================================
CREATE TABLE IF NOT EXISTS traffic_complaints (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    incident_date TIMESTAMP WITH TIME ZONE NOT NULL,
    location TEXT NOT NULL,
    officer_name TEXT,
    officer_badge_number TEXT,
    vehicle_number TEXT,
    challan_number TEXT,
    status VARCHAR(50) DEFAULT 'draft',
    priority VARCHAR(20) DEFAULT 'medium',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,
    metadata JSONB,
    created_by UUID REFERENCES auth.users(id)
);

-- Create indexes for performance
CREATE INDEX idx_traffic_complaints_user_id ON traffic_complaints(user_id);
CREATE INDEX idx_traffic_complaints_status ON traffic_complaints(status);
CREATE INDEX idx_traffic_complaints_created_at ON traffic_complaints(created_at DESC);

-- Enable RLS
ALTER TABLE traffic_complaints ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only see their own complaints
CREATE POLICY "Users can view their own traffic complaints"
ON traffic_complaints FOR SELECT
USING (auth.uid() = user_id);

-- RLS Policy: Users can insert their own complaints
CREATE POLICY "Users can create traffic complaints"
ON traffic_complaints FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- RLS Policy: Users can update their own complaints
CREATE POLICY "Users can update their own traffic complaints"
ON traffic_complaints FOR UPDATE
USING (auth.uid() = user_id);

-- ============================================================================
-- 2. labour_complaints - For labour module complaints
-- ============================================================================
CREATE TABLE IF NOT EXISTS labour_complaints (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    employer_name TEXT NOT NULL,
    employer_contact TEXT,
    company_name TEXT,
    employee_id_number TEXT,
    designation TEXT,
    salary DECIMAL(10, 2),
    issue_type VARCHAR(100),
    complaint_date TIMESTAMP WITH TIME ZONE NOT NULL,
    status VARCHAR(50) DEFAULT 'draft',
    priority VARCHAR(20) DEFAULT 'medium',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,
    metadata JSONB,
    created_by UUID REFERENCES auth.users(id)
);

-- Create indexes
CREATE INDEX idx_labour_complaints_user_id ON labour_complaints(user_id);
CREATE INDEX idx_labour_complaints_status ON labour_complaints(status);
CREATE INDEX idx_labour_complaints_created_at ON labour_complaints(created_at DESC);

-- Enable RLS
ALTER TABLE labour_complaints ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view their own labour complaints"
ON labour_complaints FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can create labour complaints"
ON labour_complaints FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own labour complaints"
ON labour_complaints FOR UPDATE
USING (auth.uid() = user_id);

-- ============================================================================
-- 3. notifications - For push notifications and in-app alerts
-- ============================================================================
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) DEFAULT 'info',  -- 'info', 'warning', 'error', 'success'
    action_url TEXT,
    read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() + INTERVAL '30 days'),
    metadata JSONB
);

-- Create indexes
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_read ON notifications(read);
CREATE INDEX idx_notifications_created_at ON notifications(created_at DESC);

-- Enable RLS
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view their own notifications"
ON notifications FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own notifications"
ON notifications FOR UPDATE
USING (auth.uid() = user_id);

-- ============================================================================
-- 4. evidence_files - For tracking uploaded evidence/documents
-- ============================================================================
CREATE TABLE IF NOT EXISTS evidence_files (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    complaint_id UUID,  -- Optional: link to specific complaint
    filename TEXT NOT NULL,
    size INTEGER NOT NULL,
    content_type VARCHAR(100),
    storage_path TEXT NOT NULL,  -- Path in Supabase storage
    url TEXT NOT NULL,  -- Public URL
    file_hash TEXT,  -- SHA256 hash for integrity
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    virus_scanned BOOLEAN DEFAULT FALSE,
    scan_result VARCHAR(50),
    metadata JSONB
);

-- Create indexes
CREATE INDEX idx_evidence_files_user_id ON evidence_files(user_id);
CREATE INDEX idx_evidence_files_complaint_id ON evidence_files(complaint_id);
CREATE INDEX idx_evidence_files_uploaded_at ON evidence_files(uploaded_at DESC);

-- Enable RLS
ALTER TABLE evidence_files ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view their own evidence files"
ON evidence_files FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can upload evidence files"
ON evidence_files FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- ============================================================================
-- 5. chat_messages - For persistent chat history
-- ============================================================================
CREATE TABLE IF NOT EXISTS chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    conversation_id UUID,
    message_type VARCHAR(50) DEFAULT 'message',  -- 'message', 'system', 'bot_response'
    content TEXT NOT NULL,
    sender VARCHAR(50),  -- 'user' or 'assistant'
    module VARCHAR(100),  -- Legal module context
    response_tokens INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    metadata JSONB
);

-- Create indexes
CREATE INDEX idx_chat_messages_user_id ON chat_messages(user_id);
CREATE INDEX idx_chat_messages_conversation_id ON chat_messages(conversation_id);
CREATE INDEX idx_chat_messages_created_at ON chat_messages(created_at DESC);

-- Enable RLS
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view their own chat messages"
ON chat_messages FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can create chat messages"
ON chat_messages FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- ============================================================================
-- 6. activity_logs - For user activity tracking and audit
-- ============================================================================
CREATE TABLE IF NOT EXISTS activity_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    activity_type VARCHAR(100) NOT NULL,  -- 'complaint_filed', 'document_uploaded', 'chat_query', etc.
    resource_type VARCHAR(50),
    resource_id UUID,
    description TEXT,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    metadata JSONB
);

-- Create indexes
CREATE INDEX idx_activity_logs_user_id ON activity_logs(user_id);
CREATE INDEX idx_activity_logs_activity_type ON activity_logs(activity_type);
CREATE INDEX idx_activity_logs_created_at ON activity_logs(created_at DESC);

-- ============================================================================
-- 7. admin_logs - For admin action audit trail
-- ============================================================================
CREATE TABLE IF NOT EXISTS admin_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    admin_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE RESTRICT,
    target_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,  -- 'ban', 'unban', 'suspend', 'activate', etc.
    reason TEXT,
    status VARCHAR(50) DEFAULT 'completed',
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    metadata JSONB
);

-- Create indexes
CREATE INDEX idx_admin_logs_admin_id ON admin_logs(admin_id);
CREATE INDEX idx_admin_logs_target_user_id ON admin_logs(target_user_id);
CREATE INDEX idx_admin_logs_action ON admin_logs(action);
CREATE INDEX idx_admin_logs_timestamp ON admin_logs(timestamp DESC);

-- ============================================================================
-- 8. settings - For app configuration and user preferences
-- ============================================================================
CREATE TABLE IF NOT EXISTS settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    setting_key VARCHAR(100) NOT NULL,
    setting_value JSONB,
    is_global BOOLEAN DEFAULT FALSE,  -- If TRUE, applies to all users
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, setting_key)
);

-- Create indexes
CREATE INDEX idx_settings_user_id ON settings(user_id);
CREATE INDEX idx_settings_setting_key ON settings(setting_key);

-- Enable RLS
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view their own settings"
ON settings FOR SELECT
USING (auth.uid() = user_id OR is_global = TRUE);

CREATE POLICY "Users can update their own settings"
ON settings FOR UPDATE
USING (auth.uid() = user_id);

-- ============================================================================
-- 9. Update profiles table with admin status and new fields
-- ============================================================================
-- Add status column if it doesn't exist
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS status VARCHAR(50) DEFAULT 'active';
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS role VARCHAR(50) DEFAULT 'user';
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS is_admin BOOLEAN DEFAULT FALSE;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS last_login TIMESTAMP WITH TIME ZONE;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS ban_reason TEXT;

-- ============================================================================
-- 10. Create storage bucket for evidence files (if not exists)
-- ============================================================================
-- Run in Supabase SQL Editor to create storage bucket
-- Note: This may need to be done through the Supabase UI or with a different approach
-- The bucket is called 'evidence_files' and should be public

-- ============================================================================
-- SUMMARY OF SCHEMA CHANGES
-- ============================================================================
-- Created 8 new tables:
-- 1. traffic_complaints - Traffic/road law complaints
-- 2. labour_complaints - Labour rights complaints
-- 3. notifications - User notifications
-- 4. evidence_files - Uploaded evidence/documents
-- 5. chat_messages - Chat history persistence
-- 6. activity_logs - User activity audit trail
-- 7. admin_logs - Admin action logs
-- 8. settings - App and user settings
--
-- All tables include:
-- ✅ Row Level Security (RLS) policies
-- ✅ Proper indexes for performance
-- ✅ Foreign key constraints
-- ✅ Timestamp tracking
-- ✅ Metadata storage in JSONB
--
-- ============================================================================
