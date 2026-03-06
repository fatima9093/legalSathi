class ChatHistory {
  final String id;
  final String title;
  final String previewText;
  final DateTime timestamp;
  final List<ChatMessage> messages;

  ChatHistory({
    required this.id,
    required this.title,
    required this.previewText,
    required this.timestamp,
    required this.messages,
  });

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

class ChatMessage {
  final String text;
  final String? urduText;
  final bool isUser;
  final String? timestamp;
  final bool showActions;

  ChatMessage({
    required this.text,
    this.urduText,
    required this.isUser,
    this.timestamp,
    this.showActions = true,
  });
}
