-- Agent Metrics Table
-- Tracks performance and errors of each agent in the pipeline

CREATE TABLE IF NOT EXISTS public.agent_metrics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  conversation_id UUID REFERENCES public.conversation_sessions(id) ON DELETE SET NULL,
  
  -- Agent execution times (milliseconds)
  law_retrieval_ms INT,
  verification_ms INT,
  explanation_ms INT,
  guidance_ms INT,
  total_ms INT NOT NULL,
  
  -- Success/error tracking
  success BOOLEAN NOT NULL DEFAULT true,
  error_stage VARCHAR(50),  -- "law_retrieval", "verification", "explanation", "guidance", NULL if success
  error_message TEXT,
  
  -- Query info
  query_hash BYTEA,
  module VARCHAR(50),
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT now(),
  
  -- Ensure data integrity
  CHECK ((success = true AND error_stage IS NULL) OR (success = false AND error_stage IS NOT NULL))
);

-- Indexes for analytics queries
CREATE INDEX IF NOT EXISTS idx_agent_metrics_created_at 
  ON public.agent_metrics(created_at);

CREATE INDEX IF NOT EXISTS idx_agent_metrics_module 
  ON public.agent_metrics(module);

CREATE INDEX IF NOT EXISTS idx_agent_metrics_error_stage 
  ON public.agent_metrics(error_stage);

CREATE INDEX IF NOT EXISTS idx_agent_metrics_success 
  ON public.agent_metrics(success);

-- Useful views for analytics

-- Agent performance by stage
CREATE OR REPLACE VIEW public.agent_metrics_by_stage AS
SELECT 
  CASE 
    WHEN success THEN 'law_retrieval' ELSE error_stage
  END as stage,
  COUNT(*) as invocations,
  AVG(CASE WHEN stage = 'law_retrieval' THEN law_retrieval_ms END) as avg_ms,
  MAX(CASE WHEN stage = 'law_retrieval' THEN law_retrieval_ms END) as max_ms,
  MIN(CASE WHEN stage = 'law_retrieval' THEN law_retrieval_ms END) as min_ms,
  COUNT(CASE WHEN success = false THEN 1 END) as failure_count
FROM public.agent_metrics
GROUP BY stage
ORDER BY stage;

-- Overall pipeline success rate
CREATE OR REPLACE VIEW public.agent_metrics_success_rate AS
SELECT 
  COUNT(*) as total_runs,
  COUNT(CASE WHEN success = true THEN 1 END) as successful,
  COUNT(CASE WHEN success = false THEN 1 END) as failed,
  ROUND(100.0 * COUNT(CASE WHEN success = true THEN 1 END) / COUNT(*), 2) as success_percentage,
  ROUND(AVG(total_ms), 2) as avg_total_ms
FROM public.agent_metrics;

-- Errors by stage
CREATE OR REPLACE VIEW public.agent_metrics_errors_by_stage AS
SELECT 
  error_stage,
  COUNT(*) as error_count,
  error_message
FROM public.agent_metrics
WHERE success = false AND error_stage IS NOT NULL
GROUP BY error_stage, error_message
ORDER BY error_count DESC;
