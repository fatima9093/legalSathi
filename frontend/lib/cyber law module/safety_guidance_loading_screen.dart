import 'package:flutter/material.dart';
import 'package:front_end/cyber%20law%20module/safety_guidance_result_screen.dart';

class SafetyGuidanceLoadingScreen extends StatefulWidget {
  final String blackmailId;
  final String situation;

  const SafetyGuidanceLoadingScreen({
    super.key,
    required this.blackmailId,
    required this.situation,
  });

  @override
  State<SafetyGuidanceLoadingScreen> createState() =>
      _SafetyGuidanceLoadingScreenState();
}

class _SafetyGuidanceLoadingScreenState
    extends State<SafetyGuidanceLoadingScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate loading and navigate to next screen after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SafetyGuidanceResultsScreen(
              blackmailId: widget.blackmailId,
              situation: widget.situation,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Safety Guidance',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Loading indicator
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color(0xFF00401A),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Loading text
            Text(
              'Preparing safety guidance...',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}