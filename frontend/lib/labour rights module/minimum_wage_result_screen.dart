import 'package:flutter/material.dart';
import '../screen_with_nav.dart';

class MinimumWageResultScreen extends StatelessWidget {
  final String province;
  final String workerType;
  final double userSalary;
  final double minimumWage;
  final bool meetsRequirements;

  const MinimumWageResultScreen({
    super.key,
    required this.province,
    required this.workerType,
    required this.userSalary,
    required this.minimumWage,
    required this.meetsRequirements,
  });

  @override
  Widget build(BuildContext context) {
    double difference = userSalary - minimumWage;
    bool isUnderpaid = difference < 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Wage Check Result'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isUnderpaid ? const Color(0xFFFFE5E5) : const Color(0xFFE8F1EB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: isUnderpaid ? const Color(0xFFC41C3B) : const Color(0xFF4A7C5C),
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isUnderpaid ? 'Underpaid' : 'Compliant',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: isUnderpaid ? const Color(0xFFC41C3B) : const Color(0xFF4A7C5C),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isUnderpaid
                          ? 'Your salary is below the legal minimum wage'
                          : 'Your salary meets the legal minimum wage',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // Wage Breakdown Section
              const Text(
                'Wage Breakdown',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildBreakdownRow(
                      icon: Icons.attach_money,
                      iconColor: const Color(0xFF6B9B7F),
                      label: 'Your Salary',
                      value: 'Rs. ${userSalary.toStringAsFixed(0)}',
                    ),
                    const SizedBox(height: 16),
                    _buildBreakdownRow(
                      icon: Icons.description,
                      iconColor: const Color(0xFF6B9B7F),
                      label: 'Legal Minimum Wage',
                      value: 'Rs. ${minimumWage.toStringAsFixed(0)}',
                    ),
                    const SizedBox(height: 16),
                    _buildBreakdownRow(
                      icon: Icons.error_outline,
                      iconColor: isUnderpaid ? const Color(0xFFC41C3B) : const Color(0xFF4A7C5C),
                      label: 'Difference',
                      value: '${isUnderpaid ? '- ' : ''}Rs. ${difference.abs().toStringAsFixed(0)}',
                      valueColor: isUnderpaid ? const Color(0xFFC41C3B) : const Color(0xFF4A7C5C),
                      isBold: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // Explanation Section
              const Text(
                'Explanation',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isUnderpaid
                      ? 'Your monthly salary of Rs. ${userSalary.toStringAsFixed(0)} is below the legal minimum wage of Rs. ${minimumWage.toStringAsFixed(0)} for $workerType Worker in $province. Your employer is legally required to pay you at least the minimum wage.\n\nYou are being underpaid by Rs. ${difference.abs().toStringAsFixed(0)} per month. This is a violation of labour laws and you have the right to claim the difference.'
                      : 'Your monthly salary of Rs. ${userSalary.toStringAsFixed(0)} meets the legal minimum wage of Rs. ${minimumWage.toStringAsFixed(0)} for $workerType Worker in $province. Your employer is complying with the legal requirement.\n\nYou are being paid Rs. ${difference.abs().toStringAsFixed(0)} above the minimum wage per month. Ensure you keep records of your salary payments for future reference.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w400,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              // Legal Reference Section
              const Text(
                'Legal Reference',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.description,
                          color: Color(0xFF6B9B7F),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Minimum Wages Ordinance 1961',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Under Section 3 of the Minimum Wages Ordinance 1961, all employers must pay workers at least the minimum wage rate notified by the provincial government.\n\nFailure to do so is a punishable offense.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // Action Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Navigate to complaint filing
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Opening complaint form...'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00401A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'File Labour Complaint',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: Navigate to back pay calculator
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Opening back pay calculator...'),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(
                      color: Color(0xFF00401A),
                      width: 2,
                    ),
                  ),
                  child: const Text(
                    'Calculate Back Pay Owed',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF00401A),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavBar(context, 1),
    );
  }

  Widget _buildBreakdownRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    Color valueColor = Colors.black,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
