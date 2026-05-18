import 'package:flutter/material.dart';
import 'package:front_end/config/api_config.dart';
import 'package:front_end/models/error_models.dart';
import 'package:front_end/services/error_handler_service.dart';
import 'package:front_end/services/http_client_wrapper.dart';
import 'package:front_end/services/snackbar_service.dart';

/// Base API service with error handling
class ApiService {
  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  final ErrorHandlerService _errorHandler = ErrorHandlerService();

  static String get baseUrl => ApiConfig.apiBaseUrl;

  /// Execute API call and show appropriate UI feedback
  Future<T?> executeWithUI<T>(
    BuildContext context,
    Future<ApiResult<T>> Function() apiCall, {
    String? loadingMessage,
    String? successMessage,
    bool showSuccess = true,
    bool showError = true,
    VoidCallback? onSuccess,
    VoidCallback? onError,
  }) async {
    try {
      // Show loading indicator if message provided
      if (loadingMessage != null) {
        SnackBarService.showLoading(context, loadingMessage);
      }

      // Execute API call
      final result = await apiCall();

      // Dismiss loading
      if (loadingMessage != null && context.mounted) {
        SnackBarService.dismiss(context);
      }

      if (result.isSuccess) {
        if (!context.mounted) return result.data;

        // Show success message
        if (showSuccess && successMessage != null) {
          SnackBarService.showSuccess(context, successMessage);
        }

        // Execute success callback
        onSuccess?.call();

        return result.data;
      } else {
        if (!context.mounted) return null;

        // Show error message
        if (showError && result.error != null) {
          SnackBarService.showError(context, result.error!);
        }

        // Execute error callback
        onError?.call();

        return null;
      }
    } catch (e) {
      if (!context.mounted) return null;

      // Handle unexpected errors
      final error = _errorHandler.parseError(e);
      if (showError) {
        SnackBarService.showError(context, error);
      }

      onError?.call();
      return null;
    }
  }

  /// Safe wrapper for API calls that handles errors without UI feedback
  Future<ApiResult<T>> executeSilent<T>(
    Future<ApiResult<T>> Function() apiCall,
  ) async {
    try {
      return await apiCall();
    } catch (e, st) {
      final error = _errorHandler.parseError(e, stackTrace: st);
      _errorHandler.handleError(error);
      return ApiResult<T>.failure(error);
    }
  }

  /// Perform API call with retry until success (useful for critical operations)
  Future<ApiResult<T>> executeWithRetry<T>(
    Future<ApiResult<T>> Function() apiCall, {
    int maxAttempts = 5,
    Duration delay = const Duration(seconds: 2),
  }) async {
    for (int i = 0; i < maxAttempts; i++) {
      final result = await apiCall();
      if (result.isSuccess) {
        return result;
      }

      if (i < maxAttempts - 1) {
        await Future.delayed(delay);
      }
    }

    return ApiResult<T>.failure(
      AppError(
        type: ErrorType.unknown,
        message: 'Operation failed after $maxAttempts attempts',
      ),
    );
  }
}

/// Extension methods for easier error handling in widgets
extension ApiResultExtension<T> on ApiResult<T> {
  /// Show error snackbar if failed
  void showErrorIfFailed(BuildContext context) {
    if (!isSuccess && error != null && context.mounted) {
      SnackBarService.showError(context, error!);
    }
  }

  /// Show success snackbar if successful
  void showSuccessIfSuccess(BuildContext context, String message) {
    if (isSuccess && context.mounted) {
      SnackBarService.showSuccess(context, message);
    }
  }

  /// Combine error and success messages
  void showMessage(BuildContext context, String successMessage) {
    if (!context.mounted) return;

    if (isSuccess) {
      SnackBarService.showSuccess(context, successMessage);
    } else if (error != null) {
      SnackBarService.showError(context, error!);
    }
  }
}

/// Example API service for specific endpoints
class ComplaintApiService {
  static final ComplaintApiService _instance = ComplaintApiService._internal();

