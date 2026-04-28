import 'package:flutter/material.dart';
import 'package:front_end/l10n/app_localizations.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  List<DocumentItem> _getDocuments(BuildContext context) {
    return [
      DocumentItem(
        title: AppLocalizations.of(context)!.firDraftHarassmentDoc,
        fileType: 'PDF',
        fileSize: '245 KB',
        date: 'Jan 15, 2024',
      ),
      DocumentItem(
        title: AppLocalizations.of(context)!.pecaComplaintDoc,
        fileType: 'PDF',
        fileSize: '189 KB',
        date: 'Jan 12, 2024',
      ),
      DocumentItem(
        title: AppLocalizations.of(context)!.labourRequestDoc,
        fileType: 'PDF',
        fileSize: '156 KB',
        date: 'Jan 10, 2024',
      ),
      DocumentItem(
        title: AppLocalizations.of(context)!.evidenceAnalysisDoc,
        fileType: 'PDF',
        fileSize: '312 KB',
        date: 'Jan 8, 2024',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final documents = _getDocuments(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.documents,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {
              // Navigate to notifications
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: documents.length,
        itemBuilder: (context, index) {
          final doc = documents[index];
          return _buildDocumentCard(doc);
        },
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildDocumentCard(DocumentItem doc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Document Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE6EFEA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.description_outlined,
                color: Color(0xFF00401A),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            // Document Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${doc.fileType} • ${doc.fileSize} • ${doc.date}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            // Action Icons
            IconButton(
              icon: const Icon(Icons.download_outlined, color: Colors.grey),
              onPressed: () {
                // Download functionality - will be implemented later
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.downloadFeatureComingSoon),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.grey),
              onPressed: () {
                // Delete functionality - will be implemented later
                _showDeleteConfirmation(context, doc);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, DocumentItem doc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.delete),
          content: Text('${AppLocalizations.of(context)!.areYouSureYouWantToDelete} "${doc.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text((AppLocalizations.of(context)!.cancel)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Delete feature coming soon'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: Text((AppLocalizations.of(context)!.delete), style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 2, // Documents tab is selected
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/home_screen');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/chat');
            break;
          case 2:
            // Already on Documents screen
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/profile');
            break;
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: AppLocalizations.of(context)!.bottomNavHome,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.chat_bubble_outline),
          label: AppLocalizations.of(context)!.bottomNavChat,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.folder_outlined),
          label: AppLocalizations.of(context)!.bottomNavDocuments,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outline),
          label: AppLocalizations.of(context)!.bottomNavProfile,
        ),
      ],
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF00401A),
      unselectedItemColor: Colors.grey,
    );
  }
}

// Model class for document items
class DocumentItem {
  final String title;
  final String fileType;
  final String fileSize;
  final String date;

  DocumentItem({
    required this.title,
    required this.fileType,
    required this.fileSize,
    required this.date,
  });
}
