import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:front_end/create_account/change_password_screen.dart';
import 'package:front_end/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Handles Supabase auth callbacks (Google OAuth, password-reset email links).
class SupabaseAuthCallbackHandler {
  static GlobalKey<NavigatorState>? _navigatorKey;
  static StreamSubscription<AuthState>? _authSubscription;
  static bool _pendingPasswordRecovery = false;
  static bool _changePasswordScreenOpen = false;
  static bool _appStarted = false;
  static bool _openedFromAuthEmailLink = false;

  static bool get hasPendingPasswordRecovery => _pendingPasswordRecovery;

  static void clearPendingPasswordRecovery() {
    _pendingPasswordRecovery = false;
    _openedFromAuthEmailLink = false;
  }

  static void markAppStarted() {
    _appStarted = true;
  }

  static Widget? _cachedInitialScreen;

  /// First screen after app launch — skip splash when opening a reset link.
  static Widget initialScreen() {
    if (_cachedInitialScreen != null) return _cachedInitialScreen!;

    final showReset =
        _pendingPasswordRecovery || _openedFromAuthEmailLink;
    if (showReset) {
      _changePasswordScreenOpen = true;
    }

    return _cachedInitialScreen ??= showReset
        ? const ChangePasswordScreen(fromEmailReset: true)
        : const SplashScreen();
  }

  static Future<void> init({
    required GlobalKey<NavigatorState> navigatorKey,
  }) async {
    _navigatorKey = navigatorKey;

    await _authSubscription?.cancel();
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      _onAuthStateChange,
    );

    if (kIsWeb) {
      final uri = Uri.base;
      if (isPasswordRecoveryUrl(uri)) {
        _pendingPasswordRecovery = true;
        _openedFromAuthEmailLink = true;
      } else if (_looksLikeAuthCallback(uri)) {
        _openedFromAuthEmailLink = true;
      }
      await _completeWebAuthCallback(uri);
    }
  }

  static Future<void> dispose() async {
    await _authSubscription?.cancel();
    _authSubscription = null;
    _navigatorKey = null;
  }

  static Future<void> _completeWebAuthCallback(Uri uri) async {
    if (!_looksLikeAuthCallback(uri)) return;

    try {
      await Supabase.instance.client.auth.getSessionFromUrl(uri);
      debugPrint('Supabase web auth callback completed');
    } catch (e) {
      debugPrint('Supabase web getSessionFromUrl failed: $e');
    }

    if (isPasswordRecoveryUrl(uri)) {
      _pendingPasswordRecovery = true;
      _openedFromAuthEmailLink = true;
    }
  }

  static void _onAuthStateChange(AuthState data) {
    if (data.event == AuthChangeEvent.passwordRecovery) {
      _pendingPasswordRecovery = true;
      _openedFromAuthEmailLink = true;
      if (_appStarted) {
        _openChangePasswordScreen(fromEmailReset: true);
      }
    }
  }

  static void _openChangePasswordScreen({required bool fromEmailReset}) {
    if (_changePasswordScreenOpen) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = _navigatorKey?.currentState;
      if (navigator == null) return;

      _changePasswordScreenOpen = true;
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => ChangePasswordScreen(fromEmailReset: fromEmailReset),
        ),
        (route) => false,
      );
    });
  }

  static bool isPasswordRecoveryUrl(Uri uri) {
    if (uri.queryParameters['type'] == 'recovery') return true;
    if (uri.fragment.contains('type=recovery')) return true;
    final fragmentParams = Uri.splitQueryString(uri.fragment);
    return fragmentParams['type'] == 'recovery';
  }

  static bool _looksLikeAuthCallback(Uri uri) {
    final value = uri.toString();
    return uri.queryParameters.containsKey('code') ||
        isPasswordRecoveryUrl(uri) ||
        uri.fragment.contains('access_token') ||
        value.contains('login-callback');
  }

  static void markChangePasswordScreenClosed() {
    _changePasswordScreenOpen = false;
  }
}
