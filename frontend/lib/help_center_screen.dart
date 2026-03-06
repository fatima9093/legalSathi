import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

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
          'Help Center',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),

            // Question Mark Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
              child: const Icon(
                Icons.question_mark,
                size: 32,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 16),

            // How Can We Help?
            const Text(
              'How Can We Help?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Find answers and get support',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),

            const SizedBox(height: 24),

            // Help Topics Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Help Topics',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildHelpTopicCard(
                    icon: Icons.menu_book,
                    iconColor: const Color(0xFF00401A),
                    title: 'How to Use Legal Sathi',
                    subtitle: 'Learn the basics of navigating the app',
                    onTap: () {},
                  ),

                  const SizedBox(height: 12),

                  _buildHelpTopicCard(
                    icon: Icons.camera_alt_outlined,
                    iconColor: const Color(0xFF00401A),
                    title: 'How to Upload Evidence',
                    subtitle: 'Step-by-step guide for uploading documents',
                    onTap: () {},
                  ),

                  const SizedBox(height: 12),

                  _buildHelpTopicCard(
                    icon: Icons.description_outlined,
                    iconColor: const Color(0xFF00401A),
                    title: 'How OCR Works',
                    subtitle: 'Understanding document scanning and analysis',
                    onTap: () {},
                  ),

                  const SizedBox(height: 12),

                  _buildHelpTopicCard(
                    icon: Icons.description_outlined,
                    iconColor: const Color(0xFF00401A),
                    title: 'How to Draft Documents',
                    subtitle: 'Creating FIRs, complaints, and legal documents',
                    onTap: () {},
                  ),

                  const SizedBox(height: 12),

                  _buildHelpTopicCard(
                    icon: Icons.info_outline,
                    iconColor: const Color(0xFF00401A),
                    title: 'How to Report an Issue',
                    subtitle: 'Get help with technical problems',
                    onTap: () {},
                  ),

                  const SizedBox(height: 24),

                  // FAQ Section
                  const Text(
                    'Frequently Asked Questions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 12),

                  _buildFAQCard(
                    question: 'Is Legal Sathi free to use?',
                    answer:
                        'Yes, Legal Sathi is currently free for all users. We provide legal information and document drafting assistance at no cost.',
                  ),

                  const SizedBox(height: 12),

                  _buildFAQCard(
                    question: 'Can I use this instead of a lawyer?',
                    answer:
                        'No. Legal Sathi provides general legal information and document templates. For legal representation and advice, consult a qualified lawyer.',
                  ),

                  const SizedBox(height: 12),

                  _buildFAQCard(
                    question: 'How accurate is the AI assistant?',
                    answer:
                        'Our AI is trained on Pakistani laws but may not cover all cases. Always verify information with legal professionals before taking action.',
                  ),

                  const SizedBox(height: 12),

                  _buildFAQCard(
                    question: 'Is my data secure?',
                    answer:
                        'Yes. We use encryption for data storage and transmission. Your information is kept confidential and never shared with third parties.',
                  ),

                  const SizedBox(height: 12),

                  _buildFAQCard(
                    question: 'What languages are supported?',
                    answer:
                        'Legal Sathi supports English, Roman Urdu, and Urdu. You can switch languages in Settings.',
                  ),

                  const SizedBox(height: 32),

                  // Still Need Help Section
                  Center(
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.black87,
                        size: 24,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Center(
                    child: Text(
                      'Still Need Help?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Center(
                    child: Text(
                      'Contact our support team for assistance',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Contact Support Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement contact support
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00401A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Contact Support',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpTopicCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        onTap: onTap,
      ),
    );
  }

  Widget _buildFAQCard({required String question, required String answer}) {
    return Container(
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
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16,
          ),
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          trailing: const Icon(Icons.expand_more, color: Colors.grey, size: 20),
          children: [
            Text(
              answer,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
