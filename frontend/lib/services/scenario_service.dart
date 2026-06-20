import 'package:flutter/material.dart';
import 'package:front_end/models/scenario_model.dart';
import 'package:front_end/l10n/app_localizations.dart';
/// Service to manage scenario data across all modules
class ScenarioService {
  static final ScenarioService _instance = ScenarioService._internal();

  factory ScenarioService() {
    return _instance;
  }

  ScenarioService._internal();

  /// Get all module scenarios
   Map<ModuleType, ModuleScenarioConfig> getAllModuleScenarios(BuildContext context) {
    return {
      ModuleType.traffic: _getTrafficScenarios(context),
      ModuleType.womenHarassment: _getWomenHarassmentScenarios(context),
      ModuleType.cyberCrime: _getCyberCrimeScenarios(context),
      ModuleType.labourRights: _getLabourRightsScenarios(context),
    };
  }

  /// Get scenarios for a specific module
  ModuleScenarioConfig getModuleScenarios(BuildContext context, ModuleType moduleType) {
    switch (moduleType) {
      case ModuleType.traffic:
        return _getTrafficScenarios(context);
      case ModuleType.womenHarassment:
        return _getWomenHarassmentScenarios(context);
      case ModuleType.cyberCrime:
        return _getCyberCrimeScenarios(context);
      case ModuleType.labourRights:
        return _getLabourRightsScenarios(context);
      case ModuleType.general:
        return _getGeneralScenarios(context);
    }
  }

  /// TRAFFIC & ROAD RULES SCENARIOS
  ModuleScenarioConfig _getTrafficScenarios(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return ModuleScenarioConfig(
      moduleType: ModuleType.traffic,
     moduleName: loc.trafficModuleName,
      moduleIcon: 'assets/icons/traffic.svg',
      chatScreenPath: 'chat_traffic',
      scenarios: [
        Scenario(
          id: 'traffic_1',
          title: loc.traffic1Title,
          description: loc.traffic1Desc,
          moduleType: ModuleType.traffic,
          chatNavigationRoute: 'chat_traffic',
          chatScreenName: 'Traffic Assistant Chat',
          guidanceSteps: [
             GuidanceStep(
              title: loc.traffic1Step1Title,
              description: loc.traffic1Step1Desc,
              points: [
                 loc.traffic1Step1P1,
                loc.traffic1Step1P2,
                loc.traffic1Step1P3,
                loc.traffic1Step1P4,
              ],
              icon: 'assets/icons/info.svg',
            ),
            GuidanceStep(
              title: loc.traffic1Step2Title,
              description: loc.traffic1Step2Desc,
              icon: 'assets/icons/rules.svg',
              points: [
                loc.traffic1Step2P1,
                loc.traffic1Step2P2,
                loc.traffic1Step2P3,
                loc.traffic1Step2P4,
                loc.traffic1Step2P5,
              ],
            
            ),
            GuidanceStep(
              title: loc.traffic1Step3Title,
              description: loc.traffic1Step3Desc,
              icon: 'assets/icons/action.svg',
              points: [
                loc.traffic1Step3P1,
                loc.traffic1Step3P2,
                loc.traffic1Step3P3,
                loc.traffic1Step3P4,
              ],
            ),
          ],
        ),

        Scenario(
          id: 'traffic_2',
          title: loc.traffic2Title,
          description: loc.traffic2Desc,
          moduleType: ModuleType.traffic,
          chatNavigationRoute: 'chat_traffic',
          chatScreenName: loc.trafficChatScreenName,
          guidanceSteps: [
            GuidanceStep(
              title: loc.traffic2Step1Title,
              description: loc.traffic2Step1Desc,
              icon: 'assets/icons/emergency.svg',
              points: [
                loc.traffic2Step1P1,
                loc.traffic2Step1P2,
                loc.traffic2Step1P3,
                loc.traffic2Step1P4,
                loc.traffic2Step1P5,
              ],
            ),
            GuidanceStep(
              title: loc.traffic2Step2Title,
              description: loc.traffic2Step2Desc,
              icon: 'assets/icons/document.svg',
              points: [
                loc.traffic2Step2P1,
                loc.traffic2Step2P2,
                loc.traffic2Step2P3,
                loc.traffic2Step2P4,
                loc.traffic2Step2P5,
              ],
            ),
            GuidanceStep(
              title: loc.traffic2Step3Title,
              description: loc.traffic2Step3Desc,
              icon: 'assets/icons/rights.svg',
              points: [
                loc.traffic2Step3P1,
                loc.traffic2Step3P2,
                loc.traffic2Step3P3,
                loc.traffic2Step3P4,
              ],
            ),
          ],
        ),

        Scenario(
          id: 'traffic_3',
          title: loc.traffic3Title,
          description: loc.traffic3Desc,
          moduleType: ModuleType.traffic,
          chatNavigationRoute: 'chat_traffic',
          chatScreenName: loc.trafficChatScreenName,
          guidanceSteps: [
            GuidanceStep(
              title: loc.traffic3Step1Title,
              description: loc.traffic3Step1Desc,
              icon: 'assets/icons/info.svg',
              points: [
                loc.traffic3Step1P1,
                loc.traffic3Step1P2,
                loc.traffic3Step1P3,
                loc.traffic3Step1P4,
              ],
            ),
            GuidanceStep(
              title: loc.traffic3Step2Title,
              description: loc.traffic3Step2Desc,
              icon: 'assets/icons/appeal.svg',
              points: [
                loc.traffic3Step2P1,
                loc.traffic3Step2P2,
                loc.traffic3Step2P3,
                loc.traffic3Step2P4,
              ],
            ),
            GuidanceStep(
              title: loc.traffic3Step3Title,
              description: loc.traffic3Step3Desc,
              icon: 'assets/icons/action.svg',
              points: [
                loc.traffic3Step3P1,
                loc.traffic3Step3P2,
                loc.traffic3Step3P3,
                loc.traffic3Step3P4,
              ],
             
            ),
          ],
        ),
      ],
    );
  }

