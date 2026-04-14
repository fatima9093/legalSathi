-- Run this in Supabase Dashboard → SQL Editor
-- Fixes: "could not find the complaint type column"
-- Adds department and complaint_type to the complaints table

-- Option A: If your PostgreSQL supports IF NOT EXISTS (most Supabase projects do):
ALTER TABLE public.complaints ADD COLUMN IF NOT EXISTS department text;
ALTER TABLE public.complaints ADD COLUMN IF NOT EXISTS complaint_type text;

-- Option B: If you get an error with IF NOT EXISTS, run these instead (ignore "already exists" if you run twice):
-- ALTER TABLE public.complaints ADD COLUMN department text;
-- ALTER TABLE public.complaints ADD COLUMN complaint_type text;
