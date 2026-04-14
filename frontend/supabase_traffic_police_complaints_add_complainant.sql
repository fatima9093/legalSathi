-- Run once in Supabase SQL Editor if [traffic_police_complaints] already exists
-- without complainant columns (adds name, phone, CNIC for the letter footer).

alter table public.traffic_police_complaints
  add column if not exists complainant_name text not null default '';

alter table public.traffic_police_complaints
  add column if not exists contact_number text not null default '';

alter table public.traffic_police_complaints
  add column if not exists cnic text not null default '';
