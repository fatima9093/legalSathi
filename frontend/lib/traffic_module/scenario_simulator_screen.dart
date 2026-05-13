import 'package:flutter/material.dart';
import 'package:front_end/l10n/app_localizations.dart';

class ScenarioSimulatorScreen extends StatefulWidget {
  const ScenarioSimulatorScreen({super.key});

  @override
  State<ScenarioSimulatorScreen> createState() =>
      _ScenarioSimulatorScreenState();
}

class _ScenarioSimulatorScreenState extends State<ScenarioSimulatorScreen> {
  int currentStep = 0;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final List<SimulatorStep> steps = [
      SimulatorStep(
        title: loc.simulatorStepStopTitle,
        description: loc.simulatorStepStopDesc,
        action: loc.simulatorStepStopAction,
        icon: Icons.error_outline,
        iconColor: const Color(0xFFDC2626),
        iconBgColor: const Color(0xFFFFE6E6),
      ),
      SimulatorStep(
        title: loc.simulatorStepDetailsTitle,
        description: loc.simulatorStepDetailsDesc,
        action: loc.simulatorStepDetailsAction,
        icon: Icons.warning_amber_outlined,
        iconColor: const Color(0xFFD97706),
        iconBgColor: const Color(0xFFFFF9E6),
      ),
      SimulatorStep(
        title: loc.simulatorStepChallanTitle,
        description: loc.simulatorStepChallanDesc,
        action: loc.simulatorStepChallanAction,
        icon: Icons.check_circle_outline,
        iconColor: const Color(0xFF0284C7),
        iconBgColor: const Color(0xFFE0F2FE),
      ),
      SimulatorStep(
        title: loc.simulatorStepReportTitle,
        description: loc.simulatorStepReportDesc,
        action: loc.simulatorStepReportAction,
        icon: Icons.check_circle,
        iconColor: const Color(0xFF00401A),
        iconBgColor: const Color(0xFFE6F7F0),
      ),
      SimulatorStep(
        title: loc.simulatorStepFollowUpTitle,
        description: loc.simulatorStepFollowUpDesc,
        action: loc.simulatorStepFollowUpAction,
        icon: Icons.check_circle,
        iconColor: const Color(0xFF00401A),
        iconBgColor: const Color(0xFFE6F7F0),
      ),
    ];

    final step = steps[currentStep];
    final isLastStep = currentStep == steps.length - 1;

    void nextStep() {
      setState(() {
        currentStep =
            isLastStep ? 0 : currentStep + 1;
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          loc.simulatorTitle,
          style: const TextStyle(
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

            Text(
              loc.bribeFlowTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFFD97706),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              loc.stepIndicator(currentStep + 1, steps.length),
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 16),

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

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: step.iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(step.icon,
                        color: step.iconColor, size: 28),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    step.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    step.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${loc.actionLabel}: ",
                        style: TextStyle(
                          fontSize: 13,
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
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00401A),
                  minimumSize: const Size(double.infinity, 54),
                ),
                child: Text(
                  isLastStep ? loc.startOver : loc.nextStep,
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