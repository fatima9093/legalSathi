import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:front_end/models/overtime_context.dart';
import 'package:front_end/services/labour_wage_record_service.dart';

import '../screen_with_nav.dart';

/// Formal demand letter for unpaid overtime (reuses same DB pattern as minimum wage tools).
class OvertimeDemandLetterScreen extends StatefulWidget {
  final OvertimeContext contextData;

  const OvertimeDemandLetterScreen({
    super.key,
    required this.contextData,
  });

  @override
  State<OvertimeDemandLetterScreen> createState() =>
      _OvertimeDemandLetterScreenState();
}

class _OvertimeDemandLetterScreenState extends State<OvertimeDemandLetterScreen> {
  final LabourWageRecordService _service = LabourWageRecordService();
  bool _savedSnapshot = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _saveSnapshotOnce());
  }

  Future<void> _saveSnapshotOnce() async {
    if (_savedSnapshot) return;
    _savedSnapshot = true;
    final res = await _service.saveOvertimeCalc(widget.contextData);
    if (!mounted) return;
    if (res['success'] == true) {
      return;
    }
    if (res['needAuth'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign in to save this letter snapshot to your account.'),
          backgroundColor: Color(0xFFD97706),
        ),
      );
    } else if (res['missingTable'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Run supabase_labour_wage_records_complete.sql in Supabase SQL Editor.',
          ),
          backgroundColor: Color(0xFFD97706),
        ),
      );
    }
  }

  String _letterBody() {
    final c = widget.contextData;
    final now = DateTime.now();
    final d =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    return '''To: The Employer / HR Department

Subject: Demand for payment of unpaid overtime wages

Dear Sir/Madam,

I am writing to formally demand payment of overtime wages owed to me under the Factories Act, 1934 and applicable provincial labour laws.

Based on my records and the standard method of calculation (ordinary hourly rate derived from my monthly salary and agreed weekly hours, with overtime payable at twice the ordinary rate), the position is as follows:

• Monthly salary: Rs. ${c.monthlySalary.toStringAsFixed(0)}
• Weekly working hours used for calculation: ${c.weeklyHours.toStringAsFixed(0)} hours
• Overtime hours in the period considered: ${c.overtimeHoursPerMonth.toStringAsFixed(0)} hours
• Derived ordinary hourly rate: Rs. ${c.hourlyRate.toStringAsFixed(2)}
• Legal overtime rate (2× ordinary): Rs. ${c.legalOvertimeHourlyRate.toStringAsFixed(2)} per hour
• Total overtime pay demanded: Rs. ${c.totalOvertimePayOwed.toStringAsFixed(0)}

I request that you arrange payment of the above amount within fifteen (15) days of this letter, failing which I shall pursue my remedies before the competent labour authorities / Labour Court without further notice.

Please treat this matter as urgent.

Yours faithfully,

[Your name]
[Your designation / employee ID]
[Contact number]
Date: $d''';
  }

  void _copy() {
    Clipboard.setData(ClipboardData(text: _letterBody()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Letter copied to clipboard'),
        backgroundColor: Color(0xFF00401A),
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
          'Draft Demand Letter',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavBar(context, 2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Unpaid overtime — demand letter',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Edit placeholders in brackets before sending. Amounts follow your calculator inputs.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: SelectableText(
                _letterBody(),
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.55,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00401A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _copy,
                icon: const Icon(Icons.copy, color: Colors.white, size: 20),
                label: const Text(
                  'Copy full letter',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
