-- Run this in Supabase SQL Editor to enable FIA complaint storage.

create table if not exists public.fia_complaints (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  full_name text not null,
  cnic text not null,
  phone text not null,
  email text not null,
  address text null,
  date_of_incident text not null,
  incident_description text not null,
  suspect_info text null,
  evidence_available text null,
  created_at timestamptz not null default now()
);

alter table public.fia_complaints enable row level security;

drop policy if exists "fia complaints select own" on public.fia_complaints;
create policy "fia complaints select own"
on public.fia_complaints for select
using (auth.uid() = user_id);

drop policy if exists "fia complaints insert own" on public.fia_complaints;
create policy "fia complaints insert own"
on public.fia_complaints for insert
with check (auth.uid() = user_id);

