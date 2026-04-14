-- Run once if [labour_wage_records] already exists from an older script.
-- Adds overtime fields and relaxes NOT NULL on wage-only columns.

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

alter table public.labour_wage_records
  alter column province drop not null;

alter table public.labour_wage_records
  alter column worker_type drop not null;

alter table public.labour_wage_records
  alter column legal_minimum_wage drop not null;

alter table public.labour_wage_records
  alter column meets_minimum drop not null;

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
