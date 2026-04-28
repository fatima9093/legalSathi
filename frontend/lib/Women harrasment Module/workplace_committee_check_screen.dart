import 'package:flutter/material.dart';
import 'package:front_end/l10n/app_localizations.dart';
import 'internal_complaint_info_screen.dart';
import 'ombudspersonComplaintsSteps_screen.dart';

class WorkplaceCommitteeCheckScreen extends StatefulWidget {
  const WorkplaceCommitteeCheckScreen({super.key});

  @override
  State<WorkplaceCommitteeCheckScreen> createState() =>
      _WorkplaceCommitteeCheckScreenState();
}

class _WorkplaceCommitteeCheckScreenState
    extends State<WorkplaceCommitteeCheckScreen> {
  int? _selectedOption;

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
          loc.workplaceCommittee,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Icon
              Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: const Center(
                    child: Text(
                      '?',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                loc.committeeCheck,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              Text(
                loc.committeeQuestion,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Color(0xFF757575)),
              ),

              const SizedBox(height: 32),

              _buildOptionCard(
                index: 0,
                icon: Icons.check_circle_outline,
                iconColor: const Color(0xFF4CAF50),
                iconBgColor: const Color(0xFFE8F5E9),
                title: loc.yesCommittee,
                subtitle: loc.fileInternalComplaint,
              ),

              const SizedBox(height: 12),

              _buildOptionCard(
                index: 1,
                icon: Icons.error_outline,
                iconColor: const Color(0xFFF44336),
                iconBgColor: const Color(0xFFFFEBEE),
                title: loc.noCommittee,
                subtitle: loc.fileWithOmbudsperson,
              ),

              const SizedBox(height: 12),

              _buildOptionCard(
                index: 2,
                icon: Icons.help_outline,
                iconColor: const Color(0xFFFF9800),
                iconBgColor: const Color(0xFFFFF3E0),
                title: loc.dontKnow,
                subtitle: loc.checkWithHR,
              ),

              const SizedBox(height: 20),

              if (_selectedOption == 1)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFB300)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFFE65100)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          loc.noCommitteeInfo,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _selectedOption != null
                      ? () {
                          if (_selectedOption == 0 || _selectedOption == 2) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const InternalComplaintInfoScreen(),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const OmbudspersonComplaintsStepsScreen(),
                              ),
                            );
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00401A),
                  ),
                  child: Text(loc.continueText),
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  loc.employerNote,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required int index,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedOption == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedOption = index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
              color: isSelected ? const Color(0xFF00401A) : Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                Text(subtitle),
              ],
            ),
          ],
        ),
      ),
    );
  }
}