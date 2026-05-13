import 'package:flutter/material.dart';
import 'package:front_end/services/auth_service.dart';
import 'package:front_end/create_account/signin_screen.dart';

/// Service to handle guest user restrictions
/// Guests can only explore the app and cannot use any services
class GuestRestrictionService {
  static final GuestRestrictionService _instance =
      GuestRestrictionService._internal();

  factory GuestRestrictionService() {
    return _instance;
  }

  GuestRestrictionService._internal();

  final AuthService _authService = AuthService();

  /// Check if user is guest (logged out)
  bool isGuest() {
    return _authService.currentUser == null;
  }

  /// Check if user is authenticated (logged in)
  bool isAuthenticated() {
    return _authService.currentUser != null;
  }

  /// Show sign-in required dialog for guest users
  void showSignInRequired(
    BuildContext context, {
    required String title,
    required String message,
    String? buttonText,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            const Icon(Icons.lock_outline, color: Color(0xFF00401A)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: Color(0xFF666666)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sign in to unlock this feature',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Continue Exploring',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SignInScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00401A),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              buttonText ?? 'Sign In',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Check and restrict: show dialog if guest, return true if authenticated
  Future<bool> checkAndRestrict(
    BuildContext context, {
    required String feature,
    String? customMessage,
  }) async {
    if (isGuest()) {
      showSignInRequired(
        context,
        title: 'Sign In Required',
        message:
            customMessage ??
            'This feature is only available for signed-in users. $feature requires an account.',
        buttonText: 'Create Account or Sign In',
      );
      return false;
    }
    return true;
  }

  /// Restrict action: prevents execution for guests
  bool restrictAction({
    required BuildContext context,
    required String featureName,
    String? customMessage,
  }) {
    if (isGuest()) {
      showSignInRequired(
        context,
        title: 'Account Required',
        message:
            customMessage ??
            '$featureName is only available for signed-in users. Create an account to save your work and access all features.',
      );
      return false;
    }
    return true;
  }

  /// Get stream of auth changes to update UI
  Stream<AppUser?> get authStateChanges => _authService.authStateChanges;

  /// Get current user
  AppUser? get currentUser => _authService.currentUser;
}
