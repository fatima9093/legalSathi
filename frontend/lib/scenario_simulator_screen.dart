import 'package:flutter/material.dart';
import 'package:front_end/models/scenario_model.dart';
import 'package:front_end/services/scenario_service.dart';
import 'package:front_end/chat_screen.dart';

// Primary green color matching the app theme
const Color appPrimaryGreen = Color(0xFF00401A);
const Color appBackgroundColor = Color(0xFFF5F5F5);
const Color appIconBackground = Color(0xFFE6EFEA);

class ScenarioSimulatorScreen extends StatefulWidget {
  final ModuleType moduleType;

  const ScenarioSimulatorScreen({super.key, required this.moduleType});

  @override
  State<ScenarioSimulatorScreen> createState() =>
      _ScenarioSimulatorScreenState();
}

class _ScenarioSimulatorScreenState extends State<ScenarioSimulatorScreen> {
  late ModuleScenarioConfig moduleConfig;
  late Scenario selectedScenario;
  int _currentStepIndex = 0;
  final ScenarioService _scenarioService = ScenarioService();

  // For general category selection
  ModuleType? _selectedModule;

  @override
  void initState() {
    super.initState();
    _initializeScenario();
  }

  void _initializeScenario() {
    moduleConfig = _scenarioService.getModuleScenarios(widget.moduleType);
    selectedScenario = moduleConfig.getDefaultScenario();
  }

  void _selectScenario(Scenario scenario) {
    setState(() {
      selectedScenario = scenario;
      _currentStepIndex = 0;
    });
  }

  void _nextStep() {
    if (_currentStepIndex < selectedScenario.guidanceSteps.length - 1) {
      setState(() {
        _currentStepIndex++;
      });
    }
  }

  void _previousStep() {
    if (_currentStepIndex > 0) {
      setState(() {
        _currentStepIndex--;
      });
    }
  }