  /// WOMEN HARASSMENT SCENARIOS
  ModuleScenarioConfig _getWomenHarassmentScenarios(BuildContext context) {
  final loc = AppLocalizations.of(context)!;

  return ModuleScenarioConfig(
    moduleType: ModuleType.womenHarassment,
    moduleName: loc.womenModuleName,
    moduleIcon: 'assets/icons/women.svg',
    chatScreenPath: 'chat_women_harassment',
    scenarios: [
      Scenario(
        id: 'women_1',
        title: loc.women1Title,
        description: loc.women1Desc,
        moduleType: ModuleType.womenHarassment,
        chatNavigationRoute: 'chat_women_harassment',
        chatScreenName: loc.womenChatName,
        guidanceSteps: [
            GuidanceStep(
            title: loc.women1Step1Title,
            description: loc.women1Step1Desc,
            icon: 'assets/icons/rights.svg',
            points: [
              loc.women1Step1P1,
              loc.women1Step1P2,
              loc.women1Step1P3,
              loc.women1Step1P4,
            ],
          ),
          GuidanceStep(
            title: loc.women1Step2Title,
            description: loc.women1Step2Desc,
            icon: 'assets/icons/action.svg',
            points: [
              loc.women1Step2P1,
              loc.women1Step2P2,
              loc.women1Step2P3,
              loc.women1Step2P4,
              loc.women1Step2P5,
              loc.women1Step2P6,
            ],
            ),
             GuidanceStep(
            title: loc.women1Step3Title,
            description: loc.women1Step3Desc,
            icon: 'assets/icons/process.svg',
            points: [
              loc.women1Step3P1,
              loc.women1Step3P2,
              loc.women1Step3P3,
              loc.women1Step3P4,
              loc.women1Step3P5,]
            ),
          ],
        ),
        Scenario(
        id: 'women_2',
        title: loc.women2Title,
        description: loc.women2Desc,
        moduleType: ModuleType.womenHarassment,
        chatNavigationRoute: 'chat_women_harassment',
        chatScreenName: loc.womenChatName,
        guidanceSteps: [
          GuidanceStep(
            title: loc.women2Step1Title,
            description: loc.women2Step1Desc,
            icon: 'assets/icons/law.svg',
            points: [
              loc.women2Step1P1,
              loc.women2Step1P2,
              loc.women2Step1P3,
              loc.women2Step1P4,
              ],
             
            ),
            GuidanceStep(
            title: loc.women2Step2Title,
            description: loc.women2Step2Desc,
            icon: 'assets/icons/safety.svg',
            points: [
              loc.women2Step2P1,
              loc.women2Step2P2,
              loc.women2Step2P3,
              loc.women2Step2P4,
              loc.women2Step2P5,
              loc.women2Step2P6,
            ],
          ),
          GuidanceStep(
            title: loc.women2Step3Title,
            description: loc.women2Step3Desc,
            icon: 'assets/icons/police.svg',
            points: [
              loc.women2Step3P1,
              loc.women2Step3P2,
              loc.women2Step3P3,
              loc.women2Step3P4,
              loc.women2Step3P5,
            ],
            ),
          ],
        ),
        Scenario(
        id: 'women_3',
        title: loc.women3Title,
        description: loc.women3Desc,
        moduleType: ModuleType.womenHarassment,
        chatNavigationRoute: 'chat_women_harassment',
        chatScreenName: loc.womenChatName,
        guidanceSteps: [
          GuidanceStep(
            title: loc.women3Step1Title,
            description: loc.women3Step1Desc,
            icon: 'assets/icons/support.svg',
            points: [
              loc.women3Step1P1,
              loc.women3Step1P2,
              loc.women3Step1P3,
              loc.women3Step1P4,
            ],
            ),
            GuidanceStep(
            title: loc.women3Step2Title,
            description: loc.women3Step2Desc,
            icon: 'assets/icons/safety.svg',
            points: [
              loc.women3Step2P1,
              loc.women3Step2P2,
              loc.women3Step2P3,
              loc.women3Step2P4,
              loc.women3Step2P5,
              loc.women3Step2P6,
            ],
          ),
          GuidanceStep(
            title: loc.women3Step3Title,
            description: loc.women3Step3Desc,
            icon: 'assets/icons/justice.svg',
            points: [
              loc.women3Step3P1,
              loc.women3Step3P2,
              loc.women3Step3P3,
              loc.women3Step3P4,
              loc.women3Step3P5,]
            ),
          ],
        ),
      ],
    );
  }

