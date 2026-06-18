import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:front_end/config/google_auth_config.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Simple user representation (replaces Firebase User in UI).
class AppUser {
  final String id;
  final String? email;
  final String? displayName;

  AppUser({required this.id, this.email, this.displayName});
}

class AuthService {
  static Timer? _sessionExpiryTimer;
  static bool _sessionExpiryMonitoringStarted = false;

  SupabaseClient get _client => Supabase.instance.client;

  /// Prefer session?.user so we use the same object the client considers "current".
  User? get _authUser =>
      _client.auth.currentSession?.user ?? _client.auth.currentUser;

  AppUser? get currentUser {
    final user = _authUser;
    if (user == null) return null;
    final meta = user.userMetadata;
    final name =
        meta?['full_name'] as String? ?? meta?['full_name']?.toString();
    return AppUser(
      id: user.id,
      email: user.email,
      displayName: name?.isNotEmpty == true ? name : null,
    );
  }

  /// Stream that emits current user when auth state changes, and emits once with
  /// current user when first listened to (so UI sees session right after login).
  Stream<AppUser?> get authStateChanges {
    final current = currentUser;
    return Stream<AppUser?>.multi((controller) {
      controller.add(current);

      final subscription = _client.auth.onAuthStateChange.listen((event) {
        final user = event.session?.user;
        if (user == null) {
          controller.add(null);
          return;
        }
        final meta = user.userMetadata;
        final name =
            meta?['full_name'] as String? ?? meta?['full_name']?.toString();
        controller.add(
          AppUser(
            id: user.id,
            email: user.email,
            displayName: name?.isNotEmpty == true ? name : null,
          ),
        );
      });

      controller.onCancel = () async {
        await subscription.cancel();
      };
    });
  }

  static void initializeSessionExpiryMonitoring() {
    if (_sessionExpiryMonitoringStarted) return;
    _sessionExpiryMonitoringStarted = true;

    final client = Supabase.instance.client;
    _scheduleSessionExpiry(client.auth.currentSession);

    client.auth.onAuthStateChange.listen((event) {
      _scheduleSessionExpiry(event.session);
    });
  }

  static void _scheduleSessionExpiry(Session? session) {
    _sessionExpiryTimer?.cancel();
    _sessionExpiryTimer = null;

    if (session == null) {
      return;
    }

    final expiresAt = session.expiresAt;
    final expiryTime = expiresAt != null
        ? DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000)
        : DateTime.now().add(const Duration(hours: 1));

    final timeUntilExpiry = expiryTime.difference(DateTime.now());
    if (timeUntilExpiry.isNegative || timeUntilExpiry == Duration.zero) {
      unawaited(
        Supabase.instance.client.auth.signOut(scope: SignOutScope.local),
      );
      return;
    }

