import 'package:flutter/material.dart';
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
  late String _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = '';
  }

  void _selectDocumentType(String type) {
    setState(() {
      _selectedType = type;
    });

    // Navigate to details screen after a brief delay for visual feedback
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
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
      }
    });
  }

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
          'Draft Document',
          style: TextStyle(
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
              // Progress Steps
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    _buildProgressStep(
                      number: 1,
                      label: 'Type',
                      isActive: true,
                      isCompleted: false,
                    ),
                    _buildProgressLine(false),
                    _buildProgressStep(
                      number: 2,
                      label: 'Details',
                      isActive: false,
                      isCompleted: false,
                    ),
                    _buildProgressLine(false),
                    _buildProgressStep(
                      number: 3,
                      label: 'Review',
                      isActive: false,
                      isCompleted: false,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Title
              const Text(
                'Select Document Type',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 24),

              // Document Type Options
              _buildDocumentTypeCard(
                icon: Icons.description,
                title: 'FIR Draft',
                subtitle: 'First Information Report',
                type: 'FIR',
                onTap: () => _selectDocumentType('FIR'),
              ),

              const SizedBox(height: 12),

              _buildDocumentTypeCard(
                icon: Icons.security,
                title: 'PECA Complaint',
                subtitle: 'Cyber crime complaint',
                type: 'PECA',
                onTap: () => _selectDocumentType('PECA'),
              ),

              const SizedBox(height: 12),

              _buildDocumentTypeCard(
                icon: Icons.warning,
                title: 'Harassment Complaint',
                subtitle: 'Workplace/online harassment',
                type: 'Harassment',
                onTap: () => _selectDocumentType('Harassment'),
              ),

              const SizedBox(height: 12),

              _buildDocumentTypeCard(
                icon: Icons.business,
                title: 'Labour Request',
                subtitle: 'Employment dispute',
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

  Widget _buildProgressStep({
    required int number,
    required String label,
    required bool isActive,
    required bool isCompleted,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isCompleted || isActive
                  ? const Color(0xFF00401A)
                  : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 24)
                  : Text(
                      '$number',
                      style: TextStyle(
                        color: isActive || isCompleted
                            ? Colors.white
                            : Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive || isCompleted
                  ? Colors.black
                  : Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressLine(bool isCompleted) {
    return Expanded(
      child: Container(
        height: 2,
        color: isCompleted ? const Color(0xFF00401A) : Colors.grey.shade300,
        margin: const EdgeInsets.only(top: 24),
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedType == type
                ? const Color(0xFF00401A)
                : Colors.grey.shade200,
            width: _selectedType == type ? 2 : 1,
          ),
          boxShadow: _selectedType == type
              ? [
                  BoxShadow(
                    color: const Color(0xFF00401A).withOpacity(0.1),
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
              color: _selectedType == type
                  ? const Color(0xFF00401A)
                  : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
