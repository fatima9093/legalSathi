-- Run this in Supabase Dashboard → SQL Editor
-- Creates tables that mirror your Firebase Realtime Database structure

-- Profiles (replaces Firebase users/{uid})
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  email text,
  created_at timestamptz default now(),
  last_login timestamptz default now()
);

-- Blackmail cases (same structure as Firebase blackmail_cases)
create table if not exists public.blackmail_cases (
  blackmail_id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  user_email text,
  situation text,
  evidence_files jsonb default '[]',
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Complaints (same structure as Firebase complaints)
create table if not exists public.complaints (
  complaint_id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  full_name text,
  cnic text,
  phone text,
  email text,
  workplace text,
  designation text,
  city text,
  incident_date text,
  harassment_type text,
  description text,
  accused_name text,
  accused_designation text,
  evidence_files jsonb default '[]',
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  status text default 'draft',
  submitted_at timestamptz
);

-- RLS: profiles
alter table public.profiles enable row level security;
drop policy if exists "Users can read own profile" on public.profiles;
create policy "Users can read own profile" on public.profiles for select using (auth.uid() = id);
drop policy if exists "Users can update own profile" on public.profiles;
create policy "Users can update own profile" on public.profiles for update using (auth.uid() = id);
drop policy if exists "Users can insert own profile" on public.profiles;
create policy "Users can insert own profile" on public.profiles for insert with check (auth.uid() = id);

-- RLS: blackmail_cases
alter table public.blackmail_cases enable row level security;
drop policy if exists "Users can manage own blackmail cases" on public.blackmail_cases;
create policy "Users can manage own blackmail cases" on public.blackmail_cases for all using (auth.uid() = user_id);

-- RLS: complaints
alter table public.complaints enable row level security;
drop policy if exists "Users can manage own complaints" on public.complaints;
create policy "Users can manage own complaints" on public.complaints for all using (auth.uid() = user_id);

-- Optional: auto-create profile on signup (so you don't have to insert from app)
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, full_name, email, created_at, last_login)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', ''),
    new.email,
    now(),
    now()
  )
  on conflict (id) do nothing;
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
