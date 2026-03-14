class ChatHistory {
  final String id;
  String title; // mutable — supports rename
  final String previewText;
  final DateTime timestamp;

  /// Stores screen's ChatMessage objects as dynamic to avoid circular imports.
  final List<dynamic> messages;

  ChatHistory({
    required this.id,
    required this.title,
    required this.previewText,
    required this.timestamp,
    List<dynamic>? messages,
  }) : messages = messages ?? [];

  String getFormattedDate() {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
