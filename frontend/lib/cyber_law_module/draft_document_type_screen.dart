import 'package:flutter/material.dart';
import 'package:front_end/l10n/app_localizations.dart';

import '../screen_with_nav.dart';
import 'draft_document_details_screen.dart';

class DraftDocumentTypeScreen extends StatefulWidget {
  final String extractedText;
  final String classifiedDomain;
  final List<String> tags;

  const DraftDocumentTypeScreen({
    super.key,
    required this.extractedText,
    required this.classifiedDomain,
    required this.tags,
  });

  @override
  State<DraftDocumentTypeScreen> createState() =>
      _DraftDocumentTypeScreenState();
}

class _DraftDocumentTypeScreenState extends State<DraftDocumentTypeScreen> {
  String _selectedType = '';

  void _selectDocumentType(String type) {
    setState(() {
      _selectedType = type;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DraftDocumentDetailsScreen(
            documentType: type,
            extractedText: widget.extractedText,
            classifiedDomain: widget.classifiedDomain,
            tags: widget.tags,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
          l10n.reviewTitle, // you can change to documentTitle if you want
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavBar(context, 2),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              Text(
                l10n.selectDocumentType,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 24),

              _buildDocumentTypeCard(
                icon: Icons.description,
                title: l10n.firDraft,
                subtitle: l10n.firSubtitle,
                type: 'FIR',
                onTap: () => _selectDocumentType('FIR'),
              ),

              const SizedBox(height: 12),

              _buildDocumentTypeCard(
                icon: Icons.security,
                title: l10n.pecaComplaint,
                subtitle: l10n.pecaSubtitle,
                type: 'PECA',
                onTap: () => _selectDocumentType('PECA'),
              ),

              const SizedBox(height: 12),

              _buildDocumentTypeCard(
                icon: Icons.warning,
                title: l10n.harassmentComplaint,
                subtitle: l10n.harassmentSubtitle,
                type: 'Harassment',
                onTap: () => _selectDocumentType('Harassment'),
              ),

              const SizedBox(height: 12),

              _buildDocumentTypeCard(
                icon: Icons.business,
                title: l10n.labourRequest,
                subtitle: l10n.labourSubtitle,
                type: 'Labour',
                onTap: () => _selectDocumentType('Labour'),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentTypeCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String type,
    required VoidCallback onTap,
  }) {
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF00401A) : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF00401A).withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF00401A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
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
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isSelected ? const Color(0xFF00401A) : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
