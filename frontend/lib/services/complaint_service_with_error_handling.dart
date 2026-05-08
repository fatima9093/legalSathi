import 'package:flutter/material.dart';
import 'package:front_end/models/error_models.dart';
import 'package:front_end/services/api_service.dart';
import 'package:front_end/services/error_handler_service.dart';
import 'package:front_end/services/http_client_wrapper.dart';
import 'package:front_end/services/snackbar_service.dart';

/// Example implementation showing how to integrate error handling
/// into existing LegalSathi API calls

/// Complete complaint service with error handling
class ComplaintServiceWithErrorHandling {
  static final ComplaintServiceWithErrorHandling _instance =
      ComplaintServiceWithErrorHandling._internal();

  factory ComplaintServiceWithErrorHandling() {
    return _instance;
  }

  ComplaintServiceWithErrorHandling._internal();

  final HttpClientWrapper _httpClient = HttpClientWrapper();

  final ApiService _apiService = ApiService();

  static const String _baseUrl = 'http://localhost:8000/api';

  /// Submit complaint with error handling and retry
  Future<ApiResult<Map<String, dynamic>>> submitComplaint({
    required String complaintId,
    required Map<String, dynamic> complaintData,
  }) {
    return _httpClient.post(
      '$_baseUrl/complaints/$complaintId/submit',
      body: complaintData,
      deserialize: (json) => Map<String, dynamic>.from(json as Map),
      errorMessage: 'Failed to submit complaint. Please try again.',
      retryConfig: const RetryConfig(
        maxAttempts: 3,
        initialDelay: Duration(milliseconds: 500),
        backoffMultiplier: 1.5,
      ),
      timeout: const Duration(seconds: 30),
    );
  }

  /// Validate complaint data
  Future<ApiResult<Map<String, dynamic>>> validateComplaint({
    required String complaintId,
    required Map<String, dynamic> complaintData,
  }) {
    return _httpClient.post(
      '$_baseUrl/complaints/$complaintId/validate',
      body: complaintData,
      deserialize: (json) => Map<String, dynamic>.from(json as Map),
      errorMessage: 'Complaint validation failed. Please check your data.',
      timeout: const Duration(seconds: 15),
    );
  }

