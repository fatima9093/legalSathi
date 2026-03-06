import 'package:flutter/material.dart';
import '../screen_with_nav.dart';
import 'document_preview_screen.dart';

class DraftDocumentReviewScreen extends StatefulWidget {
  final String documentType;
  final String complaintantName;
  final String cnic;
  final String address;
  final String incidentDate;
  final String extractedText;
  final String classifiedDomain;
  final List<String> tags;

  const DraftDocumentReviewScreen({
    super.key,
    required this.documentType,
    required this.complaintantName,
    required this.cnic,
    required this.address,
    required this.incidentDate,
    required this.extractedText,
    required this.classifiedDomain,
    required this.tags,
  });

  @override
  State<DraftDocumentReviewScreen> createState() =>
      _DraftDocumentReviewScreenState();
}

class _DraftDocumentReviewScreenState extends State<DraftDocumentReviewScreen> {
  void _generateDocument() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentPreviewScreen(
          documentType: widget.documentType,
          complaintantName: widget.complaintantName,
          cnic: widget.cnic,
          address: widget.address,
          incidentDate: widget.incidentDate,
          extractedText: widget.extractedText,
          classifiedDomain: widget.classifiedDomain,
          tags: widget.tags,
        ),
      ),
    );
  }

  void _editDetails() {
    Navigator.pop(context);
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
                      isActive: false,
                      isCompleted: true,
                    ),
                    _buildProgressLine(true),
                    _buildProgressStep(
                      number: 2,
                      label: 'Details',
                      isActive: false,
                      isCompleted: true,
                    ),
                    _buildProgressLine(true),
                    _buildProgressStep(
                      number: 3,
                      label: 'Review',
                      isActive: true,
                      isCompleted: false,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Title
              const Text(
                'Review Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 24),

              // Info Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildReviewField('Document Type', widget.documentType),
                    const SizedBox(height: 16),
                    _buildReviewField(
                      'Complainant',
                      widget.complaintantName.isNotEmpty
                          ? widget.complaintantName
                          : 'Not provided',
                    ),
                    const SizedBox(height: 16),
                    _buildReviewField(
                      'CNIC',
                      widget.cnic.isNotEmpty ? widget.cnic : 'Not provided',
                    ),
                    const SizedBox(height: 16),
                    _buildReviewField(
                      'Address',
                      widget.address.isNotEmpty
                          ? widget.address
                          : 'Not provided',
                    ),
                    const SizedBox(height: 16),
                    _buildReviewField(
                      'Incident Date',
                      widget.incidentDate.isNotEmpty
                          ? widget.incidentDate
                          : 'Not provided',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Generate Document Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _generateDocument,
                  icon: const Icon(Icons.description, color: Colors.white),
                  label: const Text(
                    'Generate Document',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00401A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Edit Details Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _editDetails,
                  icon: const Icon(Icons.edit, color: Color(0xFF00401A)),
                  label: const Text(
                    'Edit Details',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF00401A),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF00401A)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
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
}
