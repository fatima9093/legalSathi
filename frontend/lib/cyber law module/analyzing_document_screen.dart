import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../screen_with_nav.dart';
import '../services/challan_text_extraction_service.dart';
import '../services/evidence_analysis_service.dart';
import 'analysis_result_screen.dart';

/// Processes a screenshot: OCR via [ChallanTextExtractionService], then
/// domain/laws via backend [EvidenceAnalysisService].
///
/// [isDemo] skips OCR and opens [AnalysisResultScreen] with sample content.
class AnalyzingDocumentScreen extends StatefulWidget {
  final Uint8List? imageBytes;
  final String? fileName;

  /// Uses bundled-style sample analysis (no network).
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
  static const List<String> _stepTitles = [
    'Extracting text from image…',
    'Identifying legal domain…',
    'Finding relevant laws…',
  ];

  int _currentStep = 0;
  String? _error;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    if (widget.isDemo) {
      _runDemo();
    } else {
      _runPipeline();
    }
  }

  Future<void> _runDemo() async {
    for (var i = 0; i < _stepTitles.length; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      setState(() => _currentStep = i + 1);
    }
    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const AnalysisResultScreen(demoMode: true),
      ),
    );
  }

  Future<void> _runPipeline() async {
    final bytes = widget.imageBytes;
    final name = widget.fileName;
    if (bytes == null || bytes.isEmpty || name == null || name.isEmpty) {
      setState(() {
        _error = 'Missing file data. Please try uploading again.';
        _done = true;
      });
      return;
    }

    setState(() => _currentStep = 0);

    String ocr;
    try {
      ocr = await ChallanTextExtractionService.extractRawText(
        bytes: bytes,
        fileName: name,
        fileType: 'image',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not read the image: $e';
        _done = true;
      });
      return;
    }

    if (!mounted) return;
    if (ocr.trim().length < 15) {
      setState(() {
        _error =
            'Very little text was read. Try a sharper screenshot, better lighting, or paste the text manually.';
        _done = true;
      });
      return;
    }

    setState(() => _currentStep = 1);

    final analysis = await EvidenceAnalysisService.analyze(ocr);

    if (!mounted) return;
    setState(() => _currentStep = 2);
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    await Navigator.pushReplacement(
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
                  Icon(Icons.error_outline, size: 56, color: Colors.red.shade700),
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade800, height: 1.4),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF00401A),
                    ),
                    child: const Text('Go back'),
                  ),
                ] else ...[
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: CircularProgressIndicator(
                            value: _done ? 1 : (_currentStep / _stepTitles.length).clamp(0.0, 1.0),
                            strokeWidth: 6,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF00401A),
                            ),
                            backgroundColor: Colors.grey.shade300,
                          ),
                        ),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00401A).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.document_scanner_outlined,
                            size: 40,
                            color: Color(0xFF00401A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Analyzing your evidence',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.isDemo ? 'Demo mode (sample result)' : 'OCR and legal context',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
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
                              color: completed || active ? Colors.white : Colors.grey.shade600,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _stepTitles[index],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                                color: active ? const Color(0xFF00401A) : Colors.grey.shade600,
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
