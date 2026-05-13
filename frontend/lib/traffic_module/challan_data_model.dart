import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:front_end/services/challan_text_extraction_service.dart';

class ChallanData {
  final String challanNumber;
  final String vehicleNumber;
  final String violationType;
  final String fineAmount;
  final String issueLocation;
  final String officerId;
  final DateTime issueDate;
  final String violationDescription;
  final String legalReference;
  final List<String> paymentOptions;
  final String nearestOffice;
  final String appealProcess;
  /// True when OCR returned little or no text and defaults were used.
  final bool usedFallbackDefaults;

  ChallanData({
    required this.challanNumber,
    required this.vehicleNumber,
    required this.violationType,
    required this.fineAmount,
    required this.issueLocation,
    required this.officerId,
    required this.issueDate,
    required this.violationDescription,
    required this.legalReference,
    required this.paymentOptions,
    required this.nearestOffice,
    required this.appealProcess,
    this.usedFallbackDefaults = false,
  });

  /// Run OCR / PDF text extraction, then parse into structured challan fields.
  static Future<ChallanData> extractFromDocument({
    required Uint8List bytes,
    required String fileName,
    required String fileType,
  }) async {
    final raw = await ChallanTextExtractionService.extractRawText(
      bytes: bytes,
      fileName: fileName,
      fileType: fileType,
    );
    return parseFromRawText(raw);
  }

  /// Map free-form OCR/PDF text into [ChallanData] with sensible Pakistan defaults.
  static ChallanData parseFromRawText(String raw) {
    final text = raw.trim();
    final normalized = text.replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
    final original = text;

    if (text.length < 8) {
      return _fallbackTemplate(
        note:
            'We could not read enough text from this file. Try a clearer photo, ensure the backend is running for PDF/web, or install Tesseract on the server for image OCR.',
        usedFallback: true,
      );
    }

    String challanNumber = _extractChallanNumber(original) ??
        'Not detected — please verify from your document';
    String vehicleNumber =
        _extractVehicleNumber(original) ?? 'Not detected — please verify';
    String fineAmount = _extractFine(original) ?? 'See challan / verify amount';
    String issueLocation =
        _extractLocation(original) ?? 'Not detected — verify on original challan';
    String officerId =
        _extractOfficerId(original) ?? 'Not shown — check physical challan';
    final issueDate = _extractDate(original) ?? DateTime.now();

    final violation = _inferViolation(normalized, original);
    final violationType = violation.$1;
    final violationDescription = violation.$2;
    final legalReference = violation.$3;

    final usedFallback = challanNumber.startsWith('Not detected') &&
        vehicleNumber.startsWith('Not detected') &&
        fineAmount.contains('verify');

    return ChallanData(
      challanNumber: challanNumber,
      vehicleNumber: vehicleNumber,
      violationType: violationType,
      fineAmount: fineAmount,
      issueLocation: issueLocation,
      officerId: officerId,
      issueDate: issueDate,
      violationDescription: violationDescription,
      legalReference: legalReference,
      paymentOptions: const [
        '• Online: Provincial e-challan / traffic police portal (e.g. psca.gop.pk where applicable)',
        '• Bank: Designated branches as printed on your challan',
        '• Mobile app: Official police / traffic apps for your province',
        '• Traffic office: Nearest traffic police office with challan copy',
      ],
      nearestOffice:
          'Nearest traffic police office for your district — check your challan footer or provincial traffic police website.',
      appealProcess:
          'If you believe this challan is wrong: file a written objection / appeal within the period stated on the challan (often 15–30 days). Attach challan copy, CNIC, and evidence. Contact SP Traffic or the court noted on the challan.',
      usedFallbackDefaults: usedFallback,
    );
  }

  static ChallanData _fallbackTemplate({
    required String note,
    required bool usedFallback,
  }) {
    return ChallanData(
      challanNumber: '—',
      vehicleNumber: '—',
      violationType: 'Could not read challan',
      fineAmount: '—',
      issueLocation: '—',
      officerId: '—',
      issueDate: DateTime.now(),
      violationDescription:
          '$note\n\nYou can still use the app’s traffic law tools or re-upload a sharper image / PDF with selectable text.',
      legalReference:
          'Fines and procedures follow the Motor Vehicles Ordinance 1965 and provincial traffic rules — confirm against your official challan.',
      paymentOptions: const [
        '• Use the payment channel printed on your physical or e-challan',
        '• Provincial traffic police website or designated banks',
      ],
      nearestOffice: 'Check your challan or provincial traffic police website.',
      appealProcess:
          'Follow the appeal / objection process printed on your challan.',
      usedFallbackDefaults: usedFallback,
    );
  }

  static String? _extractChallanNumber(String t) {
    final patterns = [
      RegExp(
        r'challan\s*(?:no\.?|number|#)?\s*[:\-]?\s*([A-Z0-9\-\/]{6,})',
        caseSensitive: false,
      ),
      RegExp(
        r'(?:e[\s\-]?challan|e\s*challan)\s*[:\-#]?\s*([A-Z0-9\-\/]{5,})',
        caseSensitive: false,
      ),
      RegExp(r'\b([A-Z]{2,4}[\-/]\d{4}[\-/]\d{4,})\b', caseSensitive: false),
      RegExp(r'\b(\d{10,16})\b'),
    ];
    for (final re in patterns) {
      final m = re.firstMatch(t);
      if (m != null && m.groupCount >= 1) {
        final v = m.group(1)?.trim();
        if (v != null && v.length >= 5) return v.toUpperCase();
      }
    }
    return null;
  }

