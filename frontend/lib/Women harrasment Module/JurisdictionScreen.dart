import 'package:flutter/material.dart';
import 'package:front_end/Women%20harrasment%20Module/ombudspersonComplaintForm_screen.dart';

class SelectJurisdictionScreen extends StatefulWidget {
  const SelectJurisdictionScreen({super.key});

  @override
  State<SelectJurisdictionScreen> createState() =>
      _SelectJurisdictionScreenState();
}

class _SelectJurisdictionScreenState extends State<SelectJurisdictionScreen> {
  String? selectedJurisdiction;

  final List<Map<String, String>> jurisdictions = [
    {
      'name': 'Punjab',
      'urdu': 'پنجاب',
    },
    {
      'name': 'Sindh',
      'urdu': 'سندھ',
    },
    {
      'name': 'Khyber Pakhtunkhwa',
      'urdu': 'خیبرپختونخوا',
    },
    {
      'name': 'Balochistan',
      'urdu': 'بلوچستان',
    },
    {
      'name': 'Islamabad Capital Territory',
      'urdu': 'اسلام آباد',
    },
    {
      'name': 'Federal Government',
      'urdu': 'وفاقی حکومت',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Select Jurisdiction',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Location icon
            SizedBox(
              width: 60,
              height: 60,
             
              child: const Icon(
                Icons.location_on_outlined,
                color:  Color(0xFF00401A),
                size: 48,
              ),
            ),

            const SizedBox(height: 24),

            // Title
            const Text(
              'Which Province/Area?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 8),

            // Subtitle
            Text(
              'Select where your workplace is located',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 32),

            // Jurisdiction list
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: jurisdictions.map((jurisdiction) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildJurisdictionCard(
                      name: jurisdiction['name']!,
                      urdu: jurisdiction['urdu']!,
                      value: jurisdiction['name']!,
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: selectedJurisdiction != null
              ? () {
                  // TODO: Navigate to next screen
                  Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OmbudspersonComplaintFormScreen(),
                            ),
                          );
                  // You can access selectedJurisdiction value here
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00401A),
            disabledBackgroundColor: Colors.grey.shade300,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Next',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: selectedJurisdiction != null ? Colors.white : Colors.grey.shade500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJurisdictionCard({
    required String name,
    required String urdu,
    required String value,
  }) {
    final isSelected = selectedJurisdiction == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedJurisdiction = value;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF00401A) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.black87 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    urdu,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            // Radio button
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