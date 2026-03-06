import 'package:flutter/material.dart';
import '../screen_with_nav.dart';
import 'file_labour_complaint_screen.dart';
import '../utils/validators.dart';

class PaidLeaveEligibilityScreen extends StatefulWidget {
  const PaidLeaveEligibilityScreen({super.key});

  @override
  State<PaidLeaveEligibilityScreen> createState() =>
      _PaidLeaveEligibilityScreenState();
}

class _PaidLeaveEligibilityScreenState
    extends State<PaidLeaveEligibilityScreen> {
  String? _selectedEmploymentType;
  String? _selectedLeaveType;
  final TextEditingController _durationController = TextEditingController();

  String? _result;
  String? _resultMessage;
  String? _explanation;
  bool _showResult = false;

  final List<String> employmentTypes = [
    'Permanent Employee',
    'Contract Employee',
    'Daily Wage Worker',
    'Domestic Worker',
  ];

  final List<String> leaveTypes = [
    'Annual Leave',
    'Sick Leave',
    'Casual Leave',
    'Maternity Leave',
  ];

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  void _checkEligibility() {
    if (_selectedEmploymentType == null || _selectedLeaveType == null) {
      Validators.showError(context, 'Please select employment and leave type.');
      return;
    }
    if (!Validators.isPositiveNumber(_durationController.text)) {
      Validators.showError(context, 'Enter a valid duration in months.');
      return;
    }

    final duration = int.tryParse(_durationController.text.trim()) ?? 0;

    String result = '';
    String message = '';
    String explanation = '';
    int monthsNeeded = 0;

    // Check eligibility based on employment type and duration
    if (_selectedEmploymentType == 'Permanent Employee') {
      if (_selectedLeaveType == 'Annual Leave') {
        if (duration >= 12) {
          result = 'Eligible';
          message = 'You qualify for annual leave';
          explanation =
              'You have worked for $duration months. You are entitled to 15 working days of annual leave per year.';
          monthsNeeded = 0;
        } else {
          result = 'Not Eligible Yet';
          monthsNeeded = 12 - duration;
          message =
              'You need $monthsNeeded more months to qualify for annual leave';
          explanation =
              'You have worked for $duration months. To qualify for annual leave, you need to complete at least 12 months of continuous employment.';
        }
      } else if (_selectedLeaveType == 'Sick Leave') {
        if (duration >= 3) {
          result = 'Eligible';
          message = 'You qualify for sick leave';
          explanation =
              'Sick leave is a right under the Shops & Establishments Act. You can take up to 10 days per year.';
          monthsNeeded = 0;
        } else {
          result = 'Not Eligible Yet';
          monthsNeeded = 3 - duration;
          message =
              'You need $monthsNeeded more months to qualify for sick leave';
          explanation =
              'You have worked for $duration months. Workers are entitled to sick leave after 3 months of service.';
        }
      } else if (_selectedLeaveType == 'Casual Leave') {
        result = 'Eligible';
        message = 'You qualify for casual leave';
        explanation =
            'Casual leave is available to all permanent employees. Typically 8-10 days per year depending on your company policy.';
      } else if (_selectedLeaveType == 'Maternity Leave') {
        result = 'Eligible';
        message = 'You may qualify for maternity leave';
        explanation =
            'Under Pakistani law, eligible workers are entitled to maternity benefit. Eligibility and duration depend on specific circumstances.';
      }
    } else if (_selectedEmploymentType == 'Contract Employee') {
      result = 'Check Contract';
      message = 'Review your employment contract';
      explanation =
          'Leave eligibility for contract employees depends on your employment contract terms. Review your contract for specific leave provisions.';
    } else {
      result = 'Check with Employer';
      message = 'Contact your HR department';
      explanation =
          'Leave eligibility for daily wage and domestic workers varies. Contact your employer or HR department for your specific entitlements.';
    }

    setState(() {
      _result = result;
      _resultMessage = message;
      _explanation = explanation;
      _showResult = true;
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
          'Paid Leave Eligibility',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavBar(context, 2),
      body: !_showResult ? _buildFormView() : _buildResultView(),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hintText,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
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
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            underline: const SizedBox(),
            hint: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                hintText,
                style: TextStyle(color: Colors.grey.shade400),
              ),
            ),
            value: value,
            items: items
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(item),
                    ),
                  ),
                )
                .toList(),
            onChanged: onChanged,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
        ),
      ],
    );
  }

  Widget _buildFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFE6EFEA),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_today,
              color: Color(0xFF00401A),
              size: 40,
            ),
          ),

          const SizedBox(height: 20),

          // Title
          const Text(
            'Check Leave Eligibility',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 8),

          // Subtitle
          Text(
            'Find out if you\'re entitled to paid leave',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Employment Type Dropdown
          _buildDropdownField(
            label: 'Employment Type *',
            hintText: 'Select employment type',
            value: _selectedEmploymentType,
            items: employmentTypes,
            onChanged: (value) {
              setState(() {
                _selectedEmploymentType = value;
              });
            },
          ),

          const SizedBox(height: 16),

          // Duration of Employment Field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Duration of Employment (months) *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'How long have you worked here?',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Leave Type Dropdown
          _buildDropdownField(
            label: 'Leave Type *',
            hintText: 'Select leave type',
            value: _selectedLeaveType,
            items: leaveTypes,
            onChanged: (value) {
              setState(() {
                _selectedLeaveType = value;
              });
            },
          ),

          const SizedBox(height: 24),

          // Check Eligibility Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00401A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _checkEligibility,
              child: const Text(
                'Check Eligibility',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Info Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Text(
              'Paid leave is a legal right under the Factories Act and Shops & Establishments Act',
              style: TextStyle(
                fontSize: 13,
                color: Colors.green.shade900,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button and title
          GestureDetector(
            onTap: () {
              setState(() {
                _showResult = false;
              });
            },
            child: Row(
              children: [
                const Icon(Icons.arrow_back, color: Colors.black, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Leave Eligibility Result',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Result Alert Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _result == 'Eligible'
                  ? Colors.green.shade50
                  : _result == 'Check Contract' ||
                        _result == 'Check with Employer'
                  ? Colors.blue.shade50
                  : Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _result == 'Eligible'
                    ? Colors.green.shade300
                    : _result == 'Check Contract' ||
                          _result == 'Check with Employer'
                    ? Colors.blue.shade300
                    : Colors.red.shade300,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  _result == 'Eligible'
                      ? Icons.check_circle
                      : _result == 'Check Contract' ||
                            _result == 'Check with Employer'
                      ? Icons.info_outlined
                      : Icons.cancel_outlined,
                  color: _result == 'Eligible'
                      ? Colors.green.shade700
                      : _result == 'Check Contract' ||
                            _result == 'Check with Employer'
                      ? Colors.blue.shade700
                      : Colors.red.shade700,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  _result ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _result == 'Eligible'
                        ? Colors.green.shade900
                        : _result == 'Check Contract' ||
                              _result == 'Check with Employer'
                        ? Colors.blue.shade900
                        : Colors.red.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _resultMessage ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    color: _result == 'Eligible'
                        ? Colors.green.shade900
                        : _result == 'Check Contract' ||
                              _result == 'Check with Employer'
                        ? Colors.blue.shade900
                        : Colors.red.shade900,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Explanation Section
          const Text(
            'Explanation',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              _explanation ?? '',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Legal Reference Section
          const Text(
            'Legal Reference',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      color: Colors.grey.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Factories Act 1934 & Shops Act',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Section 49 guarantees 14 days of paid annual leave after 12 months of continuous service.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Action Buttons
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00401A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FileLabourComplaintScreen(),
                  ),
                );
              },
              child: const Text(
                'File Complaint for Denied Leave',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
