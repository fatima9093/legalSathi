import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:front_end/l10n/app_localizations.dart';

/// Shown on web after email reset — tells user to close this tab and use the main app.
class PasswordResetDoneScreen extends StatelessWidget {
  const PasswordResetDoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF00401A), size: 80),
              const SizedBox(height: 24),
              Text(
                loc.passwordResetSuccessTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00401A),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                kIsWeb ? loc.passwordResetCloseTabMessage : loc.passwordResetSuccessMessage,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700, height: 1.5),
              ),
              if (kIsWeb) ...[
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00401A).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFF00401A)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          loc.passwordResetCloseTabHint,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade800,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