  /// CYBER CRIME SCENARIOS
  ModuleScenarioConfig _getCyberCrimeScenarios(BuildContext context) {
  final loc = AppLocalizations.of(context)!;

  return ModuleScenarioConfig(
    moduleType: ModuleType.cyberCrime,
    moduleName: loc.cyberModuleName,
    moduleIcon: 'assets/icons/cyber.svg',
    chatScreenPath: 'chat_cyber_crime',
    scenarios: [
      Scenario(
        id: 'cyber_1',
        title: loc.cyber1Title,
        description: loc.cyber1Desc,
        moduleType: ModuleType.cyberCrime,
        chatNavigationRoute: 'chat_cyber_crime',
        chatScreenName: loc.cyberChatName,
        guidanceSteps: [
          GuidanceStep(
            title: loc.cyber1Step1Title,
            description: loc.cyber1Step1Desc,
            icon: 'assets/icons/emergency.svg',
            points: [
              loc.cyber1Step1P1,
              loc.cyber1Step1P2,
              loc.cyber1Step1P3,
              loc.cyber1Step1P4,
              loc.cyber1Step1P5,
            ],
          ),
          GuidanceStep(
            title: loc.cyber1Step2Title,
            description: loc.cyber1Step2Desc,
            icon: 'assets/icons/crime.svg',
            points: [
              loc.cyber1Step2P1,
              loc.cyber1Step2P2,
              loc.cyber1Step2P3,
              loc.cyber1Step2P4,
              loc.cyber1Step2P5,
            ],
          ),
          GuidanceStep(
            title: loc.cyber1Step3Title,
            description: loc.cyber1Step3Desc,
            icon: 'assets/icons/process.svg',
            points: [
              loc.cyber1Step3P1,
              loc.cyber1Step3P2,
              loc.cyber1Step3P3,
              loc.cyber1Step3P4,
              loc.cyber1Step3P5,
            ],
          ),
        ],
      ),

      Scenario(
        id: 'cyber_2',
        title: loc.cyber2Title,
        description: loc.cyber2Desc,
        moduleType: ModuleType.cyberCrime,
        chatNavigationRoute: 'chat_cyber_crime',
        chatScreenName: loc.cyberChatName,
        guidanceSteps: [
          GuidanceStep(
            title: loc.cyber2Step1Title,
            description: loc.cyber2Step1Desc,
            icon: 'assets/icons/rights.svg',
            points: [
              loc.cyber2Step1P1,
              loc.cyber2Step1P2,
              loc.cyber2Step1P3,
              loc.cyber2Step1P4,
              loc.cyber2Step1P5,
            ],
          ),
          GuidanceStep(
            title: loc.cyber2Step2Title,
            description: loc.cyber2Step2Desc,
            icon: 'assets/icons/action.svg',
            points: [
              loc.cyber2Step2P1,
              loc.cyber2Step2P2,
              loc.cyber2Step2P3,
              loc.cyber2Step2P4,
              loc.cyber2Step2P5,
              loc.cyber2Step2P6,
            ],
          ),
          GuidanceStep(
            title: loc.cyber2Step3Title,
            description: loc.cyber2Step3Desc,
            icon: 'assets/icons/justice.svg',
            points: [
              loc.cyber2Step3P1,
              loc.cyber2Step3P2,
              loc.cyber2Step3P3,
              loc.cyber2Step3P4,
              loc.cyber2Step3P5,
            ],
          ),
        ],
      ),

      Scenario(
        id: 'cyber_3',
        title: loc.cyber3Title,
        description: loc.cyber3Desc,
        moduleType: ModuleType.cyberCrime,
        chatNavigationRoute: 'chat_cyber_crime',
        chatScreenName: loc.cyberChatName,
        guidanceSteps: [
          GuidanceStep(
            title: loc.cyber3Step1Title,
            description: loc.cyber3Step1Desc,
            icon: 'assets/icons/security.svg',
            points: [
              loc.cyber3Step1P1,
              loc.cyber3Step1P2,
              loc.cyber3Step1P3,
              loc.cyber3Step1P4,
              loc.cyber3Step1P5,
            ],
          ),
          GuidanceStep(
            title: loc.cyber3Step2Title,
            description: loc.cyber3Step2Desc,
            icon: 'assets/icons/assessment.svg',
            points: [
              loc.cyber3Step2P1,
              loc.cyber3Step2P2,
              loc.cyber3Step2P3,
              loc.cyber3Step2P4,
              loc.cyber3Step2P5,
            ],
          ),
          GuidanceStep(
            title: loc.cyber3Step3Title,
            description: loc.cyber3Step3Desc,
            icon: 'assets/icons/justice.svg',
            points: [
              loc.cyber3Step3P1,
              loc.cyber3Step3P2,
              loc.cyber3Step3P3,
              loc.cyber3Step3P4,
              loc.cyber3Step3P5,]
            ),
          ],
        ),
      ],
    );
  }

