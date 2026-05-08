import 'package:flutter/material.dart';
import 'package:front_end/l10n/app_localizations.dart';
import '../screen_with_nav.dart';
import 'package:front_end/Women%20harrasment%20Module/IncidentDetails_screen.dart';
import 'package:front_end/models/complaint_model.dart';
import 'package:front_end/services/complaint_service.dart';
import '../utils/validators.dart';

class OmbudspersonComplaintFormScreen extends StatefulWidget {
  final String? complaintId;

  const OmbudspersonComplaintFormScreen({super.key, this.complaintId});

  @override
  State<OmbudspersonComplaintFormScreen> createState() =>
      _OmbudspersonComplaintFormScreenState();
}

class _OmbudspersonComplaintFormScreenState
    extends State<OmbudspersonComplaintFormScreen> {
  final _fullNameController = TextEditingController();
  final _cnicController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _workplaceController = TextEditingController();
  final _designationController = TextEditingController();
  final _cityController = TextEditingController();
  final ComplaintService _complaintService = ComplaintService();
  bool _isLoading = false;
  String? _currentComplaintId;

  @override
  void initState() {
    super.initState();
    _currentComplaintId = widget.complaintId;
    if (_currentComplaintId != null) {
      _loadComplaint();
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _cnicController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _workplaceController.dispose();
    _designationController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _loadComplaint() async {
    final loc = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);
    final result = await _complaintService.getComplaint(_currentComplaintId!);
    setState(() => _isLoading = false);

    if (result['success'] && result['complaint'] != null) {
      final complaint = result['complaint'] as ComplaintModel;
      _fullNameController.text = complaint.fullName ?? '';
      _cnicController.text = complaint.cnic ?? '';
      _phoneController.text = complaint.phone ?? '';
      _emailController.text = complaint.email ?? '';
      _workplaceController.text = complaint.workplace ?? '';
      _designationController.text = complaint.designation ?? '';
      _cityController.text = complaint.city ?? '';
    }
  }

  Future<void> _saveAndContinue() async {
     final loc = AppLocalizations.of(context)!;
    // Validate fields
    if (!Validators.isNonEmpty(_fullNameController.text)) {
      Validators.showError(context, loc.enterFullName);
      return;
    }

    if (!Validators.isNonEmpty(_cnicController.text)) {
      Validators.showError(context, loc.invalidCnic);
      return;
    }

    if (!Validators.isValidCnic(_cnicController.text)) {
      Validators.showError(context, 'Enter CNIC in 12345-1234567-1 format.');
      return;
    }

    if (!Validators.isValidPhone(_phoneController.text)) {
      Validators.showError(context, loc.invalidPhone);
      return;
    }

    if (!Validators.isValidEmail(_emailController.text)) {
      Validators.showError(context, loc.invalidEmail);
      return;
    }

    if (!Validators.isNonEmpty(_workplaceController.text)) {
      Validators.showError(context, loc.enterWorkplace);
      return;
    }

    if (!Validators.isNonEmpty(_designationController.text)) {
      Validators.showError(context, loc.enterDesignation);
      return;
    }

    if (!Validators.isNonEmpty(_cityController.text)) {
      Validators.showError(context,  loc.enterCity);
      return;
    }

    setState(() => _isLoading = true);

    final complaint = ComplaintModel(
      complaintId: _currentComplaintId,
      fullName: _fullNameController.text.trim(),
      cnic: _cnicController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      workplace: _workplaceController.text.trim(),
      designation: _designationController.text.trim(),
      city: _cityController.text.trim(),
      status: 'draft',
    );

    final result = await _complaintService.saveComplaint(complaint);
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      _currentComplaintId = result['complaintId'];

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.infoSaved),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              IncidentDetailsScreen(complaintId: _currentComplaintId!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to save'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
     final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(130),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top bar with back button and title
                SizedBox(
                  height: 56,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          loc.ombudspersonComplaint,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                // Progress stepper
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Row(
                    children: [
                      _buildStep(
                        number: '1',
                        label: loc.info,
                        isActive: true,
                        isCompleted: true,
                      ),
                      _buildStepLine(),
                      _buildStep(
                        number: '2',
                        label:loc.incident,
                        isActive: false,
                      ),
                      _buildStepLine(),
                      _buildStep(
                        number: '3',
                        label: loc.evidence,
                        isActive: false,
                      ),
                      _buildStepLine(),
                      _buildStep(
                        number: '4',
                        label: loc.preview,
                        isActive: false,
                      ),
                      _buildStepLine(),
                      _buildStep(number: '5', label: loc.submit, isActive: false),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const Divider(height: 1),

          // Scrollable form content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Section title
                    Text(
                      loc.applicantInfo,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Section subtitle
                    Text(
                      loc.enterDetails,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Full Name
                    _buildLabel(loc.fullName),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _fullNameController,
                      hint: 'Enter your full name',
                    ),

                    const SizedBox(height: 20),

                    // CNIC Number
                    _buildLabel(loc.cnic),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _cnicController,
                      hint: '00000-0000000-0',
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 20),

                    // Phone Number
                    _buildLabel('loc.phone'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _phoneController,
                      hint: '+92 300 0000000',
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 20),

                    // Email Address
                    _buildLabel(loc.email),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _emailController,
                      hint: 'your.email@example.com',
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 20),

                    // Workplace Name
                    _buildLabel(loc.workplace),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _workplaceController,
                      hint: 'Organization/Company name',
                    ),

                    const SizedBox(height: 20),

                    // Your Designation
                    _buildLabel(loc.designation),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _designationController,
                      hint: 'Job title/position',
                    ),

                    const SizedBox(height: 20),

                    // City
                    _buildLabel(loc.city),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _cityController,
                      hint: 'City name',
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),

          // Bottom button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveAndContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00401A),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 0),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  :  Text(
                      loc.continueToIncident,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: buildBottomNavBar(context, 2),
    );
  }

  Widget _buildStep({
    required String number,
    required String label,
    required bool isActive,
    bool isCompleted = false,
  }) {
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xFF00401A)
                  : isActive
                  ? Colors.white
                  : Colors.grey.shade300,
              shape: BoxShape.circle,
              border: Border.all(
                color: isCompleted || isActive
                    ? const Color(0xFF00401A)
                    : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : Text(
                      number,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isActive
                            ? const Color(0xFF00401A)
                            : Colors.grey.shade600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isCompleted || isActive
                  ? Colors.black87
                  : Colors.grey.shade600,
              fontWeight: isCompleted || isActive
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine() {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 16, left: 2, right: 2),
        color: Colors.grey.shade300,
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.grey.shade50,
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
          borderSide: const BorderSide(color: Color(0xFF00401A), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
