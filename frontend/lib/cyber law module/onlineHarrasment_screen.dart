import 'package:flutter/material.dart';
import 'package:front_end/l10n/app_localizations.dart';
import '../screen_with_nav.dart';

class OnlineHarassmentPECA24Screen extends StatelessWidget {
  const OnlineHarassmentPECA24Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title:  Text(
           loc.onlineHarassmentTitle,
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
            children: [
              // PECA Section 24 Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F3ED),
                  borderRadius: BorderRadius.circular(16),
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                             loc.pecaSection24,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                             loc.cyberStalking,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // What is Online Harassment?
              _buildInfoCard(
                title: loc.whatIsHarassment,
                description:
                    loc.harassmentDesc,
              ),

              const SizedBox(height: 12),

              // Penalties
              _buildInfoCard(
                title:  loc.penalties,
                description:
                    loc.penaltiesDesc,
              ),

              const SizedBox(height: 12),

              // What to Do
              _buildInfoCard(
                title: loc.whatToDo,
                description:
                    loc.whatToDoDesc,
              
              ),

              const SizedBox(height: 12),

              // How to Report
              _buildInfoCard(
              title: loc.howToReport(loc.platformLabel),
                description:
                    loc.howToReportDesc,
              ),

              const SizedBox(height: 16),

              // Footer info box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F3ED),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:  Text(
                   loc.fiaHelpline,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF00401A),
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavBar(context, 3),
    );
  }

  Widget _buildInfoCard({
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
          // Check circle icon
          Container(
            margin: const EdgeInsets.only(top: 2),
            child: const Icon(
              Icons.check_circle_outline,
              color: Color(0xFF00401A),
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

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