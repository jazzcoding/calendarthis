import 'package:flutter/material.dart';

class OnboardingPage {
  final String title;
  final String description;
  final String imagePath;
  final Color backgroundColor;
  final Color textColor;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.imagePath,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
  });
}

class OnboardingData {
  static List<OnboardingPage> pages = [
    OnboardingPage(
      title: 'Welcome to CalendarThis!',
      description: 'The easiest way to create and manage events from text.',
      imagePath: 'assets/images/onboarding_welcome.svg',
      backgroundColor: const Color(0xFF4A6572),
      textColor: Colors.white,
    ),
    OnboardingPage(
      title: 'Extract from Text',
      description:
          'Copy text from messages, emails, or websites and let us find the event details.',
      imagePath: 'assets/images/onboarding_text.svg',
      backgroundColor: const Color(0xFF344955),
      textColor: Colors.white,
    ),
    OnboardingPage(
      title: 'Scan from Images',
      description:
          'Take a photo or use a screenshot to extract event information automatically.',
      imagePath: 'assets/images/onboarding_image.svg',
      backgroundColor: const Color(0xFF232F34),
      textColor: Colors.white,
    ),
    OnboardingPage(
      title: 'You\'re All Set!',
      description:
          'Start creating events from text and images with just a few taps.',
      imagePath: 'assets/images/onboarding_welcome.svg',
      backgroundColor: const Color(0xFF4A6572),
      textColor: Colors.white,
    ),
  ];
}
