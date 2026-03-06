import 'package:flutter/material.dart';
import 'internal_complaint_submission_screen.dart';

class ComplaintPreviewScreen extends StatelessWidget {
  final String fullName;
  final String cnic;
  final String phone;
  final String email;
  final String workplaceName;
  final String designation;
  final String department;
  final String incidentDate;
  final List<String> harassmentTypes;
  final String description;
  final String accusedName;
  final String accusedDesignation;
  final String witnessNames;

  const ComplaintPreviewScreen({
    super.key,
    required this.fullName,
    required this.cnic,
    required this.phone,
    required this.email,
    required this.workplaceName,
    required this.designation,
    required this.department,
    required this.incidentDate,
    required this.harassmentTypes,
    required this.description,
    required this.accusedName,
    required this.accusedDesignation,
    required this.witnessNames,
  });

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
          'Internal Complaint',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Complaint Preview',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Complaint Document
                  Container(
                    padding: const EdgeInsets.all(20),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'INTERNAL HARASSMENT COMPLAINT',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00401A),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // To/CC Section
                        _buildDetailRow(
                          'To:',
                          'Chairperson, Harassment Inquiry Committee',
                        ),
                        const SizedBox(height: 4),
                        _buildDetailRow('CC:', 'Human Resources Department'),
                        const SizedBox(height: 4),
                        _buildDetailRow('CC:', 'Employer'),
                        const SizedBox(height: 20),

                        // Complainant Details
                        const Text(
                          'COMPLAINANT DETAILS:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00401A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          'Name:',
                          fullName.isEmpty ? 'Not provided' : fullName,
                        ),
                        const SizedBox(height: 4),
                        _buildDetailRow(
                          'Department:',
                          department.isEmpty ? 'Not provided' : department,
                        ),
                        const SizedBox(height: 4),
                        _buildDetailRow(
                          'Designation:',
                          designation.isEmpty ? 'Not provided' : designation,
                        ),
                        const SizedBox(height: 20),

                        // Incident Details
                        const Text(
                          'INCIDENT DETAILS:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00401A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          'Date:',
                          incidentDate.isEmpty ? 'Not provided' : incidentDate,
                        ),
                        const SizedBox(height: 4),
                        _buildDetailRow(
                          'Type:',
                          harassmentTypes.isEmpty
                              ? 'Not provided'
                              : harassmentTypes.join(', '),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Description:',
                          style: TextStyle(fontSize: 13, color: Colors.black87),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description.isEmpty ? 'Not provided' : description,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFF44336),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Accused
                        const Text(
                          'ACCUSED:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00401A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          'Name:',
                          accusedName.isEmpty ? 'Not provided' : accusedName,
                        ),
                        const SizedBox(height: 4),
                        _buildDetailRow(
                          'Designation:',
                          accusedDesignation.isEmpty
                              ? 'Not provided'
                              : accusedDesignation,
                        ),
                        const SizedBox(height: 20),

                        // Requested Action
                        const Text(
                          'REQUESTED ACTION:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00401A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildNumberedItem('1. Immediate inquiry by committee'),
                        _buildNumberedItem(
                          '2. Disciplinary action against accused',
                        ),
                        _buildNumberedItem('3. Safe working environment'),
                        _buildNumberedItem('4. No retaliation'),
                        const SizedBox(height: 20),

                        // Date
                        Text(
                          'Date: ${_getCurrentDate()}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Action Buttons Row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Navigate back to edit
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: Color(0xFF00401A),
                          ),
                          label: const Text('Edit'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF00401A),
                            side: const BorderSide(
                              color: Color(0xFF00401A),
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // TODO: Regenerate functionality
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF00401A),
                            side: const BorderSide(
                              color: Color(0xFF00401A),
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Regenerate'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // TODO: Download functionality
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF00401A),
                            side: const BorderSide(
                              color: Color(0xFF00401A),
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Download'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Bottom Button
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFF5F5F5),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const InternalComplaintSubmissionScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00401A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Continue to Submission',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 13, height: 1.5),
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(color: Colors.black87),
          ),
          const TextSpan(text: ' '),
          TextSpan(
            text: value,
            style: const TextStyle(color: Color(0xFFF44336)),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberedItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFFF44336),
          height: 1.5,
        ),
      ),
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.month}/${now.day}/${now.year}';
  }
}
