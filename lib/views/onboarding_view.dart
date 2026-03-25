import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_constants.dart';
import '../models/onboarding_model.dart';
import '../services/preferences_service.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final PreferencesService _preferencesService = PreferencesService();

  @override
  void initState() {
    super.initState();
    _initPreferences();
  }

  Future<void> _initPreferences() async {
    await _preferencesService.init();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _completeOnboarding() async {
    // Mark onboarding as completed
    await _preferencesService.setFirstLaunch(false);

    if (!mounted) return;

    // Navigate to home screen
    Navigator.pushReplacementNamed(context, AppConstants.homeRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Page view for onboarding pages
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: OnboardingData.pages.length,
            itemBuilder: (context, index) {
              final page = OnboardingData.pages[index];
              return _buildOnboardingPage(page);
            },
          ),

          // Navigation buttons
          Positioned(
            bottom: 48.0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Page indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    OnboardingData.pages.length,
                    (index) => _buildPageIndicator(index == _currentPage),
                  ),
                ),
                const SizedBox(height: 32.0),

                // Navigation buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Skip button
                      TextButton(
                        onPressed: _completeOnboarding,
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: OnboardingData.pages[_currentPage].textColor,
                            fontSize: 16.0,
                          ),
                        ),
                      ),

                      // Next/Done button
                      ElevatedButton(
                        onPressed: () {
                          if (_currentPage == OnboardingData.pages.length - 1) {
                            _completeOnboarding();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              OnboardingData.pages[_currentPage].textColor,
                          foregroundColor: OnboardingData
                              .pages[_currentPage].backgroundColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24.0,
                            vertical: 12.0,
                          ),
                        ),
                        child: Text(
                          _currentPage == OnboardingData.pages.length - 1
                              ? 'Get Started'
                              : 'Next',
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingPage page) {
    return Container(
      color: page.backgroundColor,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image
          Expanded(
            flex: 3,
            child: SvgPicture.asset(
              page.imagePath,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 32.0),

          // Title
          Text(
            page.title,
            style: TextStyle(
              color: page.textColor,
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16.0),

          // Description
          Text(
            page.description,
            style: TextStyle(
              color: page.textColor,
              fontSize: 18.0,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24.0),

          // Space for navigation buttons
          const Expanded(flex: 1, child: SizedBox()),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: isActive ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color: isActive
            ? OnboardingData.pages[_currentPage].textColor
            : OnboardingData.pages[_currentPage].textColor
                .withAlpha(102), // 0.4 opacity (255 * 0.4 = 102)
        borderRadius: BorderRadius.circular(4.0),
      ),
    );
  }
}
