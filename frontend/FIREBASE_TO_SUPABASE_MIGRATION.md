# Firebase → Supabase Migration Guide – Legal Sathi

This document summarizes **what is stored in Firebase** in your app and gives **step-by-step instructions** to migrate to Supabase while keeping the same data and behavior.

---

## Part 1: What Firebase Is Storing (Audit)

### 1. Firebase Authentication
- **Sign up**: email + password; display name = full name.
- **Sign in**: email + password.
- **Sign out**.
- **Password reset**: send reset email.
- **Auth state**: stream of current user for routing (login vs home).

**No custom claims or roles** – only email/password and display name.

---

### 2. Firebase Realtime Database

#### A. `users/{uid}` (user profile data)
| Field      | Type   | Description                    |
|-----------|--------|--------------------------------|
| `uid`     | string | Same as Auth UID               |
| `fullName`| string | User’s full name               |
| `email`   | string | User’s email                   |
| `createdAt` | number | Server timestamp (ms)        |
| `lastLogin` | number | Server timestamp (ms)        |

Written on **sign up** and updated on **sign in** (lastLogin; or full record if missing).

---

#### B. `blackmail_cases/{blackmailId}` (cyber law module)
| Field          | Type   | Description                          |
|----------------|--------|--------------------------------------|
| `blackmailId`  | string | e.g. `blackmail_<timestamp>_...`     |
| `userId`       | string | Current user UID                     |
| `userEmail`    | string | Current user email                  |
| `situation`    | string | User’s situation description        |
| `evidenceFiles`| array  | See below                            |
| `createdAt`    | number | ms since epoch                       |
| `updatedAt`    | number | ms since epoch                       |

**evidenceFiles** (each item):
- `fileName`, `fileType`, `localPath`, `fileSize` (no Firebase Storage URL in use).

Queries: **get by id**, **list by userId** (`orderByChild('userId').equalTo(uid)`).

---

#### C. `complaints/{complaintId}` (women harassment / ombudsperson)
| Field               | Type   | Description                    |
|---------------------|--------|--------------------------------|
| `complaintId`       | string | Push key or existing ID        |
| `userId`            | string | Current user UID               |
| `fullName`          | string | Applicant full name            |
| `cnic`              | string | CNIC                           |
| `phone`             | string | Phone                          |
| `email`             | string | Email                          |
| `workplace`         | string | Workplace                      |
| `designation`       | string | Designation                    |
| `city`              | string | City                           |
| `incidentDate`      | string | Incident date                  |
| `harassmentType`    | string | Type of harassment             |
| `description`       | string | Description                     |
| `accusedName`       | string | Accused name                   |
| `accusedDesignation`| string | Accused designation           |
| `evidenceFiles`     | array  | See below                      |
| `createdAt`         | number | ms since epoch                 |
| `updatedAt`         | number | ms since epoch                 |
| `status`            | string | `draft` \| `submitted` \| …    |
| `submittedAt`       | number | ms (set when status → submitted) |

**evidenceFiles** (each item):
- `fileName`, `fileType`, `fileUrl` (optional), `localPath`, `fileSize`, `uploadedAt` (ms).

Operations: **create/update** complaint, **get by id**, **list by userId**, **add/remove evidence metadata**, **submit** (status + submittedAt), **delete**.

---

### 3. Firebase Storage
- **Not used.** Evidence is stored as **metadata only** (local path / file info). No file uploads to Firebase Storage in the current code.

---

## Part 2: Step-by-Step Migration to Supabase

