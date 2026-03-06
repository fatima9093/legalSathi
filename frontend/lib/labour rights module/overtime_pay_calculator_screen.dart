import 'package:flutter/material.dart';
import '../screen_with_nav.dart';
import 'file_labour_complaint_screen.dart';
import '../utils/validators.dart';

class OvertimePayCalculatorScreen extends StatefulWidget {
  const OvertimePayCalculatorScreen({super.key});

  @override
  State<OvertimePayCalculatorScreen> createState() =>
      _OvertimePayCalculatorScreenState();
}

class _OvertimePayCalculatorScreenState
    extends State<OvertimePayCalculatorScreen> {
  final TextEditingController _monthlySalaryController =
      TextEditingController();
  final TextEditingController _weeklyHoursController = TextEditingController();
  final TextEditingController _overtimeHoursController =
      TextEditingController();

  double? _overtimePayResult;
  double? _hourlyRate;
  double? _legalOvertimeRate;
  double? _overtimeHours;
  bool _showResult = false;

  @override
  void dispose() {
    _monthlySalaryController.dispose();
    _weeklyHoursController.dispose();
    _overtimeHoursController.dispose();
    super.dispose();
  }

  void _calculateOvertimePay() {
    if (!Validators.isPositiveNumber(_monthlySalaryController.text) ||
        !Validators.isPositiveNumber(_weeklyHoursController.text) ||
        !Validators.isPositiveNumber(_overtimeHoursController.text)) {
      Validators.showError(context, 'Enter valid positive numbers.');
      return;
    }

    final monthlySalary = double.parse(_monthlySalaryController.text.trim());
    final weeklyHours = double.parse(_weeklyHoursController.text.trim());
    final overtimeHours = double.parse(_overtimeHoursController.text.trim());

    // Calculate hourly rate based on monthly salary
    // Assuming 4.33 weeks per month (average)
    final hourlyRate = monthlySalary / (weeklyHours * 4.33);

    // Overtime pay is 2x the regular hourly rate
    final legalOvertimeRate = hourlyRate * 2;
    final overtimePay = overtimeHours * legalOvertimeRate;

    setState(() {
      _hourlyRate = hourlyRate;
      _legalOvertimeRate = legalOvertimeRate;
      _overtimeHours = overtimeHours;
      _overtimePayResult = overtimePay;
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
          'Overtime & Pay Calculator',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavBar(context, 2),
      body: !_showResult ? _buildCalculatorView() : _buildResultView(),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required TextInputType keyboardType,
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
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
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
    );
  }

  Widget _buildCalculatorView() {
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
              Icons.access_time,
              color: Color(0xFF00401A),
              size: 40,
            ),
          ),

          const SizedBox(height: 20),

          // Title
          const Text(
            'Calculate Overtime Pay',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 8),

          // Subtitle
          Text(
            'Check if you\'re being paid correctly for overtime',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Monthly Salary Field
          _buildTextField(
            label: 'Monthly Salary (Rs.) *',
            hintText: 'Enter your monthly salary',
            controller: _monthlySalaryController,
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 16),

          // Weekly Working Hours Field
          _buildTextField(
            label: 'Weekly Working Hours *',
            hintText: 'e.g., 48 hours',
            controller: _weeklyHoursController,
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 16),

          // Overtime Hours Field
          _buildTextField(
            label: 'Overtime Hours (per month) *',
            hintText: 'Total overtime hours worked',
            controller: _overtimeHoursController,
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 24),

          // Info Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Legal Overtime Rate\nUnder Pakistani labour law, overtime must be paid at 2x your regular hourly rate. Standard work week is 48 hours.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue.shade900,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Calculate Button
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
              onPressed: _calculateOvertimePay,
              child: const Text(
                'Calculate Overtime Pay',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Warning Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_rounded,
                  color: Colors.amber.shade700,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Keep records of all overtime hours worked for accurate claims',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.amber.shade900,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
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
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showResult = false;
                  });
                },
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Overtime Calculation',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Result Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF00401A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '\$',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rs. ${_overtimePayResult!.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Total Overtime Pay Owed',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Calculation Breakdown
          const Text(
            'Calculation Breakdown',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                _buildBreakdownRow(
                  'Hourly Rate',
                  'Rs. ${_hourlyRate!.toStringAsFixed(0)}',
                ),
                const SizedBox(height: 12),
                _buildBreakdownRow(
                  'Legal Overtime Rate (2x)',
                  'Rs. ${_legalOvertimeRate!.toStringAsFixed(0)}',
                ),
                const SizedBox(height: 12),
                _buildBreakdownRow(
                  'Overtime Hours',
                  '${_overtimeHours!.toStringAsFixed(0)} hours',
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: Color(0xFFE0E0E0)),
                ),
                _buildBreakdownRow(
                  'Total Owed',
                  'Rs. ${_overtimePayResult!.toStringAsFixed(0)}',
                  isBold: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Legal Reference
          const Text(
            'Legal Reference',
            style: TextStyle(
              fontSize: 16,
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
                  'Section 51 of the Factories Act states that overtime work must be paid at twice the ordinary rate of wages.\n\nMaximum working hours: 48 hours per week or 9 hours per day. Any work beyond this is considered overtime.',
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

          // Recommended Next Steps
          const Text(
            'Recommended Next Steps',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 12),

          _buildStepItem(
            1,
            'Keep detailed records of all overtime hours worked',
          ),
          const SizedBox(height: 10),
          _buildStepItem(
            2,
            'Request written confirmation of overtime pay policy',
          ),
          const SizedBox(height: 10),
          _buildStepItem(
            3,
            'If employer refuses to pay, file complaint with Labour Court',
          ),
          const SizedBox(height: 10),
          _buildStepItem(
            4,
            'You can claim unpaid overtime for up to 3 years back',
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
                'File Labour Complaint',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

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
              onPressed: () {
                // Draft demand letter
              },
              child: const Text(
                'Draft Demand Letter',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF00401A),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(
    String label,
    String value, {
    Color? color,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: color ?? Colors.grey.shade600,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: color ?? Colors.grey.shade900,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStepItem(int number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Color(0xFF00401A),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
