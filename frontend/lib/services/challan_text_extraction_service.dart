import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'challan_ocr_mlkit_stub.dart'
    if (dart.library.io) 'challan_ocr_mlkit_io.dart'
    as mlkit;

/// Extracts plain text from challan images (ML Kit on mobile + backend fallback)
/// or PDF (backend pypdf). Uses same host as [llm_service](lib/services/llm_service.dart).
class ChallanTextExtractionService {
  static const String _baseUrl = 'http://localhost:8000';

  static Future<String> extractRawText({
    required Uint8List bytes,
    required String fileName,
    required String fileType,
  }) async {
    final lower = fileName.toLowerCase();
    final isPdf = fileType == 'pdf' || lower.endsWith('.pdf');

    if (isPdf) {
      return _extractViaBackend(bytes, fileName);
    }

    if (!kIsWeb) {
      final ext = lower.endsWith('.png') ? 'png' : 'jpg';
      try {
        final local = await mlkit.recognizeTextFromImageBytes(bytes, ext);
        if (local.trim().isNotEmpty) {
          return local.trim();
        }
      } catch (e, st) {
        debugPrint('ML Kit OCR failed (will try backend): $e $st');
      }
    }

    final remote = await _extractViaBackend(bytes, fileName);
    if (remote.trim().isNotEmpty) {
      return remote.trim();
    }
    return '';
  }

  static Future<String> _extractViaBackend(
    Uint8List bytes,
    String fileName,
  ) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/challan/extract-text');
      final request = http.MultipartRequest('POST', uri);
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName.isNotEmpty ? fileName : 'challan.bin',
        ),
      );
      final streamed = await request.send();
      final resp = await http.Response.fromStream(streamed);
      if (resp.statusCode != 200) {
        debugPrint('extract-text HTTP ${resp.statusCode}: ${resp.body}');
        return '';
      }
      final map = jsonDecode(resp.body) as Map<String, dynamic>?;
      return (map?['text'] as String?)?.trim() ?? '';
    } catch (e, st) {
      debugPrint('Backend challan extract failed: $e $st');
      return '';
    }
  }
}
