# Global Error Handling System - Quick Reference

## 📚 Core Files Created (7 files, 1000+ lines)

| File | Purpose |
|------|---------|
| `error_models.dart` | Error types, AppError class, ApiResult wrapper |
| `error_handler_service.dart` | Central error handler, retry logic, SafeApiCallWrapper |
| `snackbar_service.dart` | User-friendly error/success/warning/info messages |
| `http_client_wrapper.dart` | HTTP client with retry, timeout, timeout handling |
| `api_service.dart` | High-level API orchestrator, UI integration |
| `app_error_handler.dart` | Global app-level error handler |
| `complaint_service_with_error_handling.dart` | Example implementations |

## 🚀 Quick Start (3 Steps)

### Step 1: Initialize in main.dart
```dart
void main() {
  runApp(
    ErrorHandlerInitializer(
      child: MyApp(),
    ),
  );
}
```

### Step 2: Use in any API call
```dart
final httpClient = HttpClientWrapper();

final result = await httpClient.get(
  'http://localhost:8000/api/data',
  deserialize: (json) => json as Map<String, dynamic>,
);

if (result.isSuccess) {
  print('Success: ${result.data}');
} else {
  print('Error: ${result.error?.userMessage}');
}
```

### Step 3: Show UI feedback
```dart
final data = await apiService.executeWithUI(
  context,
  () => httpClient.get(url, deserialize: (j) => j),
  loadingMessage: 'Loading...',
  successMessage: 'Loaded successfully',
);
```

## 🎯 Features at a Glance

| Feature | Default | Configurable |
|---------|---------|--------------|
| Max Retries | 3 attempts | ✅ Yes |
| Request Timeout | 30 seconds | ✅ Yes |
| Retry Delay | 500ms initial | ✅ Yes |
| Backoff Multiplier | 1.5x exponential | ✅ Yes |
| Max Retry Delay | 10 seconds | ✅ Yes |

## 💡 Common Patterns

### Pattern 1: Simple GET
```dart
final result = await httpClient.get(
  url,
  deserialize: (j) => j as Map<String, dynamic>,
);
result.showErrorIfFailed(context);
```

### Pattern 2: POST with Custom Retry
```dart
final result = await httpClient.post(
  url,
  body: data,
  deserialize: (j) => j as Map<String, dynamic>,
  retryConfig: const RetryConfig(maxAttempts: 5),
);
```

### Pattern 3: With UI Feedback
```dart
final data = await apiService.executeWithUI(
  context,
  () => httpClient.post(url, body: data, deserialize: (j) => j),
  loadingMessage: 'Submitting...',
  successMessage: 'Submitted!',
  onSuccess: () { /* refresh UI */ },
);
```

### Pattern 4: Silent Error Handling
```dart
final result = await httpClient.get(
  url,
  deserialize: (j) => j,
  silentError: true,  // No error shown to user
);
if (!result.isSuccess) {
  debugPrint('Error: ${result.error}');  // Log only
}
```

### Pattern 5: Multiple Parallel Calls
```dart
final results = await httpClient.callMultiple([
  () => httpClient.get(url1, deserialize: (j) => j),
  () => httpClient.get(url2, deserialize: (j) => j),
  () => httpClient.get(url3, deserialize: (j) => j),
]);
```

## 🔧 Configuration Reference

### Custom Retry Policy
```dart
const retryConfig = RetryConfig(
  maxAttempts: 5,
  initialDelay: Duration(milliseconds: 1000),
  backoffMultiplier: 2.0,
  maxDelay: Duration(seconds: 30),
);
```

### Custom Timeout
```dart
const timeout = Duration(seconds: 60);
```

### Combining Both
```dart
final result = await httpClient.post(
  url,
  body: data,
  deserialize: (j) => j,
  retryConfig: retryConfig,
  timeout: timeout,
);
```

## 📱 Error Messages Shown to Users

| Scenario | Message |
|----------|---------|
| No internet | "No internet connection. Please check your network." |
| Request takes too long | "Request took too long. Please try again." |
| Invalid data sent | "Invalid request. Please check your input." |
| Session expired | "Please sign in again." |
| Access denied | "You do not have permission to perform this action." |
| Resource not found | "The requested resource was not found." |
| Server error | "Server error. Please try again later." |
| Empty response | "Empty response received. Please try again." |
| Parse error | "Error processing response. Please try again." |

