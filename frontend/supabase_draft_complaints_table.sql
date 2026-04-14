-- Run in Supabase Dashboard → SQL Editor
-- Creates draft_complaints table (Draft Complaint Generator flow)

create table if not exists public.draft_complaints (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  full_name text,
  cnic text,
  phone text,
  email text,
  designation text,
  workplace text,
  address text,
  date_of_incident text,
  description text,
  evidence text,
  witnesses text,
  mental_impact text,
  emotional_impact text,
  safety_concerns text,
  relief_sought jsonb default '[]',
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table public.draft_complaints enable row level security;
drop policy if exists "Users can manage own draft complaints" on public.draft_complaints;
create policy "Users can manage own draft complaints" on public.draft_complaints for all using (auth.uid() = user_id);