  void _startChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ChatScreen(selectedModule: _selectedModule ?? widget.moduleType),
      ),
    );
  }

  void _selectModule(ModuleType moduleType) {
    setState(() {
      _selectedModule = moduleType;
      moduleConfig = _scenarioService.getModuleScenarios(moduleType);
      selectedScenario = moduleConfig.getDefaultScenario();
      _currentStepIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show category selection for general entry
    if (widget.moduleType == ModuleType.general && _selectedModule == null) {
      return _buildCategorySelector();
    }

    final isMobile = MediaQuery.of(context).size.width < 600;
    final currentStep = selectedScenario.guidanceSteps[_currentStepIndex];

    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (widget.moduleType == ModuleType.general &&
                _selectedModule != null) {
              setState(() {
                _selectedModule = null;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          moduleConfig.moduleName,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Scenario Selection (only show if multiple scenarios)
            if (moduleConfig.scenarios.length > 1) _buildScenarioSelector(),

            // Main Content
            Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Scenario Title
                  Text(
                    selectedScenario.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Scenario Description
                  Text(
                    selectedScenario.description,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),

                  // Step Progress Indicator
                  _buildStepProgress(),
                  const SizedBox(height: 24),

                  // Current Step Content
                  _buildStepContent(currentStep),
                  const SizedBox(height: 32),

                  // Navigation Buttons
                  _buildNavigationButtons(),
                  const SizedBox(height: 24),

                  // Start Chat Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _startChat,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appPrimaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Start Chat with AI Advisor',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Category Selector - shown when entering from Quick Actions
  Widget _buildCategorySelector() {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'AI Legal Advisor',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: appIconBackground,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.chat_bubble_outline,
                        color: appPrimaryGreen,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Describe Your Legal Situation',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'AI will guide you step-by-step with legal advice and next actions',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Select Legal Domain Label
              Text(
                'Select Legal Domain *',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Category Options
              _buildCategoryButton(
                title: 'Women Harassment',
                subtitle:
                    'Workplace harassment, protection act,\nombudsperson complaints',
                icon: Icons.shield_outlined,
                iconColor: const Color(0xFFC2185B),
                iconBgColor: const Color(0xFFFCE4EC),
                moduleType: ModuleType.womenHarassment,
              ),
              const SizedBox(height: 12),

              _buildCategoryButton(
                title: 'Labour Rights',
                subtitle:
                    'Wages, overtime, leave, contract violations,\nlabour complaints',
                icon: Icons.business_center_outlined,
                iconColor: const Color(0xFF0277BD),
                iconBgColor: const Color(0xFFE1F5FE),
                moduleType: ModuleType.labourRights,
              ),
              const SizedBox(height: 12),

              _buildCategoryButton(
                title: 'Cyber Crime (PECA)',
                subtitle:
                    'Online harassment, blackmail, fake accounts,\nFIA complaints',
                icon: Icons.security_outlined,
                iconColor: const Color(0xFFF57C00),
                iconBgColor: const Color(0xFFFFE0B2),
                moduleType: ModuleType.cyberCrime,
              ),
              const SizedBox(height: 12),

              _buildCategoryButton(
                title: 'Road & Traffic Law',
                subtitle:
                    'Traffic violations, challans, fines, police\nmisconduct',
                icon: Icons.directions_car_outlined,
                iconColor: const Color(0xFF00695C),
                iconBgColor: const Color(0xFFB2DFDB),
                moduleType: ModuleType.traffic,
              ),
              const SizedBox(height: 32),

              // Info Box
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4F8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How AI Advisor Works:',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: appPrimaryGreen,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoPoint(
                      'Describe your situation in your own words',
                    ),
                    _buildInfoPoint('AI asks clarifying questions if needed'),
                    _buildInfoPoint(
                      'Get step-by-step legal guidance\n(PECA, Labour Act, etc.)',
                    ),
                    _buildInfoPoint('Receive relevant law references'),
                    _buildInfoPoint(
                      'Get complaint and legal remedies recommendations',
                    ),
                    _buildInfoPoint('All actions happen within the chat'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required ModuleType moduleType,
  }) {
    return GestureDetector(
      onTap: () => _selectModule(moduleType),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '•',
            style: TextStyle(
              color: appPrimaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioSelector() {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Your Scenario',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: moduleConfig.scenarios
                  .map(
                    (scenario) => Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () => _selectScenario(scenario),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: selectedScenario.id == scenario.id
                                ? appPrimaryGreen
                                : Colors.white,
                            border: Border.all(
                              color: selectedScenario.id == scenario.id
                                  ? appPrimaryGreen
                                  : Colors.grey[300]!,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            scenario.title,
                            style: TextStyle(
                              color: selectedScenario.id == scenario.id
                                  ? Colors.white
                                  : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepProgress() {
    final totalSteps = selectedScenario.guidanceSteps.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step ${_currentStepIndex + 1} of $totalSteps',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: appPrimaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${((_currentStepIndex + 1) / totalSteps * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: appPrimaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: (_currentStepIndex + 1) / totalSteps,
            minHeight: 8,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(appPrimaryGreen),
          ),
        ),
      ],
    );
  }

  Widget _buildStepContent(GuidanceStep step) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Title
          Text(
            step.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: appPrimaryGreen,
            ),
          ),
          const SizedBox(height: 12),

          // Step Description
          Text(
            step.description,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
          ),
          const SizedBox(height: 20),

          // Step Points
          ...step.points.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 4, right: 12),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: appPrimaryGreen,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final totalSteps = selectedScenario.guidanceSteps.length;
    final isFirstStep = _currentStepIndex == 0;
    final isLastStep = _currentStepIndex == totalSteps - 1;

    return Row(
      children: [
        if (!isFirstStep)
          Expanded(
            child: OutlinedButton(
              onPressed: _previousStep,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: appPrimaryGreen),
              ),
              child: Text(
                'Previous',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: appPrimaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        if (!isFirstStep) const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: isLastStep ? null : _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: isLastStep ? Colors.grey[400] : appPrimaryGreen,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(
              isLastStep ? 'Last Step' : 'Next',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
