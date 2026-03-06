import 'package:flutter/material.dart';
import '../screen_with_nav.dart';
import 'minimum_wage_result_screen.dart';
import '../utils/validators.dart';

class MinimumWageCheckerScreen extends StatefulWidget {
  const MinimumWageCheckerScreen({super.key});

  @override
  State<MinimumWageCheckerScreen> createState() =>
      _MinimumWageCheckerScreenState();
}

class _MinimumWageCheckerScreenState extends State<MinimumWageCheckerScreen> {
  final TextEditingController salaryController = TextEditingController();

  String? selectedProvince;
  String? selectedWorkerType;

  final List<String> provinces = [
    'Punjab',
    'Sindh',
    'Khyber Pakhtunkhwa',
    'Balochistan',
    'Islamabad',
    'Gilgit-Baltistan',
    'Azad Jammu & Kashmir',
  ];

  final List<String> workerTypes = [
    'Unskilled',
    'Semi-skilled',
    'Skilled',
    'Highly skilled',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Minimum Wage Checker'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Dollar sign icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.attach_money,
                  size: 36,
                  color: Color(0xFF00401A),
                ),
              ),
              const SizedBox(height: 24),
              // Title
              const Text(
                'Check Your Wage',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              // Subtitle
              const Text(
                'Verify if your salary meets legal minimum wage',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 32),
              // Province dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Province *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: selectedProvince,
                    hint: const Text('Select your province'),
                    items: provinces
                        .map(
                          (province) => DropdownMenuItem(
                            value: province,
                            child: Text(province),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedProvince = value;
                      });
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 0.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 0.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF00401A),
                          width: 1,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Worker Type dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Worker Type *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: selectedWorkerType,
                    hint: const Text('Select worker type'),
                    items: workerTypes
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedWorkerType = value;
                      });
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 0.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 0.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF00401A),
                          width: 1,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Monthly Salary input
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monthly Salary (Rs.) *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: salaryController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your monthly salary',
                      hintStyle: const TextStyle(color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 0.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 0.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF00401A),
                          width: 1,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Check My Wage button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _checkWage();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B9B7F),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Check My Wage',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Info box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F1EB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Minimum wage rates are updated annually by provincial governments',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4A7C5C),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavBar(context, 0),
    );
  }

  void _checkWage() {
    if (selectedProvince == null || selectedWorkerType == null) {
      Validators.showError(context, 'Please select province and worker type.');
      return;
    }
    if (!Validators.isPositiveNumber(salaryController.text)) {
      Validators.showError(context, 'Enter a valid salary amount.');
      return;
    }

    // Get user salary
    double userSalary = double.parse(salaryController.text.trim());

    // Sample minimum wage data (you can replace with actual API data)
    Map<String, Map<String, double>> minimumWageData = {
      'Punjab': {
        'Unskilled': 32000,
        'Semi-skilled': 36000,
        'Skilled': 40000,
        'Highly skilled': 45000,
      },
      'Sindh': {
        'Unskilled': 33000,
        'Semi-skilled': 37000,
        'Skilled': 41000,
        'Highly skilled': 46000,
      },
      'Khyber Pakhtunkhwa': {
        'Unskilled': 31000,
        'Semi-skilled': 35000,
        'Skilled': 39000,
        'Highly skilled': 44000,
      },
      'Balochistan': {
        'Unskilled': 30000,
        'Semi-skilled': 34000,
        'Skilled': 38000,
        'Highly skilled': 43000,
      },
      'Islamabad': {
        'Unskilled': 34000,
        'Semi-skilled': 38000,
        'Skilled': 42000,
        'Highly skilled': 47000,
      },
      'Gilgit-Baltistan': {
        'Unskilled': 29000,
        'Semi-skilled': 33000,
        'Skilled': 37000,
        'Highly skilled': 42000,
      },
      'Azad Jammu & Kashmir': {
        'Unskilled': 29000,
        'Semi-skilled': 33000,
        'Skilled': 37000,
        'Highly skilled': 42000,
      },
    };

    // Get minimum wage for selected province and worker type
    double minimumWage =
        minimumWageData[selectedProvince]?[selectedWorkerType] ?? 30000;

    // Check if wage meets requirements
    bool meetsRequirements = userSalary >= minimumWage;

    // Navigate to result screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MinimumWageResultScreen(
          province: selectedProvince!,
          workerType: selectedWorkerType!,
          userSalary: userSalary,
          minimumWage: minimumWage,
          meetsRequirements: meetsRequirements,
        ),
      ),
    );
  }

  @override
  void dispose() {
    salaryController.dispose();
    super.dispose();
  }
}
