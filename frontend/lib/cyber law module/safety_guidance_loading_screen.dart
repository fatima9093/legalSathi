import 'package:flutter/material.dart';
import 'package:front_end/cyber%20law%20module/safety_guidance_result_screen.dart';
import 'package:front_end/l10n/app_localizations.dart';
import 'package:front_end/models/blackmail_model.dart';
import 'package:front_end/services/blackmail_guidance_service.dart';

class SafetyGuidanceLoadingScreen extends StatefulWidget {
  final String blackmailId;
  final String situation;
  final List<EvidenceFile> evidenceFiles;

  const SafetyGuidanceLoadingScreen({
    super.key,
    required this.blackmailId,
    required this.situation,
    required this.evidenceFiles,
  });

  @override
  State<SafetyGuidanceLoadingScreen> createState() =>
      _SafetyGuidanceLoadingScreenState();
}

class _SafetyGuidanceLoadingScreenState
    extends State<SafetyGuidanceLoadingScreen> {

   late String _status;

  @override
  void initState() {
    super.initState();
     final loc = AppLocalizations.of(context)!;
     _status = loc.preparingGuidance;
    _runGuidancePipeline();
  }

  Future<void> _runGuidancePipeline() async {
    final loc = AppLocalizations.of(context)!;
    try {
      if (mounted) {
        setState(() => _status = loc.readingEvidence);
      }
      final guidance = await BlackmailGuidanceService.buildGuidance(
        situation: widget.situation,
        evidenceFiles: widget.evidenceFiles,
      );
      if (!mounted) return;
       setState(() => _status = loc.generatingGuidance);
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SafetyGuidanceResultsScreen(
            blackmailId: widget.blackmailId,
            situation: widget.situation,
            guidance: guidance,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
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
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          loc.safetyGuidance,
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
              _status,
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