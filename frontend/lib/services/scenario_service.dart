import 'package:front_end/models/scenario_model.dart';

/// Service to manage scenario data across all modules
class ScenarioService {
  static final ScenarioService _instance = ScenarioService._internal();

  factory ScenarioService() {
    return _instance;
  }

  ScenarioService._internal();

  /// Get all module scenarios
  Map<ModuleType, ModuleScenarioConfig> getAllModuleScenarios() {
    return {
      ModuleType.traffic: _getTrafficScenarios(),
      ModuleType.womenHarassment: _getWomenHarassmentScenarios(),
      ModuleType.cyberCrime: _getCyberCrimeScenarios(),
      ModuleType.labourRights: _getLabourRightsScenarios(),
    };
  }

  /// Get scenarios for a specific module
  ModuleScenarioConfig getModuleScenarios(ModuleType moduleType) {
    switch (moduleType) {
      case ModuleType.traffic:
        return _getTrafficScenarios();
      case ModuleType.womenHarassment:
        return _getWomenHarassmentScenarios();
      case ModuleType.cyberCrime:
        return _getCyberCrimeScenarios();
      case ModuleType.labourRights:
        return _getLabourRightsScenarios();
      case ModuleType.general:
        return _getGeneralScenarios();
    }
  }

  /// TRAFFIC & ROAD RULES SCENARIOS
  ModuleScenarioConfig _getTrafficScenarios() {
    return ModuleScenarioConfig(
      moduleType: ModuleType.traffic,
      moduleName: 'Road & Traffic Law',
      moduleIcon: 'assets/icons/traffic.svg',
      chatScreenPath: 'chat_traffic',
      scenarios: [
        Scenario(
          id: 'traffic_1',
          title: 'Traffic Violation Fine',
          description: 'You received a traffic ticket or penalty challan',
          moduleType: ModuleType.traffic,
          chatNavigationRoute: 'chat_traffic',
          chatScreenName: 'Traffic Assistant Chat',
          guidanceSteps: [
            GuidanceStep(
              title: 'Understanding Your Violation',
              description:
                  'Know what violation you committed and the legal implications',
              points: [
                'Check the violation code on your challan',
                'Understand the section under which you were fined (Motor Vehicles Act)',
                'Know the fine amount and deadline for payment',
                'Learn about your right to appeal',
              ],
              icon: 'assets/icons/info.svg',
            ),
            GuidanceStep(
              title: 'Do\'s & Don\'ts',
              description: 'Important steps to follow',
              points: [
                '✓ DO pay the fine on time to avoid additional penalties',
                '✓ DO keep your receipt and violation notice for records',
                '✓ DO appeal if you believe the violation is unfair',
                '✗ DON\'T ignore the challan - it may result in suspension',
                '✗ DON\'T try to bribe traffic officers - it\'s illegal',
              ],
              icon: 'assets/icons/rules.svg',
            ),
            GuidanceStep(
              title: 'Immediate Actions',
              description: 'Steps to take right now',
              points: [
                'Pay the fine within the deadline',
                'If appealing, file a case in traffic court within specified period',
                'Collect all evidence (documents, witnesses)',
                'Contact a traffic lawyer if needed',
              ],
              icon: 'assets/icons/action.svg',
            ),
          ],
        ),
        Scenario(
          id: 'traffic_2',
          title: 'Traffic Accident Dispute',
          description:
              'You were involved in a traffic accident and need guidance',
          moduleType: ModuleType.traffic,
          chatNavigationRoute: 'chat_traffic',
          chatScreenName: 'Traffic Assistant Chat',
          guidanceSteps: [
            GuidanceStep(
              title: 'At the Scene of Accident',
              description: 'What to do immediately after the accident',
              points: [
                'Move to a safe location if possible',
                'Alert other traffic using hazard lights',
                'Call police (100 or traffic helpline)',
                'Do not admit fault or sign any documents',
                'Gather witness information and take photos',
              ],
              icon: 'assets/icons/emergency.svg',
            ),
            GuidanceStep(
              title: 'Documentation Required',
              description: 'Collect these documents for your protection',
              points: [
                'Police report (FIR) number',
                'Insurance policy details',
                'Photographs of vehicles and accident site',
                'Medical certificates if injured',
                'Witness contacts and statements',
              ],
              icon: 'assets/icons/document.svg',
            ),
            GuidanceStep(
              title: 'Legal Rights & Claims',
              description: 'Know your compensation options',
              points: [
                'File motor accident claim within 6 months',
                'Get vehicle assessment done by insurance surveyor',
                'Claim medical expenses and loss of earnings',
                'Know your right to sue for damages',
              ],
              icon: 'assets/icons/rights.svg',
            ),
          ],
        ),
        Scenario(
          id: 'traffic_3',
          title: 'License Suspension/Cancellation',
          description: 'Your driving license is suspended or cancelled',
          moduleType: ModuleType.traffic,
          chatNavigationRoute: 'chat_traffic',
          chatScreenName: 'Traffic Assistant Chat',
          guidanceSteps: [
            GuidanceStep(
              title: 'Understanding Suspension vs Cancellation',
              description: 'Know the difference and implications',
              points: [
                'Suspension: Temporary - license paused for fixed period',
                'Cancellation: Permanent - license revoked',
                'Reasons: Traffic violations, medical grounds, age',
                'Your driving during suspension is illegal',
              ],
              icon: 'assets/icons/info.svg',
            ),
            GuidanceStep(
              title: 'Appeal Process',
              description: 'How to challenge the action',
              points: [
                'File appeal in Regional Transport Authority (RTA) office',
                'Timeline: Within 30 days of notice',
                'Gather evidence to support your case',
                'Attend hearing and present your case',
              ],
              icon: 'assets/icons/appeal.svg',
            ),
            GuidanceStep(
              title: 'Recovery Steps',
              description: 'Steps to get your license restored',
              points: [
                'Complete suspension period',
                'Pass refresher test if required',
                'Pay fees and submit renewal application',
                'Collect renewed license from RTA',
              ],
              icon: 'assets/icons/action.svg',
            ),
          ],
        ),
      ],
    );
  }

