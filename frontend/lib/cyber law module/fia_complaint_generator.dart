import 'package:flutter/material.dart';
import '../screen_with_nav.dart';
import 'generated_fia_complaint_screen.dart';
import '../utils/validators.dart';

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

  @override
  void dispose() {
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
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
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

    if (pickedDate != null) {
      setState(() {
        _dateController.text =
            '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
      });
    }
  }

  void _generateComplaint() {
    if (!_isFormComplete) {
      Validators.showError(context, 'Please fill all required fields.');
      return;
    }
    if (!Validators.isValidCnic(_cnicController.text)) {
      Validators.showError(context, 'Enter CNIC in 12345-1234567-1 format.');
      return;
    }
    if (!Validators.isValidPhone(_phoneController.text)) {
      Validators.showError(context, 'Enter a valid phone number.');
      return;
    }
    if (!Validators.isValidEmail(_emailController.text)) {
      Validators.showError(context, 'Enter a valid email address.');
      return;
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
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'FIA Complaint Generator',
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
                    const Text(
                      'File FIA Cyber Crime Complaint',
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
                      'Fill in your details to generate a formal complaint',
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
                          const Text(
                            'Personal Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildLabel('Full Name *'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _fullNameController,
                            hint: 'Muhammad Ahmed',
                          ),

                          const SizedBox(height: 16),

                          _buildLabel('CNIC Number *'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _cnicController,
                            hint: '12345-1234567-1',
                            keyboardType: TextInputType.number,
                          ),

                          const SizedBox(height: 16),

                          _buildLabel('Phone Number *'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _phoneController,
                            hint: '+92-300-1234567',
                            keyboardType: TextInputType.phone,
                          ),

                          const SizedBox(height: 16),

                          _buildLabel('Email Address *'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _emailController,
                            hint: 'ahmed@example.com',
                            keyboardType: TextInputType.emailAddress,
                          ),

                          const SizedBox(height: 16),

                          _buildLabel('Address'),
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
                          const Text(
                            'Incident Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildLabel('Date of Incident'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _dateController,
                            hint: '2026-01-15',
                          ),

                          const SizedBox(height: 16),

                          _buildLabel('Describe the Incident *'),
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

                          _buildLabel('Evidence Available'),
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
                        onPressed: _isFormComplete ? _generateComplaint : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isFormComplete
                              ? const Color(0xFF00401A)
                              : Colors.grey.shade400,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Generate FIA Complaint',
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