## 🔍 Debugging

### View Error Details Dialog
```dart
final handler = AppErrorHandler();
handler.showErrorDetailsDialog(error);
```

### Access Error Type
```dart
if (error.type == ErrorType.network) {
  // Handle network error
}
```

### Check if Retryable
```dart
if (error.type == ErrorType.timeout ||
    error.type == ErrorType.network) {
  // Show retry button
}
```

## 📊 Implementation Checklist

- [ ] **Setup**
  - [ ] Add ErrorHandlerInitializer to main.dart
  - [ ] Update base URL in ApiService

- [ ] **Integration**
  - [ ] Replace old API calls with HttpClientWrapper
  - [ ] Update all HTTP GET/POST/PUT/DELETE calls
  - [ ] Remove manual try-catch blocks
  - [ ] Remove manual SnackBar calls for errors

- [ ] **Testing**
  - [ ] Test with no internet connection
  - [ ] Test with slow network (simulate timeout)
  - [ ] Test 5xx server errors
  - [ ] Test 4xx errors (400, 401, 403, 404)
  - [ ] Test null responses
  - [ ] Test retry logic (stop at max attempts)
  - [ ] Verify SnackBar displays on all screens

- [ ] **Production**
  - [ ] Set correct API base URL
  - [ ] Configure retry policy per operation
  - [ ] Configure timeouts per operation type
  - [ ] Add error analytics logging
  - [ ] Monitor error rates

## 🎓 Learning Resources

### Example 1: Submit Complaint
```dart
import 'package:front_end/services/complaint_service_with_error_handling.dart';

final service = ComplaintServiceWithErrorHandling();
final result = await service.submitComplaint(
  complaintId: 'comp_123',
  complaintData: {...},
);

if (result.isSuccess) {
  // Success
} else {
  print(result.error?.userMessage);
}
```

### Example 2: Load Data with UI
```dart
final data = await apiService.executeWithUI(
  context,
  () => httpClient.get(
    url,
    deserialize: (json) => json as Map<String, dynamic>,
  ),
  loadingMessage: 'Loading complaints...',
  successMessage: 'Loaded successfully',
);
```

### Example 3: Error Recovery
See `ComplaintListWithErrorRecovery` in `complaint_service_with_error_handling.dart`

## 🐛 Troubleshooting

### SnackBar not showing?
- Ensure Scaffold is in widget tree
- Check ScaffoldMessenger context

### Retries not happening?
- Check network error type
- Verify errorString detection in `_shouldRetry()`
- Use custom retryable check

### Timeout not working?
- Verify Duration is set correctly
- Check API actually takes that long
- Increase timeout for slower networks

### Error message not user-friendly?
- Check ErrorType mapping in AppError.userMessage
- Add custom error message: `errorMessage: 'Custom message'`

## 📈 Performance Tips

1. **Adjust retry config per operation**
   - Critical ops: 5 retries
   - Regular ops: 3 retries
   - Non-critical: 1 retry

2. **Set timeout based on operation**
   - File upload: 60+ seconds
   - Regular query: 30 seconds
   - Quick check: 10 seconds

3. **Use silentError for background tasks**
   - Don't show error UI for background refresh
   - Log errors only

4. **Batch parallel requests**
   - Use `callMultiple()` for parallel ops
   - Reduces total time

## ✅ Verification Checklist

- [x] All 7 files created
- [x] 0 compilation errors
- [x] 1000+ lines of code
- [x] Type-safe with generics
- [x] Retry logic implemented
- [x] Timeout handling added
- [x] User-friendly messages
- [x] UI integration ready
- [x] Example implementations included
- [x] Integration guide provided
- [x] Quick reference created

## 📞 Support

For issues or questions:
1. Check GLOBAL_ERROR_HANDLING_GUIDE.md for detailed docs
2. Review example implementations in `complaint_service_with_error_handling.dart`
3. Check error logs for detailed error information
4. Use `AppErrorHandler.showErrorDetailsDialog()` for debugging
