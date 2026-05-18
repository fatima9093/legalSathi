# Fix: `requested path is invalid` + URL `https://....supabase.co/?code=...`

## What that URL means

Supabase sent you to your **project API URL** with `?code=...` instead of back into the app.

That happens when **Site URL** is still set to `https://ghwvezmgxpwwfxaeeriy.supabase.co`  
and/or the app deep link is **not** in **Redirect URLs**.

---

## A) Best fix — Native Google (no browser redirect)

1. Google Cloud → your **Web application** OAuth client → copy **Client ID**  
   (ends with `.apps.googleusercontent.com`)

2. Open `lib/config/google_auth_config.dart` and paste into:

   ```dart
   static const String fileWebClientId = 'PASTE_CLIENT_ID_HERE';
   ```

   (Same Client ID as in **Supabase → Authentication → Google**.)

3. **Android:** `flutter run` — uses Google account picker, no Supabase webpage.

4. **iPhone:** also paste iOS Client ID into `fileIosClientId`, or use Web client from Google Cloud iOS OAuth client.

---

## B) Supabase URL settings (required for browser OAuth)

**Authentication → URL Configuration**

| Field | Value |
|-------|--------|
| **Site URL** | `http://localhost:3000` |
| **NOT Site URL** | ~~`https://ghwvezmgxpwwfxaeeriy.supabase.co`~~ |

**Redirect URLs** — add all:

```text
io.legalsathi.app://login-callback/
io.legalsathi.app://login-callback
io.legalsathi.app://**
```

Save.

---

## C) Rebuild app

```powershell
cd E:\legalSathi-mobileApp\fyp-project-code\frontend
flutter pub get
flutter run
```

Uninstall old app from phone first.

---

## Quick check

If the browser address bar shows `https://ghwvezmgxpwwfxaeeriy.supabase.co/?code=...`  
→ Site URL is still wrong **or** use **native sign-in** (section A).
