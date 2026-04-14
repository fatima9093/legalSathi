-- =============================================================================
-- Labour wage records — ONE script for Supabase (Dashboard → SQL → New query → Run)
-- Required for: Generate Complaint Application, minimum wage / overtime / leave flows
-- Safe to run more than once on the same project (idempotent where supported).
-- =============================================================================

-- 1) Base table (new projects; skipped if already exists)
create table if not exists public.labour_wage_records (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  record_type text not null,
  province text,
  worker_type text,
  monthly_salary numeric not null default 0,
  legal_minimum_wage numeric,
  meets_minimum boolean,
  monthly_shortfall numeric,
  months_owed int,
  total_back_pay numeric,
  complaint_issue text,
  employer_name text,
  weekly_hours numeric,
  overtime_hours numeric,
  hourly_rate numeric,
  legal_overtime_hourly_rate numeric,
  overtime_pay_total numeric,
  created_at timestamptz default now()
);

-- 2) Add any missing columns (older installs)
alter table public.labour_wage_records
  add column if not exists weekly_hours numeric;
alter table public.labour_wage_records
  add column if not exists overtime_hours numeric;
alter table public.labour_wage_records
  add column if not exists hourly_rate numeric;
alter table public.labour_wage_records
  add column if not exists legal_overtime_hourly_rate numeric;
alter table public.labour_wage_records
  add column if not exists overtime_pay_total numeric;
alter table public.labour_wage_records
  add column if not exists complaint_issue text;
alter table public.labour_wage_records
  add column if not exists employer_name text;
alter table public.labour_wage_records
  add column if not exists monthly_shortfall numeric;
alter table public.labour_wage_records
  add column if not exists months_owed int;
alter table public.labour_wage_records
  add column if not exists total_back_pay numeric;
alter table public.labour_wage_records
  add column if not exists legal_minimum_wage numeric;
alter table public.labour_wage_records
  add column if not exists meets_minimum boolean;
alter table public.labour_wage_records
  add column if not exists province text;
alter table public.labour_wage_records
  add column if not exists worker_type text;

-- 3) Relax NOT NULL on older installs (safe if already nullable)
do $$
begin
  alter table public.labour_wage_records alter column province drop not null;
exception when others then null;
end $$;
do $$
begin
  alter table public.labour_wage_records alter column worker_type drop not null;
exception when others then null;
end $$;
do $$
begin
  alter table public.labour_wage_records alter column legal_minimum_wage drop not null;
exception when others then null;
end $$;
do $$
begin
  alter table public.labour_wage_records alter column meets_minimum drop not null;
exception when others then null;
end $$;

-- 4) Allowed record types (must match app: labour_wage_record_service.dart)
alter table public.labour_wage_records
  drop constraint if exists labour_wage_records_record_type_check;

alter table public.labour_wage_records
  add constraint labour_wage_records_record_type_check
  check (record_type in (
    'back_pay',
    'wage_complaint',
    'overtime_calc',
    'overtime_complaint',
    'general_labour_complaint',
    'denied_leave_complaint'
  ));

-- 5) Indexes
create index if not exists labour_wage_records_user_id_idx
  on public.labour_wage_records (user_id);
create index if not exists labour_wage_records_created_at_idx
  on public.labour_wage_records (created_at desc);

-- 6) Row Level Security
alter table public.labour_wage_records enable row level security;

drop policy if exists "Users manage own labour wage records"
  on public.labour_wage_records;

create policy "Users manage own labour wage records"
  on public.labour_wage_records
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
