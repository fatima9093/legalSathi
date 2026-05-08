-- Response Cache Table
-- Caches agent pipeline responses by query hash to avoid recomputation

CREATE TABLE IF NOT EXISTS public.response_cache (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Query identification
  query_hash BYTEA NOT NULL UNIQUE,  -- SHA256(normalized_query)
  query_text TEXT NOT NULL,
  module VARCHAR(50),
  
  -- Cached response
  cached_response JSONB NOT NULL,  -- Full OrchestratorResponse as JSON
  response_length_tokens INT,  -- Token count estimate
  
  -- Usage tracking
  hit_count INT DEFAULT 1,
  last_accessed TIMESTAMPTZ DEFAULT now(),
  
  -- Quality tracking
  average_rating DECIMAL(3, 2),  -- Average feedback rating
  feedback_count INT DEFAULT 0,
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT now(),
  expires_at TIMESTAMPTZ DEFAULT (now() + interval '30 days'),  -- Cache expires after 30 days
  
  -- Constraints
  CHECK (hit_count >= 1),
  CHECK (average_rating IS NULL OR (average_rating >= 1 AND average_rating <= 5))
);

-- Primary index on query hash for lookups
CREATE INDEX IF NOT EXISTS idx_response_cache_query_hash 
  ON public.response_cache(query_hash);

-- Index for cache expiration cleanup
CREATE INDEX IF NOT EXISTS idx_response_cache_expires_at 
  ON public.response_cache(expires_at);

-- Index for popular responses (by hit count)
CREATE INDEX IF NOT EXISTS idx_response_cache_hit_count 
  ON public.response_cache(hit_count DESC);

-- Index for module-specific lookups
CREATE INDEX IF NOT EXISTS idx_response_cache_module 
  ON public.response_cache(module);

-- Trigger to update last_accessed on hit
CREATE OR REPLACE FUNCTION public.update_response_cache_last_accessed()
RETURNS TRIGGER AS $$
BEGIN
  NEW.last_accessed = now();
  NEW.hit_count = COALESCE(NEW.hit_count, 1) + 1;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER IF NOT EXISTS trigger_response_cache_on_hit
  BEFORE UPDATE ON public.response_cache
  FOR EACH ROW
  WHEN (OLD.hit_count IS DISTINCT FROM NEW.hit_count)
  EXECUTE FUNCTION public.update_response_cache_last_accessed();

-- Useful views for cache analytics

-- Most popular cached responses
CREATE OR REPLACE VIEW public.response_cache_popular AS
SELECT 
  query_text,
  module,
  hit_count,
  average_rating,
  feedback_count,
  last_accessed,
  created_at
FROM public.response_cache
ORDER BY hit_count DESC
LIMIT 50;

-- Cache hit statistics
CREATE OR REPLACE VIEW public.response_cache_stats AS
SELECT 
  COUNT(*) as total_cached,
  SUM(hit_count) as total_hits,
  AVG(hit_count) as avg_hits_per_response,
  COUNT(CASE WHEN average_rating IS NOT NULL THEN 1 END) as responses_with_feedback,
  AVG(average_rating) as avg_response_rating
FROM public.response_cache;

-- Clean up expired cache entries (optional manual job)
-- Can be run periodically via backend cron or manually
-- DELETE FROM public.response_cache WHERE expires_at < now();
