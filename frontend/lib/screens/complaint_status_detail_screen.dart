import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:front_end/models/complaint_status_model.dart';
import 'package:front_end/providers/complaint_status_provider.dart';
import 'package:front_end/widgets/complaint_status_timeline.dart';
import 'package:front_end/widgets/complaint_status_update_dialog.dart';

class ComplaintStatusDetailScreen extends StatefulWidget {
  final String complaintId;
  final String complaintTitle;

  const ComplaintStatusDetailScreen({
    super.key,
    required this.complaintId,
    required this.complaintTitle,
  });

  @override
  State<ComplaintStatusDetailScreen> createState() =>
      _ComplaintStatusDetailScreenState();
}

class _ComplaintStatusDetailScreenState
    extends State<ComplaintStatusDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ComplaintStatusProvider>().loadComplaintStatus(
        widget.complaintId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Complaint Status',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Consumer<ComplaintStatusProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.currentStatus == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Unable to load complaint status',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current status card
                _buildCurrentStatusCard(provider),
                const SizedBox(height: 24),

                // Complaint details
                _buildComplaintDetailsCard(),
                const SizedBox(height: 24),

                // Timeline
                _buildTimelineSection(provider),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Consumer<ComplaintStatusProvider>(
        builder: (context, provider, _) {
          // Only show FAB if user is admin (you may need to add role checking)
          return FloatingActionButton(
            onPressed: () {
              if (provider.currentStatus != null) {
                showDialog(
                  context: context,
                  builder: (context) => ComplaintStatusUpdateDialog(
                    complaintId: widget.complaintId,
                    currentStatus: provider.currentStatus!,
                    onStatusUpdated: () {
                      provider.loadComplaintStatus(widget.complaintId);
                    },
                  ),
                );
              }
            },
            tooltip: 'Update Status',
            child: const Icon(Icons.edit),
          );
        },
      ),
    );
  }

  Widget _buildCurrentStatusCard(ComplaintStatusProvider provider) {
    final status = provider.currentStatus!;
    final color = _getStatusColor(status);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getStatusIcon(status),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Status',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status.displayName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintDetailsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Complaint Details',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Complaint ID:', widget.complaintId),
          _buildDetailRow('Title:', widget.complaintTitle),
          _buildDetailRow(
            'Status:',
            '${context.read<ComplaintStatusProvider>().currentStatus?.displayName}',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTimelineSection(ComplaintStatusProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ComplaintStatusTimeline(
        history: provider.history,
        currentStatus: provider.currentStatus ?? ComplaintStatus.submitted,
      ),
    );
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
}
