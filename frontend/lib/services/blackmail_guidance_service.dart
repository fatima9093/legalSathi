import 'package:front_end/models/blackmail_model.dart';
import 'package:front_end/services/challan_text_extraction_service.dart';
import 'package:front_end/services/evidence_analysis_service.dart';

class BlackmailGuidanceResult {
  final List<String> immediateActions;
  final List<String> evidenceChecklist;
  final List<String> reportingSteps;
  final List<String> legalOptions;
  final String analysisSummary;
  final String extractedEvidencePreview;

  const BlackmailGuidanceResult({
    required this.immediateActions,
    required this.evidenceChecklist,
    required this.reportingSteps,
    required this.legalOptions,
    required this.analysisSummary,
    required this.extractedEvidencePreview,
  });
}

class BlackmailGuidanceService {
  static Future<BlackmailGuidanceResult> buildGuidance({
    required String situation,
    required List<EvidenceFile> evidenceFiles,
  }) async {
    final evidenceText = await _extractEvidenceText(evidenceFiles);
    final combined = [situation.trim(), evidenceText.trim()]
        .where((s) => s.isNotEmpty)
        .join('\n\n');
    final lower = combined.toLowerCase();

    final analysis = combined.trim().length >= 15
        ? await EvidenceAnalysisService.analyze(combined)
        : null;

    final immediateActions = <String>[
      'Do not pay money and do not comply with demands.',
      'Stop further conversation and avoid emotional replies.',
      'Preserve all evidence exactly as received (no edits).',
      'Secure accounts: change passwords and enable two-factor authentication.',
    ];

    final evidenceChecklist = <String>[
      'Capture screenshots with date/time and sender details visible.',
      'Save profile links, usernames, phone numbers, and account IDs.',
      'Keep a short timeline of events (date, platform, demand, threat).',
      'Back up evidence in more than one safe location.',
    ];

    final reportingSteps = <String>[
      'Report to FIA Cyber Crime Wing with your evidence bundle.',
      'File a police complaint/FIR if there is extortion or safety risk.',
      'Report abusive account/content on the platform (WhatsApp, Facebook, etc.).',
      'Consult a lawyer for case-specific legal strategy.',
    ];

    final legalOptions = <String>[
      'PECA 2016 can apply depending on facts (extortion, unlawful online threats, misuse of data).',
      'Pakistan Penal Code extortion provisions may also apply.',
      'Keep evidence chain intact for admissibility and investigation.',
    ];

    if (_containsAny(lower, ['nude', 'intimate', 'private photo', 'private video', 'explicit'])) {
      immediateActions.insert(1, 'Use platform non-consensual intimate image reporting immediately.');
      reportingSteps.insert(0, 'Urgent: contact FIA Cyber Crime helpline (1991) for rapid guidance.');
    }

    if (_containsAny(lower, ['money', 'pay', 'payment', 'bank', 'easypaisa', 'jazzcash'])) {
      immediateActions.add('Alert your bank/wallet provider for fraud monitoring.');
      evidenceChecklist.add('Save payment requests, account numbers, and transaction references.');
    }

    if (_containsAny(lower, ['kill', 'harm', 'attack', 'violence', 'kidnap'])) {
      immediateActions.insert(0, 'If you are in immediate danger, call emergency services right now.');
      reportingSteps.insert(0, 'Treat as urgent physical threat: contact local police immediately.');
    }

    if (_containsAny(lower, ['minor', 'child', 'underage'])) {
      reportingSteps.insert(0, 'Critical: involve child protection authorities immediately.');
      legalOptions.insert(0, 'Cases involving minors are treated with heightened criminal seriousness.');
    }

    if (analysis != null) {
      for (final law in analysis.relevantLaws) {
        if (!legalOptions.contains(law)) {
          legalOptions.add(law);
        }
      }
    }

    final preview = evidenceText.trim().isEmpty
        ? 'No readable text extracted from uploaded evidence.'
        : _truncate(evidenceText.trim(), 400);

    return BlackmailGuidanceResult(
      immediateActions: immediateActions.take(8).toList(),
      evidenceChecklist: evidenceChecklist.take(8).toList(),
      reportingSteps: reportingSteps.take(8).toList(),
      legalOptions: legalOptions.take(8).toList(),
      analysisSummary: analysis?.summary.trim().isNotEmpty == true
          ? analysis!.summary.trim()
          : 'Guidance is tailored from your written situation and uploaded evidence text.',
      extractedEvidencePreview: preview,
    );
  }

  static Future<String> _extractEvidenceText(List<EvidenceFile> files) async {
    final chunks = <String>[];
    for (final f in files.take(4)) {
      final bytes = f.fileBytes;
      if (bytes == null || bytes.isEmpty) continue;
      final name = f.fileName.toLowerCase();
      final isImage = name.endsWith('.jpg') ||
          name.endsWith('.jpeg') ||
          name.endsWith('.png') ||
          name.endsWith('.webp');
      if (!isImage) continue;
      try {
        final text = await ChallanTextExtractionService.extractRawText(
          bytes: bytes,
          fileName: f.fileName,
          fileType: 'image',
        );
        if (text.trim().isNotEmpty) {
          chunks.add(text.trim());
        }
      } catch (_) {
        // Ignore single-file OCR failure and continue with remaining evidence.
      }
    }
    return chunks.join('\n\n---\n\n');
  }

  static bool _containsAny(String lower, List<String> terms) {
    for (final t in terms) {
      if (lower.contains(t)) return true;
    }
    return false;
  }

  static String _truncate(String value, int maxLen) {
    if (value.length <= maxLen) return value;
    return '${value.substring(0, maxLen)}...';
  }
}
