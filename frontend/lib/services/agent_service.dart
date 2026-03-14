import 'dart:convert';
import 'package:http/http.dart' as http;

// ---------------------------------------------------------------------------
// Pipeline stage enumeration
// ---------------------------------------------------------------------------

/// Represents each stage in the multi-agent pipeline.
enum AgentPipelineStage {
  idle,
  retrieving, // Law Retrieval Agent
  explaining, // Explanation Agent
  guiding, // Guidance Agent
  done,
  error,
}

extension AgentPipelineStageLabelX on AgentPipelineStage {
  String get label {
    switch (this) {
      case AgentPipelineStage.idle:
        return 'Ready';
      case AgentPipelineStage.retrieving:
        return 'Retrieving Legal Documents';
      case AgentPipelineStage.explaining:
        return 'Analysing & Explaining';
      case AgentPipelineStage.guiding:
        return 'Generating Guidance';
      case AgentPipelineStage.done:
        return 'Complete';
      case AgentPipelineStage.error:
        return 'Error';
    }
  }

  String get description {
    switch (this) {
      case AgentPipelineStage.idle:
        return '';
      case AgentPipelineStage.retrieving:
        return 'Law Retrieval Agent is searching ChromaDB and official sources…';
      case AgentPipelineStage.explaining:
        return 'Explanation Agent is summarising key points from the documents…';
      case AgentPipelineStage.guiding:
        return 'Guidance Agent is creating step-by-step legal procedure…';
      case AgentPipelineStage.done:
        return 'All agents completed successfully.';
      case AgentPipelineStage.error:
        return 'An agent error occurred.';
    }
  }
}

// ---------------------------------------------------------------------------
// Response models
// ---------------------------------------------------------------------------

/// A single procedural step returned by the Guidance Agent.
class AgentStep {
  final int stepNumber;
  final String title;
  final String description;
  final String? tips;

  const AgentStep({
    required this.stepNumber,
    required this.title,
    required this.description,
    this.tips,
  });

