import 'package:flutter/material.dart';
import 'package:front_end/l10n/app_localizations.dart';

import 'police_complaint_filing_screen.dart';
import 'police_immediate_steps_screen.dart';
import 'traffic_contact_launcher.dart';
import 'traffic_police_contacts.dart';

class PoliceMisbehaviorGuideScreen extends StatelessWidget {
  const PoliceMisbehaviorGuideScreen({super.key});

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
          loc.policeMisbehaviorGuide,
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Know Your Rights card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F7F0),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF00401A).withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.shield_outlined,
                              color: Color(0xFF00401A),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc.knowYourRights,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  loc.stepsIfMisbehaves,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Section title
                    Text(
                      loc.whatCountsMisbehavior,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF00401A),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Misbehavior items
                    _buildMisbehaviorItem(
                      icon: Icons.error_outline,
                      title: loc.bribeTitle,
                      description: loc.bribeDesc,
                      severity: loc.serious,
                      severityColor: const Color(0xFFDC2626),
                    ),

                    const SizedBox(height: 12),

                    _buildMisbehaviorItem(
                      icon: Icons.error_outline,
                      title: loc.threatTitle,
                      description: loc.threatDesc,
                      severity: loc.serious,
                      severityColor: const Color(0xFFDC2626),
                    ),

                    const SizedBox(height: 12),

                    _buildMisbehaviorItem(
                      icon: Icons.warning_amber_outlined,
                      title: loc.illegalConfiscationTitle,
                      description: loc.illegalConfiscationDesc,
                      severity: loc.moderate,
                      severityColor: const Color(0xFFD97706),
                    ),

                    const SizedBox(height: 12),

                    _buildMisbehaviorItem(
                      icon: Icons.warning_amber_outlined,
                      title: loc.wrongChallanTitle,
                      description: loc.wrongChallanDesc,
                      severity: loc.moderate,
                      severityColor: const Color(0xFFD97706),
                    ),

                    const SizedBox(height: 12),

                    _buildMisbehaviorItem(
                      icon: Icons.error_outline,
                      title: loc.harassmentTitle,
                      description: loc.harassmentDesc,
                      severity: loc.serious,
                      severityColor: const Color(0xFFDC2626),
                    ),

                    const SizedBox(height: 24),

                    // Action buttons
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const PoliceImmediateStepsScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00401A),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              loc.viewImmediateSteps,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const PoliceComplaintFilingScreen(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF00401A),
                          minimumSize: const Size(double.infinity, 54),
                          side: const BorderSide(
                            color: Color(0xFF00401A),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          loc.fileComplaintNow,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Bottom tip
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF9E6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        loc.documentTip,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => TrafficContactLauncher.dial(
                        context,
                        TrafficPoliceContacts.helpline1915,
                      ),
                      icon: const Icon(Icons.phone, size: 20),
                      label: Text(loc.call1915),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF00401A),
                        side: const BorderSide(color: Color(0xFF00401A)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const PoliceComplaintFilingScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.route, size: 20),
                      label: Text(loc.complaintPaths),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00401A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMisbehaviorItem({
    required IconData icon,
    required String title,
    required String description,
    required String severity,
    required Color severityColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: severityColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: severityColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        severity,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: severityColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
