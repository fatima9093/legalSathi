-- Run once if [labour_wage_records] exists without general/denied leave complaint types.

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