  /// WOMEN HARASSMENT SCENARIOS
  ModuleScenarioConfig _getWomenHarassmentScenarios() {
    return ModuleScenarioConfig(
      moduleType: ModuleType.womenHarassment,
      moduleName: 'Women Harassment',
      moduleIcon: 'assets/icons/women.svg',
      chatScreenPath: 'chat_women_harassment',
      scenarios: [
        Scenario(
          id: 'women_1',
          title: 'Workplace Sexual Harassment',
          description: 'You experienced harassment at your workplace',
          moduleType: ModuleType.womenHarassment,
          chatNavigationRoute: 'chat_women_harassment',
          chatScreenName: 'Women Harassment Assistant Chat',
          guidanceSteps: [
            GuidanceStep(
              title: 'Understand Your Rights',
              description: 'Know the legal protections available to you',
              points: [
                'Sexual Harassment of Women at Workplace Act protects you',
                'Harassment includes unwanted advances, comments, or touching',
                'Your employer must provide a safe work environment',
                'You have the right to complain without fear of retaliation',
              ],
              icon: 'assets/icons/rights.svg',
            ),
            GuidanceStep(
              title: 'Immediate Actions',
              description: 'What to do when harassment occurs',
              points: [
                '✓ Say "NO" clearly and firmly to unwanted behavior',
                '✓ Document incidents with dates, times, and witnesses',
                '✓ Inform the harasser in writing that their behavior is unwelcome',
                '✓ Report to HR or Internal Complaints Committee (ICC)',
                '✓ Keep copies of all communications',
                '✗ DON\'T delay reporting - report immediately',
              ],
              icon: 'assets/icons/action.svg',
            ),
            GuidanceStep(
              title: 'Complaint & Investigation',
              description: 'The formal complaint process',
              points: [
                'File complaint with ICC or HR within specified period',
                'Provide written statement with evidence',
                'Company must investigate within 90 days',
                'You have protection against retaliation',
                'Keep records of entire process',
              ],
              icon: 'assets/icons/process.svg',
            ),
          ],
        ),
        Scenario(
          id: 'women_2',
          title: 'Street Sexual Harassment',
          description: 'You faced harassment or misbehavior in public',
          moduleType: ModuleType.womenHarassment,
          chatNavigationRoute: 'chat_women_harassment',
          chatScreenName: 'Women Harassment Assistant Chat',
          guidanceSteps: [
            GuidanceStep(
              title: 'Understanding the Law',
              description: 'Legal protections for street harassment',
              points: [
                'Indecent Assault is a criminal offense',
                'Eve-teasing and stalking are punishable offenses',
                'You can file FIR with any police station',
                'You are protected under Section 354 IPC',
              ],
              icon: 'assets/icons/law.svg',
            ),
            GuidanceStep(
              title: 'Safety First - In the Moment',
              description: 'How to respond immediately',
              points: [
                '✓ Move to a crowded/safe area immediately',
                '✓ Call 100 (Police emergency) or Women Safety helpline',
                '✓ Tell nearby people what\'s happening',
                '✓ Try to remember description of harasser',
                '✓ Seek medical help if injured',
                '✗ DON\'T confront alone or engage in argument',
              ],
              icon: 'assets/icons/safety.svg',
            ),
            GuidanceStep(
              title: 'Filing a Police Report',
              description: 'Steps to lodge an FIR',
              points: [
                'Go to nearest police station with a witness if possible',
                'File FIR mentioning specific details and date/time',
                'Medical examination if physical contact occurred',
                'Get FIR copy for your records',
                'Follow up on case progress regularly',
              ],
              icon: 'assets/icons/police.svg',
            ),
          ],
        ),
        Scenario(
          id: 'women_3',
          title: 'Domestic Violence',
          description: 'You are experiencing abuse at home',
          moduleType: ModuleType.womenHarassment,
          chatNavigationRoute: 'chat_women_harassment',
          chatScreenName: 'Women Harassment Assistant Chat',
          guidanceSteps: [
            GuidanceStep(
              title: 'You Are Not Alone',
              description: 'Know your rights and available support',
              points: [
                'Domestic violence is a serious crime',
                'Protection of Women from Domestic Violence Act provides support',
                'You can get protection orders without filing FIR',
                'Multiple support systems available (legal, medical, shelter)',
              ],
              icon: 'assets/icons/support.svg',
            ),
            GuidanceStep(
              title: 'Safety Planning',
              description: 'Protect yourself and document abuse',
              points: [
                '✓ Keep important documents in safe place',
                '✓ Have emergency contacts saved (helpline, friend, family)',
                '✓ Document injuries with photos and date',
                '✓ Keep records of violence incidents',
                '✓ Know shelter locations in your area',
                '✗ DON\'T minimize the abuse or blame yourself',
              ],
              icon: 'assets/icons/safety.svg',
            ),
            GuidanceStep(
              title: 'Legal Options',
              description: 'Steps to seek justice and safety',
              points: [
                'File FIR for criminal case',
                'Apply for Protection Order in Family Court',
                'Seek medical examination and documentation',
                'Contact domestic violence helpline for support',
                'Legal aid available if you cannot afford lawyer',
              ],
              icon: 'assets/icons/justice.svg',
            ),
          ],
        ),
      ],
    );
  }

