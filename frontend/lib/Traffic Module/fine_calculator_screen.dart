import 'package:flutter/material.dart';
import 'package:front_end/l10n/app_localizations.dart';
import '../screen_with_nav.dart';

class FineCalculatorScreen extends StatefulWidget {
  const FineCalculatorScreen({super.key});

  @override
  State<FineCalculatorScreen> createState() => _FineCalculatorScreen();
}

class _FineCalculatorScreen extends State<FineCalculatorScreen> {
  final Map<String, bool> _selectedViolations = {
    'Over Speeding': false,
    'Red Light': false,
    'No Helmet': false,
    'No Seat Belt': false,
    'Mobile Use': false,
    'No License': false,
  };

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          loc.fineCalculator,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE6EFEA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calculate_outlined,
                    color: Color(0xFF00401A),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.calculateTotalFine,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        loc.selectViolations,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildViolationCard(loc.overSpeeding, 1500),
                    const SizedBox(height: 12),
                    _buildViolationCard(loc.redLight, 1000),
                    const SizedBox(height: 12),
                    _buildViolationCard(loc.noHelmet, 500),
                    const SizedBox(height: 12),
                    _buildViolationCard(loc.noSeatBelt, 500),
                    const SizedBox(height: 12),
                    _buildViolationCard(loc.mobileUse, 1000),
                    const SizedBox(height: 12),
                    _buildViolationCard(loc.noLicense, 5000),
                    const SizedBox(height: 100),
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

  Widget _buildViolationCard(String violation, int amount) {
    final isSelected = _selectedViolations[violation] ?? false;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedViolations[violation] = !isSelected;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00401A)
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(violation,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(height: 4),
                  Text(
                    'Rs. $amount',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF00401A)
                      : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00401A),
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}