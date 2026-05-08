-- Feedback Table
-- Stores user feedback on agent responses for learning and ranking

CREATE TABLE IF NOT EXISTS public.feedback (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  conversation_id UUID REFERENCES public.conversation_sessions(id) ON DELETE SET NULL,
  
  -- Query and response info
  query TEXT NOT NULL,
  response_text TEXT,
  query_hash BYTEA,  -- SHA256 hash for deduplication
  
  -- Feedback data
  rating INT CHECK (rating >= 1 AND rating <= 5),  -- 1 (unhelpful) to 5 (very helpful)
  issue_type VARCHAR(50),  -- "unclear", "wrong", "incomplete", "helpful", "perfect", "irrelevant"
  comment TEXT,  -- Optional user comment
  
  -- Metadata
  module VARCHAR(50),  -- women_harassment, labour_rights, etc.
  source VARCHAR(50),  -- "vector_db", "agent_pipeline", "groq_fallback"
  agent_stages JSONB DEFAULT '{}'::jsonb,  -- {law_retrieval_ms, verification_ms, ...}
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT now(),
  
  -- Unique: prevent duplicate feedback on same response
  CONSTRAINT unique_feedback_per_response UNIQUE(user_id, conversation_id, query_hash)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_feedback_user_id 
  ON public.feedback(user_id);

CREATE INDEX IF NOT EXISTS idx_feedback_rating 
  ON public.feedback(rating);

CREATE INDEX IF NOT EXISTS idx_feedback_module 
  ON public.feedback(module);

CREATE INDEX IF NOT EXISTS idx_feedback_created_at 
  ON public.feedback(created_at);

CREATE INDEX IF NOT EXISTS idx_feedback_query_hash 
  ON public.feedback(query_hash);

-- Row Level Security
ALTER TABLE public.feedback ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS "Users can view own feedback" 
  ON public.feedback
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY IF NOT EXISTS "Users can insert own feedback" 
  ON public.feedback
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Useful view for analytics: average rating by module
CREATE OR REPLACE VIEW public.feedback_stats_by_module AS
SELECT 
  module,
  COUNT(*) as total_feedback,
  AVG(rating) as avg_rating,
  COUNT(CASE WHEN issue_type = 'wrong' THEN 1 END) as wrong_count,
  COUNT(CASE WHEN issue_type = 'unclear' THEN 1 END) as unclear_count,
  COUNT(CASE WHEN issue_type = 'helpful' OR issue_type = 'perfect' THEN 1 END) as positive_count
FROM public.feedback
GROUP BY module;

-- Useful view for analytics: rating distribution
CREATE OR REPLACE VIEW public.feedback_rating_distribution AS
SELECT 
  rating,
  COUNT(*) as count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as percentage
FROM public.feedback
WHERE rating IS NOT NULL
GROUP BY rating
ORDER BY rating DESC;
