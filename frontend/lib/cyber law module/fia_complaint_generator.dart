import 'package:flutter/material.dart';
import '../screen_with_nav.dart';
import 'generated_fia_complaint_screen.dart';
import '../utils/validators.dart';
import 'package:front_end/services/fia_complaint_service.dart';
import 'package:front_end/l10n/app_localizations.dart';

class FIAComplaintGeneratorScreen extends StatefulWidget {
  const FIAComplaintGeneratorScreen({super.key});

  @override
  State<FIAComplaintGeneratorScreen> createState() =>
      _FIAComplaintGeneratorScreenState();
}

class _FIAComplaintGeneratorScreenState
    extends State<FIAComplaintGeneratorScreen> {
  final _fullNameController = TextEditingController();
  final _cnicController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _dateController = TextEditingController();
  final _incidentController = TextEditingController();
  final _suspectController = TextEditingController();
  final _evidenceController = TextEditingController();
  final FIAComplaintService _fiaComplaintService = FIAComplaintService();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fullNameController.addListener(_onFormChanged);
    _cnicController.addListener(_onFormChanged);
    _phoneController.addListener(_onFormChanged);
    _emailController.addListener(_onFormChanged);
    _dateController.addListener(_onFormChanged);
    _incidentController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _fullNameController.removeListener(_onFormChanged);
    _cnicController.removeListener(_onFormChanged);
    _phoneController.removeListener(_onFormChanged);
    _emailController.removeListener(_onFormChanged);
    _dateController.removeListener(_onFormChanged);
    _incidentController.removeListener(_onFormChanged);
    _fullNameController.dispose();
    _cnicController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _dateController.dispose();
    _incidentController.dispose();
    _suspectController.dispose();
    _evidenceController.dispose();
    super.dispose();
  }

  bool get _isFormComplete {
    return _fullNameController.text.trim().isNotEmpty &&
        _cnicController.text.trim().isNotEmpty &&
        _phoneController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty &&
        _dateController.text.trim().isNotEmpty &&
        _incidentController.text.trim().isNotEmpty;
  }

  Future<void> _selectDate() async {
    final loc = AppLocalizations.of(context)!;

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: loc.selectDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF00401A)),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text =
            '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _generateComplaint() async {
    final loc = AppLocalizations.of(context)!;

    if (!_isFormComplete) {
      Validators.showError(context, loc.fillRequiredFields);
      return;
    }
    if (!Validators.isValidCnic(_cnicController.text)) {
      Validators.showError(context, loc.invalidCnic);
      return;
    }
    if (!Validators.isValidPhone(_phoneController.text)) {
      Validators.showError(context,  loc.invalidPhone);
      return;
    }
    if (!Validators.isValidEmail(_emailController.text)) {
      Validators.showError(context, loc.invalidEmail);
      return;
    }

    setState(() {
      _isSaving = true;
    });
    final saveResult = await _fiaComplaintService.saveComplaint(
      fullName: _fullNameController.text.trim(),
      cnic: _cnicController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      address: _addressController.text.trim(),
      dateOfIncident: _dateController.text.trim(),
      incidentDescription: _incidentController.text.trim(),
      suspectInfo: _suspectController.text.trim(),
      evidenceAvailable: _evidenceController.text.trim(),
    );
    if (!mounted) return;
    setState(() {
      _isSaving = false;
    });

    if (!(saveResult['success'] as bool? ?? false)) {
      Validators.showError(
        context,
         saveResult['message'] ?? loc.errorSaving,
      );
      return;
    }

    if (saveResult['cloudSaved'] == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:  Text(
          saveResult['cloudSaved'] == false
              ? loc.complaintGeneratedWarning
              : loc.complaintSaved,
          ),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.complaintSaved),
          backgroundColor: const Color(0xFF00401A),
        ),
      );
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GeneratedFIAComplaintScreen(
          fullName: _fullNameController.text,
          cnic: _cnicController.text,
          phone: _phoneController.text,
          email: _emailController.text,
          address: _addressController.text,
          dateOfIncident: _dateController.text,
          incidentDescription: _incidentController.text,
          suspectInfo: _suspectController.text,
          evidenceAvailable: _evidenceController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          loc.fiaComplaintGenerator,
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),

                    // Document icon
                    Center(
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6EFEA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.description_outlined,
                          color: Color(0xFF00401A),
                          size: 32,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Title
                    Text(
                      loc.fileFiaComplaint,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      loc.fillDetailsSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Personal Information Card
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
                           Text(
                            loc.personalinfo,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildLabel(loc.fullName),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _fullNameController,
                            hint: 'Muhammad Ahmed',
                          ),

                          const SizedBox(height: 16),

                          _buildLabel(loc.cnicNumber),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _cnicController,
                            hint: '12345-1234567-1',
                            keyboardType: TextInputType.number,
                          ),

                          const SizedBox(height: 16),

                          _buildLabel(loc.phoneNumber),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _phoneController,
                            hint: '+92-300-1234567',
                            keyboardType: TextInputType.phone,
                          ),

                          const SizedBox(height: 16),

                          _buildLabel(loc.emailAddress),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _emailController,
                            hint: 'ahmed@example.com',
                            keyboardType: TextInputType.emailAddress,
                          ),

                          const SizedBox(height: 16),

                          _buildLabel(loc.address),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _addressController,
                            hint: 'House 123, Street 45, Karachi',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Incident Details Card
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
                          Text(
                            loc.incidentDetails,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildLabel(loc.dateOfIncident),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _dateController,
                            hint: '2026-01-15',
                            readOnly: true,
                            onTap: _selectDate,
                          ),

                          const SizedBox(height: 16),

                          _buildLabel(loc.describeIncident),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _incidentController,
                            maxLines: 5,
                            decoration: InputDecoration(
                              hintText:
                                  'Describe what happened, when it started, how you were contacted...',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF00401A),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),

                          const SizedBox(height: 16),

                          _buildLabel('Suspect Information (if known)'),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _suspectController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText:
                                  'Name, phone number, social media profile, etc.',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF00401A),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),

                          const SizedBox(height: 16),

                          _buildLabel(loc.evidenceAvailable),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _evidenceController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Screenshots, messages, emails, etc.',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF00401A),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (_isFormComplete && !_isSaving)
                            ? _generateComplaint
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (_isFormComplete && !_isSaving)
                              ? const Color(0xFF00401A)
                              : Colors.grey.shade400,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            :  Text(
                                loc.fiaComplaintInfo,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'This will generate a formal complaint letter that you can submit to FIA Cyber Crime Wing',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: buildBottomNavBar(context, 2),
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
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: (_) => _onFormChanged(),
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
