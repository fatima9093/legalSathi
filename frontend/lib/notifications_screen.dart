import 'package:flutter/material.dart';
import 'package:front_end/l10n/app_localizations.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

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
        title: Text(
          AppLocalizations.of(context)!.notifications,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotificationCard(
            icon: Icons.check_circle,
            iconColor: const Color(0xFF4CAF50),
            iconBackgroundColor: const Color(0xFFE8F5E9),
            title: AppLocalizations.of(context)!.documentReady,
            description: AppLocalizations.of(context)!.firDraftGeneratedSuccessfully,
            time: AppLocalizations.of(context)!.minAgo,
          ),
          const SizedBox(height: 12),
          _buildNotificationCard(
            icon: Icons.description,
            iconColor: const Color(0xFF4CAF50),
            iconBackgroundColor: const Color(0xFFE8F5E9),
            title: AppLocalizations.of(context)!.evidenceProcessed,
            description: AppLocalizations.of(context)!.evidenceHasBeenAnalyzed,
            time: AppLocalizations.of(context)!.hourAgo,
          ),
          const SizedBox(height: 12),
          _buildNotificationCard(
            icon: Icons.menu_book,
            iconColor: const Color(0xFFFFA726),
            iconBackgroundColor: const Color(0xFFFFF3E0),
            title: AppLocalizations.of(context)!.newLawUpdate,
            description: AppLocalizations.of(context)!.pecaAmendmentsAdded,
            time: AppLocalizations.of(context)!.hoursAgo,
          ),
          const SizedBox(height: 12),
          _buildNotificationCard(
            icon: Icons.access_time,
            iconColor: const Color(0xFF4CAF50),
            iconBackgroundColor: const Color(0xFFE8F5E9),
            title: AppLocalizations.of(context)!.welcomeToLegalSathi,
            description: AppLocalizations.of(context)!.startByExploringLegalCategories,
            time: AppLocalizations.of(context)!.dayAgo,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBackgroundColor,
    required String title,
    required String description,
    required String time,
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
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.4,
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
