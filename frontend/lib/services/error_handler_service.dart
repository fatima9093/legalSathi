import 'package:flutter/foundation.dart';
import 'package:front_end/models/error_models.dart';

typedef ErrorCallback = void Function(AppError error);
typedef RetryCallback = Future<T> Function<T>();

/// Global error handler service
class ErrorHandlerService {
  static final ErrorHandlerService _instance = ErrorHandlerService._internal();

  factory ErrorHandlerService() {
    return _instance;
  }

  ErrorHandlerService._internal();

  // Error callbacks
  final List<ErrorCallback> _errorCallbacks = [];

  /// Register a callback to be called when an error occurs
  void addErrorListener(ErrorCallback callback) {
    _errorCallbacks.add(callback);
  }

  /// Remove an error callback
  void removeErrorListener(ErrorCallback callback) {
    _errorCallbacks.remove(callback);
  }

  /// Handle error and notify listeners
  void handleError(AppError error) {
    debugPrint(error.logMessage);

    // Call all registered listeners
    for (final callback in _errorCallbacks) {
      try {
        callback(error);
      } catch (e) {
        debugPrint('Error in error callback: $e');
      }
    }
  }

  /// Parse different types of errors and return AppError
  AppError parseError(
    dynamic error, {
    StackTrace? stackTrace,
    int? statusCode,
    String? customMessage,
  }) {
    if (error is AppError) {
      return error;
    }

    // Handle specific error types
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('socket') ||
        errorString.contains('connection refused')) {
      return AppError(
        type: ErrorType.network,
        message: customMessage ?? 'Network connection failed',
        details: error.toString(),
        originalError: error,
        stackTrace: stackTrace,
        statusCode: statusCode,
      );
    }

    if (errorString.contains('timeout')) {
      return AppError(
        type: ErrorType.timeout,
        message: customMessage ?? 'Request timeout',
        details: error.toString(),
        originalError: error,
        stackTrace: stackTrace,
        statusCode: statusCode,
      );
    }

    if (errorString.contains('null')) {
      return AppError(
        type: ErrorType.nullResponse,
        message: customMessage ?? 'Empty response received',
        details: error.toString(),
        originalError: error,
        stackTrace: stackTrace,
        statusCode: statusCode,
      );
    }

    if (statusCode != null) {
      if (statusCode == 400) {
        return AppError(
          type: ErrorType.badRequest,
          message: customMessage ?? 'Invalid request',
          details: error.toString(),
          originalError: error,
          stackTrace: stackTrace,
          statusCode: statusCode,
        );
      }
      if (statusCode == 401) {
        return AppError(
          type: ErrorType.unauthorized,
          message: customMessage ?? 'Unauthorized access',
          details: error.toString(),
          originalError: error,
          stackTrace: stackTrace,
          statusCode: statusCode,
        );
      }
      if (statusCode == 403) {
        return AppError(
          type: ErrorType.forbidden,
          message: customMessage ?? 'Access forbidden',
          details: error.toString(),
          originalError: error,
          stackTrace: stackTrace,
          statusCode: statusCode,
        );
      }
      if (statusCode == 404) {
        return AppError(
          type: ErrorType.notFound,
          message: customMessage ?? 'Resource not found',
          details: error.toString(),
          originalError: error,
          stackTrace: stackTrace,
          statusCode: statusCode,
        );
      }
      if (statusCode >= 500) {
        return AppError(
          type: ErrorType.serverError,
          message: customMessage ?? 'Server error occurred',
          details: error.toString(),
          originalError: error,
          stackTrace: stackTrace,
          statusCode: statusCode,
        );
      }
    }

    // Default to unknown error
    return AppError(
      type: ErrorType.unknown,
      message: customMessage ?? error.toString(),
      details: error.toString(),
      originalError: error,
      stackTrace: stackTrace,
      statusCode: statusCode,
    );
  }

  /// Clear all error listeners
  void clear() {
    _errorCallbacks.clear();
  }

  /// Get all registered listeners count
  int get listenerCount => _errorCallbacks.length;
}

/// Retry configuration
class RetryConfig {
  final int maxAttempts;
  final Duration initialDelay;
  final double backoffMultiplier;
  final Duration maxDelay;