  /// LABOUR RIGHTS SCENARIOS
  ModuleScenarioConfig _getLabourRightsScenarios(BuildContext context) {
  final loc = AppLocalizations.of(context)!;

  return ModuleScenarioConfig(
    moduleType: ModuleType.labourRights,
    moduleName: loc.labourModuleName,
    moduleIcon: 'assets/icons/labour.svg',
    chatScreenPath: 'chat_labour_rights',
    scenarios: [
        Scenario(
        id: 'labour_1',
        title: loc.labour1Title,
        description: loc.labour1Desc,
        moduleType: ModuleType.labourRights,
        chatNavigationRoute: 'chat_labour_rights',
        chatScreenName: loc.labourChatName,
        guidanceSteps: [
          GuidanceStep(
            title: loc.labour1Step1Title,
            description: loc.labour1Step1Desc,
            icon: 'assets/icons/rights.svg',
            points: [
              loc.labour1Step1P1,
              loc.labour1Step1P2,
              loc.labour1Step1P3,
              loc.labour1Step1P4,
              loc.labour1Step1P5,
            ],
          ),
          GuidanceStep(
            title: loc.labour1Step2Title,
            description: loc.labour1Step2Desc,
            icon: 'assets/icons/document.svg',
            points: [
              loc.labour1Step2P1,
              loc.labour1Step2P2,
              loc.labour1Step2P3,
              loc.labour1Step2P4,
              loc.labour1Step2P5,
              loc.labour1Step2P6,
            ],
          ),
          GuidanceStep(
            title: loc.labour1Step3Title,
            description: loc.labour1Step3Desc,
            icon: 'assets/icons/process.svg',
            points: [
              loc.labour1Step3P1,
              loc.labour1Step3P2,
              loc.labour1Step3P3,
              loc.labour1Step3P4,
              loc.labour1Step3P5,
            ],
            ),
          ],
        ),
        Scenario(
        id: 'labour_2',
        title: loc.labour2Title,
        description: loc.labour2Desc,
        moduleType: ModuleType.labourRights,
        chatNavigationRoute: 'chat_labour_rights',
        chatScreenName: loc.labourChatName,
        guidanceSteps: [
          GuidanceStep(
            title: loc.labour2Step1Title,
            description: loc.labour2Step1Desc,
            icon: 'assets/icons/money.svg',
            points: [
              loc.labour2Step1P1,
              loc.labour2Step1P2,
              loc.labour2Step1P3,
              loc.labour2Step1P4,
              loc.labour2Step1P5,
            ],
          ),
          GuidanceStep(
            title: loc.labour2Step2Title,
            description: loc.labour2Step2Desc,
            icon: 'assets/icons/action.svg',
            points: [
              loc.labour2Step2P1,
              loc.labour2Step2P2,
              loc.labour2Step2P3,
              loc.labour2Step2P4,
              loc.labour2Step2P5,
              loc.labour2Step2P6,
            ],
          ),
          GuidanceStep(
            title: loc.labour2Step3Title,
            description: loc.labour2Step3Desc,
            icon: 'assets/icons/legal.svg',
            points: [
              loc.labour2Step3P1,
              loc.labour2Step3P2,
              loc.labour2Step3P3,
              loc.labour2Step3P4,
              loc.labour2Step3P5,
            ],
            ),
          ],
        ),
        Scenario(
        id: 'labour_3',
        title: loc.labour3Title,
        description: loc.labour3Desc,
        moduleType: ModuleType.labourRights,
        chatNavigationRoute: 'chat_labour_rights',
        chatScreenName: loc.labourChatName,
        guidanceSteps: [
          GuidanceStep(
            title: loc.labour3Step1Title,
            description: loc.labour3Step1Desc,
            icon: 'assets/icons/rights.svg',
            points: [
              loc.labour3Step1P1,
              loc.labour3Step1P2,
              loc.labour3Step1P3,
              loc.labour3Step1P4,
              loc.labour3Step1P5,
            ],
          ),
          GuidanceStep(
            title: loc.labour3Step2Title,
            description: loc.labour3Step2Desc,
            icon: 'assets/icons/emergency.svg',
            points: [
              loc.labour3Step2P1,
              loc.labour3Step2P2,
              loc.labour3Step2P3,
              loc.labour3Step2P4,
              loc.labour3Step2P5,
              loc.labour3Step2P6,
            ],
          ),
          GuidanceStep(
            title: loc.labour3Step3Title,
            description: loc.labour3Step3Desc,
            icon: 'assets/icons/claim.svg',
            points: [
              loc.labour3Step3P1,
              loc.labour3Step3P2,
              loc.labour3Step3P3,
              loc.labour3Step3P4,
              loc.labour3Step3P5,
            ],
            ),
          ],
        ),
      ],
    );
  }

