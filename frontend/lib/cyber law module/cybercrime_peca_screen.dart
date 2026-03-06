import 'package:flutter/material.dart';
import '../screen_with_nav.dart';
import 'package:front_end/cyber%20law%20module/blackmail_handling_screen.dart';
import 'package:front_end/cyber%20law%20module/onlineHarrasment_screen.dart';
import 'package:front_end/cyber%20law%20module/fia_complaint_generator.dart';
import 'package:front_end/cyber%20law%20module/report_fake_account_screen.dart';
import 'package:front_end/cyber%20law%20module/evidence_extractor_screen.dart';
import 'package:front_end/scenario_simulator_screen.dart';
import 'package:front_end/models/scenario_model.dart';

class CyberCrimePECAScreen extends StatefulWidget {
  const CyberCrimePECAScreen({super.key});

  @override
  State<CyberCrimePECAScreen> createState() => _CyberCrimePECAScreenState();
}

class _CyberCrimePECAScreenState extends State<CyberCrimePECAScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          'Cyber Crime (PECA)',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavBar(context, 3),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with Urdu text
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: const Text(
                'سائبر کرائم',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 20),

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
              icon: Icons.shield_outlined,
              iconColor: const Color(0xFF00401A),
              iconBgColor: const Color(0xFFE6EFEA),
              title: 'Online Harassment Explainer',
              subtitle: 'PECA Section 24 overview',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OnlineHarassmentPECA24Screen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _buildListItem(
              icon: Icons.info_outline,
              iconColor: const Color(0xFF00401A),
              iconBgColor: const Color(0xFFE6EFEA),
              title: 'Blackmail Handling Flow',
              subtitle: 'Steps to handle blackmail',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BlackmailHandlingScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _buildListItem(
              icon: Icons.description_outlined,
              iconColor: const Color(0xFF00401A),
              iconBgColor: const Color(0xFFE6EFEA),
              title: 'Fake Account Reporting',
              subtitle: 'Report fake social profiles',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReportFakeAccountScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _buildListItem(
              icon: Icons.folder_outlined,
              iconColor: const Color(0xFF00401A),
              iconBgColor: const Color(0xFFE6EFEA),
              title: 'Threat Message Evidence',
              subtitle: 'Preserve digital evidence',
              onTap: () {
                // TODO: Navigate to Threat Message Evidence
              },
            ),

            const SizedBox(height: 12),

            _buildListItem(
              icon: Icons.description_outlined,
              iconColor: const Color(0xFF00401A),
              iconBgColor: const Color(0xFFE6EFEA),
              title: 'FIA Complaint Generator',
              subtitle: 'Draft FIA cyber complaint',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FIAComplaintGeneratorScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _buildListItem(
              icon: Icons.image_outlined,
              iconColor: const Color(0xFF00401A),
              iconBgColor: const Color(0xFFE6EFEA),
              title: 'Screenshot Reader',
              subtitle: 'Extract timestamps & numbers',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EvidenceExtractorScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _buildListItem(
              icon: Icons.info_outline,
              iconColor: const Color(0xFF00401A),
              iconBgColor: const Color(0xFFE6EFEA),
              title: 'Scenario Simulator',
              subtitle: 'Learn cyber crime scenarios',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScenarioSimulatorScreen(
                      moduleType: ModuleType.cyberCrime,
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