  factory ComplaintApiService() {
    return _instance;
  }

  ComplaintApiService._internal();

  final HttpClientWrapper _httpClient = HttpClientWrapper();

  /// Submit complaint with error handling and retry
  Future<ApiResult<Map<String, dynamic>>> submitComplaint({
    required String complaintId,
    required Map<String, dynamic> data,
  }) {
    return _httpClient.post(
      '${ApiService.baseUrl}/complaints/$complaintId/submit',
      body: data,
      deserialize: (json) => Map<String, dynamic>.from(json as Map),
      errorMessage: 'Failed to submit complaint',
      retryConfig: const RetryConfig(maxAttempts: 3),
    );
  }

  /// Get user complaints with error handling
  Future<ApiResult<List<Map<String, dynamic>>>> getUserComplaints({
    required String userId,
  }) {
    return _httpClient.get(
      '${ApiService.baseUrl}/user/$userId/complaints',
      deserialize: (json) {
        final list = json as List;
        return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      },
      errorMessage: 'Failed to fetch complaints',
    );
  }

  /// Validate complaint with error handling
  Future<ApiResult<Map<String, dynamic>>> validateComplaint({
    required String complaintId,
    required Map<String, dynamic> data,
  }) {
    return _httpClient.post(
      '${ApiService.baseUrl}/complaints/$complaintId/validate',
      body: data,
      deserialize: (json) => Map<String, dynamic>.from(json as Map),
      errorMessage: 'Failed to validate complaint',
    );
  }
}

/// Example: Reusable API call pattern
class ExampleApiUsage {
  /// Example 1: Simple GET request with UI feedback
  static Future<void> fetchDataExample(BuildContext context) async {
    final apiService = ApiService();
    final httpClient = HttpClientWrapper();

    final data = await apiService.executeWithUI(
      context,
      () => httpClient.get(
        '${ApiService.baseUrl}/example',
        deserialize: (json) => json as Map<String, dynamic>,
      ),
      loadingMessage: 'Loading data...',
      successMessage: 'Data loaded successfully',
      showSuccess: true,
    );

    if (data != null) {
      // Handle successful response
      debugPrint('Data: $data');
    }
  }

  /// Example 2: POST request with custom retry config
  static Future<void> submitDataExample(
    BuildContext context,
    Map<String, dynamic> payload,
  ) async {
    final httpClient = HttpClientWrapper();

    final result = await httpClient.post(
      '${ApiService.baseUrl}/submit',
      body: payload,
      deserialize: (json) => json as Map<String, dynamic>,
      retryConfig: const RetryConfig(
        maxAttempts: 5,
        initialDelay: Duration(milliseconds: 500),
        backoffMultiplier: 2.0,
      ),
      errorMessage: 'Failed to submit data',
    );

    if (context.mounted) {
      result.showMessage(context, 'Data submitted successfully');
    }
  }

  /// Example 3: Multiple parallel API calls
  static Future<void> fetchMultipleExample(BuildContext context) async {
    final httpClient = HttpClientWrapper();
    final results = <ApiResult<dynamic>>[];

    // Execute multiple API calls
    for (final call in [
      () => httpClient.get(
        '${ApiService.baseUrl}/data1',
        deserialize: (json) => json,
      ),
      () => httpClient.get(
        '${ApiService.baseUrl}/data2',
        deserialize: (json) => json,
      ),
    ]) {
      final result = await call();
      results.add(result);
    }

    if (context.mounted) {
      for (final result in results) {
        result.showErrorIfFailed(context);
      }
    }
  }

  /// Example 4: Silent error handling (no UI feedback)
  static Future<void> fetchSilentExample() async {
    final httpClient = HttpClientWrapper();

    final result = await httpClient.get(
      '${ApiService.baseUrl}/example',
      deserialize: (json) => json,
      silentError: true,
    );

    if (result.isSuccess) {
      debugPrint('Success: ${result.data}');
    } else {
      debugPrint('Error: ${result.error}');
    }
  }
}
