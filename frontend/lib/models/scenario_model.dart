/// Module types for scenario simulator
enum ModuleType {
  traffic,
  womenHarassment,
  cyberCrime,
  labourRights,
  general, // For Quick Actions entry without specific module
}

/// Represents a single guidance step in the scenario
class GuidanceStep {
  final String title;
  final String description;
  final List<String> points;
  final String icon; // Icon name or asset path

  GuidanceStep({
    required this.title,
    required this.description,
    required this.points,
    required this.icon,
  });
}

/// Represents a complete scenario simulator session
class Scenario {
  final String id;
  final String title;
  final String description;
  final ModuleType moduleType;
  final List<GuidanceStep> guidanceSteps;
  final String chatNavigationRoute; // Route to module-specific chat
  final String? chatScreenName; // Name of chat screen to navigate to

  Scenario({
    required this.id,
    required this.title,
    required this.description,
    required this.moduleType,
    required this.guidanceSteps,
    required this.chatNavigationRoute,
    this.chatScreenName,
  });
}

/// Represents a module's scenario configuration
class ModuleScenarioConfig {
  final ModuleType moduleType;
  final String moduleName;
  final String moduleIcon;
  final List<Scenario> scenarios;
  final String chatScreenPath;

  ModuleScenarioConfig({
    required this.moduleType,
    required this.moduleName,
    required this.moduleIcon,
    required this.scenarios,
    required this.chatScreenPath,
  });

  /// Get default scenario for quick start
  Scenario getDefaultScenario() {
    return scenarios.isNotEmpty ? scenarios[0] : _getEmptyScenario();
  }

  /// Get empty scenario as fallback
  Scenario _getEmptyScenario() {
    return Scenario(
      id: 'empty',
      title: 'Start Chat',
      description: 'Talk to our AI advisor about your $moduleName concerns',
      moduleType: moduleType,
      guidanceSteps: [
        GuidanceStep(
          title: 'Getting Started',
          description: 'Describe your situation and we will provide guidance',
          points: [
            'Provide clear details about your situation',
            'Ask specific questions you need answers to',
            'We will provide legal guidance and next steps',
          ],
          icon: 'assets/icons/help.svg',
        ),
      ],
      chatNavigationRoute: chatScreenPath,
      chatScreenName: 'Chat',
    );
  }
}
