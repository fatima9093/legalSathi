import 'package:flutter/material.dart';
import 'package:front_end/traffic_module/road_traffic_law_screen.dart';
import 'package:front_end/women_harrasment_module/women_harrasment_law_screen.dart';
import 'package:front_end/cyber_law_module/cybercrime_peca_screen.dart';
import 'package:front_end/labour_rights_module/labour_rights_screen.dart';
import 'package:front_end/services/auth_service.dart';
import 'package:front_end/services/recent_activity_service.dart';
import 'package:front_end/models/recent_activity_model.dart';
import 'package:front_end/notifications_screen.dart';
import 'package:front_end/profile_screen.dart';
import 'package:front_end/chat_screen.dart';
import 'package:front_end/screens/dynamic_documents_screen.dart';
import 'package:front_end/scenario_simulator_screen.dart';
import 'package:front_end/models/scenario_model.dart';
import 'package:front_end/traffic_module/traffic_challan_ocr_screen.dart';
import 'package:front_end/cyber_law_module/draft_document_type_screen.dart';
import 'package:front_end/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();
  final RecentActivityService _activityService = RecentActivityService();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 500;
    final isMobile = screenWidth < 600;
    final loc = AppLocalizations.of(context)!;

    // Responsive font sizes
    final titleFontSize = isSmallScreen ? 24.0 : 28.0;
    final welcomeFontSize = isSmallScreen ? 12.0 : 14.0;
    final categoryTitleSize = isSmallScreen ? 11.0 : 13.0;
    final categorySubtitleSize = isSmallScreen ? 9.0 : 10.0;
    final quickActionLabelSize = isSmallScreen ? 9.0 : 10.0;

    // Responsive spacing
    final horizontalPadding = isSmallScreen ? 12.0 : 16.0;
    final verticalSpacing = isSmallScreen ? 12.0 : 16.0;
    final cardPadding = isSmallScreen ? 10.0 : 12.0;

    return StreamBuilder<AppUser?>(
      stream: _authService.authStateChanges,
      initialData: _authService.currentUser,
      builder: (context, snapshot) {
        final user = snapshot.data;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: SizedBox.shrink(),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.notifications_none,
                  color: Colors.black,
                  size: isSmallScreen ? 22 : 24,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.person_outline,
                  color: Colors.black,
                  size: isSmallScreen ? 22 : 24,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: isSmallScreen ? 6 : 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.appName,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user != null
                            ? '${loc.welcome}, ${user.displayName ?? user.email?.split('@').first ?? loc.user}'
                            : loc.welcome,
                        style: TextStyle(
                          fontSize: welcomeFontSize,
                          color: Colors.grey[600],
                          height: 1.3,
                        ),
                      ),
                      if (user != null)
                        TextButton(
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(
                                  AppLocalizations.of(context)!.logout,
                                ),
                                content: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.areYouSureYouWantToLogout,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: Text(
                                      AppLocalizations.of(context)!.cancel,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)!.logout,
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true && context.mounted) {
                              await _authService.signOut();
                              if (context.mounted) {
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/onboarding',
                                );
                              }
                            }
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 0,
                              vertical: 4,
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.logout,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 11 : 12,
                              color: Colors.red,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: verticalSpacing),

                // Guest Message
                if (user == null)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF00401A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.welcomeAsGuest,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 6 : 8),
                          Text(
                           loc.guestDescription,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 13,
                              color: Colors.white.withValues(alpha: 0.9),
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 8 : 12),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                context,
                                '/onboarding',
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF00401A),
                              minimumSize: Size(
                                double.infinity,
                                isSmallScreen ? 36 : 40,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                             loc.signUpNow,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isSmallScreen ? 12 : 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                SizedBox(height: verticalSpacing),

                // Search Bar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChatScreen(),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        enabled: false,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(
                            context,
                          )!.askALegalQuestion,
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: isSmallScreen ? 12 : 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey[400],
                            size: isSmallScreen ? 20 : 24,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: isSmallScreen ? 10 : 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: verticalSpacing),

                // Legal Categories
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Text(
                    AppLocalizations.of(context)!.legalCategoies,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: isSmallScreen ? 10 : 12),

                // Category Cards Grid
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: GridView.count(
                    crossAxisCount: isSmallScreen ? 1 : 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: isSmallScreen ? 12 : 16,
                    crossAxisSpacing: isSmallScreen ? 12 : 16,
                    childAspectRatio: isSmallScreen ? 2.2 : 1.8,
                    children: [
                      _buildCategoryButton(
                        title: 'Women\nHarrassment',
                        subtitle: 'Protection laws and\ncomplaint',
                        urduText: 'خواتین کی جنسی و زبانی زیادتی',
                        icon: Icons.shield,
                        isSmall: isSmallScreen,
                        categoryTitleSize: categoryTitleSize,
                        categorySubtitleSize: categorySubtitleSize,
                        cardPadding: cardPadding,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const WomenHarassmentLawsScreen(),
                            ),
                          );
                        },
                      ),
                      _buildCategoryButton(
                        title: 'Road & Traffic\nLaw',
                        subtitle: 'Traffic violations\nand fines',
                        urduText: 'ٹریفک قوانین',
                        icon: Icons.directions_car,
                        isSmall: isSmallScreen,
                        categoryTitleSize: categoryTitleSize,
                        categorySubtitleSize: categorySubtitleSize,
                        cardPadding: cardPadding,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const RoadTrafficLawScreen(),
                            ),
                          );
                        },
                      ),
                      _buildCategoryButton(
                        title: 'Labour Rights',
                        subtitle: 'Employment rights\nand wages',
                        urduText: 'مزدوری حقوق',
                        icon: Icons.business_center,
                        isSmall: isSmallScreen,
                        categoryTitleSize: categoryTitleSize,
                        categorySubtitleSize: categorySubtitleSize,
                        cardPadding: cardPadding,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LabourRightsScreen(),
                            ),
                          );
                        },
                      ),
                      _buildCategoryButton(
                        title: 'Cyber Crime\n(PECA)',
                        subtitle: 'Online harassment\nand digital crimes',
                        urduText: 'سائبر جرائم',
                        icon: Icons.security,
                        isSmall: isSmallScreen,
                        categoryTitleSize: categoryTitleSize,
                        categorySubtitleSize: categorySubtitleSize,
                        cardPadding: cardPadding,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CyberCrimePECAScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: verticalSpacing),

                // Quick Actions
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: GridView.count(
                    crossAxisCount: isSmallScreen ? 2 : 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: isSmallScreen ? 10 : 12,
                    crossAxisSpacing: isSmallScreen ? 10 : 12,
                    childAspectRatio: 1.0,
                    children: [
                      _buildQuickAction(
                        AppLocalizations.of(context)!.askAi,
                        Icons.chat_bubble_outline,
                        isSmall: isSmallScreen,
                        fontSize: quickActionLabelSize,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChatScreen(),
                            ),
                          );
                        },
                      ),
                      _buildQuickAction(
                        AppLocalizations.of(context)!.uploadEvidence,
                        Icons.camera_alt_outlined,
                        isSmall: isSmallScreen,
                        fontSize: quickActionLabelSize,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const TrafficChallanOCRScreen(),
                            ),
                          );
                        },
                      ),
                      _buildQuickAction(
                        AppLocalizations.of(context)!.draftDocument,
                        Icons.local_offer_outlined,
                        isSmall: isSmallScreen,
                        fontSize: quickActionLabelSize,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const DraftDocumentTypeScreen(
                                    extractedText: '',
                                    classifiedDomain: '',
                                    tags: [],
                                  ),
                            ),
                          );
                        },
                      ),
                      _buildQuickAction(
                        AppLocalizations.of(context)!.simulate,
                        Icons.play_circle_outline,
                        isSmall: isSmallScreen,
                        fontSize: quickActionLabelSize,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ScenarioSimulatorScreen(
                                    moduleType: ModuleType.general,
                                  ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: verticalSpacing),

                // Recent Activity
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Text(
                    AppLocalizations.of(context)!.recentActivity,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: isSmallScreen ? 10 : 12),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: FutureBuilder(
                    future: _activityService.getRecentActivities(limit: 3),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: const Center(
                            child: SizedBox(
                              height: 40,
                              width: 40,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }

                      final activities = snapshot.data ?? [];

                      if (activities.isEmpty) {
                        // Show placeholder when no activities
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.history,
                                size: isSmallScreen ? 32 : 40,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: isSmallScreen ? 8 : 12),
                              Text(
                                loc.noRecentActivity,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: isSmallScreen ? 12 : 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                loc.activitiesWillAppear,
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: isSmallScreen ? 11 : 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // Display activities as a list
                      return Column(
                        children: List.generate(activities.length, (index) {
                          final activity = activities[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index < activities.length - 1
                                  ? (isSmallScreen ? 10 : 12)
                                  : 0,
                            ),
                            child: _buildActivityCard(activity, isSmallScreen),
                          );
                        }),
                      );
                    },
                  ),
                ),
                SizedBox(height: verticalSpacing),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatScreen()),
              );
            },
            backgroundColor: const Color(0xFF00401A),
            child: const Icon(Icons.mic, color: Colors.white, size: 28),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
              if (index == 1) {
                // Navigate to Chat screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatScreen()),
                );
              } else if (index == 2) {
                // Navigate to Documents screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DynamicDocumentsScreen(),
                  ),
                );
              } else if (index == 3) {
                // Navigate to Profile screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              }
            },
            items: [
              BottomNavigationBarItem(icon: const Icon(Icons.home), label: loc.home),
              BottomNavigationBarItem(
                icon: const Icon(Icons.chat_bubble_outline),
                label: loc.chat,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.folder_outlined),
                label: loc.documents,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline),
                label: loc.profile,
              ),
            ],
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF00401A),
            unselectedItemColor: Colors.grey,
          ),
        );
      },
    );
  }

  Widget _buildCategoryButton({
    required String title,
    required String subtitle,
    required String urduText,
    required IconData icon,
    required VoidCallback onTap,
    required bool isSmall,
    required double categoryTitleSize,
    required double categorySubtitleSize,
    required double cardPadding,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(cardPadding),
        child: isSmall
            ? Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00401A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title.replaceAll('\n', ' '),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: categoryTitleSize,
                            color: Colors.black,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          urduText,
                          style: TextStyle(
                            fontSize: categorySubtitleSize - 1,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00401A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: categoryTitleSize,
                        color: Colors.black,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: Text(
                      urduText,
                      style: TextStyle(
                        fontSize: categorySubtitleSize,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Flexible(
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: categorySubtitleSize,
                        color: Colors.grey[600],
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildQuickAction(
    String label,
    IconData icon, {
    VoidCallback? onTap,
    required bool isSmall,
    required double fontSize,
  }) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF00401A), size: isSmall ? 24 : 28),
            SizedBox(height: isSmall ? 6 : 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build a single recent activity card
  Widget _buildActivityCard(RecentActivityModel activity, bool isSmallScreen) {
    // Determine the icon based on activity type
    IconData iconData;
    Color iconBgColor = const Color(0xFF00401A).withValues(alpha: 0.1);
    Color iconColor = const Color(0xFF00401A);

    switch (activity.type) {
      case 'draft_complaint':
        iconData = Icons.description_outlined;
        iconBgColor = Colors.blue.withValues(alpha: 0.1);
        iconColor = Colors.blue;
        break;
      case 'document_upload':
        iconData = Icons.upload_file_outlined;
        iconBgColor = Colors.green.withValues(alpha: 0.1);
        iconColor = Colors.green;
        break;
      case 'complaint_filed':
        iconData = Icons.check_circle_outline;
        iconBgColor = Colors.purple.withValues(alpha: 0.1);
        iconColor = Colors.purple;
        break;
      case 'chat_query':
        iconData = Icons.chat_bubble_outline;
        iconBgColor = Colors.orange.withValues(alpha: 0.1);
        iconColor = Colors.orange;
        break;
      default:
        iconData = Icons.history;
        iconBgColor = Colors.grey.withValues(alpha: 0.1);
        iconColor = Colors.grey;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      child: Row(
        children: [
          Container(
            width: isSmallScreen ? 36 : 40,
            height: isSmallScreen ? 36 : 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              iconData,
              color: iconColor,
              size: isSmallScreen ? 18 : 20,
            ),
          ),
          SizedBox(width: isSmallScreen ? 10 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isSmallScreen ? 2 : 4),
                Text(
                  _formatTimestamp(activity.timestamp),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: isSmallScreen ? 11 : 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Format timestamp to human-readable format
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return AppLocalizations.of(context)!.justNow;
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
