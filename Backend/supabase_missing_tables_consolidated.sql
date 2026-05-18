-- Consolidated idempotent migration for missing Supabase tables
-- Run this in Supabase SQL Editor. Uses IF NOT EXISTS / IF NOT EXISTS patterns
-- to be safe to re-run against an existing project.

-- 1) traffic_complaints
CREATE TABLE IF NOT EXISTS public.traffic_complaints (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  description text not null,
  incident_date timestamptz not null,
  location text not null,
  officer_name text,
  officer_badge_number text,
  vehicle_number text,
  challan_number text,
  status varchar(50) default 'draft',
  priority varchar(20) default 'medium',
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  deleted_at timestamptz,
  metadata jsonb,
  created_by uuid references auth.users(id)
);

CREATE INDEX IF NOT EXISTS idx_traffic_complaints_user_id ON public.traffic_complaints(user_id);
CREATE INDEX IF NOT EXISTS idx_traffic_complaints_status ON public.traffic_complaints(status);
CREATE INDEX IF NOT EXISTS idx_traffic_complaints_created_at ON public.traffic_complaints(created_at desc);

ALTER TABLE public.traffic_complaints ENABLE ROW LEVEL SECURITY;
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='traffic_complaints' AND policyname='traffic_complaints_select_own') THEN
    CREATE POLICY traffic_complaints_select_own ON public.traffic_complaints FOR SELECT USING (auth.uid() = user_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='traffic_complaints' AND policyname='traffic_complaints_insert_own') THEN
    CREATE POLICY traffic_complaints_insert_own ON public.traffic_complaints FOR INSERT WITH CHECK (auth.uid() = user_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='traffic_complaints' AND policyname='traffic_complaints_update_own') THEN
    CREATE POLICY traffic_complaints_update_own ON public.traffic_complaints FOR UPDATE USING (auth.uid() = user_id);
  END IF;
END$$;

-- 2) labour_complaints
CREATE TABLE IF NOT EXISTS public.labour_complaints (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  description text not null,
  employer_name text not null,
  employer_contact text,
  company_name text,
  employee_id_number text,
  designation text,
  salary numeric(10,2),
  issue_type varchar(100),
  complaint_date timestamptz not null,
  status varchar(50) default 'draft',
  priority varchar(20) default 'medium',
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  deleted_at timestamptz,
  metadata jsonb,
  created_by uuid references auth.users(id)
);

CREATE INDEX IF NOT EXISTS idx_labour_complaints_user_id ON public.labour_complaints(user_id);
CREATE INDEX IF NOT EXISTS idx_labour_complaints_status ON public.labour_complaints(status);
CREATE INDEX IF NOT EXISTS idx_labour_complaints_created_at ON public.labour_complaints(created_at desc);

ALTER TABLE public.labour_complaints ENABLE ROW LEVEL SECURITY;
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='labour_complaints' AND policyname='labour_complaints_select_own') THEN
    CREATE POLICY labour_complaints_select_own ON public.labour_complaints FOR SELECT USING (auth.uid() = user_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='labour_complaints' AND policyname='labour_complaints_insert_own') THEN
    CREATE POLICY labour_complaints_insert_own ON public.labour_complaints FOR INSERT WITH CHECK (auth.uid() = user_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='labour_complaints' AND policyname='labour_complaints_update_own') THEN
    CREATE POLICY labour_complaints_update_own ON public.labour_complaints FOR UPDATE USING (auth.uid() = user_id);
  END IF;
END$$;

-- 3) notifications (if missing, safe to create)
CREATE TABLE IF NOT EXISTS public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  message text not null,
  type varchar(50) default 'info',
  action_url text,
  is_read boolean default false,
  read_at timestamptz,
  created_at timestamptz default now(),
  expires_at timestamptz default (now() + interval '30 days'),
  metadata jsonb
);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON public.notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON public.notifications(created_at desc);
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='notifications' AND policyname='notifications_select_own') THEN
    CREATE POLICY notifications_select_own ON public.notifications FOR SELECT USING (auth.uid() = user_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='notifications' AND policyname='notifications_update_own') THEN
    CREATE POLICY notifications_update_own ON public.notifications FOR UPDATE USING (auth.uid() = user_id);
  END IF;
END$$;

