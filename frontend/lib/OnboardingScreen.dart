import 'package:flutter/material.dart';
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
  final List<OnboardingData> _pages = [
    OnboardingData(
      icon: Icons.balance,
      isIconData: true,
      title: 'Know Your Rights',
      urduTitle: 'اپنے حقوق جانیں',
      description:
          'Access comprehensive legal information about Pakistani laws covering criminal, civil, labour, and cyber domains.',
    ),
    OnboardingData(
      imagePath: 'assets/legal_image.png',
      isIconData: false,
      title: 'AI Legal Assistant',
      urduTitle: 'اے آئی قانونی معاون',
      description:
          'Get instant answers to your legal questions in English, Roman Urdu, or Urdu from our intelligent assistant.',
    ),
    OnboardingData(
      imagePath: 'assets/draft_image.png',
      isIconData: false,
      title: 'Draft Documents',
      urduTitle: 'دستاویزات تیار کریں',
      description:
          'Generate FIRs, complaints, and legal documents with guided step-by-step assistance.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
                  child: const Text(
                    'Skip',
                    style: TextStyle(
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
                  backgroundColor:  Color(0xFF00401A),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 0),
                ),
                child: Text(
                  _currentPage < _pages.length - 1 ? 'Next' : 'Get Started',
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
                      color:  Color(0xFF00401A),
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
                            color:  Color(0xFF00401A),
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

          const SizedBox(height: 8),

          // Urdu text
          Text(
            data.urduTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color:  Color(0xFF00401A),
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
        color: isActive ?  Color(0xFF00401A) : Colors.grey.shade300,
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
  final String urduTitle;
  final String description;

  OnboardingData({
    this.icon,
    this.imagePath,
    required this.isIconData,
    required this.title,
    required this.urduTitle,
    required this.description,
  });
}