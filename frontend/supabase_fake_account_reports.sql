-- Fake account reports table for PECA module
-- Run in Supabase SQL editor.

create table if not exists public.fake_account_reports (
  id bigserial primary key,
  report_id text unique not null,
  user_id uuid not null references auth.users(id) on delete cascade,
  platform text not null,
  profile_url text,
  username text,
  evidence_files jsonb not null default '[]'::jsonb,
  status text not null default 'draft',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.fake_account_reports enable row level security;

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'fake_account_reports'
      and policyname = 'fake_account_reports_select_own'
  ) then
    create policy fake_account_reports_select_own
      on public.fake_account_reports
      for select
      using (auth.uid() = user_id);
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'fake_account_reports'
      and policyname = 'fake_account_reports_insert_own'
  ) then
    create policy fake_account_reports_insert_own
      on public.fake_account_reports
      for insert
      with check (auth.uid() = user_id);
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'fake_account_reports'
      and policyname = 'fake_account_reports_update_own'
  ) then
    create policy fake_account_reports_update_own
      on public.fake_account_reports
      for update
      using (auth.uid() = user_id)
      with check (auth.uid() = user_id);
  end if;
end $$;