    _sessionExpiryTimer = Timer(timeUntilExpiry, () {
      unawaited(
        Supabase.instance.client.auth.signOut(scope: SignOutScope.local),
      );
    });
  }

  bool isStrongPassword(String value) {
    final password = value.trim();
    if (password.length < 8) return false;
    if (!RegExp(r'[A-Z]').hasMatch(password)) return false;
    if (!RegExp(r'[a-z]').hasMatch(password)) return false;
    if (!RegExp(r'[0-9]').hasMatch(password)) return false;
    return RegExp(r'[!@#\$%^&*(),.?":{}|<>_]').hasMatch(password);
  }

  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      if (!isStrongPassword(password)) {
        return {
          'success': false,
          'message':
              'Password must be at least 8 characters and include uppercase, lowercase, number, and symbol.',
        };
      }

      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'full_name': fullName},
      );

      final user = response.user;
      if (user != null) {
        await _upsertProfile(
          uid: user.id,
          fullName: fullName,
          email: email.trim(),
        );
        final needsEmailVerification = response.session == null;
        return {
          'success': true,
          'needsVerification': needsEmailVerification,
          'message': needsEmailVerification
              ? 'Account created. Check your email to verify your account before signing in.'
              : 'Account created successfully!',
          'user': AppUser(
            id: user.id,
            email: user.email,
            displayName: fullName,
          ),
        };
      }
      return {'success': false, 'message': 'Failed to create account'};
    } on AuthException catch (e) {
      String message;
      switch (e.message.toLowerCase()) {
        case 'password should be at least 6 characters':
        case 'invalid password':
          message = 'Password should be at least 6 characters';
          break;
        case 'user already registered':
          message = 'An account already exists with this email';
          break;
        case 'invalid email':
          message = 'Please enter a valid email address';
          break;
        default:
          message = e.message.isNotEmpty
              ? e.message
              : 'An error occurred. Please try again';
      }
      return {'success': false, 'message': message};
    } catch (e, stackTrace) {
      debugPrint('SignUp error: $e');
      debugPrint('Stack: $stackTrace');
      final String message =
          e.toString().contains('SocketException') ||
              e.toString().contains('network')
          ? 'No internet connection. Please check your network and try again'
          : 'Something went wrong. Please try again';
      return {'success': false, 'message': message};
    }
  }

  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      final user = response.user;
      if (user != null) {
        await _upsertProfile(
          uid: user.id,
          fullName:
              (user.userMetadata?['full_name'] ?? user.email?.split('@').first)
                  as String? ??
              '',
          email: user.email ?? email.trim(),
        );
        return {
          'success': true,
          'message': 'Signed in successfully!',
          'user': AppUser(
            id: user.id,
            email: user.email,
            displayName: user.userMetadata?['full_name'] as String?,
          ),
        };
      }
      return {'success': false, 'message': 'Failed to sign in'};
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      String message;
      if (msg.contains('email not confirmed')) {
        message =
            'Please confirm your email first. Check your inbox for the link from Supabase, then try signing in again.';
      } else if (msg.contains('invalid login credentials')) {
        message =
            'Incorrect password or email. Check both and try again, or use "Forgot password".';
      } else if (msg.contains('invalid email')) {
        message = 'Please enter a valid email address';
      } else {
        message = e.message.isNotEmpty
            ? e.message
            : 'Failed to sign in. Please try again';
      }
      return {'success': false, 'message': message};
    } catch (e, stackTrace) {
      debugPrint('SignIn error: $e');
      debugPrint('Stack: $stackTrace');
      final String message =
          e.toString().contains('SocketException') ||
              e.toString().contains('network')
          ? 'No internet connection. Please check your network and try again'
          : 'Sign in failed. Please check your email, password, and internet connection';
      return {'success': false, 'message': message};
    }
  }

  /// Sign in or sign up with Google (Supabase Auth).
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      if (GoogleAuthConfig.useNativeGoogleSignIn) {
        return await _signInWithGoogleNative();
      }
      return await _signInWithGoogleOAuth();
    } on AuthException catch (e) {
      return {
        'success': false,
        'message': e.message.isNotEmpty ? e.message : 'Google sign-in failed',
      };
    } catch (e, stackTrace) {
      debugPrint('Google sign-in error: $e');
      debugPrint('Stack: $stackTrace');
      final msg = e.toString();
      if (msg.contains('SocketException') || msg.contains('network')) {
        return {
          'success': false,
          'message':
              'No internet connection. Please check your network and try again',
        };
      }
      return {
        'success': false,
        'message': 'Google sign-in failed. Please try again.',
      };
    }
  }

  Future<Map<String, dynamic>> _signInWithGoogleNative() async {
    final googleSignIn = GoogleSignIn(
      clientId: !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS
          ? GoogleAuthConfig.effectiveIosClientId
          : null,
      serverClientId: GoogleAuthConfig.effectiveWebClientId,
    );

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      return {'success': false, 'message': 'Google sign-in was cancelled'};
    }

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    final accessToken = googleAuth.accessToken;

    if (idToken == null) {
      return {
        'success': false,
        'message':
            'Google did not return an ID token. Check Google Cloud / Supabase setup.',
      };
    }

    final response = await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );

    return _completeGoogleSession(
      response.user,
      fallbackName: googleUser.displayName,
    );
  }

  Future<Map<String, dynamic>> _signInWithGoogleOAuth() async {
    if (!kIsWeb && GoogleAuthConfig.effectiveWebClientId.isEmpty) {
      return {
        'success': false,
        'message':
            'Google sign-in needs your Web Client ID.\n'
            'Paste it in lib/config/google_auth_config.dart → fileWebClientId\n'
            '(Google Cloud → Web application, same ID as in Supabase → Google).',
      };
    }

    final launched = await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb ? null : GoogleAuthConfig.redirectUrl,
      // In-app webview completes PKCE and returns to the app (avoids stuck browser tab).
      authScreenLaunchMode: kIsWeb
          ? LaunchMode.platformDefault
          : LaunchMode.inAppBrowserView,
    );

    if (!launched) {
      return {'success': false, 'message': 'Could not open Google sign-in'};
    }

    if (kIsWeb) {
      return {
        'success': true,
        'pending': true,
        'message': 'Complete sign-in in the browser tab',
      };
    }

    final appUser = await authStateChanges
        .where((u) => u != null)
        .first
        .timeout(const Duration(minutes: 3), onTimeout: () => null);

    if (appUser == null) {
      return {
        'success': false,
        'message': 'Google sign-in was cancelled or timed out',
      };
    }

    final user = _authUser;
    if (user != null) {
      await _upsertProfileFromGoogleUser(user);
    }

    return {
      'success': true,
      'message': 'Signed in with Google!',
      'user': appUser,
    };
  }

  Future<Map<String, dynamic>> _completeGoogleSession(
    User? user, {
    String? fallbackName,
  }) async {
    if (user == null) {
      return {'success': false, 'message': 'Google sign-in failed'};
    }

    await _upsertProfileFromGoogleUser(user, fallbackName: fallbackName);

    final displayName = _googleDisplayName(user, fallbackName: fallbackName);

    return {
      'success': true,
      'message': 'Signed in with Google!',
      'user': AppUser(id: user.id, email: user.email, displayName: displayName),
    };
  }

  String _googleDisplayName(User user, {String? fallbackName}) {
    final meta = user.userMetadata ?? {};
    final fromMeta = meta['full_name'] as String? ?? meta['name'] as String?;
    if (fromMeta != null && fromMeta.trim().isNotEmpty) return fromMeta.trim();
    if (fallbackName != null && fallbackName.trim().isNotEmpty) {
      return fallbackName.trim();
    }
    final email = user.email;
    if (email != null && email.contains('@')) return email.split('@').first;
    return 'User';
  }

  Future<void> _upsertProfileFromGoogleUser(
    User user, {
    String? fallbackName,
  }) async {
    await _upsertProfile(
      uid: user.id,
      fullName: _googleDisplayName(user, fallbackName: fallbackName),
      email: user.email ?? '',
    );
  }

  Future<void> signOut() async {
    _sessionExpiryTimer?.cancel();
    _sessionExpiryTimer = null;

    if (GoogleAuthConfig.useNativeGoogleSignIn) {
      try {
        final googleSignIn = GoogleSignIn(
          clientId: !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS
              ? GoogleAuthConfig.effectiveIosClientId
              : null,
          serverClientId: GoogleAuthConfig.effectiveWebClientId,
        );
        await googleSignIn.signOut();
      } catch (_) {}
    }
    await _client.auth.signOut(scope: SignOutScope.local);
  }

  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email.trim());
      return {'success': true, 'message': 'Password reset email sent'};
    } on AuthException catch (e) {
      String message = e.message.isNotEmpty
          ? e.message
          : 'Failed to send reset email';
      return {'success': false, 'message': message};
    }
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final res = await _client
          .from('profiles')
          .select()
          .eq('id', uid)
          .maybeSingle();
      if (res != null) {
        return Map<String, dynamic>.from(res as Map);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _upsertProfile({
    required String uid,
    required String fullName,
    required String email,
  }) async {
    try {
      await _client.from('profiles').upsert({
        'id': uid,
        'full_name': fullName,
        'email': email,
        'last_login': DateTime.now().toIso8601String(),
      }, onConflict: 'id');
    } catch (_) {}
  }
}
