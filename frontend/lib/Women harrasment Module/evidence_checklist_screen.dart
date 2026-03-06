import 'package:flutter/material.dart';
import 'ai_evidence_review_screen.dart';

class EvidenceChecklistScreen extends StatefulWidget {
  const EvidenceChecklistScreen({super.key});

  @override
  State<EvidenceChecklistScreen> createState() =>
      _EvidenceChecklistScreenState();
}

class _EvidenceChecklistScreenState extends State<EvidenceChecklistScreen> {
  // Primary evidence checkboxes
  Map<String, bool> primaryEvidence = {
    'WhatsApp / SMS messages': false,
    'Emails': false,
    'Voice notes': false,
    'CCTV footage': false,
    'Call recordings': false,
    'Screenshots': false,
    'Photos': false,
    'Digital communication': false,
  };

  // Secondary evidence checkboxes
  Map<String, bool> secondaryEvidence = {
    'Witness statements': false,
    'Diary / incident notes': false,
    'Medical report': false,
    'HR warning emails': false,
    'Pattern of behavior': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Evidence Checklist',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            // Header icon and title
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.check_box_outlined,
                      size: 40,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Evidence Collection Guide',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Strong evidence strengthens your case',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Primary Evidence Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                'Primary Evidence',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Primary Evidence Items
            ...primaryEvidence.keys.map(
              (item) => _buildChecklistItem(
                label: item,
                isChecked: primaryEvidence[item]!,
                onChanged: (value) {
                  setState(() {
                    primaryEvidence[item] = value!;
                  });
                },
              ),
            ),

            const SizedBox(height: 32),

            // Secondary Evidence Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                'Secondary Evidence',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Secondary Evidence Items
            ...secondaryEvidence.keys.map(
              (item) => _buildChecklistItem(
                label: item,
                isChecked: secondaryEvidence[item]!,
                onChanged: (value) {
                  setState(() {
                    secondaryEvidence[item] = value!;
                  });
                },
              ),
            ),

            const SizedBox(height: 32),

            // Evidence Collection Guidance
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                'Evidence Collection Guidance',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // How to Collect Evidence Legally
            _buildGuidanceSection(
              icon: Icons.check_circle,
              iconColor: Colors.green,
              title: 'How to Collect Evidence Legally',
              items: [
                'Take screenshots with visible timestamps',
                'Keep original files, submit copies',
                'Document dates, times, and locations',
                'Get witness statements in writing',
                'Request CCTV through proper channels',
              ],
            ),

            const SizedBox(height: 16),

            // What NOT to Do
            _buildGuidanceSection(
              icon: Icons.cancel,
              iconColor: Colors.red,
              title: 'What NOT to Do',
              items: [
                'Don\'t record calls without consent (illegal in Pakistan)',
                'Don\'t alter or edit evidence',
                'Don\'t delete original messages',
                'Don\'t trespass to obtain evidence',
                'Don\'t share evidence publicly before filing',
              ],
            ),

            const SizedBox(height: 16),

            // Tips for Preserving Digital Files
            _buildGuidanceSection(
              icon: Icons.lightbulb,
              iconColor: Colors.amber.shade700,
              title: 'Tips for Preserving Digital Files',
              items: [
                'Back up to cloud storage immediately',
                'Keep multiple copies in different locations',
                'Don\'t compress or reduce image quality',
                'Note metadata (date, time, sender)',
                'Store chronologically with labels',
              ],
            ),

            const SizedBox(height: 24),

            // Upload Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AIEvidenceReviewScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00401A),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.upload_file, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Upload Evidence for AI Review',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Bottom message
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F7F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: const Color(0xFF00401A),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'AI will analyze your evidence strength and provide suggestions',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistItem({
    required String label,
    required bool isChecked,
    required ValueChanged<bool?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: CheckboxListTile(
          value: isChecked,
          onChanged: onChanged,
          title: Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          secondary: IconButton(
            icon: Icon(
              Icons.info_outline,
              color: Colors.grey.shade400,
              size: 20,
            ),
            onPressed: () {
              _showInfoDialog(label);
            },
          ),
          activeColor: const Color(0xFF00401A),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        ),
      ),
    );
  }

  Widget _buildGuidanceSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<String> items,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(String evidenceType) {
    String description = _getEvidenceDescription(evidenceType);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(evidenceType),
        content: Text(description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Got it',
              style: TextStyle(color: Color(0xFF00401A)),
            ),
          ),
        ],
      ),
    );
  }

  String _getEvidenceDescription(String evidenceType) {
    Map<String, String> descriptions = {
      'WhatsApp / SMS messages':
          'Screenshots of harassing messages with timestamps and sender information visible.',
      'Emails':
          'Email correspondence showing harassment, including headers with dates and times.',
      'Voice notes':
          'Audio recordings of threatening or harassing voice messages (where legal).',
      'CCTV footage':
          'Video evidence from security cameras showing incidents of harassment.',
      'Call recordings':
          'Recorded phone conversations (only legal with consent in Pakistan).',
      'Screenshots':
          'Screen captures of harassing content from social media or other platforms.',
      'Photos': 'Photographic evidence of physical harassment or threats.',
      'Digital communication':
          'Any other form of digital communication showing harassment.',
      'Witness statements':
          'Written statements from people who witnessed the harassment.',
      'Diary / incident notes':
          'Personal records documenting dates, times, and details of incidents.',
      'Medical report':
          'Medical documentation of physical or psychological harm caused by harassment.',
      'HR warning emails':
          'Official warnings or complaints filed with HR department.',
      'Pattern of behavior':
          'Documentation showing repeated instances of harassment over time.',
    };

    return descriptions[evidenceType] ?? 'Important evidence for your case.';
  }
}
