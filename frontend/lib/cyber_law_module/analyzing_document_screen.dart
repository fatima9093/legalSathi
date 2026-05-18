import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../screen_with_nav.dart';
import '../services/challan_text_extraction_service.dart';
import '../services/evidence_analysis_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'analysis_result_screen.dart';
import 'package:front_end/l10n/app_localizations.dart';

class AnalyzingDocumentScreen extends StatefulWidget {
  final Uint8List? imageBytes;
  final String? fileName;
  final bool isDemo;

  const AnalyzingDocumentScreen({
    super.key,
    this.imageBytes,
    this.fileName,
    this.isDemo = false,
  });

  @override
  State<AnalyzingDocumentScreen> createState() =>
      _AnalyzingDocumentScreenState();
}

class _AnalyzingDocumentScreenState extends State<AnalyzingDocumentScreen> {
  int _currentStep = 0;
  String? _error;
  bool _done = false;

  final List<String> _stepTitles = [
    'Reading document...',
    'Extracting text...',
    'Classifying content...',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isDemo) {
      _runDemo();
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _runPipeline();
      });
    }
  }

  Future<void> _runDemo() async {
    for (var i = 0; i < 3; i++) {
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      setState(() => _currentStep = i + 1);
    }

    if (!mounted) return;
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const AnalysisResultScreen(demoMode: true),
      ),
    );
  }

  Future<void> _runPipeline() async {
    final l10n = AppLocalizations.of(context)!;

    final bytes = widget.imageBytes;
    final name = widget.fileName;

    if (bytes == null || name == null || name.isEmpty) {
      setState(() {
        _error = l10n.errorMissingFile;
        _done = true;
      });
      return;
    }

    String ocr;

    try {
      // Detect file type from fileName
      final lowerName = name.toLowerCase();
      final fileType = lowerName.endsWith('.pdf') ? 'pdf' : 'image';

      ocr = await ChallanTextExtractionService.extractRawText(
        bytes: bytes,
        fileName: name,
        fileType: fileType,
      );
    } catch (e) {
      setState(() {
        _error = l10n.errorImageRead;
        _done = true;
      });
      return;
    }

    if (ocr.trim().length < 15) {
      setState(() {
        _error = l10n.errorLowText;
        _done = true;
      });
      return;
    }

    setState(() => _currentStep = 1);

    final analysis = await EvidenceAnalysisService.analyze(
      ocr,
      userId: Supabase.instance.client.auth.currentUser?.id,
    );

    setState(() => _currentStep = 2);

    await Future.delayed(const Duration(milliseconds: 350));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AnalysisResultScreen(
          demoMode: false,
          filePath: name,
          classifiedDomain: analysis.classifiedDomain,
          extractedText: ocr,
          tags: analysis.tags,
          relevantLaws: analysis.relevantLaws,
          summary: analysis.summary.isNotEmpty ? analysis.summary : null,
        ),
      ),
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
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      bottomNavigationBar: buildBottomNavBar(context, 2),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_error != null) ...[
                  Icon(Icons.error_outline, size: 56, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(_error!, textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.goBack),
                  ),
                ] else ...[
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: _done ? 1 : (_currentStep / 3).clamp(0.0, 1.0),
                          strokeWidth: 6,
                          color: const Color(0xFF00401A),
                        ),
                        const Icon(
                          Icons.document_scanner_outlined,
                          size: 40,
                          color: Color(0xFF00401A),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  Text(
                    l10n.analyzingTitle,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(widget.isDemo ? l10n.demoMode : l10n.ocrMode),

                  const SizedBox(height: 32),

                  ...List.generate(_stepTitles.length, (index) {
                    final completed = _currentStep > index;
                    final active = _currentStep == index + 1;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: completed || active
                                  ? const Color(0xFF00401A)
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              completed ? Icons.check : Icons.circle_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _stepTitles[index],
                              style: TextStyle(
                                fontWeight: active
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
