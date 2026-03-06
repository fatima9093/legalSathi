import 'package:flutter/material.dart';
import 'police_complaint_filing_screen.dart';

class PoliceImmediateStepsScreen extends StatelessWidget {
  const PoliceImmediateStepsScreen({super.key});

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
          'Immediate Steps',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // Header icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6EFEA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.access_time,
                  size: 32,
                  color: Color(0xFF00401A),
                ),
              ),

              const SizedBox(height: 16),

              // Title
              const Text(
                'What to Do Right Now',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Follow these steps during the incident',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 32),

              // Steps
              _buildStepCard(
                stepNumber: 1,
                icon: Icons.self_improvement_outlined,
                iconColor: const Color(0xFF00401A),
                title: 'Stay Calm',
                description:
                    'Remain polite and cooperative. Do not argue, shout, or resist physically.',
                tips: [
                  'Keep your composure',
                  'Speak respectfully',
                  'Avoid confrontation',
                ],
              ),

              const SizedBox(height: 16),

              _buildStepCard(
                stepNumber: 2,
                icon: Icons.access_time,
                iconColor: const Color(0xFF00401A),
                title: 'Record Time and Place',
                description:
                    'Note exact time, date, and location of the incident immediately.',
                tips: [
                  'Check your watch/phone',
                  'Note nearby landmarks',
                  'Remember street names',
                ],
              ),

              const SizedBox(height: 16),

              _buildStepCard(
                stepNumber: 3,
                icon: Icons.badge_outlined,
                iconColor: const Color(0xFF00401A),
                title: 'Ask for Officer Details',
                description:
                    'Politely request officer name, badge number, and station.',
                tips: [
                  'Say: "May I have your name and badge number?"',
                  'Note vehicle number if applicable',
                  'Be polite but firm',
                ],
              ),

              const SizedBox(height: 16),

              _buildStepCard(
                stepNumber: 4,
                icon: Icons.description_outlined,
                iconColor: const Color(0xFF00401A),
                title: 'Save Challan Number',
                description:
                    'If challan is issued, keep it safe and note all details.',
                tips: [
                  'Take photo of challan',
                  'Note challan number',
                  'Keep original safe',
                ],
              ),

              const SizedBox(height: 16),

              _buildStepCard(
                stepNumber: 5,
                icon: Icons.videocam_outlined,
                iconColor: const Color(0xFF00401A),
                title: 'Safe Recording Methods',
                description: 'Legal ways to document the interaction.',
                tips: [
                  'Video recording in public is legal',
                  'Keep phone visible, not hidden',
                  'Inform officer you are recording',
                  'Do NOT record audio without consent',
                ],
              ),

              const SizedBox(height: 16),

              _buildStepCard(
                stepNumber: 6,
                icon: Icons.camera_alt_outlined,
                iconColor: const Color(0xFF00401A),
                title: 'Gather Evidence',
                description: 'Collect any available evidence of misbehavior.',
                tips: [
                  'Take photos if safe',
                  'Get witness contact info',
                  'Note any CCTV cameras nearby',
                ],
              ),

              const SizedBox(height: 32),

              // Next step button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const PoliceComplaintFilingScreen(),
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
                    children: const [
                      Text(
                        'Next: Where to File Complaint',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Warning
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE6E6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning,
                      color: Color(0xFFDC2626),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'If you feel physically threatened, prioritize your safety and leave the situation',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required int stepNumber,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required List<String> tips,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF00401A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00401A),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          stepNumber.toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Tips:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                ...tips.map(
                  (tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• $tip',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
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
