import 'package:flutter/material.dart';
import 'package:front_end/l10n/app_localizations.dart';

import 'police_ai_complaint_generator_screen.dart';
import 'traffic_contact_launcher.dart';
import 'traffic_police_contacts.dart';

class PoliceComplaintFilingScreen extends StatelessWidget {
  const PoliceComplaintFilingScreen({super.key});

  @override
  Widget build(BuildContext context) {
     final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
           loc.complaintFilingPaths,
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
               Text(
                loc.whereToFileComplaint,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                loc.chooseOption,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),
              _buildFilingOption(
                icon: Icons.phone,
                iconColor: const Color(0xFF00401A),
                iconBgColor: const Color(0xFFE6F7F0),
                 title: loc.helpline,
                  subtitle: loc.helplineDesc,
                  actionText: loc.callNow,
                onTap: () => TrafficContactLauncher.dial(
                  context,
                  TrafficPoliceContacts.helpline1915,
                ),
              ),
              const SizedBox(height: 12),
              _buildFilingOption(
                icon: Icons.chat_bubble_outline,
                iconColor: const Color(0xFF00401A),
                iconBgColor: const Color(0xFFE6F7F0),
                title: loc.whatsapp,
                subtitle: loc.whatsappDesc,
                actionText: loc.openWhatsapp,
                onTap: () => TrafficContactLauncher.whatsAppComplaint(context),
              ),
              const SizedBox(height: 12),
              _buildFilingOption(
                icon: Icons.public,
                iconColor: const Color(0xFF00401A),
                iconBgColor: const Color(0xFFE6F7F0),
                title: loc.safeCity,
              subtitle: loc.safeCityDesc,
              actionText: loc.visitWebsite,
                onTap: () => TrafficContactLauncher.openHttpUrl(
                  context,
                  TrafficPoliceContacts.safeCityWebsite,
                ),
              ),
              const SizedBox(height: 12),
              _buildFilingOption(
                icon: Icons.location_on_outlined,
                iconColor: const Color(0xFF6B21A8),
                iconBgColor: const Color(0xFFF3E8FF),
                title: loc.khidmatMarkaz,
              subtitle: loc.khidmatMarkazDesc,
              actionText: loc.findLocation,
                onTap: () => TrafficContactLauncher.openMapsSearch(
                  context,
                  TrafficPoliceContacts.mapsKhidmatMarkazQuery,
                ),
              ),
              const SizedBox(height: 12),
              _buildFilingOption(
                icon: Icons.phone_in_talk,
                iconColor: const Color(0xFFD97706),
                iconBgColor: const Color(0xFFFFF9E6),
                title: loc.helpline1787,
              subtitle: loc.helpline1787Desc,
              actionText: loc.callNow,
                onTap: () => TrafficContactLauncher.dial(
                  context,
                  TrafficPoliceContacts.helpline1787,
                ),
              ),
              const SizedBox(height: 12),
              _buildFilingOption(
                icon: Icons.mail_outline,
                iconColor: const Color(0xFF00401A),
                iconBgColor: const Color(0xFFE6EFEA),
                title: loc.writtenComplaint,
                subtitle: loc.writtenComplaintDesc,
                actionText: loc.getAddress,
                onTap: () =>
                    TrafficContactLauncher.showWrittenComplaintAddressesSheet(
                  context,
                ),
              ),
              const SizedBox(height: 24),
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
                     Text(
                      loc.contactInformation,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                     _buildContactInfo(loc.punjabContact),
                  _buildContactInfo(loc.sindhContact),
                  _buildContactInfo(loc.kpkContact),
                  _buildContactInfo(loc.islamabadContact),
                ],
                ),
              ),
              const SizedBox(height: 24),
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
                    children: [
                      const Icon(Icons.description, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        loc.generateAIComplaint,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9E6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:  Text(loc.fileWithinDays,
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