  /// CYBER CRIME SCENARIOS
  ModuleScenarioConfig _getCyberCrimeScenarios() {
    return ModuleScenarioConfig(
      moduleType: ModuleType.cyberCrime,
      moduleName: 'Cyber Crime',
      moduleIcon: 'assets/icons/cyber.svg',
      chatScreenPath: 'chat_cyber_crime',
      scenarios: [
        Scenario(
          id: 'cyber_1',
          title: 'Online Financial Fraud',
          description: 'You lost money due to online scam or fraud',
          moduleType: ModuleType.cyberCrime,
          chatNavigationRoute: 'chat_cyber_crime',
          chatScreenName: 'Cyber Crime Assistant Chat',
          guidanceSteps: [
            GuidanceStep(
              title: 'Immediate Actions',
              description: 'Act quickly to minimize loss',
              points: [
                'Block compromised accounts immediately',
                'Change all passwords (email, banking, social media)',
                'Contact your bank and block credit/debit cards',
                'Check bank statements for unauthorized transactions',
                'Apply for fraud alert with credit bureau',
              ],
              icon: 'assets/icons/emergency.svg',
            ),
            GuidanceStep(
              title: 'Know the Crime',
              description: 'Understand what happened legally',
              points: [
                'Online banking fraud is Section 420 IPC',
                'Identity theft is Section 66C of IT Act',
                'Phishing and spoofing are also criminal offenses',
                'You can file FIR with cyber crime unit',
                'Your bank may also file complaint on your behalf',
              ],
              icon: 'assets/icons/crime.svg',
            ),
            GuidanceStep(
              title: 'Recovery & Legal Steps',
              description: 'What you can do to recover and prosecute',
              points: [
                'File FIR at local cyber crime police station',
                'Provide all transaction records and evidence',
                'Chase with bank for chargeback/reversal',
                'Register with RBI\'s cybercrime cell',
                'Consider civil suit for damages if needed',
              ],
              icon: 'assets/icons/process.svg',
            ),
          ],
        ),
        Scenario(
          id: 'cyber_2',
          title: 'Revenge Porn / Intimate Image Abuse',
          description: 'Your private images are shared without consent online',
          moduleType: ModuleType.cyberCrime,
          chatNavigationRoute: 'chat_cyber_crime',
          chatScreenName: 'Cyber Crime Assistant Chat',
          guidanceSteps: [
            GuidanceStep(
              title: 'Know Your Rights',
              description: 'Legal protections against image abuse',
              points: [
                'Sharing intimate images without consent is criminal',
                'Section 354D IPC (Stalking) covers this',
                'Section 67A IT Act provides additional protection',
                'POCSO Act applies if minor is involved',
                'Criminal AND civil remedies available',
              ],
              icon: 'assets/icons/rights.svg',
            ),
            GuidanceStep(
              title: 'Immediate Response',
              description: 'Act fast to contain the spread',
              points: [
                '✓ Report immediately to platform where image is shared',
                '✓ Use platform\'s "report non-consensual intimate image" option',
                '✓ Take screenshots of posts with timestamps',
                '✓ Document URLs and usernames',
                '✓ Tell trusted friends about situation for support',
                '✗ DON\'T try to contact harasser yourself',
                '✗ DON\'T spread more images trying to retrieve them',
              ],
              icon: 'assets/icons/action.svg',
            ),
            GuidanceStep(
              title: 'Legal Recourse',
              description: 'Criminal and civil options',
              points: [
                'File FIR with cyber crime police immediately',
                'File complaint with social media platform',
                'File complaint with NCW (National Commission for Women)',
                'Request platform to remove content',
                'Consider civil suit for damages and injunction',
              ],
              icon: 'assets/icons/justice.svg',
            ),
          ],
        ),
        Scenario(
          id: 'cyber_3',
          title: 'Account Hacking / Identity Theft',
          description: 'Your email or social media account was hacked',
          moduleType: ModuleType.cyberCrime,
          chatNavigationRoute: 'chat_cyber_crime',
          chatScreenName: 'Cyber Crime Assistant Chat',
          guidanceSteps: [
            GuidanceStep(
              title: 'Securing Your Accounts',
              description: 'Steps to regain control',
              points: [
                'Use recovery email/phone to regain account access',
                'Change password immediately',
                'Enable two-factor authentication',
                'Check account activity history',
                'Remove suspicious connected apps',
              ],
              icon: 'assets/icons/security.svg',
            ),
            GuidanceStep(
              title: 'Damage Assessment',
              description: 'Check what was done with your account',
              points: [
                '✓ Check sent emails/messages to identify scams',
                '✓ Look for unauthorized purchases or money transfers',
                '✓ Check if personal information was changed',
                '✓ Monitor linked financial accounts',
                '✓ Notify contacts who received messages from your account',
              ],
              icon: 'assets/icons/assessment.svg',
            ),
            GuidanceStep(
              title: 'Legal Action',
              description: 'File police complaint and protect yourself',
              points: [
                'File FIR with cyber crime unit',
                'Report to social media company\'s safety team',
                'Document all evidence of hacking',
                'Monitor for identity theft (credit reports)',
                'Consider hiring cybersecurity expert for investigation',
              ],
              icon: 'assets/icons/justice.svg',
            ),
          ],
        ),
      ],
    );
  }

