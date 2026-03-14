import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:front_end/services/llm_service.dart';
import 'package:front_end/services/agent_service.dart';
import 'package:front_end/models/scenario_model.dart';
import 'package:front_end/models/chat_history_model.dart';
import 'package:front_end/widgets/agent_status_widget.dart';
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
  final AgentService _agentService = AgentService();
  final ScrollController _scrollController = ScrollController();
  late String _conversationId;
  bool _isLoading = false;
  bool _showHistory = false; // Toggle for history sidebar

  // Multi-agent pipeline state — auto-detected per message
  bool _isAgentActive = false;
  AgentPipelineStage _pipelineStage = AgentPipelineStage.idle;

  // Chat History — populated dynamically as conversations happen
  final List<ChatHistory> _chatHistories = [];

  // ── NEW feature state ──────────────────────────────────────────────────────
  String _responseLength = 'detailed'; // 'short' | 'detailed' | 'bullets'
  int? _editingMessageIndex; // index of user message being edited
  int? _streamingMessageIndex; // index of currently-streaming AI message
  http.Client? _activeStreamClient; // cancel by closing this
  bool _stopRequested = false;
  final List<String> _uploadedFiles = []; // names of uploaded files in context
  // ──────────────────────────────────────────────────────────────────────────

  // Speech to Text
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = '';

  // Dynamic case context for productive chat UX
  String _caseIssue = 'General guidance';
  String _caseUrgency = 'Normal';
  bool _caseNeedsEvidence = false;
  bool _caseNeedsPolice = false;
  String _preferredLanguage = 'English';
  List<SuggestedAction> _suggestedActions = const [];

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

  String? _getModuleLabel() {
    switch (widget.selectedModule) {
      case ModuleType.traffic:
        return 'Road & Traffic';
      case ModuleType.womenHarassment:
        return 'Women Harassment';
      case ModuleType.cyberCrime:
        return 'Cyber Crime';
      case ModuleType.labourRights:
        return 'Labour Rights';
      default:
        return null;
    }
  }

  List<String> _getQuickPrompts() {
    switch (widget.selectedModule) {
      case ModuleType.traffic:
        return const [
          'I got a challan, what should I do?',
          'What documents must I carry while driving?',
          'How can I report police misbehavior?',
        ];
      case ModuleType.womenHarassment:
        return const [
          'How do I file a workplace harassment complaint?',
          'What evidence should I collect?',
          'What are my legal rights in this case?',
        ];
      case ModuleType.cyberCrime:
        return const [
          'I am being blackmailed online, what now?',
          'How to file FIA cyber complaint?',
          'How can I preserve digital evidence?',
        ];
      case ModuleType.labourRights:
        return const [
          'My salary is delayed, what are my rights?',
          'How is overtime calculated?',
          'How to file a labour complaint?',
        ];
      default:
        return const [
          'I need legal help with a complaint',
          'What are my rights in Pakistan?',
          'Guide me step by step for my issue',
        ];
    }
  }

  Future<void> _sendQuickPrompt(String prompt) async {
    if (_isLoading) return;
    _messageController.text = prompt;
    await _sendMessage();
  }

  Future<void> _sendSuggestedAction(String prompt) async {
    if (_isLoading) return;
    _messageController.text = prompt;
    await _sendMessage();
  }

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _conversationId = _newConversationId();

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
    if (_isLoading) {
      // Interrupt current generation and start new one
      _stopGeneration();
      await Future.delayed(const Duration(milliseconds: 100));
    }

    final insights = _analyzeQuery(message);
    final useAgentMode = insights.useAgentMode;

    // If editing, replace the old user message and remove its AI response
    if (_editingMessageIndex != null) {
      final editIdx = _editingMessageIndex!;
      _editingMessageIndex = null;
      setState(() {
        _messages[editIdx] = ChatMessage(
          text: message,
          isUser: true,
          timestamp: _getCurrentTime(),
          showActions: false,
        );
        // Remove all messages below the edited user message
        if (editIdx + 1 < _messages.length) {
          _messages.removeRange(editIdx + 1, _messages.length);
        }
      });
    } else {
      setState(() {
        _messages.add(
          ChatMessage(
            text: message,
            isUser: true,
            timestamp: _getCurrentTime(),
            showActions: false,
            attachedFileName: _uploadedFiles.isNotEmpty
                ? _uploadedFiles.last
                : null,
          ),
        );
      });
    }

    _messageController.clear();
    _stopRequested = false;

    setState(() {
      _isLoading = true;
      _caseIssue = insights.caseIssue;
      _caseUrgency = insights.urgency;
      _caseNeedsEvidence = insights.needsEvidence;
      _caseNeedsPolice = insights.needsPolice;
      _preferredLanguage = insights.preferredLanguage;
      _suggestedActions = insights.suggestedActions;
      _isAgentActive = useAgentMode;
      if (useAgentMode) _pipelineStage = AgentPipelineStage.retrieving;
    });
    _scrollToBottom();

    final conversationHistory = _buildConversationHistoryPayload(
      excludeLatestUser: true,
    );

    // ── Multi-agent path (no streaming – complex structured response) ────────
    if (useAgentMode) {
      try {
        final moduleKey = _moduleKeyFromType(widget.selectedModule);
        final agentResult = await _agentService.ask(
          message,
          module: moduleKey,
          conversationId: _conversationId,
          conversationHistory: conversationHistory,
          onStageChanged: (stage) {
            if (mounted) setState(() => _pipelineStage = stage);
          },
        );

        if (mounted && !_stopRequested) {
          setState(() {
            _pipelineStage = AgentPipelineStage.idle;
            _isLoading = false;
            _isAgentActive = false;
            _messages.add(
              ChatMessage(
                text: agentResult.answer,
                isUser: false,
                timestamp: _getCurrentTime(),
                showActions: false,
                agentResponse: agentResult,
              ),
            );
            _saveCurrentChatToHistory();
          });
          _scrollToBottom();
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _pipelineStage = AgentPipelineStage.idle;
            _isLoading = false;
            _isAgentActive = false;
            _messages.add(
              ChatMessage(
                text: 'Something went wrong.\n\nError: $e',
                isUser: false,
                timestamp: _getCurrentTime(),
                showActions: false,
                isError: true,
                errorText: e.toString(),
              ),
            );
            _saveCurrentChatToHistory();
          });
          _scrollToBottom();
        }
      }
      return;
    }

    // ── Streaming RAG path ───────────────────────────────────────────────────
    // Add placeholder streaming message
    final streamingMsg = ChatMessage(
      text: '',
      isUser: false,
      timestamp: _getCurrentTime(),
      showActions: false,
      isStreaming: true,
    );
    setState(() {
      _messages.add(streamingMsg);
      _streamingMessageIndex = _messages.length - 1;
    });
    _scrollToBottom();

    final streamClient = http.Client();
    _activeStreamClient = streamClient;

    try {
      final module = _moduleKeyFromType(widget.selectedModule);
      final stream = _llmService.sendMessageStream(
        message,
        module: module,
        conversationId: _conversationId,
        conversationHistory: conversationHistory,
        responseLength: _responseLength,
        client: streamClient,
      );

      await for (final event in stream) {
        if (!mounted || _stopRequested) break;
        switch (event.type) {
          case StreamEventType.token:
            setState(() {
              _messages[_streamingMessageIndex!].text += event.token!;
            });
            _scrollToBottom();
            break;
          case StreamEventType.meta:
            // meta received – could update source badge here
            break;
          case StreamEventType.error:
            setState(() {
              final idx = _streamingMessageIndex!;
              final errText = _messages[idx].text.isNotEmpty
                  ? _messages[idx].text
                  : 'Error: ${event.error}';
              _messages[idx] = ChatMessage(
                text: errText.isNotEmpty
                    ? errText
                    : 'Something went wrong. Tap Retry.',
                isUser: false,
                timestamp: _getCurrentTime(),
                showActions: false,
                isError: true,
                errorText: event.error,
              );
            });
            break;
          case StreamEventType.done:
            break;
        }
      }
    } catch (e) {
      if (mounted && _streamingMessageIndex != null) {
        setState(() {
          _messages[_streamingMessageIndex!] = ChatMessage(
            text: 'Connection error. Tap Retry.',
            isUser: false,
            timestamp: _getCurrentTime(),
            showActions: false,
            isError: true,
            errorText: e.toString(),
          );
        });
      }
    } finally {
      _activeStreamClient = null;
      if (mounted) {
        setState(() {
          if (_streamingMessageIndex != null &&
              _streamingMessageIndex! < _messages.length) {
            _messages[_streamingMessageIndex!].isStreaming = false;
          }
          _streamingMessageIndex = null;
          _isLoading = false;
          _isAgentActive = false;
          _saveCurrentChatToHistory();
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  bool _containsAny(String text, List<String> keywords) {
    return keywords.any(text.contains);
  }

  QueryInsights _analyzeQuery(String message) {
    final queryLower = message.toLowerCase();
    final selectedModule = _getModuleLabel();

    final hasUrduScript = RegExp(r'[\u0600-\u06FF]').hasMatch(message);
    final hasRomanUrdu = _containsAny(queryLower, const [
      'mujhe',
      'mera',
      'meri',
      'masla',
      'maslaa',
      'shikayat',
      'haq',
      'haqooq',
      'fauran',
      'jaldi',
      'madad',
      'thana',
      'qanoon',
      'zabta',
      'saboot',
      'muqadma',
    ]);

    final preferredLanguage =
        hasUrduScript || hasRomanUrdu || queryLower.contains('urdu')
        ? 'Urdu'
        : 'English';

    String caseIssue = selectedModule ?? 'General guidance';

    if (_containsAny(queryLower, const [
      'blackmail',
      'hack',
      'scam',
      'online',
    ])) {
      caseIssue = 'Cyber safety';
    } else if (_containsAny(queryLower, const [
      'harassment',
      'workplace',
      'stalking',
      'threaten',
      'abuse',
    ])) {
      caseIssue = 'Harassment protection';
    } else if (_containsAny(queryLower, const [
      'salary',
      'overtime',
      'wage',
      'termination',
      'fired',
      'employer',
    ])) {
      caseIssue = 'Labour rights';
    } else if (_containsAny(queryLower, const [
      'challan',
      'driving',
      'license',
      'accident',
      'traffic',
    ])) {
      caseIssue = 'Traffic law';
    }

    final urgency =
        _containsAny(queryLower, const [
          'urgent',
          'immediately',
          'asap',
          'emergency',
          'fauran',
          'jaldi',
          'abhi',
          'immediate',
        ])
        ? 'Urgent'
        : 'Normal';

    final needsPolice = _containsAny(queryLower, const [
      'police',
      'fir',
      'thana',
      'fia',
      'helpline',
      '1099',
      '15',
    ]);

    final needsEvidence = _containsAny(queryLower, const [
      'evidence',
      'proof',
      'screenshot',
      'recording',
      'witness',
      'document',
      'saboot',
    ]);

    final suggestedActions = _buildSuggestedActions(
      queryLower: queryLower,
      preferredLanguage: preferredLanguage,
      caseIssue: caseIssue,
      urgency: urgency,
      needsPolice: needsPolice,
      needsEvidence: needsEvidence,
    );

    return QueryInsights(
      caseIssue: caseIssue,
      urgency: urgency,
      needsEvidence: needsEvidence,
      needsPolice: needsPolice,
      preferredLanguage: preferredLanguage,
      suggestedActions: suggestedActions,
      useAgentMode: _shouldUseAgentMode(message),
    );
  }

  List<SuggestedAction> _buildSuggestedActions({
    required String queryLower,
    required String preferredLanguage,
    required String caseIssue,
    required String urgency,
    required bool needsPolice,
    required bool needsEvidence,
  }) {
    final actions = <SuggestedAction>[];

    void addAction(SuggestedAction action) {
      if (actions.any((a) => a.label == action.label)) return;
      actions.add(action);
    }

    addAction(
      SuggestedAction(
        label: preferredLanguage == 'Urdu' ? 'اردو رہنمائی' : 'Urdu guidance',
        prompt:
            'Please respond in simple Urdu with step-by-step legal guidance for Pakistan.',
        icon: Icons.translate,
      ),
    );

    if (caseIssue == 'Cyber safety') {
      addAction(
        SuggestedAction(
          label: 'FIA complaint steps',
          prompt:
              'Give me exact FIA cyber crime complaint steps in Pakistan with timeline and office links.',
          icon: Icons.security,
        ),
      );
      addAction(
        SuggestedAction(
          label: 'Evidence checklist',
          prompt:
              'Create a digital evidence checklist for this cyber case and what to avoid doing.',
          icon: Icons.fact_check_outlined,
        ),
      );
    } else if (caseIssue == 'Harassment protection') {
      addAction(
        SuggestedAction(
          label: 'Draft complaint',
          prompt:
              'Draft a formal harassment complaint template I can submit in Pakistan.',
          icon: Icons.description_outlined,
        ),
      );
      addAction(
        SuggestedAction(
          label: 'Immediate safety',
          prompt:
              'What immediate safety steps should I take right now in this harassment case?',
          icon: Icons.health_and_safety_outlined,
        ),
      );
    } else if (caseIssue == 'Labour rights') {
      addAction(
        SuggestedAction(
          label: 'Salary recovery plan',
          prompt:
              'Give me step-by-step plan to recover unpaid salary in Pakistan including labour office process.',
          icon: Icons.account_balance_outlined,
        ),
      );
      addAction(
        SuggestedAction(
          label: 'Draft labour complaint',
          prompt:
              'Draft a labour complaint letter for my employer with legal references.',
          icon: Icons.note_alt_outlined,
        ),
      );
    } else if (caseIssue == 'Traffic law') {
      addAction(
        SuggestedAction(
          label: 'Challan challenge',
          prompt:
              'How can I challenge an unfair traffic challan in Pakistan? Give exact procedure.',
          icon: Icons.gavel,
        ),
      );
      addAction(
        SuggestedAction(
          label: 'Required documents',
          prompt:
              'List all driving and vehicle documents I must carry in Pakistan.',
          icon: Icons.folder_copy_outlined,
        ),
      );
    } else {
      addAction(
        SuggestedAction(
          label: 'Know my rights',
          prompt:
              'Explain my legal rights in Pakistan in simple terms based on this issue.',
          icon: Icons.menu_book_outlined,
        ),
      );
      addAction(
        SuggestedAction(
          label: 'Step-by-step plan',
          prompt:
              'Give me a practical step-by-step legal action plan for this issue in Pakistan.',
          icon: Icons.alt_route,
        ),
      );
    }

    if (needsEvidence || _containsAny(queryLower, const ['proof', 'saboot'])) {
      addAction(
        SuggestedAction(
          label: 'Proof I should collect',
          prompt:
              'List all evidence and documents I should collect for this case and their format.',
          icon: Icons.collections_bookmark_outlined,
        ),
      );
    }

    if (needsPolice) {
      addAction(
        SuggestedAction(
          label: 'Police route',
          prompt:
              'Tell me when to go to police/FIA, what to say, and what documents to carry.',
          icon: Icons.local_police_outlined,
        ),
      );
    }

    if (urgency == 'Urgent' || needsPolice) {
      addAction(
        SuggestedAction(
          label: 'Emergency help now',
          prompt:
              'Give immediate emergency safety steps in Pakistan and relevant helplines (Police 15, Legal aid 1099, FIA cybercrime where relevant).',
          icon: Icons.emergency_outlined,
        ),
      );
    }

    return actions.take(4).toList();
  }

  void _resetCaseInsights() {
    _caseIssue = 'General guidance';
    _caseUrgency = 'Normal';
    _caseNeedsEvidence = false;
    _caseNeedsPolice = false;
    _preferredLanguage = 'English';
    _suggestedActions = const [];
  }

  // ── Save current chat to history ──────────────────────────────────────────
  void _saveCurrentChatToHistory() {
    final userMsgs = _messages.where((m) => m.isUser).toList();
    if (userMsgs.isEmpty) return;
    final firstUserText = userMsgs.first.text;
    final title = firstUserText.length > 42
        ? '${firstUserText.substring(0, 39)}...'
        : firstUserText;
    final snapshot = _messages.map((m) => _cloneMessage(m)).toList();
    final existingIdx = _chatHistories.indexWhere(
      (h) => h.id == _conversationId,
    );
    if (existingIdx >= 0) {
      _chatHistories[existingIdx] = ChatHistory(
        id: _conversationId,
        title: title,
        previewText: firstUserText,
        timestamp: DateTime.now(),
        messages: snapshot,
      );
    } else {
      _chatHistories.insert(
        0,
        ChatHistory(
          id: _conversationId,
          title: title,
          previewText: firstUserText,
          timestamp: DateTime.now(),
          messages: snapshot,
        ),
      );
    }
  }

  ChatMessage _cloneMessage(ChatMessage message) {
    return ChatMessage(
      text: message.text,
      urduText: message.urduText,
      isUser: message.isUser,
      timestamp: message.timestamp,
      showActions: message.showActions,
      agentResponse: message.agentResponse,
      isError: message.isError,
      rating: message.rating,
      errorText: message.errorText,
      isStreaming: message.isStreaming,
      attachedFileName: message.attachedFileName,
    );
  }

  // ── Stop generation ────────────────────────────────────────────────────────
  void _stopGeneration() {
    _stopRequested = true;
    _activeStreamClient?.close();
    _activeStreamClient = null;
    if (_streamingMessageIndex != null &&
        _streamingMessageIndex! < _messages.length) {
      setState(() {
        _messages[_streamingMessageIndex!].isStreaming = false;
        _streamingMessageIndex = null;
        _isLoading = false;
        _isAgentActive = false;
        _pipelineStage = AgentPipelineStage.idle;
      });
    } else {
      setState(() {
        _isLoading = false;
        _streamingMessageIndex = null;
      });
    }
  }

  // ── Copy message text to clipboard ─────────────────────────────────────────
  void _copyMessage(ChatMessage msg) {
    Clipboard.setData(ClipboardData(text: msg.text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard'),
        backgroundColor: const Color(0xFF00401A),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── Delete a message ───────────────────────────────────────────────────────
  void _deleteMessage(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete message?'),
        content: const Text('This message will be removed from the chat.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                // Remove the message and potentially its paired response
                if (index < _messages.length) {
                  _messages.removeAt(index);
                  // If this was a user message and the next is an AI reply, remove pair
                  if (index < _messages.length &&
                      index > 0 &&
                      !_messages[index].isUser) {
                    _messages.removeAt(index);
                  }
                }
              });
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ── Edit a user message and re-send ────────────────────────────────────────
  void _editMessage(int index) {
    if (!_messages[index].isUser) return;
    _editingMessageIndex = index;
    _messageController.text = _messages[index].text;
    _messageController.selection = TextSelection.fromPosition(
      TextPosition(offset: _messageController.text.length),
    );
    FocusScope.of(context).requestFocus(FocusNode());
    // Scroll to input area not necessary – it is always visible
  }

  // ── Regenerate (re-run the last user query for an AI message) ─────────────
  Future<void> _regenerateMessage(int aiMessageIndex) async {
    // Find the user message that triggered this AI response
    int? userIndex;
    for (int i = aiMessageIndex - 1; i >= 0; i--) {
      if (_messages[i].isUser) {
        userIndex = i;
        break;
      }
    }
    if (userIndex == null) return;
    if (_isLoading) return;

    final userText = _messages[userIndex].text;
    // Remove the current AI response
    setState(() {
      _messages.removeAt(aiMessageIndex);
    });
    // Put the user text back and re-send
    _messageController.text = userText;
    await _sendMessage();
  }

  // ── Rate message ───────────────────────────────────────────────────────────
  void _rateMessage(int index, int rating) {
    if (index < 0 || index >= _messages.length) return;
    setState(() {
      _messages[index].rating = _messages[index].rating == rating ? 0 : rating;
    });
  }

  // ── Share / export current chat ────────────────────────────────────────────
  Future<void> _exportChat() async {
    try {
      final buf = StringBuffer();
      buf.writeln('Legal Sathi — Chat Export');
      buf.writeln('=' * 45);
      buf.writeln('Exported: ${DateTime.now().toLocal()}');
      buf.writeln();
      for (final msg in _messages) {
        buf.writeln(msg.isUser ? '🧑 You:' : '🤖 Legal Sathi:');
        buf.writeln(msg.text);
        if (msg.timestamp != null) buf.writeln('  (${msg.timestamp})');
        buf.writeln();
      }

      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/legalsathi_chat_${DateTime.now().millisecondsSinceEpoch}.txt',
      );
      await file.writeAsString(buf.toString());
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Legal Sathi Chat Export',
        text: 'Here is my Legal Sathi conversation.',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ── Upload file ────────────────────────────────────────────────────────────
  Future<void> _uploadFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
      );
      if (result == null || result.files.isEmpty) return;
      final fileName = result.files.single.name;
      setState(() {
        _uploadedFiles.add(fileName);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '📎 "$fileName" attached — mention it in your question',
            ),
            backgroundColor: const Color(0xFF00401A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File pick failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ── Show message action bottom sheet ──────────────────────────────────────
  void _showMessageActions(BuildContext ctx, int index) {
    final msg = _messages[index];
    showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.copy_outlined,
                  color: Color(0xFF00401A),
                ),
                title: const Text('Copy'),
                onTap: () {
                  Navigator.pop(ctx);
                  _copyMessage(msg);
                },
              ),
              if (msg.isUser)
                ListTile(
                  leading: const Icon(
                    Icons.edit_outlined,
                    color: Color(0xFF00401A),
                  ),
                  title: const Text('Edit & Resend'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _editMessage(index);
                  },
                ),
              if (!msg.isUser)
                ListTile(
                  leading: const Icon(
                    Icons.refresh_outlined,
                    color: Color(0xFF00401A),
                  ),
                  title: const Text('Regenerate'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _regenerateMessage(index);
                  },
                ),
              ListTile(
                leading: const Icon(
                  Icons.share_outlined,
                  color: Color(0xFF00401A),
                ),
                title: const Text('Share'),
                onTap: () {
                  Navigator.pop(ctx);
                  Share.share(msg.text, subject: 'Legal Sathi Answer');
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _deleteMessage(index);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Show prompt templates ──────────────────────────────────────────────────
  void _showPromptTemplates() {
    const templates = [
      '📋 Explain this law simply:\n',
      '📝 Draft a formal complaint about:\n',
      '⚖️ What are my legal rights regarding:\n',
      '🔍 What evidence should I collect for:\n',
      '📞 What helpline numbers apply to:\n',
      '🏛️ Step-by-step court procedure for:\n',
    ];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'Prompt Templates',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
            ...templates.map(
              (t) => ListTile(
                dense: true,
                title: Text(
                  t.trim(),
                  style: TextStyle(fontSize: 13, color: Colors.black87),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _messageController.text = t;
                  _messageController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _messageController.text.length),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Automatically decides whether to use the full multi-agent pipeline.
  /// Returns true for complex questions that need step-by-step legal guidance.
  bool _shouldUseAgentMode(String message) {
    final q = message.toLowerCase();
    const complexKeywords = [
      // Filing / procedure requests
      'how to file', 'how do i file', 'how to register', 'how to report',
      'what steps', 'step by step', 'procedure', 'process', 'guide me',
      // Legal actions
      'complaint', 'fir', 'case', 'court', 'police', 'fia', 'peca',
      'lawsuit', 'appeal', 'bail', 'warrant', 'notice',
      // Rights & documents
      'my rights', 'what are my rights', 'what documents', 'required documents',
      'legal rights', 'entitled to',
      // Harassment / blackmail
      'blackmail', 'harass', 'threaten', 'stalking', 'harassment',
      // Labour
      'salary is delayed', 'salary delayed', 'overtime', 'termination',
      'fired', 'resign', 'eobi', 'provident fund', 'minimum wage',
      // Traffic
      'challan', 'driving licen', 'accident report',
      // General complex
      'what should i do', 'help me with', 'can i sue',
      'compensation', 'damages', 'action against',
      // Urdu / Roman Urdu (local users)
      'shikayat', 'haqooq', 'haq', 'fauran', 'jaldi', 'thana',
      'saboot', 'qanooni', 'madad karo', 'mujhe kya karna chahiye',
    ];
    return complexKeywords.any((kw) => q.contains(kw));
  }

  String? _moduleKeyFromType(ModuleType? type) {
    switch (type) {
      case ModuleType.womenHarassment:
        return 'women_harassment';
      case ModuleType.labourRights:
        return 'labour_rights';
      case ModuleType.cyberCrime:
        return 'cyber_law';
      case ModuleType.traffic:
        return 'road_laws';
      default:
        return null;
    }
  }

  String _newConversationId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  List<Map<String, String>> _buildConversationHistoryPayload({
    bool excludeLatestUser = false,
    int maxTurns = 12,
  }) {
    List<ChatMessage> candidateMessages = List<ChatMessage>.from(_messages);

    if (excludeLatestUser && candidateMessages.isNotEmpty) {
      final last = candidateMessages.last;
      if (last.isUser) {
        candidateMessages = candidateMessages.sublist(
          0,
          candidateMessages.length - 1,
        );
      }
    }

    final filtered = candidateMessages
        .where((m) => m.text.trim().isNotEmpty)
        .toList();

    final recent = filtered.length > maxTurns
        ? filtered.sublist(filtered.length - maxTurns)
        : filtered;

    return recent
        .map(
          (message) => {
            'role': message.isUser ? 'user' : 'assistant',
            'content': message.text,
          },
        )
        .toList();
  }

  @override
  void dispose() {
    _activeStreamClient?.close();
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
        localeId: _preferredLanguage == 'Urdu' ? 'ur_PK' : 'en_US',
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
    final moduleLabel = _getModuleLabel();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            _showHistory ? Icons.close : Icons.menu,
            color: Colors.black,
          ),
          onPressed: () {
            setState(() {
              _showHistory = !_showHistory;
            });
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Legal Assistant',
              style: TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              _isAgentActive
                  ? 'Deep analysis active…'
                  : '$_preferredLanguage • Your legal assistant',
              style: TextStyle(
                color: _isAgentActive
                    ? const Color(0xFF00401A)
                    : Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          // Export chat
          IconButton(
            icon: const Icon(Icons.download_outlined, color: Colors.black),
            tooltip: 'Export chat',
            onPressed: _exportChat,
          ),
          // New chat
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            tooltip: 'New chat',
            onPressed: () {
              // Start new chat
              setState(() {
                _saveCurrentChatToHistory();
                _messages.clear();
                _conversationId = _newConversationId();
                _showHistory = false;
                _resetCaseInsights();
                final contextMsg = _getModuleContextMessage();
                final greeting = contextMsg.isEmpty
                    ? 'Assalam-o-Alaikum! I am Legal Sathi, your Pakistani legal assistant. How can I help you today?'
                    : 'Assalam-o-Alaikum! I am Legal Sathi, your Pakistani legal assistant. $contextMsg How can I help?';

                _messages.add(
                  ChatMessage(
                    text: greeting,
                    urduText:
                        'آپ کا قانونی ساتھی حاضر ہے۔ میں آپ کی کیسے مدد کر سکتا ہوں؟',
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
              if (moduleLabel != null || _messages.any((m) => m.isUser))
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (moduleLabel != null)
                        _buildContextChip(
                          icon: Icons.dashboard_customize_outlined,
                          text: moduleLabel,
                          isHighlighted: true,
                        ),
                      if (_messages.any((m) => m.isUser))
                        _buildContextChip(
                          icon: Icons.topic_outlined,
                          text: _caseIssue,
                        ),
                      if (_messages.any((m) => m.isUser))
                        _buildContextChip(
                          icon: Icons.timer_outlined,
                          text: _caseUrgency,
                          isHighlighted: _caseUrgency == 'Urgent',
                        ),
                      if (_caseNeedsEvidence)
                        _buildContextChip(
                          icon: Icons.fact_check_outlined,
                          text: 'Evidence needed',
                        ),
                      if (_caseNeedsPolice)
                        _buildContextChip(
                          icon: Icons.local_police_outlined,
                          text: 'Police/FIA route',
                        ),
                    ],
                  ),
                ),

              // Chat messages area
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isLoading) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child:
                            _isAgentActive &&
                                _pipelineStage != AgentPipelineStage.idle
                            ? AgentStatusWidget(currentStage: _pipelineStage)
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE6EFEA),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.smart_toy,
                                      size: 16,
                                      color: Color(0xFF00401A),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const _TypingDots(),
                                  ),
                                ],
                              ),
                      );
                    }
                    return _buildMessageBubble(_messages[index]);
                  },
                ),
              ),

              if (_messages.length <= 1 && !_isLoading)
                Container(
                  width: double.infinity,
                  color: const Color(0xFFF5F5F5),
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _getQuickPrompts().map((prompt) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => _sendQuickPrompt(prompt),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Text(
                                prompt,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

              if (_suggestedActions.isNotEmpty && !_isLoading)
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _suggestedActions.map((action) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => _sendSuggestedAction(action.prompt),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE6EFEA),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    action.icon,
                                    size: 15,
                                    color: const Color(0xFF00401A),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    action.label,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF00401A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

              // ── Input area ─────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Response Length + Attachment row ──────────────────
                    if (_uploadedFiles.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                        child: Wrap(
                          spacing: 6,
                          children: _uploadedFiles
                              .map(
                                (f) => Chip(
                                  label: Text(
                                    f,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  deleteIcon: const Icon(Icons.close, size: 14),
                                  onDeleted: () =>
                                      setState(() => _uploadedFiles.remove(f)),
                                  backgroundColor: const Color(0xFFE6EFEA),
                                  labelStyle: const TextStyle(
                                    color: Color(0xFF00401A),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    // Response length selector
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                      child: Row(
                        children: [
                          Text(
                            'Response:',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ...[
                            ('Short', 'short'),
                            ('Detailed', 'detailed'),
                            ('Bullets', 'bullets'),
                          ].map((e) {
                            final isSelected = _responseLength == e.$2;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _responseLength = e.$2),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF00401A)
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    e.$1,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black54,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                          const Spacer(),
                          // Template button
                          IconButton(
                            icon: Icon(
                              Icons.text_snippet_outlined,
                              size: 18,
                              color: const Color(0xFF00401A),
                            ),
                            tooltip: 'Templates',
                            onPressed: _showPromptTemplates,
                          ),
                          // File upload button
                          IconButton(
                            icon: Icon(
                              Icons.attach_file_outlined,
                              size: 18,
                              color: const Color(0xFF00401A),
                            ),
                            tooltip: 'Attach file',
                            onPressed: _uploadFile,
                          ),
                        ],
                      ),
                    ),
                    // ── Message text input ─────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
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
                                color: _isListening
                                    ? Colors.white
                                    : Colors.grey.shade600,
                                size: 20,
                              ),
                              onPressed: _toggleListening,
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Text input field
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(24),
                                border: _isListening
                                    ? Border.all(
                                        color: const Color(0xFF00401A),
                                        width: 2,
                                      )
                                    : (_editingMessageIndex != null
                                          ? Border.all(
                                              color: Colors.orange,
                                              width: 2,
                                            )
                                          : null),
                              ),
                              child: TextField(
                                controller: _messageController,
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                                decoration: InputDecoration(
                                  hintText: _isListening
                                      ? 'Listening...'
                                      : (_editingMessageIndex != null
                                            ? '✏️ Editing message...'
                                            : 'Ask about Pakistani law...'),
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
                                  prefixIcon: _editingMessageIndex != null
                                      ? const Icon(
                                          Icons.edit,
                                          size: 16,
                                          color: Colors.orange,
                                        )
                                      : null,
                                ),
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                textInputAction: TextInputAction.newline,
                                onSubmitted: (_) {},
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Stop / Send button
                          if (_isLoading)
                            GestureDetector(
                              onTap: _stopGeneration,
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.red.shade600,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.stop_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            )
                          else
                            GestureDetector(
                              onTap: _sendMessage,
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF00401A),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.send_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                        ],
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
                      color: Colors.grey.withValues(alpha: 0.1),
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
                          Navigator.pushReplacementNamed(
                            context,
                            '/home_screen',
                          );
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
                            Navigator.pushReplacementNamed(
                              context,
                              '/documents',
                            );
                          },
                        ),
                        _buildNavItem(
                          Icons.person_outline,
                          'Profile',
                          false,
                          () {
                            Navigator.pushReplacementNamed(context, '/profile');
                          },
                        ),
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
                      color: Colors.black.withValues(alpha: 0.1),
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
                child: Container(color: Colors.black.withValues(alpha: 0.3)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final idx = _messages.indexOf(message);
    final isAgentMsg = !message.isUser && message.agentResponse != null;
    final isAssistantMessage = !message.isUser;
    final surfaceColor = Colors.white;
    final userBubbleColor = const Color(0xFF00401A);
    final textColor = Colors.black87;

    return GestureDetector(
      onLongPress: () => _showMessageActions(context, idx),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment: message.isUser
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isAssistantMessage)
              Container(
                width: 30,
                height: 30,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(
                  color: Color(0xFFE6EFEA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.smart_toy,
                  size: 16,
                  color: Color(0xFF00401A),
                ),
              ),
            if (isAssistantMessage) const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: message.isUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  // ── Bubble ────────────────────────────────────────────
                  Container(
                    constraints: BoxConstraints(
                      maxWidth:
                          MediaQuery.of(context).size.width *
                          (isAgentMsg ? 0.95 : 0.80),
                    ),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: message.isUser ? userBubbleColor : surfaceColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(message.isUser ? 16 : 6),
                        bottomRight: Radius.circular(message.isUser ? 6 : 16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: message.isError
                          ? Border.all(color: Colors.red.shade300, width: 1.5)
                          : null,
                    ),
                    child: isAgentMsg
                        ? AgentResponseCard(
                            summary: message.agentResponse!.summary,
                            keyPoints: message.agentResponse!.keyPoints,
                            steps: message.agentResponse!.steps
                                .map(
                                  (s) => {
                                    'step_number': s.stepNumber,
                                    'title': s.title,
                                    'description': s.description,
                                    'tips': s.tips,
                                  },
                                )
                                .toList(),
                            requiredDocuments:
                                message.agentResponse!.requiredDocuments,
                            officialLinks: message.agentResponse!.officialLinks,
                            notes: message.agentResponse!.notes,
                            elapsedSeconds:
                                message.agentResponse!.elapsedSeconds,
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // File attachment badge
                              if (message.attachedFileName != null) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.attach_file,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        message.attachedFileName!,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                              ],
                              // Message text — markdown for AI, plain for user
                              if (isAssistantMessage && !message.isError)
                                _StreamingMarkdown(
                                  data: message.text,
                                  isStreaming: message.isStreaming,
                                  textColor: textColor,
                                )
                              else if (message.isError)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          size: 16,
                                          color: Colors.red.shade400,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Something went wrong',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Colors.red.shade600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (message.text.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        message.text,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 10),
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        // Find the user message above and retry
                                        for (int i = idx - 1; i >= 0; i--) {
                                          if (_messages[i].isUser) {
                                            setState(
                                              () => _messages.removeAt(idx),
                                            );
                                            _messageController.text =
                                                _messages[math.min(
                                                      i,
                                                      _messages.length - 1,
                                                    )]
                                                    .text;
                                            _sendMessage();
                                            return;
                                          }
                                        }
                                      },
                                      icon: const Icon(Icons.refresh, size: 14),
                                      label: const Text(
                                        'Retry',
                                        style: TextStyle(fontSize: 13),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(
                                          0xFF00401A,
                                        ),
                                        side: const BorderSide(
                                          color: Color(0xFF00401A),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Text(
                                  message.text,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: message.isUser
                                        ? Colors.white
                                        : textColor,
                                    height: 1.45,
                                  ),
                                ),
                              if (message.urduText != null &&
                                  message.agentResponse == null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  message.urduText!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: message.isUser
                                        ? Colors.white.withValues(alpha: 0.9)
                                        : Colors.black54,
                                    height: 1.4,
                                  ),
                                  textDirection: TextDirection.rtl,
                                ),
                              ],
                              if (!message.isUser && message.showActions) ...[
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _buildActionButton(
                                      'Draft FIR',
                                      Icons.description,
                                      prompt:
                                          'Draft a complete FIR template in Pakistan format based on this case.',
                                    ),
                                    _buildActionButton(
                                      'Complaint draft',
                                      Icons.info_outline,
                                      prompt:
                                          'Draft an official complaint letter in formal Urdu and English.',
                                    ),
                                    _buildActionButton(
                                      'Urdu explain',
                                      Icons.translate,
                                      prompt:
                                          'Explain the above answer in simple Urdu and short bullet points.',
                                    ),
                                    _buildActionButton(
                                      'Upload',
                                      Icons.upload_outlined,
                                      prompt:
                                          'Tell me which documents and proof I should upload first for this case.',
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                  ),

                  // ── Relevance badge ──────────────────────────────────────
                  if (message.agentResponse != null &&
                      message.agentResponse!.relevanceScore > 0) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6EFEA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '🎯 Relevance ${((message.agentResponse!.relevanceScore) * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF00401A),
                        ),
                      ),
                    ),
                  ],

                  // ── Message action bar ───────────────────────────────────
                  if (!message.isStreaming) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Copy
                        _MsgActionBtn(
                          icon: Icons.copy_outlined,
                          tooltip: 'Copy',
                          onTap: () => _copyMessage(message),
                        ),
                        if (message.isUser) ...[
                          const SizedBox(width: 4),
                          _MsgActionBtn(
                            icon: Icons.edit_outlined,
                            tooltip: 'Edit',
                            onTap: () => _editMessage(idx),
                          ),
                        ],
                        if (isAssistantMessage && !message.isUser) ...[
                          const SizedBox(width: 4),
                          _MsgActionBtn(
                            icon: Icons.refresh_outlined,
                            tooltip: 'Regenerate',
                            onTap: () => _regenerateMessage(idx),
                          ),
                          const SizedBox(width: 4),
                          // 👍
                          _MsgActionBtn(
                            icon: Icons.thumb_up_outlined,
                            tooltip: 'Helpful',
                            color: message.rating == 1
                                ? const Color(0xFF00401A)
                                : null,
                            onTap: () => _rateMessage(idx, 1),
                          ),
                          const SizedBox(width: 4),
                          // 👎
                          _MsgActionBtn(
                            icon: Icons.thumb_down_outlined,
                            tooltip: 'Not helpful',
                            color: message.rating == -1 ? Colors.red : null,
                            onTap: () => _rateMessage(idx, -1),
                          ),
                        ],
                        const SizedBox(width: 4),
                        _MsgActionBtn(
                          icon: Icons.share_outlined,
                          tooltip: 'Share',
                          onTap: () => Share.share(
                            message.text,
                            subject: 'Legal Sathi Answer',
                          ),
                        ),
                        const SizedBox(width: 4),
                        _MsgActionBtn(
                          icon: Icons.delete_outline,
                          tooltip: 'Delete',
                          color: Colors.red.shade300,
                          onTap: () => _deleteMessage(idx),
                        ),
                        // Timestamp
                        if (message.timestamp != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            message.timestamp!,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ] else ...[
                    if (message.timestamp != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        message.timestamp!,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, {String? prompt}) {
    return InkWell(
      onTap: () {
        if (prompt == null || prompt.trim().isEmpty) return;
        _sendSuggestedAction(prompt);
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

  Widget _buildContextChip({
    required IconData icon,
    required String text,
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isHighlighted
            ? const Color(0xFF00401A)
            : const Color(0xFFEFF3F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isHighlighted ? Colors.white : const Color(0xFF00401A),
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: isHighlighted ? Colors.white : const Color(0xFF00401A),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
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
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE6EFEA) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFF00401A) : Colors.grey,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? const Color(0xFF00401A) : Colors.grey,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(ChatHistory chat) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: ListTile(
        onTap: () {
          // Load this chat conversation
          // Save current conversation first, then load the selected one
          _saveCurrentChatToHistory();
          setState(() {
            _conversationId = chat.id;
            _showHistory = false;
            _resetCaseInsights();
            _messages.clear();
            // Restore all messages from the history snapshot
            for (final m in chat.messages) {
              if (m is ChatMessage) _messages.add(_cloneMessage(m));
            }
            // If somehow empty, add a greeting
            if (_messages.isEmpty) {
              _messages.add(
                ChatMessage(
                  text: 'Previous conversation loaded.',
                  isUser: false,
                  timestamp: _getCurrentTime(),
                  showActions: false,
                ),
              );
            }
          });
          _scrollToBottom();
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
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              chat.getFormattedDate(),
              style: const TextStyle(fontSize: 11, color: Colors.grey),
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
                leading: const Icon(
                  Icons.edit_outlined,
                  color: Color(0xFF00401A),
                ),
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
                title: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
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
                setState(() {
                  _chatHistories.removeWhere((h) => h.id == chat.id);
                  if (_conversationId == chat.id) {
                    _messages.clear();
                    _conversationId = _newConversationId();
                    final contextMsg = _getModuleContextMessage();
                    final greeting = contextMsg.isEmpty
                        ? 'Assalam-o-Alaikum! I am Legal Sathi, your Pakistani legal assistant. How can I help you today?'
                        : 'Assalam-o-Alaikum! I am Legal Sathi, your Pakistani legal assistant. $contextMsg How can I help?';
                    _messages.add(
                      ChatMessage(
                        text: greeting,
                        urduText:
                            'آپ کا قانونی ساتھی حاضر ہے۔ میں آپ کی کیسے مدد کر سکتا ہوں؟',
                        isUser: false,
                        timestamp: _getCurrentTime(),
                        showActions: false,
                      ),
                    );
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Chat deleted'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

class ChatMessage {
  String text; // mutable: streaming builds it up
  final String? urduText;
  final bool isUser;
  final String? timestamp;
  final bool showActions;
  final AgentResponse? agentResponse;
  // ── New feature fields ────────────────────────────────────────────────────
  final bool isError; // show retry button
  int rating; // -1 = 👎  0 = none  1 = 👍
  final String? errorText; // original error details
  bool isStreaming; // currently receiving tokens
  String? attachedFileName; // name of file user uploaded with this message

  ChatMessage({
    required this.text,
    this.urduText,
    required this.isUser,
    this.timestamp,
    this.showActions = true,
    this.agentResponse,
    this.isError = false,
    this.rating = 0,
    this.errorText,
    this.isStreaming = false,
    this.attachedFileName,
  });
}

class SuggestedAction {
  final String label;
  final String prompt;
  final IconData icon;

  const SuggestedAction({
    required this.label,
    required this.prompt,
    required this.icon,
  });
}

class QueryInsights {
  final String caseIssue;
  final String urgency;
  final bool needsEvidence;
  final bool needsPolice;
  final String preferredLanguage;
  final List<SuggestedAction> suggestedActions;
  final bool useAgentMode;

  const QueryInsights({
    required this.caseIssue,
    required this.urgency,
    required this.needsEvidence,
    required this.needsPolice,
    required this.preferredLanguage,
    required this.suggestedActions,
    required this.useAgentMode,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Three animated bouncing dots: "Legal Sathi is thinking…"
class _TypingDots extends StatefulWidget {
  const _TypingDots();
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i / 3.0;
            final progress = ((_ctrl.value - delay + 1.0) % 1.0);
            final opacity = progress < 0.5 ? progress * 2 : 2 - progress * 2;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Opacity(
                opacity: 0.3 + 0.7 * opacity,
                child: const CircleAvatar(
                  radius: 4,
                  backgroundColor: Color(0xFF00401A),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

/// Renders AI response text as Markdown.
/// While [isStreaming] is true a blinking cursor `▌` is appended.
class _StreamingMarkdown extends StatefulWidget {
  final String data;
  final bool isStreaming;
  final Color textColor;

  const _StreamingMarkdown({
    required this.data,
    required this.isStreaming,
    required this.textColor,
  });

  @override
  State<_StreamingMarkdown> createState() => _StreamingMarkdownState();
}

class _StreamingMarkdownState extends State<_StreamingMarkdown>
    with SingleTickerProviderStateMixin {
  late AnimationController _blink;

  @override
  void initState() {
    super.initState();
    _blink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 530),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isStreaming) {
      return MarkdownBody(
        data: widget.data.isEmpty ? ' ' : widget.data,
        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
          p: TextStyle(fontSize: 14, color: widget.textColor, height: 1.5),
          code: TextStyle(
            fontSize: 13,
            backgroundColor: Colors.grey.shade200,
            color: const Color(0xFF00401A),
          ),
          blockquote: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        selectable: true,
      );
    }
    return AnimatedBuilder(
      animation: _blink,
      builder: (_, __) {
        final cursor = _blink.value > 0.5 ? '▌' : '';
        final displayData = widget.data.isEmpty ? cursor : widget.data + cursor;
        return MarkdownBody(
          data: displayData,
          styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
            p: TextStyle(fontSize: 14, color: widget.textColor, height: 1.5),
          ),
          selectable: false,
        );
      },
    );
  }
}

/// Small icon-only action button under a message.
class _MsgActionBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color? color;

  const _MsgActionBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 15, color: color ?? Colors.grey.shade500),
        ),
      ),
    );
  }
}
