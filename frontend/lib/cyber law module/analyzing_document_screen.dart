import 'package:flutter/material.dart';
import '../screen_with_nav.dart';
import 'analysis_result_screen.dart';

class AnalyzingDocumentScreen extends StatefulWidget {
  final String filePath;

  const AnalyzingDocumentScreen({super.key, required this.filePath});

  @override
  State<AnalyzingDocumentScreen> createState() =>
      _AnalyzingDocumentScreenState();
}

class _AnalyzingDocumentScreenState extends State<AnalyzingDocumentScreen> {
  late List<_AnalysisStep> steps;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    steps = [
      _AnalysisStep(
        title: 'Reading document...',
        icon: Icons.description,
        duration: const Duration(seconds: 2),
      ),
      _AnalysisStep(
        title: 'Extracting text...',
        icon: Icons.search,
        duration: const Duration(seconds: 2),
      ),
      _AnalysisStep(
        title: 'Classifying content...',
        icon: Icons.label,
        duration: const Duration(seconds: 2),
      ),
    ];
    _simulateAnalysis();
  }

  void _simulateAnalysis() async {
    for (int i = 0; i < steps.length; i++) {
      await Future.delayed(steps[i].duration);
      if (mounted) {
        setState(() {
          _currentStep = i + 1;
        });
      }
    }

    // Navigate to results after all steps complete with file path
    if (mounted) {
      await Future.delayed(const Duration(milliseconds: 500));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AnalysisResultScreen(filePath: widget.filePath),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Circular Progress Indicator
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
                          value: _currentStep / steps.length,
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
                        child: Icon(
                          steps[(_currentStep - 1).clamp(0, steps.length - 1)]
                              .icon,
                          size: 40,
                          color: const Color(0xFF00401A),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                const Text(
                  'Analyzing Your Document',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle
                const Text(
                  'Please wait while we process your evidence',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),

                const SizedBox(height: 32),

                // Steps
                Column(
                  children: List.generate(steps.length, (index) {
                    final isCompleted = _currentStep > index;
                    final isActive = _currentStep == index + 1;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: AnimatedOpacity(
                        opacity: _currentStep >= index + 1 ? 1.0 : 0.5,
                        duration: const Duration(milliseconds: 300),
                        child: Row(
                          children: [
                            // Icon
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isCompleted || isActive
                                    ? const Color(0xFF00401A)
                                    : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                isCompleted ? Icons.check : steps[index].icon,
                                color: isCompleted || isActive
                                    ? Colors.white
                                    : Colors.grey.shade600,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Text
                            Expanded(
                              child: Text(
                                steps[index].title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isActive
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: isActive
                                      ? const Color(0xFF00401A)
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnalysisStep {
  final String title;
  final IconData icon;
  final Duration duration;

  _AnalysisStep({
    required this.title,
    required this.icon,
    required this.duration,
  });
}
