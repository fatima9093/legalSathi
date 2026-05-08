-- Conversation Sessions Table
-- Stores persistent multi-turn conversation context (replaces in-memory 6-hour TTL)

CREATE TABLE IF NOT EXISTS public.conversation_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  
  -- Case context and metadata
  summary TEXT,  -- Case summary (e.g., "Wage dispute with employer")
  module VARCHAR(50),  -- Module type: women_harassment, labour_rights, cyber_law, road_laws
  metadata JSONB DEFAULT '{}'::jsonb,  -- {urgency, issue_type, location, ...}
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  expires_at TIMESTAMPTZ DEFAULT (now() + interval '7 days'),  -- Auto-expire after 7 days
  
  -- Unique constraint per user+conversation
  CONSTRAINT unique_user_conversation UNIQUE(user_id, id)
);

-- Indexes for common queries
CREATE INDEX IF NOT EXISTS idx_conversation_sessions_user_id 
  ON public.conversation_sessions(user_id);

CREATE INDEX IF NOT EXISTS idx_conversation_sessions_expires_at 
  ON public.conversation_sessions(expires_at);

CREATE INDEX IF NOT EXISTS idx_conversation_sessions_module 
  ON public.conversation_sessions(module);

-- Row Level Security (RLS) - Users can only see their own sessions
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

-- Trigger to auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_conversation_sessions_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER IF NOT EXISTS trigger_conversation_sessions_updated_at
  BEFORE UPDATE ON public.conversation_sessions
  FOR EACH ROW
  EXECUTE FUNCTION public.update_conversation_sessions_updated_at();

-- Clean up expired conversations (optional manual job)
-- Can be run periodically via backend cron or manually
-- DELETE FROM public.conversation_sessions WHERE expires_at < now();
