import 'package:flutter/material.dart';
import 'package:front_end/home_screen.dart';
import 'package:front_end/services/auth_service.dart';

/// After email or Google auth succeeds, wait for session and go home.
Future<void> navigateToHomeAfterAuth(
  BuildContext context,
  AuthService authService, {
  bool needsVerification = false,
}) async {
  if (!context.mounted) return;
  if (needsVerification) return;

  await authService.authStateChanges
      .where((user) => user != null)
      .first
      .timeout(const Duration(seconds: 5), onTimeout: () => null);

  if (!context.mounted) return;

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const HomeScreen()),
  );
}

/// Shared Google sign-in handler for login and sign-up screens.
Future<void> handleGoogleSignIn(
  BuildContext context, {
  required AuthService authService,
  required ValueChanged<bool> setLoading,
  required bool Function() isMounted,
}) async {
  setLoading(true);

  final result = await authService.signInWithGoogle();

  setLoading(false);

  if (!isMounted()) return;
  final messenger = ScaffoldMessenger.of(context);

  if (result['success'] == true) {
    if (result['pending'] == true) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(result['message'] as String? ?? 'Complete sign-in in the browser'),
          backgroundColor: Colors.blue,
        ),
      );
      return;
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(result['message'] as String? ?? 'Signed in with Google!'),
        backgroundColor: Colors.green,
      ),
    );

    await navigateToHomeAfterAuth(context, authService);
  } else {
    messenger.showSnackBar(
      SnackBar(
        content: Text(result['message'] as String? ?? 'Google sign-in failed'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
