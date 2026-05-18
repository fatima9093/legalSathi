import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:front_end/l10n/app_localizations.dart';
import 'fia_complaint_generator.dart';
import 'package:front_end/services/challan_text_extraction_service.dart';
import 'package:front_end/services/evidence_analysis_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReportingGuidanceScreen extends StatefulWidget {
  final String profileUrl;
  final String username;
  final String platform;
  final List<PlatformFile> uploadedFiles;
  final String? reportId;

  const ReportingGuidanceScreen({
    super.key,
    required this.profileUrl,
    required this.username,
    required this.platform,
    required this.uploadedFiles,
    this.reportId,
  });

  @override
  State<ReportingGuidanceScreen> createState() =>
      _ReportingGuidanceScreenState();
}

class _ReportingGuidanceScreenState extends State<ReportingGuidanceScreen> {
  bool _isLoading = true;
  String _analysisSummary = '';
  List<String> _legalOptions = [];
  List<String> _protectionTips = [];
  List<String> _reportingSteps = [];

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _analyzeInput();
    });
  }

  Future<void> _analyzeInput() async {
    final loc = AppLocalizations.of(context)!;
    final platformSteps = _getPlatformSteps(widget.platform);
    final tips = <String>[
      loc.tipSaveScreenshots,
      loc.tipDocumentInteractions,
      loc.tipInformContacts,
      loc.tipEnablePrivacy,
    ];

    final profileInfo = [
      if (widget.profileUrl.trim().isNotEmpty)
        '${loc.urlLabel}: ${widget.profileUrl.trim()}',
      if (widget.username.trim().isNotEmpty)
        '${loc.usernameLabel}: ${widget.username.trim()}',
      '${loc.platformLabel}: ${widget.platform}',
    ].join('\n');

    final evidenceText = await _extractEvidenceText(widget.uploadedFiles);
    final combined = [
      profileInfo,
      evidenceText,
    ].where((e) => e.trim().isNotEmpty).join('\n\n');

    EvidenceAnalysisResult? analysis;
    if (combined.trim().length >= 15) {
      analysis = await EvidenceAnalysisService.analyze(
        combined,
        userId: Supabase.instance.client.auth.currentUser?.id,
      );
    }

    final legal = <String>[
      loc.legalFia,
      loc.legalPta,
      loc.legalFIR,
      loc.legalCivilCase,
    ];
    if (analysis != null) {
      for (final law in analysis.relevantLaws) {
        if (!legal.contains(law)) {
          legal.add(law);
        }
      }
    }

    if (mounted) {
      setState(() {
        _analysisSummary = analysis?.summary.isNotEmpty == true
            ? analysis!.summary
            : 'Guidance prepared from profile details and uploaded screenshots.';
        _reportingSteps = platformSteps;
        _legalOptions = legal.take(6).toList();
        _protectionTips = tips;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          loc.reportingGuidanceTitle,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? _buildLoadingScreen(AppLocalizations.of(context)!)
          : _buildResultsScreen(AppLocalizations.of(context)!),
    );
  }

  Widget _buildLoadingScreen(AppLocalizations loc) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade400),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            loc.analyzingAccount,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsScreen(AppLocalizations loc) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),

          // Fake Account Detected Alert
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 20,
                          color: Colors.red.shade600,
                        ),
                        Icon(Icons.close, size: 14, color: Colors.red.shade600),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.fakeAccountDetected,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.red.shade600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          loc.followStepsReport,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (widget.reportId != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${loc.referenceId}: ${widget.reportId}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),

          if (_analysisSummary.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.aiSummary,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _analysisSummary,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade900,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 20),

          // Platform-specific reporting guide
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.howToReport(widget.platform),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._reportingSteps.asMap().entries.map(
                    (e) => _buildStepItem(e.key + 1, e.value),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Legal Options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.legalOptions,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        ..._legalOptions.asMap().entries.map((entry) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: entry.key == _legalOptions.length - 1
                                  ? 0
                                  : 12,
                            ),
                            child: _buildLegalOption(entry.value),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Additional Protection Tips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.protectionTips,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._protectionTips.asMap().entries.map((entry) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: entry.key == _protectionTips.length - 1 ? 0 : 8,
                      ),
                      child: _buildTipItem(entry.value),
                    );
                  }),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // File FIA Complaint Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FIAComplaintGeneratorScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.description_outlined, size: 20),
                label: Text(loc.fileFiaComplaint),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00401A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Report Another Account Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  side: BorderSide(color: Colors.grey.shade400),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  loc.reportAnotherAccount,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Info message
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.yellow.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.yellow.shade300),
            ),
            child: Text(
              'Platform response time: 24-48 hours. FIA Investigation: 7-14 days.',
              style: TextStyle(fontSize: 12, color: Colors.yellow.shade800),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStepItem(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF00401A),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getPlatformSteps(String platform) {
    final p = platform.toLowerCase();
    if (p.contains('instagram')) {
      return [
        'Open the fake Instagram profile and tap the three dots.',
        'Choose Report > It\'s pretending to be someone else.',
        'Select me/another person and submit.',
        'Add screenshots and profile details if prompted.',
        'Monitor in-app support requests for updates.',
      ];
    }
    if (p.contains('facebook')) {
      return [
        'Open the fake Facebook profile.',
        'Tap the three dots and choose Find support or report profile.',
        'Select Pretending to be someone.',
        'Choose who is being impersonated and submit.',
        'Check Support Inbox for response.',
      ];
    }
    if (p.contains('tiktok')) {
      return [
        'Open fake TikTok profile and tap Share/Report.',
        'Select Report account > Pretending to be someone.',
        'Provide your real profile and evidence screenshots.',
        'Submit and keep complaint reference.',
      ];
    }
    if (p.contains('twitter') || p.contains('x')) {
      return [
        'Open the fake X/Twitter account profile.',
        'Tap three dots > Report.',
        'Select It\'s suspicious or spam / impersonation path.',
        'Submit report with username/link evidence.',
      ];
    }
    if (p.contains('linkedin')) {
      return [
        'Open fake LinkedIn profile.',
        'Click More > Report/Block.',
        'Choose impersonation reason and submit.',
        'Use LinkedIn help center if additional proof is requested.',
      ];
    }
    return [
      'Open the fake profile on the platform.',
      'Use the account\'s Report option.',
      'Select impersonation/fake account reason.',
      'Submit with username, URL, and screenshots.',
      'Track response in platform help/support center.',
    ];
  }

  Future<String> _extractEvidenceText(List<PlatformFile> files) async {
    final chunks = <String>[];
    for (final f in files.take(4)) {
      final bytes = f.bytes;
      if (bytes == null || bytes.isEmpty) continue;
      final n = f.name.toLowerCase();
      final isImage =
          n.endsWith('.jpg') ||
          n.endsWith('.jpeg') ||
          n.endsWith('.png') ||
          n.endsWith('.webp');
      if (!isImage) continue;
      try {
        final text = await ChallanTextExtractionService.extractRawText(
          bytes: bytes,
          fileName: f.name,
          fileType: 'image',
        );
        if (text.trim().isNotEmpty) {
          chunks.add(text.trim());
        }
      } catch (_) {}
    }
    return chunks.join('\n\n---\n\n');
  }

  Widget _buildLegalOption(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: Colors.blue.shade600,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 12),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildTipItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.info_outline,
            color: Colors.orange.shade700,
            size: 12,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
