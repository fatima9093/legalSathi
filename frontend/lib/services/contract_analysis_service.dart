/// Heuristic labour-law contract review (not legal advice).
class ContractIssue {
  final String title;
  final String description;
  final String severity; // Serious | Moderate | Info
  final String law;

  const ContractIssue({
    required this.title,
    required this.description,
    required this.severity,
    required this.law,
  });
}

class ContractAnalysisResult {
  final bool insufficientText;
  final String? insufficientMessage;
  final List<ContractIssue> concerns;
  final List<String> positiveNotes;
  final String summary;

  const ContractAnalysisResult._({
    required this.insufficientText,
    this.insufficientMessage,
    required this.concerns,
    required this.positiveNotes,
    required this.summary,
  });

  factory ContractAnalysisResult.insufficient(String message) {
    return ContractAnalysisResult._(
      insufficientText: true,
      insufficientMessage: message,
      concerns: [],
      positiveNotes: [],
      summary: '',
    );
  }

  factory ContractAnalysisResult.analyzed({
    required List<ContractIssue> concerns,
    required List<String> positiveNotes,
    required String summary,
  }) {
    return ContractAnalysisResult._(
      insufficientText: false,
      concerns: concerns,
      positiveNotes: positiveNotes,
      summary: summary,
    );
  }

  bool get looksBroadlyCompliant =>
      !insufficientText &&
      concerns.where((c) => c.severity != 'Info').isEmpty;

  int get seriousCount =>
      concerns.where((c) => c.severity == 'Serious').length;

  int get moderateCount =>
      concerns.where((c) => c.severity == 'Moderate').length;
}

class ContractAnalysisService {
  ContractAnalysisService._();

  static ContractAnalysisResult analyze(String rawText) {
    final text = rawText.trim();
    if (text.length < 40) {
      return ContractAnalysisResult.insufficient(
        'Paste more contract text, or upload a clearer PDF/image so we can extract at least a short paragraph.',
      );
    }

    final lower = text.toLowerCase();
    final concerns = <ContractIssue>[];
    final positives = <String>[];

    void addPositive(String note) {
      if (!positives.contains(note)) positives.add(note);
    }

    // --- Positive signals (common compliant language) ---
    if (lower.contains('notice') &&
        (lower.contains('termination') || lower.contains('terminate'))) {
      addPositive('Mentions termination / notice — review duration against law.');
    }
    if (lower.contains('overtime') ||
        lower.contains('extra hours') ||
        lower.contains('ordinary rate')) {
      addPositive('References overtime or extra hours — compare to Factories Act (typically 2× rate).');
    }
    if (lower.contains('leave') &&
        (lower.contains('annual') ||
            lower.contains('sick') ||
            lower.contains('casual'))) {
      addPositive('References types of leave — aligns with common leave clauses.');
    }
    if (lower.contains('minimum wage') ||
        lower.contains('statutory') ||
        lower.contains('labour law') ||
        lower.contains('in accordance with')) {
      addPositive('References statutory pay or compliance with law.');
    }

    // --- Red-flag phrases (conservative: explicit harmful wording) ---
    if (_pair(lower, 'waive', 'right') ||
        lower.contains('relinquish all rights') ||
        lower.contains('forfeit any claim')) {
      concerns.add(
        const ContractIssue(
          title: 'Possible waiver of statutory rights',
          description:
              'Clauses that ask you to waive or forfeit statutory employment rights are often unenforceable, but they are a serious concern — get legal advice before signing.',
          severity: 'Serious',
          law: 'Constitution & labour protective statutes (interpretation varies)',
        ),
      );
    }

    if (lower.contains('no overtime pay') ||
        lower.contains('overtime shall not be paid') ||
        lower.contains('no payment for overtime') ||
        (lower.contains('overtime') && lower.contains('without pay'))) {
      concerns.add(
        const ContractIssue(
          title: 'Denial of overtime pay',
          description:
              'Pakistani law generally requires overtime at higher than ordinary rates (e.g. Factories Act). Explicit denial of overtime pay is a major concern.',
          severity: 'Serious',
          law: 'Factories Act 1934, Section 51 (context-dependent)',
        ),
      );
    }

    if (RegExp(
      r'no (paid )?leave.{0,40}(first|initial).{0,20}(six|6) month',
      caseSensitive: false,
    ).hasMatch(text)) {
      concerns.add(
        const ContractIssue(
          title: 'Restricted leave in early employment',
          description:
              'Blanket “no leave for six months” may conflict with rights to sick/casual leave under provincial Shops & Establishments laws.',
          severity: 'Moderate',
          law: 'Provincial Shops & Establishments Acts',
        ),
      );
    }

    if ((lower.contains('terminate immediately') ||
            lower.contains('termination without notice')) &&
        !lower.contains('pay in lieu') &&
        !lower.contains('payment in lieu') &&
        !lower.contains('30 day')) {
      concerns.add(
        const ContractIssue(
          title: 'Termination without notice or pay in lieu',
          description:
              'Industrial/labour law often requires notice or wages in lieu unless serious misconduct is proven. One-sided instant termination clauses need review.',
          severity: 'Serious',
          law: 'Industrial Relations Act / case law (varies by sector)',
        ),
      );
    }

    if (lower.contains('24/7') ||
        lower.contains('unlimited working hours') ||
        lower.contains('on call at all times')) {
      concerns.add(
        const ContractIssue(
          title: 'Unlimited or extreme working hours',
          description:
              'Standard limits apply (e.g. weekly hours under Factories / provincial rules). “24/7” or unlimited hours are unlikely to be fully enforceable.',
          severity: 'Serious',
          law: 'Factories Act 1934 & provincial rules',
        ),
      );
    }

    if (lower.contains('salary below minimum') ||
        lower.contains('below the minimum wage')) {
      concerns.add(
        const ContractIssue(
          title: 'Below minimum wage (if literal)',
          description:
              'Pay must meet notified minimum wages for your category and province.',
          severity: 'Serious',
          law: 'Minimum Wages Ordinance 1961 & provincial notifications',
        ),
      );
    }

    // If nothing flagged: explain clearly
    final summary = concerns.isEmpty
        ? 'No obvious red-flag phrases were detected in this excerpt. Many employment contracts refer to “applicable law” without repeating every rule — that is normal. This tool only spots common risky wording, not a full legal review.'
        : 'The clauses above match patterns that often deserve a lawyer’s review. Other parts of your contract may still be fine.';

    return ContractAnalysisResult.analyzed(
      concerns: concerns,
      positiveNotes: positives,
      summary: summary,
    );
  }

  static bool _pair(String lower, String a, String b) {
    final ia = lower.indexOf(a);
    if (ia < 0) return false;
    final ib = lower.indexOf(b, ia);
    return ib > ia && (ib - ia) < 120;
  }
}
