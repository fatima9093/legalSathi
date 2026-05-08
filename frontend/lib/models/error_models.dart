/// Error types for the application
enum ErrorType {
  network, // Network connectivity error
  timeout, // Request timeout
  badRequest, // 400 Bad Request
  unauthorized, // 401 Unauthorized
  forbidden, // 403 Forbidden
  notFound, // 404 Not Found
  serverError, // 5xx Server errors
  unknown, // Unknown error
  nullResponse, // Null or empty response
  parseError, // JSON parse error
  cancelled, // Request cancelled
  invalidData, // Invalid data format
}

/// Custom error class
class AppError {
  final ErrorType type;
  final String message;
  final String? details;
  final dynamic originalError;
  final StackTrace? stackTrace;
  final int? statusCode;

  AppError({
    required this.type,
    required this.message,
    this.details,
    this.originalError,
    this.stackTrace,
    this.statusCode,
  });

  /// User-friendly error message
  String get userMessage {
    switch (type) {
      case ErrorType.network:
        return 'No internet connection. Please check your network.';
      case ErrorType.timeout:
        return 'Request took too long. Please try again.';
      case ErrorType.badRequest:
        return 'Invalid request. Please check your input.';
      case ErrorType.unauthorized:
        return 'Please sign in again.';
      case ErrorType.forbidden:
        return 'You do not have permission to perform this action.';
      case ErrorType.notFound:
        return 'The requested resource was not found.';
      case ErrorType.serverError:
        return 'Server error. Please try again later.';
      case ErrorType.nullResponse:
        return 'Empty response received. Please try again.';
      case ErrorType.parseError:
        return 'Error processing response. Please try again.';
      case ErrorType.cancelled:
        return 'Request was cancelled.';
      case ErrorType.invalidData:
        return 'Invalid data format. Please try again.';
      case ErrorType.unknown:
        return 'Something went wrong. Please try again.';
    }
  }

  /// Log friendly format
  String get logMessage {
    final buffer = StringBuffer();
    buffer.writeln('=== App Error ===');
    buffer.writeln('Type: $type');
    buffer.writeln('Message: $message');
    if (details != null) buffer.writeln('Details: $details');
    if (statusCode != null) buffer.writeln('Status Code: $statusCode');
    if (originalError != null) buffer.writeln('Original Error: $originalError');
    return buffer.toString();
  }

  @override
  String toString() => 'AppError(type: $type, message: $message)';
}

/// Result wrapper for API calls
class ApiResult<T> {
  final bool isSuccess;
  final T? data;
  final AppError? error;

  ApiResult.success(this.data) : isSuccess = true, error = null;

  ApiResult.failure(this.error) : isSuccess = false, data = null;

  /// Map result to another type
  ApiResult<U> map<U>(U Function(T) transform) {
    if (isSuccess && data != null) {
      try {
        return ApiResult<U>.success(transform(data as T));
      } catch (e, st) {
        return ApiResult<U>.failure(
          AppError(
            type: ErrorType.parseError,
            message: 'Failed to transform result',
            details: e.toString(),
            originalError: e,
            stackTrace: st,
          ),
        );
      }
    }
    return ApiResult<U>.failure(error!);
  }

  /// Execute callback on success
  void onSuccess(void Function(T) callback) {
    if (isSuccess && data != null) {
      callback(data as T);
    }
  }

  /// Execute callback on failure
  void onFailure(void Function(AppError) callback) {
    if (!isSuccess && error != null) {
      callback(error!);
    }
  }

  /// Get data or null
  T? getOrNull() => data;

  /// Get error or null
  AppError? getErrorOrNull() => error;
}
