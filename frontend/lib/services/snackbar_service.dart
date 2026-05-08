import 'package:flutter/material.dart';
import 'package:front_end/models/error_models.dart';

/// SnackBar utility for displaying messages to users
class SnackBarService {
  static final SnackBarService _instance = SnackBarService._internal();

  factory SnackBarService() {
    return _instance;
  }

  SnackBarService._internal();

  /// Show error SnackBar with user-friendly message
  static void showError(
    BuildContext context,
    AppError error, {
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    _showSnackBar(
      context,
      message: error.userMessage,
      backgroundColor: Colors.red,
      duration: duration,
      action: action,
      icon: Icons.error_outline,
    );
  }

  /// Show success SnackBar
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
    SnackBarAction? action,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: Colors.green,
      duration: duration,
      action: action,
      icon: Icons.check_circle_outline,
    );
  }

  /// Show warning SnackBar
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: Colors.orange,
      duration: duration,
      action: action,
      icon: Icons.warning_outlined,
    );
  }

  /// Show info SnackBar
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: Colors.blue,
      duration: duration,
      action: action,
      icon: Icons.info_outline,
    );
  }

  /// Generic SnackBar display
  static void _showSnackBar(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required Duration duration,
    SnackBarAction? action,
    IconData? icon,
  }) {
    final scaffold = ScaffoldMessenger.of(context);

    // Remove existing snackbars
    scaffold.clearSnackBars();

    // Show new snackbar
    scaffold.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: action,
      ),
    );
  }

  /// Show loading SnackBar (doesn't auto-dismiss)
  static void showLoading(BuildContext context, String message) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: Colors.grey.shade700,
      duration: const Duration(days: 1), // Stays until dismissed
      icon: null,
    );
  }

  /// Dismiss current SnackBar
  static void dismiss(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
  }
}

/// Dialog utility for showing error details
class ErrorDialogService {
  /// Show detailed error dialog
  static void showErrorDialog(
    BuildContext context,
    AppError error, {
    VoidCallback? onRetry,
    String? title,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 12),
            Text(title ?? 'Error'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              error.userMessage,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            if (error.details != null) ...[
              const SizedBox(height: 12),
              Text(
                'Details: ${error.details}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ],
        ),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onRetry();
              },
              child: const Text('Retry'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Show confirmation dialog with error context
  static Future<bool?> showErrorConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Yes',
    String cancelLabel = 'No',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_outlined, color: Colors.orange),
            const SizedBox(width: 12),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelLabel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              confirmLabel,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
