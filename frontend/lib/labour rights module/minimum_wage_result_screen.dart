import 'package:flutter/material.dart';
import '../screen_with_nav.dart';
import 'package:front_end/l10n/app_localizations.dart';
import 'back_pay_calculator_screen.dart';
import 'file_general_complaint_screen.dart';
import 'package:front_end/models/wage_check_context.dart';

class MinimumWageResultScreen extends StatelessWidget {
  final String province;
  final String workerType;
  final double userSalary;
  final double minimumWage;

  const MinimumWageResultScreen({
    super.key,
    required this.province,
    required this.workerType,
    required this.userSalary,
    required this.minimumWage,
  });

  String _prefillComplaintIssue() {
    if (userSalary < minimumWage) {
      return 'Minimum wage violation: I work as a $workerType employee in $province. '
          'My current monthly salary is Rs. ${userSalary.toStringAsFixed(0)} while the '
          'notified minimum wage for my category is Rs. ${minimumWage.toStringAsFixed(0)}. '
          'I request that the competent authority direct my employer to pay the legal minimum '
          'and any arrears owed.';
    }
    return 'Request for clarification on wage classification and applicable minimum wage '
        'for my role ($workerType) in $province.';
  }

  @override
  Widget build(BuildContext context) {
    final difference = userSalary - minimumWage;
    final isUnderpaid = difference < 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.wageCheckResultTitle),
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isUnderpaid
                      ? const Color(0xFFFFE5E5)
                      : const Color(0xFFE8F1EB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isUnderpaid
                              ? Icons.warning_amber_rounded
                              : Icons.check_circle,
                          color: isUnderpaid
                              ? const Color(0xFFC41C3B)
                              : const Color(0xFF4A7C5C),
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isUnderpaid ? AppLocalizations.of(context)!.underpaidStatus : AppLocalizations.of(context)!.compliantStatus,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: isUnderpaid
                                ? const Color(0xFFC41C3B)
                                : const Color(0xFF4A7C5C),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isUnderpaid
                          ? AppLocalizations.of(context)!.underpaidMessage
                          : AppLocalizations.of(context)!.compliantMessage,
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
              Text(
                AppLocalizations.of(context)!.wageBreakdownTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildBreakdownRow(
                      icon: Icons.attach_money,
                      iconColor: const Color(0xFF6B9B7F),
                      label: AppLocalizations.of(context)!.yourSalaryLabel,
                      value: 'Rs. ${userSalary.toStringAsFixed(0)}',
                    ),
                    const SizedBox(height: 16),
                    _buildBreakdownRow(
                      icon: Icons.description,
                      iconColor: const Color(0xFF6B9B7F),
                      label: AppLocalizations.of(context)!.legalMinimumWageLabel,
                      value: 'Rs. ${minimumWage.toStringAsFixed(0)}',
                    ),
                    const SizedBox(height: 16),
                    _buildBreakdownRow(
                      icon: Icons.trending_flat,
                      iconColor: isUnderpaid
                          ? const Color(0xFFC41C3B)
                          : const Color(0xFF4A7C5C),
                      label: AppLocalizations.of(context)!.differenceLabel,
                      value:
                          '${isUnderpaid ? '- ' : '+ '}Rs. ${difference.abs().toStringAsFixed(0)}',
                      valueColor: isUnderpaid
                          ? const Color(0xFFC41C3B)
                          : const Color(0xFF4A7C5C),
                      isBold: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Text(
                AppLocalizations.of(context)!.explanationTitle,
                style: const TextStyle(
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
                      ? AppLocalizations.of(context)!.underpaidExplanation
                      : AppLocalizations.of(context)!.compliantExplanation,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w400,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                AppLocalizations.of(context)!.legalReferenceTitle,
                style: const TextStyle(
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
                        Text(
                          AppLocalizations.of(context)!.minimumWagesOrdinanceLabel,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context)!.minimumWagesOrdinanceText,
                      style: const TextStyle(
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => FileGeneralComplaintScreen(
                          complaintIssue: _prefillComplaintIssue(),
                          wageCheckContext: WageCheckContext(
                            province: province,
                            workerType: workerType,
                            userSalary: userSalary,
                            legalMinimum: minimumWage,
                          ),
                        ),
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
                    children: [
                      Text(
                        AppLocalizations.of(context)!.fileLabourComplaintButton,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => BackPayCalculatorScreen(
                          province: province,
                          workerType: workerType,
                          userSalary: userSalary,
                          minimumWage: minimumWage,
                        ),
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
                  child: Text(
                    AppLocalizations.of(context)!.calculateBackPayButton,
                    style: const TextStyle(
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
