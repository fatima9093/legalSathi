// REAL-TIME SUPABASE SUBSCRIPTIONS PATCH FOR chat_screen.dart
// 
// This patch adds real-time message updates so that when admin updates complaints
// or system sends notifications, users see updates immediately without polling.
//
// CHANGES REQUIRED:

// 1. ADD PROPERTY NEAR THE TOP OF _ChatScreenState CLASS (after line ~140):
// ─────────────────────────────────────────────────────────────────────────
/*
  // Real-time subscriptions for incoming messages/updates
  late RealtimeChannel _chatRealtimeChannel;
  late RealtimeChannel _complaintsRealtimeChannel;
*/

// 2. MODIFY initState() METHOD (around line 154-170):
// ─────────────────────────────────────────────────────────────────────────
/*
  @override
  void initState() {
    super.initState();

    _speech = stt.SpeechToText();
    _conversationId = _newConversationId();

    // Get current user ID
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      _currentUserId = userId;
      print('🔍 DEBUG: Your User ID: $userId');
      _loadChatHistory().then((_) {
        // ADDITION: Set up real-time subscriptions after loading history
        _setupRealtimeSubscriptions();
      });
    } else {
      // If no user, show greeting only
      _addGreetingMessage();
    }
  }
*/

// 3. ADD NEW METHOD BEFORE dispose():
// ─────────────────────────────────────────────────────────────────────────
/*
  /// Sets up real-time Supabase subscriptions for incoming messages and complaints
  void _setupRealtimeSubscriptions() {
    try {
      // Subscribe to NEW messages in chat_messages table for this conversation
      _chatRealtimeChannel = Supabase.instance.client
          .channel('public:chat_messages:conversation_id=eq.${_conversationId}')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'chat_messages',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'conversation_id',
              value: _conversationId,
            ),
            callback: (payload) {
              _handleNewChatMessage(payload);
            },
          )
          .subscribe();

      print('✅ Real-time subscription active for conversation: $_conversationId');

      // Subscribe to COMPLAINT UPDATES if in applicable modules (women_harassment, cyber_law)
      if (widget.selectedModule == ModuleType.womenHarassment ||
          widget.selectedModule == ModuleType.cyberCrime) {
        _complaintsRealtimeChannel = Supabase.instance.client
            .channel('public:complaints:user_id=eq.${_currentUserId}')
            .onPostgresChanges(
              event: PostgresChangeEvent.update,
              schema: 'public',
              table: 'complaints',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'user_id',
                value: _currentUserId,
              ),
              callback: (payload) {
                _handleComplaintUpdate(payload);
              },
            )
            .subscribe();

        print('✅ Real-time subscription active for complaints');
      }
    } catch (e) {
      print('❌ Error setting up real-time subscriptions: $e');
      // Continue gracefully - polling fallback still works
    }
  }

  /// Handles incoming chat messages in real-time
  void _handleNewChatMessage(PostgresChangePayload payload) {
    try {
      final newMsg = payload.newRecord;
      if (newMsg == null) return;

      final messageText = newMsg['message_text'] as String? ?? '';
      final senderType = newMsg['sender_type'] as String? ?? 'user';
      final timestamp = newMsg['created_at'] as String? ?? '';

      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              text: messageText,
              isUser: senderType == 'user',
              timestamp: _formatTimestamp(DateTime.parse(timestamp)),
              showActions: senderType != 'user', // Show actions for AI messages
            ),
          );
        });

        print('📨 Received real-time message: ${messageText.substring(0, 50)}...');
        _scrollToBottom();
      }
    } catch (e) {
      print('❌ Error handling new chat message: $e');
    }
  }

  /// Handles complaint status updates in real-time
  void _handleComplaintUpdate(PostgresChangePayload payload) {
    try {
      final updatedComplaint = payload.newRecord;
      if (updatedComplaint == null) return;

      final complaintId = updatedComplaint['id'] as String? ?? '';
      final status = updatedComplaint['status'] as String? ?? '';
      final staffNotes = updatedComplaint['staff_notes'] as String? ?? '';

      if (mounted) {
        // Show snackbar notification when complaint status changes
        String notificationText = '📋 Complaint $complaintId status: $status';
        if (staffNotes.isNotEmpty) {
          notificationText += '\n💬 Staff notes: $staffNotes';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(notificationText),
            duration: const Duration(seconds: 5),
            backgroundColor: _getStatusColor(status),
          ),
        );

        print('📋 Complaint updated in real-time: $complaintId ($status)');

        // Optionally add system message to chat
        _addSystemMessage('Your complaint #$complaintId status changed to: $status');
      }
    } catch (e) {
      print('❌ Error handling complaint update: $e');
    }
  }

  /// Adds a system notification message to the chat
  void _addSystemMessage(String message) {
    if (mounted) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: message,
            isUser: false,
            timestamp: _getCurrentTime(),
            showActions: false,
            isSystemMessage: true, // Add this property to ChatMessage if needed
          ),
        );
      });
    }
  }

  /// Returns appropriate color for complaint status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return Colors.blue;
      case 'under_review':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
*/

// 4. MODIFY dispose() METHOD (around line 1246):
// ─────────────────────────────────────────────────────────────────────────
/*
  @override
  void dispose() {
    _activeStreamClient?.close();
    _messageController.dispose();
    _scrollController.dispose();
    _speech.stop();
    
    // ADDITION: Clean up real-time subscriptions
    try {
      Supabase.instance.client.removeChannel(_chatRealtimeChannel);
      print('🛑 Removed chat messages subscription');
    } catch (e) {
      print('Warning: Could not remove chat subscription: $e');
    }
    
    try {
      Supabase.instance.client.removeChannel(_complaintsRealtimeChannel);
      print('🛑 Removed complaints subscription');
    } catch (e) {
      print('Warning: Could not remove complaints subscription: $e');
    }
    
    super.dispose();
  }
*/

// 5. IF ChatMessage MODEL DOESN'T HAVE isSystemMessage, ADD IT:
// ─────────────────────────────────────────────────────────────────────────
/*
  In chat_history_model.dart or similar:
  
  class ChatMessage {
    final String text;
    final String? urduText;
    final bool isUser;
    final String timestamp;
    final bool showActions;
    final bool isSystemMessage; // ADD THIS LINE
    
    ChatMessage({
      required this.text,
      this.urduText,
      required this.isUser,
      required this.timestamp,
      this.showActions = false,
      this.isSystemMessage = false, // ADD THIS LINE
    });
  }
*/

// VERIFICATION:
// ─────────────────────────────────────────────────────────────────────────
// After these changes:
// 1. Run: flutter clean && flutter pub get
// 2. Test: Send a message, then use another client (web console) to insert a message
// 3. Verify: New message appears instantly in chat without polling
// 4. Check logs: Should see "✅ Real-time subscription active" and "📨 Received real-time message"
//
// BENEFITS:
// ✅ Instant message delivery (no polling delays)
// ✅ Real-time complaint status updates
// ✅ Better UX for multi-user scenarios
// ✅ Reduced server load (push instead of pull)
// ✅ Works across multiple app instances
