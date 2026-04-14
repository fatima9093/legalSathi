import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Response from backend /api/review-evidence
class EvidenceReviewResult {
  final String strength; // Weak, Medium, Strong
  final String summary;
  final List<String> suggestions;

  EvidenceReviewResult({
    required this.strength,
    required this.summary,
    required this.suggestions,
  });

  factory EvidenceReviewResult.fromJson(Map<String, dynamic> json) {
    return EvidenceReviewResult(
      strength: json['strength'] as String? ?? 'Medium',
      summary: json['summary'] as String? ?? '',
      suggestions: (json['suggestions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

class EvidenceReviewService {
  static const String _baseUrl = 'http://localhost:8000';

  /// Upload files to backend for AI evidence review.
  /// Supports images, PDF, audio, video. Returns strength, summary, suggestions.
  Future<EvidenceReviewResult> reviewEvidence(List<PlatformFile> files) async {
    final uri = Uri.parse('$_baseUrl/api/review-evidence');
    final request = http.MultipartRequest('POST', uri);

    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      if (file.bytes != null && file.bytes!.isNotEmpty) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'files',
            file.bytes!,
            filename: file.name,
          ),
        );
      } else if (file.path != null && !kIsWeb) {
        request.files.add(
          await http.MultipartFile.fromPath('files', file.path!, filename: file.name),
        );
      }
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      String msg;
      if (response.body.isNotEmpty) {
        try {
          final body = jsonDecode(response.body);
          msg = (body is Map && body['detail'] != null)
              ? body['detail'].toString()
              : response.body;
        } catch (_) {
          msg = response.body;
        }
      } else {
        msg = 'Status ${response.statusCode}';
      }
      throw Exception(msg);
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return EvidenceReviewResult.fromJson(data);
  }
}
