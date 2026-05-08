import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:front_end/models/error_models.dart';
import 'package:front_end/services/error_handler_service.dart';

/// HTTP client wrapper with error handling, retry logic, and timeout
class HttpClientWrapper {
  static final HttpClientWrapper _instance = HttpClientWrapper._internal();

  factory HttpClientWrapper() {
    return _instance;
  }

  HttpClientWrapper._internal();

  final SafeApiCallWrapper _safeCallWrapper = SafeApiCallWrapper();

  // Default configuration
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const int defaultMaxRetries = 3;

  /// GET request with error handling and retry
  Future<ApiResult<T>> get<T>(
    String url, {
    Map<String, String>? headers,
    Duration? timeout,
    RetryConfig? retryConfig,
    required T Function(dynamic) deserialize,
    String? errorMessage,
    bool silentError = false,
  }) async {
    return _safeCallWrapper.call(
      () async {
        final response = await http
            .get(Uri.parse(url), headers: _getHeaders(headers))
            .timeout(timeout ?? defaultTimeout);

        _checkStatusCode(response.statusCode);
        return deserialize(jsonDecode(response.body));
      },
      timeout: timeout,
      retryConfig: retryConfig,
      errorMessage: errorMessage,
      silentError: silentError,
    );
  }

  /// POST request with error handling and retry
  Future<ApiResult<T>> post<T>(
    String url, {
    dynamic body,
    Map<String, String>? headers,
    Duration? timeout,
    RetryConfig? retryConfig,
    required T Function(dynamic) deserialize,
    String? errorMessage,
    bool silentError = false,
  }) async {
    return _safeCallWrapper.call(
      () async {
        final response = await http
            .post(
              Uri.parse(url),
              headers: _getHeaders(headers),
              body: body is String ? body : jsonEncode(body),
            )
            .timeout(timeout ?? defaultTimeout);

        _checkStatusCode(response.statusCode);
        return deserialize(jsonDecode(response.body));
      },
      timeout: timeout,
      retryConfig: retryConfig,
      errorMessage: errorMessage,
      silentError: silentError,
    );
  }

  /// PUT request with error handling and retry
  Future<ApiResult<T>> put<T>(
    String url, {
    dynamic body,
    Map<String, String>? headers,
    Duration? timeout,
    RetryConfig? retryConfig,
    required T Function(dynamic) deserialize,
    String? errorMessage,
    bool silentError = false,
  }) async {
    return _safeCallWrapper.call(
      () async {
        final response = await http
            .put(
              Uri.parse(url),
              headers: _getHeaders(headers),
              body: body is String ? body : jsonEncode(body),
            )
            .timeout(timeout ?? defaultTimeout);

        _checkStatusCode(response.statusCode);
        return deserialize(jsonDecode(response.body));
      },
      timeout: timeout,
      retryConfig: retryConfig,
      errorMessage: errorMessage,
      silentError: silentError,
    );
  }

  /// PATCH request with error handling and retry
  Future<ApiResult<T>> patch<T>(
    String url, {
    dynamic body,
    Map<String, String>? headers,
    Duration? timeout,
    RetryConfig? retryConfig,
    required T Function(dynamic) deserialize,
    String? errorMessage,
    bool silentError = false,
  }) async {
    return _safeCallWrapper.call(
      () async {
        final response = await http
            .patch(
              Uri.parse(url),
              headers: _getHeaders(headers),
              body: body is String ? body : jsonEncode(body),
            )
            .timeout(timeout ?? defaultTimeout);

        _checkStatusCode(response.statusCode);
        return deserialize(jsonDecode(response.body));
      },
      timeout: timeout,
      retryConfig: retryConfig,
      errorMessage: errorMessage,
      silentError: silentError,
    );
  }

  /// DELETE request with error handling and retry
  Future<ApiResult<T>> delete<T>(
    String url, {
    Map<String, String>? headers,
    Duration? timeout,
    RetryConfig? retryConfig,
    required T Function(dynamic) deserialize,
    String? errorMessage,
    bool silentError = false,
  }) async {
    return _safeCallWrapper.call(
      () async {
        final response = await http
            .delete(Uri.parse(url), headers: _getHeaders(headers))
            .timeout(timeout ?? defaultTimeout);

        _checkStatusCode(response.statusCode);
        return deserialize(jsonDecode(response.body));
      },
      timeout: timeout,
      retryConfig: retryConfig,
      errorMessage: errorMessage,
      silentError: silentError,
    );
  }

  /// Download file with progress tracking
  Future<ApiResult<List<int>>> download(
    String url, {
    Map<String, String>? headers,
    Duration? timeout,
    RetryConfig? retryConfig,
    void Function(int received, int total)? onProgress,
    String? errorMessage,
    bool silentError = false,
  }) async {
    return _safeCallWrapper.call(
      () async {
        final request = http.Request('GET', Uri.parse(url));
        request.headers.addAll(_getHeaders(headers));

        final streamedResponse = await request.send().timeout(
          timeout ?? defaultTimeout,
        );

        _checkStatusCode(streamedResponse.statusCode);

        final contentLength = streamedResponse.contentLength ?? 0;
        final chunks = <List<int>>[];
        int received = 0;

        await for (final chunk in streamedResponse.stream) {
          chunks.add(chunk);
          received += chunk.length;
          onProgress?.call(received, contentLength);
        }

        return chunks.expand((chunk) => chunk).toList();
      },
      timeout: timeout,
      retryConfig: retryConfig,
      errorMessage: errorMessage,
      silentError: silentError,
    );
  }

  /// Get default headers
  Map<String, String> _getHeaders(Map<String, String>? customHeaders) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    return headers;
  }

  /// Check HTTP status code and throw if error
  void _checkStatusCode(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) {
      return; // Success
    }

    if (statusCode >= 400) {
      throw HttpServerErrorException(
        statusCode: statusCode,
        message: 'HTTP Error $statusCode',
      );
    }
  }
}