  /// GENERAL SCENARIOS (FOR QUICK ACTIONS)
  ModuleScenarioConfig _getGeneralScenarios(BuildContext context) {
  final loc = AppLocalizations.of(context)!;

  return ModuleScenarioConfig(
    moduleType: ModuleType.general,
    moduleName: loc.generalModuleName,
    moduleIcon: 'assets/icons/legal.svg',
    chatScreenPath: 'home',
    scenarios: [
      Scenario(
        id: 'general_1',
        title: loc.general1Title,
        description: loc.general1Desc,
        moduleType: ModuleType.general,
        chatNavigationRoute: 'home',
        chatScreenName: loc.generalChatName,
        guidanceSteps: [
          GuidanceStep(
            title: loc.general1Step1Title,
            description: loc.general1Step1Desc,
            icon: 'assets/icons/help.svg',
            points: [
              loc.general1Step1P1,
              loc.general1Step1P2,
              loc.general1Step1P3,
              loc.general1Step1P4,
              loc.general1Step1P5,
            ],
          ),
          GuidanceStep(
            title: loc.general1Step2Title,
            description: loc.general1Step2Desc,
            icon: 'assets/icons/category.svg',
            points: [
              loc.general1Step2P1,
              loc.general1Step2P2,
              loc.general1Step2P3,
              loc.general1Step2P4,
            ],
          ),
          GuidanceStep(
            title: loc.general1Step3Title,
            description: loc.general1Step3Desc,
            icon: 'assets/icons/guide.svg',
            points: [
              loc.general1Step3P1,
              loc.general1Step3P2,
              loc.general1Step3P3,
              loc.general1Step3P4,
              loc.general1Step3P5,
            ],
          ),
        ],
      ),
    ],
  );
  }
  }