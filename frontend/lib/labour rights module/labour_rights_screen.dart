import 'package:flutter/material.dart';
import '../screen_with_nav.dart';
import 'minimum_wage_checker_screen.dart';
import 'overtime_pay_calculator_screen.dart';
import 'paid_leave_eligibility_screen.dart';
import 'contract_violation_checker_screen.dart';
import 'file_labour_complaint_screen.dart';
import 'draft_labour_application_screen.dart';
import '../cyber law module/screenshot_evidence_reader_screen.dart';
import 'package:front_end/scenario_simulator_screen.dart';
import 'package:front_end/models/scenario_model.dart';

class LabourRightsScreen extends StatefulWidget {
  const LabourRightsScreen({super.key});

  @override
  State<LabourRightsScreen> createState() => _LabourRightsScreenState();
}

class _LabourRightsScreenState extends State<LabourRightsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Labour Rights',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavBar(context, 2),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with Urdu text
            Container(
              width: double.infinity,
              color: const Color(0xFFF5F5F5),
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: const Text(
                'مزدور\nحقوق',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search sections...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // List items
            _buildListItem(
              icon: Icons.table_chart,
              iconColor: const Color(0xFF00401A),
              iconBgColor: const Color(0xFFE6EFEA),
              title: 'Minimum Wage Table',
              subtitle: 'Current wage rates by province',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MinimumWageCheckerScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _buildListItem(
              icon: Icons.access_time,
              iconColor: const Color(0xFF00401A),
              iconBgColor: const Color(0xFFE6EFEA),
              title: 'Overtime Rules',
              subtitle: 'Overtime pay calculations',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OvertimePayCalculatorScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _buildListItem(
              icon: Icons.calendar_today,
              iconColor: const Color(0xFF00401A),
              iconBgColor: const Color(0xFFE6EFEA),
              title: 'Paid Leave Rules',
              subtitle: 'Annual, sick, and casual leave',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PaidLeaveEligibilityScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _buildListItem(
              icon: Icons.info_outline,
              iconColor: const Color(0xFF00401A),
              iconBgColor: const Color(0xFFE6EFEA),
              title: 'Contract Violation\nExplainer',
              subtitle: 'Identify contract breaches',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const ContractViolationCheckerScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _buildListItem(
              icon: Icons.description_outlined,
              iconColor: const Color(0xFF00401A),
              iconBgColor: const Color(0xFFE6EFEA),
              title: 'Complaint Filing Steps',
              subtitle: 'How to file labour complaint',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FileLabourComplaintScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _buildListItem(
              icon: Icons.edit_document,
              iconColor: const Color(0xFF00401A),
              iconBgColor: const Color(0xFFE6EFEA),
              title: 'Application Draft\nGenerator',
              subtitle: 'Generate labour applications',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DraftLabourApplicationScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _buildListItem(
              icon: Icons.image_outlined,
              iconColor: const Color(0xFF00401A),
              iconBgColor: const Color(0xFFE6EFEA),
              title: 'Screenshot Evidence\nReader',
              subtitle: 'Extract salary slip data',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const ScreenshotEvidenceReaderScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _buildListItem(
              icon: Icons.play_circle_outline,
              iconColor: const Color(0xFF00401A),
              iconBgColor: const Color(0xFFE6EFEA),
              title: 'Scenario Simulator',
              subtitle: 'Learn labour-related scenarios',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScenarioSimulatorScreen(
                      moduleType: ModuleType.labourRights,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
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
          child: Row(
            children: [
              // Icon container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),

              const SizedBox(width: 16),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