  /// LABOUR RIGHTS SCENARIOS
  ModuleScenarioConfig _getLabourRightsScenarios() {
    return ModuleScenarioConfig(
      moduleType: ModuleType.labourRights,
      moduleName: 'Labour Rights',
      moduleIcon: 'assets/icons/labour.svg',
      chatScreenPath: 'chat_labour_rights',
      scenarios: [
        Scenario(
          id: 'labour_1',
          title: 'Unfair Dismissal',
          description: 'You were fired without proper notice or compensation',
          moduleType: ModuleType.labourRights,
          chatNavigationRoute: 'chat_labour_rights',
          chatScreenName: 'Labour Rights Assistant Chat',
          guidanceSteps: [
            GuidanceStep(
              title: 'Understanding Your Rights',
              description: 'Employer cannot fire you arbitrarily',
              points: [
                'Industrial Disputes Act (1947) protects workers',
                'Employer must provide valid reason for termination',
                'You must be given written notice and opportunity to respond',
                'Wrongful termination is punishable by law',
                'You have right to compensation and reinstatement',
              ],
              icon: 'assets/icons/rights.svg',
            ),
            GuidanceStep(
              title: 'Immediate Documentation',
              description: 'Collect evidence right away',
              points: [
                '✓ Keep a copy of termination letter',
                '✓ Document details of dismissal (date, time, witnesses)',
                '✓ Collect all salary slips and employment documents',
                '✓ Note any performance reviews and communication',
                '✓ Gather witness statements from colleagues',
                '✓ Keep all company policy documents',
              ],
              icon: 'assets/icons/document.svg',
            ),
            GuidanceStep(
              title: 'Legal Steps',
              description: 'How to seek remedy',
              points: [
                'File complaint with Labour Commissioner/Department',
                'File claim for unpaid wages, notice pay, severance',
                'Seek reinstatement or compensation',
                'File before Industrial Tribunal if needed',
                'Free legal aid available if you cannot afford lawyer',
              ],
              icon: 'assets/icons/process.svg',
            ),
          ],
        ),
        Scenario(
          id: 'labour_2',
          title: 'Non-payment of Wages',
          description: 'Your employer is not paying your salary',
          moduleType: ModuleType.labourRights,
          chatNavigationRoute: 'chat_labour_rights',
          chatScreenName: 'Labour Rights Assistant Chat',
          guidanceSteps: [
            GuidanceStep(
              title: 'Know Your Entitlement',
              description: 'What you must legally be paid',
              points: [
                'Minimum wage as per state law is mandatory',
                'Wages must be paid on time (on agreed date)',
                'You cannot be deducted without valid reason',
                'Deductions must be for specific purposes only',
                'Unpaid wages + penalty interest recoverable',
              ],
              icon: 'assets/icons/money.svg',
            ),
            GuidanceStep(
              title: 'Immediate Steps',
              description: 'Act immediately',
              points: [
                '✓ Send formal written demand for payment with deadline',
                '✓ Keep records of all communication with employer',
                '✓ Document work hours and dates worked',
                '✓ Calculate total pending amount accurately',
                '✓ Keep bank statements showing payment failures',
                '✗ DON\'T accept verbal promises - get in writing',
              ],
              icon: 'assets/icons/action.svg',
            ),
            GuidanceStep(
              title: 'Filing Complaint',
              description: 'Formal legal action',
              points: [
                'File complaint with Labour Department/Commissioner',
                'File case in Labour Court for recovery',
                'Include all unpaid salary + damages',
                'Complaint free under Payment of Wages Act',
                'Company must appear and explain non-payment',
              ],
              icon: 'assets/icons/legal.svg',
            ),
          ],
        ),
        Scenario(
          id: 'labour_3',
          title: 'Workplace Injury / Accident',
          description: 'You were injured at work and need compensation',
          moduleType: ModuleType.labourRights,
          chatNavigationRoute: 'chat_labour_rights',
          chatScreenName: 'Labour Rights Assistant Chat',
          guidanceSteps: [
            GuidanceStep(
              title: 'Your Rights After Injury',
              description: 'Compensation and care you deserve',
              points: [
                'Employer liable for workplace injuries (Workmen\'s Compensation Act)',
                'You entitled to medical expenses coverage',
                'You entitled to disability/partial disability compensation',
                'You entitled to lost wages during recovery',
                'In fatal cases, family entitled to compensation',
              ],
              icon: 'assets/icons/rights.svg',
            ),
            GuidanceStep(
              title: 'Immediate Actions',
              description: 'Do this right after injury',
              points: [
                '✓ Report injury to employer immediately',
                '✓ Get written acknowledgment of incident',
                '✓ Seek immediate medical treatment',
                '✓ Take photos of injury and accident site',
                '✓ Get witness statements from colleagues',
                '✓ Keep all medical bills and receipts',
                '✗ DON\'T sign any settlement without consulting lawyer',
              ],
              icon: 'assets/icons/emergency.svg',
            ),
            GuidanceStep(
              title: 'Claiming Compensation',
              description: 'Steps to receive compensation',
              points: [
                'File claim with Workmen\'s Compensation Commissioner',
                'Attach medical reports and accident evidence',
                'Claim unpaid wages during recovery period',
                'Claim permanent disability compensation if applicable',
                'Employer must present insurance certificate',
              ],
              icon: 'assets/icons/claim.svg',
            ),
          ],
        ),
      ],
    );
  }

