import 'package:flutter/material.dart';

class ScenarioSimulatorScreen extends StatefulWidget {
  const ScenarioSimulatorScreen({super.key});

  @override
  State<ScenarioSimulatorScreen> createState() =>
      _ScenarioSimulatorScreenState();
}

class _ScenarioSimulatorScreenState extends State<ScenarioSimulatorScreen> {
  int currentStep = 0;

  final List<SimulatorStep> steps = [
    SimulatorStep(
      title: 'Officer Stops You',
      description: 'Traffic officer asks for bribe',
      action: 'Refuse Politely',
      icon: Icons.error_outline,
      iconColor: const Color(0xFFDC2626),
      iconBgColor: const Color(0xFFFFE6E6),
    ),
    SimulatorStep(
      title: 'Collect Details',
      description: 'Note badge number, time, location',
      action: 'Record Information',
      icon: Icons.warning_amber_outlined,
      iconColor: const Color(0xFFD97706),
      iconBgColor: const Color(0xFFFFF9E6),
    ),
    SimulatorStep(
      title: 'Request Challan',
      description: 'Ask for written official challan',
      action: 'Get Documentation',
      icon: Icons.check_circle_outline,
      iconColor: const Color(0xFF0284C7),
      iconBgColor: const Color(0xFFE0F2FE),
    ),
    SimulatorStep(
      title: 'Report Incident',
      description: 'Call 1915 helpline immediately',
      action: 'File Complaint',
      icon: Icons.check_circle,
      iconColor: const Color(0xFF00401A),
      iconBgColor: const Color(0xFFE6F7F0),
    ),
    SimulatorStep(
      title: 'Follow Up',
      description: 'Submit written complaint online',
      action: 'Track Status',
      icon: Icons.check_circle,
      iconColor: const Color(0xFF00401A),
      iconBgColor: const Color(0xFFE6F7F0),
    ),
  ];

  void _nextStep() {
    if (currentStep < steps.length - 1) {
      setState(() {
        currentStep++;
      });
    } else {
      // Start over
      setState(() {
        currentStep = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = steps[currentStep];
    final isLastStep = currentStep == steps.length - 1;

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
          'Scenario Simulator',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 24),

            // Title
            const Text(
              'Bribe Refusal Flow',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFFD97706),
              ),
            ),

            const SizedBox(height: 12),

            // Step indicator
            Text(
              'Step ${currentStep + 1} of ${steps.length}',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 16),

            // Progress bar
            Row(
              children: List.generate(
                steps.length,
                (index) => Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(
                      right: index < steps.length - 1 ? 6 : 0,
                    ),
                    decoration: BoxDecoration(
                      color: index <= currentStep
                          ? const Color(0xFF00401A)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Step card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: step.iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(step.icon, color: step.iconColor, size: 28),
                  ),

                  const SizedBox(height: 16),

                  // Title
                  Text(
                    step.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Description
                  Text(
                    step.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Action: ',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        step.action,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF00401A),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: Color(0xFF00401A),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Next button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00401A),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isLastStep ? 'Start Over' : 'Next Step',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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

class SimulatorStep {
  final String title;
  final String description;
  final String action;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  SimulatorStep({
    required this.title,
    required this.description,
    required this.action,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });
}