### Step 1: Create Supabase project and get keys
1. Go to [supabase.com](https://supabase.com) and create a new project.
2. In **Project Settings → API** copy:
   - **Project URL** (e.g. `https://xxxx.supabase.co`)
   - **anon public** key (for Flutter app).

You will use these in the Flutter app (e.g. env or config file).

---

### Step 2: Create database tables in Supabase
In Supabase **SQL Editor**, run the SQL that matches the Firebase structure (see **Part 3** below). This creates:
- `profiles` (replaces `users` in Realtime DB)
- `blackmail_cases`
- `complaints` (with JSONB for `evidence_files` if you prefer)

Row Level Security (RLS) should allow:
- Users to read/write only their own `profiles` row (by `auth.uid()`).
- Users to read/write only their own `blackmail_cases` and `complaints` rows (by `userId`).

---

### Step 3: Enable Auth in Supabase
1. In Supabase: **Authentication → Providers**.
2. Enable **Email** provider (email + password).
3. Optional: configure **Email templates** for signup and password reset.

No Firebase Auth config is needed once you switch the app to Supabase.

---

### Step 4: Add Supabase Flutter SDK and remove Firebase
In `pubspec.yaml`:
- **Add**: `supabase_flutter: ^2.8.0` (or latest).
- **Remove** (after migration): `firebase_core`, `firebase_auth`, `firebase_database`.

Then run:
```bash
flutter pub get
```

**Already done in this project:** Firebase packages were removed and `supabase_flutter` was added. Replace `YOUR_SUPABASE_URL` and `YOUR_SUPABASE_ANON_KEY` in `lib/supabase_config.dart` with your Supabase project URL and anon key.

---

### Step 5: Initialize Supabase in the app
- Replace `Firebase.initializeApp(...)` in `main.dart` with `Supabase.initialize(url: ..., anonKey: ...)`.
- Remove `firebase_options.dart` and Firebase init; use a single Supabase init (with URL and anon key from Step 1).

---

### Step 6: Replace Auth usage
- **Auth state**: Use `Supabase.instance.client.auth.onAuthStateChange` (or equivalent) instead of `FirebaseAuth.instance.authStateChanges()` in your auth wrapper.
- **Sign up**: Use `Supabase.instance.client.auth.signUp(email: ..., password: ..., data: {'full_name': fullName})` and insert/update row in `profiles` (e.g. in a trigger or from the app).
- **Sign in**: `signInWithPassword(email, password)`.
- **Sign out**: `signOut()`.
- **Password reset**: `resetPasswordForEmail(email)`.
- **Current user**: `Supabase.instance.client.auth.currentUser`; user id = `currentUser?.id`.

Map Firebase `User` to Supabase `User` where needed (e.g. `user.id`, `user.email`).

---

### Step 7: Replace Realtime Database with Supabase Postgres
- **users** → table `profiles` (keyed by `id = auth.uid()`). On sign up/sign in, upsert `full_name`, `email`, `last_login`, etc.
- **blackmail_cases** → table `blackmail_cases`. Use Supabase client: `.from('blackmail_cases').insert(...).select()`, `.select().eq('userId', uid)`, etc.
- **complaints** → table `complaints`. Same idea: `.from('complaints').insert(...)`, `.update(...).eq('complaintId', id)`, `.select().eq('userId', uid)`.

Keep the same field names and types (or a clear mapping) so your existing models (`ComplaintModel`, `BlackmailModel`) still work with minimal changes (e.g. only the service layer changes).

---

### Step 8: Update app entry and auth wrapper
- **main.dart**: Only call `Supabase.initialize(...)`; remove all Firebase imports and `DefaultFirebaseOptions`.
- **Auth wrapper**: Use Supabase auth state stream and current user; route to **Home** when logged in, **Onboarding/Login** when not.

---

### Step 9: Optional – Migrate existing Firebase data
If you need to keep existing users and data:
1. Export Firebase Realtime Database (JSON) and, if any, Auth user list.
2. Transform and import into Supabase:
   - Create Auth users (e.g. via Admin API or import) and then fill `profiles`.
   - Insert rows into `blackmail_cases` and `complaints` from the exported JSON.

---

### Step 10: Remove Firebase from the project
- Delete or stop using `firebase_options.dart`, `google-services.json` (Android), and any Firebase config in iOS/Web/Windows.
- Remove Firebase from `pubspec.yaml` and run `flutter pub get`.
- Remove Firebase from native config (e.g. Android `build.gradle`, iOS Podfile) if present.

---

## Part 3: Supabase SQL schema (to store the same data)

Run this in Supabase **SQL Editor** (adjust types/lengths if needed):

```sql
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
create policy "Users can read own profile" on public.profiles for select using (auth.uid() = id);
create policy "Users can update own profile" on public.profiles for update using (auth.uid() = id);
create policy "Users can insert own profile" on public.profiles for insert with check (auth.uid() = id);

-- RLS: blackmail_cases
alter table public.blackmail_cases enable row level security;
create policy "Users can manage own blackmail cases" on public.blackmail_cases for all using (auth.uid() = user_id);

-- RLS: complaints
alter table public.complaints enable row level security;
create policy "Users can manage own complaints" on public.complaints for all using (auth.uid() = user_id);

-- Optional: trigger to create profile on signup
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, full_name, email, created_at, last_login)
  values (new.id, new.raw_user_meta_data->>'full_name', new.email, now(), now());
  return new;
end;
$$ language plpgsql security definer;

create or replace trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
```

---

## Summary

| Firebase              | Supabase equivalent                          |
|-----------------------|----------------------------------------------|
| Auth (email/password) | Supabase Auth (Email provider)               |
| Realtime DB `users`   | Table `profiles` + trigger on sign up         |
| Realtime DB `blackmail_cases` | Table `blackmail_cases` + RLS         |
| Realtime DB `complaints`      | Table `complaints` + RLS              |
| Auth state stream     | `Supabase.instance.client.auth.onAuthStateChange` |
| No Storage in use     | No Supabase Storage required for current flow |

After migration, the app will store the same data (users, blackmail cases, complaints) in Supabase instead of Firebase.
