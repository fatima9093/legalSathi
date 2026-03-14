import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

// ─── Stream event types ───────────────────────────────────────────────────────

enum StreamEventType { token, meta, error, done }

class StreamEvent {
  final StreamEventType type;
  final String? token;
  final Map<String, dynamic>? meta;
  final String? error;
  const StreamEvent({required this.type, this.token, this.meta, this.error});
}

// ─── LlmService ──────────────────────────────────────────────────────────────

class LlmService {
  // 🔥 NEW: Backend RAG API endpoint
  // Change this to your backend URL
  // - For local development: http://localhost:8000/api/ask
  // - For production: https://your-backend-url.com/api/ask
  static const String _backendUrl = 'http://localhost:8000/api/ask';
  static const String _streamUrl = 'http://localhost:8000/api/ask/stream';

  // For checking backend health
  static const String _healthUrl = 'http://localhost:8000';

  /// Send message to RAG backend and get response
  ///
  /// Flow:
  /// 1. Backend searches Vector DB (your PDFs) first
  /// 2. If good match found → returns answer from documents
  /// 3. If no match → uses Groq as fallback
  Future<String> sendMessage(
    String userMessage, {
    String? module,
    String? conversationId,
    List<Map<String, String>>? conversationHistory,
  }) async {
    try {
      final payload = <String, dynamic>{
        'question': userMessage,
        if (module != null) 'module': module,
        if (conversationId != null && conversationId.trim().isNotEmpty)
          'conversation_id': conversationId.trim(),
        if (conversationHistory != null && conversationHistory.isNotEmpty)
          'conversation_history': conversationHistory,
      };

      final response = await http.post(
        Uri.parse(_backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final answer = data['answer'] as String;
        final source = data['source'] as String;
        final verificationStatus =
            data['verification_status'] as String? ?? 'unverified';
        final verificationNote = data['verification_note'] as String?;
        final requiresOfficialConfirmation =
            data['requires_official_confirmation'] as bool? ?? true;
        final freshnessStatus =
            data['freshness_status'] as String? ?? 'unknown';
        final trustedSourceRatio =
            (data['trusted_source_ratio'] as num?)?.toDouble() ?? 0.0;
        final relevanceScore =
            (data['relevance_score'] as num?)?.toDouble() ?? 0.0;
        final lastUpdated = data['last_updated'] as String?;

        // Add source indicator for transparency
        String sourceIndicator = '';
        if (source == 'vector_db') {
          final module = data['module'];
          final file = data['file'];
          sourceIndicator =
              '\n\n📚 Source: $file (${_formatModuleName(module)})';
        } else if (source == 'groq_fallback') {
          sourceIndicator =
              '\n\n⚠️ Note: No specific documents found. This is general legal information.';
        }

        String verificationIndicator = '';
        if (verificationStatus == 'verified') {
          verificationIndicator =
              '\n\n✅ Verification: Verified ($freshnessStatus, trusted ${(trustedSourceRatio * 100).toStringAsFixed(0)}%)';
        } else {
          verificationIndicator =
              '\n\n⚠️ Verification: Needs confirmation with latest official notification.';
        }

        verificationIndicator +=
            '\n🎯 Relevance: ${(relevanceScore * 100).toStringAsFixed(0)}%';

        if (verificationNote != null && verificationNote.trim().isNotEmpty) {
          verificationIndicator += '\n$verificationNote';
        }

        if (lastUpdated != null && lastUpdated.trim().isNotEmpty) {
          verificationIndicator += '\nLast updated evidence: $lastUpdated';
        }

        if (requiresOfficialConfirmation) {
          verificationIndicator +=
              '\nBefore final legal action, cross-check latest gazette/department update or consult a licensed lawyer.';
        }

        return answer + sourceIndicator + verificationIndicator;
      } else if (response.statusCode == 500) {
        return '❌ Backend error. Please make sure the backend server is running.\n\nRun: python main.py in the backend folder';
      } else {
        return '❌ Error: ${response.statusCode}\n\nResponse: ${response.body}';
      }
    } catch (e) {
      // Connection error - backend not running
      if (e.toString().contains('Failed host lookup') ||
          e.toString().contains('Connection refused')) {
        return '''❌ Cannot connect to Legal Sathi backend.

Please start the backend server:

1. Open terminal in backend folder
2. Run: python main.py
3. Wait for "🚀 Starting Legal Sathi RAG API..."
4. Then try again

Error: $e''';
      }

      return 'Error connecting to Legal Sathi backend.\n\nError: $e';
    }
  }

  /// Stream tokens from the backend SSE streaming endpoint.
  ///
  /// Yields [StreamEvent] objects:
  ///   • type == token  → append [token] to the displayed text
  ///   • type == meta   → [meta] map with source, confidence, etc.
  ///   • type == error  → [error] string
  ///   • type == done   → stream complete
  ///
  /// Pass [client] to control cancellation — call client.close() to stop.
  Stream<StreamEvent> sendMessageStream(
    String userMessage, {
    String? module,
    String? conversationId,
    List<Map<String, String>>? conversationHistory,
    String responseLength = 'detailed',
    http.Client? client,
  }) async* {
    final ownClient = client == null;
    final httpClient = client ?? http.Client();
    bool doneSent = false;
    try {
      final payload = <String, dynamic>{
        'question': userMessage,
        if (module != null) 'module': module,
        if (conversationId != null && conversationId.trim().isNotEmpty)
          'conversation_id': conversationId.trim(),
        if (conversationHistory != null && conversationHistory.isNotEmpty)
          'conversation_history': conversationHistory,
        'response_length': responseLength,
      };

      final request = http.Request('POST', Uri.parse(_streamUrl));
      request.headers['Content-Type'] = 'application/json';
      request.headers['Accept'] = 'text/event-stream';
      request.body = jsonEncode(payload);

      final streamed = await httpClient.send(request);

      String buffer = '';
      await for (final bytes in streamed.stream) {
        buffer += utf8.decode(bytes);
        final lines = buffer.split('\n');
        // Keep last partial line in buffer
        buffer = lines.removeLast();
        for (final line in lines) {
          final trimmed = line.trim();
          if (!trimmed.startsWith('data: ')) continue;
          final payload = trimmed.substring(6).trim();
          if (payload == '[DONE]') {
            doneSent = true;
            yield const StreamEvent(type: StreamEventType.done);
            return;
          }
          try {
            final json = jsonDecode(payload) as Map<String, dynamic>;
            if (json.containsKey('token')) {
              yield StreamEvent(
                type: StreamEventType.token,
                token: json['token'] as String,
              );
            } else if (json.containsKey('meta')) {
              yield StreamEvent(
                type: StreamEventType.meta,
                meta: json['meta'] as Map<String, dynamic>,
              );
            } else if (json.containsKey('error')) {
              yield StreamEvent(
                type: StreamEventType.error,
                error: json['error'] as String,
              );
            }
          } catch (_) {
            // ignore malformed JSON lines
          }
        }
      }
    } catch (e) {
      yield StreamEvent(type: StreamEventType.error, error: e.toString());
    } finally {
      if (ownClient) httpClient.close();
      if (!doneSent) {
        yield const StreamEvent(type: StreamEventType.done);
      }
    }
  }

  /// Check if backend is running
  Future<Map<String, dynamic>> checkBackendHealth() async {
    try {
      final response = await http.get(Uri.parse(_healthUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'status': 'online',
          'vector_db_loaded': data['vector_db_loaded'] ?? false,
          'total_documents': data['total_documents'] ?? 0,
        };
      }
      return {
        'status': 'error',
        'message': 'Backend returned ${response.statusCode}',
      };
    } catch (e) {
      return {'status': 'offline', 'message': e.toString()};
    }
  }

  /// Format module name for display
  String _formatModuleName(String? module) {
    if (module == null) return 'General';

    final names = {
      'women_harassment': 'Women Harassment',
      'labour_rights': 'Labour Rights',
      'cyber_law': 'Cyber Law',
      'road_laws': 'Road Laws',
    };

    return names[module] ?? module;
  }
}
