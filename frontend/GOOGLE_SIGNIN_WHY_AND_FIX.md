# Why Google sign-in fails (simple explanation)

## What you see

1. Google says: **"Sign in to continue to ghwvezmgxpwwfxaeeriy.supabase.co"**  
   → This is **normal**. Supabase handles login, so Google shows the Supabase project name.

2. After you tap Continue, the browser opens:  
   `https://ghwvezmgxpwwfxaeeriy.supabase.co/?code=...`  
   → This is the **bug**.

3. That page shows: `{"error":"requested path is invalid"}`  
   → Because that URL is an **API server**, not a website or your app.

---

## Why it happens (one sentence)

**Supabase sends you to the wrong address after Google login** — it uses **Site URL** (`https://....supabase.co`) instead of opening your app (`io.legalsathi.app://login-callback/`).

---

## How to fix (pick ONE path)

### Path A — Recommended: Native Google (no browser)

You already pasted **Web Client ID** in `google_auth_config.dart`. Good.

1. **Uninstall** the app from your phone.
2. Rebuild:
   ```powershell
   cd E:\legalSathi-mobileApp\fyp-project-code\frontend
   flutter clean
   flutter pub get
   flutter run
   ```
3. Tap **Continue with Google**.
4. You should see **Google account picker** (not a long browser flow to supabase.co).

**Android only:** In Google Cloud, create an **Android** OAuth client with:
- Package: `com.example.front_end`
- SHA-1 from:
  ```bash
  keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
  ```

**iPhone:** In Google Cloud, create an **iOS** OAuth client (bundle `com.example.frontEnd`), then paste Client ID in:
`lib/config/google_auth_config.dart` → `fileIosClientId = '...'`

---

### Path B — Fix Supabase (if you keep browser login)

1. Supabase → **Authentication** → **URL Configuration**

2. **Site URL** — must be:
   ```text
   http://localhost:3000
   ```
   **Delete** `https://ghwvezmgxpwwfxaeeriy.supabase.co` from Site URL.

3. **Redirect URLs** — add:
   ```text
   io.legalsathi.app://login-callback/
   io.legalsathi.app://**
   ```

4. Save, wait 2 minutes, uninstall app, `flutter run`, try again.

---

## Checklist

| Check | Correct |
|-------|---------|
| Site URL | `http://localhost:3000` |
| NOT Site URL | `https://ghwvezmgxpwwfxaeeriy.supabase.co` |
| Redirect URLs | `io.legalsathi.app://login-callback/` |
| fileWebClientId in code | filled (you did this) |
| After login | App opens, not supabase.co in Safari |

---

## Still stuck?

Tell us: **Android or iPhone?** and what happens after you tap your Google account (screenshot or exact URL in the address bar).
