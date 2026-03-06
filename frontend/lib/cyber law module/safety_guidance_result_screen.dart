import 'package:flutter/material.dart';
import '../screen_with_nav.dart';

class SafetyGuidanceResultsScreen extends StatelessWidget {
  final String blackmailId;
  final String situation;

  const SafetyGuidanceResultsScreen({
    super.key,
    required this.blackmailId,
    required this.situation,
  });

  List<String> _getImmediateActions() {
    List<String> actions = [
      'DO NOT pay any money or comply with demands',
      'DO NOT delete any messages or evidence',
      'Stop all communication with the blackmailer immediately',
      'Block the person on all platforms',
      'Change your passwords on all accounts',
      'Enable two-factor authentication everywhere',
    ];

    // Personalize based on situation keywords
    String lowerSituation = situation.toLowerCase();

    if (lowerSituation.contains('photo') ||
        lowerSituation.contains('image') ||
        lowerSituation.contains('picture') ||
        lowerSituation.contains('video')) {
      actions.add(
          'Report intimate images to platform immediately (they have takedown policies)');
      actions.add('Document all platforms where content may be shared');
    }

    if (lowerSituation.contains('money') ||
        lowerSituation.contains('payment') ||
        lowerSituation.contains('bank') ||
        lowerSituation.contains('account')) {
      actions.add('Alert your bank about potential fraud');
      actions.add('Monitor your financial accounts closely');
    }

    if (lowerSituation.contains('social media') ||
        lowerSituation.contains('facebook') ||
        lowerSituation.contains('instagram') ||
        lowerSituation.contains('whatsapp')) {
      actions.add('Set all social media accounts to private');
      actions.add('Review and limit who can see your friend list');
    }

    return actions;
  }

  List<String> _getEvidencePreservation() {
    List<String> checklist = [
      'Screenshot all threatening messages with timestamps',
      'Save phone numbers, email addresses, social media profiles',
      'Document dates, times, and methods of contact',
      'Keep original files/messages (do not edit)',
      'Inform trusted family member or friend',
      'Consider deactivating social media temporarily',
    ];

    String lowerSituation = situation.toLowerCase();

    if (lowerSituation.contains('email')) {
      checklist.add('Save email headers (View > Show Original in Gmail)');
      checklist.add('Do not mark emails as spam - keep them as evidence');
    }

    if (lowerSituation.contains('call') ||
        lowerSituation.contains('phone') ||
        lowerSituation.contains('voice')) {
      checklist.add('Check call logs and take screenshots');
      checklist.add('If possible, record future calls (legal in Pakistan)');
    }

    if (lowerSituation.contains('threat') ||
        lowerSituation.contains('harm') ||
        lowerSituation.contains('violence')) {
      checklist
          .add('Document any physical threats separately for police report');
      checklist.add('Consider informing local police immediately');
    }

    return checklist;
  }

  List<String> _getReportingSteps() {
    List<String> steps = [
      'File complaint with FIA Cyber Crime Wing (online or in person)',
      'Visit nearest police station to file FIR',
      'Report to platform (Facebook, Instagram, WhatsApp, etc.)',
      'Contact National Commission for Human Rights if needed',
      'Consider consulting a lawyer for legal advice',
    ];

    String lowerSituation = situation.toLowerCase();

    if (lowerSituation.contains('sexual') ||
        lowerSituation.contains('intimate') ||
        lowerSituation.contains('nude') ||
        lowerSituation.contains('private')) {
      steps.insert(
          0, 'URGENT: Report to FIA Cyber Crime immediately - this is priority');
      steps.add(
          'Contact helpline 1991 (FIA Cyber Crime) for immediate assistance');
    }

    if (lowerSituation.contains('minor') ||
        lowerSituation.contains('child') ||
        lowerSituation.contains('underage')) {
      steps.insert(0,
          'CRITICAL: Contact Child Protection Bureau immediately at 1121');
      steps.add('Report to NCRC (National Commission on Rights of Child)');
    }

    if (lowerSituation.contains('workplace') ||
        lowerSituation.contains('colleague') ||
        lowerSituation.contains('boss') ||
        lowerSituation.contains('office')) {
      steps.add('Report to HR department with documented evidence');
      steps.add('File complaint with Provincial Ombudsperson if applicable');
    }

    return steps;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Critical warning card
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
                                  'Critical: Do Not Pay',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Follow these steps immediately',
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

                    // Immediate Actions
                    const Text(
                      'Immediate Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _buildActionsList(_getImmediateActions()),

                    const SizedBox(height: 24),

                    // Evidence Preservation Checklist
                    const Text(
                      'Evidence Preservation Checklist',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _buildChecklistCard(_getEvidencePreservation()),

                    const SizedBox(height: 24),

                    // Reporting Steps
                    const Text(
                      'Reporting Steps',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _buildReportingSteps(_getReportingSteps()),

                    const SizedBox(height: 24),

                    // Legal Options
                    const Text(
                      'Legal Options',
                      style: TextStyle(
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
                                'This is a serious crime with severe penalties',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildBulletPoint(
                            'PECA Section 20: Cyber Extortion (up to 14 years imprisonment)',
                          ),
                          _buildBulletPoint(
                            'PECA Section 21: Unauthorized access (up to 7 years)',
                          ),
                          _buildBulletPoint(
                            'Pakistan Penal Code Section 384: Extortion',
                          ),
                          _buildBulletPoint(
                            'This is a cognizable, non-bailable offense',
                          ),
                        ],
                      ),
                    ),

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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          // Remove checkmark if already in text
          String displayText = entry.value;
          if (displayText.startsWith('✓ ')) {
            displayText = displayText.substring(2);
          }

          return Padding(
            padding: EdgeInsets.only(
              bottom: entry.key < items.length - 1 ? 12 : 0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green.shade700,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    displayText,
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

  Widget _buildReportingSteps(List<String> steps) {
    return Container(
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
        children: steps.asMap().entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: entry.key < steps.length - 1 ? 12 : 0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00401A),
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
