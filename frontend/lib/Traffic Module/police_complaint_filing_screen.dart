import 'package:flutter/material.dart';
import 'police_ai_complaint_generator_screen.dart';

class PoliceComplaintFilingScreen extends StatelessWidget {
  const PoliceComplaintFilingScreen({super.key});

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
          'Complaint Filing Paths',
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
                  Icons.description_outlined,
                  size: 32,
                  color: Color(0xFF00401A),
                ),
              ),

              const SizedBox(height: 16),

              // Title
              const Text(
                'Where to File Your Complaint',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Choose the most convenient option',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 32),

              // Filing options
              _buildFilingOption(
                icon: Icons.phone,
                iconColor: const Color(0xFF00401A),
                iconBgColor: const Color(0xFFE6F7F0),
                title: 'Provincial Helpline',
                subtitle: 'Call 1915 (Punjab, Sindh, KPK)',
                actionText: 'Call Now',
                onTap: () {
                  // TODO: Launch phone dialer
                },
              ),

              const SizedBox(height: 12),

              _buildFilingOption(
                icon: Icons.chat_bubble_outline,
                iconColor: const Color(0xFF00401A),
                iconBgColor: const Color(0xFFE6F7F0),
                title: 'IG Complaint WhatsApp',
                subtitle: 'Send complaint to IG Office',
                actionText: 'Open WhatsApp',
                onTap: () {
                  // TODO: Launch WhatsApp
                },
              ),

              const SizedBox(height: 12),

              _buildFilingOption(
                icon: Icons.public,
                iconColor: const Color(0xFF00401A),
                iconBgColor: const Color(0xFFE6F7F0),
                title: 'SafeCity App',
                subtitle: 'Report through SafeCity platform',
                actionText: 'Visit Website',
                onTap: () {
                  // TODO: Launch URL
                },
              ),

              const SizedBox(height: 12),

              _buildFilingOption(
                icon: Icons.location_on_outlined,
                iconColor: const Color(0xFF6B21A8),
                iconBgColor: const Color(0xFFF3E8FF),
                title: 'Police Khidmat Markaz',
                subtitle: 'Visit nearest service center',
                actionText: 'Find Location',
                onTap: () {
                  // TODO: Open maps
                },
              ),

              const SizedBox(height: 12),

              _buildFilingOption(
                icon: Icons.phone_in_talk,
                iconColor: const Color(0xFFD97706),
                iconBgColor: const Color(0xFFFFF9E6),
                title: '1787 Complaint Helpline',
                subtitle: 'National police complaint line',
                actionText: 'Call Now',
                onTap: () {
                  // TODO: Launch phone dialer
                },
              ),

              const SizedBox(height: 12),

              _buildFilingOption(
                icon: Icons.mail_outline,
                iconColor: const Color(0xFF00401A),
                iconBgColor: const Color(0xFFE6EFEA),
                title: 'Written Complaint',
                subtitle: 'Submit to SP Traffic office',
                actionText: 'Get Address',
                onTap: () {
                  // TODO: Show addresses
                },
              ),

              const SizedBox(height: 24),

              // Contact Information
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F7F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Contact Information',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildContactInfo(
                      'Punjab: 1915 or complaint.punjabpolice.gov.pk',
                    ),
                    _buildContactInfo('Sindh: 1915 or sindhpolice.gov.pk'),
                    _buildContactInfo('KPK: 1915 or kppolice.gov.pk'),
                    _buildContactInfo(
                      'Islamabad: 1715 or islamabadpolice.gov.pk',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // AI Generator button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const PoliceAIComplaintGeneratorScreen(),
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
                      Icon(Icons.description, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Generate AI Complaint Letter',
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

              // Tip
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9E6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'File complaint within 7 days for best results',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilingOption({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
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
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      actionText,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF00401A),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward,
                      color: Color(0xFF00401A),
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactInfo(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        '• $text',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade700,
          height: 1.4,
        ),
      ),
    );
  }
}
