-- Migration: Create missing Supabase tables required by the app
-- Creates `conversation_sessions` and `activity_logs` if they do not exist.

-- Ensure required extension for UUID generation
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Conversation Sessions (safe-create - app already includes a file, keep minimal here)
CREATE TABLE IF NOT EXISTS public.conversation_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  summary TEXT,
  module VARCHAR(50),
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  expires_at TIMESTAMPTZ DEFAULT (now() + interval '7 days')
);

CREATE INDEX IF NOT EXISTS idx_conversation_sessions_user_id ON public.conversation_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_conversation_sessions_expires_at ON public.conversation_sessions(expires_at);

-- Activity Logs
CREATE TABLE IF NOT EXISTS public.activity_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  activity_type VARCHAR(128),
  description TEXT,
  icon VARCHAR(64),
  resource_id UUID,
  related_id UUID,
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT now(),
  timestamp TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_activity_logs_user_id ON public.activity_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_activity_logs_created_at ON public.activity_logs(created_at);

-- Row Level Security: allow users to access their own rows when using Supabase auth
ALTER TABLE public.activity_logs ENABLE ROW LEVEL SECURITY;
CREATE POLICY IF NOT EXISTS "Users can view own activity logs"
  ON public.activity_logs
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY IF NOT EXISTS "Users can insert own activity logs"
  ON public.activity_logs
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY IF NOT EXISTS "Users can update own activity logs"
  ON public.activity_logs
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY IF NOT EXISTS "Users can delete own activity logs"
  ON public.activity_logs
  FOR DELETE
  USING (auth.uid() = user_id);

-- Optional: ensure conversation_sessions has RLS as well (idempotent)
ALTER TABLE public.conversation_sessions ENABLE ROW LEVEL SECURITY;
CREATE POLICY IF NOT EXISTS "Users can view own conversations"
  ON public.conversation_sessions
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY IF NOT EXISTS "Users can insert own conversations"
  ON public.conversation_sessions
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY IF NOT EXISTS "Users can update own conversations"
  ON public.conversation_sessions
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY IF NOT EXISTS "Users can delete own conversations"
  ON public.conversation_sessions
  FOR DELETE
  USING (auth.uid() = user_id);

-- Trigger for updated_at on conversation_sessions
CREATE OR REPLACE FUNCTION public.update_conversation_sessions_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_conversation_sessions_updated_at ON public.conversation_sessions;
CREATE TRIGGER trigger_conversation_sessions_updated_at
  BEFORE UPDATE ON public.conversation_sessions
  FOR EACH ROW
  EXECUTE FUNCTION public.update_conversation_sessions_updated_at();

-- End of migration
