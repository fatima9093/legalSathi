import 'package:flutter/material.dart';
import 'package:front_end/models/complaint_status_model.dart';
import 'package:front_end/services/complaint_status_service.dart';

class ComplaintStatusProvider extends ChangeNotifier {
  final ComplaintStatusService _service = ComplaintStatusService();

  ComplaintStatus? _currentStatus;
  List<ComplaintStatusHistory> _history = [];
  bool _isLoading = false;
  String? _currentComplaintId;

  ComplaintStatus? get currentStatus => _currentStatus;
  List<ComplaintStatusHistory> get history => _history;
  bool get isLoading => _isLoading;

  Future<void> loadComplaintStatus(String complaintId) async {
    _currentComplaintId = complaintId;
    _isLoading = true;
    notifyListeners();

    // Fetch current status
    final statusResult = await _service.getComplaintStatus(complaintId);
    if (statusResult.isSuccess) {
      _currentStatus = statusResult.data;
    }

    // Fetch history
    final historyResult = await _service.getStatusHistory(complaintId);
    if (historyResult.isSuccess) {
      _history = historyResult.data ?? [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateStatus(ComplaintStatus newStatus, {String? notes}) async {
    if (_currentComplaintId == null) return false;

    final result = await _service.updateComplaintStatus(
      complaintId: _currentComplaintId!,
      newStatus: newStatus,
      notes: notes,
    );

    if (result.isSuccess) {
      _currentStatus = newStatus;
      // Reload history to show new entry
      await loadComplaintStatus(_currentComplaintId!);
      return true;
    }
    return false;
  }

  void subscribeToStatusChanges() {
    if (_currentComplaintId == null) return;

    _service.subscribeToStatusChanges(
      complaintId: _currentComplaintId!,
      onStatusChange: (newStatus) {
        _currentStatus = newStatus;
        notifyListeners();
        // Reload history to show updated entry
        loadComplaintStatus(_currentComplaintId!);
      },
      onError: (error) {
        debugPrint('Status subscription error: $error');
      },
    );
  }

  void unsubscribeFromStatusChanges() {
    if (_currentComplaintId != null) {
      _service.unsubscribeFromStatusChanges(_currentComplaintId!);
    }
  }

  @override
  void dispose() {
    unsubscribeFromStatusChanges();
    super.dispose();
  }
}
