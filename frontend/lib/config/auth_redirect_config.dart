import 'package:flutter/foundation.dart';

/// Redirect URLs for Supabase auth (Google OAuth, password reset, email confirm).
///
/// Must match **Authentication → URL Configuration → Redirect URLs** in Supabase.
class AuthRedirectConfig {
  /// Mobile deep link — same host as Google OAuth in AndroidManifest.
  static const String mobileRedirectUrl = 'io.legalsathi.app://login-callback/';

  /// Flutter Web dev URL. Run with: `flutter run -d chrome --web-port=3000`
  static const String webRedirectUrl = String.fromEnvironment(
    'AUTH_REDIRECT_URL',
    defaultValue: 'http://localhost:3000',
  );

  /// Used by resetPasswordForEmail, signInWithOAuth (mobile), etc.
  static String get redirectUrl => kIsWeb ? webRedirectUrl : mobileRedirectUrl;
}
