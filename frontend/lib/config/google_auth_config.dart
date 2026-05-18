import 'package:flutter/foundation.dart';

/// Google Sign-In configuration for Supabase Auth.
///
/// **OAuth (browser):** Works after enabling Google in Supabase Dashboard.
/// Add [redirectUrl] under Authentication → URL Configuration → Redirect URLs.
///
/// **Native (optional):** Set Web + iOS client IDs from Google Cloud Console
/// (same project linked in Supabase → Auth → Google).
class GoogleAuthConfig {
  /// OAuth redirect — must match Supabase **Redirect URLs** (not Site URL).
  /// No underscores (Google OAuth can break URLs that contain `_`).
  static const String redirectUrl = 'io.legalsathi.app://login-callback/';

  /// Web client ID from `--dart-define=GOOGLE_WEB_CLIENT_ID=...`
  static const String webClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '',
  );

  /// Paste here if not using dart-define (Google Cloud → Web application Client ID).
  /// Must match the Client ID in Supabase → Authentication → Google.
  static const String fileWebClientId = '633598188583-rgro5h0n0anhtbeiv0d0f2rdcamkuvq0.apps.googleusercontent.com';

  /// iOS client ID (OAuth 2.0 **iOS** application), optional on Android.
  static const String iosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
    defaultValue: '',
  );

  static const String fileIosClientId = '';

  /// Resolved Web client ID for native Google sign-in (no browser redirect).
  static String get effectiveWebClientId {
    if (webClientId.isNotEmpty) return webClientId;
    return fileWebClientId.trim();
  }

  static String get effectiveIosClientId {
    if (iosClientId.isNotEmpty) return iosClientId;
    return fileIosClientId.trim();
  }

  /// Native sign-in avoids broken browser redirect to *.supabase.co/?code=...
  /// Uses Google account picker in-app (no Supabase webpage after login).
  static bool get useNativeGoogleSignIn =>
      !kIsWeb && effectiveWebClientId.isNotEmpty;
}