  factory AgentStep.fromJson(Map<String, dynamic> json) {
    return AgentStep(
      stepNumber: (json['step_number'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      tips: json['tips'] as String?,
    );
  }
}

/// Full structured response from the multi-agent pipeline.
class AgentResponse {
  final String answer;
  final String summary;
  final List<String> keyPoints;
  final List<AgentStep> steps;
  final List<String> requiredDocuments;
  final List<String> references;
  final Map<String, String> officialLinks;
  final String? notes;
  final String? module;
  final String query;
  final double elapsedSeconds;
  final double relevanceScore;
  final String? lastUpdated;
  final String verificationStatus;
  final String? verificationNote;
  final bool requiresOfficialConfirmation;
  final double trustedSourceRatio;
  final String freshnessStatus;

  const AgentResponse({
    required this.answer,
    required this.summary,
    required this.keyPoints,
    required this.steps,
    required this.requiredDocuments,
    required this.references,
    required this.officialLinks,
    this.notes,
    this.module,
    required this.query,
    required this.elapsedSeconds,
    this.relevanceScore = 0.0,
    this.lastUpdated,
    this.verificationNote,
    this.verificationStatus = 'unverified',
    this.requiresOfficialConfirmation = true,
    this.trustedSourceRatio = 0.0,
    this.freshnessStatus = 'unknown',
  });

  factory AgentResponse.fromJson(Map<String, dynamic> json) {
    final rawSteps = json['steps'] as List<dynamic>? ?? [];
    final rawLinks = json['official_links'] as Map<String, dynamic>? ?? {};

    return AgentResponse(
      answer: json['answer'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      keyPoints: List<String>.from(json['key_points'] as List<dynamic>? ?? []),
      steps: rawSteps
          .map((s) => AgentStep.fromJson(s as Map<String, dynamic>))
          .toList(),
      requiredDocuments: List<String>.from(
        json['required_documents'] as List<dynamic>? ?? [],
      ),
      references: List<String>.from(json['references'] as List<dynamic>? ?? []),
      officialLinks: rawLinks.map((k, v) => MapEntry(k, v.toString())),
      notes: json['notes'] as String?,
      module: json['module'] as String?,
      query: json['query'] as String? ?? '',
      elapsedSeconds: (json['elapsed_seconds'] as num?)?.toDouble() ?? 0.0,
      relevanceScore: (json['relevance_score'] as num?)?.toDouble() ?? 0.0,
      lastUpdated: json['last_updated'] as String?,
      verificationStatus:
          json['verification_status'] as String? ?? 'unverified',
      verificationNote: json['verification_note'] as String?,
      requiresOfficialConfirmation:
          json['requires_official_confirmation'] as bool? ?? true,
      trustedSourceRatio:
          (json['trusted_source_ratio'] as num?)?.toDouble() ?? 0.0,
      freshnessStatus: json['freshness_status'] as String? ?? 'unknown',
    );
  }

  /// Whether the response carries meaningful guidance content.
  bool get hasGuidance => steps.isNotEmpty;

  /// Whether the response has key legal points.
  bool get hasKeyPoints => keyPoints.isNotEmpty;

  /// Whether the response includes required documents.
  bool get hasRequiredDocuments => requiredDocuments.isNotEmpty;

  /// Whether the response includes official portal links.
  bool get hasOfficialLinks => officialLinks.isNotEmpty;
}

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

/// Service that invokes the Legal Sathi multi-agent pipeline.
///
/// Calls [POST /api/ask/agent] and returns a typed [AgentResponse].
/// The [onStageChanged] callback is invoked when the pipeline progresses
/// through its stages so the UI can reflect real-time status.
class AgentService {
  static const String _baseUrl = 'http://localhost:8000';
  static const String _agentAskUrl = '$_baseUrl/api/ask/agent';

  /// Valid module keys accepted by the backend.
  static const Map<String, String> moduleLabels = {
    'women_harassment': 'Women Harassment',
    'labour_rights': 'Labour Rights',
    'cyber_law': 'Cyber Law',
    'road_laws': 'Road Laws',
  };

  /// Calls the multi-agent pipeline and returns a structured [AgentResponse].
  ///
  /// [query]            — the user's legal question.
  /// [module]           — optional module filter (one of [moduleLabels] keys).
  /// [language]         — natural language for the response (default: 'English').
  /// [onStageChanged]   — callback fired as each pipeline stage begins/ends.
  Future<AgentResponse> ask(
    String query, {
    String? module,
    String language = 'English',
    String? conversationId,
    List<Map<String, String>>? conversationHistory,
    void Function(AgentPipelineStage stage)? onStageChanged,
  }) async {
    onStageChanged?.call(AgentPipelineStage.retrieving);

    try {
      final body = <String, dynamic>{
        'question': query,
        'use_agents': true,
        'language': language,
        if (module != null && moduleLabels.containsKey(module))
          'module': module,
        if (conversationId != null && conversationId.trim().isNotEmpty)
          'conversation_id': conversationId.trim(),
        if (conversationHistory != null && conversationHistory.isNotEmpty)
          'conversation_history': conversationHistory,
      };

      // The backend runs all three agents sequentially.
      // We simulate stage transitions via timed callbacks so the UI stays
      // informative for the duration of the request.
      onStageChanged?.call(AgentPipelineStage.retrieving);
      final stageTimer = _simulateStages(onStageChanged);

      final response = await http
          .post(
            Uri.parse(_agentAskUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(
            const Duration(seconds: 120),
            onTimeout: () {
              stageTimer.cancel();
              throw Exception(
                'The multi-agent pipeline timed out. '
                'The backend may be under heavy load — please try again.',
              );
            },
          );

      stageTimer.cancel();

      if (response.statusCode == 200) {
        onStageChanged?.call(AgentPipelineStage.done);
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return AgentResponse.fromJson(data);
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final detail = data['detail'] as String? ?? response.body;
        onStageChanged?.call(AgentPipelineStage.error);
        throw Exception('No relevant documents found: $detail');
      } else if (response.statusCode == 501) {
        onStageChanged?.call(AgentPipelineStage.error);
        throw Exception(
          'Multi-agent pipeline is not available on this server. '
          'Ensure OPENAI_API_KEY is set and openai-agents is installed.',
        );
      } else {
        onStageChanged?.call(AgentPipelineStage.error);
        throw Exception(
          'Backend error ${response.statusCode}: ${response.body}',
        );
      }
    } on FormatException catch (e) {
      onStageChanged?.call(AgentPipelineStage.error);
      throw Exception('Invalid response format from backend: $e');
    } catch (e) {
      onStageChanged?.call(AgentPipelineStage.error);
      if (e.toString().contains('Failed host lookup') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('SocketException')) {
        throw Exception(
          'Cannot connect to Legal Sathi backend.\n\n'
          'Please start the backend:\n'
          '  cd backend && python main.py',
        );
      }
      rethrow;
    }
  }

  /// Fires simulated stage transitions at intervals so the UI reflects
  /// that the pipeline is progressing even while awaiting the HTTP response.
  _StageCancellable _simulateStages(
    void Function(AgentPipelineStage)? onStageChanged,
  ) {
    if (onStageChanged == null) return _StageCancellable._noop();

    bool cancelled = false;

    Future.delayed(const Duration(seconds: 5), () {
      if (!cancelled) onStageChanged(AgentPipelineStage.explaining);
    });
    Future.delayed(const Duration(seconds: 15), () {
      if (!cancelled) onStageChanged(AgentPipelineStage.guiding);
    });

    return _StageCancellable._(() => cancelled = true);
  }

  /// Check backend health and agent availability.
  Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await http
          .get(Uri.parse(_baseUrl))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {'status': 'error'};
    } catch (_) {
      return {'status': 'offline'};
    }
  }
}

class _StageCancellable {
  final void Function() _cancel;
  _StageCancellable._(this._cancel);
  factory _StageCancellable._noop() => _StageCancellable._(() {});
  void cancel() => _cancel();
}