  const RetryConfig({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(milliseconds: 500),
    this.backoffMultiplier = 1.5,
    this.maxDelay = const Duration(seconds: 10),
  });

  /// Get delay for attempt number
  Duration getDelay(int attemptNumber) {
    if (attemptNumber <= 0) return Duration.zero;

    final exponentialDelay =
        initialDelay.inMilliseconds *
        (backoffMultiplier * (attemptNumber - 1)).toInt();
    final delay = Duration(milliseconds: exponentialDelay.toInt());

    // Cap at max delay
    return delay > maxDelay ? maxDelay : delay;
  }
}

/// Safe API call wrapper with retry logic and timeout
class SafeApiCallWrapper {
  final ErrorHandlerService _errorHandler = ErrorHandlerService();
  final RetryConfig _retryConfig;
  final Duration _defaultTimeout;

  SafeApiCallWrapper({
    RetryConfig? retryConfig,
    Duration defaultTimeout = const Duration(seconds: 30),
  }) : _retryConfig = retryConfig ?? const RetryConfig(),
       _defaultTimeout = defaultTimeout;

  /// Execute API call with retry logic and timeout
  Future<ApiResult<T>> call<T>(
    Future<T> Function() apiCall, {
    Duration? timeout,
    RetryConfig? retryConfig,
    String? errorMessage,
    bool silentError = false,
  }) async {
    final config = retryConfig ?? _retryConfig;
    final finalTimeout = timeout ?? _defaultTimeout;
    int attempt = 0;

    while (attempt < config.maxAttempts) {
      attempt++;
      try {
        debugPrint('API Call Attempt $attempt/${config.maxAttempts}');

        // Execute with timeout
        final result = await apiCall().timeout(
          finalTimeout,
          onTimeout: () => throw TimeoutException('API request timeout'),
        );

        // Check for null response
        if (result == null) {
          throw NullResponseException('Null response received');
        }

        return ApiResult<T>.success(result);
      } catch (error, stackTrace) {
        debugPrint('Error on attempt $attempt: $error');

        // Check if we should retry
        bool shouldRetry = attempt < config.maxAttempts && _shouldRetry(error);

        if (shouldRetry) {
          final delay = config.getDelay(attempt);
          debugPrint('Retrying after ${delay.inMilliseconds}ms...');
          await Future.delayed(delay);
          continue;
        }

        // Parse error
        final appError = _errorHandler.parseError(
          error,
          stackTrace: stackTrace,
          customMessage: errorMessage,
        );

        // Notify error handler
        if (!silentError) {
          _errorHandler.handleError(appError);
        }

        return ApiResult<T>.failure(appError);
      }
    }

    // Should not reach here
    final error = AppError(
      type: ErrorType.unknown,
      message: errorMessage ?? 'Max retry attempts exceeded',
    );
    _errorHandler.handleError(error);
    return ApiResult<T>.failure(error);
  }

  /// Execute multiple API calls in parallel with error handling
  Future<List<ApiResult<T>>> callMultiple<T>(
    List<Future<T> Function()> apiCalls, {
    Duration? timeout,
    bool continueOnError = true,
  }) async {
    final futures = apiCalls
        .map(
          (apiCall) =>
              call(apiCall, timeout: timeout, silentError: continueOnError),
        )
        .toList();

    return Future.wait(futures);
  }

  /// Check if error is retryable
  bool _shouldRetry(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Network errors are retryable
    if (errorString.contains('socket') ||
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('temporary failure')) {
      return true;
    }

    // Server errors (5xx) are retryable
    if (error is HttpServerErrorException) {
      return true;
    }

    return false;
  }
}

/// Custom exception for null response
class NullResponseException implements Exception {
  final String message;
  NullResponseException(this.message);

  @override
  String toString() => message;
}

/// Custom exception for HTTP server errors
class HttpServerErrorException implements Exception {
  final int statusCode;
  final String message;

  HttpServerErrorException({required this.statusCode, required this.message});

  @override
  String toString() => 'HttpServerError($statusCode): $message';
}

/// Custom exception for timeout
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}
