import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:front_end/services/labour_wage_record_service.dart';

import '../screen_with_nav.dart';

/// Multi-step back-pay estimate from a minimum wage check result.
class BackPayCalculatorScreen extends StatefulWidget {
  final String province;
  final String workerType;
  final double userSalary;
  final double minimumWage;

  const BackPayCalculatorScreen({
    super.key,
    required this.province,
    required this.workerType,
    required this.userSalary,
    required this.minimumWage,
  });

  @override
  State<BackPayCalculatorScreen> createState() =>
      _BackPayCalculatorScreenState();
}

class _BackPayCalculatorScreenState extends State<BackPayCalculatorScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _monthsController = TextEditingController();
  final LabourWageRecordService _service = LabourWageRecordService();

  int _pageIndex = 0;
  bool _saving = false;

  double get _monthlyGap {
    final g = widget.minimumWage - widget.userSalary;
    return g > 0 ? g : 0;
  }

  int get _monthsParsed {
    final t = _monthsController.text.trim();
    final n = int.tryParse(t);
    return n == null || n < 0 ? 0 : n;
  }

  double get _totalBackPay => _monthlyGap * _monthsParsed;

  @override
  void dispose() {
    _pageController.dispose();
    _monthsController.dispose();
    super.dispose();
  }

  Future<void> _saveToDb() async {
    setState(() => _saving = true);
    final res = await _service.saveBackPay(
      province: widget.province,
      workerType: widget.workerType,
      monthlySalary: widget.userSalary,
      legalMinimumWage: widget.minimumWage,
      meetsMinimum: widget.userSalary >= widget.minimumWage,
      monthlyShortfall: _monthlyGap,
      monthsOwed: _monthsParsed,
      totalBackPay: _totalBackPay,
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Back pay estimate saved to your account.'),
          backgroundColor: Color(0xFF00401A),
        ),
      );
    } else if (res['needAuth'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign in to save this estimate to your account.'),
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message']?.toString() ?? 'Could not save.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Calculate Back Pay Owed'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      bottomNavigationBar: buildBottomNavBar(context, 2),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: List.generate(3, (i) {
                final active = i <= _pageIndex;
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                    height: 4,
                    decoration: BoxDecoration(
                      color: active
                          ? const Color(0xFF00401A)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _pageIndex = i),
              children: [
                _buildStepContext(),
                _buildStepMonths(),
                _buildStepSummary(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContext() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your wage context',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _card([
            _row('Province', widget.province),
            _row('Worker type', widget.workerType),
            _row('Your monthly salary', 'Rs. ${widget.userSalary.toStringAsFixed(0)}'),
            _row('Legal minimum (monthly)', 'Rs. ${widget.minimumWage.toStringAsFixed(0)}'),
            _row(
              'Monthly shortfall',
              _monthlyGap > 0
                  ? 'Rs. ${_monthlyGap.toStringAsFixed(0)}'
                  : 'Rs. 0 (you are at or above minimum)',
              emphasize: _monthlyGap > 0,
            ),
          ]),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00401A),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Continue',
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
    );
  }

  Widget _buildStepMonths() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How long has this been owed?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _monthlyGap <= 0
                ? 'You can still enter months for records; estimated back pay will be Rs. 0.'
                : 'Enter the number of full months you were paid below the legal minimum.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _monthsController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Number of months',
              hintText: 'e.g. 6',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFF00401A)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Back',
                    style: TextStyle(color: Color(0xFF00401A)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    if (_monthsController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Enter number of months')),
                      );
                      return;
                    }
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00401A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'See estimate',
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
        ],
      ),
    );
  }

  Widget _buildStepSummary() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estimated total back pay',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rs. ${_totalBackPay.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF00401A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '($_monthsParsed months × Rs. ${_monthlyGap.toStringAsFixed(0)} monthly gap)',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'This is an estimate for your records. Actual amounts may depend on notifications, '
            'proof of payment, and labour court orders.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFF00401A)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Back',
                    style: TextStyle(color: Color(0xFF00401A)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _saving
                      ? null
                      : () async {
                          await _saveToDb();
                          if (mounted) Navigator.pop(context);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00401A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Save to account',
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
        ],
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _intersperse(children, const SizedBox(height: 12)),
      ),
    );
  }

  List<Widget> _intersperse(List<Widget> list, Widget gap) {
    final out = <Widget>[];
    for (var i = 0; i < list.length; i++) {
      out.add(list[i]);
      if (i < list.length - 1) out.add(gap);
    }
    return out;
  }

  Widget _row(String label, String value, {bool emphasize = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              fontWeight: emphasize ? FontWeight.w700 : FontWeight.w600,
              color: emphasize ? const Color(0xFFC41C3B) : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
