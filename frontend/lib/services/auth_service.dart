import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Simple user representation (replaces Firebase User in UI).
class AppUser {
  final String id;
  final String? email;
  final String? displayName;

  AppUser({required this.id, this.email, this.displayName});
}

class AuthService {
  SupabaseClient get _client => Supabase.instance.client;

  /// Prefer session?.user so we use the same object the client considers "current".
  User? get _authUser =>
      _client.auth.currentSession?.user ?? _client.auth.currentUser;

  AppUser? get currentUser {
    final user = _authUser;
    if (user == null) return null;
    final meta = user.userMetadata;
    final name = meta?['full_name'] as String? ?? meta?['full_name']?.toString();
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
    final fromAuth = _client.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      if (user == null) return null;
      final meta = user.userMetadata;
      final name = meta?['full_name'] as String? ?? meta?['full_name']?.toString();
      return AppUser(
        id: user.id,
        email: user.email,
        displayName: name?.isNotEmpty == true ? name : null,
      );
    });
    return Stream.fromIterable([current]).asyncExpand((_) => fromAuth);
  }

  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
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
        return {
          'success': true,
          'message': 'Account created successfully!',
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
          message = e.message.isNotEmpty ? e.message : 'An error occurred. Please try again';
      }
      return {'success': false, 'message': message};
    } catch (e, stackTrace) {
      debugPrint('SignUp error: $e');
      debugPrint('Stack: $stackTrace');
      final String message = e.toString().contains('SocketException') ||
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
          fullName: (user.userMetadata?['full_name'] ?? user.email?.split('@').first) as String? ?? '',
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
        message = 'Please confirm your email first. Check your inbox for the link from Supabase, then try signing in again.';
      } else if (msg.contains('invalid login credentials')) {
        message = 'Incorrect password or email. Check both and try again, or use "Forgot password".';
      } else if (msg.contains('invalid email')) {
        message = 'Please enter a valid email address';
      } else {
        message = e.message.isNotEmpty ? e.message : 'Failed to sign in. Please try again';
      }
      return {'success': false, 'message': message};
    } catch (e, stackTrace) {
      debugPrint('SignIn error: $e');
      debugPrint('Stack: $stackTrace');
      final String message = e.toString().contains('SocketException') ||
              e.toString().contains('network')
          ? 'No internet connection. Please check your network and try again'
          : 'Sign in failed. Please check your email, password, and internet connection';
      return {'success': false, 'message': message};
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email.trim());
      return {
        'success': true,
        'message': 'Password reset email sent',
      };
    } on AuthException catch (e) {
      String message = e.message.isNotEmpty ? e.message : 'Failed to send reset email';
      return {'success': false, 'message': message};
    }
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final res = await _client.from('profiles').select().eq('id', uid).maybeSingle();
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
