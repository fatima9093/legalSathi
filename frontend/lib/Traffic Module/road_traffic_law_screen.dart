import 'package:flutter/material.dart';
import '../screen_with_nav.dart';
import 'package:front_end/Traffic%20Module/fine_calculator_screen.dart';
import 'Traffic_Offence_Types_Screen.dart';
import 'traffic_challan_ocr_screen.dart';
import 'required_documents_screen.dart';
import 'police_misbehavior_guide_screen.dart';
import 'package:front_end/scenario_simulator_screen.dart';
import 'package:front_end/models/scenario_model.dart';

class RoadTrafficLawScreen extends StatefulWidget {
  const RoadTrafficLawScreen({super.key});

  @override
  State<RoadTrafficLawScreen> createState() => _RoadTrafficLawScreenState();
}

class _RoadTrafficLawScreenState extends State<RoadTrafficLawScreen> {
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
          'Road & Traffic Law',
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
            // Header with Urdu text
            Container(
              width: double.infinity,
              color: Color(0xFFF5F5F5),
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: const Text(
                'ٹریفک\nقوانین',
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
              icon: Icons.camera_alt_outlined,
              iconColor: const Color(0xFF00401A),
              iconBgColor: const Color(0xFFE6EFEA),
              title: 'Traffic Challan OCR Reader',
              subtitle: 'Scan and identify violations',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TrafficChallanOCRScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _buildListItem(
              icon: Icons.info_outline,
              iconColor: const Color(0xFF00401A),
              iconBgColor: const Color(0xFFE6EFEA),
              title: 'Offence Types Guide',
              subtitle: 'Recognize traffic violations',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TrafficOffenceTypesScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _buildListItem(
              icon: Icons.calculate_outlined,
              iconColor: const Color(0xFF00401A),
              iconBgColor: const Color(0xFFE6EFEA),
              title: 'Fine Calculator',
              subtitle: 'Calculate penalty amounts',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FineCalculatorScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _buildListItem(
              icon: Icons.description_outlined,
              iconColor: const Color(0xFF00401A),
              iconBgColor: const Color(0xFFE6EFEA),
              title: 'Required Documents',
              subtitle: 'What to carry while driving',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RequiredDocumentsScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _buildListItem(
              icon: Icons.shield_outlined,
              iconColor: const Color(0xFF00401A),
              iconBgColor: const Color(0xFFE6EFEA),
              title: 'Police Misbehavior Guide',
              subtitle: 'Steps if officer misbehaves',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PoliceMisbehaviorGuideScreen(),
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
              subtitle: 'Learn traffic-related scenarios',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScenarioSimulatorScreen(
                      moduleType: ModuleType.traffic,
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
