-- Run in Supabase Dashboard → SQL Editor
-- Stores submissions from Traffic module → AI Police Complaint Generator

create table if not exists public.traffic_police_complaints (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  what_happened text not null,
  incident_location text not null,
  incident_date text not null,
  incident_time text not null,
  officer_id text,
  witnesses text,
  complainant_name text not null default '',
  contact_number text not null default '',
  cnic text not null default '',
  created_at timestamptz default now()
);

create index if not exists traffic_police_complaints_user_id_idx
  on public.traffic_police_complaints (user_id);

alter table public.traffic_police_complaints enable row level security;

drop policy if exists "Users manage own traffic police complaints"
  on public.traffic_police_complaints;
-- USING + WITH CHECK so INSERT is allowed for the authenticated user’s own row
create policy "Users manage own traffic police complaints"
  on public.traffic_police_complaints
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