-- 4) evidence_files
CREATE TABLE IF NOT EXISTS public.evidence_files (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  complaint_id uuid,
  filename text not null,
  size integer not null,
  content_type varchar(100),
  storage_path text not null,
  url text not null,
  file_hash text,
  uploaded_at timestamptz default now(),
  virus_scanned boolean default false,
  scan_result varchar(50),
  metadata jsonb
);
CREATE INDEX IF NOT EXISTS idx_evidence_files_user_id ON public.evidence_files(user_id);
CREATE INDEX IF NOT EXISTS idx_evidence_files_complaint_id ON public.evidence_files(complaint_id);
CREATE INDEX IF NOT EXISTS idx_evidence_files_uploaded_at ON public.evidence_files(uploaded_at desc);
ALTER TABLE public.evidence_files ENABLE ROW LEVEL SECURITY;
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='evidence_files' AND policyname='evidence_files_select_own') THEN
    CREATE POLICY evidence_files_select_own ON public.evidence_files FOR SELECT USING (auth.uid() = user_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='evidence_files' AND policyname='evidence_files_insert_own') THEN
    CREATE POLICY evidence_files_insert_own ON public.evidence_files FOR INSERT WITH CHECK (auth.uid() = user_id);
  END IF;
END$$;

-- 5) chat_messages (safe, but the repo already has a schema; include minimal)
CREATE TABLE IF NOT EXISTS public.chat_messages (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  conversation_id uuid,
  message_type varchar(50) default 'message',
  content text not null,
  sender varchar(50),
  module varchar(100),
  response_tokens integer,
  created_at timestamptz default now(),
  metadata jsonb
);
CREATE INDEX IF NOT EXISTS idx_chat_messages_user_id ON public.chat_messages(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_conversation_id ON public.chat_messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_created_at ON public.chat_messages(created_at desc);
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='chat_messages' AND policyname='chat_messages_select_own') THEN
    CREATE POLICY chat_messages_select_own ON public.chat_messages FOR SELECT USING (auth.uid() = user_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='chat_messages' AND policyname='chat_messages_insert_own') THEN
    CREATE POLICY chat_messages_insert_own ON public.chat_messages FOR INSERT WITH CHECK (auth.uid() = user_id);
  END IF;
END$$;

-- 6) admin_logs
CREATE TABLE IF NOT EXISTS public.admin_logs (
  id uuid primary key default gen_random_uuid(),
  admin_id uuid not null references auth.users(id) on delete restrict,
  target_user_id uuid references auth.users(id) on delete set null,
  action varchar(100) not null,
  reason text,
  status varchar(50) default 'completed',
  timestamp timestamptz default now(),
  metadata jsonb
);
CREATE INDEX IF NOT EXISTS idx_admin_logs_admin_id ON public.admin_logs(admin_id);
CREATE INDEX IF NOT EXISTS idx_admin_logs_target_user_id ON public.admin_logs(target_user_id);
CREATE INDEX IF NOT EXISTS idx_admin_logs_action ON public.admin_logs(action);
CREATE INDEX IF NOT EXISTS idx_admin_logs_timestamp ON public.admin_logs(timestamp desc);

-- 7) settings
CREATE TABLE IF NOT EXISTS public.settings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  setting_key varchar(100) not null,
  setting_value jsonb,
  is_global boolean default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  UNIQUE(user_id, setting_key)
);
CREATE INDEX IF NOT EXISTS idx_settings_user_id ON public.settings(user_id);
CREATE INDEX IF NOT EXISTS idx_settings_setting_key ON public.settings(setting_key);
ALTER TABLE public.settings ENABLE ROW LEVEL SECURITY;
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='settings' AND policyname='settings_select_own') THEN
    CREATE POLICY settings_select_own ON public.settings FOR SELECT USING (auth.uid() = user_id OR is_global = TRUE);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='settings' AND policyname='settings_update_own') THEN
    CREATE POLICY settings_update_own ON public.settings FOR UPDATE USING (auth.uid() = user_id);
  END IF;
END$$;

-- 8) ensure profiles columns exist
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS status varchar(50) default 'active';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS role varchar(50) default 'user';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS is_admin boolean default false;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS last_login timestamptz;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS ban_reason text;

-- End of consolidated migration