  static String? _extractVehicleNumber(String t) {
    final re = RegExp(
      r'\b([A-Z]{2,3}[\s\-]?\d{2,4}[\s\-]?[A-Z]{1,3}[\s\-]?\d{1,4}|[A-Z]{3}[\s\-]?\d{3,4})\b',
      caseSensitive: false,
    );
    final m = re.firstMatch(t);
    return m?.group(1)?.replaceAll(RegExp(r'\s+'), '-').toUpperCase();
  }

  static String? _extractFine(String t) {
    final re = RegExp(
      r'(?:rs\.?|pkr|rupees?)\s*([\d,]+(?:\.\d{2})?)',
      caseSensitive: false,
    );
    final m = re.firstMatch(t);
    if (m != null) {
      return 'Rs. ${m.group(1)}';
    }
    final re2 = RegExp(r'\b([\d,]{3,5})\s*(?:rupees|pkr)\b', caseSensitive: false);
    final m2 = re2.firstMatch(t.toLowerCase());
    if (m2 != null) return 'Rs. ${m2.group(1)}';
    return null;
  }

  static String? _extractLocation(String t) {
    final re = RegExp(
      r'(?:place|location|at|near)\s*[:\-]\s*([^\n]{5,80})',
      caseSensitive: false,
    );
    final m = re.firstMatch(t);
    return m?.group(1)?.trim();
  }

  static String? _extractOfficerId(String t) {
    final re = RegExp(
      r'(?:officer|constable|badge|id)\s*(?:no\.?)?\s*[:\-]?\s*([A-Z0-9\-]{3,12})',
      caseSensitive: false,
    );
    final m = re.firstMatch(t);
    return m?.group(1)?.trim().toUpperCase();
  }

  static DateTime? _extractDate(String t) {
    final re = RegExp(
      r'(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{2,4})',
    );
    final m = re.firstMatch(t);
    if (m != null) {
      var d = int.tryParse(m.group(1)!);
      var mo = int.tryParse(m.group(2)!);
      var y = int.tryParse(m.group(3)!);
      if (y != null && y < 100) y += 2000;
      if (d != null && mo != null && y != null) {
        try {
          return DateTime(y, mo, d);
        } catch (_) {}
      }
    }
    return null;
  }

  /// Returns (type, description, legal blurb).
  static (String, String, String) _inferViolation(
    String lower,
    String original,
  ) {
    if (lower.contains('speed') ||
        lower.contains('over speed') ||
        lower.contains('overspeed')) {
      return (
        'Over speeding',
        _clipContext(original, 'speed'),
        'Over speeding is enforced under the Motor Vehicles Ordinance 1965 and provincial traffic rules; penalties vary by road and speed margin.',
      );
    }
    if (lower.contains('helmet') || lower.contains('without helmet')) {
      return (
        'Helmet violation',
        _clipContext(original, 'helmet'),
        'Two-wheeler helmet requirements are enforced under provincial traffic laws; fines are set by notified schedules.',
      );
    }
    if (lower.contains('signal') ||
        lower.contains('red light') ||
        lower.contains('traffic light')) {
      return (
        'Signal violation',
        _clipContext(original, 'signal'),
        'Jumping a red signal / disobeying traffic signals carries higher penalties and may affect driving record.',
      );
    }
    if (lower.contains('parking') || lower.contains('wrong parking')) {
      return (
        'Parking violation',
        _clipContext(original, 'park'),
        'Wrong or obstructive parking is a compoundable offence; pay or contest within the period on the challan.',
      );
    }
    if (lower.contains('license') &&
        (lower.contains('without') || lower.contains('expired'))) {
      return (
        'License-related violation',
        _clipContext(original, 'license'),
        'Driving without a valid licence or with an expired licence is a serious offence under the MVO 1965.',
      );
    }
    if (lower.contains('seat belt') || lower.contains('seatbelt')) {
      return (
        'Seat belt violation',
        _clipContext(original, 'belt'),
        'Seat-belt use is mandatory for drivers and often front passengers under provincial rules.',
      );
    }
    return (
      'Traffic violation (general)',
      original.length > 600 ? '${original.substring(0, 600)}…' : original,
      'Verify the exact section and fine on your official challan; penalties follow the Motor Vehicles Ordinance 1965 and provincial notifications.',
    );
  }

  static String _clipContext(String original, String keyword) {
    final i = original.toLowerCase().indexOf(keyword);
    if (i < 0) {
      return original.length > 400 ? '${original.substring(0, 400)}…' : original;
    }
    final start = (i - 80).clamp(0, original.length);
    final end = (i + 200).clamp(0, original.length);
    return original.substring(start, end).trim();
  }

  Color getViolationColor() {
    switch (violationType.toLowerCase()) {
      case 'over speeding':
        return const Color(0xFFD97706);
      case 'helmet violation':
      case 'signal violation':
        return const Color(0xFFDC2626);
      case 'parking violation':
        return const Color(0xFFEAB308);
      default:
        return const Color(0xFF00401A);
    }
  }
}
