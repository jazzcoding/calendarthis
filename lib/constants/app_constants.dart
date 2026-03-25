class AppConstants {
  // App information
  static const String appName = 'Calendar This';
  static const String appVersion = '1.0.0';

  // Routes
  static const String splashRoute = '/splash';
  static const String homeRoute = '/';
  static const String settingsRoute = '/settings';
  static const String eventCreationRoute = '/event-creation';
  static const String textExtractionRoute = '/text-extraction';
  static const String onboardingRoute = '/onboarding';
  static const String eventDetailRoute = '/event-detail';
  static const String cameraCaptureRoute = '/camera-capture';
  static const String savedEventsRoute = '/saved-events';
  static const String privacyPolicyRoute = '/privacy-policy';
  static const String termsOfServiceRoute = '/terms-of-service';
  static const String debugLogsRoute = '/debug-logs';

  // Shared Preferences Keys
  static const String prefIsFirstLaunch = 'is_first_launch';

  static const String prefTimeFormat = 'time_format';
  static const String prefDateFormat = 'date_format';
  static const String prefLanguage = 'language';

  // Permission related
  static const String cameraPermissionRationale =
      'Camera access is needed to scan event details from physical documents or screens.';
  static const String storagePermissionRationale =
      'Storage access is needed to save and process images for event extraction.';
  static const String notificationPermissionRationale =
      'Notification access is needed to remind you about upcoming events.';

  // Feature descriptions
  static const String textExtractionDescription =
      'Extract event details from text messages, emails, or any text containing event information.';
  static const String imageExtractionDescription =
      'Scan event details from images, screenshots, or physical documents using your camera.';
}
