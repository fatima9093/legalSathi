# Google Sign-In Setup (Supabase)

The app has **Continue with Google** on Login and Sign Up. Complete these steps once in Supabase and Google Cloud.

## 1. Supabase Dashboard

1. Open [Supabase](https://supabase.com) → your project (`ghwvezmgxpwwfxaeeriy`).
2. **Authentication** → **Providers** → **Google** → Enable.
3. Copy **Client ID** and **Client Secret** from Google (step 2 below) into Supabase.
4. **Authentication** → **URL Configuration**:
   - **Site URL** (must be `http://` or `https://`, NOT the app deep link, NOT `*.supabase.co`):
     ```
     http://localhost:3000
     ```
   - **Redirect URLs** — add (app returns here after Google):
     ```
     io.legalsathi.app://login-callback/
     io.legalsathi.app://login-callback
     ```
   - Do **not** put `io.legalsathi.app://...` or `https://....supabase.co` in **Site URL**.
5. Save.

See **SUPABASE_URL_FIX.md** if you already hit that error.

## 2. Google Cloud Console

1. [Google Cloud Console](https://console.cloud.google.com/) → project **legal-sathi-f6009** (or create OAuth credentials).
2. **APIs & Services** → **Credentials** → **Create Credentials** → **OAuth client ID**.
3. Configure **OAuth consent screen** (External, add test users if in testing).
4. Create:
   - **Web application** → copy Client ID (used in Supabase + optional native Android `serverClientId`).
   - **Android** → package name `com.example.front_end`, SHA-1 from your debug keystore:
     ```bash
     keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
     ```
   - **iOS** (if building for iPhone) → bundle ID from Xcode.

5. Paste Web client ID + secret into Supabase Google provider.

## 3. Optional: native Google picker (smoother on phone)

Run the app with your Web client ID (and iOS client ID on iPhone):

```bash
flutter run --dart-define=GOOGLE_WEB_CLIENT_ID=YOUR_WEB_CLIENT_ID.apps.googleusercontent.com --dart-define=GOOGLE_IOS_CLIENT_ID=YOUR_IOS_CLIENT_ID.apps.googleusercontent.com
```

Without these, the app uses **browser OAuth** (still works after steps 1–2).

## 4. Test

1. `flutter pub get`
2. `flutter run` on device
3. Tap **Continue with Google** on Sign In or Create Account
4. After Google login you should land on **Home** as a logged-in user

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `site url is improperly formatted` | Site URL = `http://localhost:3000`; deep link only under Redirect URLs |
| `requested path is invalid` | Site URL must NOT be `https://....supabase.co`; add `io.legalsathi.app://login-callback/` to Redirect URLs |
| Browser opens then nothing | Add redirect URL in Supabase (step 1.4) |
| `localhost refused to connect` on phone | Fix Site URL + Redirect URLs (see SUPABASE_URL_FIX.md) |
| `redirect_uri_mismatch` | Same redirect URL in Google Cloud authorized redirects if required |
| Stuck on login | Rebuild app after manifest / Info.plist changes |
| Profile not saved | Ensure `profiles` table exists and RLS allows insert for authenticated users |
