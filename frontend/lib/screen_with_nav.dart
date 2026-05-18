import 'package:flutter/material.dart';
import 'labour_rights_module/minimum_wage_checker_screen.dart';
import 'labour_rights_module/labour_rights_screen.dart';
import 'cyber_law_module/blackmail_handling_screen.dart';
import 'cyber_law_module/cybercrime_peca_screen.dart';
import 'cyber_law_module/fia_complaint_generator.dart';
import 'cyber_law_module/generated_complaint_screen.dart';
import 'cyber_law_module/online_harrasment_screen.dart';
// Import all your other screens...

// Bottom Navigation Bar Builder
BottomNavigationBar buildBottomNavBar(BuildContext context, int selectedIndex) {
  // Determine if we should visually highlight a selected tab.
  // Only highlight when the current route corresponds to one of the main tabs.
  final routeName = ModalRoute.of(context)?.settings.name;
  final mainRouteToIndex = {
    '/home': 0,
    '/home_screen': 0,
    '/chat': 1,
    '/documents': 2,
    '/profile': 3,
  };

  // Only highlight when we're at a top-level route (not a pushed module).
  final bool isTopLevel = !Navigator.of(context).canPop();
  final bool shouldHighlight =
      isTopLevel &&
      routeName != null &&
      mainRouteToIndex.containsKey(routeName);
  final int currentIndex = shouldHighlight
      ? (mainRouteToIndex[routeName] as int)
      : 0;

  return BottomNavigationBar(
    currentIndex: currentIndex,
    onTap: (index) {
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/home_screen');
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/chat');
          break;
        case 2:
          Navigator.pushReplacementNamed(context, '/documents');
          break;
        case 3:
          Navigator.pushReplacementNamed(context, '/profile');
          break;
      }
    },
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(
        icon: Icon(Icons.chat_bubble_outline),
        label: 'Chat',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.folder_outlined),
        label: 'Documents',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        label: 'Profile',
      ),
    ],
    type: BottomNavigationBarType.fixed,
    // If we're on a module/category screen (no main route name), don't visually highlight
    // any tab — make selected color same as unselected to avoid misleading active state.
    selectedItemColor: shouldHighlight ? const Color(0xFF00401A) : Colors.grey,
    unselectedItemColor: Colors.grey,
  );
}

class ScreensWithNav extends StatefulWidget {
  final String initialScreen; // To know which screen to show first

  const ScreensWithNav({super.key, required this.initialScreen});

  @override
  State<ScreensWithNav> createState() => _ScreensWithNavState();
}

class _ScreensWithNavState extends State<ScreensWithNav> {
  int _selectedIndex = 0;
  String _currentScreen = '';

  @override
  void initState() {
    super.initState();
    _currentScreen = widget.initialScreen;
  }

  // Map of all screens that should have the bottom nav
  Widget _getCurrentScreen() {
    switch (_currentScreen) {
      case 'minimum_wage_checker':
        return const MinimumWageCheckerScreen();
      case 'labour_rights':
        return const LabourRightsScreen();
      case 'blackmail_handling_screen':
        return const BlackmailHandlingScreen();
      case 'cybercrime_peca_screen':
        return const CyberCrimePECAScreen();
      case 'fia_complaint_generator':
        return const FIAComplaintGeneratorScreen();
      case 'generated_complaint_screen':
        return const GeneratedComplaintScreen();
      case 'onlineHarrasment_screen':
        return const OnlineHarassmentPECA24Screen();
      case 'safety_guidance_result_screen':
        // This route should not be used directly - navigate via blackmail_handling_screen
        return const Scaffold(
          body: Center(child: Text('Please use Blackmail Handling Flow')),
        );

      // Add all your 15+ screens here
      default:
        return const MinimumWageCheckerScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getCurrentScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            // Navigate to different main sections
            switch (index) {
              case 0:
                Navigator.pushReplacementNamed(context, '/home_screen');
                break;
              case 1:
                Navigator.pushReplacementNamed(context, '/chat');
                break;
              case 2:
                Navigator.pushReplacementNamed(context, '/documents');
                break;
              case 3:
                Navigator.pushReplacementNamed(context, '/profile');
                break;
            }
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_outlined),
            label: 'Documents',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF00401A),
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
