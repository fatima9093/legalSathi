import 'package:flutter/material.dart';

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
        title: const Text(
          'Notifications',
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
            title: 'Document Ready',
            description: 'Your FIR draft has been generated successfully.',
            time: '2 min ago',
          ),
          const SizedBox(height: 12),
          _buildNotificationCard(
            icon: Icons.description,
            iconColor: const Color(0xFF4CAF50),
            iconBackgroundColor: const Color(0xFFE8F5E9),
            title: 'Evidence Processed',
            description: 'Your uploaded evidence has been analyzed.',
            time: '1 hour ago',
          ),
          const SizedBox(height: 12),
          _buildNotificationCard(
            icon: Icons.menu_book,
            iconColor: const Color(0xFFFFA726),
            iconBackgroundColor: const Color(0xFFFFF3E0),
            title: 'New Law Update',
            description: 'PECA 2016 amendments have been added.',
            time: '2 hours ago',
          ),
          const SizedBox(height: 12),
          _buildNotificationCard(
            icon: Icons.access_time,
            iconColor: const Color(0xFF4CAF50),
            iconBackgroundColor: const Color(0xFFE8F5E9),
            title: 'Welcome to Legal Sathi',
            description: 'Start by exploring our legal categories.',
            time: '1 day ago',
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
