import 'package:flutter/material.dart';
import 'rights_and_escalation_screen.dart';
import 'workplace_committee_check_screen.dart';

class WorkplaceCommitteeProcedureScreen extends StatelessWidget {
  const WorkplaceCommitteeProcedureScreen({super.key});

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
          'Workplace Committee Procedure',
          style: TextStyle(
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD9EBD9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Every organization with 3+ employees must have an inquiry committee',
                  style: TextStyle(fontSize: 14, color: Color(0xFF1B5E20)),
                ),
              ),

              const SizedBox(height: 20),

              // Committee Composition Section
              _buildSectionCard(
                title: 'Committee Composition',
                items: [
                  '3 members minimum',
                  'At least 1 woman member',
                  'Senior management representative',
                ],
              ),

              const SizedBox(height: 16),

              // Filing Process Section
              _buildSectionCard(
                title: 'Filing Process',
                items: [
                  'Submit written complaint to committee',
                  'Within 3 days of incident',
                  'Include all evidence and witnesses',
                ],
              ),

              const SizedBox(height: 16),

              // Inquiry Timeline Section
              _buildSectionCard(
                title: 'Inquiry Timeline',
                items: [
                  'Committee must complete inquiry in 30 days',
                  'Both parties given fair hearing',
                  'Confidentiality maintained',
                ],
              ),

              const SizedBox(height: 16),

              // Possible Outcomes Section
              _buildSectionCard(
                title: 'Possible Outcomes',
                items: [
                  'Warning to accused',
                  'Transfer or suspension',
                  'Termination for serious cases',
                  'Compensation to complainant',
                ],
              ),

              const SizedBox(height: 20),

              // Warning Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFFE65100),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF5D4037),
                          ),
                          children: [
                            TextSpan(
                              text:
                                  'If committee doesn\'t exist or fails to act, file directly with ',
                            ),
                            TextSpan(
                              text: 'Ombudsperson',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Start Internal Complaint Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const WorkplaceCommitteeCheckScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00401A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.description, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Start Internal Complaint',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // View Rights & Escalation Button
              SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RightsAndEscalationScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF00401A), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'View Rights & Escalation',
                    style: TextStyle(
                      color: Color(0xFF00401A),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
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
}
