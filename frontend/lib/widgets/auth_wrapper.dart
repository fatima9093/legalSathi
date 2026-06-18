import 'package:flutter/material.dart';
import 'package:front_end/services/auth_service.dart';
import 'package:front_end/onboarding_screen.dart';
import 'package:front_end/home_screen.dart';
import 'package:front_end/create_account/signin_screen.dart';
import 'package:front_end/create_account/auth_navigation_helper.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    return StreamBuilder<AppUser?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF00401A)),
            ),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          return const HomeScreen();
        }
        // User not logged in - check if onboarding completed
        return FutureBuilder<bool>(
          future: hasCompletedOnboarding(),
          builder: (context, onboardingSnapshot) {
            if (onboardingSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(color: Color(0xFF00401A)),
                ),
              );
            }
            // If onboarding completed, show SignIn; otherwise show Onboarding
            if (onboardingSnapshot.data == true) {
              return const SignInScreen();
            }
            return const OnboardingScreen();
          },
        );
      },
    );
  }
}
