import 'package:flutter/material.dart';
import 'package:front_end/l10n/app_localizations.dart';
import 'ai_evidence_review_screen.dart';

class EvidenceChecklistScreen extends StatefulWidget {
  const EvidenceChecklistScreen({super.key});

  @override
  State<EvidenceChecklistScreen> createState() =>
      _EvidenceChecklistScreenState();
}

class _EvidenceChecklistScreenState extends State<EvidenceChecklistScreen> {
  // Primary evidence checkboxes
  late Map<String, bool> primaryEvidence;
  late Map<String, String> primaryEvidenceKeys; // Maps label to key

  // Secondary evidence checkboxes
  late Map<String, bool> secondaryEvidence;
  late Map<String, String> secondaryEvidenceKeys; // Maps label to key

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final loc = AppLocalizations.of(context)!;

    final whatsAppLabel = '${loc.whatsApp} / SMS';
    final diaryLabel = '${loc.diary} / ${loc.incidentNotes}';

    primaryEvidence = {
      whatsAppLabel: false,
      loc.emails: false,
      loc.voiceNotes: false,
      loc.cctv: false,
      loc.callRecordings: false,
      loc.screenshots: false,
      loc.photos: false,
      loc.digitalCommunication: false,
    };

    primaryEvidenceKeys = {
      whatsAppLabel: 'whatsApp',
      loc.emails: 'emails',
      loc.voiceNotes: 'voiceNotes',
      loc.cctv: 'cctv',
      loc.callRecordings: 'callRecordings',
      loc.screenshots: 'screenshots',
      loc.photos: 'photos',
      loc.digitalCommunication: 'digitalCommunication',
    };

    secondaryEvidence = {
      loc.witnessStatements: false,
      diaryLabel: false,
      loc.medicalReports: false,
      loc.hrwarningemails: false,
      loc.patternOfBehavior: false,
    };

    secondaryEvidenceKeys = {
      loc.witnessStatements: 'witnessStatements',
      diaryLabel: 'diaryIncidentNotes',
      loc.medicalReports: 'medicalReports',
      loc.hrwarningemails: 'hrwarningemails',
      loc.patternOfBehavior: 'patternOfBehavior',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.evidenceChecklist,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            // Header icon and title
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.check_box_outlined,
                      size: 40,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.evidenceCollectionGuide,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.strongEvidenceStrengthensCase,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Primary Evidence Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                AppLocalizations.of(context)!.primaryEvidence,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Primary Evidence Items
            ...primaryEvidence.keys.map(
              (item) => _buildChecklistItem(
                label: item,
                isChecked: primaryEvidence[item]!,
                evidenceKey: primaryEvidenceKeys[item],
                onChanged: (value) {
                  setState(() {
                    primaryEvidence[item] = value!;
                  });
                },
              ),
            ),

            const SizedBox(height: 32),

            // Secondary Evidence Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                AppLocalizations.of(context)!.secondaryEvidence,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Secondary Evidence Items
            ...secondaryEvidence.keys.map(
              (item) => _buildChecklistItem(
                label: item,
                isChecked: secondaryEvidence[item]!,
                evidenceKey: secondaryEvidenceKeys[item],
                onChanged: (value) {
                  setState(() {
                    secondaryEvidence[item] = value!;
                  });
                },
              ),
            ),

            const SizedBox(height: 32),

            // Evidence Collection Guidance
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                AppLocalizations.of(context)!.evidenceCollectionGuidanceSection,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // How to Collect Evidence Legally
            _buildGuidanceSection(
              icon: Icons.check_circle,
              iconColor: Colors.green,
              title: AppLocalizations.of(context)!.howToCollectEvidenceLegally,
              items: [
                AppLocalizations.of(context)!.takeScreenshotsWithTimestamps,
                AppLocalizations.of(context)!.keepOriginalFilesSubmitCopies,
                AppLocalizations.of(context)!.documentDatesTimesLocations,
                AppLocalizations.of(context)!.getWitnessStatementsWriting,
                AppLocalizations.of(context)!.requestCCTVProperChannels,
              ],
            ),

            const SizedBox(height: 16),

            // What NOT to Do
            _buildGuidanceSection(
              icon: Icons.cancel,
              iconColor: Colors.red,
              title: AppLocalizations.of(context)!.whatNotToDo,
              items: [
                AppLocalizations.of(context)!.dontRecordCallsWithoutConsent,
                AppLocalizations.of(context)!.dontAlterOrEditEvidence,
                AppLocalizations.of(context)!.dontDeleteOriginalMessages,
                AppLocalizations.of(context)!.dontTrespassObtainEvidence,
                AppLocalizations.of(context)!.dontShareEvidencePublicly,
              ],
            ),

            const SizedBox(height: 16),

            // Tips for Preserving Digital Files
            _buildGuidanceSection(
              icon: Icons.lightbulb,
              iconColor: Colors.amber.shade700,
              title: AppLocalizations.of(
                context,
              )!.tipsForPreservivngDigitalFiles,
              items: [
                AppLocalizations.of(context)!.tipsBackupCloudStorage,
                AppLocalizations.of(context)!.tipsMultipleCopies,
                AppLocalizations.of(context)!.tipsDontCompress,
                AppLocalizations.of(context)!.tipsNoteMetadata,
                AppLocalizations.of(context)!.tipsStoreChronologically,]
              
            ),

            const SizedBox(height: 24),

            // Upload Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AIEvidenceReviewScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00401A),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.upload_file, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.uploadEvidenceForAiReview,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Bottom message
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F7F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: const Color(0xFF00401A),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.aiAnalyzeText,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistItem({
    required String label,
    required bool isChecked,
    required String? evidenceKey,
    required ValueChanged<bool?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: CheckboxListTile(
          value: isChecked,
          onChanged: onChanged,
          title: Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          secondary: IconButton(
            icon: Icon(
              Icons.info_outline,
              color: Colors.grey.shade400,
              size: 20,
            ),
            onPressed: () {
              _showInfoDialog(evidenceKey);
            },
          ),
          activeColor: const Color(0xFF00401A),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        ),
      ),
    );
  }

