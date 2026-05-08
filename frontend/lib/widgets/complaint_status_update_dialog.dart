import 'package:flutter/material.dart';
import 'package:front_end/models/complaint_status_model.dart';
import 'package:front_end/services/complaint_status_service.dart';
import 'package:front_end/services/snackbar_service.dart';

class ComplaintStatusUpdateDialog extends StatefulWidget {
  final String complaintId;
  final ComplaintStatus currentStatus;
  final VoidCallback? onStatusUpdated;

  const ComplaintStatusUpdateDialog({
    super.key,
    required this.complaintId,
    required this.currentStatus,
    this.onStatusUpdated,
  });

  @override
  State<ComplaintStatusUpdateDialog> createState() =>
      _ComplaintStatusUpdateDialogState();
}

class _ComplaintStatusUpdateDialogState
    extends State<ComplaintStatusUpdateDialog> {
  late final ComplaintStatusService _service;
  late ComplaintStatus _selectedStatus;
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _service = ComplaintStatusService();
    _selectedStatus = widget.currentStatus;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _updateStatus() async {
    if (_selectedStatus == widget.currentStatus) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a different status')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _service.updateComplaintStatus(
      complaintId: widget.complaintId,
      newStatus: _selectedStatus,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      SnackBarService.showSuccess(context, 'Status updated successfully');
      widget.onStatusUpdated?.call();
      Navigator.pop(context);
    } else {
      if (result.error != null) {
        SnackBarService.showError(context, result.error!);
      }
    }
  }

  Color _getStatusColor(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.submitted:
        return Colors.blue;
      case ComplaintStatus.underReview:
        return Colors.orange;
      case ComplaintStatus.inProgress:
        return Colors.purple;
      case ComplaintStatus.resolved:
        return Colors.green;
    }
  }

  IconData _getStatusIcon(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.submitted:
        return Icons.inbox;
      case ComplaintStatus.underReview:
        return Icons.search;
      case ComplaintStatus.inProgress:
        return Icons.build;
      case ComplaintStatus.resolved:
        return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update Complaint Status',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Current Status: ${widget.currentStatus.displayName}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 24),
            Text(
              'Select New Status',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ComplaintStatus.values.map((status) {
                final isSelected = _selectedStatus == status;
                final color = _getStatusColor(status);

                return FilterChip(
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedStatus = status);
                  },
                  label: Text(status.displayName),
                  avatar: Icon(_getStatusIcon(status), size: 16),
                  backgroundColor: Colors.grey[200],
                  selectedColor: color.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? color : Colors.black,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: 'Add notes (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              maxLines: 3,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _updateStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Update Status'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
