import 'package:flutter/material.dart';
import 'package:front_end/cyber_law_module/safety_guidance_result_screen.dart';
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
  String _status = '';
  bool _hasStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_hasStarted) return;
    _hasStarted = true;

    _status = AppLocalizations.of(context)!.preparingGuidance;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _runGuidancePipeline();
    });
  }

  Future<void> _runGuidancePipeline() async {
    try {
      if (mounted) {
        setState(() {
          _status = AppLocalizations.of(context)!.readingEvidence;
        });
      }

      final guidance = await BlackmailGuidanceService.buildGuidance(
        situation: widget.situation,
        evidenceFiles: widget.evidenceFiles,
      );

      if (!mounted) return;

      setState(() {
        _status = AppLocalizations.of(context)!.generatingGuidance;
      });

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
          style: const TextStyle(
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

            Text(
              _status,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}
