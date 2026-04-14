import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ro.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ro'),
    Locale('ur')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Legal Sathi'**
  String get appTitle;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @voiceMode.
  ///
  /// In en, this message translates to:
  /// **'Voice Mode'**
  String get voiceMode;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @simulate.
  ///
  /// In en, this message translates to:
  /// **'Simulate'**
  String get simulate;

  /// No description provided for @firDraft.
  ///
  /// In en, this message translates to:
  /// **'FIR Draft'**
  String get firDraft;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @urdu.
  ///
  /// In en, this message translates to:
  /// **'Urdu'**
  String get urdu;

  /// No description provided for @romanUrdu.
  ///
  /// In en, this message translates to:
  /// **'Roman Urdu'**
  String get romanUrdu;

  /// No description provided for @askALegalQuestion.
  ///
  /// In en, this message translates to:
  /// **'Ask a legal question'**
  String get askALegalQuestion;

  /// No description provided for @created2HoursAgo.
  ///
  /// In en, this message translates to:
  /// **'Created 2 hours ago'**
  String get created2HoursAgo;

  /// No description provided for @legalCategoies.
  ///
  /// In en, this message translates to:
  /// **'Legal Categories'**
  String get legalCategoies;

  /// No description provided for @selectLegalCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Legal Category'**
  String get selectLegalCategory;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @noRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'No recent activity'**
  String get noRecentActivity;

  /// No description provided for @askAi.
  ///
  /// In en, this message translates to:
  /// **'Ask AI'**
  String get askAi;

  /// No description provided for @whatsApp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsApp;

  /// No description provided for @emails.
  ///
  /// In en, this message translates to:
  /// **'Emails'**
  String get emails;

  /// No description provided for @voiceNotes.
  ///
  /// In en, this message translates to:
  /// **'Voice Notes'**
  String get voiceNotes;

  /// No description provided for @cctv.
  ///
  /// In en, this message translates to:
  /// **'CCTV Footage'**
  String get cctv;

  /// No description provided for @digitalCommunication.
  ///
  /// In en, this message translates to:
  /// **'Digital Communication'**
  String get digitalCommunication;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @generate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get generate;

  /// No description provided for @screenshots.
  ///
  /// In en, this message translates to:
  /// **'Screenshots'**
  String get screenshots;

  /// No description provided for @callRecordings.
  ///
  /// In en, this message translates to:
  /// **'Call Recordings'**
  String get callRecordings;

  /// No description provided for @witnessStatements.
  ///
  /// In en, this message translates to:
  /// **'Witness Statements'**
  String get witnessStatements;

  /// No description provided for @medicalReports.
  ///
  /// In en, this message translates to:
  /// **'Medical Reports'**
  String get medicalReports;

  /// No description provided for @policeReports.
  ///
  /// In en, this message translates to:
  /// **'Police Reports'**
  String get policeReports;

  /// No description provided for @diary.
  ///
  /// In en, this message translates to:
  /// **'Diary'**
  String get diary;

  /// No description provided for @hrwarningemails.
  ///
  /// In en, this message translates to:
  /// **'HR Warning Emails'**
  String get hrwarningemails;

  /// No description provided for @patternOfBehavior.
  ///
  /// In en, this message translates to:
  /// **'Pattern of Behavior'**
  String get patternOfBehavior;

  /// No description provided for @whatnotTodo.
  ///
  /// In en, this message translates to:
  /// **'What not to do'**
  String get whatnotTodo;

  /// No description provided for @tipsForPreservivngDigitalFiles.
  ///
  /// In en, this message translates to:
  /// **'Tips for Preserving Digital Files'**
  String get tipsForPreservivngDigitalFiles;

  /// No description provided for @uploadEvidenceForAiReview.
  ///
  /// In en, this message translates to:
  /// **'Upload evidence for AI review'**
  String get uploadEvidenceForAiReview;

  /// No description provided for @evidenceCollectionGuide.
  ///
  /// In en, this message translates to:
  /// **'Evidence Collection Guide'**
  String get evidenceCollectionGuide;

  /// No description provided for @typeYourQuestion.
  ///
  /// In en, this message translates to:
  /// **'Type your question here...'**
  String get typeYourQuestion;

  /// No description provided for @uploadEvidence.
  ///
  /// In en, this message translates to:
  /// **'Upload Evidence'**
  String get uploadEvidence;

  /// No description provided for @selectFile.
  ///
  /// In en, this message translates to:
  /// **'Select File'**
  String get selectFile;

  /// No description provided for @draftDocument.
  ///
  /// In en, this message translates to:
  /// **'Draft Document'**
  String get draftDocument;

  /// No description provided for @selectDocumentType.
  ///
  /// In en, this message translates to:
  /// **'Select Document Type'**
  String get selectDocumentType;

  /// No description provided for @siulate.
  ///
  /// In en, this message translates to:
  /// **'Simulate'**
  String get siulate;

  /// No description provided for @protection.
  ///
  /// In en, this message translates to:
  /// **'Protection'**
  String get protection;

  /// No description provided for @rights.
  ///
  /// In en, this message translates to:
  /// **'Rights'**
  String get rights;

  /// No description provided for @provideEvidence.
  ///
  /// In en, this message translates to:
  /// **'Provide Evidence'**
  String get provideEvidence;

  /// No description provided for @inquiryProcess.
  ///
  /// In en, this message translates to:
  /// **'InquiryProcess'**
  String get inquiryProcess;

  /// No description provided for @decisionwithin90Days.
  ///
  /// In en, this message translates to:
  /// **'Decision within 90 Days'**
  String get decisionwithin90Days;

  /// No description provided for @implementation.
  ///
  /// In en, this message translates to:
  /// **'Implementation'**
  String get implementation;

  /// No description provided for @fileWrittenComplaint.
  ///
  /// In en, this message translates to:
  /// **'File Written Complaint'**
  String get fileWrittenComplaint;

  /// No description provided for @legalProcess.
  ///
  /// In en, this message translates to:
  /// **'Legal Process'**
  String get legalProcess;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @obligations.
  ///
  /// In en, this message translates to:
  /// **'Obligations'**
  String get obligations;

  /// No description provided for @legalAdvice.
  ///
  /// In en, this message translates to:
  /// **'Legal Advice'**
  String get legalAdvice;

  /// No description provided for @caseAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Case Analysis'**
  String get caseAnalysis;

  /// No description provided for @legalResearch.
  ///
  /// In en, this message translates to:
  /// **'Legal Research'**
  String get legalResearch;

  /// No description provided for @documentReview.
  ///
  /// In en, this message translates to:
  /// **'Document Review'**
  String get documentReview;

  /// No description provided for @contractDrafting.
  ///
  /// In en, this message translates to:
  /// **'Contract Drafting'**
  String get contractDrafting;

  /// No description provided for @workplaceCommitteeProcedure.
  ///
  /// In en, this message translates to:
  /// **'Workplace Committee Procedure'**
  String get workplaceCommitteeProcedure;

  /// No description provided for @legalCategory.
  ///
  /// In en, this message translates to:
  /// **'Legal Category'**
  String get legalCategory;

  /// No description provided for @ombudspersonComplaintSteps.
  ///
  /// In en, this message translates to:
  /// **'Ombudsperson Complaint Steps'**
  String get ombudspersonComplaintSteps;

  /// No description provided for @ombudspersonComplaintForm.
  ///
  /// In en, this message translates to:
  /// **'Ombudsperson Complaint Form'**
  String get ombudspersonComplaintForm;

  /// No description provided for @protectionAgainstHarassmentAct.
  ///
  /// In en, this message translates to:
  /// **'Protection Against Harassment Act'**
  String get protectionAgainstHarassmentAct;

  /// No description provided for @sexualHarassment.
  ///
  /// In en, this message translates to:
  /// **'Sexual Harassment'**
  String get sexualHarassment;

  /// No description provided for @workplaceHarassment.
  ///
  /// In en, this message translates to:
  /// **'Workplace Harassment'**
  String get workplaceHarassment;

  /// No description provided for @evidenceChecklist.
  ///
  /// In en, this message translates to:
  /// **'Evidence Checklist'**
  String get evidenceChecklist;

  /// No description provided for @legalRights.
  ///
  /// In en, this message translates to:
  /// **'Legal Rights'**
  String get legalRights;

  /// No description provided for @committeComposition.
  ///
  /// In en, this message translates to:
  /// **'Committee Composition'**
  String get committeComposition;

  /// No description provided for @complaintFiling.
  ///
  /// In en, this message translates to:
  /// **'Complaint Filing'**
  String get complaintFiling;

  /// No description provided for @fillingProcess.
  ///
  /// In en, this message translates to:
  /// **'Filing Process'**
  String get fillingProcess;

  /// No description provided for @inquiryTimeline.
  ///
  /// In en, this message translates to:
  /// **'Inquiry Timeline'**
  String get inquiryTimeline;

  /// No description provided for @possibleOutcomes.
  ///
  /// In en, this message translates to:
  /// **'Possible Outcomes'**
  String get possibleOutcomes;

  /// No description provided for @appealProcess.
  ///
  /// In en, this message translates to:
  /// **'Appeal Process'**
  String get appealProcess;

  /// No description provided for @escalation.
  ///
  /// In en, this message translates to:
  /// **'Escalation'**
  String get escalation;

  /// No description provided for @organizationalPolicies.
  ///
  /// In en, this message translates to:
  /// **'Organizational Policies'**
  String get organizationalPolicies;

  /// No description provided for @legalObligations.
  ///
  /// In en, this message translates to:
  /// **'Legal Obligations'**
  String get legalObligations;

  /// No description provided for @legalAdviceForHarassment.
  ///
  /// In en, this message translates to:
  /// **'Legal Advice for Harassment'**
  String get legalAdviceForHarassment;

  /// No description provided for @draftComplaintGenerator.
  ///
  /// In en, this message translates to:
  /// **'Draft Complaint Generator'**
  String get draftComplaintGenerator;

  /// No description provided for @scenarioSimulator.
  ///
  /// In en, this message translates to:
  /// **'Scenario Simulator'**
  String get scenarioSimulator;

  /// No description provided for @selectYourScenario.
  ///
  /// In en, this message translates to:
  /// **'Select Your Scenario'**
  String get selectYourScenario;

  /// No description provided for @getLegalAdvice.
  ///
  /// In en, this message translates to:
  /// **'Get Legal Advice'**
  String get getLegalAdvice;

  /// No description provided for @understantYourRights.
  ///
  /// In en, this message translates to:
  /// **'Understand Your Rights'**
  String get understantYourRights;

  /// No description provided for @streetSexualHarassment.
  ///
  /// In en, this message translates to:
  /// **'Street Sexual Harassment'**
  String get streetSexualHarassment;

  /// No description provided for @workplaceSexualHarassment.
  ///
  /// In en, this message translates to:
  /// **'Workplace Sexual Harassment'**
  String get workplaceSexualHarassment;

  /// No description provided for @domesticViolence.
  ///
  /// In en, this message translates to:
  /// **'Domestic Violence'**
  String get domesticViolence;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get terms;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @startChatWithAiAdvisor.
  ///
  /// In en, this message translates to:
  /// **'Start Chat with AI Advisor'**
  String get startChatWithAiAdvisor;

  /// No description provided for @primaryEvidence.
  ///
  /// In en, this message translates to:
  /// **'Primary Evidence'**
  String get primaryEvidence;

  /// No description provided for @legalResearchTool.
  ///
  /// In en, this message translates to:
  /// **'Legal Research Tool'**
  String get legalResearchTool;

  /// No description provided for @documentReviewTool.
  ///
  /// In en, this message translates to:
  /// **'Document Review Tool'**
  String get documentReviewTool;

  /// No description provided for @contractDraftingTool.
  ///
  /// In en, this message translates to:
  /// **'Contract Drafting Tool'**
  String get contractDraftingTool;

  /// No description provided for @employerObligations.
  ///
  /// In en, this message translates to:
  /// **'Employer Obligations'**
  String get employerObligations;

  /// No description provided for @employeeRights.
  ///
  /// In en, this message translates to:
  /// **'Employee Rights'**
  String get employeeRights;

  /// No description provided for @penalties.
  ///
  /// In en, this message translates to:
  /// **'Penalties'**
  String get penalties;

  /// No description provided for @law.
  ///
  /// In en, this message translates to:
  /// **'Law'**
  String get law;

  /// No description provided for @caseStudies.
  ///
  /// In en, this message translates to:
  /// **'Case Studies'**
  String get caseStudies;

  /// No description provided for @pakistan.
  ///
  /// In en, this message translates to:
  /// **'Pakistan'**
  String get pakistan;

  /// No description provided for @protectionAct2010.
  ///
  /// In en, this message translates to:
  /// **'Protection Against Harassment of 2010'**
  String get protectionAct2010;

  /// No description provided for @areYouSureYouWantToLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get areYouSureYouWantToLogout;

  /// No description provided for @downloadFeatureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Download will be available soon.'**
  String get downloadFeatureComingSoon;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ro', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ro': return AppLocalizationsRo();
    case 'ur': return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
