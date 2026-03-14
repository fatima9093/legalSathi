import 'dart:convert';
import 'package:http/http.dart' as http;

/// Source information from legal documents
class SourceInfo {
  final String file;
  final String actName;
  final String citation;
  final int publicationYear;
  final String amendmentYears;
  final String currencyIndicator;
  final String documentType;
  final double recencyScore;

  SourceInfo({
    required this.file,
    required this.actName,
    required this.citation,
    required this.publicationYear,
    required this.amendmentYears,
    required this.currencyIndicator,
    required this.documentType,
    required this.recencyScore,
  });

  factory SourceInfo.fromJson(Map<String, dynamic> json) {
    return SourceInfo(
      file: json['file'] ?? '',
      actName: json['act_name'] ?? '',
      citation: json['citation'] ?? '',
      publicationYear: json['publication_year'] ?? 0,
      amendmentYears: json['amendment_years'] ?? '',
      currencyIndicator: json['currency_indicator'] ?? '',
      documentType: json['document_type'] ?? 'document',
      recencyScore: (json['recency_score'] ?? 0.5).toDouble(),
    );
  }
}

/// Enhanced response from Legal Sathi AI
class LegalResponse {
  final String answer;
  final String source;
  final double confidence;
  final String? module;
  final List<SourceInfo> sources;
  final bool hasCurrentInfo;
  final String recencyIndicator;
  final int documentCount;

  LegalResponse({
    required this.answer,
    required this.source,
    required this.confidence,
    this.module,
    required this.sources,
    required this.hasCurrentInfo,
    required this.recencyIndicator,
    required this.documentCount,
  });

  factory LegalResponse.fromJson(Map<String, dynamic> json) {
    return LegalResponse(
      answer: json['answer'] ?? '',
      source: json['source'] ?? 'unknown',
      confidence: (json['confidence'] ?? 0.5).toDouble(),
      module: json['module'],
      sources:
          (json['sources'] as List<dynamic>?)
              ?.map((s) => SourceInfo.fromJson(s))
              .toList() ??
          [],
      hasCurrentInfo: json['has_current_info'] ?? false,
      recencyIndicator: json['recency_indicator'] ?? '',
      documentCount: json['document_count'] ?? 0,
    );
  }

  /// Format sources for display
  String formatSourcesForDisplay() {
    if (sources.isEmpty) {
      return recencyIndicator.isNotEmpty
          ? '\n\n$recencyIndicator'
          : '\n\n⚠️ General information - not based on specific documents';
    }

    final buffer = StringBuffer('\n\n━━━━━━━━━━━━━━━━━━━━━━━━\n');
    buffer.writeln('📚 SOURCES & REFERENCES\n');

    for (int i = 0; i < sources.length; i++) {
      final source = sources[i];
      buffer.writeln('${i + 1}. ${source.citation}');

      if (source.currencyIndicator.isNotEmpty) {
        buffer.writeln('   ${source.currencyIndicator}');
      }

      if (source.amendmentYears.isNotEmpty) {
        buffer.writeln('   📝 Amendments: ${source.amendmentYears}');
      }

      if (i < sources.length - 1) {
        buffer.writeln();
      }
    }

    buffer.writeln('\n━━━━━━━━━━━━━━━━━━━━━━━━');

    if (recencyIndicator.isNotEmpty) {
      buffer.writeln('\n$recencyIndicator');
    }

    return buffer.toString();
  }
}

class LlmService {
  // Backend RAG API endpoint
  // Change this to your backend URL
  // - For local development: http://localhost:8000
  // - For deployed backend: https://your-backend-url.com
  static const String _baseUrl = 'http://localhost:8000';
  static const String _askUrl = '$_baseUrl/api/ask';
  static const String _healthUrl = _baseUrl;

  /// Send message to enhanced RAG backend and get detailed response
  ///
  /// Flow:
  /// 1. Backend searches Vector DB with enhanced metadata
  /// 2. Analyzes document recency and relevance
  /// 3. Returns answer with full citations and dates
  Future<LegalResponse> sendMessage(
    String userMessage, {
    String? module,
    List<Map<String, String>>? conversationHistory,
  }) async {
    try {
      final requestBody = {
        'question': userMessage,
        if (module != null) 'module': module,
        if (conversationHistory != null)
          'conversation_history': conversationHistory,
      };

      final response = await http
          .post(
            Uri.parse(_askUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timeout - backend took too long to respond',
              );
            },
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return LegalResponse.fromJson(data);
      } else if (response.statusCode == 500) {
        throw Exception(
          'Backend error. Make sure the backend server is running.\n\nRun: python main_enhanced.py in the backend folder',
        );
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } on FormatException catch (e) {
      throw Exception('Invalid response format from backend: $e');
    } catch (e) {
      // Connection error - backend not running
      if (e.toString().contains('Failed host lookup') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('SocketException')) {
        throw Exception('''Cannot connect to Legal Sathi backend.

Please start the backend server:

1. Open terminal in backend folder
2. Run: python main_enhanced.py
3. Wait for "🚀 Starting Legal Sathi..."
4. Then try again

Error: $e''');
      }

      throw Exception('Error connecting to Legal Sathi backend: $e');
    }
  }

  /// Check if backend is running and get status
  Future<Map<String, dynamic>> checkBackendHealth() async {
    try {
      final response = await http
          .get(Uri.parse(_healthUrl))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'status': 'online',
          'version': data['version'] ?? '1.0',
          'vector_db_loaded': data['vector_db_loaded'] ?? false,
          'legal_agent_ready': data['legal_agent_ready'] ?? false,
          'total_documents': data['total_documents'] ?? 0,
          'features': data['features'] ?? [],
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

  /// Get statistics about the legal database
  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/stats'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      throw Exception('Error ${response.statusCode}');
    } catch (e) {
      throw Exception('Error getting stats: $e');
    }
  }

  /// Get available modules
  Future<List<Map<String, dynamic>>> getModules() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/modules'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['modules'] ?? []);
      }

      throw Exception('Error ${response.statusCode}');
    } catch (e) {
      throw Exception('Error getting modules: $e');
    }
  }

  /// Format module name for display
  String formatModuleName(String? module) {
    if (module == null) return 'General';

    final names = {
      'women_harassment': 'Women Harassment',
      'labour_rights': 'Labour Rights',
      'cyber_law': 'Cyber Law',
      'road_laws': 'Road Laws',
    };

    return names[module] ?? module;
  }

  /// Get confidence level description
  String getConfidenceDescription(double confidence) {
    if (confidence >= 0.8) {
      return 'Very High';
    } else if (confidence >= 0.6) {
      return 'High';
    } else if (confidence >= 0.4) {
      return 'Medium';
    } else {
      return 'Low';
    }
  }

  /// Get confidence color (for UI)
  String getConfidenceColor(double confidence) {
    if (confidence >= 0.8) {
      return 'green';
    } else if (confidence >= 0.6) {
      return 'blue';
    } else if (confidence >= 0.4) {
      return 'orange';
    } else {
      return 'red';
    }
  }
}
