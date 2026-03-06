import 'package:flutter/material.dart';
import 'generated_complaint_screen.dart';
import '../utils/validators.dart';

class DraftComplaintGeneratorScreen extends StatefulWidget {
  const DraftComplaintGeneratorScreen({super.key});

  @override
  State<DraftComplaintGeneratorScreen> createState() =>
      _DraftComplaintGeneratorScreenState();
}

class _DraftComplaintGeneratorScreenState
    extends State<DraftComplaintGeneratorScreen> {
  int currentStep = 0;

  // Step 1: Personal Information
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController cnicController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController designationController = TextEditingController();
  final TextEditingController workplaceController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // Step 2: Incident Details
  final TextEditingController dateController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController evidenceController = TextEditingController();
  final TextEditingController witnessController = TextEditingController();

  // Step 3: Impact on You
  final TextEditingController mentalImpactController = TextEditingController();
  final TextEditingController emotionalImpactController =
      TextEditingController();
  final TextEditingController safetyConcernsController =
      TextEditingController();

  // Step 4: Relief Sought
  Map<String, bool> reliefOptions = {
    'Written apology from accused': false,
    'Transfer of accused to different department': false,
    'Removal/termination of accused': false,
    'Monetary compensation for damages': false,
    'Disciplinary action against accused': false,
    'Workplace policy changes': false,
  };

  @override
  void dispose() {
    fullNameController.dispose();
    cnicController.dispose();
    phoneController.dispose();
    emailController.dispose();
    designationController.dispose();
    workplaceController.dispose();
    addressController.dispose();
    dateController.dispose();
    descriptionController.dispose();
    evidenceController.dispose();
    witnessController.dispose();
    mentalImpactController.dispose();
    emotionalImpactController.dispose();
    safetyConcernsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Draft Complaint',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildStepContent(),
            ),
          ),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          _buildStepCircle(1, 'Personal', currentStep >= 0),
          _buildStepLine(currentStep >= 1),
          _buildStepCircle(2, 'Incident', currentStep >= 1),
          _buildStepLine(currentStep >= 2),
          _buildStepCircle(3, 'Impact', currentStep >= 2),
          _buildStepLine(currentStep >= 3),
          _buildStepCircle(4, 'Relief', currentStep >= 3),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int step, String label, bool isActive) {
    bool isCompleted = currentStep > step - 1;
    bool isCurrent = currentStep == step - 1;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCompleted
                ? const Color(0xFF00401A)
                : isCurrent
                ? const Color(0xFF00401A)
                : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted && !isCurrent
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Text(
                    '$step',
                    style: TextStyle(
                      color: isCurrent || isCompleted
                          ? Colors.white
                          : Colors.grey.shade600,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isCurrent || isCompleted
                ? const Color(0xFF00401A)
                : Colors.grey.shade600,
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: isActive ? const Color(0xFF00401A) : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildStepContent() {
    switch (currentStep) {
      case 0:
        return _buildPersonalInfoStep();
      case 1:
        return _buildIncidentDetailsStep();
      case 2:
        return _buildImpactStep();
      case 3:
        return _buildReliefStep();
      default:
        return Container();
    }
  }

  Widget _buildPersonalInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personal Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 24),
        _buildTextField(
          'Full Name',
          'Enter your full name',
          fullNameController,
        ),
        _buildTextField('CNIC Number', '00000-0000000-0', cnicController),
        _buildTextField('Phone Number', '+92 300 0000000', phoneController),
        _buildTextField(
          'Email Address',
          'your.email@example.com',
          emailController,
        ),
        _buildTextField(
          'Your Designation',
          'Job title/position',
          designationController,
        ),
        _buildTextField(
          'Workplace Name',
          'Organization/Company name',
          workplaceController,
        ),
        _buildTextField(
          'Workplace Address',
          'Complete address...',
          addressController,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildIncidentDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Incident Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 24),
        _buildTextField(
          'Date(s) of Incident',
          'DD/MM/YYYY or date range',
          dateController,
        ),
        _buildTextField(
          'Description of Harassment',
          'Describe what happened in detail. Include: what was said/done, when, where, who was involved, and any witnesses present...',
          descriptionController,
          maxLines: 5,
        ),
        _buildTextField(
          'Evidence Attached',
          'List all evidence: screenshots, emails, messages, recordings, etc.',
          evidenceController,
          maxLines: 3,
        ),
        _buildTextField(
          'Witness Names (if any)',
          'List names of witnesses, one per line...',
          witnessController,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildImpactStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Impact on You',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 24),
        _buildTextField(
          'Mental Impact',
          'Describe mental health effects: stress, anxiety, depression, sleep issues...',
          mentalImpactController,
          maxLines: 3,
        ),
        _buildTextField(
          'Emotional Impact',
          'Describe emotional effects: fear, humiliation, loss of confidence...',
          emotionalImpactController,
          maxLines: 3,
        ),
        _buildTextField(
          'Safety Concerns',
          'Describe any safety concerns or threats...',
          safetyConcernsController,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildReliefStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Relief Sought',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select all that apply',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),
        ...reliefOptions.keys.map((option) => _buildCheckboxTile(option)),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
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
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxTile(String option) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: CheckboxListTile(
          value: reliefOptions[option],
          onChanged: (value) {
            setState(() {
              reliefOptions[option] = value!;
            });
          },
          title: Text(
            option,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          activeColor: const Color(0xFF00401A),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (currentStep == 3)
            ElevatedButton(
              onPressed: _generateComplaint,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00401A),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Generate Complaint',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            )
          else
            ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00401A),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Continue',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          if (currentStep > 0) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _previousStep,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF00401A),
                minimumSize: const Size(double.infinity, 56),
                side: const BorderSide(color: Color(0xFF00401A), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Back',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _nextStep() {
    // Validate fields based on current step
    if (currentStep == 0) {
      // Validate personal information
      if (!Validators.isNonEmpty(fullNameController.text)) {
        Validators.showError(context, 'Please enter your full name.');
        return;
      }
      if (!Validators.isValidCnic(cnicController.text)) {
        Validators.showError(context, 'Enter CNIC in 12345-1234567-1 format.');
        return;
      }
      if (!Validators.isValidPhone(phoneController.text)) {
        Validators.showError(context, 'Enter a valid phone number.');
        return;
      }
      if (!Validators.isValidEmail(emailController.text)) {
        Validators.showError(context, 'Enter a valid email address.');
        return;
      }
      if (!Validators.isNonEmpty(designationController.text)) {
        Validators.showError(context, 'Please enter your designation.');
        return;
      }
      if (!Validators.isNonEmpty(workplaceController.text)) {
        Validators.showError(context, 'Please enter your workplace.');
        return;
      }
    } else if (currentStep == 1) {
      // Validate incident details
      if (!Validators.isNonEmpty(dateController.text)) {
        Validators.showError(context, 'Please select the incident date.');
        return;
      }
      if (!Validators.isNonEmpty(descriptionController.text)) {
        Validators.showError(context, 'Please describe the incident.');
        return;
      }
    } else if (currentStep == 2) {
      // Validate impact information
      if (!Validators.isNonEmpty(mentalImpactController.text)) {
        Validators.showError(context, 'Please describe the mental impact.');
        return;
      }
      if (!Validators.isNonEmpty(emotionalImpactController.text)) {
        Validators.showError(context, 'Please describe the emotional impact.');
        return;
      }
    }

    if (currentStep < 3) {
      setState(() {
        currentStep++;
      });
    }
  }

  void _previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
    }
  }

  void _generateComplaint() {
    // Validate relief selection
    List<String> selectedRelief = reliefOptions.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (selectedRelief.isEmpty) {
      Validators.showError(
        context,
        'Please select at least one relief option.',
      );
      return;
    }

    // Navigate to generated complaint screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GeneratedComplaintScreen(
          fullName: fullNameController.text,
          cnic: cnicController.text,
          phone: phoneController.text,
          email: emailController.text,
          designation: designationController.text,
          workplace: workplaceController.text,
          address: addressController.text,
          dateOfIncident: dateController.text,
          description: descriptionController.text,
          evidence: evidenceController.text,
          witnesses: witnessController.text,
          mentalImpact: mentalImpactController.text,
          emotionalImpact: emotionalImpactController.text,
          safetyConcerns: safetyConcernsController.text,
          reliefSought: selectedRelief,
        ),
      ),
    );
  }
}
