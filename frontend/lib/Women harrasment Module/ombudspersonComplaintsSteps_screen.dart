import 'package:flutter/material.dart';
import '../screen_with_nav.dart';
import 'package:front_end/Women%20harrasment%20Module/JurisdictionScreen.dart';

class OmbudspersonComplaintsStepsScreen extends StatelessWidget {
  const OmbudspersonComplaintsStepsScreen({super.key});

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
          'Ombudsperson Complaint Steps',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Header text
          Container(
            width: double.infinity,
            color: Color(0xFFF5F5F5),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Text(
              'Follow these steps to file with Federal\nOmbudsperson',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // Step 1
                    _buildStepCard(
                      stepNumber: '1',
                      title: 'File Written Complaint',
                      description:
                          'Submit complaint within 3 months of incident to Federal Ombudsperson office',
                    ),

                    const SizedBox(height: 12),

                    // Step 2
                    _buildStepCard(
                      stepNumber: '2',
                      title: 'Provide Evidence',
                      description:
                          'Attach all evidence: emails, messages, witness statements, CCTV footage',
                    ),

                    const SizedBox(height: 12),

                    // Step 3
                    _buildStepCard(
                      stepNumber: '3',
                      title: 'Inquiry Process',
                      description:
                          'Ombudsperson conducts inquiry, both parties are heard',
                    ),

                    const SizedBox(height: 12),

                    // Step 4
                    _buildStepCard(
                      stepNumber: '4',
                      title: 'Decision Within 90 Days',
                      description:
                          'Final decision must be issued within 90 days of filing',
                    ),

                    const SizedBox(height: 12),

                    // Step 5
                    _buildStepCard(
                      stepNumber: '5',
                      title: 'Implementation',
                      description:
                          'Organization must implement decision within 30 days',
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),

          // Bottom button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SelectJurisdictionScreen(),
                  ),
                );
                // TODO: Navigate to complaint form or generator
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00401A),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 0),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.description_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Start Ombudsperson Complaint',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: buildBottomNavBar(context, 2),
    );
  }

  Widget _buildStepCard({
    required String stepNumber,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step number circle
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF00401A),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                stepNumber,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
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
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.5,
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
