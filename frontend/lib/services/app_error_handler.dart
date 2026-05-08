import 'package:flutter/material.dart';
import 'package:front_end/models/error_models.dart';
import 'package:front_end/services/error_handler_service.dart';
import 'package:front_end/services/snackbar_service.dart';

/// Global error handler for the entire app
class AppErrorHandler {
  static final AppErrorHandler _instance = AppErrorHandler._internal();
  static BuildContext? _lastContext;

  factory AppErrorHandler() {
    return _instance;
  }

  AppErrorHandler._internal();

  final ErrorHandlerService _errorService = ErrorHandlerService();

  /// Initialize error handling (call in main.dart)
  void initialize(BuildContext context) {
    _lastContext = context;

    // Register default error handler
    _errorService.addErrorListener(_handleErrorGlobally);

    // Handle uncaught exceptions
    FlutterError.onError = _handleFlutterError;
  }

  /// Update context when it changes
  void setContext(BuildContext context) {
    _lastContext = context;
  }

  /// Handle Flutter framework errors
  void _handleFlutterError(FlutterErrorDetails details) {
    debugPrintStack(stackTrace: details.stack, label: 'Flutter Error');

    final appError = AppError(
      type: ErrorType.unknown,
      message: 'Framework error: ${details.exceptionAsString()}',
      details: details.context?.toString(),
      originalError: details.exception,
      stackTrace: details.stack,
    );

    _handleErrorGlobally(appError);
  }

  /// Global error handler callback
  void _handleErrorGlobally(AppError error) {
    // Log error
    _logError(error);

    // Show UI feedback if context is available
    if (_lastContext != null && _lastContext!.mounted) {
      _showErrorUI(error);
    }
  }

  /// Log error to console
  void _logError(AppError error) {
    final buffer = StringBuffer();
    buffer.writeln('');
    buffer.writeln('════════════════════════════════════════');
    buffer.writeln('⚠️  ERROR LOG');
    buffer.writeln('════════════════════════════════════════');
    buffer.writeln('Type: ${error.type}');
    buffer.writeln('Message: ${error.message}');
    if (error.details != null) buffer.writeln('Details: ${error.details}');
    if (error.statusCode != null) {
      buffer.writeln('Status Code: ${error.statusCode}');
    }
    if (error.originalError != null) {
      buffer.writeln('Original Error: ${error.originalError}');
    }
    buffer.writeln('════════════════════════════════════════');
    buffer.writeln('');

    debugPrint(buffer.toString());
  }

  /// Show error UI based on error type
  void _showErrorUI(AppError error) {
    if (_lastContext == null || !_lastContext!.mounted) return;

    switch (error.type) {
      case ErrorType.unauthorized:
        // Show login screen or redirect
        _showUnauthorizedUI();
        break;

      case ErrorType.network:
        // Show network error UI
        SnackBarService.showError(
          _lastContext!,
          error,
          duration: const Duration(seconds: 5),
        );
        break;

      case ErrorType.timeout:
        // Show timeout error with retry option
        SnackBarService.showWarning(
          _lastContext!,
          'Request timed out. Please try again.',
        );
        break;

      case ErrorType.serverError:
        // Show server error
        SnackBarService.showError(
          _lastContext!,
          error,
          duration: const Duration(seconds: 5),
        );
        break;

      default:
        // Show generic error
        SnackBarService.showError(_lastContext!, error);
    }
  }

  /// Handle unauthorized access (401)
  void _showUnauthorizedUI() {
    if (_lastContext == null || !_lastContext!.mounted) return;

    // You can implement custom unauthorized handling here
    // For example, redirect to login, show dialog, etc.
    SnackBarService.showWarning(
      _lastContext!,
      'Your session has expired. Please sign in again.',
    );
  }

  /// Show error details dialog (for debugging)
  void showErrorDetailsDialog(AppError error) {
    if (_lastContext == null || !_lastContext!.mounted) return;

    showDialog(
      context: _lastContext!,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Error Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Type', error.type.toString()),
              _buildDetailRow('Message', error.message),
              if (error.details != null)
                _buildDetailRow('Details', error.details!),
              if (error.statusCode != null)
                _buildDetailRow('Status Code', error.statusCode.toString()),
              if (error.originalError != null)
                _buildDetailRow(
                  'Original Error',
                  error.originalError.toString(),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Build detail row for error dialog
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.maxFinite,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(value, style: const TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  /// Clear all error listeners
  void dispose() {
    _errorService.clear();
    _lastContext = null;
  }
}

/// Widget to initialize error handling
class ErrorHandlerInitializer extends StatefulWidget {
  final Widget child;

  const ErrorHandlerInitializer({super.key, required this.child});

  @override
  State<ErrorHandlerInitializer> createState() =>
      _ErrorHandlerInitializerState();
}

class _ErrorHandlerInitializerState extends State<ErrorHandlerInitializer>
    with WidgetsBindingObserver {
  late AppErrorHandler _errorHandler;

  @override
  void initState() {
    super.initState();
    _errorHandler = AppErrorHandler();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _errorHandler.initialize(context);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _errorHandler.setContext(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _errorHandler.dispose();
    super.dispose();
  }
}
