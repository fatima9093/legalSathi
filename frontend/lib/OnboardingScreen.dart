import 'package:flutter/material.dart';
import 'package:front_end/l10n/app_localizations.dart';
import '../LanguageSelectionScreen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Define all onboarding data
  List<OnboardingData> _pages = []; // ← removed "late final", empty list initially

@override
void didChangeDependencies() {
  super.didChangeDependencies();
  // Safe to use context here
  _pages = [
    OnboardingData(
      icon: Icons.balance,
      isIconData: true,
      title: AppLocalizations.of(context)!.knowYourRights,
      description: AppLocalizations.of(context)!.knowYourRightsDesc,
    ),
    OnboardingData(
      imagePath: 'assets/legal_image.png',
      isIconData: false,
      title: AppLocalizations.of(context)!.aiLegalAssistantTitle,
      description: AppLocalizations.of(context)!.aiLegalAssistantDesc,
    ),
    OnboardingData(
      imagePath: 'assets/draft_image.png',
      isIconData: false,
      title: AppLocalizations.of(context)!.draftDocumentsTitle,
      description: AppLocalizations.of(context)!.draftDocumentsDesc,
    ),
  ];
}

  void _navigateToLanguageSelection() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LanguageSelectionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.only(right: 24, top: 24),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _navigateToLanguageSelection,
                  child: Text(
                    AppLocalizations.of(context)!.skip,
                    style: const TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Page indicators
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => _dot(isActive: index == _currentPage),
                ),
              ),
            ),

            // Next/Get Started button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                onPressed: () {
                  if (_currentPage < _pages.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    _navigateToLanguageSelection();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00401A),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 0),
                ),
                child: Text(
                  _currentPage < _pages.length - 1 ? AppLocalizations.of(context)!.next : AppLocalizations.of(context)!.getStarted,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),

          // Icon with circle background
          Center(
            child: Container(
              height: 110,
              width: 110,
              decoration: const BoxDecoration(
                color: Color(0xFFE6EFEA),
                shape: BoxShape.circle,
              ),
              child: data.isIconData
                  ? Icon(
                      data.icon,
                      color: const Color(0xFF00401A),
                      size: 48,
                    )
                  : Center(
                      child: Image.asset(
                        data.imagePath!,
                        height: 110,
                        width: 110,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback if image not found
                          return const Icon(
                            Icons.image,
                            color: const Color(0xFF00401A),
                            size: 48,
                          );
                        },
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 32),

          // Title
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              height: 1.5,
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }

  Widget _dot({bool isActive = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 20 : 8,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF00401A) : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// Data model for onboarding pages
class OnboardingData {
  final IconData? icon;
  final String? imagePath;
  final bool isIconData;
  final String title;
  final String description;

  OnboardingData({
    this.icon,
    this.imagePath,
    required this.isIconData,
    required this.title,
    required this.description,
  });
}