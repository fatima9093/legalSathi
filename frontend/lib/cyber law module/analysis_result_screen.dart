import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../labour rights module/file_general_complaint_screen.dart';
import '../screen_with_nav.dart';
import 'package:front_end/l10n/app_localizations.dart';

class AnalysisResultScreen extends StatefulWidget {
  final String? filePath;
  final String? classifiedDomain;
  final String? extractedText;
  final List<String>? tags;
  final List<String>? relevantLaws;
  final String? summary;

  final bool demoMode;

  const AnalysisResultScreen({
    super.key,
    this.filePath,
    this.classifiedDomain,
    this.extractedText,
    this.tags,
    this.relevantLaws,
    this.summary,
    this.demoMode = false,
  });

  @override
  State<AnalysisResultScreen> createState() => _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends State<AnalysisResultScreen> {
  late String _extractedText;
  late List<String> _tags;
  late List<String> _relevantLaws;
  late String _classifiedDomain;
  late String _summary;

  @override
  void initState() {
    super.initState();

    if (widget.demoMode) {
      _extractedText = '''
Employee Name: Muhammad Ali
CNIC: 00000-0000000-0
Position: Software Engineer
Department: IT
Basic Salary: 50,000 PKR
Allowances: 10,000 PKR
Deductions: 5,000 PKR
Net Salary: 55,000 PKR
Payment Date: February 2026
''';

      _tags = ['Salary Slip', 'Employment Proof'];
      _relevantLaws = [
        'Labour Code compliance required',
        'Payment of Wages rules apply',
        'Verify deductions legally',
      ];
      _classifiedDomain = 'Labour Document';
      _summary = 'Demo analysis of salary slip document.';
    } else {
      _extractedText = widget.extractedText ?? 'No text extracted.';
      _tags = widget.tags ?? ['Document'];
      _relevantLaws = widget.relevantLaws ??
          ['Consult legal authority for verification'];
      _classifiedDomain = widget.classifiedDomain ?? 'Unclassified';
      _summary = widget.summary ?? '';
    }
  }

  void _copyToClipboard(AppLocalizations l10n) {
    Clipboard.setData(ClipboardData(text: _extractedText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.textCopiedMessage)),
    );
  }

  void _generateComplaint() {
    final issue = StringBuffer()
      ..writeln('Domain: $_classifiedDomain')
      ..writeln('Tags: ${_tags.join(', ')}')
      ..writeln('Summary: $_summary')
      ..writeln('')
      ..writeln(_extractedText);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FileGeneralComplaintScreen(
          complaintIssue: issue.toString(),
        ),
      ),
    );
  }

  Future<void> _shareAnalysis(AppLocalizations l10n) async {
    final text = StringBuffer()
      ..writeln(l10n.shareHeader)
      ..writeln(l10n.domainLabel(_classifiedDomain))
      ..writeln(l10n.tagsLabel(_tags.join(', ')))
      ..writeln('')
      ..writeln(l10n.summaryLabel)
      ..writeln(_summary)
      ..writeln('')
      ..writeln(l10n.relevantLawsLabel)
      ..writeln(_relevantLaws.join('\n- '))
      ..writeln('')
      ..writeln(l10n.extractedTextLabel)
      ..writeln(_extractedText);

    await Share.share(
      text.toString(),
      subject: l10n.shareSubject,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l10n.analysisResultTitle),
      ),
      bottomNavigationBar: buildBottomNavBar(context, 2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(l10n.analysisCompleteLabel),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Domain
            Text(l10n.classifiedDomainLabel),
            Text(
              _classifiedDomain,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // Summary
            if (_summary.isNotEmpty) ...[
              Text(l10n.summaryLabel),
              Text(_summary),
              const SizedBox(height: 16),
            ],

            // Tags
            Wrap(
              spacing: 8,
              children: _tags
                  .map((tag) => Chip(label: Text(tag)))
                  .toList(),
            ),

            const SizedBox(height: 20),

            // Extracted Text
            Text(l10n.extractedTextLabel),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.white,
              child: SelectableText(_extractedText),
            ),

            const SizedBox(height: 20),

            // Relevant Laws
            Text(l10n.relevantLawsLabel),
            ..._relevantLaws.map((law) => Text("• $law")),

            const SizedBox(height: 20),

            // Buttons
            ElevatedButton(
              onPressed: _generateComplaint,
              child: Text(l10n.generateComplaintButton),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () => _shareAnalysis(l10n),
              child: Text(l10n.shareAnalysisButton),
            ),
          ],
        ),
      ),
    );
  }
}