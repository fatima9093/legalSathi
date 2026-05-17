import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatMessage {
  final String? id;
  final String userId;
  final String messageText;
  final String senderType; // 'user' or 'ai'
  final String? category;
  final DateTime timestamp;
  final bool isDeleted;

  ChatMessage({
    this.id,
    required this.userId,
    required this.messageText,
    required this.senderType,
    this.category,
    required this.timestamp,
    this.isDeleted = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String?,
      userId: json['user_id'] as String? ?? '',
      messageText: json['message_text'] as String? ?? '',
      senderType: json['sender_type'] as String? ?? 'user',
      category: json['category'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      isDeleted: json['is_deleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'message_text': messageText,
      'sender_type': senderType,
      'category': category,
      'timestamp': timestamp.toIso8601String(),
      'is_deleted': isDeleted,
    };
  }

  @override
  String toString() {
    return 'ChatMessage(id: $id, senderType: $senderType, messageText: ${messageText.substring(0, 50)}...)';
  }
}

class ChatPersistenceService {
  static final ChatPersistenceService _instance =
      ChatPersistenceService._internal();

  factory ChatPersistenceService() {
    return _instance;
  }

  ChatPersistenceService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _tableName = 'chat_messages';
  static const String _sessionTable = 'conversation_sessions';

  Map<String, dynamic> _normalizeMetadata(dynamic metadata) {
    if (metadata is Map<String, dynamic>) {
      return Map<String, dynamic>.from(metadata);
    }
    if (metadata is String && metadata.isNotEmpty) {
      try {
        final decoded = jsonDecode(metadata);
        if (decoded is Map<String, dynamic>) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {}
    }
    return <String, dynamic>{};
  }

  List<Map<String, dynamic>> _normalizeMessages(dynamic rawMessages) {
    if (rawMessages is! List) return [];
    return rawMessages
        .whereType<Map>()
        .map((message) => Map<String, dynamic>.from(message))
        .toList();
  }

  String _buildTitle(String previewText) {
    final text = previewText.trim();
    if (text.isEmpty) return 'New Chat';
    return text.length > 42 ? '${text.substring(0, 39)}...' : text;
  }

  String _buildPreview(String messageText) {
    final text = messageText.trim();
    if (text.isEmpty) return 'New conversation';
    return text.length > 96 ? '${text.substring(0, 93)}...' : text;
  }

  Map<String, dynamic> _sessionToActivityRow(Map<String, dynamic> row) {
    final summary = (row['summary'] as String?)?.trim() ?? 'Chat session';
    final metadata = _normalizeMetadata(row['metadata']);
    final preview = (metadata['preview_text'] as String?)?.trim();
    final module = (row['module'] as String?)?.trim();
    return {
      'id': row['id'],
      'user_id': row['user_id'],
      'title': 'Chat Session',
      'description': preview != null && preview.isNotEmpty ? preview : summary,
      'type': 'chat_session',
      'icon': 'chat',
      'timestamp': row['updated_at'] ?? row['created_at'],
      'related_id': row['id'],
      'module': module,
    };
  }

  /// Save a full conversation session snapshot for a user.
  Future<void> saveConversationSession({
    required String userId,
    required String conversationId,
    required String previewText,
    required List<Map<String, dynamic>> messages,
    String? module,
    Map<String, dynamic>? metadata,
  }) async {
    final snapshotMetadata = <String, dynamic>{
      ...?metadata,
      'preview_text': previewText,
      'title': _buildTitle(previewText),
      'messages': messages,
      'message_count': messages.length,
      'saved_at': DateTime.now().toIso8601String(),
    };

    await _supabase.from(_sessionTable).upsert({
      'id': conversationId,
      'user_id': userId,
      'summary': _buildTitle(previewText),
      'module': module,
      'metadata': snapshotMetadata,
      'updated_at': DateTime.now().toIso8601String(),
      'expires_at': DateTime.now()
          .add(const Duration(days: 7))
          .toIso8601String(),
    }, onConflict: 'id');
  }

  /// Load all chat sessions for a user, newest first.
  Future<List<Map<String, dynamic>>> loadConversationSessions({
    required String userId,
    int limit = 50,
  }) async {
    try {
      final response = await _supabase
          .from(_sessionTable)
          .select()
          .eq('user_id', userId)
          .order('updated_at', ascending: false)
          .limit(limit);

      return (response as List).map((row) {
        final map = Map<String, dynamic>.from(row as Map);
        final metadata = _normalizeMetadata(map['metadata']);
        final messages = _normalizeMessages(metadata['messages']);
        map['metadata'] = metadata;
        map['messages'] = messages;
        map['title'] = (metadata['title'] as String?)?.trim().isNotEmpty == true
            ? metadata['title']
            : map['summary'] ?? 'Chat Session';
        map['preview_text'] =
            (metadata['preview_text'] as String?) ?? map['summary'] ?? '';
        map['message_count'] = messages.length;
        return map;
      }).toList();
    } catch (e) {
      debugPrint('Error loading conversation sessions: $e');
      rethrow;
    }
  }

  /// Load one conversation session snapshot by id.
  Future<List<Map<String, dynamic>>> loadConversationMessages({
    required String userId,
    required String conversationId,
  }) async {
    try {
      final result = await _supabase
          .from(_sessionTable)
          .select()
          .eq('user_id', userId)
          .eq('id', conversationId)
          .maybeSingle();

      if (result == null) return [];
      final map = Map<String, dynamic>.from(result as Map);
      final metadata = _normalizeMetadata(map['metadata']);
      return _normalizeMessages(metadata['messages']);
    } catch (e) {
      debugPrint('Error loading conversation messages: $e');
      rethrow;
    }
  }

  /// Delete a persisted conversation session.
  Future<bool> deleteConversationSession({
    required String userId,
    required String conversationId,
  }) async {
    try {
      await _supabase
          .from(_sessionTable)
          .delete()
          .eq('user_id', userId)
          .eq('id', conversationId);
      return true;
    } catch (e) {
      debugPrint('Error deleting conversation session: $e');
      rethrow;
    }
  }

  /// Build a Supabase activity row from a stored conversation session.
  Map<String, dynamic> conversationSessionAsActivity(Map<String, dynamic> row) {
    return _sessionToActivityRow(row);
  }

  /// Save a message to database
  Future<ChatMessage?> saveMessage({
    required String userId,
    required String messageText,
    required String senderType,
    String? category,
  }) async {
    try {
      final now = DateTime.now();

      final response = await _supabase.from(_tableName).insert({
        'user_id': userId,
        'message_text': messageText,
        'sender_type': senderType,
        'category': category,
        'timestamp': now.toIso8601String(),
      }).select();

      if (response.isNotEmpty) {
        return ChatMessage.fromJson(response[0]);
      }
      return null;
    } catch (e) {
      debugPrint('Error saving message: $e');
      rethrow;
    }
  }

  /// Load all messages for a user ordered by timestamp
  Future<List<ChatMessage>> loadChatHistory({
    required String userId,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('is_deleted', false)
          .order('timestamp', ascending: true)
          .range(offset, offset + limit - 1);

      final messages = (response as List)
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();

      return messages;
    } catch (e) {
      debugPrint('Error loading chat history: $e');
      rethrow;
    }
  }

  /// Load chat history with pagination
  Future<List<ChatMessage>> loadChatHistoryPaginated({
    required String userId,
    required int page,
    int pageSize = 50,
  }) async {
    try {
      final offset = (page - 1) * pageSize;
      return loadChatHistory(userId: userId, limit: pageSize, offset: offset);
    } catch (e) {
      debugPrint('Error loading paginated chat history: $e');
      rethrow;
    }
  }

  /// Load latest messages since a specific timestamp
  Future<List<ChatMessage>> loadMessagesSinceTimestamp({
    required String userId,
    required DateTime since,
  }) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('is_deleted', false)
          .gte('timestamp', since.toIso8601String())
          .order('timestamp', ascending: true);

      final messages = (response as List)
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();

      return messages;
    } catch (e) {
      debugPrint('Error loading messages since timestamp: $e');
      rethrow;
    }
  }

  /// Soft delete a message
  Future<bool> deleteMessage(String messageId) async {
    try {
      await _supabase
          .from(_tableName)
          .update({'is_deleted': true})
          .eq('id', messageId);
      return true;
    } catch (e) {
      debugPrint('Error deleting message: $e');
      rethrow;
    }
  }

  /// Update message text (for corrections)
  Future<ChatMessage?> updateMessage({
    required String messageId,
    required String newText,
  }) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .update({
            'message_text': newText,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', messageId)
          .select();

      if (response.isNotEmpty) {
        return ChatMessage.fromJson(response[0]);
      }
      return null;
    } catch (e) {
      debugPrint('Error updating message: $e');
      rethrow;
    }
  }

  /// Clear all messages for a user
  Future<bool> clearChatHistory(String userId) async {
    try {
      await _supabase
          .from(_tableName)
          .update({'is_deleted': true})
          .eq('user_id', userId);
      return true;
    } catch (e) {
      debugPrint('Error clearing chat history: $e');
      rethrow;
    }
  }

  /// Get message count for user
  Future<int> getMessageCount(String userId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('id')
          .eq('user_id', userId)
          .eq('is_deleted', false)
          .count(CountOption.exact);

      return response.count;
    } catch (e) {
      debugPrint('Error getting message count: $e');
      return 0;
    }
  }

  /// Check if message already exists (prevent duplicates)
  Future<bool> messageExists({
    required String userId,
    required String messageText,
    required String senderType,
    Duration timeDifference = const Duration(seconds: 5),
  }) async {
    try {
      final recentTime = DateTime.now()
          .subtract(timeDifference)
          .toIso8601String();

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('message_text', messageText)
          .eq('sender_type', senderType)
          .gte('timestamp', recentTime)
          .limit(1);

      return response.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking if message exists: $e');
      return false;
    }
  }

  /// Save user message with duplicate check
  Future<ChatMessage?> saveUserMessage({
    required String userId,
    required String messageText,
    String? category,
  }) async {
    // Check for duplicates within last 5 seconds
    final isDuplicate = await messageExists(
      userId: userId,
      messageText: messageText,
      senderType: 'user',
      timeDifference: const Duration(seconds: 5),
    );

    if (isDuplicate) {
      debugPrint('Duplicate user message prevented');
      return null;
    }

    return saveMessage(
      userId: userId,
      messageText: messageText,
      senderType: 'user',
      category: category,
    );
  }

  /// Save AI response with duplicate check
  Future<ChatMessage?> saveAIResponse({
    required String userId,
    required String messageText,
    String? category,
  }) async {
    // Check for duplicates within last 5 seconds
    final isDuplicate = await messageExists(
      userId: userId,
      messageText: messageText,
      senderType: 'ai',
      timeDifference: const Duration(seconds: 5),
    );

    if (isDuplicate) {
      debugPrint('Duplicate AI response prevented');
      return null;
    }

    return saveMessage(
      userId: userId,
      messageText: messageText,
      senderType: 'ai',
      category: category,
    );
  }

  /// Get conversation summary for a user
  Future<Map<String, dynamic>> getConversationStats(String userId) async {
    try {
      final userMessages = await _supabase
          .from(_tableName)
          .select('id')
          .eq('user_id', userId)
          .eq('sender_type', 'user')
          .eq('is_deleted', false)
          .count(CountOption.exact);

      final aiMessages = await _supabase
          .from(_tableName)
          .select('id')
          .eq('user_id', userId)
          .eq('sender_type', 'ai')
          .eq('is_deleted', false)
          .count(CountOption.exact);

      return {
        'user_messages': userMessages.count,
        'ai_responses': aiMessages.count,
        'total_messages': userMessages.count + aiMessages.count,
      };
    } catch (e) {
      debugPrint('Error getting conversation stats: $e');
      return {};
    }
  }

  /// Search messages by keyword
  Future<List<ChatMessage>> searchMessages({
    required String userId,
    required String keyword,
  }) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('is_deleted', false)
          .ilike('message_text', '%$keyword%')
          .order('timestamp', ascending: false);

      final messages = (response as List)
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();

      return messages;
    } catch (e) {
      debugPrint('Error searching messages: $e');
      rethrow;
    }
  }

  /// Export chat history as list
  Future<List<Map<String, dynamic>>> exportChatHistory(String userId) async {
    try {
      final messages = await loadChatHistory(userId: userId, limit: 10000);
      return messages.map((m) => m.toJson()).toList();
    } catch (e) {
      debugPrint('Error exporting chat history: $e');
      rethrow;
    }
  }
}
