import 'package:flutter/material.dart';
import '../screen_with_nav.dart';
import 'uploadEvidence_screen.dart';
import 'package:front_end/models/complaint_model.dart';
import 'package:front_end/services/complaint_service.dart';
import '../utils/validators.dart';

class IncidentDetailsScreen extends StatefulWidget {
  final String complaintId;

  const IncidentDetailsScreen({super.key, required this.complaintId});

  @override
  State<IncidentDetailsScreen> createState() => _IncidentDetailsScreenState();
}

class _IncidentDetailsScreenState extends State<IncidentDetailsScreen> {
  final _dateController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _accusedNameController = TextEditingController();
  final _accusedDesignationController = TextEditingController();
  final ComplaintService _complaintService = ComplaintService();

  String? selectedHarassmentType;
  bool _isLoading = false;

  final List<String> harassmentTypes = [
    'Verbal harassment',
    'Physical harassment',
    'Sexual harassment',
    'Cyber harassment',
    'Stalking',
    'Intimidation',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadComplaint();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _descriptionController.dispose();
    _accusedNameController.dispose();
    _accusedDesignationController.dispose();
    super.dispose();
  }

  Future<void> _loadComplaint() async {
    setState(() => _isLoading = true);
    final result = await _complaintService.getComplaint(widget.complaintId);
    setState(() => _isLoading = false);

    if (result['success'] && result['complaint'] != null) {
      final complaint = result['complaint'] as ComplaintModel;
      setState(() {
        _dateController.text = complaint.incidentDate ?? '';
        _descriptionController.text = complaint.description ?? '';
        _accusedNameController.text = complaint.accusedName ?? '';
        _accusedDesignationController.text = complaint.accusedDesignation ?? '';
        if (complaint.harassmentType != null) {
          selectedHarassmentType = complaint.harassmentType;
        }
      });
    }
  }

  Future<void> _saveAndContinue() async {
    // Validate fields
    if (!Validators.isNonEmpty(_dateController.text)) {
      Validators.showError(context, 'Please select the incident date.');
      return;
    }

    if (selectedHarassmentType == null) {
      Validators.showError(context, 'Please select the type of harassment.');
      return;
    }

    if (!Validators.isNonEmpty(_descriptionController.text)) {
      Validators.showError(context, 'Please describe the incident in detail.');
      return;
    }

    if (!Validators.isNonEmpty(_accusedNameController.text)) {
      Validators.showError(
        context,
        'Please enter the name of the accused person.',
      );
      return;
    }

    if (!Validators.isNonEmpty(_accusedDesignationController.text)) {
      Validators.showError(
        context,
        'Please enter the designation of the accused person.',
      );
      return;
    }

    setState(() => _isLoading = true);

    // Get existing complaint
    final result = await _complaintService.getComplaint(widget.complaintId);

    if (!result['success']) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to load complaint'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final existingComplaint = result['complaint'] as ComplaintModel;

    // Update with incident details
    final updatedComplaint = existingComplaint.copyWith(
      incidentDate: _dateController.text.trim(),
      harassmentType: selectedHarassmentType,
      description: _descriptionController.text.trim(),
      accusedName: _accusedNameController.text.trim(),
      accusedDesignation: _accusedDesignationController.text.trim(),
    );

    final saveResult = await _complaintService.saveComplaint(updatedComplaint);
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (saveResult['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incident details saved successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              UploadEvidenceScreen(complaintId: widget.complaintId),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(saveResult['message'] ?? 'Failed to save'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
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
                SizedBox(
                  height: 56,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          'Ombudsperson Complaint',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.only(right: 16),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF00401A),
                            ),
                          ),
                        ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Row(
                    children: [
                      _buildStep(number: '1', label: 'Info', isCompleted: true),
                      _buildStepLine(),
                      _buildStep(
                        number: '2',
                        label: 'Incident',
                        isActive: true,
                      ),
                      _buildStepLine(),
                      _buildStep(
                        number: '3',
                        label: 'Evidence',
                        isActive: false,
                      ),
                      _buildStepLine(),
                      _buildStep(
                        number: '4',
                        label: 'Preview',
                        isActive: false,
                      ),
                      _buildStepLine(),
                      _buildStep(number: '5', label: 'Submit', isActive: false),
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
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Incident Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Describe what happened',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Date of Incident
                    _buildLabel('Date of Incident'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _dateController,
                      hint: 'DD/MM/YYYY',
                    ),

                    const SizedBox(height: 20),

                    // Type of Harassment
                    _buildLabel('Type of Harassment'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: harassmentTypes.map((type) {
                        return _buildChoiceChip(type);
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // Detailed Description
                    _buildLabel('Detailed Description'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: 'Describe the incident in detail...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
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
                          borderSide: const BorderSide(
                            color: Color(0xFF00401A),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Help box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.help_outline,
                            color: Colors.grey.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Need help writing?',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Include: What happened, when, where, who was involved, and any witnesses',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Accused Person's Name
                    _buildLabel('Accused Person\'s Name'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _accusedNameController,
                      hint: 'Full name of the person',
                    ),

                    const SizedBox(height: 20),

                    // Accused Person's Designation
                    _buildLabel('Accused Person\'s Designation'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _accusedDesignationController,
                      hint: 'Their job title/position',
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),

          // Bottom buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton(
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
                      : const Text(
                          'Continue to Evidence',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 0),
                  ),
                  child: const Text(
                    'Back',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
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
    bool isActive = false,
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
  }) {
    return TextField(
      controller: controller,
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

  Widget _buildChoiceChip(String label) {
    final isSelected = selectedHarassmentType == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedHarassmentType = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00401A) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF00401A) : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
