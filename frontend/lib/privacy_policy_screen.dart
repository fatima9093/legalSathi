import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          'Privacy Policy',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Your Privacy Matters Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: Color(0xFF00401A),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Privacy Matters',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'How we protect your information',
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Data Usage Section
            _buildSection(
              title: 'Data Usage',
              content:
                  'Legal Sathi collects minimal personal information necessary to provide legal assistance. Your data is used solely for generating legal documents, analyzing evidence, and providing AI-powered legal guidance. We do not sell or share your personal information with third parties.',
            ),

            const SizedBox(height: 16),

            // Evidence Handling Section
            _buildSection(
              title: 'Evidence Handling',
              content:
                  'All uploaded evidence (photos, documents, screenshots) is processed securely and stored with encryption. Evidence files are automatically deleted after 90 days unless saved to your account. We recommend keeping original copies of all evidence separately.',
            ),

            const SizedBox(height: 16),

            // User Identity Protection Section
            _buildSection(
              title: 'User Identity Protection',
              content:
                  'Your identity and case details are kept confidential. We use industry-standard encryption for data transmission and storage. Account information is protected with secure authentication. You can request deletion of your data at any time.',
            ),

            const SizedBox(height: 16),

            // AI Response Limitations Section
            _buildSection(
              title: 'AI Response Limitations',
              content:
                  'Legal Sathi provides general legal information and document drafting assistance. AI responses are not legal advice and should not replace consultation with a qualified lawyer. Always verify information with legal professionals before taking action.',
            ),

            const SizedBox(height: 16),

            // Contact for Complaints Section
            _buildSection(
              title: 'Contact for Complaints',
              content:
                  'For privacy concerns or data-related complaints, contact us at privacy@legalsathi.pk. We respond to all inquiries within 7 business days. You have the right to access, correct, or delete your personal information.',
            ),

            const SizedBox(height: 24),

            // Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Last updated: January 2026 • Version 1.0',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
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
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