  /// Get user complaints with error handling
  Future<ApiResult<List<Map<String, dynamic>>>> getUserComplaints({
    required String userId,
  }) {
    return _httpClient.get(
      '$_baseUrl/user/$userId/complaints',
      deserialize: (json) {
        if (json is List) {
          return json.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
        return [];
      },
      errorMessage: 'Failed to fetch complaints.',
      timeout: const Duration(seconds: 20),
    );
  }

  /// Upload evidence files with progress tracking
  Future<ApiResult<Map<String, dynamic>>> uploadEvidence({
    required String complaintId,
    required List<int> fileData,
    required String fileName,
    void Function(int, int)? onProgress,
  }) {
    // Use POST to upload; expects server to accept multipart or binary encoded body
    return _httpClient.post(
      '$_baseUrl/documents/upload?complaint_id=$complaintId&file_name=$fileName',
      body: {'file_data': fileData, 'file_name': fileName},
      deserialize: (json) => Map<String, dynamic>.from(json as Map),
      errorMessage: 'Failed to upload evidence file.',
      retryConfig: const RetryConfig(maxAttempts: 5),
      timeout: const Duration(seconds: 60),
    );
  }

  /// Get complaint notifications
  Future<ApiResult<List<Map<String, dynamic>>>> getNotifications({
    required String userId,
    bool unreadOnly = false,
  }) {
    final url = unreadOnly
        ? '$_baseUrl/notifications/user/$userId?unread=true'
        : '$_baseUrl/notifications/user/$userId';

    return _httpClient.get(
      url,
      deserialize: (json) {
        if (json is List) {
          return json.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
        return [];
      },
      errorMessage: 'Failed to fetch notifications.',
    );
  }

  /// Delete complaint with error handling
  Future<ApiResult<Map<String, dynamic>>> deleteComplaint({
    required String complaintId,
  }) {
    return _httpClient.delete(
      '$_baseUrl/complaints/$complaintId',
      deserialize: (json) => Map<String, dynamic>.from(json as Map),
      errorMessage: 'Failed to delete complaint.',
    );
  }

  /// Execute with UI feedback
  Future<T?> executeWithUIFeedback<T>(
    BuildContext context,
    Future<ApiResult<T>> Function() operation, {
    required String loadingMessage,
    required String successMessage,
    VoidCallback? onSuccess,
    VoidCallback? onError,
  }) {
    return _apiService.executeWithUI(
      context,
      operation,
      loadingMessage: loadingMessage,
      successMessage: successMessage,
      showSuccess: true,
      showError: true,
      onSuccess: onSuccess,
      onError: onError,
    );
  }
}

/// Example widget using error handling
class ComplaintSubmissionExample extends StatefulWidget {
  final String complaintId;
  final Map<String, dynamic> complaintData;

  const ComplaintSubmissionExample({
    super.key,
    required this.complaintId,
    required this.complaintData,
  });

  @override
  State<ComplaintSubmissionExample> createState() =>
      _ComplaintSubmissionExampleState();
}

class _ComplaintSubmissionExampleState
    extends State<ComplaintSubmissionExample> {
  final _complaintService = ComplaintServiceWithErrorHandling();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Complaint')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _submitComplaint,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit Complaint'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _validateComplaint,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Validate First'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _loadComplaints,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Load My Complaints'),
            ),
          ],
        ),
      ),
    );
  }

  /// Example 1: Submit complaint with UI feedback
  Future<void> _submitComplaint() async {
    if (!mounted) return;

    final result = await _complaintService.executeWithUIFeedback(
      context,
      () => _complaintService.submitComplaint(
        complaintId: widget.complaintId,
        complaintData: widget.complaintData,
      ),
      loadingMessage: 'Submitting complaint...',
      successMessage: 'Complaint submitted successfully!',
      onSuccess: () {
        debugPrint('Complaint submitted successfully');
        // Navigate or refresh UI
      },
      onError: () {
        debugPrint('Failed to submit complaint');
      },
    );

    // Handle the result if needed
    if (result != null) {
      debugPrint('Complaint ID: ${result['id']}');
    }
  }

  /// Example 2: Validate complaint with error handling
  Future<void> _validateComplaint() async {
    setState(() => _isLoading = true);

    try {
      final result = await _complaintService.validateComplaint(
        complaintId: widget.complaintId,
        complaintData: widget.complaintData,
      );

      if (!mounted) return;

      if (result.isSuccess) {
        SnackBarService.showSuccess(context, 'Complaint data is valid');
        debugPrint('Validation result: ${result.data}');
      } else if (result.error != null) {
        SnackBarService.showError(context, result.error!);

        // Show detailed error dialog for debugging
        if (result.error!.details != null) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Validation Error'),
              content: Text(result.error!.details!),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Example 3: Load complaints with automatic error handling
  Future<void> _loadComplaints() async {
    if (!mounted) return;

    final userId = 'user_123'; // Get from auth service

    final data = await _complaintService
        .executeWithUIFeedback<List<Map<String, dynamic>>>(
          context,
          () => _complaintService.getUserComplaints(userId: userId),
          loadingMessage: 'Loading your complaints...',
          successMessage: 'Complaints loaded',
          onSuccess: () {
            debugPrint('Complaints loaded successfully');
          },
          onError: () {
            debugPrint('Failed to load complaints');
          },
        );

    if (data != null) {
      debugPrint('Loaded ${data.length} complaints');
      for (final complaint in data) {
        debugPrint('Complaint: ${complaint['id']}');
      }
    }
  }
}

/// Example: Handling multiple API calls in sequence with error recovery
class MultiStepComplaintProcess extends StatefulWidget {
  final String complaintId;
  final Map<String, dynamic> complaintData;

  const MultiStepComplaintProcess({
    super.key,
    required this.complaintId,
    required this.complaintData,
  });

  @override
  State<MultiStepComplaintProcess> createState() =>
      _MultiStepComplaintProcessState();
}

class _MultiStepComplaintProcessState extends State<MultiStepComplaintProcess> {
  final _complaintService = ComplaintServiceWithErrorHandling();
  int _currentStep = 0;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Multi-Step Complaint Process')),
      body: Stepper(
        currentStep: _currentStep,
        steps: [
          Step(
            title: const Text('Validate'),
            content: ElevatedButton(
              onPressed: _isProcessing ? null : _stepValidate,
              child: const Text('Validate Complaint'),
            ),
          ),
          Step(
            title: const Text('Submit'),
            content: ElevatedButton(
              onPressed: _isProcessing ? null : _stepSubmit,
              child: const Text('Submit Complaint'),
            ),
          ),
          Step(
            title: const Text('Confirm'),
            content: const Text('Complaint submitted successfully!'),
          ),
        ],
      ),
    );
  }

  /// Step 1: Validate with automatic retry and error handling
  Future<void> _stepValidate() async {
    if (!mounted) return;

    setState(() => _isProcessing = true);

    try {
      final result = await _complaintService.validateComplaint(
        complaintId: widget.complaintId,
        complaintData: widget.complaintData,
      );

      if (!mounted) return;

      if (result.isSuccess) {
        setState(() => _currentStep = 1);
        SnackBarService.showSuccess(context, 'Validation passed');
      } else if (result.error != null) {
        SnackBarService.showError(context, result.error!);
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  /// Step 2: Submit with UI feedback
  Future<void> _stepSubmit() async {
    if (!mounted) return;

    final result = await _complaintService.executeWithUIFeedback(
      context,
      () => _complaintService.submitComplaint(
        complaintId: widget.complaintId,
        complaintData: widget.complaintData,
      ),
      loadingMessage: 'Submitting complaint...',
      successMessage: 'Complaint submitted!',
      onSuccess: () {
        setState(() => _currentStep = 2);
      },
    );
  }
}

/// Example: Error recovery with fallback
class ComplaintListWithErrorRecovery extends StatefulWidget {
  const ComplaintListWithErrorRecovery({super.key});

  @override
  State<ComplaintListWithErrorRecovery> createState() =>
      _ComplaintListWithErrorRecoveryState();
}

class _ComplaintListWithErrorRecoveryState
    extends State<ComplaintListWithErrorRecovery> {
  final _complaintService = ComplaintServiceWithErrorHandling();
  List<Map<String, dynamic>> _cachedComplaints = [];
  bool _isLoading = false;
  String? _lastError;

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Complaints'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadComplaints,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cachedComplaints.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No complaints found'),
                  if (_lastError != null) ...[
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Last error: $_lastError',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadComplaints,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _cachedComplaints.length,
              itemBuilder: (context, index) {
                final complaint = _cachedComplaints[index];
                return ListTile(
                  title: Text(complaint['title'] ?? 'Complaint'),
                  subtitle: Text(complaint['status'] ?? 'Pending'),
                  onTap: () {
                    // Navigate to complaint details
                  },
                );
              },
            ),
    );
  }

  /// Load with error recovery
  Future<void> _loadComplaints() async {
    setState(() => _isLoading = true);
    _lastError = null;

    try {
      final userId = 'user_123'; // From auth service

      final result = await _complaintService.getUserComplaints(userId: userId);

      if (!mounted) return;

      if (result.isSuccess && result.data != null) {
        setState(() {
          _cachedComplaints = result.data!;
          _isLoading = false;
        });
      } else {
        // Error occurred
        setState(() {
          _lastError = result.error?.userMessage ?? 'Unknown error';
          _isLoading = false;
          // Keep previous data if available
        });

        if (mounted) {
          SnackBarService.showError(
            context,
            result.error ??
                AppError(
                  type: ErrorType.unknown,
                  message: 'Failed to load complaints',
                ),
            action: SnackBarAction(label: 'Retry', onPressed: _loadComplaints),
          );
        }
      }
    } catch (e, st) {
      debugPrintStack(stackTrace: st, label: 'Error loading complaints');

      if (mounted) {
        setState(() {
          _lastError = e.toString();
          _isLoading = false;
        });
      }
    }
  }
}
