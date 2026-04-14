import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../labour rights module/file_general_complaint_screen.dart';
import '../screen_with_nav.dart';

class AnalysisResultScreen extends StatefulWidget {
  final String? filePath;
  final String? classifiedDomain;
  final String? extractedText;
  final List<String>? tags;
  final List<String>? relevantLaws;
  final String? summary;

  /// Sample salary-slip style content when no OCR pipeline ran.
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
      _extractedText =
          '''Employee Name: Muhammad Ali
CNIC: 00000-0000000-0
Position: Software Engineer
Department: IT
Basic Salary: 50,000 PKR
Allowances: 10,000 PKR
Deductions: 5,000 PKR
Net Salary: 55,000 PKR
Payment Date: February 2026

The salary slip confirms employment with monthly compensation. This document can be used as proof of employment and income for legal purposes.''';
      _tags = const ['Salary Slip', 'Employment Proof'];
      _relevantLaws = const [
        'Labour Code / minimum wage rules — verify current provincial notification.',
        'Payment of Wages — timely payment and authorised deductions.',
        'Cross-check allowances and deductions with your appointment terms.',
      ];
      _classifiedDomain = 'Labour — sample salary slip (demo)';
      _summary =
          'Demo only: replace with a real screenshot upload for OCR and analysis.';
    } else {
      _extractedText = widget.extractedText?.trim().isNotEmpty == true
          ? widget.extractedText!.trim()
          : 'No text was extracted.';
      _tags = widget.tags != null && widget.tags!.isNotEmpty
          ? List<String>.from(widget.tags!)
          : ['Document'];
      _relevantLaws = widget.relevantLaws != null &&
              widget.relevantLaws!.isNotEmpty
          ? List<String>.from(widget.relevantLaws!)
          : [
              'Review the applicable Pakistani statute with a lawyer or official source.',
            ];
      _classifiedDomain = widget.classifiedDomain?.trim().isNotEmpty == true
          ? widget.classifiedDomain!.trim()
          : 'Unclassified document';
      _summary = widget.summary?.trim() ?? '';
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _extractedText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Text copied to clipboard'),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFF00401A),
      ),
    );
  }

  void _generateComplaint() {
    final issue = StringBuffer()
      ..writeln('Issue inferred from screenshot evidence')
      ..writeln('Domain: $_classifiedDomain');
    if (_tags.isNotEmpty) {
      issue.writeln('Tags: ${_tags.join(', ')}');
    }
    issue
      ..writeln('')
      ..writeln('Summary:')
      ..writeln(_summary.isNotEmpty ? _summary : 'User requests legal action based on extracted evidence.')
      ..writeln('')
      ..writeln('Extracted evidence text:')
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

  Future<void> _shareAnalysis() async {
    final shareText = StringBuffer()
      ..writeln('Legal Sathi - Evidence Analysis')
      ..writeln('Domain: $_classifiedDomain')
      ..writeln('Tags: ${_tags.join(', ')}')
      ..writeln('');
    if (_summary.isNotEmpty) {
      shareText
        ..writeln('Summary:')
        ..writeln(_summary)
        ..writeln('');
    }
    if (_relevantLaws.isNotEmpty) {
      shareText.writeln('Relevant Laws:');
      for (final law in _relevantLaws) {
        shareText.writeln('- $law');
      }
      shareText.writeln('');
    }
    shareText
      ..writeln('Extracted Text:')
      ..writeln(_extractedText);

    await Share.share(
      shareText.toString(),
      subject: 'Legal Sathi Evidence Analysis',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Analysis Result',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavBar(context, 2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Analysis Complete Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00401A),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Analysis Complete',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Classified Domain Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00401A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.work,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Classified Domain',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _classifiedDomain,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (_summary.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF00401A).withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF00401A).withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Summary',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _summary,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Tags
            Wrap(
              spacing: 8,
              children: _tags
                  .map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00401A).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF00401A).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF00401A),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 24),

            // Extracted Text Section
            const Text(
              'Extracted Text',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.copy,
                          size: 20,
                          color: Color(0xFF00401A),
                        ),
                        onPressed: _copyToClipboard,
                        tooltip: 'Copy text',
                      ),
                    ],
                  ),
                  SelectableText(
                    _extractedText,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Relevant Laws Section
            const Text(
              'Relevant Laws',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 12),

            Column(
              children: _relevantLaws
                  .map(
                    (law) => Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00401A).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.menu_book,
                              color: Color(0xFF00401A),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              law,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 24),

            // Generate Complaint Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _generateComplaint,
                icon: const Icon(Icons.description, color: Colors.white),
                label: const Text(
                  'Generate Complaint',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00401A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Share Analysis Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _shareAnalysis,
                icon: const Icon(Icons.share, color: Color(0xFF00401A)),
                label: const Text(
                  'Share Analysis',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00401A),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF00401A)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
