import 'package:flutter/material.dart';
import 'package:front_end/services/llm_service.dart';
import 'package:front_end/models/scenario_model.dart';
import 'package:front_end/models/chat_history_model.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class ChatScreen extends StatefulWidget {
  final ModuleType? selectedModule;

  const ChatScreen({super.key, this.selectedModule});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final LlmService _llmService = LlmService();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _showHistory = false; // Toggle for history sidebar

  // Chat History - static data for now (will be dynamic with database later)
  final List<ChatHistory> _chatHistories = [
    ChatHistory(
      id: '1',
      title: 'Traffic Challan Query',
      previewText: 'I received a traffic challan...',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      messages: [],
    ),
    ChatHistory(
      id: '2',
      title: 'Labour Rights Question',
      previewText: 'What is the minimum wage...',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      messages: [],
    ),
    ChatHistory(
      id: '3',
      title: 'Cyber Crime Help',
      previewText: 'Someone is blackmailing me...',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      messages: [],
    ),
  ];

  // Speech to Text
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = '';

  String _getModuleContextMessage() {
    final module = widget.selectedModule;
    if (module == null) return '';

    switch (module) {
      case ModuleType.traffic:
        return 'You\'re getting help with Road & Traffic Law matters.';
      case ModuleType.womenHarassment:
        return 'You\'re getting help with Women Harassment matters.';
      case ModuleType.cyberCrime:
        return 'You\'re getting help with Cyber Crime (PECA) matters.';
      case ModuleType.labourRights:
        return 'You\'re getting help with Labour Rights matters.';
      default:
        return '';
    }
  }

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();

    // Add initial greeting message
    final contextMsg = _getModuleContextMessage();
    final greeting = contextMsg.isEmpty
        ? 'Assalam-o-Alaikum! I am Legal Sathi, your Pakistani legal assistant. How can I help you today?'
        : 'Assalam-o-Alaikum! I am Legal Sathi, your Pakistani legal assistant. $contextMsg How can I help?';

    _messages.add(
      ChatMessage(
        text: greeting,
        urduText: 'آپ کا قانونی ساتھی حاضر ہے۔ میں آپ کی کیسے مدد کر سکتا ہوں؟',
        isUser: false,
        timestamp: _getCurrentTime(),
        showActions: false,
      ),
    );
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : now.hour;
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${now.minute.toString().padLeft(2, '0')} $period';
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: message,
          isUser: true,
          timestamp: _getCurrentTime(),
          showActions: false,
        ),
      );
      _isLoading = true;
    });

    _messageController.clear();

    try {
      final response = await _llmService.sendMessage(message);

      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              text: response,
              isUser: false,
              timestamp: _getCurrentTime(),
              showActions: false,
            ),
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              text: 'Error: $e',
              isUser: false,
              timestamp: _getCurrentTime(),
              showActions: false,
            ),
          );
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _startListening() async {
    // Request microphone permission
    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone permission is required for voice input'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        setState(() => _isListening = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${error.errorMsg}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );

    if (available) {
      setState(() {
        _isListening = true;
        _recognizedText = '';
      });

      _speech.listen(
        onResult: (result) {
          setState(() {
            _recognizedText = result.recognizedWords;
            _messageController.text = _recognizedText;
          });
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        localeId: 'en_US', // You can change to 'ur_PK' for Urdu
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Speech recognition not available'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  void _toggleListening() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(_showHistory ? Icons.close : Icons.menu, color: Colors.black),
          onPressed: () {
            setState(() {
              _showHistory = !_showHistory;
            });
          },
        ),
        title: const Text(
          'Legal Assistant',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () {
              // Start new chat
              setState(() {
                _messages.clear();
                _showHistory = false;
                final contextMsg = _getModuleContextMessage();
                final greeting = contextMsg.isEmpty
                    ? 'Assalam-o-Alaikum! I am Legal Sathi, your Pakistani legal assistant. How can I help you today?'
                    : 'Assalam-o-Alaikum! I am Legal Sathi, your Pakistani legal assistant. $contextMsg How can I help?';

                _messages.add(
                  ChatMessage(
                    text: greeting,
                    urduText: 'آپ کا قانونی ساتھی حاضر ہے۔ میں آپ کی کیسے مدد کر سکتا ہوں؟',
                    isUser: false,
                    timestamp: _getCurrentTime(),
                    showActions: false,
                  ),
                );
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main chat interface
          Column(
            children: [
              // Chat messages area
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isLoading) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        const Color(0xFF00401A),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text('Legal Sathi is typing...'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return _buildMessageBubble(_messages[index]);
                  },
                ),
              ),

              // Input area
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    // Attachment button
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.attach_file,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                        onPressed: () {
                          // TODO: Handle attachment
                        },
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Microphone button
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _isListening
                            ? const Color(0xFF00401A)
                            : Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color:
                              _isListening ? Colors.white : Colors.grey.shade600,
                          size: 20,
                        ),
                        onPressed: _toggleListening,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Text input field
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(24),
                          border: _isListening
                              ? Border.all(
                                  color: const Color(0xFF00401A), width: 2)
                              : null,
                        ),
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: _isListening
                                ? 'Listening...'
                                : 'Ask about Pakistani law...',
                            hintStyle: TextStyle(
                              color: _isListening
                                  ? const Color(0xFF00401A)
                                  : Colors.grey,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                          ),
                          maxLines: null,
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Send button
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00401A),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send,
                            color: Colors.white, size: 20),
                        onPressed: _isLoading ? null : _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Navigation Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNavItem(Icons.home_outlined, 'Home', false, () {
                          Navigator.pushReplacementNamed(context, '/home_screen');
                        }),
                        _buildNavItem(
                          Icons.chat_bubble_outline,
                          'Chat',
                          true,
                          () {},
                        ),
                        _buildNavItem(
                          Icons.folder_outlined,
                          'Documents',
                          false,
                          () {
                            Navigator.pushReplacementNamed(context, '/documents');
                          },
                        ),
                        _buildNavItem(Icons.person_outline, 'Profile', false, () {
                          Navigator.pushReplacementNamed(context, '/profile');
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // History Sidebar (ChatGPT-style)
          if (_showHistory)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.75,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(2, 0),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // History Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Chat History',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.black),
                            onPressed: () {
                              setState(() {
                                _showHistory = false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    // History List
                    Expanded(
                      child: ListView.builder(
                        itemCount: _chatHistories.length,
                        itemBuilder: (context, index) {
                          final chat = _chatHistories[index];
                          return _buildHistoryItem(chat);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Overlay to close sidebar when tapping outside
          if (_showHistory)
            Positioned.fill(
              left: MediaQuery.of(context).size.width * 0.75,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showHistory = false;
                  });
                },
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
            ),
        ],
      ),
        );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: message.isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: message.isUser ? const Color(0xFF00401A) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.text,
                  style: TextStyle(
                    fontSize: 14,
                    color: message.isUser ? Colors.white : Colors.black87,
                    height: 1.4,
                  ),
                ),
                if (message.urduText != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    message.urduText!,
                    style: TextStyle(
                      fontSize: 13,
                      color: message.isUser
                          ? Colors.white.withOpacity(0.9)
                          : Colors.black54,
                      height: 1.4,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
                if (!message.isUser && message.timestamp != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    message.timestamp!,
                    style: const TextStyle(fontSize: 11, color: Colors.black45),
                  ),
                ],
                if (!message.isUser && message.showActions) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildActionButton('Draft FIR', Icons.description),
                      _buildActionButton('Complaint', Icons.info_outline),
                      _buildActionButton('Listen', Icons.headset),
                      _buildActionButton('Upload', Icons.upload_outlined),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon) {
    return InkWell(
      onTap: () {
        // TODO: Handle action
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.black87),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isActive,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFF00401A) : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? const Color(0xFF00401A) : Colors.grey,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(ChatHistory chat) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0)),
        ),
      ),
      child: ListTile(
        onTap: () {
          // Load this chat conversation
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Loading: ${chat.title}'),
              duration: const Duration(seconds: 1),
            ),
          );
          setState(() {
            _showHistory = false;
          });
        },
        leading: const Icon(
          Icons.chat_bubble_outline,
          color: Color(0xFF00401A),
        ),
        title: Text(
          chat.title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              chat.previewText,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              chat.getFormattedDate(),
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
          onPressed: () {
            _showHistoryOptions(context, chat);
          },
        ),
      ),
    );
  }

  void _showHistoryOptions(BuildContext context, ChatHistory chat) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: Color(0xFF00401A)),
                title: const Text('Rename'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Rename feature coming soon'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteChatConfirmation(context, chat);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteChatConfirmation(BuildContext context, ChatHistory chat) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Chat'),
          content: Text('Are you sure you want to delete "${chat.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Delete feature coming soon'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
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
