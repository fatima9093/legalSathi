import 'package:flutter/material.dart';
import '../utils/validators.dart';
import '../screen_with_nav.dart';
import 'draft_document_review_screen.dart';

class DraftDocumentDetailsScreen extends StatefulWidget {
  final String documentType;
  final String extractedText;
  final String classifiedDomain;
  final List<String> tags;

  const DraftDocumentDetailsScreen({
    super.key,
    required this.documentType,
    required this.extractedText,
    required this.classifiedDomain,
    required this.tags,
  });

  @override
  State<DraftDocumentDetailsScreen> createState() =>
      _DraftDocumentDetailsScreenState();
}

class _DraftDocumentDetailsScreenState
    extends State<DraftDocumentDetailsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  bool get _isFormComplete {
    return _nameController.text.trim().isNotEmpty &&
        _cnicController.text.trim().isNotEmpty &&
        _addressController.text.trim().isNotEmpty &&
        _dateController.text.trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
    _cnicController.addListener(() => setState(() {}));
    _addressController.addListener(() => setState(() {}));
    _dateController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cnicController.dispose();
    _addressController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF00401A)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  void _continueToReview() {
    if (!_isFormComplete) {
      Validators.showError(context, 'Please fill all required fields.');
      return;
    }
    if (!Validators.isValidCnic(_cnicController.text)) {
      Validators.showError(context, 'Enter CNIC in 12345-1234567-1 format.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DraftDocumentReviewScreen(
          documentType: widget.documentType,
          complaintantName: _nameController.text.trim(),
          cnic: _cnicController.text.trim(),
          address: _addressController.text.trim(),
          incidentDate: _dateController.text.trim(),
          extractedText: widget.extractedText,
          classifiedDomain: widget.classifiedDomain,
          tags: widget.tags,
        ),
      ),
    );
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
                      isActive: true,
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

              const SizedBox(height: 24),

              // Title
              const Text(
                'Enter Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 24),

              // Complainant Name
              _buildFormField(
                label: 'Complainant Name',
                hint: 'Enter your full name',
                controller: _nameController,
                icon: Icons.person,
              ),

              const SizedBox(height: 20),

              // CNIC Number
              _buildFormField(
                label: 'CNIC Number',
                hint: '00000-0000000-0',
                controller: _cnicController,
                icon: Icons.credit_card,
                inputType: TextInputType.number,
              ),

              const SizedBox(height: 20),

              // Address
              _buildFormField(
                label: 'Address',
                hint: 'Enter your address',
                controller: _addressController,
                icon: Icons.location_on,
              ),

              const SizedBox(height: 20),

              // Incident Date
              const Text(
                'Incident Date',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _dateController.text.isEmpty
                              ? 'DD/MM/YYYY'
                              : _dateController.text,
                          style: TextStyle(
                            fontSize: 14,
                            color: _dateController.text.isEmpty
                                ? Colors.grey.shade400
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isFormComplete
                        ? const Color(0xFF00401A)
                        : Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isFormComplete ? _continueToReview : null,
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF00401A)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Back',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF00401A),
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

  Widget _buildFormField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: inputType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(icon, color: Colors.grey.shade600, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF00401A)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 0,
              vertical: 14,
            ),
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
