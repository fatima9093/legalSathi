import 'dart:convert';

import 'package:http/http.dart' as http;

/// Backend analysis of OCR text from screenshots (domain, tags, indicative laws).
class EvidenceAnalysisResult {
  final String classifiedDomain;
  final List<String> tags;
  final List<String> relevantLaws;
  final String summary;

  const EvidenceAnalysisResult({
    required this.classifiedDomain,
    required this.tags,
    required this.relevantLaws,
    required this.summary,
  });

  factory EvidenceAnalysisResult.fromJson(Map<String, dynamic> json) {
    final tags = json['tags'];
    final laws = json['relevant_laws'];
    return EvidenceAnalysisResult(
      classifiedDomain:
          (json['classified_domain'] as String?)?.trim() ??
          'Unclassified document',
      tags: tags is List
          ? tags
                .map((e) => e.toString().trim())
                .where((s) => s.isNotEmpty)
                .toList()
          : const [],
      relevantLaws: laws is List
          ? laws
                .map((e) => e.toString().trim())
                .where((s) => s.isNotEmpty)
                .toList()
          : const [],
      summary: (json['summary'] as String?)?.trim() ?? '',
    );
  }

  static EvidenceAnalysisResult heuristicFallback(String ocrPreview) {
    final short = ocrPreview.length > 200
        ? '${ocrPreview.substring(0, 200)}…'
        : ocrPreview;
    return EvidenceAnalysisResult(
      classifiedDomain: 'Document (offline analysis)',
      tags: const ['Extracted text', 'Manual review'],
      relevantLaws: const [
        'Could not reach analysis server. Verify laws with an official source or lawyer.',
      ],
      summary:
          'Connect the Legal Sathi backend (localhost:8000) for AI classification. Text preview: $short',
    );
  }
}

class EvidenceAnalysisService {
  static const String _url = 'http://localhost:8000/api/evidence/analyze-text';

  static Future<EvidenceAnalysisResult> analyze(
    String extractedText, {
    String? userId,
    String? complaintId,
  }) async {
    final body = jsonEncode({
      'text': extractedText,
      if (userId != null) 'user_id': userId,
      if (complaintId != null) 'complaint_id': complaintId,
    });
    try {
      final response = await http
          .post(
            Uri.parse(_url),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return EvidenceAnalysisResult.fromJson(data);
      }
    } catch (_) {
      // Fall through to local fallback
    }
    return EvidenceAnalysisResult.heuristicFallback(extractedText);
  }
}
