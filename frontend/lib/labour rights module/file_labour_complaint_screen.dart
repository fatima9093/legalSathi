import 'package:flutter/material.dart';
import 'file_denied_leave_complaint_screen.dart';
import 'file_general_complaint_screen.dart';
import '../screen_with_nav.dart';
import 'package:front_end/l10n/app_localizations.dart';

/// Single hub for labour complaints (used from Labour Rights, Paid Leave, Contract Violation, etc.).
class FileLabourComplaintScreen extends StatelessWidget {
  const FileLabourComplaintScreen({super.key});

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
          AppLocalizations.of(context)!.fileLabourComplaintTitle,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavBar(context, 2),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.selectComplaintIssue,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 20),
          _ComplaintOptionTile(
            icon: Icons.event_busy,
            iconColor: const Color(0xFF00401A),
            title: AppLocalizations.of(context)!.fileDeniedLeaveComplaintTitle,
            subtitle: AppLocalizations.of(context)!.fileDeniedLeaveComplaintSubtitle,
            onTap: () {
              Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (context) => const FileDeniedLeaveComplaintScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _ComplaintOptionTile(
            icon: Icons.info_outline,
            iconColor: const Color(0xFF00401A),
            title: AppLocalizations.of(context)!.fileGeneralComplaintTitle,
            subtitle: AppLocalizations.of(context)!.fileGeneralComplaintSubtitle,
            onTap: () {
              Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (context) => const FileGeneralComplaintScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ComplaintOptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ComplaintOptionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
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
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
