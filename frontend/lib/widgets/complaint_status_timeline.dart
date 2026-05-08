import 'package:flutter/material.dart';
import 'package:front_end/models/complaint_status_model.dart';

class ComplaintStatusTimeline extends StatelessWidget {
  final List<ComplaintStatusHistory> history;
  final ComplaintStatus currentStatus;

  const ComplaintStatusTimeline({
    super.key,
    required this.history,
    required this.currentStatus,
  });

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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';

    return '${date.day} ${_getMonth(date.month)} ${date.year}';
  }

  String _getMonth(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            'Status Timeline',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        // Status progress indicator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildStatusProgressBar(),
        ),
        const SizedBox(height: 24),
        // Timeline history
        if (history.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                'No status history',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index];
              final isLast = index == history.length - 1;

              return _buildTimelineItem(context, item, isLast: isLast);
            },
          ),
      ],
    );
  }

  Widget _buildStatusProgressBar() {
    const statuses = [
      ComplaintStatus.submitted,
      ComplaintStatus.underReview,
      ComplaintStatus.inProgress,
      ComplaintStatus.resolved,
    ];

    return Column(
      children: [
        Row(
          children: List.generate(statuses.length, (index) {
            final status = statuses[index];
            final isActive = _isStatusReached(status);
            final isCurrent = currentStatus == status;

            return Expanded(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: isActive ? Colors.green : Colors.grey[300],
                    child: Icon(
                      _getStatusIcon(status),
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    status.displayName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isCurrent
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isActive ? Colors.green : Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            widthFactor: _getProgressPercentage(),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _isStatusReached(ComplaintStatus status) {
    const statusOrder = [
      ComplaintStatus.submitted,
      ComplaintStatus.underReview,
      ComplaintStatus.inProgress,
      ComplaintStatus.resolved,
    ];

    return statusOrder.indexOf(status) <= statusOrder.indexOf(currentStatus);
  }

  double _getProgressPercentage() {
    const statuses = [
      ComplaintStatus.submitted,
      ComplaintStatus.underReview,
      ComplaintStatus.inProgress,
      ComplaintStatus.resolved,
    ];

    final index = statuses.indexOf(currentStatus);
    return (index + 1) / statuses.length;
  }

  Widget _buildTimelineItem(
    BuildContext context,
    ComplaintStatusHistory item, {
    required bool isLast,
  }) {
    final color = _getStatusColor(item.status);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: color,
                child: Icon(
                  _getStatusIcon(item.status),
                  color: Colors.white,
                  size: 14,
                ),
              ),
              if (!isLast)
                Container(width: 2, height: 40, color: Colors.grey[400]),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.status.displayName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(item.changedAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                if (item.notes != null && item.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.notes!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ),
                ],
                if (!isLast) const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
