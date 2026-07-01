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

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @lastStep.
  ///
  /// In en, this message translates to:
  /// **'Last Step'**
  String get lastStep;

  /// No description provided for @simulation_aiDescription.
  ///
  /// In en, this message translates to:
  /// **'AI will guide you step-by-step with legal advice and next actions'**
  String get simulation_aiDescription;

  /// No description provided for @howAiWorks.
  ///
  /// In en, this message translates to:
  /// **'How AI Advisor Works:'**
  String get howAiWorks;

  /// No description provided for @stepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepOf(Object current, Object total);

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
  /// **'No Recent Activity'**
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
  /// **'Witness contacts and statements'**
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

  /// No description provided for @incidentNotes.
  ///
  /// In en, this message translates to:
  /// **'Incident Notes'**
  String get incidentNotes;

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

  /// No description provided for @evidenceWhatsAppDescription.
  ///
  /// In en, this message translates to:
  /// **'Screenshots of harassing messages with timestamps and sender information visible.'**
  String get evidenceWhatsAppDescription;

  /// No description provided for @evidenceEmailsDescription.
  ///
  /// In en, this message translates to:
  /// **'Email correspondence showing harassment, including headers with dates and times.'**
  String get evidenceEmailsDescription;

  /// No description provided for @evidenceVoiceNotesDescription.
  ///
  /// In en, this message translates to:
  /// **'Audio recordings of threatening or harassing voice messages (where legal).'**
  String get evidenceVoiceNotesDescription;

  /// No description provided for @evidenceCctvDescription.
  ///
  /// In en, this message translates to:
  /// **'Video evidence from security cameras showing incidents of harassment.'**
  String get evidenceCctvDescription;

  /// No description provided for @evidenceCallRecordingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Recorded phone conversations (only legal with consent in Pakistan).'**
  String get evidenceCallRecordingsDescription;

  /// No description provided for @evidenceScreenshotsDescription.
  ///
  /// In en, this message translates to:
  /// **'Screen captures of harassing content from social media or other platforms.'**
  String get evidenceScreenshotsDescription;

  /// No description provided for @evidencePhotosDescription.
  ///
  /// In en, this message translates to:
  /// **'Photographic evidence of physical harassment or threats.'**
  String get evidencePhotosDescription;

  /// No description provided for @evidenceDigitalCommunicationDescription.
  ///
  /// In en, this message translates to:
  /// **'Any other form of digital communication showing harassment.'**
  String get evidenceDigitalCommunicationDescription;

  /// No description provided for @evidenceWitnessStatementsDescription.
  ///
  /// In en, this message translates to:
  /// **'Written statements from people who witnessed the harassment.'**
  String get evidenceWitnessStatementsDescription;

  /// No description provided for @evidenceDiaryIncidentNotesDescription.
  ///
  /// In en, this message translates to:
  /// **'Personal records documenting dates, times, and details of incidents.'**
  String get evidenceDiaryIncidentNotesDescription;

  /// No description provided for @evidenceMedicalReportsDescription.
  ///
  /// In en, this message translates to:
  /// **'Medical documentation of physical or psychological harm caused by harassment.'**
  String get evidenceMedicalReportsDescription;

  /// No description provided for @evidenceHrWarningEmailsDescription.
  ///
  /// In en, this message translates to:
  /// **'Official warnings or complaints filed with HR department.'**
  String get evidenceHrWarningEmailsDescription;

  /// No description provided for @evidencePatternOfBehaviorDescription.
  ///
  /// In en, this message translates to:
  /// **'Documentation showing repeated instances of harassment over time.'**
  String get evidencePatternOfBehaviorDescription;

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
  /// **'Inquiry Process'**
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
  /// **'File a Written Complaint'**
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
  /// **'Sexual harassment'**
  String get sexualHarassment;

  /// No description provided for @workplaceHarassment.
  ///
  /// In en, this message translates to:
  /// **'Workplace Harassment'**
  String get workplaceHarassment;

  /// No description provided for @evidenceChecklist.
  ///
  /// In en, this message translates to:
  /// **'Evidence Preservation Checklist'**
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

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
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
  /// **'Protection Act 2010'**
  String get protectionAct2010;

  /// No description provided for @areYouSureYouWantToLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get areYouSureYouWantToLogout;

  /// No description provided for @downloadFeatureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Download feature coming soon'**
  String get downloadFeatureComingSoon;

  /// No description provided for @legalAssistant.
  ///
  /// In en, this message translates to:
  /// **'Legal Assistant'**
  String get legalAssistant;

  /// No description provided for @deepAnalysisActive.
  ///
  /// In en, this message translates to:
  /// **'Deep analysis active…'**
  String get deepAnalysisActive;

  /// No description provided for @yourLegalAssistant.
  ///
  /// In en, this message translates to:
  /// **'Your legal assistant'**
  String get yourLegalAssistant;

  /// No description provided for @userId.
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get userId;

  /// No description provided for @notLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Not logged in'**
  String get notLoggedIn;

  /// No description provided for @documentReady.
  ///
  /// In en, this message translates to:
  /// **'Document Ready'**
  String get documentReady;

  /// No description provided for @firDraftGeneratedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Your FIR draft has been generated successfully.'**
  String get firDraftGeneratedSuccessfully;

  /// No description provided for @evidenceProcessed.
  ///
  /// In en, this message translates to:
  /// **'Evidence Processed'**
  String get evidenceProcessed;

  /// No description provided for @evidenceHasBeenAnalyzed.
  ///
  /// In en, this message translates to:
  /// **'Your uploaded evidence has been analyzed.'**
  String get evidenceHasBeenAnalyzed;

  /// No description provided for @newLawUpdate.
  ///
  /// In en, this message translates to:
  /// **'New Law Update'**
  String get newLawUpdate;

  /// No description provided for @pecaAmendmentsAdded.
  ///
  /// In en, this message translates to:
  /// **'PECA 2016 amendments have been added.'**
  String get pecaAmendmentsAdded;

  /// No description provided for @welcomeToLegalSathi.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Legal Sathi'**
  String get welcomeToLegalSathi;

  /// No description provided for @startByExploringLegalCategories.
  ///
  /// In en, this message translates to:
  /// **'Start by exploring our legal categories.'**
  String get startByExploringLegalCategories;

  /// No description provided for @minAgo.
  ///
  /// In en, this message translates to:
  /// **'2 min ago'**
  String get minAgo;

  /// No description provided for @hourAgo.
  ///
  /// In en, this message translates to:
  /// **'1 hour ago'**
  String get hourAgo;

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'2 hours ago'**
  String get hoursAgo;

  /// No description provided for @dayAgo.
  ///
  /// In en, this message translates to:
  /// **'1 day ago'**
  String get dayAgo;

  /// No description provided for @aiLegalAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Legal Assistant'**
  String get aiLegalAssistant;

  /// No description provided for @aboutLegalSathi.
  ///
  /// In en, this message translates to:
  /// **'About Legal Sathi'**
  String get aboutLegalSathi;

  /// No description provided for @howCanWeHelp.
  ///
  /// In en, this message translates to:
  /// **'How Can We Help?'**
  String get howCanWeHelp;

  /// No description provided for @findAnswersAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Find answers and support'**
  String get findAnswersAndSupport;

  /// No description provided for @helpTopics.
  ///
  /// In en, this message translates to:
  /// **'Help Topics'**
  String get helpTopics;

  /// No description provided for @howToUseLegalSathi.
  ///
  /// In en, this message translates to:
  /// **'How to use Legal Sathi'**
  String get howToUseLegalSathi;

  /// No description provided for @learnBasicsNavigatingApp.
  ///
  /// In en, this message translates to:
  /// **'Learn basics of navigating the app'**
  String get learnBasicsNavigatingApp;

  /// No description provided for @howToUploadEvidence.
  ///
  /// In en, this message translates to:
  /// **'How to upload evidence'**
  String get howToUploadEvidence;

  /// No description provided for @stepByStepGuideUploadingDocuments.
  ///
  /// In en, this message translates to:
  /// **'Step-by-step guide for uploading documents'**
  String get stepByStepGuideUploadingDocuments;

  /// No description provided for @privacyMatters.
  ///
  /// In en, this message translates to:
  /// **'Your Privacy Matters'**
  String get privacyMatters;

  /// No description provided for @howWeProtectYourInformation.
  ///
  /// In en, this message translates to:
  /// **'How we protect your information'**
  String get howWeProtectYourInformation;

  /// No description provided for @dataUsage.
  ///
  /// In en, this message translates to:
  /// **'Data Usage'**
  String get dataUsage;

  /// No description provided for @dataUsageDesc.
  ///
  /// In en, this message translates to:
  /// **'We collect only the information necessary to provide legal assistance. Your queries and documents are processed securely and not shared with third parties. Usage data helps us improve the app experience.'**
  String get dataUsageDesc;

  /// No description provided for @evidenceHandlingTitle.
  ///
  /// In en, this message translates to:
  /// **'Evidence Handling'**
  String get evidenceHandlingTitle;

  /// No description provided for @evidenceHandlingDesc.
  ///
  /// In en, this message translates to:
  /// **'Uploaded evidence is encrypted and stored securely. Files are only used for the purpose you upload them for and are not shared. You can delete uploaded files at any time from your account.'**
  String get evidenceHandlingDesc;

  /// No description provided for @userIdentityProtection.
  ///
  /// In en, this message translates to:
  /// **'User Identity Protection'**
  String get userIdentityProtection;

  /// No description provided for @areYouSureYouWantToDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete'**
  String get areYouSureYouWantToDelete;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @knowYourRights.
  ///
  /// In en, this message translates to:
  /// **'Know Your Rights'**
  String get knowYourRights;

  /// No description provided for @knowYourRightsDesc.
  ///
  /// In en, this message translates to:
  /// **'Access comprehensive legal information about Pakistani laws covering criminal, civil, labour, and cyber domains.'**
  String get knowYourRightsDesc;

  /// No description provided for @aiLegalAssistantTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Legal Assistant'**
  String get aiLegalAssistantTitle;

  /// No description provided for @aiLegalAssistantDesc.
  ///
  /// In en, this message translates to:
  /// **'Get instant answers to your legal questions in English, Roman Urdu, or Urdu from our intelligent assistant.'**
  String get aiLegalAssistantDesc;

  /// No description provided for @draftDocumentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Draft Documents'**
  String get draftDocumentsTitle;

  /// No description provided for @draftDocumentsDesc.
  ///
  /// In en, this message translates to:
  /// **'Generate FIRs, complaints, and legal documents with guided step-by-step assistance.'**
  String get draftDocumentsDesc;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @regenerate.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get regenerate;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @errorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorMessage(Object message);

  /// No description provided for @successMessage.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get successMessage;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Complaint copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @downloadedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Downloaded successfully'**
  String get downloadedSuccessfully;

  /// No description provided for @noFilesSelected.
  ///
  /// In en, this message translates to:
  /// **'No files selected.'**
  String get noFilesSelected;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @featureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Feature coming soon'**
  String get featureComingSoon;

  /// No description provided for @cyberCrimePeca.
  ///
  /// In en, this message translates to:
  /// **'Cyber Crime (PECA)'**
  String get cyberCrimePeca;

  /// No description provided for @onlineHarassmentPeca.
  ///
  /// In en, this message translates to:
  /// **'Online Harassment (PECA 24)'**
  String get onlineHarassmentPeca;

  /// No description provided for @cyberStalking.
  ///
  /// In en, this message translates to:
  /// **'Cyber stalking & harassment'**
  String get cyberStalking;

  /// No description provided for @whatIsOnlineHarassment.
  ///
  /// In en, this message translates to:
  /// **'What is Online Harassment?'**
  String get whatIsOnlineHarassment;

  /// No description provided for @whatToDo.
  ///
  /// In en, this message translates to:
  /// **'What to do'**
  String get whatToDo;

  /// No description provided for @howToReport.
  ///
  /// In en, this message translates to:
  /// **'How to Report on {platform}'**
  String howToReport(Object platform);

  /// No description provided for @evidenceExtractor.
  ///
  /// In en, this message translates to:
  /// **'Evidence Extractor'**
  String get evidenceExtractor;

  /// No description provided for @uploadThreatEvidence.
  ///
  /// In en, this message translates to:
  /// **'Upload Threat Evidence'**
  String get uploadThreatEvidence;

  /// No description provided for @blackmailHandling.
  ///
  /// In en, this message translates to:
  /// **'Blackmail Handling'**
  String get blackmailHandling;

  /// No description provided for @reportFakeAccount.
  ///
  /// In en, this message translates to:
  /// **'Report Fake Account'**
  String get reportFakeAccount;

  /// No description provided for @fiaCyberCrime.
  ///
  /// In en, this message translates to:
  /// **'FIA Cyber Crime'**
  String get fiaCyberCrime;

  /// No description provided for @labourRights.
  ///
  /// In en, this message translates to:
  /// **'Labour Rights'**
  String get labourRights;

  /// No description provided for @minimumWageChecker.
  ///
  /// In en, this message translates to:
  /// **'Minimum Wage Checker'**
  String get minimumWageChecker;

  /// No description provided for @overtimePayCalculator.
  ///
  /// In en, this message translates to:
  /// **'Overtime & Pay Calculator'**
  String get overtimePayCalculator;

  /// No description provided for @backPayCalculator.
  ///
  /// In en, this message translates to:
  /// **'Back Pay Calculator'**
  String get backPayCalculator;

  /// No description provided for @contractViolationChecker.
  ///
  /// In en, this message translates to:
  /// **'Contract Violation Checker'**
  String get contractViolationChecker;

  /// No description provided for @paidLeaveEligibility.
  ///
  /// In en, this message translates to:
  /// **'Paid Leave Eligibility'**
  String get paidLeaveEligibility;

  /// No description provided for @fileLabourComplaint.
  ///
  /// In en, this message translates to:
  /// **'File Labour Complaint'**
  String get fileLabourComplaint;

  /// No description provided for @selectProvince.
  ///
  /// In en, this message translates to:
  /// **'Select Province'**
  String get selectProvince;

  /// No description provided for @selectWorkerType.
  ///
  /// In en, this message translates to:
  /// **'Select Worker Type'**
  String get selectWorkerType;

  /// No description provided for @minimumWageTable.
  ///
  /// In en, this message translates to:
  /// **'Minimum Wage Table'**
  String get minimumWageTable;

  /// No description provided for @wageCheckResult.
  ///
  /// In en, this message translates to:
  /// **'Wage Check Result'**
  String get wageCheckResult;

  /// No description provided for @roadTrafficLaw.
  ///
  /// In en, this message translates to:
  /// **'Road & Traffic Law'**
  String get roadTrafficLaw;

  /// No description provided for @trafficChallan.
  ///
  /// In en, this message translates to:
  /// **'Traffic Challan OCR'**
  String get trafficChallan;

  /// No description provided for @fineCalculator.
  ///
  /// In en, this message translates to:
  /// **'Fine Calculator'**
  String get fineCalculator;

  /// No description provided for @offenceTypes.
  ///
  /// In en, this message translates to:
  /// **'Offence Types'**
  String get offenceTypes;

  /// No description provided for @overSpeeding.
  ///
  /// In en, this message translates to:
  /// **'Over Speeding'**
  String get overSpeeding;

  /// No description provided for @redLight.
  ///
  /// In en, this message translates to:
  /// **'Red Light'**
  String get redLight;

  /// No description provided for @helmet.
  ///
  /// In en, this message translates to:
  /// **'No Helmet'**
  String get helmet;

  /// No description provided for @seatBelt.
  ///
  /// In en, this message translates to:
  /// **'No Seat Belt'**
  String get seatBelt;

  /// No description provided for @mobileUse.
  ///
  /// In en, this message translates to:
  /// **'Mobile Use'**
  String get mobileUse;

  /// No description provided for @noLicense.
  ///
  /// In en, this message translates to:
  /// **'No License'**
  String get noLicense;

  /// No description provided for @parkingViolation.
  ///
  /// In en, this message translates to:
  /// **'Parking Violation'**
  String get parkingViolation;

  /// No description provided for @fineAmount.
  ///
  /// In en, this message translates to:
  /// **'Fine Amount'**
  String get fineAmount;

  /// No description provided for @severity.
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get severity;

  /// No description provided for @policeMisbehaviorGuide.
  ///
  /// In en, this message translates to:
  /// **'Police Misbehavior Guide'**
  String get policeMisbehaviorGuide;

  /// No description provided for @immediateSteps.
  ///
  /// In en, this message translates to:
  /// **'Immediate Steps'**
  String get immediateSteps;

  /// No description provided for @challanDetails.
  ///
  /// In en, this message translates to:
  /// **'Challan Details'**
  String get challanDetails;

  /// No description provided for @womenHarassmentLaws.
  ///
  /// In en, this message translates to:
  /// **'Women Harassment Laws'**
  String get womenHarassmentLaws;

  /// No description provided for @protectionAgainstHarassmentActTitle.
  ///
  /// In en, this message translates to:
  /// **'Protection Against Harassment Act'**
  String get protectionAgainstHarassmentActTitle;

  /// No description provided for @workplaceCommitteeProcedures.
  ///
  /// In en, this message translates to:
  /// **'Workplace Committee Procedures'**
  String get workplaceCommitteeProcedures;

  /// No description provided for @ombudsmanComplaints.
  ///
  /// In en, this message translates to:
  /// **'Ombudsman Complaints'**
  String get ombudsmanComplaints;

  /// No description provided for @incidentDetails.
  ///
  /// In en, this message translates to:
  /// **'INCIDENT DETAILS:'**
  String get incidentDetails;

  /// No description provided for @selectIncidentType.
  ///
  /// In en, this message translates to:
  /// **'Select Incident Type'**
  String get selectIncidentType;

  /// No description provided for @incidentLocation.
  ///
  /// In en, this message translates to:
  /// **'Incident Location'**
  String get incidentLocation;

  /// No description provided for @incidentDate.
  ///
  /// In en, this message translates to:
  /// **'Date(s) of Incident'**
  String get incidentDate;

  /// No description provided for @describeIncident.
  ///
  /// In en, this message translates to:
  /// **'Please describe the incident.'**
  String get describeIncident;

  /// No description provided for @jurisdictionCheck.
  ///
  /// In en, this message translates to:
  /// **'Jurisdiction Check'**
  String get jurisdictionCheck;

  /// No description provided for @internalComplaintInfo.
  ///
  /// In en, this message translates to:
  /// **'Internal Complaint Information'**
  String get internalComplaintInfo;

  /// No description provided for @submissionInstructions.
  ///
  /// In en, this message translates to:
  /// **'Submission Instructions'**
  String get submissionInstructions;

  /// No description provided for @uploadEvidenceDocuments.
  ///
  /// In en, this message translates to:
  /// **'Upload Evidence Documents'**
  String get uploadEvidenceDocuments;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @minimumCharacters.
  ///
  /// In en, this message translates to:
  /// **'Must be at least 6 characters'**
  String get minimumCharacters;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @fileAdded.
  ///
  /// In en, this message translates to:
  /// **'file(s) added successfully'**
  String get fileAdded;

  /// No description provided for @fileUploaded.
  ///
  /// In en, this message translates to:
  /// **'file(s) uploaded successfully'**
  String get fileUploaded;

  /// No description provided for @fileRemoved.
  ///
  /// In en, this message translates to:
  /// **'File removed'**
  String get fileRemoved;

  /// No description provided for @permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Permission required'**
  String get permissionRequired;

  /// No description provided for @speechNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition not available'**
  String get speechNotAvailable;

  /// No description provided for @deleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This message will be removed from the chat'**
  String get deleteMessage;

  /// No description provided for @deleteChat.
  ///
  /// In en, this message translates to:
  /// **'Delete Chat'**
  String get deleteChat;

  /// No description provided for @renameChat.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get renameChat;

  /// No description provided for @renameComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Rename feature coming soon'**
  String get renameComingSoon;

  /// No description provided for @chatSaved.
  ///
  /// In en, this message translates to:
  /// **'Chat saved to your account'**
  String get chatSaved;

  /// No description provided for @signInToSave.
  ///
  /// In en, this message translates to:
  /// **'Sign in to save this to your account'**
  String get signInToSave;

  /// No description provided for @pdfDownloaded.
  ///
  /// In en, this message translates to:
  /// **'PDF downloaded successfully!'**
  String get pdfDownloaded;

  /// No description provided for @templateDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Template downloaded successfully'**
  String get templateDownloaded;

  /// No description provided for @regenerated.
  ///
  /// In en, this message translates to:
  /// **'Regenerated'**
  String get regenerated;

  /// No description provided for @goToHome.
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get goToHome;

  /// No description provided for @emailCopied.
  ///
  /// In en, this message translates to:
  /// **'Email address copied to clipboard'**
  String get emailCopied;

  /// No description provided for @joinLegalSathi.
  ///
  /// In en, this message translates to:
  /// **'Join Legal Sathi'**
  String get joinLegalSathi;

  /// No description provided for @createAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create an account to save your documents\nand chat history'**
  String get createAccountSubtitle;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to access your legal assistant'**
  String get signInSubtitle;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullName;

  /// No description provided for @createPassword.
  ///
  /// In en, this message translates to:
  /// **'Create a password'**
  String get createPassword;

  /// No description provided for @confirmYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirmYourPassword;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get continueAsGuest;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Legal Sathi'**
  String get appName;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @welcomeAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Welcome as Guest'**
  String get welcomeAsGuest;

  /// No description provided for @guestDescription.
  ///
  /// In en, this message translates to:
  /// **'Sign up to unlock full features, save documents, and track your cases.'**
  String get guestDescription;

  /// No description provided for @signUpNow.
  ///
  /// In en, this message translates to:
  /// **'Sign Up Now'**
  String get signUpNow;

  /// No description provided for @activitiesWillAppear.
  ///
  /// In en, this message translates to:
  /// **'Your activities will appear here'**
  String get activitiesWillAppear;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @bySigningUpYouAgree.
  ///
  /// In en, this message translates to:
  /// **'By signing up, you agree to our'**
  String get bySigningUpYouAgree;

  /// No description provided for @nameAtLeast3Chars.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 3 characters'**
  String get nameAtLeast3Chars;

  /// No description provided for @passwordAtLeast6Chars.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordAtLeast6Chars;

  /// No description provided for @pleaseEnterFullName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get pleaseEnterFullName;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get pleaseEnterPassword;

  /// No description provided for @pleaseConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmPassword;

  /// No description provided for @pleaseEnterEmailFirst.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email first'**
  String get pleaseEnterEmailFirst;

  /// No description provided for @createAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountTitle;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInTitle;

  /// No description provided for @yourPrivacyMatters.
  ///
  /// In en, this message translates to:
  /// **'Your Privacy Matters'**
  String get yourPrivacyMatters;

  /// No description provided for @howWeProtect.
  ///
  /// In en, this message translates to:
  /// **'How we protect your information'**
  String get howWeProtect;

  /// No description provided for @userIdentityProtectionDesc.
  ///
  /// In en, this message translates to:
  /// **'Your identity and case details are kept confidential. We use industry-standard encryption for data transmission and storage. Account information is protected with secure authentication. You can request deletion of your data at any time.'**
  String get userIdentityProtectionDesc;

  /// No description provided for @aiResponseLimitations.
  ///
  /// In en, this message translates to:
  /// **'AI Response Limitations'**
  String get aiResponseLimitations;

  /// No description provided for @aiResponseLimitationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Legal Sathi provides general legal information and document drafting assistance. AI responses are not legal advice and should not replace consultation with a qualified lawyer. Always verify information with legal professionals before taking action.'**
  String get aiResponseLimitationsDesc;

  /// No description provided for @contactForComplaints.
  ///
  /// In en, this message translates to:
  /// **'Contact for Complaints'**
  String get contactForComplaints;

  /// No description provided for @contactForComplaintsDesc.
  ///
  /// In en, this message translates to:
  /// **'For privacy concerns or data-related complaints, contact us at privacy@legalsathi.pk. We respond to all inquiries within 7 business days. You have the right to access, correct, or delete your personal information.'**
  String get contactForComplaintsDesc;

  /// No description provided for @privacyFooter.
  ///
  /// In en, this message translates to:
  /// **'Last updated: January 2026 • Version 1.0'**
  String get privacyFooter;

  /// No description provided for @cyberCrimeUrdu.
  ///
  /// In en, this message translates to:
  /// **'سائبر کرائم'**
  String get cyberCrimeUrdu;

  /// No description provided for @searchSections.
  ///
  /// In en, this message translates to:
  /// **'Search sections...'**
  String get searchSections;

  /// No description provided for @pecaSection24Overview.
  ///
  /// In en, this message translates to:
  /// **'PECA Section 24 overview'**
  String get pecaSection24Overview;

  /// No description provided for @stepsToHandleBlackmail.
  ///
  /// In en, this message translates to:
  /// **'Steps to handle blackmail'**
  String get stepsToHandleBlackmail;

  /// No description provided for @reportFakeSocialProfiles.
  ///
  /// In en, this message translates to:
  /// **'Report fake social profiles'**
  String get reportFakeSocialProfiles;

  /// No description provided for @threatMessageEvidence.
  ///
  /// In en, this message translates to:
  /// **'Threat Message Evidence'**
  String get threatMessageEvidence;

  /// No description provided for @preserveDigitalEvidence.
  ///
  /// In en, this message translates to:
  /// **'Preserve digital evidence'**
  String get preserveDigitalEvidence;

  /// No description provided for @draftFiaCyberComplaint.
  ///
  /// In en, this message translates to:
  /// **'Draft FIA cyber complaint'**
  String get draftFiaCyberComplaint;

  /// No description provided for @screenshotReader.
  ///
  /// In en, this message translates to:
  /// **'Screenshot Reader'**
  String get screenshotReader;

  /// No description provided for @extractTimestampsNumbers.
  ///
  /// In en, this message translates to:
  /// **'Extract timestamps & numbers'**
  String get extractTimestampsNumbers;

  /// No description provided for @learnCyberCrimeScenarios.
  ///
  /// In en, this message translates to:
  /// **'Learn cyber crime scenarios'**
  String get learnCyberCrimeScenarios;

  /// No description provided for @blackmailHandlingTitle.
  ///
  /// In en, this message translates to:
  /// **'Blackmail Handling'**
  String get blackmailHandlingTitle;

  /// No description provided for @blackmailSituation.
  ///
  /// In en, this message translates to:
  /// **'Blackmail Situation'**
  String get blackmailSituation;

  /// No description provided for @blackmailGuidanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get immediate guidance on handling blackmail safely'**
  String get blackmailGuidanceSubtitle;

  /// No description provided for @blackmailWarning.
  ///
  /// In en, this message translates to:
  /// **'Do NOT pay the blackmailer. Do NOT engage further. Follow the guidance below.'**
  String get blackmailWarning;

  /// No description provided for @describeBlackmailSituation.
  ///
  /// In en, this message translates to:
  /// **'Describe the blackmail situation'**
  String get describeBlackmailSituation;

  /// No description provided for @describeBlackmailHint.
  ///
  /// In en, this message translates to:
  /// **'What are they threatening? What do they want? Include any details...'**
  String get describeBlackmailHint;

  /// No description provided for @uploadEvidenceRecommended.
  ///
  /// In en, this message translates to:
  /// **'Upload Evidence (Recommended)'**
  String get uploadEvidenceRecommended;

  /// No description provided for @screenshotsOfThreats.
  ///
  /// In en, this message translates to:
  /// **'Screenshots of threats or demands'**
  String get screenshotsOfThreats;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @filesUploaded.
  ///
  /// In en, this message translates to:
  /// **'{count} file(s) uploaded'**
  String filesUploaded(Object count);

  /// No description provided for @getSafetyGuidance.
  ///
  /// In en, this message translates to:
  /// **'Get Safety Guidance'**
  String get getSafetyGuidance;

  /// No description provided for @errorDescribeBlackmail.
  ///
  /// In en, this message translates to:
  /// **'Please describe the blackmail situation.'**
  String get errorDescribeBlackmail;

  /// No description provided for @errorUploadEvidence.
  ///
  /// In en, this message translates to:
  /// **'Please upload at least one evidence file.'**
  String get errorUploadEvidence;

  /// No description provided for @errorPickingFiles.
  ///
  /// In en, this message translates to:
  /// **'Error picking files: {error}'**
  String errorPickingFiles(Object error);

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorGeneric(Object error);

  /// No description provided for @womenHarassmentLabel.
  ///
  /// In en, this message translates to:
  /// **'Women Harassment'**
  String get womenHarassmentLabel;

  /// No description provided for @protectionLawsAndComplaint.
  ///
  /// In en, this message translates to:
  /// **'Protection laws and complaint'**
  String get protectionLawsAndComplaint;

  /// No description provided for @roadAndTrafficLawLabel.
  ///
  /// In en, this message translates to:
  /// **'Road & Traffic Law'**
  String get roadAndTrafficLawLabel;

  /// No description provided for @trafficViolationsAndFines.
  ///
  /// In en, this message translates to:
  /// **'Traffic violations and fines'**
  String get trafficViolationsAndFines;

  /// No description provided for @employmentRightsAndWages.
  ///
  /// In en, this message translates to:
  /// **'Employment rights and wages'**
  String get employmentRightsAndWages;

  /// No description provided for @onlineHarassmentAndDigitalCrimes.
  ///
  /// In en, this message translates to:
  /// **'Online harassment and digital crimes'**
  String get onlineHarassmentAndDigitalCrimes;

  /// No description provided for @bottomNavHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get bottomNavHome;

  /// No description provided for @bottomNavChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get bottomNavChat;

  /// No description provided for @bottomNavDocuments.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get bottomNavDocuments;

  /// No description provided for @bottomNavProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get bottomNavProfile;

  /// No description provided for @deleteMessageConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete message?'**
  String get deleteMessageConfirm;

  /// No description provided for @copyAction.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyAction;

  /// No description provided for @editAndResendAction.
  ///
  /// In en, this message translates to:
  /// **'Edit & Resend'**
  String get editAndResendAction;

  /// No description provided for @deleteChatAction.
  ///
  /// In en, this message translates to:
  /// **'Delete Chat'**
  String get deleteChatAction;

  /// No description provided for @firDraftHarassmentDoc.
  ///
  /// In en, this message translates to:
  /// **'FIR Draft - Harassment'**
  String get firDraftHarassmentDoc;

  /// No description provided for @pecaComplaintDoc.
  ///
  /// In en, this message translates to:
  /// **'PECA Complaint'**
  String get pecaComplaintDoc;

  /// No description provided for @labourRequestDoc.
  ///
  /// In en, this message translates to:
  /// **'Labour Request'**
  String get labourRequestDoc;

  /// No description provided for @evidenceAnalysisDoc.
  ///
  /// In en, this message translates to:
  /// **'Evidence Analysis'**
  String get evidenceAnalysisDoc;

  /// No description provided for @labourRightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Labour Rights'**
  String get labourRightsTitle;

  /// No description provided for @searchSectionsHint.
  ///
  /// In en, this message translates to:
  /// **'Search sections...'**
  String get searchSectionsHint;

  /// No description provided for @minimumWageTableTitle.
  ///
  /// In en, this message translates to:
  /// **'Minimum Wage Table'**
  String get minimumWageTableTitle;

  /// No description provided for @minimumWageTableSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Current wage rates by province'**
  String get minimumWageTableSubtitle;

  /// No description provided for @overtimeRulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Overtime Rules'**
  String get overtimeRulesTitle;

  /// No description provided for @overtimeRulesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Overtime pay calculations'**
  String get overtimeRulesSubtitle;

  /// No description provided for @paidLeaveRulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Paid Leave Rules'**
  String get paidLeaveRulesTitle;

  /// No description provided for @paidLeaveRulesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Annual, sick, and casual leave'**
  String get paidLeaveRulesSubtitle;

  /// No description provided for @contractViolationTitle.
  ///
  /// In en, this message translates to:
  /// **'Contract Violation Explainer'**
  String get contractViolationTitle;

  /// No description provided for @contractViolationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Identify contract breaches'**
  String get contractViolationSubtitle;

  /// No description provided for @complaintFilingStepsTitle.
  ///
  /// In en, this message translates to:
  /// **'Complaint Filing Steps'**
  String get complaintFilingStepsTitle;

  /// No description provided for @complaintFilingStepsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How to file labour complaint'**
  String get complaintFilingStepsSubtitle;

  /// No description provided for @applicationDraftGeneratorTitle.
  ///
  /// In en, this message translates to:
  /// **'Application Draft Generator'**
  String get applicationDraftGeneratorTitle;

  /// No description provided for @applicationDraftGeneratorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Generate labour applications'**
  String get applicationDraftGeneratorSubtitle;

  /// No description provided for @screenshotEvidenceReaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Screenshot Evidence Reader'**
  String get screenshotEvidenceReaderTitle;

  /// No description provided for @screenshotEvidenceReaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Extract salary slip data'**
  String get screenshotEvidenceReaderSubtitle;

  /// No description provided for @labourScenarioSimulatorTitle.
  ///
  /// In en, this message translates to:
  /// **'Scenario Simulator'**
  String get labourScenarioSimulatorTitle;

  /// No description provided for @labourScenarioSimulatorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn labour-related scenarios'**
  String get labourScenarioSimulatorSubtitle;

  /// No description provided for @minimumWageCheckerTitle.
  ///
  /// In en, this message translates to:
  /// **'Minimum Wage Checker'**
  String get minimumWageCheckerTitle;

  /// No description provided for @checkYourWageTitle.
  ///
  /// In en, this message translates to:
  /// **'Check Your Wage'**
  String get checkYourWageTitle;

  /// No description provided for @checkYourWageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'See if your salary meets the legal minimum wage for your province and worker type.'**
  String get checkYourWageSubtitle;

  /// No description provided for @provinceLabel.
  ///
  /// In en, this message translates to:
  /// **'Province *'**
  String get provinceLabel;

  /// No description provided for @selectProvinceHint.
  ///
  /// In en, this message translates to:
  /// **'Select province'**
  String get selectProvinceHint;

  /// No description provided for @workerTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Worker Type *'**
  String get workerTypeLabel;

  /// No description provided for @selectWorkerTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Select worker type'**
  String get selectWorkerTypeHint;

  /// No description provided for @monthlySalaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly Salary *'**
  String get monthlySalaryLabel;

  /// No description provided for @monthlySalaryHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your monthly salary'**
  String get monthlySalaryHint;

  /// No description provided for @checkMyWageButton.
  ///
  /// In en, this message translates to:
  /// **'Check My Wage'**
  String get checkMyWageButton;

  /// No description provided for @minimumWageRatesNote.
  ///
  /// In en, this message translates to:
  /// **'Minimum wage rates are set by provincial governments and updated annually.'**
  String get minimumWageRatesNote;

  /// No description provided for @roadTrafficLawTitle.
  ///
  /// In en, this message translates to:
  /// **'Road & Traffic Law'**
  String get roadTrafficLawTitle;

  /// No description provided for @trafficChallanOCRTitle.
  ///
  /// In en, this message translates to:
  /// **'Traffic Challan OCR Reader'**
  String get trafficChallanOCRTitle;

  /// No description provided for @trafficChallanOCRSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scan and identify violations'**
  String get trafficChallanOCRSubtitle;

  /// No description provided for @offenceTypesGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Offence Types Guide'**
  String get offenceTypesGuideTitle;

  /// No description provided for @offenceTypesGuideSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Recognize traffic violations'**
  String get offenceTypesGuideSubtitle;

  /// No description provided for @fineCalculatorTitle.
  ///
  /// In en, this message translates to:
  /// **'Fine Calculator'**
  String get fineCalculatorTitle;

  /// No description provided for @fineCalculatorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Calculate penalty amounts'**
  String get fineCalculatorSubtitle;

  /// No description provided for @requiredDocumentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Required Documents'**
  String get requiredDocumentsTitle;

  /// No description provided for @requiredDocumentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What to carry while driving'**
  String get requiredDocumentsSubtitle;

  /// No description provided for @policeMisbehaviorGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Police Misbehavior Guide'**
  String get policeMisbehaviorGuideTitle;

  /// No description provided for @policeMisbehaviorGuideSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Steps if officer misbehaves'**
  String get policeMisbehaviorGuideSubtitle;

  /// No description provided for @trafficScenarioSimulatorTitle.
  ///
  /// In en, this message translates to:
  /// **'Scenario Simulator'**
  String get trafficScenarioSimulatorTitle;

  /// No description provided for @trafficScenarioSimulatorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn traffic-related scenarios'**
  String get trafficScenarioSimulatorSubtitle;

  /// No description provided for @calculateTotalFineTitle.
  ///
  /// In en, this message translates to:
  /// **'Calculate Total Fine'**
  String get calculateTotalFineTitle;

  /// No description provided for @selectAllViolationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select all violations'**
  String get selectAllViolationsSubtitle;

  /// No description provided for @overSpeedingViolation.
  ///
  /// In en, this message translates to:
  /// **'Over Speeding'**
  String get overSpeedingViolation;

  /// No description provided for @redLightViolation.
  ///
  /// In en, this message translates to:
  /// **'Red Light Violation'**
  String get redLightViolation;

  /// No description provided for @noHelmetViolation.
  ///
  /// In en, this message translates to:
  /// **'No Helmet'**
  String get noHelmetViolation;

  /// No description provided for @noSeatBeltViolation.
  ///
  /// In en, this message translates to:
  /// **'No Seat Belt'**
  String get noSeatBeltViolation;

  /// No description provided for @mobileUseViolation.
  ///
  /// In en, this message translates to:
  /// **'Mobile Use'**
  String get mobileUseViolation;

  /// No description provided for @noLicenseViolation.
  ///
  /// In en, this message translates to:
  /// **'No License'**
  String get noLicenseViolation;

  /// No description provided for @womenHarassmentLawsTitle.
  ///
  /// In en, this message translates to:
  /// **'Women Harassment Laws'**
  String get womenHarassmentLawsTitle;

  /// No description provided for @protectionAgainstHarassmentActSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete law overview and'**
  String get protectionAgainstHarassmentActSubtitle;

  /// No description provided for @ombudspersonComplainStepsTitle.
  ///
  /// In en, this message translates to:
  /// **'Ombudsperson Complain Steps'**
  String get ombudspersonComplainStepsTitle;

  /// No description provided for @ombudspersonComplainStepsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How to file with Ombudsperson'**
  String get ombudspersonComplainStepsSubtitle;

  /// No description provided for @workplaceCommitteeProcedureTitle.
  ///
  /// In en, this message translates to:
  /// **'Workplace Committee Procedure'**
  String get workplaceCommitteeProcedureTitle;

  /// No description provided for @workplaceCommitteeProcedureSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Internal complaint process'**
  String get workplaceCommitteeProcedureSubtitle;

  /// No description provided for @evidenceChecklistTitle.
  ///
  /// In en, this message translates to:
  /// **'Evidence Checklist'**
  String get evidenceChecklistTitle;

  /// No description provided for @evidenceChecklistSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What evidence to collect'**
  String get evidenceChecklistSubtitle;

  /// No description provided for @draftComplaintGeneratorTitle.
  ///
  /// In en, this message translates to:
  /// **'Draft Complaint Generator'**
  String get draftComplaintGeneratorTitle;

  /// No description provided for @draftComplaintGeneratorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Step-by-step complaint form'**
  String get draftComplaintGeneratorSubtitle;

  /// No description provided for @harassmentScenarioSimulatorTitle.
  ///
  /// In en, this message translates to:
  /// **'Scenario Simulator'**
  String get harassmentScenarioSimulatorTitle;

  /// No description provided for @harassmentScenarioSimulatorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn harassment-related scenarios'**
  String get harassmentScenarioSimulatorSubtitle;

  /// No description provided for @draftComplaintTitle.
  ///
  /// In en, this message translates to:
  /// **'File Labour Complaint'**
  String get draftComplaintTitle;

  /// No description provided for @personalStepLabel.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get personalStepLabel;

  /// No description provided for @incidentStepLabel.
  ///
  /// In en, this message translates to:
  /// **'Incident'**
  String get incidentStepLabel;

  /// No description provided for @impactStepLabel.
  ///
  /// In en, this message translates to:
  /// **'Impact'**
  String get impactStepLabel;

  /// No description provided for @reliefStepLabel.
  ///
  /// In en, this message translates to:
  /// **'Relief'**
  String get reliefStepLabel;

  /// No description provided for @personalInformationTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformationTitle;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameLabel;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get fullNameHint;

  /// No description provided for @cnicNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'CNIC Number'**
  String get cnicNumberLabel;

  /// No description provided for @cnicNumberHint.
  ///
  /// In en, this message translates to:
  /// **'00000-0000000-0'**
  String get cnicNumberHint;

  /// No description provided for @phoneNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumberLabel;

  /// No description provided for @phoneNumberHint.
  ///
  /// In en, this message translates to:
  /// **'+92 300 0000000'**
  String get phoneNumberHint;

  /// No description provided for @emailAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddressLabel;

  /// No description provided for @emailAddressHint.
  ///
  /// In en, this message translates to:
  /// **'your.email@example.com'**
  String get emailAddressHint;

  /// No description provided for @designationLabel.
  ///
  /// In en, this message translates to:
  /// **'Your Designation'**
  String get designationLabel;

  /// No description provided for @designationHint.
  ///
  /// In en, this message translates to:
  /// **'Your position'**
  String get designationHint;

  /// No description provided for @workplaceNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Workplace Name'**
  String get workplaceNameLabel;

  /// No description provided for @workplaceNameHint.
  ///
  /// In en, this message translates to:
  /// **'Organization/Company name'**
  String get workplaceNameHint;

  /// No description provided for @workplaceAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Workplace Address'**
  String get workplaceAddressLabel;

  /// No description provided for @workplaceAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Complete address...'**
  String get workplaceAddressHint;

  /// No description provided for @incidentDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Incident Details'**
  String get incidentDetailsTitle;

  /// No description provided for @incidentDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date of Incident'**
  String get incidentDateLabel;

  /// No description provided for @incidentDateHint.
  ///
  /// In en, this message translates to:
  /// **'DD/MM/YYYY or date range'**
  String get incidentDateHint;

  /// No description provided for @harassmentDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description of Harassment'**
  String get harassmentDescriptionLabel;

  /// No description provided for @harassmentDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe what happened...'**
  String get harassmentDescriptionHint;

  /// No description provided for @evidenceAttachedLabel.
  ///
  /// In en, this message translates to:
  /// **'Evidence Attached'**
  String get evidenceAttachedLabel;

  /// No description provided for @evidenceAttachedHint.
  ///
  /// In en, this message translates to:
  /// **'List all evidence: screenshots, emails, messages, recordings, etc.'**
  String get evidenceAttachedHint;

  /// No description provided for @witnessNamesLabel.
  ///
  /// In en, this message translates to:
  /// **'Witness Names (if any)'**
  String get witnessNamesLabel;

  /// No description provided for @witnessNamesHint.
  ///
  /// In en, this message translates to:
  /// **'List names of witnesses, one per line...'**
  String get witnessNamesHint;

  /// No description provided for @impactOnYouTitle.
  ///
  /// In en, this message translates to:
  /// **'Impact on You'**
  String get impactOnYouTitle;

  /// No description provided for @mentalImpactLabel.
  ///
  /// In en, this message translates to:
  /// **'Mental Impact'**
  String get mentalImpactLabel;

  /// No description provided for @mentalImpactHint.
  ///
  /// In en, this message translates to:
  /// **'Describe mental effects...'**
  String get mentalImpactHint;

  /// No description provided for @emotionalImpactLabel.
  ///
  /// In en, this message translates to:
  /// **'Emotional Impact'**
  String get emotionalImpactLabel;

  /// No description provided for @emotionalImpactHint.
  ///
  /// In en, this message translates to:
  /// **'Describe emotional effects...'**
  String get emotionalImpactHint;

  /// No description provided for @safetyConcernsLabel.
  ///
  /// In en, this message translates to:
  /// **'Safety Concerns'**
  String get safetyConcernsLabel;

  /// No description provided for @safetyConcernsHint.
  ///
  /// In en, this message translates to:
  /// **'Describe any safety concerns...'**
  String get safetyConcernsHint;

  /// No description provided for @reliefSoughtTitle.
  ///
  /// In en, this message translates to:
  /// **'Relief Sought'**
  String get reliefSoughtTitle;

  /// No description provided for @selectAllThatApplySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select all that apply'**
  String get selectAllThatApplySubtitle;

  /// No description provided for @reliefApologyOption.
  ///
  /// In en, this message translates to:
  /// **'Written apology from accused'**
  String get reliefApologyOption;

  /// No description provided for @reliefTransferOption.
  ///
  /// In en, this message translates to:
  /// **'Transfer of accused to different department'**
  String get reliefTransferOption;

  /// No description provided for @reliefRemovalOption.
  ///
  /// In en, this message translates to:
  /// **'Removal/termination of accused'**
  String get reliefRemovalOption;

  /// No description provided for @reliefCompensationOption.
  ///
  /// In en, this message translates to:
  /// **'Monetary compensation for damages'**
  String get reliefCompensationOption;

  /// No description provided for @reliefDisciplinaryOption.
  ///
  /// In en, this message translates to:
  /// **'Disciplinary action against accused'**
  String get reliefDisciplinaryOption;

  /// No description provided for @reliefPolicyChangesOption.
  ///
  /// In en, this message translates to:
  /// **'Workplace policy changes'**
  String get reliefPolicyChangesOption;

  /// No description provided for @generateComplaintButton.
  ///
  /// In en, this message translates to:
  /// **'Generate Complaint Letter'**
  String get generateComplaintButton;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @backButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backButton;

  /// No description provided for @fullNameErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name.'**
  String get fullNameErrorMessage;

  /// No description provided for @cnicFormatErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter CNIC in 12345-1234567-1 format.'**
  String get cnicFormatErrorMessage;

  /// No description provided for @phoneNumberErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number.'**
  String get phoneNumberErrorMessage;

  /// No description provided for @emailAddressErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get emailAddressErrorMessage;

  /// No description provided for @designationErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter your designation.'**
  String get designationErrorMessage;

  /// No description provided for @workplaceErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter your workplace.'**
  String get workplaceErrorMessage;

  /// No description provided for @incidentDateErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Please select the incident date.'**
  String get incidentDateErrorMessage;

  /// No description provided for @incidentDescriptionErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Please describe the incident.'**
  String get incidentDescriptionErrorMessage;

  /// No description provided for @mentalImpactErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Please describe the mental impact.'**
  String get mentalImpactErrorMessage;

  /// No description provided for @emotionalImpactErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Please describe the emotional impact.'**
  String get emotionalImpactErrorMessage;

  /// No description provided for @draftDocumentTitle.
  ///
  /// In en, this message translates to:
  /// **'Draft Document'**
  String get draftDocumentTitle;

  /// No description provided for @typeStepLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get typeStepLabel;

  /// No description provided for @detailsStepLabel.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get detailsStepLabel;

  /// No description provided for @reviewStepLabel.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get reviewStepLabel;

  /// No description provided for @selectDocumentTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Document Type'**
  String get selectDocumentTypeTitle;

  /// No description provided for @firDraftTitle.
  ///
  /// In en, this message translates to:
  /// **'FIR Draft'**
  String get firDraftTitle;

  /// No description provided for @firDraftSubtitle.
  ///
  /// In en, this message translates to:
  /// **'First Information Report'**
  String get firDraftSubtitle;

  /// No description provided for @pecaComplaintTitle.
  ///
  /// In en, this message translates to:
  /// **'PECA Complaint'**
  String get pecaComplaintTitle;

  /// No description provided for @pecaComplaintSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Cyber crime complaint'**
  String get pecaComplaintSubtitle;

  /// No description provided for @harassmentComplaintTitle.
  ///
  /// In en, this message translates to:
  /// **'Harassment Complaint'**
  String get harassmentComplaintTitle;

  /// No description provided for @harassmentComplaintSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Workplace/online harassment'**
  String get harassmentComplaintSubtitle;

  /// No description provided for @labourRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Labour Request'**
  String get labourRequestTitle;

  /// No description provided for @labourRequestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Employment dispute'**
  String get labourRequestSubtitle;

  /// No description provided for @calculateOvertimePayTitle.
  ///
  /// In en, this message translates to:
  /// **'Calculate Overtime Pay'**
  String get calculateOvertimePayTitle;

  /// No description provided for @checkIfYouArePaidCorrectlyForOvertime.
  ///
  /// In en, this message translates to:
  /// **'Check if you\'re being paid correctly for overtime'**
  String get checkIfYouArePaidCorrectlyForOvertime;

  /// No description provided for @weeklyWorkingHoursLabel.
  ///
  /// In en, this message translates to:
  /// **'Weekly Working Hours *'**
  String get weeklyWorkingHoursLabel;

  /// No description provided for @weeklyWorkingHoursHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 48 hours'**
  String get weeklyWorkingHoursHint;

  /// No description provided for @overtimeHoursPerMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'Overtime Hours (per month) *'**
  String get overtimeHoursPerMonthLabel;

  /// No description provided for @overtimeHoursPerMonthHint.
  ///
  /// In en, this message translates to:
  /// **'Total overtime hours worked'**
  String get overtimeHoursPerMonthHint;

  /// No description provided for @legalOvertimeRateTitle.
  ///
  /// In en, this message translates to:
  /// **'Legal Overtime Rate'**
  String get legalOvertimeRateTitle;

  /// No description provided for @legalOvertimeRateDescription.
  ///
  /// In en, this message translates to:
  /// **'Under Pakistani labour law, overtime must be paid at 2x your regular hourly rate. Standard work week is 48 hours.'**
  String get legalOvertimeRateDescription;

  /// No description provided for @calculateOvertimePayButton.
  ///
  /// In en, this message translates to:
  /// **'Calculate Overtime Pay'**
  String get calculateOvertimePayButton;

  /// No description provided for @keepRecordsWarningText.
  ///
  /// In en, this message translates to:
  /// **'Keep records of all overtime hours worked for accurate claims'**
  String get keepRecordsWarningText;

  /// No description provided for @overtimeCalculationTitle.
  ///
  /// In en, this message translates to:
  /// **'Overtime Calculation'**
  String get overtimeCalculationTitle;

  /// No description provided for @checkLeaveEligibilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Check Leave Eligibility'**
  String get checkLeaveEligibilityTitle;

  /// No description provided for @findOutIfYouAreEntitledToPaidLeave.
  ///
  /// In en, this message translates to:
  /// **'Find out if you\'re entitled to paid leave'**
  String get findOutIfYouAreEntitledToPaidLeave;

  /// No description provided for @employmentTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Employment Type *'**
  String get employmentTypeLabel;

  /// No description provided for @selectEmploymentTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Select employment type'**
  String get selectEmploymentTypeHint;

  /// No description provided for @durationOfEmploymentMonthsLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration of Employment (months) *'**
  String get durationOfEmploymentMonthsLabel;

  /// No description provided for @howLongHaveYouWorkedHint.
  ///
  /// In en, this message translates to:
  /// **'How long have you worked here?'**
  String get howLongHaveYouWorkedHint;

  /// No description provided for @leaveTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Leave Type'**
  String get leaveTypeLabel;

  /// No description provided for @selectLeaveTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Select leave type'**
  String get selectLeaveTypeHint;

  /// No description provided for @checkEligibilityButton.
  ///
  /// In en, this message translates to:
  /// **'Check Eligibility'**
  String get checkEligibilityButton;

  /// No description provided for @paidLeaveIsALegalRightNote.
  ///
  /// In en, this message translates to:
  /// **'Paid leave is a legal right under the Factories Act and Shops & Establishments Act'**
  String get paidLeaveIsALegalRightNote;

  /// No description provided for @backPayCalculatorTitle.
  ///
  /// In en, this message translates to:
  /// **'Calculate Back Pay Owed'**
  String get backPayCalculatorTitle;

  /// No description provided for @draftLabourApplicationTitle.
  ///
  /// In en, this message translates to:
  /// **'Draft Labour Application'**
  String get draftLabourApplicationTitle;

  /// No description provided for @generateApplicationTitle.
  ///
  /// In en, this message translates to:
  /// **'Generate Application'**
  String get generateApplicationTitle;

  /// No description provided for @generateApplicationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'AI will create a legally formatted application'**
  String get generateApplicationSubtitle;

  /// No description provided for @employerNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Employer Name'**
  String get employerNameLabel;

  /// No description provided for @companyNameHint.
  ///
  /// In en, this message translates to:
  /// **'Company/organization name'**
  String get companyNameHint;

  /// No description provided for @yourFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Your full name'**
  String get yourFullNameLabel;

  /// No description provided for @asOnCnicHint.
  ///
  /// In en, this message translates to:
  /// **'As on CNIC / service record'**
  String get asOnCnicHint;

  /// No description provided for @contactLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact (phone / email)'**
  String get contactLabel;

  /// No description provided for @contactHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 03XX-XXXXXXX, name@email.com'**
  String get contactHint;

  /// No description provided for @wageCheckResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Wage Check Result'**
  String get wageCheckResultTitle;

  /// No description provided for @underpaidStatus.
  ///
  /// In en, this message translates to:
  /// **'Underpaid'**
  String get underpaidStatus;

  /// No description provided for @compliantStatus.
  ///
  /// In en, this message translates to:
  /// **'Compliant'**
  String get compliantStatus;

  /// No description provided for @underpaidMessage.
  ///
  /// In en, this message translates to:
  /// **'Your salary is below the legal minimum wage'**
  String get underpaidMessage;

  /// No description provided for @compliantMessage.
  ///
  /// In en, this message translates to:
  /// **'Your salary meets the legal minimum wage'**
  String get compliantMessage;

  /// No description provided for @wageBreakdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Wage Breakdown'**
  String get wageBreakdownTitle;

  /// No description provided for @yourSalaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Your Salary'**
  String get yourSalaryLabel;

  /// No description provided for @legalMinimumWageLabel.
  ///
  /// In en, this message translates to:
  /// **'Legal Minimum Wage'**
  String get legalMinimumWageLabel;

  /// No description provided for @differenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Difference'**
  String get differenceLabel;

  /// No description provided for @explanationTitle.
  ///
  /// In en, this message translates to:
  /// **'Explanation'**
  String get explanationTitle;

  /// No description provided for @underpaidExplanation.
  ///
  /// In en, this message translates to:
  /// **'Your monthly salary is below the legal minimum wage for your worker type and province. Your employer is legally required to pay you at least the minimum wage.'**
  String get underpaidExplanation;

  /// No description provided for @compliantExplanation.
  ///
  /// In en, this message translates to:
  /// **'Your monthly salary is at or above the reference minimum for your worker type and province. Keep salary slips and bank records as evidence.'**
  String get compliantExplanation;

  /// No description provided for @legalReferenceTitle.
  ///
  /// In en, this message translates to:
  /// **'Legal Reference'**
  String get legalReferenceTitle;

  /// No description provided for @minimumWagesOrdinanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Minimum Wages Ordinance 1961'**
  String get minimumWagesOrdinanceLabel;

  /// No description provided for @minimumWagesOrdinanceText.
  ///
  /// In en, this message translates to:
  /// **'Under Section 3 of the Minimum Wages Ordinance 1961, all employers must pay workers at least the minimum wage rate notified by the provincial government. Failure to do so is a punishable offense.'**
  String get minimumWagesOrdinanceText;

  /// No description provided for @fileLabourComplaintButton.
  ///
  /// In en, this message translates to:
  /// **'File Labour Complaint'**
  String get fileLabourComplaintButton;

  /// No description provided for @calculateBackPayButton.
  ///
  /// In en, this message translates to:
  /// **'Calculate Back Pay'**
  String get calculateBackPayButton;

  /// No description provided for @draftDemandLetterTitle.
  ///
  /// In en, this message translates to:
  /// **'Draft Demand Letter'**
  String get draftDemandLetterTitle;

  /// No description provided for @unpaidOvertimeLetterTitle.
  ///
  /// In en, this message translates to:
  /// **'Unpaid overtime — demand letter'**
  String get unpaidOvertimeLetterTitle;

  /// No description provided for @editPlaceholdersNote.
  ///
  /// In en, this message translates to:
  /// **'Edit placeholders in brackets before sending. Amounts follow your calculator inputs.'**
  String get editPlaceholdersNote;

  /// No description provided for @copyFullLetterButton.
  ///
  /// In en, this message translates to:
  /// **'Copy full letter'**
  String get copyFullLetterButton;

  /// No description provided for @signInToSaveLetter.
  ///
  /// In en, this message translates to:
  /// **'Sign in to save this letter snapshot to your account.'**
  String get signInToSaveLetter;

  /// No description provided for @runSupabaseScriptNote.
  ///
  /// In en, this message translates to:
  /// **'Run supabase_labour_wage_records_complete.sql in Supabase SQL Editor.'**
  String get runSupabaseScriptNote;

  /// No description provided for @letterCopiedMessage.
  ///
  /// In en, this message translates to:
  /// **'Letter copied to clipboard'**
  String get letterCopiedMessage;

  /// No description provided for @generatedApplicationTitle.
  ///
  /// In en, this message translates to:
  /// **'Generated Application'**
  String get generatedApplicationTitle;

  /// No description provided for @labourApplicationHeader.
  ///
  /// In en, this message translates to:
  /// **'Labour Application'**
  String get labourApplicationHeader;

  /// No description provided for @generatedByAiSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Generated by Legal Sathi AI'**
  String get generatedByAiSubtitle;

  /// No description provided for @applicationGeneratedBadge.
  ///
  /// In en, this message translates to:
  /// **'Application Generated'**
  String get applicationGeneratedBadge;

  /// No description provided for @editButton.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editButton;

  /// No description provided for @regenerateButton.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get regenerateButton;

  /// No description provided for @applicationCopiedMessage.
  ///
  /// In en, this message translates to:
  /// **'Application copied to clipboard'**
  String get applicationCopiedMessage;

  /// No description provided for @applicationRegeneratedMessage.
  ///
  /// In en, this message translates to:
  /// **'Application regenerated'**
  String get applicationRegeneratedMessage;

  /// No description provided for @fileLabourComplaintTitle.
  ///
  /// In en, this message translates to:
  /// **'File Labour Complaint'**
  String get fileLabourComplaintTitle;

  /// No description provided for @selectComplaintIssue.
  ///
  /// In en, this message translates to:
  /// **'Select the issue you want to file a complaint for:'**
  String get selectComplaintIssue;

  /// No description provided for @fileDeniedLeaveComplaintTitle.
  ///
  /// In en, this message translates to:
  /// **'File Complaint for Denied Leave'**
  String get fileDeniedLeaveComplaintTitle;

  /// No description provided for @fileDeniedLeaveComplaintSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your leave request was unfairly denied'**
  String get fileDeniedLeaveComplaintSubtitle;

  /// No description provided for @fileGeneralComplaintTitle.
  ///
  /// In en, this message translates to:
  /// **'File Labour Complaint (General)'**
  String get fileGeneralComplaintTitle;

  /// No description provided for @fileGeneralComplaintSubtitle.
  ///
  /// In en, this message translates to:
  /// **'File a general workplace complaint'**
  String get fileGeneralComplaintSubtitle;

  /// No description provided for @complaintSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Complaint saved successfully'**
  String get complaintSavedMessage;

  /// No description provided for @signInToSaveComplaint.
  ///
  /// In en, this message translates to:
  /// **'Sign in to save your complaint'**
  String get signInToSaveComplaint;

  /// No description provided for @runSupabaseSqlMessage.
  ///
  /// In en, this message translates to:
  /// **'Run supabase_labour_wage_records_complete.sql in Supabase SQL Editor'**
  String get runSupabaseSqlMessage;

  /// No description provided for @fillAllFieldsError.
  ///
  /// In en, this message translates to:
  /// **'Please fill all required fields.'**
  String get fillAllFieldsError;

  /// No description provided for @validContactError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid contact number'**
  String get validContactError;

  /// No description provided for @employerNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter employer name'**
  String get employerNameHint;

  /// No description provided for @complaintIssueLabel.
  ///
  /// In en, this message translates to:
  /// **'Complaint Issue: {complaintIssue}'**
  String complaintIssueLabel(String complaintIssue);

  /// No description provided for @complaintIssueHint.
  ///
  /// In en, this message translates to:
  /// **'Describe your complaint issue in detail'**
  String get complaintIssueHint;

  /// No description provided for @yourNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get yourNameLabel;

  /// No description provided for @yourNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get yourNameHint;

  /// No description provided for @contactInfoLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInfoLabel;

  /// No description provided for @contactInfoHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get contactInfoHint;

  /// No description provided for @selectDateHint.
  ///
  /// In en, this message translates to:
  /// **'mm/dd/yyyy'**
  String get selectDateHint;

  /// No description provided for @annualLeave.
  ///
  /// In en, this message translates to:
  /// **'Annual Leave'**
  String get annualLeave;

  /// No description provided for @sickLeave.
  ///
  /// In en, this message translates to:
  /// **'Sick Leave'**
  String get sickLeave;

  /// No description provided for @casualLeave.
  ///
  /// In en, this message translates to:
  /// **'Casual Leave'**
  String get casualLeave;

  /// No description provided for @dateOfLeaveRequestLabel.
  ///
  /// In en, this message translates to:
  /// **'Date of Leave Request'**
  String get dateOfLeaveRequestLabel;

  /// No description provided for @dateHint.
  ///
  /// In en, this message translates to:
  /// **'DD/MM/YYYY'**
  String get dateHint;

  /// No description provided for @reasonForDenialLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason for Denial'**
  String get reasonForDenialLabel;

  /// No description provided for @reasonForDenialHint.
  ///
  /// In en, this message translates to:
  /// **'Describe why your leave was denied'**
  String get reasonForDenialHint;

  /// No description provided for @aiHelperNote.
  ///
  /// In en, this message translates to:
  /// **'Our AI will help you draft a formal complaint based on your information. '**
  String get aiHelperNote;

  /// No description provided for @aiHelperNoteBold.
  ///
  /// In en, this message translates to:
  /// **'Make sure all details are accurate before proceeding.'**
  String get aiHelperNoteBold;

  /// No description provided for @proceedButton.
  ///
  /// In en, this message translates to:
  /// **'Proceed'**
  String get proceedButton;

  /// No description provided for @draftComplaintApplicationTitle.
  ///
  /// In en, this message translates to:
  /// **'Draft Complaint Application'**
  String get draftComplaintApplicationTitle;

  /// No description provided for @generatedComplaintLabel.
  ///
  /// In en, this message translates to:
  /// **'Generated Complaint'**
  String get generatedComplaintLabel;

  /// No description provided for @complaintCopiedMessage.
  ///
  /// In en, this message translates to:
  /// **'Complaint copied to clipboard'**
  String get complaintCopiedMessage;

  /// No description provided for @complaintRegeneratedMessage.
  ///
  /// In en, this message translates to:
  /// **'Complaint regenerated'**
  String get complaintRegeneratedMessage;

  /// No description provided for @copyTextButton.
  ///
  /// In en, this message translates to:
  /// **'Copy Text'**
  String get copyTextButton;

  /// No description provided for @complaintToHeader.
  ///
  /// In en, this message translates to:
  /// **'To: Labour Department / Relevant Authority'**
  String get complaintToHeader;

  /// No description provided for @complaintSubject.
  ///
  /// In en, this message translates to:
  /// **'Subject: Formal Labour Complaint'**
  String get complaintSubject;

  /// No description provided for @complaintSalutation.
  ///
  /// In en, this message translates to:
  /// **'Dear Sir/Madam,'**
  String get complaintSalutation;

  /// No description provided for @complaintBody.
  ///
  /// In en, this message translates to:
  /// **'I am writing to file a formal complaint regarding a cyber crime that I have experienced...'**
  String complaintBody(String employerName);

  /// No description provided for @complaintIssueSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Complaint Issue'**
  String get complaintIssueSectionLabel;

  /// No description provided for @complaintDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date of Incident: {incidentDate}'**
  String complaintDateLabel(String incidentDate);

  /// No description provided for @complaintMiddlePara.
  ///
  /// In en, this message translates to:
  /// **'This matter has caused significant distress and violates my rights as an employee under the applicable labour laws. I have attempted to resolve this issue internally without success.'**
  String get complaintMiddlePara;

  /// No description provided for @complaintRequestPara.
  ///
  /// In en, this message translates to:
  /// **'I hereby request that the relevant authorities investigate this matter and take appropriate action to ensure my rights are protected and such violations do not occur in the future.'**
  String get complaintRequestPara;

  /// No description provided for @complaintAvailabilityPara.
  ///
  /// In en, this message translates to:
  /// **'I am available to provide any additional information or documentation required for this investigation.'**
  String get complaintAvailabilityPara;

  /// No description provided for @complaintThankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your attention to this serious matter.'**
  String get complaintThankYou;

  /// No description provided for @complaintSignoff.
  ///
  /// In en, this message translates to:
  /// **'Sincerely,'**
  String get complaintSignoff;

  /// No description provided for @analysisResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Analysis Result'**
  String get analysisResultTitle;

  /// No description provided for @analysisCompleteLabel.
  ///
  /// In en, this message translates to:
  /// **'Analysis Complete'**
  String get analysisCompleteLabel;

  /// No description provided for @classifiedDomainLabel.
  ///
  /// In en, this message translates to:
  /// **'Classified Domain'**
  String get classifiedDomainLabel;

  /// No description provided for @summaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summaryLabel;

  /// No description provided for @extractedTextLabel.
  ///
  /// In en, this message translates to:
  /// **'Extracted Text'**
  String get extractedTextLabel;

  /// No description provided for @relevantLawsLabel.
  ///
  /// In en, this message translates to:
  /// **'Relevant Laws'**
  String get relevantLawsLabel;

  /// No description provided for @textCopiedMessage.
  ///
  /// In en, this message translates to:
  /// **'Text copied to clipboard'**
  String get textCopiedMessage;

  /// No description provided for @shareAnalysisButton.
  ///
  /// In en, this message translates to:
  /// **'Share Analysis'**
  String get shareAnalysisButton;

  /// No description provided for @shareSubject.
  ///
  /// In en, this message translates to:
  /// **'Legal Sathi Evidence Analysis'**
  String get shareSubject;

  /// No description provided for @shareHeader.
  ///
  /// In en, this message translates to:
  /// **'Legal Sathi - Evidence Analysis'**
  String get shareHeader;

  /// No description provided for @domainLabel.
  ///
  /// In en, this message translates to:
  /// **'Domain: {domain}'**
  String domainLabel(String domain);

  /// No description provided for @tagsLabel.
  ///
  /// In en, this message translates to:
  /// **'Tags: {tags}'**
  String tagsLabel(String tags);

  /// No description provided for @stepExtractText.
  ///
  /// In en, this message translates to:
  /// **'Extracting text from image…'**
  String get stepExtractText;

  /// No description provided for @stepIdentifyDomain.
  ///
  /// In en, this message translates to:
  /// **'Identifying legal domain…'**
  String get stepIdentifyDomain;

  /// No description provided for @stepFindLaws.
  ///
  /// In en, this message translates to:
  /// **'Finding relevant laws…'**
  String get stepFindLaws;

  /// No description provided for @analyzingTitle.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your evidence'**
  String get analyzingTitle;

  /// No description provided for @demoMode.
  ///
  /// In en, this message translates to:
  /// **'Demo mode (sample result)'**
  String get demoMode;

  /// No description provided for @ocrMode.
  ///
  /// In en, this message translates to:
  /// **'OCR and legal context'**
  String get ocrMode;

  /// No description provided for @errorMissingFile.
  ///
  /// In en, this message translates to:
  /// **'Missing file data. Please try uploading again.'**
  String get errorMissingFile;

  /// No description provided for @errorImageRead.
  ///
  /// In en, this message translates to:
  /// **'Could not read the image.'**
  String get errorImageRead;

  /// No description provided for @errorLowText.
  ///
  /// In en, this message translates to:
  /// **'Very little text detected. Try a clearer image.'**
  String get errorLowText;

  /// No description provided for @documentPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Document Preview'**
  String get documentPreviewTitle;

  /// No description provided for @documentGenerated.
  ///
  /// In en, this message translates to:
  /// **'Document tayar ho gaya'**
  String get documentGenerated;

  /// No description provided for @warningMessage.
  ///
  /// In en, this message translates to:
  /// **'This is a draft document. Please verify before submission.'**
  String get warningMessage;

  /// No description provided for @downloadPdf.
  ///
  /// In en, this message translates to:
  /// **'Download as PDF'**
  String get downloadPdf;

  /// No description provided for @copiedMessage.
  ///
  /// In en, this message translates to:
  /// **'Document copied to clipboard'**
  String get copiedMessage;

  /// No description provided for @downloadSoon.
  ///
  /// In en, this message translates to:
  /// **'Download feature coming soon'**
  String get downloadSoon;

  /// No description provided for @shareSoon.
  ///
  /// In en, this message translates to:
  /// **'Share feature coming soon'**
  String get shareSoon;

  /// No description provided for @firTitle.
  ///
  /// In en, this message translates to:
  /// **'FIRST INFORMATION REPORT (FIR)'**
  String get firTitle;

  /// No description provided for @pecaTitle.
  ///
  /// In en, this message translates to:
  /// **'PECA COMPLAINT'**
  String get pecaTitle;

  /// No description provided for @harassmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Harassment'**
  String get harassmentTitle;

  /// No description provided for @labourTitle.
  ///
  /// In en, this message translates to:
  /// **'LABOUR COMPLAINT'**
  String get labourTitle;

  /// No description provided for @formalComplaintTitle.
  ///
  /// In en, this message translates to:
  /// **'FORMAL COMPLAINT TO FIA CYBER CRIME WING'**
  String get formalComplaintTitle;

  /// No description provided for @policeStation.
  ///
  /// In en, this message translates to:
  /// **'Police Station: __________'**
  String get policeStation;

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District: __________'**
  String get district;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date:'**
  String get dateLabel;

  /// No description provided for @complainantDetails.
  ///
  /// In en, this message translates to:
  /// **'COMPLAINANT DETAILS:'**
  String get complainantDetails;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location: Online / Physical'**
  String get locationLabel;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'DESCRIPTION OF INCIDENT:'**
  String get description;

  /// No description provided for @relevantSections.
  ///
  /// In en, this message translates to:
  /// **'RELEVANT SECTIONS'**
  String get relevantSections;

  /// No description provided for @prayer.
  ///
  /// In en, this message translates to:
  /// **'PRAYER'**
  String get prayer;

  /// No description provided for @signatureComplainant.
  ///
  /// In en, this message translates to:
  /// **'Signature of Complainant'**
  String get signatureComplainant;

  /// No description provided for @signatureOfficer.
  ///
  /// In en, this message translates to:
  /// **'Signature of Officer'**
  String get signatureOfficer;

  /// No description provided for @enterDetails.
  ///
  /// In en, this message translates to:
  /// **'Enter your personal details'**
  String get enterDetails;

  /// No description provided for @complainantName.
  ///
  /// In en, this message translates to:
  /// **'Complainant Name'**
  String get complainantName;

  /// No description provided for @cnicNumber.
  ///
  /// In en, this message translates to:
  /// **'CNIC Number *'**
  String get cnicNumber;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Please select the date of the incident.'**
  String get selectDate;

  /// No description provided for @backBtn.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backBtn;

  /// No description provided for @reviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review Information'**
  String get reviewTitle;

  /// No description provided for @generateDocument.
  ///
  /// In en, this message translates to:
  /// **'Document banayein'**
  String get generateDocument;

  /// No description provided for @editDetails.
  ///
  /// In en, this message translates to:
  /// **'Tafseelat tabdeel karein'**
  String get editDetails;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Tafseelat'**
  String get details;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Jaiza'**
  String get review;

  /// No description provided for @notProvided.
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get notProvided;

  /// No description provided for @firSubtitle.
  ///
  /// In en, this message translates to:
  /// **'First Information Report'**
  String get firSubtitle;

  /// No description provided for @pecaComplaint.
  ///
  /// In en, this message translates to:
  /// **'PECA Complaint'**
  String get pecaComplaint;

  /// No description provided for @pecaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Cyber crime complaint'**
  String get pecaSubtitle;

  /// No description provided for @harassmentComplaint.
  ///
  /// In en, this message translates to:
  /// **'Harassment Complaint'**
  String get harassmentComplaint;

  /// No description provided for @harassmentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Workplace/online harassment'**
  String get harassmentSubtitle;

  /// No description provided for @labourRequest.
  ///
  /// In en, this message translates to:
  /// **'Labour Request'**
  String get labourRequest;

  /// No description provided for @labourSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Employment dispute'**
  String get labourSubtitle;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @analysisComplete.
  ///
  /// In en, this message translates to:
  /// **'Analysis mukammal'**
  String get analysisComplete;

  /// No description provided for @classifiedDomain.
  ///
  /// In en, this message translates to:
  /// **'Classified Domain'**
  String get classifiedDomain;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Khulasa'**
  String get summary;

  /// No description provided for @extractText.
  ///
  /// In en, this message translates to:
  /// **'Nikaala gaya text'**
  String get extractText;

  /// No description provided for @relevantLaws.
  ///
  /// In en, this message translates to:
  /// **'Mutaliqa qawaneen'**
  String get relevantLaws;

  /// No description provided for @copyText.
  ///
  /// In en, this message translates to:
  /// **'Copy karein'**
  String get copyText;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get fillAllFields;

  /// No description provided for @invalidCnic.
  ///
  /// In en, this message translates to:
  /// **'Use format 12345-1234567-1'**
  String get invalidCnic;

  /// No description provided for @reviewInformationTitle.
  ///
  /// In en, this message translates to:
  /// **'Review Information'**
  String get reviewInformationTitle;

  /// No description provided for @documentType.
  ///
  /// In en, this message translates to:
  /// **'Document Type'**
  String get documentType;

  /// No description provided for @complainant.
  ///
  /// In en, this message translates to:
  /// **'Complainant'**
  String get complainant;

  /// No description provided for @cnic.
  ///
  /// In en, this message translates to:
  /// **'CNIC'**
  String get cnic;

  /// No description provided for @generateDocumentButton.
  ///
  /// In en, this message translates to:
  /// **'Generate Document'**
  String get generateDocumentButton;

  /// No description provided for @editDetailsButton.
  ///
  /// In en, this message translates to:
  /// **'Edit Details'**
  String get editDetailsButton;

  /// No description provided for @enterDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter Details'**
  String get enterDetailsTitle;

  /// No description provided for @cnicHint.
  ///
  /// In en, this message translates to:
  /// **'00000-0000000-0'**
  String get cnicHint;

  /// No description provided for @enterAddress.
  ///
  /// In en, this message translates to:
  /// **'Complete address...'**
  String get enterAddress;

  /// No description provided for @pleaseFillFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all required fields.'**
  String get pleaseFillFields;

  /// No description provided for @cnicFormatError.
  ///
  /// In en, this message translates to:
  /// **'Enter CNIC in 12345-1234567-1 format.'**
  String get cnicFormatError;

  /// No description provided for @completeOverviewOfYourRights.
  ///
  /// In en, this message translates to:
  /// **'Complete overview of your rights'**
  String get completeOverviewOfYourRights;

  /// No description provided for @whatIsHarassment.
  ///
  /// In en, this message translates to:
  /// **'What is Online Harassment?'**
  String get whatIsHarassment;

  /// No description provided for @whatIsHarassmentDesc.
  ///
  /// In en, this message translates to:
  /// **'Any unwelcome sexual advance, request for sexual favors, or conduct of sexual nature at workplace.'**
  String get whatIsHarassmentDesc;

  /// No description provided for @whoIsProtected.
  ///
  /// In en, this message translates to:
  /// **'Who is Protected?'**
  String get whoIsProtected;

  /// No description provided for @whoIsProtectedDesc.
  ///
  /// In en, this message translates to:
  /// **'All women working in public and private organizations, including interns and trainees.'**
  String get whoIsProtectedDesc;

  /// No description provided for @employerObligationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Must establish inquiry committee, display law prominently, and take action within 3 months.'**
  String get employerObligationsDesc;

  /// No description provided for @penaltiesDesc.
  ///
  /// In en, this message translates to:
  /// **'Imprisonment up to 3 years and/or fine up to Rs. 1 million.'**
  String get penaltiesDesc;

  /// No description provided for @lawAppliesNote.
  ///
  /// In en, this message translates to:
  /// **'This law applies to all workplaces in Pakistan with 3 or more employees.'**
  String get lawAppliesNote;

  /// No description provided for @internalComplaint.
  ///
  /// In en, this message translates to:
  /// **'Internal Complaint'**
  String get internalComplaint;

  /// No description provided for @dateOfIncident.
  ///
  /// In en, this message translates to:
  /// **'Date of Incident'**
  String get dateOfIncident;

  /// No description provided for @dateFormatHint.
  ///
  /// In en, this message translates to:
  /// **'DD/MM/YYYY or date range'**
  String get dateFormatHint;

  /// No description provided for @typeOfHarassment.
  ///
  /// In en, this message translates to:
  /// **'Type of Harassment'**
  String get typeOfHarassment;

  /// No description provided for @verbalHarassment.
  ///
  /// In en, this message translates to:
  /// **'Verbal harassment'**
  String get verbalHarassment;

  /// No description provided for @physicalHarassment.
  ///
  /// In en, this message translates to:
  /// **'Physical harassment'**
  String get physicalHarassment;

  /// No description provided for @cyberHarassment.
  ///
  /// In en, this message translates to:
  /// **'Cyber harassment'**
  String get cyberHarassment;

  /// No description provided for @stalking.
  ///
  /// In en, this message translates to:
  /// **'Stalking'**
  String get stalking;

  /// No description provided for @intimidation.
  ///
  /// In en, this message translates to:
  /// **'Intimidation'**
  String get intimidation;

  /// No description provided for @detailedDescription.
  ///
  /// In en, this message translates to:
  /// **'Detailed Description'**
  String get detailedDescription;

  /// No description provided for @describeIncidentHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the incident...'**
  String get describeIncidentHint;

  /// No description provided for @accusedPersonName.
  ///
  /// In en, this message translates to:
  /// **'Accused Person\'s Name'**
  String get accusedPersonName;

  /// No description provided for @accusedPersonDesignation.
  ///
  /// In en, this message translates to:
  /// **'Accused Person\'s Designation'**
  String get accusedPersonDesignation;

  /// No description provided for @jobTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Job title'**
  String get jobTitleHint;

  /// No description provided for @addSupportingDocuments.
  ///
  /// In en, this message translates to:
  /// **'Add supporting documents'**
  String get addSupportingDocuments;

  /// No description provided for @witnessNames.
  ///
  /// In en, this message translates to:
  /// **'Witness Names (if any)'**
  String get witnessNames;

  /// No description provided for @listWitnessesHint.
  ///
  /// In en, this message translates to:
  /// **'List witnesses...'**
  String get listWitnessesHint;

  /// No description provided for @continueToPreview.
  ///
  /// In en, this message translates to:
  /// **'Continue to Preview'**
  String get continueToPreview;

  /// No description provided for @strongEvidenceStrengthensCase.
  ///
  /// In en, this message translates to:
  /// **'Strong evidence strengthens your case'**
  String get strongEvidenceStrengthensCase;

  /// No description provided for @secondaryEvidence.
  ///
  /// In en, this message translates to:
  /// **'Secondary Evidence'**
  String get secondaryEvidence;

  /// No description provided for @evidenceCollectionGuidanceSection.
  ///
  /// In en, this message translates to:
  /// **'Evidence Collection Guidance'**
  String get evidenceCollectionGuidanceSection;

  /// No description provided for @howToCollectEvidenceLegally.
  ///
  /// In en, this message translates to:
  /// **'How to Collect Evidence Legally'**
  String get howToCollectEvidenceLegally;

  /// No description provided for @takeScreenshotsWithTimestamps.
  ///
  /// In en, this message translates to:
  /// **'Take screenshots with visible timestamps'**
  String get takeScreenshotsWithTimestamps;

  /// No description provided for @keepOriginalFilesSubmitCopies.
  ///
  /// In en, this message translates to:
  /// **'Keep original files, submit copies'**
  String get keepOriginalFilesSubmitCopies;

  /// No description provided for @documentDatesTimesLocations.
  ///
  /// In en, this message translates to:
  /// **'Document dates, times, and locations'**
  String get documentDatesTimesLocations;

  /// No description provided for @getWitnessStatementsWriting.
  ///
  /// In en, this message translates to:
  /// **'Get witness statements in writing'**
  String get getWitnessStatementsWriting;

  /// No description provided for @requestCCTVProperChannels.
  ///
  /// In en, this message translates to:
  /// **'Request CCTV through proper channels'**
  String get requestCCTVProperChannels;

  /// No description provided for @whatNotToDo.
  ///
  /// In en, this message translates to:
  /// **'What NOT to Do'**
  String get whatNotToDo;

  /// No description provided for @dontRecordCallsWithoutConsent.
  ///
  /// In en, this message translates to:
  /// **'Don\'t record calls without consent (illegal in Pakistan)'**
  String get dontRecordCallsWithoutConsent;

  /// No description provided for @dontAlterOrEditEvidence.
  ///
  /// In en, this message translates to:
  /// **'Don\'t alter or edit evidence'**
  String get dontAlterOrEditEvidence;

  /// No description provided for @dontDeleteOriginalMessages.
  ///
  /// In en, this message translates to:
  /// **'Don\'t delete original messages'**
  String get dontDeleteOriginalMessages;

  /// No description provided for @dontTrespassObtainEvidence.
  ///
  /// In en, this message translates to:
  /// **'Don\'t trespass to obtain evidence'**
  String get dontTrespassObtainEvidence;

  /// No description provided for @dontShareEvidencePublicly.
  ///
  /// In en, this message translates to:
  /// **'Don\'t share evidence publicly before filing'**
  String get dontShareEvidencePublicly;

  /// No description provided for @readyToSubmit.
  ///
  /// In en, this message translates to:
  /// **'Ready to Submit!'**
  String get readyToSubmit;

  /// No description provided for @howToSubmitInternally.
  ///
  /// In en, this message translates to:
  /// **'How to Submit Internally'**
  String get howToSubmitInternally;

  /// No description provided for @internalComplaintProcedureStep1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Submit to Committee'**
  String get internalComplaintProcedureStep1Title;

  /// No description provided for @internalComplaintProcedureStep1Desc.
  ///
  /// In en, this message translates to:
  /// **'Send the complaint to the chairperson of the harassment inquiry committee by hand or email'**
  String get internalComplaintProcedureStep1Desc;

  /// No description provided for @internalComplaintProcedureStep2Title.
  ///
  /// In en, this message translates to:
  /// **'2. Through HR Department'**
  String get internalComplaintProcedureStep2Title;

  /// No description provided for @internalComplaintProcedureStep2Desc.
  ///
  /// In en, this message translates to:
  /// **'Submit through HR with proper receipt acknowledgment'**
  String get internalComplaintProcedureStep2Desc;

  /// No description provided for @internalComplaintProcedureStep3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Obtain Diary Number'**
  String get internalComplaintProcedureStep3Title;

  /// No description provided for @internalComplaintProcedureStep3Desc.
  ///
  /// In en, this message translates to:
  /// **'Get official receipt with date and reference number'**
  String get internalComplaintProcedureStep3Desc;

  /// No description provided for @timeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timeline;

  /// No description provided for @timeline1.
  ///
  /// In en, this message translates to:
  /// **'Committee must start inquiry within 7 days'**
  String get timeline1;

  /// No description provided for @timeline2.
  ///
  /// In en, this message translates to:
  /// **'Inquiry completes within 30 days'**
  String get timeline2;

  /// No description provided for @timeline3.
  ///
  /// In en, this message translates to:
  /// **'Employer implements recommendations within 7 days'**
  String get timeline3;

  /// No description provided for @emailToHR.
  ///
  /// In en, this message translates to:
  /// **'Email to HR'**
  String get emailToHR;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Keep copies of all documents and receipts'**
  String get note;

  /// No description provided for @followStepsFileWithFederalOmbudsperson.
  ///
  /// In en, this message translates to:
  /// **'Follow these steps to file with the Federal Ombudsperson'**
  String get followStepsFileWithFederalOmbudsperson;

  /// No description provided for @submitComplaintWithin3Months.
  ///
  /// In en, this message translates to:
  /// **'Submit complaint within 3 months'**
  String get submitComplaintWithin3Months;

  /// No description provided for @attachAllEvidence.
  ///
  /// In en, this message translates to:
  /// **'Attach all evidence and documents'**
  String get attachAllEvidence;

  /// No description provided for @ombudspersonConductsInquiry.
  ///
  /// In en, this message translates to:
  /// **'Ombudsperson conducts inquiry'**
  String get ombudspersonConductsInquiry;

  /// No description provided for @decisionWithin90Days.
  ///
  /// In en, this message translates to:
  /// **'Decision within 90 Days'**
  String get decisionWithin90Days;

  /// No description provided for @finalDecisionWithin90Days.
  ///
  /// In en, this message translates to:
  /// **'Final decision is given within 90 days'**
  String get finalDecisionWithin90Days;

  /// No description provided for @organizationImplementDecision.
  ///
  /// In en, this message translates to:
  /// **'Organization implements decision'**
  String get organizationImplementDecision;

  /// No description provided for @startOmbudspersonComplaint.
  ///
  /// In en, this message translates to:
  /// **'Start Ombudsperson Complaint'**
  String get startOmbudspersonComplaint;

  /// No description provided for @organizationInquiryCommittee.
  ///
  /// In en, this message translates to:
  /// **'Your organization must have an inquiry committee'**
  String get organizationInquiryCommittee;

  /// No description provided for @workplaceCommitteeComposition.
  ///
  /// In en, this message translates to:
  /// **'Committee Composition'**
  String get workplaceCommitteeComposition;

  /// No description provided for @committeeMembersMinimum.
  ///
  /// In en, this message translates to:
  /// **'At least 3 members'**
  String get committeeMembersMinimum;

  /// No description provided for @atLeastOneWomanMember.
  ///
  /// In en, this message translates to:
  /// **'At least one woman member'**
  String get atLeastOneWomanMember;

  /// No description provided for @seniorManagementRepresentative.
  ///
  /// In en, this message translates to:
  /// **'One senior management representative'**
  String get seniorManagementRepresentative;

  /// No description provided for @filingProcess.
  ///
  /// In en, this message translates to:
  /// **'Filing Process'**
  String get filingProcess;

  /// No description provided for @submitWrittenComplaint.
  ///
  /// In en, this message translates to:
  /// **'Submit a written complaint'**
  String get submitWrittenComplaint;

  /// No description provided for @withinThreeDaysOfIncident.
  ///
  /// In en, this message translates to:
  /// **'Within 3 days of incident'**
  String get withinThreeDaysOfIncident;

  /// No description provided for @includeAllEvidenceAndWitnesses.
  ///
  /// In en, this message translates to:
  /// **'Include evidence and witnesses'**
  String get includeAllEvidenceAndWitnesses;

  /// No description provided for @committeeCompleteInquiry30Days.
  ///
  /// In en, this message translates to:
  /// **'Complete within 30 days'**
  String get committeeCompleteInquiry30Days;

  /// No description provided for @bothPartiesFairHearing.
  ///
  /// In en, this message translates to:
  /// **'Fair hearing for both parties'**
  String get bothPartiesFairHearing;

  /// No description provided for @confidentialityMaintained.
  ///
  /// In en, this message translates to:
  /// **'Confidentiality maintained'**
  String get confidentialityMaintained;

  /// No description provided for @warningToAccused.
  ///
  /// In en, this message translates to:
  /// **'Warning to accused'**
  String get warningToAccused;

  /// No description provided for @transferOrSuspension.
  ///
  /// In en, this message translates to:
  /// **'Transfer or suspension'**
  String get transferOrSuspension;

  /// No description provided for @terminationForSeriousCases.
  ///
  /// In en, this message translates to:
  /// **'Termination for serious cases'**
  String get terminationForSeriousCases;

  /// No description provided for @compensationToComplainant.
  ///
  /// In en, this message translates to:
  /// **'Compensation to complainant'**
  String get compensationToComplainant;

  /// No description provided for @ifCommitteeDoesNotExist.
  ///
  /// In en, this message translates to:
  /// **'If committee does not exist, contact '**
  String get ifCommitteeDoesNotExist;

  /// No description provided for @ombudsperson.
  ///
  /// In en, this message translates to:
  /// **'Ombudsperson'**
  String get ombudsperson;

  /// No description provided for @startInternalComplaint.
  ///
  /// In en, this message translates to:
  /// **'Start Internal Complaint'**
  String get startInternalComplaint;

  /// No description provided for @viewRightsAndEscalation.
  ///
  /// In en, this message translates to:
  /// **'View Rights & Escalation'**
  String get viewRightsAndEscalation;

  /// No description provided for @workplaceCommittee.
  ///
  /// In en, this message translates to:
  /// **'Workplace Committee'**
  String get workplaceCommittee;

  /// No description provided for @committeeCheck.
  ///
  /// In en, this message translates to:
  /// **'Committee Check'**
  String get committeeCheck;

  /// No description provided for @committeeQuestion.
  ///
  /// In en, this message translates to:
  /// **'Does your workplace have a Harassment Inquiry Committee?'**
  String get committeeQuestion;

  /// No description provided for @yesCommittee.
  ///
  /// In en, this message translates to:
  /// **'Yes, we have a committee'**
  String get yesCommittee;

  /// No description provided for @fileInternalComplaint.
  ///
  /// In en, this message translates to:
  /// **'File internal complaint'**
  String get fileInternalComplaint;

  /// No description provided for @noCommittee.
  ///
  /// In en, this message translates to:
  /// **'No committee exists'**
  String get noCommittee;

  /// No description provided for @fileWithOmbudsperson.
  ///
  /// In en, this message translates to:
  /// **'File with Ombudsperson'**
  String get fileWithOmbudsperson;

  /// No description provided for @dontKnow.
  ///
  /// In en, this message translates to:
  /// **'I don\'t know'**
  String get dontKnow;

  /// No description provided for @checkWithHR.
  ///
  /// In en, this message translates to:
  /// **'Check with HR first'**
  String get checkWithHR;

  /// No description provided for @noCommitteeInfo.
  ///
  /// In en, this message translates to:
  /// **'Organizations with 3+ employees must have a committee. You can file directly with the Ombudsperson.'**
  String get noCommitteeInfo;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @employerNote.
  ///
  /// In en, this message translates to:
  /// **'If the accused is your employer, file directly with Ombudsperson'**
  String get employerNote;

  /// No description provided for @ombudspersonComplaint.
  ///
  /// In en, this message translates to:
  /// **'Ombudsperson Complaint'**
  String get ombudspersonComplaint;

  /// No description provided for @addSupportingDocs.
  ///
  /// In en, this message translates to:
  /// **'Add supporting documents and witness information'**
  String get addSupportingDocs;

  /// No description provided for @whatsappChats.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Chats'**
  String get whatsappChats;

  /// No description provided for @audioFiles.
  ///
  /// In en, this message translates to:
  /// **'Audio Files'**
  String get audioFiles;

  /// No description provided for @videoFiles.
  ///
  /// In en, this message translates to:
  /// **'Video Files'**
  String get videoFiles;

  /// No description provided for @uploadedFiles.
  ///
  /// In en, this message translates to:
  /// **'Uploaded Files'**
  String get uploadedFiles;

  /// No description provided for @witnessHint.
  ///
  /// In en, this message translates to:
  /// **'List names and contact info of witnesses, one per line'**
  String get witnessHint;

  /// No description provided for @continuePreview.
  ///
  /// In en, this message translates to:
  /// **'Continue to Preview'**
  String get continuePreview;

  /// No description provided for @filesAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'file(s) added successfully'**
  String get filesAddedSuccessfully;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @invalidWitness.
  ///
  /// In en, this message translates to:
  /// **'Please provide valid witness information'**
  String get invalidWitness;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @incident.
  ///
  /// In en, this message translates to:
  /// **'Incident'**
  String get incident;

  /// No description provided for @evidence.
  ///
  /// In en, this message translates to:
  /// **'Evidence'**
  String get evidence;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @aiWillExtractTimestamps.
  ///
  /// In en, this message translates to:
  /// **'AI will extract timestamps, numbers, URLs, and classify threats'**
  String get aiWillExtractTimestamps;

  /// No description provided for @uploadScreenshotsMessages.
  ///
  /// In en, this message translates to:
  /// **'Upload screenshots, messages, or text logs'**
  String get uploadScreenshotsMessages;

  /// No description provided for @textLogs.
  ///
  /// In en, this message translates to:
  /// **'Text Logs'**
  String get textLogs;

  /// No description provided for @uploadedEvidenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Uploaded Evidence'**
  String get uploadedEvidenceLabel;

  /// No description provided for @extractDataWithAi.
  ///
  /// In en, this message translates to:
  /// **'Extract Data with AI'**
  String get extractDataWithAi;

  /// No description provided for @whatAiExtracts.
  ///
  /// In en, this message translates to:
  /// **'What AI Extracts:'**
  String get whatAiExtracts;

  /// No description provided for @timestampsAndDates.
  ///
  /// In en, this message translates to:
  /// **'Timestamps and dates'**
  String get timestampsAndDates;

  /// No description provided for @phoneNumbersAndEmails.
  ///
  /// In en, this message translates to:
  /// **'Phone numbers and email addresses'**
  String get phoneNumbersAndEmails;

  /// No description provided for @urlsAndSocialMedia.
  ///
  /// In en, this message translates to:
  /// **'URLs and social media links'**
  String get urlsAndSocialMedia;

  /// No description provided for @threatClassificationLabel.
  ///
  /// In en, this message translates to:
  /// **'Threat classification (harassment, blackmail, violence)'**
  String get threatClassificationLabel;

  /// No description provided for @keyPhrasesAndEvidence.
  ///
  /// In en, this message translates to:
  /// **'Key phrases and evidence markers'**
  String get keyPhrasesAndEvidence;

  /// No description provided for @supportedFormatsMessage.
  ///
  /// In en, this message translates to:
  /// **'Supported formats: JPG, PNG, PDF, TXT (max 10MB each)'**
  String get supportedFormatsMessage;

  /// No description provided for @noImagesSelected.
  ///
  /// In en, this message translates to:
  /// **'No images selected'**
  String get noImagesSelected;

  /// No description provided for @errorUploadingScreenshots.
  ///
  /// In en, this message translates to:
  /// **'Error uploading screenshots'**
  String get errorUploadingScreenshots;

  /// No description provided for @errorUploadingTextLogs.
  ///
  /// In en, this message translates to:
  /// **'Error uploading text logs'**
  String get errorUploadingTextLogs;

  /// No description provided for @noFilesSelectedTryAgain.
  ///
  /// In en, this message translates to:
  /// **'No files selected. Please try again.'**
  String get noFilesSelectedTryAgain;

  /// No description provided for @invalidFileDetected.
  ///
  /// In en, this message translates to:
  /// **'Invalid file detected. Please try again.'**
  String get invalidFileDetected;

  /// No description provided for @fileExceedsLimitMB.
  ///
  /// In en, this message translates to:
  /// **'File {fileName} exceeds 10MB limit'**
  String fileExceedsLimitMB(String fileName);

  /// No description provided for @noValidFilesCheck.
  ///
  /// In en, this message translates to:
  /// **'No valid files to add. Please check file size and format.'**
  String get noValidFilesCheck;

  /// No description provided for @maximumFilesAllowed.
  ///
  /// In en, this message translates to:
  /// **'Maximum 10 files allowed. You can add {remaining} more file(s).'**
  String maximumFilesAllowed(int remaining);

  /// No description provided for @filesAddedSuccessfullyCount.
  ///
  /// In en, this message translates to:
  /// **'{count} file(s) added successfully'**
  String filesAddedSuccessfullyCount(int count);

  /// No description provided for @pleaseUploadAtLeastOneFile.
  ///
  /// In en, this message translates to:
  /// **'Please upload at least one file'**
  String get pleaseUploadAtLeastOneFile;

  /// No description provided for @fiaComplaintGenerator.
  ///
  /// In en, this message translates to:
  /// **'FIA Complaint Generator'**
  String get fiaComplaintGenerator;

  /// No description provided for @fileFiaComplaint.
  ///
  /// In en, this message translates to:
  /// **'File FIA Complaint'**
  String get fileFiaComplaint;

  /// No description provided for @fillDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fill in your details to generate a formal complaint'**
  String get fillDetailsSubtitle;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number *'**
  String get phoneNumber;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address *'**
  String get emailAddress;

  /// No description provided for @suspectInfo.
  ///
  /// In en, this message translates to:
  /// **'Suspect Information (if known)'**
  String get suspectInfo;

  /// No description provided for @evidenceAvailable.
  ///
  /// In en, this message translates to:
  /// **'Evidence Available'**
  String get evidenceAvailable;

  /// No description provided for @generateFiaComplaint.
  ///
  /// In en, this message translates to:
  /// **'Generate FIA Complaint'**
  String get generateFiaComplaint;

  /// No description provided for @fillRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all required fields.'**
  String get fillRequiredFields;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number (at least 10 digits)'**
  String get invalidPhone;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get invalidEmail;

  /// No description provided for @complaintSaved.
  ///
  /// In en, this message translates to:
  /// **'Complaint saved to your account.'**
  String get complaintSaved;

  /// No description provided for @complaintGeneratedWarning.
  ///
  /// In en, this message translates to:
  /// **'Complaint generated. To store in DB, run supabase SQL script.'**
  String get complaintGeneratedWarning;

  /// No description provided for @fiaComplaintInfo.
  ///
  /// In en, this message translates to:
  /// **'This will generate a formal complaint letter that you can submit to FIA Cyber Crime Wing'**
  String get fiaComplaintInfo;

  /// No description provided for @generatedComplaint.
  ///
  /// In en, this message translates to:
  /// **'Generated Complaint'**
  String get generatedComplaint;

  /// No description provided for @complaintGeneratedSuccess.
  ///
  /// In en, this message translates to:
  /// **'FIA Complaint Generated Successfully'**
  String get complaintGeneratedSuccess;

  /// No description provided for @yourFiaComplaint.
  ///
  /// In en, this message translates to:
  /// **'Your FIA Complaint'**
  String get yourFiaComplaint;

  /// No description provided for @reviewEditDownload.
  ///
  /// In en, this message translates to:
  /// **'Review, edit, and download your complaint'**
  String get reviewEditDownload;

  /// No description provided for @fiaCyberCrimeComplaint.
  ///
  /// In en, this message translates to:
  /// **'FIA Cyber Crime Complaint'**
  String get fiaCyberCrimeComplaint;

  /// No description provided for @generatedBy.
  ///
  /// In en, this message translates to:
  /// **'Generated by Legal Sathi AI'**
  String get generatedBy;

  /// No description provided for @downloadTxt.
  ///
  /// In en, this message translates to:
  /// **'Download as TXT'**
  String get downloadTxt;

  /// No description provided for @copyClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy to Clipboard'**
  String get copyClipboard;

  /// No description provided for @copiedClipboard.
  ///
  /// In en, this message translates to:
  /// **'Complaint copied to clipboard'**
  String get copiedClipboard;

  /// No description provided for @errorSaving.
  ///
  /// In en, this message translates to:
  /// **'Could not save complaint.'**
  String get errorSaving;

  /// No description provided for @personalinfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalinfo;

  /// No description provided for @nextSteps.
  ///
  /// In en, this message translates to:
  /// **'Next Steps:'**
  String get nextSteps;

  /// No description provided for @step1.
  ///
  /// In en, this message translates to:
  /// **'1. Print and sign the complaint'**
  String get step1;

  /// No description provided for @step2.
  ///
  /// In en, this message translates to:
  /// **'2. Attach all evidence (screenshots, documents)'**
  String get step2;

  /// No description provided for @step3.
  ///
  /// In en, this message translates to:
  /// **'3. Submit to nearest FIA Cyber Crime office'**
  String get step3;

  /// No description provided for @step4.
  ///
  /// In en, this message translates to:
  /// **'4. Or file online at complaint.fia.gov.pk'**
  String get step4;

  /// No description provided for @toDirector.
  ///
  /// In en, this message translates to:
  /// **'To: Director, FIA Cyber Crime Wing'**
  String get toDirector;

  /// No description provided for @sampleName.
  ///
  /// In en, this message translates to:
  /// **'Name:'**
  String get sampleName;

  /// No description provided for @sampleCnic.
  ///
  /// In en, this message translates to:
  /// **'CNIC:'**
  String get sampleCnic;

  /// No description provided for @samplePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone:'**
  String get samplePhone;

  /// No description provided for @sampleEmail.
  ///
  /// In en, this message translates to:
  /// **'Email:'**
  String get sampleEmail;

  /// No description provided for @sampleAddress.
  ///
  /// In en, this message translates to:
  /// **'Address:'**
  String get sampleAddress;

  /// No description provided for @subject.
  ///
  /// In en, this message translates to:
  /// **'Subject: Complaint Against Police Officer Misbehavior'**
  String get subject;

  /// No description provided for @respected.
  ///
  /// In en, this message translates to:
  /// **'Respected Sir/Madam,'**
  String get respected;

  /// No description provided for @fiaHelpline.
  ///
  /// In en, this message translates to:
  /// **'FIA Cyber Crime Helpline: 1991 | Website: complaint.fia.gov.pk'**
  String get fiaHelpline;

  /// No description provided for @sampleComplaintText.
  ///
  /// In en, this message translates to:
  /// **'FORMAL COMPLAINT TO FIA CYBER CRIME WING\n\nTo: Director, FIA Cyber Crime Wing\nDate: [Enter Date]\n\nCOMPLAINANT DETAILS:\nName: [Your Name]\nCNIC: [Your CNIC]\nPhone: [Your Phone Number]\nEmail: [Your Email]\nAddress: [Your Address]\n\nSUBJECT: Formal Complaint of Cyber Crime under PECA\n\nRespected Sir/Madam,\n\nI am writing to file a formal complaint regarding a cyber crime that I have experienced. This complaint is being submitted under the Prevention of Electronic Crimes Act (PECA), 2016.\n\nI request the concerned authorities to kindly investigate this matter and take appropriate legal action.\n\nSincerely,\n[Your Name]'**
  String get sampleComplaintText;

  /// No description provided for @screenshotReaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Screenshot Evidence Reader'**
  String get screenshotReaderTitle;

  /// No description provided for @uploadScreenshot.
  ///
  /// In en, this message translates to:
  /// **'Upload Screenshot'**
  String get uploadScreenshot;

  /// No description provided for @webDescription.
  ///
  /// In en, this message translates to:
  /// **'We read text from your image, classify the legal area, suggest relevant laws, then you can generate a draft document.'**
  String get webDescription;

  /// No description provided for @mobileDescription.
  ///
  /// In en, this message translates to:
  /// **'Text is read on-device when possible, then analyzed via the Legal Sathi backend.'**
  String get mobileDescription;

  /// No description provided for @tapToUpload.
  ///
  /// In en, this message translates to:
  /// **'Tap to upload'**
  String get tapToUpload;

  /// No description provided for @fileFormatInfo.
  ///
  /// In en, this message translates to:
  /// **'PNG, JPG, WebP — up to 10 MB'**
  String get fileFormatInfo;

  /// No description provided for @tryDemo.
  ///
  /// In en, this message translates to:
  /// **'Try demo (sample analysis)'**
  String get tryDemo;

  /// No description provided for @whatWeDo.
  ///
  /// In en, this message translates to:
  /// **'What we do:'**
  String get whatWeDo;

  /// No description provided for @ocrText.
  ///
  /// In en, this message translates to:
  /// **'Extract text (OCR)'**
  String get ocrText;

  /// No description provided for @identifyDomain.
  ///
  /// In en, this message translates to:
  /// **'Identify legal domain'**
  String get identifyDomain;

  /// No description provided for @suggestLaws.
  ///
  /// In en, this message translates to:
  /// **'Suggest relevant laws (indicative)'**
  String get suggestLaws;

  /// No description provided for @generateDraft.
  ///
  /// In en, this message translates to:
  /// **'Generate a draft document in the next step'**
  String get generateDraft;

  /// No description provided for @errorReadingImage.
  ///
  /// In en, this message translates to:
  /// **'Could not read the image.'**
  String get errorReadingImage;

  /// No description provided for @imageSizeError.
  ///
  /// In en, this message translates to:
  /// **'Image must be under 10 MB.'**
  String get imageSizeError;

  /// No description provided for @defaultFileName.
  ///
  /// In en, this message translates to:
  /// **'screenshot.jpg'**
  String get defaultFileName;

  /// No description provided for @errorLabel.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorLabel;

  /// No description provided for @safetyGuidance.
  ///
  /// In en, this message translates to:
  /// **'Safety Guidance'**
  String get safetyGuidance;

  /// No description provided for @criticalDoNotPay.
  ///
  /// In en, this message translates to:
  /// **'Critical: Do Not Pay'**
  String get criticalDoNotPay;

  /// No description provided for @followStepsImmediately.
  ///
  /// In en, this message translates to:
  /// **'Follow these steps immediately'**
  String get followStepsImmediately;

  /// No description provided for @aiSummary.
  ///
  /// In en, this message translates to:
  /// **'AI Summary'**
  String get aiSummary;

  /// No description provided for @immediateActions.
  ///
  /// In en, this message translates to:
  /// **'Immediate Actions'**
  String get immediateActions;

  /// No description provided for @reportingSteps.
  ///
  /// In en, this message translates to:
  /// **'Reporting Steps'**
  String get reportingSteps;

  /// No description provided for @legalOptions.
  ///
  /// In en, this message translates to:
  /// **'Legal Options (PECA)'**
  String get legalOptions;

  /// No description provided for @extractedEvidencePreview.
  ///
  /// In en, this message translates to:
  /// **'Extracted Evidence Preview'**
  String get extractedEvidencePreview;

  /// No description provided for @seriousCrimeNotice.
  ///
  /// In en, this message translates to:
  /// **'This is a serious crime with severe penalties'**
  String get seriousCrimeNotice;

  /// No description provided for @actionDoNotPay.
  ///
  /// In en, this message translates to:
  /// **'DO NOT pay any money or comply with demands'**
  String get actionDoNotPay;

  /// No description provided for @actionDoNotDelete.
  ///
  /// In en, this message translates to:
  /// **'DO NOT delete any messages or evidence'**
  String get actionDoNotDelete;

  /// No description provided for @actionStopCommunication.
  ///
  /// In en, this message translates to:
  /// **'Stop all communication with the blackmailer immediately'**
  String get actionStopCommunication;

  /// No description provided for @actionBlockPerson.
  ///
  /// In en, this message translates to:
  /// **'Block the person on all platforms'**
  String get actionBlockPerson;

  /// No description provided for @actionChangePasswords.
  ///
  /// In en, this message translates to:
  /// **'Change your passwords on all accounts'**
  String get actionChangePasswords;

  /// No description provided for @actionEnable2FA.
  ///
  /// In en, this message translates to:
  /// **'Enable two-factor authentication everywhere'**
  String get actionEnable2FA;

  /// No description provided for @actionReportImages.
  ///
  /// In en, this message translates to:
  /// **'Report intimate images to platform immediately (they have takedown policies)'**
  String get actionReportImages;

  /// No description provided for @actionDocumentPlatforms.
  ///
  /// In en, this message translates to:
  /// **'Document all platforms where content may be shared'**
  String get actionDocumentPlatforms;

  /// No description provided for @actionAlertBank.
  ///
  /// In en, this message translates to:
  /// **'Alert your bank about potential fraud'**
  String get actionAlertBank;

  /// No description provided for @actionMonitorAccounts.
  ///
  /// In en, this message translates to:
  /// **'Monitor your financial accounts closely'**
  String get actionMonitorAccounts;

  /// No description provided for @actionPrivateAccounts.
  ///
  /// In en, this message translates to:
  /// **'Set all social media accounts to private'**
  String get actionPrivateAccounts;

  /// No description provided for @actionLimitFriends.
  ///
  /// In en, this message translates to:
  /// **'Review and limit who can see your friend list'**
  String get actionLimitFriends;

  /// No description provided for @evidenceScreenshot.
  ///
  /// In en, this message translates to:
  /// **'Screenshot all threatening messages with timestamps'**
  String get evidenceScreenshot;

  /// No description provided for @evidenceSaveContacts.
  ///
  /// In en, this message translates to:
  /// **'Save phone numbers, email addresses, social media profiles'**
  String get evidenceSaveContacts;

  /// No description provided for @evidenceDocumentDetails.
  ///
  /// In en, this message translates to:
  /// **'Document dates, times, and methods of contact'**
  String get evidenceDocumentDetails;

  /// No description provided for @evidenceKeepOriginal.
  ///
  /// In en, this message translates to:
  /// **'Keep original files/messages (do not edit)'**
  String get evidenceKeepOriginal;

  /// No description provided for @evidenceInformTrusted.
  ///
  /// In en, this message translates to:
  /// **'Inform trusted family member or friend'**
  String get evidenceInformTrusted;

  /// No description provided for @evidenceDeactivateSocial.
  ///
  /// In en, this message translates to:
  /// **'Consider deactivating social media temporarily'**
  String get evidenceDeactivateSocial;

  /// No description provided for @evidenceEmailHeaders.
  ///
  /// In en, this message translates to:
  /// **'Save email headers (View > Show Original in Gmail)'**
  String get evidenceEmailHeaders;

  /// No description provided for @evidenceKeepEmails.
  ///
  /// In en, this message translates to:
  /// **'Do not mark emails as spam - keep them as evidence'**
  String get evidenceKeepEmails;

  /// No description provided for @evidenceCallLogs.
  ///
  /// In en, this message translates to:
  /// **'Check call logs and take screenshots'**
  String get evidenceCallLogs;

  /// No description provided for @evidenceRecordCalls.
  ///
  /// In en, this message translates to:
  /// **'If possible, record future calls (legal in Pakistan)'**
  String get evidenceRecordCalls;

  /// No description provided for @evidencePhysicalThreats.
  ///
  /// In en, this message translates to:
  /// **'Document any physical threats separately for police report'**
  String get evidencePhysicalThreats;

  /// No description provided for @evidenceInformPolice.
  ///
  /// In en, this message translates to:
  /// **'Consider informing local police immediately'**
  String get evidenceInformPolice;

  /// No description provided for @reportFIA.
  ///
  /// In en, this message translates to:
  /// **'File complaint with FIA Cyber Crime Wing (online or in person)'**
  String get reportFIA;

  /// No description provided for @reportPolice.
  ///
  /// In en, this message translates to:
  /// **'Visit nearest police station to file FIR'**
  String get reportPolice;

  /// No description provided for @reportPlatform.
  ///
  /// In en, this message translates to:
  /// **'Report to platform (Facebook, Instagram, WhatsApp, etc.)'**
  String get reportPlatform;

  /// No description provided for @reportHumanRights.
  ///
  /// In en, this message translates to:
  /// **'Contact National Commission for Human Rights if needed'**
  String get reportHumanRights;

  /// No description provided for @reportLawyer.
  ///
  /// In en, this message translates to:
  /// **'Consider consulting a lawyer for legal advice'**
  String get reportLawyer;

  /// No description provided for @reportUrgentFIA.
  ///
  /// In en, this message translates to:
  /// **'URGENT: Report to FIA Cyber Crime immediately - this is priority'**
  String get reportUrgentFIA;

  /// No description provided for @reportHelpline.
  ///
  /// In en, this message translates to:
  /// **'Contact helpline 1991 (FIA Cyber Crime) for immediate assistance'**
  String get reportHelpline;

  /// No description provided for @reportChildProtection.
  ///
  /// In en, this message translates to:
  /// **'CRITICAL: Contact Child Protection Bureau immediately at 1121'**
  String get reportChildProtection;

  /// No description provided for @reportNCRC.
  ///
  /// In en, this message translates to:
  /// **'Report to NCRC (National Commission on Rights of Child)'**
  String get reportNCRC;

  /// No description provided for @reportHR.
  ///
  /// In en, this message translates to:
  /// **'Report to HR department with documented evidence'**
  String get reportHR;

  /// No description provided for @reportOmbudsperson.
  ///
  /// In en, this message translates to:
  /// **'File complaint with Provincial Ombudsperson if applicable'**
  String get reportOmbudsperson;

  /// No description provided for @legalPeca20.
  ///
  /// In en, this message translates to:
  /// **'PECA Section 20: Cyber Extortion (up to 14 years imprisonment)'**
  String get legalPeca20;

  /// No description provided for @legalPeca21.
  ///
  /// In en, this message translates to:
  /// **'PECA Section 21: Unauthorized access (up to 7 years)'**
  String get legalPeca21;

  /// No description provided for @legalPpc384.
  ///
  /// In en, this message translates to:
  /// **'Pakistan Penal Code Section 384: Extortion'**
  String get legalPpc384;

  /// No description provided for @legalNonBailable.
  ///
  /// In en, this message translates to:
  /// **'This is a cognizable, non-bailable offense'**
  String get legalNonBailable;

  /// No description provided for @preparingGuidance.
  ///
  /// In en, this message translates to:
  /// **'Preparing safety guidance...'**
  String get preparingGuidance;

  /// No description provided for @readingEvidence.
  ///
  /// In en, this message translates to:
  /// **'Reading uploaded evidence...'**
  String get readingEvidence;

  /// No description provided for @generatingGuidance.
  ///
  /// In en, this message translates to:
  /// **'Generating personalized guidance...'**
  String get generatingGuidance;

  /// No description provided for @fiaComplaintSuccess.
  ///
  /// In en, this message translates to:
  /// **'FIA Complaint Generated Successfully'**
  String get fiaComplaintSuccess;

  /// No description provided for @fiaCyberComplaint.
  ///
  /// In en, this message translates to:
  /// **'FIA Cyber Crime Complaint'**
  String get fiaCyberComplaint;

  /// No description provided for @generatedByAI.
  ///
  /// In en, this message translates to:
  /// **'Generated by Legal Sathi AI'**
  String get generatedByAI;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @subjectPeca.
  ///
  /// In en, this message translates to:
  /// **'SUBJECT: Formal Complaint under PECA'**
  String get subjectPeca;

  /// No description provided for @finalRequest.
  ///
  /// In en, this message translates to:
  /// **'I request FIA to take action.'**
  String get finalRequest;

  /// No description provided for @sincerely.
  ///
  /// In en, this message translates to:
  /// **'Sincerely,'**
  String get sincerely;

  /// No description provided for @complaintNextSteps.
  ///
  /// In en, this message translates to:
  /// **'Next Steps:'**
  String get complaintNextSteps;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phone;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @descriptionIncident.
  ///
  /// In en, this message translates to:
  /// **'Description of Incident:'**
  String get descriptionIncident;

  /// No description provided for @complaintStep1.
  ///
  /// In en, this message translates to:
  /// **'Print and sign the complaint'**
  String get complaintStep1;

  /// No description provided for @complaintStep2.
  ///
  /// In en, this message translates to:
  /// **'Attach all evidence (screenshots, documents)'**
  String get complaintStep2;

  /// No description provided for @complaintStep3.
  ///
  /// In en, this message translates to:
  /// **'Submit to nearest FIA Cyber Crime office'**
  String get complaintStep3;

  /// No description provided for @complaintStep4.
  ///
  /// In en, this message translates to:
  /// **'Or file online at complaint.fia.gov.pk'**
  String get complaintStep4;

  /// No description provided for @platformRequired.
  ///
  /// In en, this message translates to:
  /// **'Platform *'**
  String get platformRequired;

  /// No description provided for @facebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get facebook;

  /// No description provided for @instagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get instagram;

  /// No description provided for @twitter.
  ///
  /// In en, this message translates to:
  /// **'Twitter'**
  String get twitter;

  /// No description provided for @tiktok.
  ///
  /// In en, this message translates to:
  /// **'TikTok'**
  String get tiktok;

  /// No description provided for @linkedin.
  ///
  /// In en, this message translates to:
  /// **'LinkedIn'**
  String get linkedin;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @uploadScreenshotsRecommended.
  ///
  /// In en, this message translates to:
  /// **'Upload Screenshots (Recommended)'**
  String get uploadScreenshotsRecommended;

  /// No description provided for @fakeProfileScreenshots.
  ///
  /// In en, this message translates to:
  /// **'Screenshots of fake profile'**
  String get fakeProfileScreenshots;

  /// No description provided for @uploadScreenshotsBtn.
  ///
  /// In en, this message translates to:
  /// **'Upload Screenshots'**
  String get uploadScreenshotsBtn;

  /// No description provided for @uploadedScreenshots.
  ///
  /// In en, this message translates to:
  /// **'{count} Uploaded Screenshots'**
  String uploadedScreenshots(Object count);

  /// No description provided for @checkReportingSteps.
  ///
  /// In en, this message translates to:
  /// **'Check & Get Reporting Steps'**
  String get checkReportingSteps;

  /// No description provided for @pecaInfoMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ll receive platform-specific steps to report and legal options under PECA'**
  String get pecaInfoMessage;

  /// No description provided for @reportFakeOrImpersonating.
  ///
  /// In en, this message translates to:
  /// **'Report Fake or Impersonating Account'**
  String get reportFakeOrImpersonating;

  /// No description provided for @platformSpecificGuidance.
  ///
  /// In en, this message translates to:
  /// **'Get platform-specific reporting guidance'**
  String get platformSpecificGuidance;

  /// No description provided for @accountDetails.
  ///
  /// In en, this message translates to:
  /// **'Account Details'**
  String get accountDetails;

  /// No description provided for @profileUrl.
  ///
  /// In en, this message translates to:
  /// **'Profile URL or Link'**
  String get profileUrl;

  /// No description provided for @profileUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://facebook.com/fake-profile'**
  String get profileUrlHint;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username (if no URL)'**
  String get username;

  /// No description provided for @usernameHint.
  ///
  /// In en, this message translates to:
  /// **'@fakeaccount123'**
  String get usernameHint;

  /// No description provided for @filesUploadedSuccess.
  ///
  /// In en, this message translates to:
  /// **'file(s) uploaded successfully'**
  String get filesUploadedSuccess;

  /// No description provided for @provideProfileAndPlatform.
  ///
  /// In en, this message translates to:
  /// **'Please provide profile info and platform.'**
  String get provideProfileAndPlatform;

  /// No description provided for @invalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid profile URL.'**
  String get invalidUrl;

  /// No description provided for @provideUrlOrUsername.
  ///
  /// In en, this message translates to:
  /// **'Provide profile URL or username.'**
  String get provideUrlOrUsername;

  /// No description provided for @couldNotSaveReport.
  ///
  /// In en, this message translates to:
  /// **'Could not save report.'**
  String get couldNotSaveReport;

  /// No description provided for @checkAndGetSteps.
  ///
  /// In en, this message translates to:
  /// **'Check & Get Reporting Steps'**
  String get checkAndGetSteps;

  /// No description provided for @extractedEvidence.
  ///
  /// In en, this message translates to:
  /// **'Extracted Evidence'**
  String get extractedEvidence;

  /// No description provided for @timestamps.
  ///
  /// In en, this message translates to:
  /// **'Extracted Timestamps'**
  String get timestamps;

  /// No description provided for @phoneNumbersFound.
  ///
  /// In en, this message translates to:
  /// **'Phone Numbers Found'**
  String get phoneNumbersFound;

  /// No description provided for @urlsFound.
  ///
  /// In en, this message translates to:
  /// **'URLs/Links Found'**
  String get urlsFound;

  /// No description provided for @keyThreatPhrases.
  ///
  /// In en, this message translates to:
  /// **'Key Threatening Phrases'**
  String get keyThreatPhrases;

  /// No description provided for @useInFIAComplaint.
  ///
  /// In en, this message translates to:
  /// **'Use in FIA Complaint'**
  String get useInFIAComplaint;

  /// No description provided for @exportAsPDF.
  ///
  /// In en, this message translates to:
  /// **'Export as PDF'**
  String get exportAsPDF;

  /// No description provided for @phoneCopied.
  ///
  /// In en, this message translates to:
  /// **'Phone number copied'**
  String get phoneCopied;

  /// No description provided for @evidenceNotice.
  ///
  /// In en, this message translates to:
  /// **'This evidence is court-admissible. Keep original files safe and secure.'**
  String get evidenceNotice;

  /// No description provided for @pdfTitle.
  ///
  /// In en, this message translates to:
  /// **'Threat Message Evidence Report'**
  String get pdfTitle;

  /// No description provided for @filesAnalyzed.
  ///
  /// In en, this message translates to:
  /// **'Files analyzed'**
  String get filesAnalyzed;

  /// No description provided for @threatClassifications.
  ///
  /// In en, this message translates to:
  /// **'Threat Classifications'**
  String get threatClassifications;

  /// No description provided for @phoneNumbers.
  ///
  /// In en, this message translates to:
  /// **'Phone Numbers'**
  String get phoneNumbers;

  /// No description provided for @urls.
  ///
  /// In en, this message translates to:
  /// **'URLs'**
  String get urls;

  /// No description provided for @keyPhrases.
  ///
  /// In en, this message translates to:
  /// **'Key Phrases'**
  String get keyPhrases;

  /// No description provided for @confidence.
  ///
  /// In en, this message translates to:
  /// **'confidence'**
  String get confidence;

  /// No description provided for @risk.
  ///
  /// In en, this message translates to:
  /// **'Risk'**
  String get risk;

  /// No description provided for @onlineHarassmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Online Harassment (PECA 24)'**
  String get onlineHarassmentTitle;

  /// No description provided for @pecaSection24.
  ///
  /// In en, this message translates to:
  /// **'PECA Section 24'**
  String get pecaSection24;

  /// No description provided for @harassmentDesc.
  ///
  /// In en, this message translates to:
  /// **'Gender-based or personal harassment'**
  String get harassmentDesc;

  /// No description provided for @whatToDoDesc.
  ///
  /// In en, this message translates to:
  /// **'Save all evidence (screenshots with timestamps), block the harasser, report to FIA Cyber Crime Wing.'**
  String get whatToDoDesc;

  /// No description provided for @howToReportDesc.
  ///
  /// In en, this message translates to:
  /// **'Visit FIA Cyber Crime website, file online complaint, or visit nearest FIA office.'**
  String get howToReportDesc;

  /// No description provided for @downloadAsPDF.
  ///
  /// In en, this message translates to:
  /// **'Download as PDF'**
  String get downloadAsPDF;

  /// No description provided for @downloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading...'**
  String get downloading;

  /// No description provided for @rightsEscalation.
  ///
  /// In en, this message translates to:
  /// **'Rights & Escalation'**
  String get rightsEscalation;

  /// No description provided for @protectedUnderLaw.
  ///
  /// In en, this message translates to:
  /// **'Protected under the law'**
  String get protectedUnderLaw;

  /// No description provided for @yourRights.
  ///
  /// In en, this message translates to:
  /// **'Your Rights'**
  String get yourRights;

  /// No description provided for @whenToEscalate.
  ///
  /// In en, this message translates to:
  /// **'When to Escalate to Ombudsperson'**
  String get whenToEscalate;

  /// No description provided for @templates.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get templates;

  /// No description provided for @rightConfidentiality.
  ///
  /// In en, this message translates to:
  /// **'Right to Confidentiality'**
  String get rightConfidentiality;

  /// No description provided for @rightConfidentialityDesc.
  ///
  /// In en, this message translates to:
  /// **'Your complaint and identity must be kept confidential throughout the process'**
  String get rightConfidentialityDesc;

  /// No description provided for @rightFemaleMember.
  ///
  /// In en, this message translates to:
  /// **'Right to Female Committee Member'**
  String get rightFemaleMember;

  /// No description provided for @rightFemaleMemberDesc.
  ///
  /// In en, this message translates to:
  /// **'At least one female member must be present in the inquiry committee'**
  String get rightFemaleMemberDesc;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Legal Sathi v1.0.0'**
  String get appVersion;

  /// No description provided for @rightNoRetaliation.
  ///
  /// In en, this message translates to:
  /// **'Right to No Retaliation'**
  String get rightNoRetaliation;

  /// No description provided for @rightNoRetaliationDesc.
  ///
  /// In en, this message translates to:
  /// **'You cannot be punished, demoted, or fired for filing a complaint'**
  String get rightNoRetaliationDesc;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @rightFairHearing.
  ///
  /// In en, this message translates to:
  /// **'Right to Fair Hearing'**
  String get rightFairHearing;

  /// No description provided for @rightFairHearingDesc.
  ///
  /// In en, this message translates to:
  /// **'Both parties must be given equal opportunity to present their case'**
  String get rightFairHearingDesc;

  /// No description provided for @escalateIf.
  ///
  /// In en, this message translates to:
  /// **'Escalate if any of these occur:'**
  String get escalateIf;

  /// No description provided for @escalate1.
  ///
  /// In en, this message translates to:
  /// **'Committee not formed within 7 days'**
  String get escalate1;

  /// No description provided for @escalate2.
  ///
  /// In en, this message translates to:
  /// **'Inquiry not completed within 30 days'**
  String get escalate2;

  /// No description provided for @escalate3.
  ///
  /// In en, this message translates to:
  /// **'Biased or unfair inquiry process'**
  String get escalate3;

  /// No description provided for @escalate4.
  ///
  /// In en, this message translates to:
  /// **'Recommendations not implemented'**
  String get escalate4;

  /// No description provided for @escalate5.
  ///
  /// In en, this message translates to:
  /// **'Retaliation after filing complaint'**
  String get escalate5;

  /// No description provided for @templateReconstitution.
  ///
  /// In en, this message translates to:
  /// **'Committee Reconstitution Request'**
  String get templateReconstitution;

  /// No description provided for @templateReconstitutionDesc.
  ///
  /// In en, this message translates to:
  /// **'If committee is biased'**
  String get templateReconstitutionDesc;

  /// No description provided for @templateEscalation.
  ///
  /// In en, this message translates to:
  /// **'Escalation Letter'**
  String get templateEscalation;

  /// No description provided for @templateEscalationDesc.
  ///
  /// In en, this message translates to:
  /// **'File with Ombudsperson'**
  String get templateEscalationDesc;

  /// No description provided for @downloadTemplates.
  ///
  /// In en, this message translates to:
  /// **'Download Templates'**
  String get downloadTemplates;

  /// No description provided for @stepInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get stepInfo;

  /// No description provided for @stepIncident.
  ///
  /// In en, this message translates to:
  /// **'Incident'**
  String get stepIncident;

  /// No description provided for @stepEvidence.
  ///
  /// In en, this message translates to:
  /// **'Evidence'**
  String get stepEvidence;

  /// No description provided for @stepPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get stepPreview;

  /// No description provided for @stepSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get stepSubmit;

  /// No description provided for @followInstructions.
  ///
  /// In en, this message translates to:
  /// **'Follow these instructions to file your complaint'**
  String get followInstructions;

  /// No description provided for @ombudspersonPunjab.
  ///
  /// In en, this message translates to:
  /// **'Provincial Ombudsperson Punjab'**
  String get ombudspersonPunjab;

  /// No description provided for @howToSubmit.
  ///
  /// In en, this message translates to:
  /// **'How to Submit'**
  String get howToSubmit;

  /// No description provided for @expectedTimeline.
  ///
  /// In en, this message translates to:
  /// **'Expected Timeline'**
  String get expectedTimeline;

  /// No description provided for @emailSubmission.
  ///
  /// In en, this message translates to:
  /// **'Email Submission'**
  String get emailSubmission;

  /// No description provided for @inPersonSubmission.
  ///
  /// In en, this message translates to:
  /// **'In-Person Submission'**
  String get inPersonSubmission;

  /// No description provided for @onlinePortal.
  ///
  /// In en, this message translates to:
  /// **'Online Portal'**
  String get onlinePortal;

  /// No description provided for @emailSubmissionDesc.
  ///
  /// In en, this message translates to:
  /// **'Send your complaint PDF to the email address above with subject: \"Harassment Complaint - [Your Name]\"'**
  String get emailSubmissionDesc;

  /// No description provided for @inPersonDesc.
  ///
  /// In en, this message translates to:
  /// **'Visit the office address above and submit printed complaint with evidence'**
  String get inPersonDesc;

  /// No description provided for @onlinePortalDesc.
  ///
  /// In en, this message translates to:
  /// **'Visit the website and use the online complaint submission form'**
  String get onlinePortalDesc;

  /// No description provided for @inquiryDesc.
  ///
  /// In en, this message translates to:
  /// **'Decision within 90 days of filing'**
  String get inquiryDesc;

  /// No description provided for @implementationDesc.
  ///
  /// In en, this message translates to:
  /// **'Organization must comply within 30 days'**
  String get implementationDesc;

  /// No description provided for @downloadComplaintPDF.
  ///
  /// In en, this message translates to:
  /// **'Download Complaint PDF'**
  String get downloadComplaintPDF;

  /// No description provided for @copyEmail.
  ///
  /// In en, this message translates to:
  /// **'Copy Email Address'**
  String get copyEmail;

  /// No description provided for @markSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Mark as Submitted'**
  String get markSubmitted;

  /// No description provided for @submitFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit'**
  String get submitFailed;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get success;

  /// No description provided for @complaintSubmittedMsg.
  ///
  /// In en, this message translates to:
  /// **'Your complaint has been submitted successfully. You will receive further instructions via email.'**
  String get complaintSubmittedMsg;

  /// No description provided for @goHome.
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get goHome;

  /// No description provided for @keepCopy.
  ///
  /// In en, this message translates to:
  /// **'Keep a copy of your complaint and all evidence for your records'**
  String get keepCopy;

  /// No description provided for @applicantInfo.
  ///
  /// In en, this message translates to:
  /// **'Applicant Information'**
  String get applicantInfo;

  /// No description provided for @workplace.
  ///
  /// In en, this message translates to:
  /// **'Workplace Name'**
  String get workplace;

  /// No description provided for @designation.
  ///
  /// In en, this message translates to:
  /// **'Your Designation'**
  String get designation;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @enterWorkplace.
  ///
  /// In en, this message translates to:
  /// **'Please enter your workplace.'**
  String get enterWorkplace;

  /// No description provided for @enterDesignation.
  ///
  /// In en, this message translates to:
  /// **'Enter designation'**
  String get enterDesignation;

  /// No description provided for @enterCity.
  ///
  /// In en, this message translates to:
  /// **'Enter city'**
  String get enterCity;

  /// No description provided for @enterFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullNameHint;

  /// No description provided for @workplaceHint.
  ///
  /// In en, this message translates to:
  /// **'Company name'**
  String get workplaceHint;

  /// No description provided for @cityHint.
  ///
  /// In en, this message translates to:
  /// **'City name'**
  String get cityHint;

  /// No description provided for @continueToIncident.
  ///
  /// In en, this message translates to:
  /// **'Continue to Incident Details'**
  String get continueToIncident;

  /// No description provided for @infoSaved.
  ///
  /// In en, this message translates to:
  /// **'Information saved successfully'**
  String get infoSaved;

  /// No description provided for @complaintGenerated.
  ///
  /// In en, this message translates to:
  /// **'Complaint Letter Generated'**
  String get complaintGenerated;

  /// No description provided for @yourFormalComplaint.
  ///
  /// In en, this message translates to:
  /// **'Your Formal Complaint'**
  String get yourFormalComplaint;

  /// No description provided for @generatedByApp.
  ///
  /// In en, this message translates to:
  /// **'Generated by Legal Sathi AI'**
  String get generatedByApp;

  /// No description provided for @failedToLoadComplaint.
  ///
  /// In en, this message translates to:
  /// **'Failed to load complaint'**
  String get failedToLoadComplaint;

  /// No description provided for @complaintRegenerated.
  ///
  /// In en, this message translates to:
  /// **'Complaint regenerated!'**
  String get complaintRegenerated;

  /// No description provided for @complaintPreview.
  ///
  /// In en, this message translates to:
  /// **'Complaint Preview'**
  String get complaintPreview;

  /// No description provided for @reviewBeforeSubmission.
  ///
  /// In en, this message translates to:
  /// **'Review your complaint before submission'**
  String get reviewBeforeSubmission;

  /// No description provided for @generatedByLegalSathi.
  ///
  /// In en, this message translates to:
  /// **'Generated by Legal Sathi'**
  String get generatedByLegalSathi;

  /// No description provided for @formalOmbudspersonTitle.
  ///
  /// In en, this message translates to:
  /// **'COMPLAINT TO FEDERAL OMBUDSPERSON FOR PROTECTION AGAINST HARASSMENT OF WOMEN AT WORKPLACE'**
  String get formalOmbudspersonTitle;

  /// No description provided for @applicantDetails.
  ///
  /// In en, this message translates to:
  /// **'APPLICANT DETAILS:'**
  String get applicantDetails;

  /// No description provided for @accusedPerson.
  ///
  /// In en, this message translates to:
  /// **'ACCUSED PERSON:'**
  String get accusedPerson;

  /// No description provided for @evidenceFiles.
  ///
  /// In en, this message translates to:
  /// **'EVIDENCE FILES:'**
  String get evidenceFiles;

  /// No description provided for @continueToSubmission.
  ///
  /// In en, this message translates to:
  /// **'Continue to Submission Instructions'**
  String get continueToSubmission;

  /// No description provided for @regenerateComplaint.
  ///
  /// In en, this message translates to:
  /// **'Regenerate Complaint'**
  String get regenerateComplaint;

  /// No description provided for @regenerateConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will regenerate the complaint with the same information. Continue?'**
  String get regenerateConfirm;

  /// No description provided for @draftWarning.
  ///
  /// In en, this message translates to:
  /// **'This is a draft document. Please review carefully and consult a legal professional before submission.'**
  String get draftWarning;

  /// No description provided for @aiEvidenceReview.
  ///
  /// In en, this message translates to:
  /// **'AI Evidence Review'**
  String get aiEvidenceReview;

  /// No description provided for @uploadYourEvidence.
  ///
  /// In en, this message translates to:
  /// **'Upload Your Evidence'**
  String get uploadYourEvidence;

  /// No description provided for @aiAnalyzeText.
  ///
  /// In en, this message translates to:
  /// **'AI will analyze strength and provide suggestions'**
  String get aiAnalyzeText;

  /// No description provided for @mediumEvidence.
  ///
  /// In en, this message translates to:
  /// **'Medium Evidence'**
  String get mediumEvidence;

  /// No description provided for @basedOnEvidence.
  ///
  /// In en, this message translates to:
  /// **'Based on {count} pieces of evidence'**
  String basedOnEvidence(Object count);

  /// No description provided for @evidenceStrengthDescription.
  ///
  /// In en, this message translates to:
  /// **'Your evidence is adequate but could be strengthened. You have some key evidence, but additional supporting materials would make your case more robust.'**
  String get evidenceStrengthDescription;

  /// No description provided for @aiSuggestionsTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Suggestions to Improve'**
  String get aiSuggestionsTitle;

  /// No description provided for @suggestion1.
  ///
  /// In en, this message translates to:
  /// **'Add more screenshots of communications'**
  String get suggestion1;

  /// No description provided for @suggestion2.
  ///
  /// In en, this message translates to:
  /// **'Get written witness statements'**
  String get suggestion2;

  /// No description provided for @suggestion3.
  ///
  /// In en, this message translates to:
  /// **'Include any HR correspondence'**
  String get suggestion3;

  /// No description provided for @suggestion4.
  ///
  /// In en, this message translates to:
  /// **'Document pattern of behavior with dates'**
  String get suggestion4;

  /// No description provided for @suggestion5.
  ///
  /// In en, this message translates to:
  /// **'Add contemporaneous diary entries if available'**
  String get suggestion5;

  /// No description provided for @continueToDraft.
  ///
  /// In en, this message translates to:
  /// **'Continue to Draft Complaint'**
  String get continueToDraft;

  /// No description provided for @uploadMoreEvidence.
  ///
  /// In en, this message translates to:
  /// **'Upload More Evidence'**
  String get uploadMoreEvidence;

  /// No description provided for @draftComplaint.
  ///
  /// In en, this message translates to:
  /// **'Draft Complaint'**
  String get draftComplaint;

  /// No description provided for @personal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get personal;

  /// No description provided for @impact.
  ///
  /// In en, this message translates to:
  /// **'Impact'**
  String get impact;

  /// No description provided for @relief.
  ///
  /// In en, this message translates to:
  /// **'Relief'**
  String get relief;

  /// No description provided for @impactOnYou.
  ///
  /// In en, this message translates to:
  /// **'Impact on You'**
  String get impactOnYou;

  /// No description provided for @reliefSought.
  ///
  /// In en, this message translates to:
  /// **'Relief Sought'**
  String get reliefSought;

  /// No description provided for @enterFullNameError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name.'**
  String get enterFullNameError;

  /// No description provided for @jobTitle.
  ///
  /// In en, this message translates to:
  /// **'Job title/position'**
  String get jobTitle;

  /// No description provided for @workplaceName.
  ///
  /// In en, this message translates to:
  /// **'Workplace Name'**
  String get workplaceName;

  /// No description provided for @organizationName.
  ///
  /// In en, this message translates to:
  /// **'Organization/Company name'**
  String get organizationName;

  /// No description provided for @workplaceAddress.
  ///
  /// In en, this message translates to:
  /// **'Workplace Address'**
  String get workplaceAddress;

  /// No description provided for @selectIncidentDate.
  ///
  /// In en, this message translates to:
  /// **'Please select the incident date.'**
  String get selectIncidentDate;

  /// No description provided for @harassmentDescription.
  ///
  /// In en, this message translates to:
  /// **'Description of Harassment'**
  String get harassmentDescription;

  /// No description provided for @evidenceAttached.
  ///
  /// In en, this message translates to:
  /// **'Evidence Attached'**
  String get evidenceAttached;

  /// No description provided for @evidenceHint.
  ///
  /// In en, this message translates to:
  /// **'List all evidence...'**
  String get evidenceHint;

  /// No description provided for @witnesses.
  ///
  /// In en, this message translates to:
  /// **'Witness Names'**
  String get witnesses;

  /// No description provided for @mentalImpact.
  ///
  /// In en, this message translates to:
  /// **'Mental Impact'**
  String get mentalImpact;

  /// No description provided for @mentalImpactError.
  ///
  /// In en, this message translates to:
  /// **'Please describe the mental impact.'**
  String get mentalImpactError;

  /// No description provided for @emotionalImpact.
  ///
  /// In en, this message translates to:
  /// **'Emotional Impact'**
  String get emotionalImpact;

  /// No description provided for @emotionalImpactError.
  ///
  /// In en, this message translates to:
  /// **'Please describe the emotional impact.'**
  String get emotionalImpactError;

  /// No description provided for @safetyConcerns.
  ///
  /// In en, this message translates to:
  /// **'Safety Concerns'**
  String get safetyConcerns;

  /// No description provided for @selectAllThatApply.
  ///
  /// In en, this message translates to:
  /// **'Select all that apply'**
  String get selectAllThatApply;

  /// No description provided for @generateComplaint.
  ///
  /// In en, this message translates to:
  /// **'Generate Complaint'**
  String get generateComplaint;

  /// No description provided for @selectJurisdiction.
  ///
  /// In en, this message translates to:
  /// **'Select Jurisdiction'**
  String get selectJurisdiction;

  /// No description provided for @whichProvince.
  ///
  /// In en, this message translates to:
  /// **'Which Province/Area?'**
  String get whichProvince;

  /// No description provided for @selectWorkplaceLocation.
  ///
  /// In en, this message translates to:
  /// **'Select where your workplace is located'**
  String get selectWorkplaceLocation;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get emailHint;

  /// No description provided for @orgHint.
  ///
  /// In en, this message translates to:
  /// **'Organization ka naam'**
  String get orgHint;

  /// No description provided for @jobHint.
  ///
  /// In en, this message translates to:
  /// **'Job title'**
  String get jobHint;

  /// No description provided for @deptHint.
  ///
  /// In en, this message translates to:
  /// **'Department ka naam'**
  String get deptHint;

  /// No description provided for @yourInformation.
  ///
  /// In en, this message translates to:
  /// **'Your Information'**
  String get yourInformation;

  /// No description provided for @department.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get department;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'+92 300 0000000'**
  String get phoneHint;

  /// No description provided for @accused.
  ///
  /// In en, this message translates to:
  /// **'Accused'**
  String get accused;

  /// No description provided for @requestedAction.
  ///
  /// In en, this message translates to:
  /// **'Requested Action'**
  String get requestedAction;

  /// No description provided for @selectReliefError.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one relief option.'**
  String get selectReliefError;

  /// No description provided for @reliefApology.
  ///
  /// In en, this message translates to:
  /// **'Written apology from accused'**
  String get reliefApology;

  /// No description provided for @reliefTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer of accused to different department'**
  String get reliefTransfer;

  /// No description provided for @reliefTermination.
  ///
  /// In en, this message translates to:
  /// **'Removal/termination of accused'**
  String get reliefTermination;

  /// No description provided for @reliefCompensation.
  ///
  /// In en, this message translates to:
  /// **'Monetary compensation for damages'**
  String get reliefCompensation;

  /// No description provided for @reliefDisciplinary.
  ///
  /// In en, this message translates to:
  /// **'Disciplinary action against accused'**
  String get reliefDisciplinary;

  /// No description provided for @reliefPolicyChanges.
  ///
  /// In en, this message translates to:
  /// **'Workplace policy changes'**
  String get reliefPolicyChanges;

  /// No description provided for @describeWhatHappened.
  ///
  /// In en, this message translates to:
  /// **'Please describe what happened'**
  String get describeWhatHappened;

  /// No description provided for @accusedName.
  ///
  /// In en, this message translates to:
  /// **'Accused Person\'s Name'**
  String get accusedName;

  /// No description provided for @accusedDesignation.
  ///
  /// In en, this message translates to:
  /// **'Accused Person\'s Designation'**
  String get accusedDesignation;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the incident in detail...'**
  String get descriptionHint;

  /// No description provided for @accusedNameHint.
  ///
  /// In en, this message translates to:
  /// **'Full name of the person'**
  String get accusedNameHint;

  /// No description provided for @accusedDesignationHint.
  ///
  /// In en, this message translates to:
  /// **'Their job title/position'**
  String get accusedDesignationHint;

  /// No description provided for @needHelpWriting.
  ///
  /// In en, this message translates to:
  /// **'Need help writing?'**
  String get needHelpWriting;

  /// No description provided for @helpDescription.
  ///
  /// In en, this message translates to:
  /// **'Include: What happened, when, where, who was involved, and any witnesses'**
  String get helpDescription;

  /// No description provided for @continueToEvidence.
  ///
  /// In en, this message translates to:
  /// **'Continue to Evidence'**
  String get continueToEvidence;

  /// No description provided for @fileAppeal.
  ///
  /// In en, this message translates to:
  /// **'File an Appeal'**
  String get fileAppeal;

  /// No description provided for @nextStep.
  ///
  /// In en, this message translates to:
  /// **'Next Step'**
  String get nextStep;

  /// No description provided for @appealGuidance.
  ///
  /// In en, this message translates to:
  /// **'Appeals must follow the deadline and office printed on your challan. Keep copies of the challan, CNIC, and any evidence.'**
  String get appealGuidance;

  /// No description provided for @officialReferences.
  ///
  /// In en, this message translates to:
  /// **'Official references'**
  String get officialReferences;

  /// No description provided for @challanExtractedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Challan Extracted Successfully'**
  String get challanExtractedSuccessfully;

  /// No description provided for @challanFallbackWarning.
  ///
  /// In en, this message translates to:
  /// **'Some fields could not be read automatically. Please compare with your original challan.'**
  String get challanFallbackWarning;

  /// No description provided for @extractedInformation.
  ///
  /// In en, this message translates to:
  /// **'Extracted Information'**
  String get extractedInformation;

  /// No description provided for @aiReadChallan.
  ///
  /// In en, this message translates to:
  /// **'AI has read your challan details'**
  String get aiReadChallan;

  /// No description provided for @challanNumber.
  ///
  /// In en, this message translates to:
  /// **'Challan Number'**
  String get challanNumber;

  /// No description provided for @vehicleNumber.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Number'**
  String get vehicleNumber;

  /// No description provided for @violationType.
  ///
  /// In en, this message translates to:
  /// **'Violation Type'**
  String get violationType;

  /// No description provided for @issueLocation.
  ///
  /// In en, this message translates to:
  /// **'Issue Location'**
  String get issueLocation;

  /// No description provided for @officerId.
  ///
  /// In en, this message translates to:
  /// **'Officer ID / Badge Number'**
  String get officerId;

  /// No description provided for @explanationNextSteps.
  ///
  /// In en, this message translates to:
  /// **'Explanation & Next Steps'**
  String get explanationNextSteps;

  /// No description provided for @understandingChallan.
  ///
  /// In en, this message translates to:
  /// **'Understanding Your Challan'**
  String get understandingChallan;

  /// No description provided for @violationMeaningSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What this violation means and how to proceed'**
  String get violationMeaningSubtitle;

  /// No description provided for @whatViolationMeans.
  ///
  /// In en, this message translates to:
  /// **'What This Violation Means'**
  String get whatViolationMeans;

  /// No description provided for @isFineCorrect.
  ///
  /// In en, this message translates to:
  /// **'Is the Fine Correct?'**
  String get isFineCorrect;

  /// No description provided for @whereHowToPay.
  ///
  /// In en, this message translates to:
  /// **'Where & How to Pay'**
  String get whereHowToPay;

  /// No description provided for @thinkChallanWrong.
  ///
  /// In en, this message translates to:
  /// **'Think the Challan is Wrong?'**
  String get thinkChallanWrong;

  /// No description provided for @fineVerified.
  ///
  /// In en, this message translates to:
  /// **'Fine Amount Verified'**
  String get fineVerified;

  /// No description provided for @paymentOptions.
  ///
  /// In en, this message translates to:
  /// **'Payment Options'**
  String get paymentOptions;

  /// No description provided for @nearestOffice.
  ///
  /// In en, this message translates to:
  /// **'Nearest Office'**
  String get nearestOffice;

  /// No description provided for @helpline.
  ///
  /// In en, this message translates to:
  /// **'Provincial Helpline'**
  String get helpline;

  /// No description provided for @helplineNumber.
  ///
  /// In en, this message translates to:
  /// **'Call 1915 for payment assistance'**
  String get helplineNumber;

  /// No description provided for @payOnlineNow.
  ///
  /// In en, this message translates to:
  /// **'Pay Online Now'**
  String get payOnlineNow;

  /// No description provided for @payWithinDeadline.
  ///
  /// In en, this message translates to:
  /// **'Pay within 15 days to avoid additional penalties'**
  String get payWithinDeadline;

  /// No description provided for @issuedOn.
  ///
  /// In en, this message translates to:
  /// **'Issued on: {date}'**
  String issuedOn(Object date);

  /// No description provided for @viewExplanation.
  ///
  /// In en, this message translates to:
  /// **'View Explanation & Next Steps'**
  String get viewExplanation;

  /// No description provided for @punjabPolice.
  ///
  /// In en, this message translates to:
  /// **'Punjab Police'**
  String get punjabPolice;

  /// No description provided for @punjabPoliceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Provincial police website & services'**
  String get punjabPoliceSubtitle;

  /// No description provided for @islamabadPolice.
  ///
  /// In en, this message translates to:
  /// **'Islamabad Police'**
  String get islamabadPolice;

  /// No description provided for @islamabadPoliceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'ICT citizen services'**
  String get islamabadPoliceSubtitle;

  /// No description provided for @sindhPolice.
  ///
  /// In en, this message translates to:
  /// **'Sindh Police'**
  String get sindhPolice;

  /// No description provided for @sindhPoliceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sindh traffic / citizen services'**
  String get sindhPoliceSubtitle;

  /// No description provided for @appealFooterNote.
  ///
  /// In en, this message translates to:
  /// **'For deadlines and the correct office (magistrate / SP Traffic), follow what is printed on your official challan.'**
  String get appealFooterNote;

  /// No description provided for @trafficOffenceTypes.
  ///
  /// In en, this message translates to:
  /// **'Traffic Offence Types'**
  String get trafficOffenceTypes;

  /// No description provided for @commonViolationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Common traffic violations and penalties'**
  String get commonViolationsSubtitle;

  /// No description provided for @noHelmet.
  ///
  /// In en, this message translates to:
  /// **'No Helmet'**
  String get noHelmet;

  /// No description provided for @wrongWayDriving.
  ///
  /// In en, this message translates to:
  /// **'Wrong Way Driving'**
  String get wrongWayDriving;

  /// No description provided for @noSeatBelt.
  ///
  /// In en, this message translates to:
  /// **'No Seat Belt'**
  String get noSeatBelt;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @finesVariationNote.
  ///
  /// In en, this message translates to:
  /// **'Fines may vary by province. Repeat offences carry higher penalties.'**
  String get finesVariationNote;

  /// No description provided for @couldNotOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open this link on this device.'**
  String get couldNotOpenLink;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorOccurred(Object error);

  /// No description provided for @incidentSaved.
  ///
  /// In en, this message translates to:
  /// **'Incident details saved successfully'**
  String get incidentSaved;

  /// No description provided for @failedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load complaint'**
  String get failedToLoad;

  /// No description provided for @failedToSave.
  ///
  /// In en, this message translates to:
  /// **'Failed to save'**
  String get failedToSave;

  /// No description provided for @errorSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Please select the incident date.'**
  String get errorSelectDate;

  /// No description provided for @errorSelectHarassmentType.
  ///
  /// In en, this message translates to:
  /// **'Please select the type of harassment.'**
  String get errorSelectHarassmentType;

  /// No description provided for @errorDescription.
  ///
  /// In en, this message translates to:
  /// **'Please describe the incident in detail.'**
  String get errorDescription;

  /// No description provided for @errorAccusedName.
  ///
  /// In en, this message translates to:
  /// **'Please enter the name of the accused person.'**
  String get errorAccusedName;

  /// No description provided for @errorAccusedDesignation.
  ///
  /// In en, this message translates to:
  /// **'Please enter the designation of the accused person.'**
  String get errorAccusedDesignation;

  /// No description provided for @payChallanOnline.
  ///
  /// In en, this message translates to:
  /// **'Pay challan online'**
  String get payChallanOnline;

  /// No description provided for @useOfficialPortals.
  ///
  /// In en, this message translates to:
  /// **'Use only official government or police portals. Have your challan number ready.'**
  String get useOfficialPortals;

  /// No description provided for @challanNumberTitle.
  ///
  /// In en, this message translates to:
  /// **'Your challan number'**
  String get challanNumberTitle;

  /// No description provided for @challanCopied.
  ///
  /// In en, this message translates to:
  /// **'Challan number copied'**
  String get challanCopied;

  /// No description provided for @openPaymentPortal.
  ///
  /// In en, this message translates to:
  /// **'Open a payment portal'**
  String get openPaymentPortal;

  /// No description provided for @selectProvincePortal.
  ///
  /// In en, this message translates to:
  /// **'Pick your province or official site.'**
  String get selectProvincePortal;

  /// No description provided for @fineShown.
  ///
  /// In en, this message translates to:
  /// **'Fine shown in app: {amount}'**
  String fineShown(Object amount);

  /// No description provided for @cannotStartCall.
  ///
  /// In en, this message translates to:
  /// **'Cannot start a call on this device.'**
  String get cannotStartCall;

  /// No description provided for @writtenComplaintTitle.
  ///
  /// In en, this message translates to:
  /// **'Written complaint — addresses & links'**
  String get writtenComplaintTitle;

  /// No description provided for @verifyWithOfficialSources.
  ///
  /// In en, this message translates to:
  /// **'Verify with your official challan or provincial police site.'**
  String get verifyWithOfficialSources;

  /// No description provided for @lahoreTrafficHQ.
  ///
  /// In en, this message translates to:
  /// **'Lahore — Traffic HQ (indicative)'**
  String get lahoreTrafficHQ;

  /// No description provided for @lahoreTrafficDesc.
  ///
  /// In en, this message translates to:
  /// **'Confirm the current SP Traffic office from official Punjab Police website.'**
  String get lahoreTrafficDesc;

  /// No description provided for @karachiTrafficHQ.
  ///
  /// In en, this message translates to:
  /// **'Karachi — Traffic Police (indicative)'**
  String get karachiTrafficHQ;

  /// No description provided for @karachiTrafficDesc.
  ///
  /// In en, this message translates to:
  /// **'Use Sindh Police official portal for updated address.'**
  String get karachiTrafficDesc;

  /// No description provided for @islamabadTrafficHQ.
  ///
  /// In en, this message translates to:
  /// **'Islamabad — ICT Traffic'**
  String get islamabadTrafficHQ;

  /// No description provided for @islamabadTrafficDesc.
  ///
  /// In en, this message translates to:
  /// **'Follow ICT Police official citizen services.'**
  String get islamabadTrafficDesc;

  /// No description provided for @onlinePunjabComplaint.
  ///
  /// In en, this message translates to:
  /// **'Online — Punjab complaint portal'**
  String get onlinePunjabComplaint;

  /// No description provided for @whatsappComplaintMessage.
  ///
  /// In en, this message translates to:
  /// **'Assalam-o-Alaikum. I want to file a traffic complaint via Legal Sathi app.'**
  String get whatsappComplaintMessage;

  /// No description provided for @errorOpeningLink.
  ///
  /// In en, this message translates to:
  /// **'Error opening link: {error}'**
  String errorOpeningLink(Object error);

  /// No description provided for @punjabPsca.
  ///
  /// In en, this message translates to:
  /// **'Punjab (PSCA / e-Challan)'**
  String get punjabPsca;

  /// No description provided for @punjabPscaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Safe Cities / Punjab digital challan services'**
  String get punjabPscaSubtitle;

  /// No description provided for @processingChallan.
  ///
  /// In en, this message translates to:
  /// **'Processing Challan'**
  String get processingChallan;

  /// No description provided for @extractingChallanDetails.
  ///
  /// In en, this message translates to:
  /// **'Extracting Challan Details'**
  String get extractingChallanDetails;

  /// No description provided for @pleaseWaitAiReading.
  ///
  /// In en, this message translates to:
  /// **'Please wait while AI reads your challan'**
  String get pleaseWaitAiReading;

  /// No description provided for @extractingPdfText.
  ///
  /// In en, this message translates to:
  /// **'Extracting text from PDF…'**
  String get extractingPdfText;

  /// No description provided for @runningOcr.
  ///
  /// In en, this message translates to:
  /// **'Running OCR on image…'**
  String get runningOcr;

  /// No description provided for @couldNotProcessChallan.
  ///
  /// In en, this message translates to:
  /// **'Could not process challan: {error}'**
  String couldNotProcessChallan(Object error);

  /// No description provided for @ictPolice.
  ///
  /// In en, this message translates to:
  /// **'Islamabad Capital Police'**
  String get ictPolice;

  /// No description provided for @ictPoliceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'ICT traffic & challan information'**
  String get ictPoliceSubtitle;

  /// No description provided for @calculateTotalFine.
  ///
  /// In en, this message translates to:
  /// **'Calculate Total Fine'**
  String get calculateTotalFine;

  /// No description provided for @selectViolations.
  ///
  /// In en, this message translates to:
  /// **'Select all violations'**
  String get selectViolations;

  /// No description provided for @editComplaint.
  ///
  /// In en, this message translates to:
  /// **'Edit Complaint'**
  String get editComplaint;

  /// No description provided for @aiComplaintGenerator.
  ///
  /// In en, this message translates to:
  /// **'AI Complaint Generator'**
  String get aiComplaintGenerator;

  /// No description provided for @updateFormalComplaint.
  ///
  /// In en, this message translates to:
  /// **'Update Formal Complaint'**
  String get updateFormalComplaint;

  /// No description provided for @generateFormalComplaint.
  ///
  /// In en, this message translates to:
  /// **'Generate Formal Complaint'**
  String get generateFormalComplaint;

  /// No description provided for @updateComplaintSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Change details below, then update your letter'**
  String get updateComplaintSubtitle;

  /// No description provided for @generateComplaintSubtitle.
  ///
  /// In en, this message translates to:
  /// **'AI will create a properly formatted complaint letter'**
  String get generateComplaintSubtitle;

  /// No description provided for @yourDetails.
  ///
  /// In en, this message translates to:
  /// **'Your details'**
  String get yourDetails;

  /// No description provided for @complaintFilingPaths.
  ///
  /// In en, this message translates to:
  /// **'Complaint Filing Paths'**
  String get complaintFilingPaths;

  /// No description provided for @whereToFileComplaint.
  ///
  /// In en, this message translates to:
  /// **'Where to File Your Complaint'**
  String get whereToFileComplaint;

  /// No description provided for @chooseOption.
  ///
  /// In en, this message translates to:
  /// **'Choose the most convenient option'**
  String get chooseOption;

  /// No description provided for @helplineDesc.
  ///
  /// In en, this message translates to:
  /// **'Call 1915 (Punjab, Sindh, KPK)'**
  String get helplineDesc;

  /// No description provided for @callNow.
  ///
  /// In en, this message translates to:
  /// **'Call Now'**
  String get callNow;

  /// No description provided for @whatsapp.
  ///
  /// In en, this message translates to:
  /// **'IG / Police WhatsApp'**
  String get whatsapp;

  /// No description provided for @whatsappDesc.
  ///
  /// In en, this message translates to:
  /// **'Opens WhatsApp with a pre-filled message'**
  String get whatsappDesc;

  /// No description provided for @openWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Open WhatsApp'**
  String get openWhatsapp;

  /// No description provided for @reviewEditSubmit.
  ///
  /// In en, this message translates to:
  /// **'Review, edit, and submit your complaint'**
  String get reviewEditSubmit;

  /// No description provided for @policeMisbehavior.
  ///
  /// In en, this message translates to:
  /// **'Police Misbehavior Complaint'**
  String get policeMisbehavior;

  /// No description provided for @whatToDoNow.
  ///
  /// In en, this message translates to:
  /// **'What to Do Right Now'**
  String get whatToDoNow;

  /// No description provided for @followSteps.
  ///
  /// In en, this message translates to:
  /// **'Follow these steps during the incident'**
  String get followSteps;

  /// No description provided for @step1Title.
  ///
  /// In en, this message translates to:
  /// **'Stay Calm'**
  String get step1Title;

  /// No description provided for @step1Desc.
  ///
  /// In en, this message translates to:
  /// **'Remain polite and cooperative.'**
  String get step1Desc;

  /// No description provided for @step1Tip1.
  ///
  /// In en, this message translates to:
  /// **'Keep your composure'**
  String get step1Tip1;

  /// No description provided for @step1Tip2.
  ///
  /// In en, this message translates to:
  /// **'Speak respectfully'**
  String get step1Tip2;

  /// No description provided for @step1Tip3.
  ///
  /// In en, this message translates to:
  /// **'Avoid confrontation'**
  String get step1Tip3;

  /// No description provided for @ocrTitle.
  ///
  /// In en, this message translates to:
  /// **'Traffic Challan OCR Reader'**
  String get ocrTitle;

  /// No description provided for @uploadChallan.
  ///
  /// In en, this message translates to:
  /// **'Upload Your Challan'**
  String get uploadChallan;

  /// No description provided for @extractExplainText.
  ///
  /// In en, this message translates to:
  /// **'We extract text and explain the violation'**
  String get extractExplainText;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @takePhotoSub.
  ///
  /// In en, this message translates to:
  /// **'Open camera and capture challan'**
  String get takePhotoSub;

  /// No description provided for @importGallery.
  ///
  /// In en, this message translates to:
  /// **'Import from Gallery'**
  String get importGallery;

  /// No description provided for @importSub.
  ///
  /// In en, this message translates to:
  /// **'JPG, PNG or PDF (max 10MB)'**
  String get importSub;

  /// No description provided for @cameraAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera Access'**
  String get cameraAccessTitle;

  /// No description provided for @cameraAccessDesc.
  ///
  /// In en, this message translates to:
  /// **'We need camera permission to scan your challan'**
  String get cameraAccessDesc;

  /// No description provided for @mwProvincePunjab.
  ///
  /// In en, this message translates to:
  /// **'Punjab'**
  String get mwProvincePunjab;

  /// No description provided for @mwProvinceSindh.
  ///
  /// In en, this message translates to:
  /// **'Sindh'**
  String get mwProvinceSindh;

  /// No description provided for @mwProvinceKPK.
  ///
  /// In en, this message translates to:
  /// **'Khyber Pakhtunkhwa'**
  String get mwProvinceKPK;

  /// No description provided for @mwProvinceBalochistan.
  ///
  /// In en, this message translates to:
  /// **'Balochistan'**
  String get mwProvinceBalochistan;

  /// No description provided for @mwProvinceIslamabad.
  ///
  /// In en, this message translates to:
  /// **'Islamabad'**
  String get mwProvinceIslamabad;

  /// No description provided for @mwProvinceGB.
  ///
  /// In en, this message translates to:
  /// **'Gilgit-Baltistan'**
  String get mwProvinceGB;

  /// No description provided for @mwProvinceAJK.
  ///
  /// In en, this message translates to:
  /// **'Azad Jammu & Kashmir'**
  String get mwProvinceAJK;

  /// No description provided for @mwWorkerUnskilled.
  ///
  /// In en, this message translates to:
  /// **'Unskilled'**
  String get mwWorkerUnskilled;

  /// No description provided for @mwWorkerSemiskilled.
  ///
  /// In en, this message translates to:
  /// **'Semi-skilled'**
  String get mwWorkerSemiskilled;

  /// No description provided for @mwWorkerSkilled.
  ///
  /// In en, this message translates to:
  /// **'Skilled'**
  String get mwWorkerSkilled;

  /// No description provided for @mwWorkerHighlySkilled.
  ///
  /// In en, this message translates to:
  /// **'Highly skilled'**
  String get mwWorkerHighlySkilled;

  /// No description provided for @cameraPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera permission denied'**
  String get cameraPermissionDenied;

  /// No description provided for @photoCaptured.
  ///
  /// In en, this message translates to:
  /// **'Photo captured successfully'**
  String get photoCaptured;

  /// No description provided for @errorTakingPhoto.
  ///
  /// In en, this message translates to:
  /// **'Error taking photo:'**
  String get errorTakingPhoto;

  /// No description provided for @fileReadError.
  ///
  /// In en, this message translates to:
  /// **'Could not read file'**
  String get fileReadError;

  /// No description provided for @fileTooLarge.
  ///
  /// In en, this message translates to:
  /// **'File exceeds 10MB limit'**
  String get fileTooLarge;

  /// No description provided for @errorPickingFile.
  ///
  /// In en, this message translates to:
  /// **'Error picking file:'**
  String get errorPickingFile;

  /// No description provided for @photoTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Photo exceeds 10MB limit'**
  String get photoTooLarge;

  /// No description provided for @backendTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: Keep the laptop backend running on the same Wi-Fi (port 8000)'**
  String get backendTip;

  /// No description provided for @simulatorTitle.
  ///
  /// In en, this message translates to:
  /// **'Scenario Simulator'**
  String get simulatorTitle;

  /// No description provided for @bribeFlowTitle.
  ///
  /// In en, this message translates to:
  /// **'Bribe Refusal Flow'**
  String get bribeFlowTitle;

  /// No description provided for @actionLabel.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get actionLabel;

  /// No description provided for @startOver.
  ///
  /// In en, this message translates to:
  /// **'Start Over'**
  String get startOver;

  /// No description provided for @stepIndicator.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepIndicator(Object current, Object total);

  /// No description provided for @simulatorStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Officer Stops You'**
  String get simulatorStep1Title;

  /// No description provided for @simulatorStep1Desc.
  ///
  /// In en, this message translates to:
  /// **'Traffic officer asks for bribe'**
  String get simulatorStep1Desc;

  /// No description provided for @simulatorStep1Action.
  ///
  /// In en, this message translates to:
  /// **'Refuse Politely'**
  String get simulatorStep1Action;

  /// No description provided for @simulatorStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Collect Details'**
  String get simulatorStep2Title;

  /// No description provided for @simulatorStep2Desc.
  ///
  /// In en, this message translates to:
  /// **'Note badge number, time, location'**
  String get simulatorStep2Desc;

  /// No description provided for @simulatorStep2Action.
  ///
  /// In en, this message translates to:
  /// **'Record Information'**
  String get simulatorStep2Action;

  /// No description provided for @simulatorStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Request Challan'**
  String get simulatorStep3Title;

  /// No description provided for @simulatorStep3Desc.
  ///
  /// In en, this message translates to:
  /// **'Ask for written official challan'**
  String get simulatorStep3Desc;

  /// No description provided for @simulatorStep3Action.
  ///
  /// In en, this message translates to:
  /// **'Get Documentation'**
  String get simulatorStep3Action;

  /// No description provided for @simulatorStep4Title.
  ///
  /// In en, this message translates to:
  /// **'Report Incident'**
  String get simulatorStep4Title;

  /// No description provided for @simulatorStep4Desc.
  ///
  /// In en, this message translates to:
  /// **'Call 1915 helpline immediately'**
  String get simulatorStep4Desc;

  /// No description provided for @simulatorStep4Action.
  ///
  /// In en, this message translates to:
  /// **'File Complaint'**
  String get simulatorStep4Action;

  /// No description provided for @simulatorStep5Title.
  ///
  /// In en, this message translates to:
  /// **'Follow Up'**
  String get simulatorStep5Title;

  /// No description provided for @simulatorStep5Desc.
  ///
  /// In en, this message translates to:
  /// **'Submit written complaint online'**
  String get simulatorStep5Desc;

  /// No description provided for @simulatorStep5Action.
  ///
  /// In en, this message translates to:
  /// **'Track Status'**
  String get simulatorStep5Action;

  /// No description provided for @step2Title.
  ///
  /// In en, this message translates to:
  /// **'Record Time and Place'**
  String get step2Title;

  /// No description provided for @step2Desc.
  ///
  /// In en, this message translates to:
  /// **'Note exact time, date, and location.'**
  String get step2Desc;

  /// No description provided for @step2Tip1.
  ///
  /// In en, this message translates to:
  /// **'Check your phone'**
  String get step2Tip1;

  /// No description provided for @step2Tip2.
  ///
  /// In en, this message translates to:
  /// **'Note landmarks'**
  String get step2Tip2;

  /// No description provided for @step2Tip3.
  ///
  /// In en, this message translates to:
  /// **'Remember street names'**
  String get step2Tip3;

  /// No description provided for @step3Title.
  ///
  /// In en, this message translates to:
  /// **'Ask for Officer Details'**
  String get step3Title;

  /// No description provided for @step3Desc.
  ///
  /// In en, this message translates to:
  /// **'Request officer name and badge number.'**
  String get step3Desc;

  /// No description provided for @step3Tip1.
  ///
  /// In en, this message translates to:
  /// **'Ask politely'**
  String get step3Tip1;

  /// No description provided for @step3Tip2.
  ///
  /// In en, this message translates to:
  /// **'Note vehicle number'**
  String get step3Tip2;

  /// No description provided for @step3Tip3.
  ///
  /// In en, this message translates to:
  /// **'Be firm'**
  String get step3Tip3;

  /// No description provided for @step4Title.
  ///
  /// In en, this message translates to:
  /// **'Save Challan Number'**
  String get step4Title;

  /// No description provided for @step4Desc.
  ///
  /// In en, this message translates to:
  /// **'Keep challan safe.'**
  String get step4Desc;

  /// No description provided for @step4Tip1.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get step4Tip1;

  /// No description provided for @step4Tip2.
  ///
  /// In en, this message translates to:
  /// **'Note number'**
  String get step4Tip2;

  /// No description provided for @step4Tip3.
  ///
  /// In en, this message translates to:
  /// **'Keep original'**
  String get step4Tip3;

  /// No description provided for @step5Title.
  ///
  /// In en, this message translates to:
  /// **'Safe Recording'**
  String get step5Title;

  /// No description provided for @step5Desc.
  ///
  /// In en, this message translates to:
  /// **'Document legally.'**
  String get step5Desc;

  /// No description provided for @step5Tip1.
  ///
  /// In en, this message translates to:
  /// **'Video allowed'**
  String get step5Tip1;

  /// No description provided for @step5Tip2.
  ///
  /// In en, this message translates to:
  /// **'Keep visible'**
  String get step5Tip2;

  /// No description provided for @step5Tip3.
  ///
  /// In en, this message translates to:
  /// **'Inform officer'**
  String get step5Tip3;

  /// No description provided for @step5Tip4.
  ///
  /// In en, this message translates to:
  /// **'No secret audio'**
  String get step5Tip4;

  /// No description provided for @step6Title.
  ///
  /// In en, this message translates to:
  /// **'Gather Evidence'**
  String get step6Title;

  /// No description provided for @step6Desc.
  ///
  /// In en, this message translates to:
  /// **'Collect proof.'**
  String get step6Desc;

  /// No description provided for @step6Tip1.
  ///
  /// In en, this message translates to:
  /// **'Take photos'**
  String get step6Tip1;

  /// No description provided for @step6Tip2.
  ///
  /// In en, this message translates to:
  /// **'Get witnesses'**
  String get step6Tip2;

  /// No description provided for @step6Tip3.
  ///
  /// In en, this message translates to:
  /// **'Note CCTV'**
  String get step6Tip3;

  /// No description provided for @nextFileComplaint.
  ///
  /// In en, this message translates to:
  /// **'Next: File Complaint'**
  String get nextFileComplaint;

  /// No description provided for @safetyWarning.
  ///
  /// In en, this message translates to:
  /// **'If threatened, prioritize safety'**
  String get safetyWarning;

  /// No description provided for @call1915.
  ///
  /// In en, this message translates to:
  /// **'Call 1915'**
  String get call1915;

  /// No description provided for @fileComplaint.
  ///
  /// In en, this message translates to:
  /// **'File Complaint'**
  String get fileComplaint;

  /// No description provided for @submitInstruction.
  ///
  /// In en, this message translates to:
  /// **'Submit this complaint to SSP Traffic office or file online through provincial police portal'**
  String get submitInstruction;

  /// No description provided for @notNoted.
  ///
  /// In en, this message translates to:
  /// **'Not noted'**
  String get notNoted;

  /// No description provided for @noWitnesses.
  ///
  /// In en, this message translates to:
  /// **'No witnesses present'**
  String get noWitnesses;

  /// No description provided for @complaintTitle.
  ///
  /// In en, this message translates to:
  /// **'FORMAL COMPLAINT AGAINST POLICE OFFICER MISBEHAVIOR'**
  String get complaintTitle;

  /// No description provided for @toSSP.
  ///
  /// In en, this message translates to:
  /// **'To: Senior Superintendent of Police (SSP) Traffic'**
  String get toSSP;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @intro.
  ///
  /// In en, this message translates to:
  /// **'I am writing to file a formal complaint regarding the unprofessional conduct of a traffic police officer.'**
  String get intro;

  /// No description provided for @officerIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Officer ID/Badge Number'**
  String get officerIdLabel;

  /// No description provided for @witnessSection.
  ///
  /// In en, this message translates to:
  /// **'WITNESSES:'**
  String get witnessSection;

  /// No description provided for @requestAction.
  ///
  /// In en, this message translates to:
  /// **'I request that you investigate this matter and take appropriate action.'**
  String get requestAction;

  /// No description provided for @closing.
  ///
  /// In en, this message translates to:
  /// **'I am willing to provide further information if required.'**
  String get closing;

  /// No description provided for @yoursSincerely.
  ///
  /// In en, this message translates to:
  /// **'Yours sincerely'**
  String get yoursSincerely;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @safeCity.
  ///
  /// In en, this message translates to:
  /// **'SafeCity / PSCA'**
  String get safeCity;

  /// No description provided for @safeCityDesc.
  ///
  /// In en, this message translates to:
  /// **'Official Safe Cities Punjab site'**
  String get safeCityDesc;

  /// No description provided for @visitWebsite.
  ///
  /// In en, this message translates to:
  /// **'Visit Website'**
  String get visitWebsite;

  /// No description provided for @khidmatMarkaz.
  ///
  /// In en, this message translates to:
  /// **'Police Khidmat Markaz'**
  String get khidmatMarkaz;

  /// No description provided for @khidmatMarkazDesc.
  ///
  /// In en, this message translates to:
  /// **'Find a service centre on the map'**
  String get khidmatMarkazDesc;

  /// No description provided for @findLocation.
  ///
  /// In en, this message translates to:
  /// **'Find Location'**
  String get findLocation;

  /// No description provided for @helpline1787.
  ///
  /// In en, this message translates to:
  /// **'1787 Complaint Helpline'**
  String get helpline1787;

  /// No description provided for @helpline1787Desc.
  ///
  /// In en, this message translates to:
  /// **'National police complaint line'**
  String get helpline1787Desc;

  /// No description provided for @writtenComplaint.
  ///
  /// In en, this message translates to:
  /// **'Written Complaint'**
  String get writtenComplaint;

  /// No description provided for @writtenComplaintDesc.
  ///
  /// In en, this message translates to:
  /// **'Addresses, copy, maps & online portal'**
  String get writtenComplaintDesc;

  /// No description provided for @getAddress.
  ///
  /// In en, this message translates to:
  /// **'Get Address'**
  String get getAddress;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// No description provided for @punjabContact.
  ///
  /// In en, this message translates to:
  /// **'Punjab: 1915 or complaint.punjabpolice.gov.pk'**
  String get punjabContact;

  /// No description provided for @sindhContact.
  ///
  /// In en, this message translates to:
  /// **'Sindh: 1915 or sindhpolice.gov.pk'**
  String get sindhContact;

  /// No description provided for @kpkContact.
  ///
  /// In en, this message translates to:
  /// **'KPK: 1915 or kppolice.gov.pk'**
  String get kpkContact;

  /// No description provided for @islamabadContact.
  ///
  /// In en, this message translates to:
  /// **'Islamabad: 1715 or islamabadpolice.gov.pk'**
  String get islamabadContact;

  /// No description provided for @generateAIComplaint.
  ///
  /// In en, this message translates to:
  /// **'Generate AI Complaint Letter'**
  String get generateAIComplaint;

  /// No description provided for @fileWithinDays.
  ///
  /// In en, this message translates to:
  /// **'File complaint within 7 days for best results'**
  String get fileWithinDays;

  /// No description provided for @contactNumber.
  ///
  /// In en, this message translates to:
  /// **'Contact number'**
  String get contactNumber;

  /// No description provided for @whatHappened.
  ///
  /// In en, this message translates to:
  /// **'What Happened?'**
  String get whatHappened;

  /// No description provided for @whereDidItHappen.
  ///
  /// In en, this message translates to:
  /// **'Where Did It Happen?'**
  String get whereDidItHappen;

  /// No description provided for @asOnCnic.
  ///
  /// In en, this message translates to:
  /// **'As on CNIC'**
  String get asOnCnic;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get mobileNumber;

  /// No description provided for @cnicFormat.
  ///
  /// In en, this message translates to:
  /// **'12345-1234567-1'**
  String get cnicFormat;

  /// No description provided for @whatHappenedHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the incident in detail: what the officer said, did, or demanded...'**
  String get whatHappenedHint;

  /// No description provided for @locationHint.
  ///
  /// In en, this message translates to:
  /// **'Exact location (road name, area, city)'**
  String get locationHint;

  /// No description provided for @timeHint.
  ///
  /// In en, this message translates to:
  /// **'HH:MM AM/PM'**
  String get timeHint;

  /// No description provided for @officerIdHint.
  ///
  /// In en, this message translates to:
  /// **'If you noted it down'**
  String get officerIdHint;

  /// No description provided for @enterLocation.
  ///
  /// In en, this message translates to:
  /// **'Please enter the location'**
  String get enterLocation;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @tipLabel.
  ///
  /// In en, this message translates to:
  /// **'Tip: '**
  String get tipLabel;

  /// No description provided for @tipDescription.
  ///
  /// In en, this message translates to:
  /// **'Be specific and factual. Include exact quotes if you remember them.'**
  String get tipDescription;

  /// No description provided for @updateComplaintButton.
  ///
  /// In en, this message translates to:
  /// **'Update Complaint Letter'**
  String get updateComplaintButton;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Please select the time of the incident.'**
  String get selectTime;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @signInRequired.
  ///
  /// In en, this message translates to:
  /// **'Sign in to save this complaint to your account.'**
  String get signInRequired;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save complaint.'**
  String get saveFailed;

  /// No description provided for @stepsIfMisbehaves.
  ///
  /// In en, this message translates to:
  /// **'Steps to take if officer misbehaves'**
  String get stepsIfMisbehaves;

  /// No description provided for @whatCountsMisbehavior.
  ///
  /// In en, this message translates to:
  /// **'What Counts as Misbehavior?'**
  String get whatCountsMisbehavior;

  /// No description provided for @bribeTitle.
  ///
  /// In en, this message translates to:
  /// **'Asking for Bribe'**
  String get bribeTitle;

  /// No description provided for @bribeDesc.
  ///
  /// In en, this message translates to:
  /// **'Officer demands money instead of issuing challan'**
  String get bribeDesc;

  /// No description provided for @threatTitle.
  ///
  /// In en, this message translates to:
  /// **'Threatening Behavior'**
  String get threatTitle;

  /// No description provided for @threatDesc.
  ///
  /// In en, this message translates to:
  /// **'Verbal threats, intimidation, or aggressive conduct'**
  String get threatDesc;

  /// No description provided for @illegalConfiscationTitle.
  ///
  /// In en, this message translates to:
  /// **'Taking Keys/Documents Illegally'**
  String get illegalConfiscationTitle;

  /// No description provided for @illegalConfiscationDesc.
  ///
  /// In en, this message translates to:
  /// **'Confiscating items without proper authority'**
  String get illegalConfiscationDesc;

  /// No description provided for @wrongChallanTitle.
  ///
  /// In en, this message translates to:
  /// **'Wrong Challan'**
  String get wrongChallanTitle;

  /// No description provided for @wrongChallanDesc.
  ///
  /// In en, this message translates to:
  /// **'Issuing challan for violation you did not commit'**
  String get wrongChallanDesc;

  /// No description provided for @serious.
  ///
  /// In en, this message translates to:
  /// **'Serious'**
  String get serious;

  /// No description provided for @moderate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get moderate;

  /// No description provided for @viewImmediateSteps.
  ///
  /// In en, this message translates to:
  /// **'View Immediate Steps'**
  String get viewImmediateSteps;

  /// No description provided for @fileComplaintNow.
  ///
  /// In en, this message translates to:
  /// **'File Complaint Now'**
  String get fileComplaintNow;

  /// No description provided for @documentTip.
  ///
  /// In en, this message translates to:
  /// **'Document everything: time, place, officer ID, and witnesses'**
  String get documentTip;

  /// No description provided for @complaintPaths.
  ///
  /// In en, this message translates to:
  /// **'Complaint paths'**
  String get complaintPaths;

  /// No description provided for @requiredDocuments.
  ///
  /// In en, this message translates to:
  /// **'Required Documents'**
  String get requiredDocuments;

  /// No description provided for @documentsToCarry.
  ///
  /// In en, this message translates to:
  /// **'Documents to Carry While Driving'**
  String get documentsToCarry;

  /// No description provided for @keepDocs.
  ///
  /// In en, this message translates to:
  /// **'Always keep these documents in your '**
  String get keepDocs;

  /// No description provided for @vehicleWord.
  ///
  /// In en, this message translates to:
  /// **'vehicle'**
  String get vehicleWord;

  /// No description provided for @drivingLicense.
  ///
  /// In en, this message translates to:
  /// **'Driving License'**
  String get drivingLicense;

  /// No description provided for @drivingLicenseDesc.
  ///
  /// In en, this message translates to:
  /// **'Must be valid and not expired'**
  String get drivingLicenseDesc;

  /// No description provided for @vehicleRegistration.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Registration'**
  String get vehicleRegistration;

  /// No description provided for @vehicleRegistrationDesc.
  ///
  /// In en, this message translates to:
  /// **'Original or certified copy'**
  String get vehicleRegistrationDesc;

  /// No description provided for @insuranceCertificate.
  ///
  /// In en, this message translates to:
  /// **'Insurance Certificate'**
  String get insuranceCertificate;

  /// No description provided for @insuranceCertificateDesc.
  ///
  /// In en, this message translates to:
  /// **'Valid third-party insurance minimum'**
  String get insuranceCertificateDesc;

  /// No description provided for @routePermit.
  ///
  /// In en, this message translates to:
  /// **'Route Permit'**
  String get routePermit;

  /// No description provided for @routePermitDesc.
  ///
  /// In en, this message translates to:
  /// **'For commercial vehicles only'**
  String get routePermitDesc;

  /// No description provided for @fitnessCertificate.
  ///
  /// In en, this message translates to:
  /// **'Fitness Certificate'**
  String get fitnessCertificate;

  /// No description provided for @fitnessCertificateDesc.
  ///
  /// In en, this message translates to:
  /// **'For vehicles over 3 years old'**
  String get fitnessCertificateDesc;

  /// No description provided for @pollutionCertificate.
  ///
  /// In en, this message translates to:
  /// **'Pollution Certificate'**
  String get pollutionCertificate;

  /// No description provided for @pollutionCertificateDesc.
  ///
  /// In en, this message translates to:
  /// **'Valid emission test certificate'**
  String get pollutionCertificateDesc;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @fineWarning.
  ///
  /// In en, this message translates to:
  /// **'Driving without required documents can result in Rs. 500-1000 fine'**
  String get fineWarning;

  /// No description provided for @trafficHeaderUrdu.
  ///
  /// In en, this message translates to:
  /// **'Traffic\nLaws'**
  String get trafficHeaderUrdu;

  /// No description provided for @ocrReaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Traffic Challan OCR Reader'**
  String get ocrReaderTitle;

  /// No description provided for @ocrReaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scan and identify violations'**
  String get ocrReaderSubtitle;

  /// No description provided for @offenceGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Offence Types Guide'**
  String get offenceGuideTitle;

  /// No description provided for @offenceGuideSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Recognize traffic violations'**
  String get offenceGuideSubtitle;

  /// No description provided for @policeGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Police Misbehavior Guide'**
  String get policeGuideTitle;

  /// No description provided for @policeGuideSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Steps if officer misbehaves'**
  String get policeGuideSubtitle;

  /// No description provided for @simulatorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn traffic-related scenarios'**
  String get simulatorSubtitle;

  /// No description provided for @simulatorStepStopTitle.
  ///
  /// In en, this message translates to:
  /// **'Officer Stops You'**
  String get simulatorStepStopTitle;

  /// No description provided for @simulatorStepStopDesc.
  ///
  /// In en, this message translates to:
  /// **'Traffic officer asks for bribe'**
  String get simulatorStepStopDesc;

  /// No description provided for @simulatorStepStopAction.
  ///
  /// In en, this message translates to:
  /// **'Refuse Politely'**
  String get simulatorStepStopAction;

  /// No description provided for @simulatorStepDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Collect Details'**
  String get simulatorStepDetailsTitle;

  /// No description provided for @simulatorStepDetailsDesc.
  ///
  /// In en, this message translates to:
  /// **'Note badge number, time, location'**
  String get simulatorStepDetailsDesc;

  /// No description provided for @simulatorStepDetailsAction.
  ///
  /// In en, this message translates to:
  /// **'Record Information'**
  String get simulatorStepDetailsAction;

  /// No description provided for @simulatorStepChallanTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Challan'**
  String get simulatorStepChallanTitle;

  /// No description provided for @simulatorStepChallanDesc.
  ///
  /// In en, this message translates to:
  /// **'Ask for written official challan'**
  String get simulatorStepChallanDesc;

  /// No description provided for @simulatorStepChallanAction.
  ///
  /// In en, this message translates to:
  /// **'Get Documentation'**
  String get simulatorStepChallanAction;

  /// No description provided for @simulatorStepReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report Incident'**
  String get simulatorStepReportTitle;

  /// No description provided for @simulatorStepReportDesc.
  ///
  /// In en, this message translates to:
  /// **'Call 1915 helpline immediately'**
  String get simulatorStepReportDesc;

  /// No description provided for @simulatorStepReportAction.
  ///
  /// In en, this message translates to:
  /// **'File Complaint'**
  String get simulatorStepReportAction;

  /// No description provided for @simulatorStepFollowUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Follow Up'**
  String get simulatorStepFollowUpTitle;

  /// No description provided for @simulatorStepFollowUpDesc.
  ///
  /// In en, this message translates to:
  /// **'Submit written complaint online'**
  String get simulatorStepFollowUpDesc;

  /// No description provided for @simulatorStepFollowUpAction.
  ///
  /// In en, this message translates to:
  /// **'Track Status'**
  String get simulatorStepFollowUpAction;

  /// No description provided for @reportingGuidanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Reporting Guidance'**
  String get reportingGuidanceTitle;

  /// No description provided for @analyzingAccount.
  ///
  /// In en, this message translates to:
  /// **'Analyzing account...'**
  String get analyzingAccount;

  /// No description provided for @fakeAccountDetected.
  ///
  /// In en, this message translates to:
  /// **'Fake Account Detected'**
  String get fakeAccountDetected;

  /// No description provided for @followStepsReport.
  ///
  /// In en, this message translates to:
  /// **'Follow these steps to report'**
  String get followStepsReport;

  /// No description provided for @referenceId.
  ///
  /// In en, this message translates to:
  /// **'Reference ID'**
  String get referenceId;

  /// No description provided for @protectionTips.
  ///
  /// In en, this message translates to:
  /// **'Additional Protection Tips'**
  String get protectionTips;

  /// No description provided for @reportAnotherAccount.
  ///
  /// In en, this message translates to:
  /// **'Report Another Account'**
  String get reportAnotherAccount;

  /// No description provided for @urlLabel.
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get urlLabel;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// No description provided for @platformLabel.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get platformLabel;

  /// No description provided for @tipSaveScreenshots.
  ///
  /// In en, this message translates to:
  /// **'Save all screenshots with timestamps'**
  String get tipSaveScreenshots;

  /// No description provided for @tipDocumentInteractions.
  ///
  /// In en, this message translates to:
  /// **'Document all interactions'**
  String get tipDocumentInteractions;

  /// No description provided for @tipInformContacts.
  ///
  /// In en, this message translates to:
  /// **'Inform your contacts about fake account'**
  String get tipInformContacts;

  /// No description provided for @tipEnablePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Enable privacy settings'**
  String get tipEnablePrivacy;

  /// No description provided for @legalFia.
  ///
  /// In en, this message translates to:
  /// **'File FIA complaint under PECA'**
  String get legalFia;

  /// No description provided for @legalPta.
  ///
  /// In en, this message translates to:
  /// **'Report to PTA'**
  String get legalPta;

  /// No description provided for @legalFIR.
  ///
  /// In en, this message translates to:
  /// **'File FIR if harassment or fraud'**
  String get legalFIR;

  /// No description provided for @legalCivilCase.
  ///
  /// In en, this message translates to:
  /// **'Consider civil defamation case'**
  String get legalCivilCase;

  /// No description provided for @defaultAnalysisSummary.
  ///
  /// In en, this message translates to:
  /// **'Guidance generated from provided evidence.'**
  String get defaultAnalysisSummary;

  /// No description provided for @guestFeatureTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign In Required'**
  String get guestFeatureTitle;

  /// No description provided for @guestChatMessage.
  ///
  /// In en, this message translates to:
  /// **'Chat with our AI legal assistant is only available for signed-in users. Create an account to save your conversations and access personalized guidance.'**
  String get guestChatMessage;

  /// No description provided for @guestComplaintMessage.
  ///
  /// In en, this message translates to:
  /// **'Filing complaints requires an account to safely store your information and track status. Sign in to get started.'**
  String get guestComplaintMessage;

  /// No description provided for @guestDownloadMessage.
  ///
  /// In en, this message translates to:
  /// **'Downloading and saving documents requires an account. Create an account to save your generated documents and access them anytime.'**
  String get guestDownloadMessage;

  /// No description provided for @guestGenerateMessage.
  ///
  /// In en, this message translates to:
  /// **'Generating documents requires an account to save your work. Sign in to generate and manage your legal documents.'**
  String get guestGenerateMessage;

  /// No description provided for @guestSubmitMessage.
  ///
  /// In en, this message translates to:
  /// **'Submitting forms requires an account. Sign in to submit your information and track your requests.'**
  String get guestSubmitMessage;

  /// No description provided for @guestSaveMessage.
  ///
  /// In en, this message translates to:
  /// **'Saving your work requires an account. Create an account to store your progress and access it later.'**
  String get guestSaveMessage;

  /// No description provided for @guestSimulatorMessage.
  ///
  /// In en, this message translates to:
  /// **'Scenario simulation with personalized feedback requires an account. Sign in to track your learning progress.'**
  String get guestSimulatorMessage;

  /// No description provided for @continueExploring.
  ///
  /// In en, this message translates to:
  /// **'Continue Exploring'**
  String get continueExploring;

  /// No description provided for @signInToAccess.
  ///
  /// In en, this message translates to:
  /// **'Sign In to Access This Feature'**
  String get signInToAccess;

  /// No description provided for @guestCanExplore.
  ///
  /// In en, this message translates to:
  /// **'As a guest, you can explore all available information and resources. Sign in to unlock interactive features and save your work.'**
  String get guestCanExplore;

  /// No description provided for @guestBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Exploring as Guest'**
  String get guestBannerTitle;

  /// No description provided for @guestBannerMessage.
  ///
  /// In en, this message translates to:
  /// **'You can view information, but services require sign in.'**
  String get guestBannerMessage;

  /// No description provided for @signInForFeatures.
  ///
  /// In en, this message translates to:
  /// **'Sign In for Full Features'**
  String get signInForFeatures;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @passwordRule.
  ///
  /// In en, this message translates to:
  /// **'Use 8+ characters with uppercase, lowercase, number, and symbol.'**
  String get passwordRule;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @orText.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get orText;

  /// No description provided for @passwordRequirements.
  ///
  /// In en, this message translates to:
  /// **'Password must be 6+ characters and include uppercase, lowercase, number, and symbol.'**
  String get passwordRequirements;

  /// No description provided for @bySigningUp.
  ///
  /// In en, this message translates to:
  /// **'By signing up, you agree to our '**
  String get bySigningUp;

  /// No description provided for @andText.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get andText;

  /// No description provided for @nameMinCharacters.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 3 characters'**
  String get nameMinCharacters;

  /// No description provided for @passwordMinCharacters.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinCharacters;

  /// No description provided for @passwordComplexity.
  ///
  /// In en, this message translates to:
  /// **'Use uppercase, lowercase, number, and symbol'**
  String get passwordComplexity;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get emailInvalid;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get passwordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordTooShort;

  /// No description provided for @enterEmailFirst.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email first'**
  String get enterEmailFirst;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Set New Password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a strong password for your account'**
  String get resetPasswordSubtitle;

  /// No description provided for @setNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get setNewPassword;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @signInFirstToChangePassword.
  ///
  /// In en, this message translates to:
  /// **'You must sign in first before you can change your password. After signing in, go to Profile → Settings → Change Password.'**
  String get signInFirstToChangePassword;

  /// No description provided for @signInRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in required'**
  String get signInRequiredTitle;

  /// No description provided for @passwordResetSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Password reset'**
  String get passwordResetSuccessTitle;

  /// No description provided for @passwordResetSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your password has been reset successfully. Go back and sign in with your new password.'**
  String get passwordResetSuccessMessage;

  /// No description provided for @passwordResetCloseTabMessage.
  ///
  /// In en, this message translates to:
  /// **'Your password has been reset successfully.'**
  String get passwordResetCloseTabMessage;

  /// No description provided for @passwordResetCloseTabHint.
  ///
  /// In en, this message translates to:
  /// **'You can close this browser tab now. Return to the Legal Sathi app window (where you tapped Forgot Password) and sign in with your new password.'**
  String get passwordResetCloseTabHint;

  /// No description provided for @goToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Go to Sign In'**
  String get goToSignIn;

  /// No description provided for @tipsBackupCloudStorage.
  ///
  /// In en, this message translates to:
  /// **'Back up to cloud storage immediately'**
  String get tipsBackupCloudStorage;

  /// No description provided for @tipsMultipleCopies.
  ///
  /// In en, this message translates to:
  /// **'Keep multiple copies in different locations'**
  String get tipsMultipleCopies;

  /// No description provided for @tipsDontCompress.
  ///
  /// In en, this message translates to:
  /// **'Don\'t compress or reduce image quality'**
  String get tipsDontCompress;

  /// No description provided for @tipsNoteMetadata.
  ///
  /// In en, this message translates to:
  /// **'Note metadata (date, time, sender)'**
  String get tipsNoteMetadata;

  /// No description provided for @tipsStoreChronologically.
  ///
  /// In en, this message translates to:
  /// **'Store chronologically with labels'**
  String get tipsStoreChronologically;

  /// No description provided for @limitedAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Limited Access'**
  String get limitedAccessTitle;

  /// No description provided for @limitedAccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Scenario simulations with progress tracking are available for signed-in users. You can still view the scenarios as a guest.'**
  String get limitedAccessMessage;

  /// No description provided for @selectLegalDomain.
  ///
  /// In en, this message translates to:
  /// **'Select Legal Domain *'**
  String get selectLegalDomain;

  /// No description provided for @describeLegalSituation.
  ///
  /// In en, this message translates to:
  /// **'Describe Your Legal Situation'**
  String get describeLegalSituation;

  /// No description provided for @aiGuidanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'AI will guide you step-by-step with legal advice and next actions'**
  String get aiGuidanceSubtitle;

  /// No description provided for @womenHarassment.
  ///
  /// In en, this message translates to:
  /// **'Women Harassment'**
  String get womenHarassment;

  /// No description provided for @womenHarassmentDesc.
  ///
  /// In en, this message translates to:
  /// **'Workplace harassment, protection act, ombudsperson complaints'**
  String get womenHarassmentDesc;

  /// No description provided for @labourRightsDesc.
  ///
  /// In en, this message translates to:
  /// **'Wages, overtime, leave, contract violations, labour complaints'**
  String get labourRightsDesc;

  /// No description provided for @cyberCrime.
  ///
  /// In en, this message translates to:
  /// **'Cyber Crime (PECA)'**
  String get cyberCrime;

  /// No description provided for @cyberCrimeDesc.
  ///
  /// In en, this message translates to:
  /// **'Online harassment, blackmail, fake accounts, FIA complaints'**
  String get cyberCrimeDesc;

  /// No description provided for @trafficLaw.
  ///
  /// In en, this message translates to:
  /// **'Road & Traffic Law'**
  String get trafficLaw;

  /// No description provided for @trafficLawDesc.
  ///
  /// In en, this message translates to:
  /// **'Traffic violations, challans, fines, police misconduct'**
  String get trafficLawDesc;

  /// No description provided for @aiStep1.
  ///
  /// In en, this message translates to:
  /// **'Describe your situation in your own words'**
  String get aiStep1;

  /// No description provided for @aiStep2.
  ///
  /// In en, this message translates to:
  /// **'AI asks clarifying questions if needed'**
  String get aiStep2;

  /// No description provided for @aiStep3.
  ///
  /// In en, this message translates to:
  /// **'Get step-by-step legal guidance (PECA, Labour Act, etc.)'**
  String get aiStep3;

  /// No description provided for @aiStep4.
  ///
  /// In en, this message translates to:
  /// **'Receive relevant law references'**
  String get aiStep4;

  /// No description provided for @aiStep5.
  ///
  /// In en, this message translates to:
  /// **'Get complaint and legal remedies recommendations'**
  String get aiStep5;

  /// No description provided for @aiStep6.
  ///
  /// In en, this message translates to:
  /// **'All actions happen within the chat'**
  String get aiStep6;

  /// No description provided for @stepProgress.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepProgress(Object current, Object total);

  /// No description provided for @startChat.
  ///
  /// In en, this message translates to:
  /// **'Start Chat with AI Advisor'**
  String get startChat;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @simulation_suspectInfo.
  ///
  /// In en, this message translates to:
  /// **'Suspect Information (if known)'**
  String get simulation_suspectInfo;

  /// No description provided for @simulation_aiStep1.
  ///
  /// In en, this message translates to:
  /// **'Describe your situation in your own words'**
  String get simulation_aiStep1;

  /// No description provided for @simulation_aiStep2.
  ///
  /// In en, this message translates to:
  /// **'AI asks clarifying questions if needed'**
  String get simulation_aiStep2;

  /// No description provided for @simulation_aiStep3.
  ///
  /// In en, this message translates to:
  /// **'Get step-by-step legal guidance (PECA, Labour Act, etc.)'**
  String get simulation_aiStep3;

  /// No description provided for @simulation_aiStep4.
  ///
  /// In en, this message translates to:
  /// **'Receive relevant law references'**
  String get simulation_aiStep4;

  /// No description provided for @simulation_aiStep5.
  ///
  /// In en, this message translates to:
  /// **'Get complaint and legal remedies recommendations'**
  String get simulation_aiStep5;

  /// No description provided for @simulation_aiStep6.
  ///
  /// In en, this message translates to:
  /// **'All actions happen within the chat'**
  String get simulation_aiStep6;

  /// No description provided for @trafficAccidentDisputeTitle.
  ///
  /// In en, this message translates to:
  /// **'Traffic Accident Dispute'**
  String get trafficAccidentDisputeTitle;

  /// No description provided for @trafficAccidentDisputeDesc.
  ///
  /// In en, this message translates to:
  /// **'You were involved in a traffic accident and need guidance'**
  String get trafficAccidentDisputeDesc;

  /// No description provided for @accidentSceneTitle.
  ///
  /// In en, this message translates to:
  /// **'At the Scene of Accident'**
  String get accidentSceneTitle;

  /// No description provided for @accidentSceneDesc.
  ///
  /// In en, this message translates to:
  /// **'What to do immediately after the accident'**
  String get accidentSceneDesc;

  /// No description provided for @moveToSafeLocation.
  ///
  /// In en, this message translates to:
  /// **'Move to a safe location if possible'**
  String get moveToSafeLocation;

  /// No description provided for @alertTrafficHazard.
  ///
  /// In en, this message translates to:
  /// **'Alert other traffic using hazard lights'**
  String get alertTrafficHazard;

  /// No description provided for @callPolice.
  ///
  /// In en, this message translates to:
  /// **'Call police or traffic helpline'**
  String get callPolice;

  /// No description provided for @dontAdmitFault.
  ///
  /// In en, this message translates to:
  /// **'Do not admit fault or sign documents'**
  String get dontAdmitFault;

  /// No description provided for @gatherWitnessInfo.
  ///
  /// In en, this message translates to:
  /// **'Gather witness information and photos'**
  String get gatherWitnessInfo;

  /// No description provided for @accidentDocsTitle.
  ///
  /// In en, this message translates to:
  /// **'Documentation Required'**
  String get accidentDocsTitle;

  /// No description provided for @accidentDocsDesc.
  ///
  /// In en, this message translates to:
  /// **'Collect these documents for your protection'**
  String get accidentDocsDesc;

  /// No description provided for @firNumber.
  ///
  /// In en, this message translates to:
  /// **'FIR number'**
  String get firNumber;

  /// No description provided for @insuranceDetails.
  ///
  /// In en, this message translates to:
  /// **'Insurance policy details'**
  String get insuranceDetails;

  /// No description provided for @accidentPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photographs of accident site'**
  String get accidentPhotos;

  /// No description provided for @medicalCertificate.
  ///
  /// In en, this message translates to:
  /// **'Medical certificates if injured'**
  String get medicalCertificate;

  /// No description provided for @accidentRightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Legal Rights & Claims'**
  String get accidentRightsTitle;

  /// No description provided for @accidentRightsDesc.
  ///
  /// In en, this message translates to:
  /// **'Know your compensation options'**
  String get accidentRightsDesc;

  /// No description provided for @fileMotorClaim.
  ///
  /// In en, this message translates to:
  /// **'File motor accident claim within 6 months'**
  String get fileMotorClaim;

  /// No description provided for @vehicleAssessment.
  ///
  /// In en, this message translates to:
  /// **'Get vehicle assessment done'**
  String get vehicleAssessment;

  /// No description provided for @claimMedicalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Claim medical expenses and loss of earnings'**
  String get claimMedicalExpenses;

  /// No description provided for @rightToSue.
  ///
  /// In en, this message translates to:
  /// **'Know your right to sue for damages'**
  String get rightToSue;

  /// No description provided for @licenseIssueTitle.
  ///
  /// In en, this message translates to:
  /// **'License Suspension/Cancellation'**
  String get licenseIssueTitle;

  /// No description provided for @licenseIssueDesc.
  ///
  /// In en, this message translates to:
  /// **'Your driving license is suspended or cancelled'**
  String get licenseIssueDesc;

  /// No description provided for @suspensionVsCancellationTitle.
  ///
  /// In en, this message translates to:
  /// **'Suspension vs Cancellation'**
  String get suspensionVsCancellationTitle;

  /// No description provided for @suspensionVsCancellationDesc.
  ///
  /// In en, this message translates to:
  /// **'Know the difference and implications'**
  String get suspensionVsCancellationDesc;

  /// No description provided for @suspensionDefinition.
  ///
  /// In en, this message translates to:
  /// **'Suspension is temporary license pause'**
  String get suspensionDefinition;

  /// No description provided for @cancellationDefinition.
  ///
  /// In en, this message translates to:
  /// **'Cancellation is permanent revocation'**
  String get cancellationDefinition;

  /// No description provided for @violationReasons.
  ///
  /// In en, this message translates to:
  /// **'Reasons include violations or medical issues'**
  String get violationReasons;

  /// No description provided for @illegalDrivingWarning.
  ///
  /// In en, this message translates to:
  /// **'Driving during suspension is illegal'**
  String get illegalDrivingWarning;

  /// No description provided for @appealProcessTitle.
  ///
  /// In en, this message translates to:
  /// **'Appeal Process'**
  String get appealProcessTitle;

  /// No description provided for @appealProcessDesc.
  ///
  /// In en, this message translates to:
  /// **'How to challenge the decision'**
  String get appealProcessDesc;

  /// No description provided for @fileRTAAppeal.
  ///
  /// In en, this message translates to:
  /// **'File appeal in RTA office'**
  String get fileRTAAppeal;

  /// No description provided for @appealDeadline.
  ///
  /// In en, this message translates to:
  /// **'File within 30 days'**
  String get appealDeadline;

  /// No description provided for @gatherEvidence.
  ///
  /// In en, this message translates to:
  /// **'Gather supporting evidence'**
  String get gatherEvidence;

  /// No description provided for @attendHearing.
  ///
  /// In en, this message translates to:
  /// **'Attend hearing and present case'**
  String get attendHearing;

  /// No description provided for @recoveryStepsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recovery Steps'**
  String get recoveryStepsTitle;

  /// No description provided for @recoveryStepsDesc.
  ///
  /// In en, this message translates to:
  /// **'Steps to restore your license'**
  String get recoveryStepsDesc;

  /// No description provided for @completeSuspension.
  ///
  /// In en, this message translates to:
  /// **'Complete suspension period'**
  String get completeSuspension;

  /// No description provided for @passRefresherTest.
  ///
  /// In en, this message translates to:
  /// **'Pass refresher test if required'**
  String get passRefresherTest;

  /// No description provided for @payFees.
  ///
  /// In en, this message translates to:
  /// **'Pay required fees'**
  String get payFees;

  /// No description provided for @collectLicense.
  ///
  /// In en, this message translates to:
  /// **'Collect renewed license'**
  String get collectLicense;

  /// No description provided for @trafficModuleName.
  ///
  /// In en, this message translates to:
  /// **'Road & Traffic Law'**
  String get trafficModuleName;

  /// No description provided for @womenModuleName.
  ///
  /// In en, this message translates to:
  /// **'Women Harassment'**
  String get womenModuleName;

  /// No description provided for @cyberModuleName.
  ///
  /// In en, this message translates to:
  /// **'Cyber Crime'**
  String get cyberModuleName;

  /// No description provided for @labourModuleName.
  ///
  /// In en, this message translates to:
  /// **'Labour Rights'**
  String get labourModuleName;

  /// No description provided for @generalModuleName.
  ///
  /// In en, this message translates to:
  /// **'Legal Guidance'**
  String get generalModuleName;

  /// No description provided for @trafficChatScreenName.
  ///
  /// In en, this message translates to:
  /// **'Traffic Assistant Chat'**
  String get trafficChatScreenName;

  /// No description provided for @traffic1Title.
  ///
  /// In en, this message translates to:
  /// **'Traffic Violation Fine'**
  String get traffic1Title;

  /// No description provided for @traffic1Desc.
  ///
  /// In en, this message translates to:
  /// **'You received a traffic ticket or penalty challan'**
  String get traffic1Desc;

  /// No description provided for @traffic1Step1Title.
  ///
  /// In en, this message translates to:
  /// **'Understanding Your Violation'**
  String get traffic1Step1Title;

  /// No description provided for @traffic1Step1Desc.
  ///
  /// In en, this message translates to:
  /// **'Know what violation you committed and the legal implications'**
  String get traffic1Step1Desc;

  /// No description provided for @traffic1Step1P1.
  ///
  /// In en, this message translates to:
  /// **'Check the violation code on your challan'**
  String get traffic1Step1P1;

  /// No description provided for @traffic1Step1P2.
  ///
  /// In en, this message translates to:
  /// **'Understand the section under Motor Vehicles Act'**
  String get traffic1Step1P2;

  /// No description provided for @traffic1Step1P3.
  ///
  /// In en, this message translates to:
  /// **'Know the fine amount and deadline'**
  String get traffic1Step1P3;

  /// No description provided for @traffic1Step1P4.
  ///
  /// In en, this message translates to:
  /// **'Learn about your right to appeal'**
  String get traffic1Step1P4;

  /// No description provided for @traffic1Step2Title.
  ///
  /// In en, this message translates to:
  /// **'Do\'s & Don\'ts'**
  String get traffic1Step2Title;

  /// No description provided for @traffic1Step2Desc.
  ///
  /// In en, this message translates to:
  /// **'Important steps to follow'**
  String get traffic1Step2Desc;

  /// No description provided for @traffic1Step2P1.
  ///
  /// In en, this message translates to:
  /// **'Pay the fine on time'**
  String get traffic1Step2P1;

  /// No description provided for @traffic1Step2P2.
  ///
  /// In en, this message translates to:
  /// **'Keep receipt and challan safe'**
  String get traffic1Step2P2;

  /// No description provided for @traffic1Step2P3.
  ///
  /// In en, this message translates to:
  /// **'Appeal if you think it is unfair'**
  String get traffic1Step2P3;

  /// No description provided for @traffic1Step2P4.
  ///
  /// In en, this message translates to:
  /// **'Do not ignore the challan'**
  String get traffic1Step2P4;

  /// No description provided for @traffic1Step2P5.
  ///
  /// In en, this message translates to:
  /// **'Do not offer bribes'**
  String get traffic1Step2P5;

  /// No description provided for @traffic1Step3Title.
  ///
  /// In en, this message translates to:
  /// **'Immediate Actions'**
  String get traffic1Step3Title;

  /// No description provided for @traffic1Step3Desc.
  ///
  /// In en, this message translates to:
  /// **'Steps to take right now'**
  String get traffic1Step3Desc;

  /// No description provided for @traffic1Step3P1.
  ///
  /// In en, this message translates to:
  /// **'Pay fine within deadline'**
  String get traffic1Step3P1;

  /// No description provided for @traffic1Step3P2.
  ///
  /// In en, this message translates to:
  /// **'File appeal in traffic court if needed'**
  String get traffic1Step3P2;

  /// No description provided for @traffic1Step3P3.
  ///
  /// In en, this message translates to:
  /// **'Collect all evidence'**
  String get traffic1Step3P3;

  /// No description provided for @traffic1Step3P4.
  ///
  /// In en, this message translates to:
  /// **'Contact a lawyer if required'**
  String get traffic1Step3P4;

  /// No description provided for @traffic2Title.
  ///
  /// In en, this message translates to:
  /// **'Traffic Accident Dispute'**
  String get traffic2Title;

  /// No description provided for @traffic2Desc.
  ///
  /// In en, this message translates to:
  /// **'You were involved in a traffic accident and need guidance'**
  String get traffic2Desc;

  /// No description provided for @traffic2Step1Title.
  ///
  /// In en, this message translates to:
  /// **'At the Scene of Accident'**
  String get traffic2Step1Title;

  /// No description provided for @traffic2Step1Desc.
  ///
  /// In en, this message translates to:
  /// **'What to do immediately after accident'**
  String get traffic2Step1Desc;

  /// No description provided for @traffic2Step1P1.
  ///
  /// In en, this message translates to:
  /// **'Move to a safe place'**
  String get traffic2Step1P1;

  /// No description provided for @traffic2Step1P2.
  ///
  /// In en, this message translates to:
  /// **'Turn on hazard lights'**
  String get traffic2Step1P2;

  /// No description provided for @traffic2Step1P3.
  ///
  /// In en, this message translates to:
  /// **'Call police (100)'**
  String get traffic2Step1P3;

  /// No description provided for @traffic2Step1P4.
  ///
  /// In en, this message translates to:
  /// **'Do not admit fault'**
  String get traffic2Step1P4;

  /// No description provided for @traffic2Step1P5.
  ///
  /// In en, this message translates to:
  /// **'Collect witness info and photos'**
  String get traffic2Step1P5;

  /// No description provided for @traffic2Step2Title.
  ///
  /// In en, this message translates to:
  /// **'Documentation Required'**
  String get traffic2Step2Title;

  /// No description provided for @traffic2Step2Desc.
  ///
  /// In en, this message translates to:
  /// **'Collect these documents'**
  String get traffic2Step2Desc;

  /// No description provided for @traffic2Step2P1.
  ///
  /// In en, this message translates to:
  /// **'FIR number'**
  String get traffic2Step2P1;

  /// No description provided for @traffic2Step2P2.
  ///
  /// In en, this message translates to:
  /// **'Insurance details'**
  String get traffic2Step2P2;

  /// No description provided for @traffic2Step2P3.
  ///
  /// In en, this message translates to:
  /// **'Photos of accident'**
  String get traffic2Step2P3;

  /// No description provided for @traffic2Step2P4.
  ///
  /// In en, this message translates to:
  /// **'Medical certificates'**
  String get traffic2Step2P4;

  /// No description provided for @traffic2Step2P5.
  ///
  /// In en, this message translates to:
  /// **'Witness statements'**
  String get traffic2Step2P5;

  /// No description provided for @traffic2Step3Title.
  ///
  /// In en, this message translates to:
  /// **'Legal Rights & Claims'**
  String get traffic2Step3Title;

  /// No description provided for @traffic2Step3Desc.
  ///
  /// In en, this message translates to:
  /// **'Know your compensation rights'**
  String get traffic2Step3Desc;

  /// No description provided for @traffic2Step3P1.
  ///
  /// In en, this message translates to:
  /// **'File claim within 6 months'**
  String get traffic2Step3P1;

  /// No description provided for @traffic2Step3P2.
  ///
  /// In en, this message translates to:
  /// **'Get vehicle inspection'**
  String get traffic2Step3P2;

  /// No description provided for @traffic2Step3P3.
  ///
  /// In en, this message translates to:
  /// **'Claim medical expenses'**
  String get traffic2Step3P3;

  /// No description provided for @traffic2Step3P4.
  ///
  /// In en, this message translates to:
  /// **'Right to sue for damages'**
  String get traffic2Step3P4;

  /// No description provided for @traffic3Title.
  ///
  /// In en, this message translates to:
  /// **'License Suspension/Cancellation'**
  String get traffic3Title;

  /// No description provided for @traffic3Desc.
  ///
  /// In en, this message translates to:
  /// **'Your driving license is suspended or cancelled'**
  String get traffic3Desc;

  /// No description provided for @traffic3Step1Title.
  ///
  /// In en, this message translates to:
  /// **'Suspension vs Cancellation'**
  String get traffic3Step1Title;

  /// No description provided for @traffic3Step1Desc.
  ///
  /// In en, this message translates to:
  /// **'Understand the difference'**
  String get traffic3Step1Desc;

  /// No description provided for @traffic3Step1P1.
  ///
  /// In en, this message translates to:
  /// **'Suspension is temporary'**
  String get traffic3Step1P1;

  /// No description provided for @traffic3Step1P2.
  ///
  /// In en, this message translates to:
  /// **'Cancellation is permanent'**
  String get traffic3Step1P2;

  /// No description provided for @traffic3Step1P3.
  ///
  /// In en, this message translates to:
  /// **'Causes include violations or medical issues'**
  String get traffic3Step1P3;

  /// No description provided for @traffic3Step1P4.
  ///
  /// In en, this message translates to:
  /// **'Driving during suspension is illegal'**
  String get traffic3Step1P4;

  /// No description provided for @traffic3Step2Title.
  ///
  /// In en, this message translates to:
  /// **'Appeal Process'**
  String get traffic3Step2Title;

  /// No description provided for @traffic3Step2Desc.
  ///
  /// In en, this message translates to:
  /// **'How to challenge decision'**
  String get traffic3Step2Desc;

  /// No description provided for @traffic3Step2P1.
  ///
  /// In en, this message translates to:
  /// **'File appeal in RTA office'**
  String get traffic3Step2P1;

  /// No description provided for @traffic3Step2P2.
  ///
  /// In en, this message translates to:
  /// **'Within 30 days'**
  String get traffic3Step2P2;

  /// No description provided for @traffic3Step2P3.
  ///
  /// In en, this message translates to:
  /// **'Collect supporting evidence'**
  String get traffic3Step2P3;

  /// No description provided for @traffic3Step2P4.
  ///
  /// In en, this message translates to:
  /// **'Attend hearing'**
  String get traffic3Step2P4;

  /// No description provided for @traffic3Step3Title.
  ///
  /// In en, this message translates to:
  /// **'Recovery Steps'**
  String get traffic3Step3Title;

  /// No description provided for @traffic3Step3Desc.
  ///
  /// In en, this message translates to:
  /// **'How to restore license'**
  String get traffic3Step3Desc;

  /// No description provided for @traffic3Step3P1.
  ///
  /// In en, this message translates to:
  /// **'Complete suspension period'**
  String get traffic3Step3P1;

  /// No description provided for @traffic3Step3P2.
  ///
  /// In en, this message translates to:
  /// **'Pass required tests'**
  String get traffic3Step3P2;

  /// No description provided for @traffic3Step3P3.
  ///
  /// In en, this message translates to:
  /// **'Pay fees'**
  String get traffic3Step3P3;

  /// No description provided for @traffic3Step3P4.
  ///
  /// In en, this message translates to:
  /// **'Collect renewed license'**
  String get traffic3Step3P4;

  /// No description provided for @womenChatName.
  ///
  /// In en, this message translates to:
  /// **'Women Harassment Assistant Chat'**
  String get womenChatName;

  /// No description provided for @women1Title.
  ///
  /// In en, this message translates to:
  /// **'Workplace Sexual Harassment'**
  String get women1Title;

  /// No description provided for @women1Desc.
  ///
  /// In en, this message translates to:
  /// **'You experienced harassment at your workplace'**
  String get women1Desc;

  /// No description provided for @women1Step1Title.
  ///
  /// In en, this message translates to:
  /// **'Understand Your Rights'**
  String get women1Step1Title;

  /// No description provided for @women1Step1Desc.
  ///
  /// In en, this message translates to:
  /// **'Know legal protections available to you'**
  String get women1Step1Desc;

  /// No description provided for @women1Step1P1.
  ///
  /// In en, this message translates to:
  /// **'Sexual Harassment of Women at Workplace Act protects you'**
  String get women1Step1P1;

  /// No description provided for @women1Step1P2.
  ///
  /// In en, this message translates to:
  /// **'Harassment includes unwanted advances, comments, or touching'**
  String get women1Step1P2;

  /// No description provided for @women1Step1P3.
  ///
  /// In en, this message translates to:
  /// **'Employer must ensure safe working environment'**
  String get women1Step1P3;

  /// No description provided for @women1Step1P4.
  ///
  /// In en, this message translates to:
  /// **'You can complain without fear of retaliation'**
  String get women1Step1P4;

  /// No description provided for @women1Step2Title.
  ///
  /// In en, this message translates to:
  /// **'Immediate Actions'**
  String get women1Step2Title;

  /// No description provided for @women1Step2Desc.
  ///
  /// In en, this message translates to:
  /// **'What to do when harassment occurs'**
  String get women1Step2Desc;

  /// No description provided for @women1Step2P1.
  ///
  /// In en, this message translates to:
  /// **'Say NO clearly and firmly'**
  String get women1Step2P1;

  /// No description provided for @women1Step2P2.
  ///
  /// In en, this message translates to:
  /// **'Document incidents with details'**
  String get women1Step2P2;

  /// No description provided for @women1Step2P3.
  ///
  /// In en, this message translates to:
  /// **'Inform harasser in writing'**
  String get women1Step2P3;

  /// No description provided for @women1Step2P4.
  ///
  /// In en, this message translates to:
  /// **'Report to HR or ICC'**
  String get women1Step2P4;

  /// No description provided for @women1Step2P5.
  ///
  /// In en, this message translates to:
  /// **'Keep copies of communication'**
  String get women1Step2P5;

  /// No description provided for @women1Step2P6.
  ///
  /// In en, this message translates to:
  /// **'Do not delay reporting'**
  String get women1Step2P6;

  /// No description provided for @women1Step3Title.
  ///
  /// In en, this message translates to:
  /// **'Complaint & Investigation'**
  String get women1Step3Title;

  /// No description provided for @women1Step3Desc.
  ///
  /// In en, this message translates to:
  /// **'Formal complaint process'**
  String get women1Step3Desc;

  /// No description provided for @women1Step3P1.
  ///
  /// In en, this message translates to:
  /// **'File complaint with ICC/HR'**
  String get women1Step3P1;

  /// No description provided for @women1Step3P2.
  ///
  /// In en, this message translates to:
  /// **'Provide written evidence'**
  String get women1Step3P2;

  /// No description provided for @women1Step3P3.
  ///
  /// In en, this message translates to:
  /// **'Investigation within 90 days'**
  String get women1Step3P3;

  /// No description provided for @women1Step3P4.
  ///
  /// In en, this message translates to:
  /// **'Protection against retaliation'**
  String get women1Step3P4;

  /// No description provided for @women1Step3P5.
  ///
  /// In en, this message translates to:
  /// **'Keep records of process'**
  String get women1Step3P5;

  /// No description provided for @women2Title.
  ///
  /// In en, this message translates to:
  /// **'Street Sexual Harassment'**
  String get women2Title;

  /// No description provided for @women2Desc.
  ///
  /// In en, this message translates to:
  /// **'You faced harassment in public'**
  String get women2Desc;

  /// No description provided for @women2Step1Title.
  ///
  /// In en, this message translates to:
  /// **'Understanding the Law'**
  String get women2Step1Title;

  /// No description provided for @women2Step1Desc.
  ///
  /// In en, this message translates to:
  /// **'Legal protections available'**
  String get women2Step1Desc;

  /// No description provided for @women2Step1P1.
  ///
  /// In en, this message translates to:
  /// **'Indecent assault is a crime'**
  String get women2Step1P1;

  /// No description provided for @women2Step1P2.
  ///
  /// In en, this message translates to:
  /// **'Stalking and eve-teasing are punishable'**
  String get women2Step1P2;

  /// No description provided for @women2Step1P3.
  ///
  /// In en, this message translates to:
  /// **'You can file FIR at any police station'**
  String get women2Step1P3;

  /// No description provided for @women2Step1P4.
  ///
  /// In en, this message translates to:
  /// **'Section 354 IPC applies'**
  String get women2Step1P4;

  /// No description provided for @women2Step2Title.
  ///
  /// In en, this message translates to:
  /// **'Safety First'**
  String get women2Step2Title;

  /// No description provided for @women2Step2Desc.
  ///
  /// In en, this message translates to:
  /// **'Immediate response'**
  String get women2Step2Desc;

  /// No description provided for @women2Step2P1.
  ///
  /// In en, this message translates to:
  /// **'Move to safe area'**
  String get women2Step2P1;

  /// No description provided for @women2Step2P2.
  ///
  /// In en, this message translates to:
  /// **'Call emergency number 100'**
  String get women2Step2P2;

  /// No description provided for @women2Step2P3.
  ///
  /// In en, this message translates to:
  /// **'Inform people nearby'**
  String get women2Step2P3;

  /// No description provided for @women2Step2P4.
  ///
  /// In en, this message translates to:
  /// **'Remember description of offender'**
  String get women2Step2P4;

  /// No description provided for @women2Step2P5.
  ///
  /// In en, this message translates to:
  /// **'Seek medical help if needed'**
  String get women2Step2P5;

  /// No description provided for @women2Step2P6.
  ///
  /// In en, this message translates to:
  /// **'Do not confront alone'**
  String get women2Step2P6;

  /// No description provided for @women2Step3Title.
  ///
  /// In en, this message translates to:
  /// **'Filing FIR'**
  String get women2Step3Title;

  /// No description provided for @women2Step3Desc.
  ///
  /// In en, this message translates to:
  /// **'Police complaint process'**
  String get women2Step3Desc;

  /// No description provided for @women2Step3P1.
  ///
  /// In en, this message translates to:
  /// **'Go to nearest police station'**
  String get women2Step3P1;

  /// No description provided for @women2Step3P2.
  ///
  /// In en, this message translates to:
  /// **'File FIR with details'**
  String get women2Step3P2;

  /// No description provided for @women2Step3P3.
  ///
  /// In en, this message translates to:
  /// **'Get FIR copy'**
  String get women2Step3P3;

  /// No description provided for @women2Step3P4.
  ///
  /// In en, this message translates to:
  /// **'Medical examination if needed'**
  String get women2Step3P4;

  /// No description provided for @women2Step3P5.
  ///
  /// In en, this message translates to:
  /// **'Follow up case'**
  String get women2Step3P5;

  /// No description provided for @women3Title.
  ///
  /// In en, this message translates to:
  /// **'Domestic Violence'**
  String get women3Title;

  /// No description provided for @women3Desc.
  ///
  /// In en, this message translates to:
  /// **'You are experiencing abuse at home'**
  String get women3Desc;

  /// No description provided for @women3Step1Title.
  ///
  /// In en, this message translates to:
  /// **'You Are Not Alone'**
  String get women3Step1Title;

  /// No description provided for @women3Step1Desc.
  ///
  /// In en, this message translates to:
  /// **'Support and legal rights'**
  String get women3Step1Desc;

  /// No description provided for @women3Step1P1.
  ///
  /// In en, this message translates to:
  /// **'Domestic violence is a crime'**
  String get women3Step1P1;

  /// No description provided for @women3Step1P2.
  ///
  /// In en, this message translates to:
  /// **'Protection of Women Act supports you'**
  String get women3Step1P2;

  /// No description provided for @women3Step1P3.
  ///
  /// In en, this message translates to:
  /// **'You can get protection order'**
  String get women3Step1P3;

  /// No description provided for @women3Step1P4.
  ///
  /// In en, this message translates to:
  /// **'Legal and shelter support available'**
  String get women3Step1P4;

  /// No description provided for @women3Step2Title.
  ///
  /// In en, this message translates to:
  /// **'Safety Planning'**
  String get women3Step2Title;

  /// No description provided for @women3Step2Desc.
  ///
  /// In en, this message translates to:
  /// **'Protect yourself'**
  String get women3Step2Desc;

  /// No description provided for @women3Step2P1.
  ///
  /// In en, this message translates to:
  /// **'Keep documents safe'**
  String get women3Step2P1;

  /// No description provided for @women3Step2P2.
  ///
  /// In en, this message translates to:
  /// **'Save emergency contacts'**
  String get women3Step2P2;

  /// No description provided for @women3Step2P3.
  ///
  /// In en, this message translates to:
  /// **'Document injuries'**
  String get women3Step2P3;

  /// No description provided for @women3Step2P4.
  ///
  /// In en, this message translates to:
  /// **'Record incidents'**
  String get women3Step2P4;

  /// No description provided for @women3Step2P5.
  ///
  /// In en, this message translates to:
  /// **'Know shelter locations'**
  String get women3Step2P5;

  /// No description provided for @women3Step2P6.
  ///
  /// In en, this message translates to:
  /// **'Do not blame yourself'**
  String get women3Step2P6;

  /// No description provided for @women3Step3Title.
  ///
  /// In en, this message translates to:
  /// **'Legal Options'**
  String get women3Step3Title;

  /// No description provided for @women3Step3Desc.
  ///
  /// In en, this message translates to:
  /// **'Legal actions available'**
  String get women3Step3Desc;

  /// No description provided for @women3Step3P1.
  ///
  /// In en, this message translates to:
  /// **'File FIR'**
  String get women3Step3P1;

  /// No description provided for @women3Step3P2.
  ///
  /// In en, this message translates to:
  /// **'Apply for protection order'**
  String get women3Step3P2;

  /// No description provided for @women3Step3P3.
  ///
  /// In en, this message translates to:
  /// **'Get medical documentation'**
  String get women3Step3P3;

  /// No description provided for @women3Step3P4.
  ///
  /// In en, this message translates to:
  /// **'Contact helpline'**
  String get women3Step3P4;

  /// No description provided for @women3Step3P5.
  ///
  /// In en, this message translates to:
  /// **'Free legal aid available'**
  String get women3Step3P5;

  /// No description provided for @cyberChatName.
  ///
  /// In en, this message translates to:
  /// **'Cyber Crime Assistant Chat'**
  String get cyberChatName;

  /// No description provided for @cyber1Title.
  ///
  /// In en, this message translates to:
  /// **'Online Financial Fraud'**
  String get cyber1Title;

  /// No description provided for @cyber1Desc.
  ///
  /// In en, this message translates to:
  /// **'You lost money due to online scam'**
  String get cyber1Desc;

  /// No description provided for @cyber1Step1Title.
  ///
  /// In en, this message translates to:
  /// **'Immediate Actions'**
  String get cyber1Step1Title;

  /// No description provided for @cyber1Step1Desc.
  ///
  /// In en, this message translates to:
  /// **'Act quickly'**
  String get cyber1Step1Desc;

  /// No description provided for @cyber1Step1P1.
  ///
  /// In en, this message translates to:
  /// **'Block accounts immediately'**
  String get cyber1Step1P1;

  /// No description provided for @cyber1Step1P2.
  ///
  /// In en, this message translates to:
  /// **'Change passwords'**
  String get cyber1Step1P2;

  /// No description provided for @cyber1Step1P3.
  ///
  /// In en, this message translates to:
  /// **'Contact bank'**
  String get cyber1Step1P3;

  /// No description provided for @cyber1Step1P4.
  ///
  /// In en, this message translates to:
  /// **'Check transactions'**
  String get cyber1Step1P4;

  /// No description provided for @cyber1Step1P5.
  ///
  /// In en, this message translates to:
  /// **'Enable fraud alert'**
  String get cyber1Step1P5;

  /// No description provided for @cyber1Step2Title.
  ///
  /// In en, this message translates to:
  /// **'Know the Crime'**
  String get cyber1Step2Title;

  /// No description provided for @cyber1Step2Desc.
  ///
  /// In en, this message translates to:
  /// **'Legal understanding'**
  String get cyber1Step2Desc;

  /// No description provided for @cyber1Step2P1.
  ///
  /// In en, this message translates to:
  /// **'Section 420 IPC applies'**
  String get cyber1Step2P1;

  /// No description provided for @cyber1Step2P2.
  ///
  /// In en, this message translates to:
  /// **'Identity theft is cyber crime'**
  String get cyber1Step2P2;

  /// No description provided for @cyber1Step2P3.
  ///
  /// In en, this message translates to:
  /// **'Phishing is punishable'**
  String get cyber1Step2P3;

  /// No description provided for @cyber1Step2P4.
  ///
  /// In en, this message translates to:
  /// **'File FIR cyber unit'**
  String get cyber1Step2P4;

  /// No description provided for @cyber1Step2P5.
  ///
  /// In en, this message translates to:
  /// **'Bank may assist'**
  String get cyber1Step2P5;

  /// No description provided for @cyber1Step3Title.
  ///
  /// In en, this message translates to:
  /// **'Recovery Steps'**
  String get cyber1Step3Title;

  /// No description provided for @cyber1Step3Desc.
  ///
  /// In en, this message translates to:
  /// **'Legal recovery'**
  String get cyber1Step3Desc;

  /// No description provided for @cyber1Step3P1.
  ///
  /// In en, this message translates to:
  /// **'File FIR'**
  String get cyber1Step3P1;

  /// No description provided for @cyber1Step3P2.
  ///
  /// In en, this message translates to:
  /// **'Provide evidence'**
  String get cyber1Step3P2;

  /// No description provided for @cyber1Step3P3.
  ///
  /// In en, this message translates to:
  /// **'Request bank reversal'**
  String get cyber1Step3P3;

  /// No description provided for @cyber1Step3P4.
  ///
  /// In en, this message translates to:
  /// **'Report to cyber cell'**
  String get cyber1Step3P4;

  /// No description provided for @cyber1Step3P5.
  ///
  /// In en, this message translates to:
  /// **'Consider legal action'**
  String get cyber1Step3P5;

  /// No description provided for @cyber2Title.
  ///
  /// In en, this message translates to:
  /// **'Revenge Porn / Image Abuse'**
  String get cyber2Title;

  /// No description provided for @cyber2Desc.
  ///
  /// In en, this message translates to:
  /// **'Private images shared without consent'**
  String get cyber2Desc;

  /// No description provided for @cyber2Step1Title.
  ///
  /// In en, this message translates to:
  /// **'Know Your Rights'**
  String get cyber2Step1Title;

  /// No description provided for @cyber2Step1Desc.
  ///
  /// In en, this message translates to:
  /// **'Legal protection'**
  String get cyber2Step1Desc;

  /// No description provided for @cyber2Step1P1.
  ///
  /// In en, this message translates to:
  /// **'Sharing images is crime'**
  String get cyber2Step1P1;

  /// No description provided for @cyber2Step1P2.
  ///
  /// In en, this message translates to:
  /// **'Section 67A IT Act'**
  String get cyber2Step1P2;

  /// No description provided for @cyber2Step1P3.
  ///
  /// In en, this message translates to:
  /// **'Section 354D IPC'**
  String get cyber2Step1P3;

  /// No description provided for @cyber2Step1P4.
  ///
  /// In en, this message translates to:
  /// **'POCSO applies if minor'**
  String get cyber2Step1P4;

  /// No description provided for @cyber2Step1P5.
  ///
  /// In en, this message translates to:
  /// **'POCSO Act applies if a minor is involved'**
  String get cyber2Step1P5;

  /// No description provided for @cyber2Step2Title.
  ///
  /// In en, this message translates to:
  /// **'Immediate Response'**
  String get cyber2Step2Title;

  /// No description provided for @cyber2Step2Desc.
  ///
  /// In en, this message translates to:
  /// **'Act fast'**
  String get cyber2Step2Desc;

  /// No description provided for @cyber2Step2P1.
  ///
  /// In en, this message translates to:
  /// **'Report platform'**
  String get cyber2Step2P1;

  /// No description provided for @cyber2Step2P2.
  ///
  /// In en, this message translates to:
  /// **'Use takedown option'**
  String get cyber2Step2P2;

  /// No description provided for @cyber2Step2P3.
  ///
  /// In en, this message translates to:
  /// **'Take screenshots'**
  String get cyber2Step2P3;

  /// No description provided for @cyber2Step2P4.
  ///
  /// In en, this message translates to:
  /// **'Save URLs'**
  String get cyber2Step2P4;

  /// No description provided for @cyber2Step2P5.
  ///
  /// In en, this message translates to:
  /// **'Inform trusted people'**
  String get cyber2Step2P5;

  /// No description provided for @cyber2Step2P6.
  ///
  /// In en, this message translates to:
  /// **'Do not engage attacker'**
  String get cyber2Step2P6;

  /// No description provided for @cyber2Step3Title.
  ///
  /// In en, this message translates to:
  /// **'Legal Action'**
  String get cyber2Step3Title;

  /// No description provided for @cyber2Step3Desc.
  ///
  /// In en, this message translates to:
  /// **'File complaint'**
  String get cyber2Step3Desc;

  /// No description provided for @cyber2Step3P1.
  ///
  /// In en, this message translates to:
  /// **'File FIR cyber police'**
  String get cyber2Step3P1;

  /// No description provided for @cyber2Step3P2.
  ///
  /// In en, this message translates to:
  /// **'Report platform'**
  String get cyber2Step3P2;

  /// No description provided for @cyber2Step3P3.
  ///
  /// In en, this message translates to:
  /// **'NCW complaint'**
  String get cyber2Step3P3;

  /// No description provided for @cyber2Step3P4.
  ///
  /// In en, this message translates to:
  /// **'Content removal request'**
  String get cyber2Step3P4;

  /// No description provided for @cyber2Step3P5.
  ///
  /// In en, this message translates to:
  /// **'Civil case option'**
  String get cyber2Step3P5;

  /// No description provided for @cyber3Title.
  ///
  /// In en, this message translates to:
  /// **'Account Hacking'**
  String get cyber3Title;

  /// No description provided for @cyber3Desc.
  ///
  /// In en, this message translates to:
  /// **'Your account was hacked'**
  String get cyber3Desc;

  /// No description provided for @cyber3Step1Title.
  ///
  /// In en, this message translates to:
  /// **'Secure Account'**
  String get cyber3Step1Title;

  /// No description provided for @cyber3Step1Desc.
  ///
  /// In en, this message translates to:
  /// **'Regain control'**
  String get cyber3Step1Desc;

  /// No description provided for @cyber3Step1P1.
  ///
  /// In en, this message translates to:
  /// **'Recover account'**
  String get cyber3Step1P1;

  /// No description provided for @cyber3Step1P2.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get cyber3Step1P2;

  /// No description provided for @cyber3Step1P3.
  ///
  /// In en, this message translates to:
  /// **'Enable 2FA'**
  String get cyber3Step1P3;

  /// No description provided for @cyber3Step1P4.
  ///
  /// In en, this message translates to:
  /// **'Check activity'**
  String get cyber3Step1P4;

  /// No description provided for @cyber3Step1P5.
  ///
  /// In en, this message translates to:
  /// **'Remove unknown apps'**
  String get cyber3Step1P5;

  /// No description provided for @cyber3Step2Title.
  ///
  /// In en, this message translates to:
  /// **'Damage Check'**
  String get cyber3Step2Title;

  /// No description provided for @cyber3Step2Desc.
  ///
  /// In en, this message translates to:
  /// **'Assess impact'**
  String get cyber3Step2Desc;

  /// No description provided for @cyber3Step2P1.
  ///
  /// In en, this message translates to:
  /// **'Check sent messages'**
  String get cyber3Step2P1;

  /// No description provided for @cyber3Step2P2.
  ///
  /// In en, this message translates to:
  /// **'Check transactions'**
  String get cyber3Step2P2;

  /// No description provided for @cyber3Step2P3.
  ///
  /// In en, this message translates to:
  /// **'Check changes'**
  String get cyber3Step2P3;

  /// No description provided for @cyber3Step2P4.
  ///
  /// In en, this message translates to:
  /// **'Monitor accounts'**
  String get cyber3Step2P4;

  /// No description provided for @cyber3Step2P5.
  ///
  /// In en, this message translates to:
  /// **'Inform contacts'**
  String get cyber3Step2P5;

  /// No description provided for @cyber3Step3Title.
  ///
  /// In en, this message translates to:
  /// **'Legal Action'**
  String get cyber3Step3Title;

  /// No description provided for @cyber3Step3Desc.
  ///
  /// In en, this message translates to:
  /// **'Report crime'**
  String get cyber3Step3Desc;

  /// No description provided for @cyber3Step3P1.
  ///
  /// In en, this message translates to:
  /// **'File FIR'**
  String get cyber3Step3P1;

  /// No description provided for @cyber3Step3P2.
  ///
  /// In en, this message translates to:
  /// **'Report platform'**
  String get cyber3Step3P2;

  /// No description provided for @cyber3Step3P3.
  ///
  /// In en, this message translates to:
  /// **'Save evidence'**
  String get cyber3Step3P3;

  /// No description provided for @cyber3Step3P4.
  ///
  /// In en, this message translates to:
  /// **'Check credit reports'**
  String get cyber3Step3P4;

  /// No description provided for @cyber3Step3P5.
  ///
  /// In en, this message translates to:
  /// **'Cyber expert help'**
  String get cyber3Step3P5;

  /// No description provided for @labourChatName.
  ///
  /// In en, this message translates to:
  /// **'Labour Rights Assistant Chat'**
  String get labourChatName;

  /// No description provided for @labour1Title.
  ///
  /// In en, this message translates to:
  /// **'Unfair Dismissal'**
  String get labour1Title;

  /// No description provided for @labour1Desc.
  ///
  /// In en, this message translates to:
  /// **'You were fired without proper notice or compensation'**
  String get labour1Desc;

  /// No description provided for @labour1Step1Title.
  ///
  /// In en, this message translates to:
  /// **'Understanding Your Rights'**
  String get labour1Step1Title;

  /// No description provided for @labour1Step1Desc.
  ///
  /// In en, this message translates to:
  /// **'Employer cannot fire you arbitrarily'**
  String get labour1Step1Desc;

  /// No description provided for @labour1Step1P1.
  ///
  /// In en, this message translates to:
  /// **'Industrial Disputes Act protects workers'**
  String get labour1Step1P1;

  /// No description provided for @labour1Step1P2.
  ///
  /// In en, this message translates to:
  /// **'Valid reason is required for termination'**
  String get labour1Step1P2;

  /// No description provided for @labour1Step1P3.
  ///
  /// In en, this message translates to:
  /// **'Written notice is mandatory'**
  String get labour1Step1P3;

  /// No description provided for @labour1Step1P4.
  ///
  /// In en, this message translates to:
  /// **'Wrongful termination is illegal'**
  String get labour1Step1P4;

  /// No description provided for @labour1Step1P5.
  ///
  /// In en, this message translates to:
  /// **'You can claim compensation or reinstatement'**
  String get labour1Step1P5;

  /// No description provided for @labour1Step2Title.
  ///
  /// In en, this message translates to:
  /// **'Immediate Documentation'**
  String get labour1Step2Title;

  /// No description provided for @labour1Step2Desc.
  ///
  /// In en, this message translates to:
  /// **'Collect evidence'**
  String get labour1Step2Desc;

  /// No description provided for @labour1Step2P1.
  ///
  /// In en, this message translates to:
  /// **'Keep termination letter'**
  String get labour1Step2P1;

  /// No description provided for @labour1Step2P2.
  ///
  /// In en, this message translates to:
  /// **'Record dismissal details'**
  String get labour1Step2P2;

  /// No description provided for @labour1Step2P3.
  ///
  /// In en, this message translates to:
  /// **'Collect salary slips'**
  String get labour1Step2P3;

  /// No description provided for @labour1Step2P4.
  ///
  /// In en, this message translates to:
  /// **'Save performance records'**
  String get labour1Step2P4;

  /// No description provided for @labour1Step2P5.
  ///
  /// In en, this message translates to:
  /// **'Gather witness statements'**
  String get labour1Step2P5;

  /// No description provided for @labour1Step2P6.
  ///
  /// In en, this message translates to:
  /// **'Keep company policies'**
  String get labour1Step2P6;

  /// No description provided for @labour1Step3Title.
  ///
  /// In en, this message translates to:
  /// **'Legal Steps'**
  String get labour1Step3Title;

  /// No description provided for @labour1Step3Desc.
  ///
  /// In en, this message translates to:
  /// **'How to seek remedy'**
  String get labour1Step3Desc;

  /// No description provided for @labour1Step3P1.
  ///
  /// In en, this message translates to:
  /// **'File complaint with Labour Department'**
  String get labour1Step3P1;

  /// No description provided for @labour1Step3P2.
  ///
  /// In en, this message translates to:
  /// **'Claim unpaid wages and severance'**
  String get labour1Step3P2;

  /// No description provided for @labour1Step3P3.
  ///
  /// In en, this message translates to:
  /// **'Seek reinstatement or compensation'**
  String get labour1Step3P3;

  /// No description provided for @labour1Step3P4.
  ///
  /// In en, this message translates to:
  /// **'File Labour Tribunal case'**
  String get labour1Step3P4;

  /// No description provided for @labour1Step3P5.
  ///
  /// In en, this message translates to:
  /// **'Free legal aid available'**
  String get labour1Step3P5;

  /// No description provided for @generalChatName.
  ///
  /// In en, this message translates to:
  /// **'Legal Advisor'**
  String get generalChatName;

  /// No description provided for @general1Title.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Concern'**
  String get general1Title;

  /// No description provided for @general1Desc.
  ///
  /// In en, this message translates to:
  /// **'Let AI guide your legal issue'**
  String get general1Desc;

  /// No description provided for @general1Step1Title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Legal Advisor'**
  String get general1Step1Title;

  /// No description provided for @general1Step1Desc.
  ///
  /// In en, this message translates to:
  /// **'Get legal help easily'**
  String get general1Step1Desc;

  /// No description provided for @general1Step1P1.
  ///
  /// In en, this message translates to:
  /// **'Describe your issue'**
  String get general1Step1P1;

  /// No description provided for @general1Step1P2.
  ///
  /// In en, this message translates to:
  /// **'AI will analyze your case'**
  String get general1Step1P2;

  /// No description provided for @general1Step1P3.
  ///
  /// In en, this message translates to:
  /// **'Get legal guidance'**
  String get general1Step1P3;

  /// No description provided for @general1Step1P4.
  ///
  /// In en, this message translates to:
  /// **'Based on laws'**
  String get general1Step1P4;

  /// No description provided for @general1Step1P5.
  ///
  /// In en, this message translates to:
  /// **'All inside app'**
  String get general1Step1P5;

  /// No description provided for @general1Step2Title.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get general1Step2Title;

  /// No description provided for @general1Step2Desc.
  ///
  /// In en, this message translates to:
  /// **'Select your issue type'**
  String get general1Step2Desc;

  /// No description provided for @general1Step2P1.
  ///
  /// In en, this message translates to:
  /// **'Traffic law issues'**
  String get general1Step2P1;

  /// No description provided for @general1Step2P2.
  ///
  /// In en, this message translates to:
  /// **'Women harassment cases'**
  String get general1Step2P2;

  /// No description provided for @general1Step2P3.
  ///
  /// In en, this message translates to:
  /// **'Cyber crimes'**
  String get general1Step2P3;

  /// No description provided for @general1Step2P4.
  ///
  /// In en, this message translates to:
  /// **'Labour rights'**
  String get general1Step2P4;

  /// No description provided for @general1Step3Title.
  ///
  /// In en, this message translates to:
  /// **'How to Use'**
  String get general1Step3Title;

  /// No description provided for @general1Step3Desc.
  ///
  /// In en, this message translates to:
  /// **'Simple steps'**
  String get general1Step3Desc;

  /// No description provided for @general1Step3P1.
  ///
  /// In en, this message translates to:
  /// **'Select category'**
  String get general1Step3P1;

  /// No description provided for @general1Step3P2.
  ///
  /// In en, this message translates to:
  /// **'Read guidance'**
  String get general1Step3P2;

  /// No description provided for @general1Step3P3.
  ///
  /// In en, this message translates to:
  /// **'Start AI chat'**
  String get general1Step3P3;

  /// No description provided for @general1Step3P4.
  ///
  /// In en, this message translates to:
  /// **'Get advice'**
  String get general1Step3P4;

  /// No description provided for @general1Step3P5.
  ///
  /// In en, this message translates to:
  /// **'Follow steps'**
  String get general1Step3P5;

  /// No description provided for @labour2Title.
  ///
  /// In en, this message translates to:
  /// **'Non-payment of Wages'**
  String get labour2Title;

  /// No description provided for @labour2Desc.
  ///
  /// In en, this message translates to:
  /// **'Your employer is not paying your salary'**
  String get labour2Desc;

  /// No description provided for @labour2Step1Title.
  ///
  /// In en, this message translates to:
  /// **'Know Your Entitlement'**
  String get labour2Step1Title;

  /// No description provided for @labour2Step1Desc.
  ///
  /// In en, this message translates to:
  /// **'Your legal wage rights'**
  String get labour2Step1Desc;

  /// No description provided for @labour2Step1P1.
  ///
  /// In en, this message translates to:
  /// **'Minimum wage must be paid by law'**
  String get labour2Step1P1;

  /// No description provided for @labour2Step1P2.
  ///
  /// In en, this message translates to:
  /// **'Wages must be paid on time'**
  String get labour2Step1P2;

  /// No description provided for @labour2Step1P3.
  ///
  /// In en, this message translates to:
  /// **'Illegal deductions are not allowed'**
  String get labour2Step1P3;

  /// No description provided for @labour2Step1P4.
  ///
  /// In en, this message translates to:
  /// **'Only lawful deductions are valid'**
  String get labour2Step1P4;

  /// No description provided for @labour2Step1P5.
  ///
  /// In en, this message translates to:
  /// **'You can recover unpaid wages with penalty'**
  String get labour2Step1P5;

  /// No description provided for @labour2Step2Title.
  ///
  /// In en, this message translates to:
  /// **'Immediate Steps'**
  String get labour2Step2Title;

  /// No description provided for @labour2Step2Desc.
  ///
  /// In en, this message translates to:
  /// **'Act quickly'**
  String get labour2Step2Desc;

  /// No description provided for @labour2Step2P1.
  ///
  /// In en, this message translates to:
  /// **'Send written demand for salary'**
  String get labour2Step2P1;

  /// No description provided for @labour2Step2P2.
  ///
  /// In en, this message translates to:
  /// **'Keep all communication records'**
  String get labour2Step2P2;

  /// No description provided for @labour2Step2P3.
  ///
  /// In en, this message translates to:
  /// **'Record working hours'**
  String get labour2Step2P3;

  /// No description provided for @labour2Step2P4.
  ///
  /// In en, this message translates to:
  /// **'Calculate pending amount'**
  String get labour2Step2P4;

  /// No description provided for @labour2Step2P5.
  ///
  /// In en, this message translates to:
  /// **'Keep bank statements'**
  String get labour2Step2P5;

  /// No description provided for @labour2Step2P6.
  ///
  /// In en, this message translates to:
  /// **'Do not rely on verbal promises'**
  String get labour2Step2P6;

  /// No description provided for @labour2Step3Title.
  ///
  /// In en, this message translates to:
  /// **'Filing Complaint'**
  String get labour2Step3Title;

  /// No description provided for @labour2Step3Desc.
  ///
  /// In en, this message translates to:
  /// **'Legal action process'**
  String get labour2Step3Desc;

  /// No description provided for @labour2Step3P1.
  ///
  /// In en, this message translates to:
  /// **'File complaint with Labour Department'**
  String get labour2Step3P1;

  /// No description provided for @labour2Step3P2.
  ///
  /// In en, this message translates to:
  /// **'File recovery case in Labour Court'**
  String get labour2Step3P2;

  /// No description provided for @labour2Step3P3.
  ///
  /// In en, this message translates to:
  /// **'Claim unpaid salary + damages'**
  String get labour2Step3P3;

  /// No description provided for @labour2Step3P4.
  ///
  /// In en, this message translates to:
  /// **'Case is free under law'**
  String get labour2Step3P4;

  /// No description provided for @labour2Step3P5.
  ///
  /// In en, this message translates to:
  /// **'Employer must respond legally'**
  String get labour2Step3P5;

  /// No description provided for @labour3Title.
  ///
  /// In en, this message translates to:
  /// **'Workplace Injury / Accident'**
  String get labour3Title;

  /// No description provided for @labour3Desc.
  ///
  /// In en, this message translates to:
  /// **'You were injured at work'**
  String get labour3Desc;

  /// No description provided for @labour3Step1Title.
  ///
  /// In en, this message translates to:
  /// **'Your Rights After Injury'**
  String get labour3Step1Title;

  /// No description provided for @labour3Step1Desc.
  ///
  /// In en, this message translates to:
  /// **'Legal protection and compensation'**
  String get labour3Step1Desc;

  /// No description provided for @labour3Step1P1.
  ///
  /// In en, this message translates to:
  /// **'Employer is liable for workplace injury'**
  String get labour3Step1P1;

  /// No description provided for @labour3Step1P2.
  ///
  /// In en, this message translates to:
  /// **'Medical expenses must be covered'**
  String get labour3Step1P2;

  /// No description provided for @labour3Step1P3.
  ///
  /// In en, this message translates to:
  /// **'You can claim disability compensation'**
  String get labour3Step1P3;

  /// No description provided for @labour3Step1P4.
  ///
  /// In en, this message translates to:
  /// **'You can claim lost wages'**
  String get labour3Step1P4;

  /// No description provided for @labour3Step1P5.
  ///
  /// In en, this message translates to:
  /// **'Family gets compensation in fatal cases'**
  String get labour3Step1P5;

  /// No description provided for @labour3Step2Title.
  ///
  /// In en, this message translates to:
  /// **'Immediate Actions'**
  String get labour3Step2Title;

  /// No description provided for @labour3Step2Desc.
  ///
  /// In en, this message translates to:
  /// **'What to do after accident'**
  String get labour3Step2Desc;

  /// No description provided for @labour3Step2P1.
  ///
  /// In en, this message translates to:
  /// **'Report injury immediately'**
  String get labour3Step2P1;

  /// No description provided for @labour3Step2P2.
  ///
  /// In en, this message translates to:
  /// **'Get written acknowledgment'**
  String get labour3Step2P2;

  /// No description provided for @labour3Step2P3.
  ///
  /// In en, this message translates to:
  /// **'Seek medical treatment'**
  String get labour3Step2P3;

  /// No description provided for @labour3Step2P4.
  ///
  /// In en, this message translates to:
  /// **'Take photos of accident'**
  String get labour3Step2P4;

  /// No description provided for @labour3Step2P5.
  ///
  /// In en, this message translates to:
  /// **'Collect witness statements'**
  String get labour3Step2P5;

  /// No description provided for @labour3Step2P6.
  ///
  /// In en, this message translates to:
  /// **'Do not sign settlement without advice'**
  String get labour3Step2P6;

  /// No description provided for @labour3Step3Title.
  ///
  /// In en, this message translates to:
  /// **'Compensation Claim'**
  String get labour3Step3Title;

  /// No description provided for @labour3Step3Desc.
  ///
  /// In en, this message translates to:
  /// **'How to get compensation'**
  String get labour3Step3Desc;

  /// No description provided for @labour3Step3P1.
  ///
  /// In en, this message translates to:
  /// **'File claim with Compensation Commissioner'**
  String get labour3Step3P1;

  /// No description provided for @labour3Step3P2.
  ///
  /// In en, this message translates to:
  /// **'Attach medical reports'**
  String get labour3Step3P2;

  /// No description provided for @labour3Step3P3.
  ///
  /// In en, this message translates to:
  /// **'Claim recovery wages'**
  String get labour3Step3P3;

  /// No description provided for @labour3Step3P4.
  ///
  /// In en, this message translates to:
  /// **'Claim disability benefits'**
  String get labour3Step3P4;

  /// No description provided for @labour3Step3P5.
  ///
  /// In en, this message translates to:
  /// **'Employer must provide insurance proof'**
  String get labour3Step3P5;

  /// No description provided for @myDocuments.
  ///
  /// In en, this message translates to:
  /// **'My Documents'**
  String get myDocuments;

  /// No description provided for @signInToViewDocs.
  ///
  /// In en, this message translates to:
  /// **'Sign in to view and manage your documents'**
  String get signInToViewDocs;

  /// No description provided for @signInToDownloadDocs.
  ///
  /// In en, this message translates to:
  /// **'Sign in to download documents'**
  String get signInToDownloadDocs;

  /// No description provided for @signInToManageDocs.
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage documents'**
  String get signInToManageDocs;

  /// No description provided for @noDocumentsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No documents available'**
  String get noDocumentsAvailable;

  /// No description provided for @noDocumentsYet.
  ///
  /// In en, this message translates to:
  /// **'No documents yet'**
  String get noDocumentsYet;

  /// No description provided for @documentsEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Documents you generate or download will appear here'**
  String get documentsEmptyHint;

  /// No description provided for @noDocumentsOfType.
  ///
  /// In en, this message translates to:
  /// **'No documents of this type'**
  String get noDocumentsOfType;

  /// No description provided for @deleteDocument.
  ///
  /// In en, this message translates to:
  /// **'Delete Document'**
  String get deleteDocument;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @couldNotOpenDocument.
  ///
  /// In en, this message translates to:
  /// **'Could not open document'**
  String get couldNotOpenDocument;

  /// No description provided for @documentDeleted.
  ///
  /// In en, this message translates to:
  /// **'Document deleted successfully'**
  String get documentDeleted;

  /// No description provided for @storageUsage.
  ///
  /// In en, this message translates to:
  /// **'Storage Usage'**
  String get storageUsage;

  /// No description provided for @complaints.
  ///
  /// In en, this message translates to:
  /// **'Complaints'**
  String get complaints;

  /// No description provided for @generatedPdfs.
  ///
  /// In en, this message translates to:
  /// **'Generated PDFs'**
  String get generatedPdfs;

  /// No description provided for @uploaded.
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get uploaded;

  /// No description provided for @allDocuments.
  ///
  /// In en, this message translates to:
  /// **'All ({count})'**
  String allDocuments(Object count);

  /// No description provided for @openingDocument.
  ///
  /// In en, this message translates to:
  /// **'Opening: {title}'**
  String openingDocument(Object title);

  /// Confirm delete dialog message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"?'**
  String deleteConfirm(Object title);

  /// No description provided for @howToReportIssue.
  ///
  /// In en, this message translates to:
  /// **'How to report an issue'**
  String get howToReportIssue;

  /// No description provided for @reportIssueSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get help with technical problems'**
  String get reportIssueSubtitle;

  /// No description provided for @helpReportContent.
  ///
  /// In en, this message translates to:
  /// **'For technical support, contact us through in-app support or website.'**
  String get helpReportContent;

  /// No description provided for @faqTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get faqTitle;

  /// No description provided for @faqFreeUse.
  ///
  /// In en, this message translates to:
  /// **'Is Legal Sathi free to use?'**
  String get faqFreeUse;

  /// No description provided for @faqFreeUseAnswer.
  ///
  /// In en, this message translates to:
  /// **'Yes, Legal Sathi is free for all users.'**
  String get faqFreeUseAnswer;

  /// No description provided for @faqLawyerUse.
  ///
  /// In en, this message translates to:
  /// **'Can I use this instead of a lawyer?'**
  String get faqLawyerUse;

  /// No description provided for @faqLawyerUseAnswer.
  ///
  /// In en, this message translates to:
  /// **'No, it provides guidance only.'**
  String get faqLawyerUseAnswer;

  /// No description provided for @faqAiAccuracy.
  ///
  /// In en, this message translates to:
  /// **'How accurate is the AI assistant?'**
  String get faqAiAccuracy;

  /// No description provided for @faqAiAccuracyAnswer.
  ///
  /// In en, this message translates to:
  /// **'AI is trained on Pakistani laws but may not be 100% accurate.'**
  String get faqAiAccuracyAnswer;

  /// No description provided for @faqDataSecurity.
  ///
  /// In en, this message translates to:
  /// **'Is my data secure?'**
  String get faqDataSecurity;

  /// No description provided for @faqDataSecurityAnswer.
  ///
  /// In en, this message translates to:
  /// **'Yes, your data is encrypted and secure.'**
  String get faqDataSecurityAnswer;

  /// No description provided for @stepByStepUpload.
  ///
  /// In en, this message translates to:
  /// **'Step by step guide'**
  String get stepByStepUpload;

  /// No description provided for @howOcrWorks.
  ///
  /// In en, this message translates to:
  /// **'How OCR works'**
  String get howOcrWorks;

  /// No description provided for @ocrSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Document scanning and analysis'**
  String get ocrSubtitle;

  /// No description provided for @howToDraftDocuments.
  ///
  /// In en, this message translates to:
  /// **'How to draft documents'**
  String get howToDraftDocuments;

  /// No description provided for @draftSubtitle.
  ///
  /// In en, this message translates to:
  /// **'FIRs, complaints and legal documents'**
  String get draftSubtitle;

  /// No description provided for @helpUseAppContent.
  ///
  /// In en, this message translates to:
  /// **'Use bottom navigation to move between screens.'**
  String get helpUseAppContent;

  /// No description provided for @helpUploadContent.
  ///
  /// In en, this message translates to:
  /// **'Go to documents and upload files.'**
  String get helpUploadContent;

  /// No description provided for @helpOcrContent.
  ///
  /// In en, this message translates to:
  /// **'OCR extracts text from images and PDFs.'**
  String get helpOcrContent;

  /// No description provided for @helpDraftContent.
  ///
  /// In en, this message translates to:
  /// **'Use draft tools to create legal documents.'**
  String get helpDraftContent;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @faqLanguages.
  ///
  /// In en, this message translates to:
  /// **'What languages are supported?'**
  String get faqLanguages;

  /// No description provided for @faqLanguagesAnswer.
  ///
  /// In en, this message translates to:
  /// **'English, Urdu, and Roman Urdu are supported.'**
  String get faqLanguagesAnswer;

  /// No description provided for @stillNeedHelp.
  ///
  /// In en, this message translates to:
  /// **'Still Need Help?'**
  String get stillNeedHelp;

  /// No description provided for @contactSupportText.
  ///
  /// In en, this message translates to:
  /// **'Contact our support team for assistance'**
  String get contactSupportText;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @urduLine1.
  ///
  /// In en, this message translates to:
  /// **'Your Legal'**
  String get urduLine1;

  /// No description provided for @urduLine2.
  ///
  /// In en, this message translates to:
  /// **'Companion'**
  String get urduLine2;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Legal Sathi is an AI-powered legal assistant designed to help Pakistani citizens understand their legal rights and navigate the legal system. We provide information on criminal law, civil law, labour rights, cyber crime, and more.\n\nOur mission is to make legal information accessible to everyone, regardless of their background or resources. We help users draft legal documents, understand laws, and take informed action.'**
  String get aboutDescription;

  /// No description provided for @versionInfo.
  ///
  /// In en, this message translates to:
  /// **'Version Information'**
  String get versionInfo;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @build.
  ///
  /// In en, this message translates to:
  /// **'Build'**
  String get build;

  /// No description provided for @platform.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get platform;

  /// No description provided for @mobileApp.
  ///
  /// In en, this message translates to:
  /// **'Mobile App'**
  String get mobileApp;

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// No description provided for @developedWith.
  ///
  /// In en, this message translates to:
  /// **'Developed with '**
  String get developedWith;

  /// No description provided for @forPakistan.
  ///
  /// In en, this message translates to:
  /// **' for the people of Pakistan'**
  String get forPakistan;

  /// No description provided for @legalDisclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Legal Disclaimer'**
  String get legalDisclaimerTitle;

  /// No description provided for @legalDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Legal Sathi provides general legal information only. This is not legal advice and should not replace consultation with a qualified lawyer.'**
  String get legalDisclaimer;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'© 2026 Legal Sathi. All rights reserved.'**
  String get copyright;
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