  /// GENERAL SCENARIOS (FOR QUICK ACTIONS)
  ModuleScenarioConfig _getGeneralScenarios() {
    return ModuleScenarioConfig(
      moduleType: ModuleType.general,
      moduleName: 'Legal Guidance',
      moduleIcon: 'assets/icons/legal.svg',
      chatScreenPath: 'home', // Navigate back to home to select module
      scenarios: [
        Scenario(
          id: 'general_1',
          title: 'Choose Your Concern',
          description: 'Let AI guide you through legal scenarios',
          moduleType: ModuleType.general,
          chatNavigationRoute: 'home',
          chatScreenName: 'Legal Advisor',
          guidanceSteps: [
            GuidanceStep(
              title: 'Welcome to AI Legal Advisor',
              description: 'Get legal guidance for your specific situation',
              points: [
                'Describe your legal concern in your own words',
                'AI will ask clarifying questions to understand better',
                'Get relevant legal information and next steps',
                'Receive guidance based on Indian laws',
                'All actions happen within the app',
              ],
              icon: 'assets/icons/help.svg',
            ),
            GuidanceStep(
              title: 'What You Can Get Help With',
              description: 'Choose the relevant category',
              points: [
                '🚗 Road & Traffic Rules - Violations, accidents, licenses',
                '👩 Women Harassment - Workplace, street, domestic',
                '💻 Cyber Crime - Fraud, hacking, online abuse',
                '⚖️ Labour Rights - Wages, dismissal, workplace safety',
              ],
              icon: 'assets/icons/category.svg',
            ),
            GuidanceStep(
              title: 'How to Use This Service',
              description: 'Step-by-step process',
              points: [
                'Select your legal concern category',
                'Review important guidance and dos/don\'ts',
                'Click "Start Chat" to speak with AI advisor',
                'Get personalized legal guidance',
                'Receive recommended next actions',
              ],
              icon: 'assets/icons/guide.svg',
            ),
          ],
        ),
      ],
    );
  }
}
