import 'package:flutter/material.dart';
import 'complaint_preview_screen.dart';

class UploadEvidenceScreen extends StatefulWidget {
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

  const UploadEvidenceScreen({
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
  });

  @override
  State<UploadEvidenceScreen> createState() => _UploadEvidenceScreenState();
}

class _UploadEvidenceScreenState extends State<UploadEvidenceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _witnessNamesController = TextEditingController();

  @override
  void dispose() {
    _witnessNamesController.dispose();
    super.dispose();
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
          'Internal Complaint',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Upload Evidence',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add supporting documents',
                style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
              ),
              const SizedBox(height: 24),

              // Witness Names
              _buildLabel('Witness Names'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _witnessNamesController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'List witnesses...',
                  hintStyle: const TextStyle(
                    color: Color(0xFFBDBDBD),
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF00401A),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),

              // Continue to Preview Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ComplaintPreviewScreen(
                          fullName: widget.fullName,
                          cnic: widget.cnic,
                          phone: widget.phone,
                          email: widget.email,
                          workplaceName: widget.workplaceName,
                          designation: widget.designation,
                          department: widget.department,
                          incidentDate: widget.incidentDate,
                          harassmentTypes: widget.harassmentTypes,
                          description: widget.description,
                          accusedName: widget.accusedName,
                          accusedDesignation: widget.accusedDesignation,
                          witnessNames: _witnessNamesController.text,
                        ),
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
                    'Continue to Preview',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Back Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Back',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    );
  }
}