  Widget _buildGuidanceSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<String> items,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(String? evidenceKey) {
    final loc = AppLocalizations.of(context)!;
    String description = _getEvidenceDescription(evidenceKey, loc);
    String title = _getEvidenceTitle(evidenceKey, loc);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Got it',
              style: TextStyle(color: Color(0xFF00401A)),
            ),
          ),
        ],
      ),
    );
  }

  String _getEvidenceTitle(String? key, AppLocalizations loc) {
    switch (key) {
      case 'whatsApp':
        return '${loc.whatsApp} / SMS';
      case 'emails':
        return loc.emails;
      case 'voiceNotes':
        return loc.voiceNotes;
      case 'cctv':
        return loc.cctv;
      case 'callRecordings':
        return loc.callRecordings;
      case 'screenshots':
        return loc.screenshots;
      case 'photos':
        return loc.photos;
      case 'digitalCommunication':
        return loc.digitalCommunication;
      case 'witnessStatements':
        return loc.witnessStatements;
      case 'diaryIncidentNotes':
        return '${loc.diary} / ${loc.incidentNotes}';
      case 'medicalReports':
        return loc.medicalReports;
      case 'hrwarningemails':
        return loc.hrwarningemails;
      case 'patternOfBehavior':
        return loc.patternOfBehavior;
      default:
        return 'Evidence';
    }
  }

  String _getEvidenceDescription(String? key, AppLocalizations loc) {
    switch (key) {
      case 'whatsApp':
        return loc.evidenceWhatsAppDescription;
      case 'emails':
        return loc.evidenceEmailsDescription;
      case 'voiceNotes':
        return loc.evidenceVoiceNotesDescription;
      case 'cctv':
        return loc.evidenceCctvDescription;
      case 'callRecordings':
        return loc.evidenceCallRecordingsDescription;
      case 'screenshots':
        return loc.evidenceScreenshotsDescription;
      case 'photos':
        return loc.evidencePhotosDescription;
      case 'digitalCommunication':
        return loc.evidenceDigitalCommunicationDescription;
      case 'witnessStatements':
        return loc.evidenceWitnessStatementsDescription;
      case 'diaryIncidentNotes':
        return loc.evidenceDiaryIncidentNotesDescription;
      case 'medicalReports':
        return loc.evidenceMedicalReportsDescription;
      case 'hrwarningemails':
        return loc.evidenceHrWarningEmailsDescription;
      case 'patternOfBehavior':
        return loc.evidencePatternOfBehaviorDescription;
      default:
        return 'Important evidence for your case.';
    }
  }
}
