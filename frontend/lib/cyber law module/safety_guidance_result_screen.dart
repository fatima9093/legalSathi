import 'package:flutter/material.dart';
import 'package:front_end/l10n/app_localizations.dart';
import 'package:front_end/services/blackmail_guidance_service.dart';
import '../screen_with_nav.dart';

class SafetyGuidanceResultsScreen extends StatelessWidget {
  final String blackmailId;
  final String situation;
  final BlackmailGuidanceResult? guidance;

  const SafetyGuidanceResultsScreen({
    super.key,
    required this.blackmailId,
    required this.situation,
    this.guidance,
  });

  List<String> _getImmediateActions(AppLocalizations loc) {
    List<String> actions = [
      loc.actionDoNotPay,
      loc.actionDoNotDelete,
      loc.actionStopCommunication,
      loc.actionBlockPerson,
      loc.actionChangePasswords,
      loc.actionEnable2FA,
    ];

    String lowerSituation = situation.toLowerCase();

    if (lowerSituation.contains('photo') ||
        lowerSituation.contains('image') ||
        lowerSituation.contains('picture') ||
        lowerSituation.contains('video')) {
      actions.add(loc.actionReportImages);
      actions.add(loc.actionDocumentPlatforms);
    }

    if (lowerSituation.contains('money') ||
        lowerSituation.contains('payment') ||
        lowerSituation.contains('bank') ||
        lowerSituation.contains('account')) {
      actions.add(loc.actionAlertBank);
      actions.add(loc.actionMonitorAccounts);
    }

    if (lowerSituation.contains('social media') ||
        lowerSituation.contains('facebook') ||
        lowerSituation.contains('instagram') ||
        lowerSituation.contains('whatsapp')) {
      actions.add(loc.actionPrivateAccounts);
      actions.add(loc.actionLimitFriends);
    }

    return actions;
  }

  List<String> _getEvidencePreservation(AppLocalizations loc) {
    List<String> checklist = [
      loc.evidenceScreenshot,
      loc.evidenceSaveContacts,
      loc.evidenceDocumentDetails,
      loc.evidenceKeepOriginal,
      loc.evidenceInformTrusted,
      loc.evidenceDeactivateSocial,
    ];

    String lowerSituation = situation.toLowerCase();

    if (lowerSituation.contains('email')) {
      checklist.add(loc.evidenceEmailHeaders);
      checklist.add(loc.evidenceKeepEmails);
    }

    if (lowerSituation.contains('call') ||
        lowerSituation.contains('phone') ||
        lowerSituation.contains('voice')) {
      checklist.add(loc.evidenceCallLogs);
      checklist.add(loc.evidenceRecordCalls);
    }

    if (lowerSituation.contains('threat') ||
        lowerSituation.contains('harm') ||
        lowerSituation.contains('violence')) {
      checklist.add(loc.evidencePhysicalThreats);
      checklist.add(loc.evidenceInformPolice);
    }

    return checklist;
  }

  List<String> _getReportingSteps(AppLocalizations loc) {
    List<String> steps = [
      loc.reportFIA,
      loc.reportPolice,
      loc.reportPlatform,
      loc.reportHumanRights,
      loc.reportLawyer,
    ];

    String lowerSituation = situation.toLowerCase();

    if (lowerSituation.contains('sexual') ||
        lowerSituation.contains('intimate') ||
        lowerSituation.contains('nude') ||
        lowerSituation.contains('private')) {
      steps.insert(0, loc.reportUrgentFIA);
      steps.add(loc.reportHelpline);
    }

    if (lowerSituation.contains('minor') ||
        lowerSituation.contains('child') ||
        lowerSituation.contains('underage')) {
      steps.insert(0, loc.reportChildProtection);
      steps.add(loc.reportNCRC);
    }

    if (lowerSituation.contains('workplace') ||
        lowerSituation.contains('colleague') ||
        lowerSituation.contains('boss') ||
        lowerSituation.contains('office')) {
      steps.add(loc.reportHR);
      steps.add(loc.reportOmbudsperson);
    }

    return steps;
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
          loc.safetyGuidance,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.red.shade700,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc.criticalDoNotPay,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  loc.followStepsImmediately,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    if (guidance != null) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade100),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.aiSummary,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.blue.shade900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              guidance!.analysisSummary,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.4,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    Text(
                      loc.immediateActions,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _buildActionsList(
                      guidance?.immediateActions ??
                          _getImmediateActions(loc),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      loc.evidenceChecklist,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _buildChecklistCard(
                      guidance?.evidenceChecklist ??
                          _getEvidencePreservation(loc),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      loc.reportingSteps,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _buildReportingSteps(
                      guidance?.reportingSteps ??
                          _getReportingSteps(loc),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      loc.legalOptions,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.shield_outlined,
                                color: Colors.blue.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                loc.seriousCrimeNotice,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...((guidance?.legalOptions ??
                                  [
                                    loc.legalPeca20,
                                    loc.legalPeca21,
                                    loc.legalPpc384,
                                    loc.legalNonBailable,
                                  ])
                              .map(_buildBulletPoint)),
                        ],
                      ),
                    ),

                    if (guidance != null) ...[
                      const SizedBox(height: 24),
                      Text(
                        loc.extractedEvidencePreview,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          guidance!.extractedEvidencePreview,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade800,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: buildBottomNavBar(context, 3),
    );
  }

  Widget _buildActionsList(List<String> actions) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: actions.asMap().entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: entry.key < actions.length - 1 ? 12 : 0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.red.shade700,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${entry.key + 1}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade800,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChecklistCard(List<String> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: items.map((item) => _buildBulletPoint(item)).toList(),
      ),
    );
  }

  Widget _buildReportingSteps(List<String> steps) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: steps.map((step) => _buildBulletPoint(step)).toList(),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 14)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade800,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}