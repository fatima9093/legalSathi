import 'package:flutter/material.dart';
import 'package:front_end/services/notification_service.dart';

class NotificationBadge extends StatefulWidget {
  final VoidCallback onPressed;
  final Duration refreshInterval;

  const NotificationBadge({
    super.key,
    required this.onPressed,
    this.refreshInterval = const Duration(seconds: 30),
  });

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge> {
  late final NotificationService _notificationService;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService();
    _loadUnreadCount();
    // Polling for unread count
    _startPolling();
  }

  void _startPolling() {
    Future.delayed(widget.refreshInterval, () {
      if (mounted) {
        _loadUnreadCount();
        _startPolling();
      }
    });
  }

  Future<void> _loadUnreadCount() async {
    final result = await _notificationService.getUnreadCount();
    if (result.isSuccess) {
      setState(() {
        _unreadCount = result.data ?? 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: widget.onPressed,
        ),
        if (_unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                _unreadCount > 99 ? '99+' : '$_unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
