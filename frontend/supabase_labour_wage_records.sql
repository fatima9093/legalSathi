-- Run in Supabase Dashboard → SQL Editor
-- Labour module: minimum wage, back-pay, overtime snapshots, and complaint filings

create table if not exists public.labour_wage_records (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  record_type text not null check (record_type in (
    'back_pay',
    'wage_complaint',
    'overtime_calc',
    'overtime_complaint',
    'general_labour_complaint',
    'denied_leave_complaint'
  )),
  province text,
  worker_type text,
  monthly_salary numeric not null,
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

create index if not exists labour_wage_records_user_id_idx
  on public.labour_wage_records (user_id);

create index if not exists labour_wage_records_created_at_idx
  on public.labour_wage_records (created_at desc);

alter table public.labour_wage_records enable row level security;

drop policy if exists "Users manage own labour wage records"
  on public.labour_wage_records;
create policy "Users manage own labour wage records"
  on public.labour_wage_records
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
