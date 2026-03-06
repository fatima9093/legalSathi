import 'package:flutter/material.dart';
import '../screen_with_nav.dart';
import 'package:front_end/Women%20harrasment%20Module/ombudspersonComplaintsSteps_screen.dart';
import 'ProtectionAgainstHarassmentActScreen.dart';
import 'workplace_committee_procedure_screen.dart';
import 'evidence_checklist_screen.dart';
import 'draft_complaint_generator_screen.dart';
import 'package:front_end/scenario_simulator_screen.dart';
import 'package:front_end/models/scenario_model.dart';

class WomenHarassmentLawsScreen extends StatefulWidget {
  const WomenHarassmentLawsScreen({super.key});

  @override
  State<WomenHarassmentLawsScreen> createState() =>
      _WomenHarassmentLawsScreenState();
}

class _WomenHarassmentLawsScreenState extends State<WomenHarassmentLawsScreen> {
  final _searchController = TextEditingController();

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
          'Women Harassment Laws',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header section with Urdu text
            Container(
              width: double.infinity,
              color: Color(0xFFF5F5F5),
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: const Text(
                'خواتین کی ہراسانی کے\nقوانین',
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
                    borderSide: BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
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
              icon: Icons.shield_outlined,
              iconColor: Color(0xFF00401A),
              iconBgColor: const Color(0xFFE6EFEA),
              title: 'Protection Against\nHarassment Act',
              subtitle: 'Complete law overview and',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const ProtectionAgainstHarassmentActScreen(),
                  ),
                );
                // TODO: Navigate to Protection Against Harassment details
              },
            ),

            const SizedBox(height: 12),

            _buildListItem(
              icon: Icons.format_list_bulleted,
              iconColor: Color(0xFF00401A),
              iconBgColor: const Color(0xFFE6EFEA),
              title: 'Ombudsperson Complain\nSteps',
              subtitle: 'How to file with Ombudsperson',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const OmbudspersonComplaintsStepsScreen(),
                  ),
                );
                // TODO: Navigate to Ombudsperson steps
              },
            ),

            const SizedBox(height: 12),

            _buildListItem(
              icon: Icons.description_outlined,
              iconColor: Color(0xFF00401A),
              iconBgColor: const Color(0xFFE6EFEA),
              title: 'Workplace Committee\nProcedure',
              subtitle: 'Internal complaint process',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const WorkplaceCommitteeProcedureScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _buildListItem(
              icon: Icons.photo_camera_outlined,
              iconColor: Color(0xFF00401A),
              iconBgColor: const Color(0xFFE6EFEA),
              title: 'Evidence Checklist',
              subtitle: 'What evidence to collect',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EvidenceChecklistScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _buildListItem(
              icon: Icons.description_outlined,
              iconColor: Color(0xFF00401A),
              iconBgColor: const Color(0xFFE6EFEA),
              title: 'Draft Complaint Generator',
              subtitle: 'Step-by-step complaint form',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DraftComplaintGeneratorScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _buildListItem(
              icon: Icons.play_circle_outline,
              iconColor: Color(0xFF00401A),
              iconBgColor: const Color(0xFFE6EFEA),
              title: 'Scenario Simulator',
              subtitle: 'Learn harassment-related scenarios',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScenarioSimulatorScreen(
                      moduleType: ModuleType.womenHarassment,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNavBar(context, 2),
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
