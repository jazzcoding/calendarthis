import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:calendar_this/l10n/app_localizations.dart';

import 'models/event_model.dart';
import 'constants/app_constants.dart';
import 'constants/app_theme.dart';
import 'services/intent_service.dart';
import 'services/cache_manager.dart';
import 'services/preferences_service.dart';
import 'views/home_view.dart';
import 'views/settings_view.dart';
import 'views/event_creation_view.dart';
import 'views/text_extraction_view.dart';
import 'views/onboarding_view.dart';
import 'views/camera_capture_view.dart';
import 'views/saved_events_view.dart';
import 'views/event_detail_view.dart';
import 'views/splash_view.dart';
import 'views/privacy_policy_view.dart';
import 'views/terms_of_service_view.dart';
import 'views/debug_logs_view.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set up intent service for handling shared text (required for app functionality)
  final intentService = IntentService();
  await intentService.init();

  // Initialize cache manager
  final cacheManager = CacheManager();
  cacheManager.init();

  // We'll initialize other services lazily when they're needed
  // This improves startup time

  // Initialize preferences service
  final preferencesService = PreferencesService();
  await preferencesService.init();

  // Get dark mode preference
  final isDarkMode = preferencesService.getDarkMode();

  runApp(CalendarThisApp(isDarkMode: isDarkMode));
}

class CalendarThisApp extends StatelessWidget {
  final bool isDarkMode;

  const CalendarThisApp({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('es'), // Spanish
      ],
      initialRoute: AppConstants.splashRoute,
      routes: {
        AppConstants.splashRoute: (context) => const SplashView(),
        AppConstants.homeRoute: (context) => const HomeView(),
        AppConstants.settingsRoute: (context) => const SettingsView(),
        AppConstants.eventCreationRoute: (context) {
          // Get the arguments without casting
          final args = ModalRoute.of(context)?.settings.arguments;

          try {
            // Try to handle as EventModel first
            if (args is EventModel) {
              return EventCreationView(event: args);
            }
            // Try to handle as DateTime
            else if (args is DateTime) {
              return EventCreationView(selectedDate: args);
            }
            // Try to handle as Map for initialTab
            else if (args is Map<String, dynamic>) {
              final initialTab = args['initialTab'] as int?;
              final initialText = args['initialText'] as String?;
              return EventCreationView(
                initialTab: initialTab,
                initialText: initialText,
              );
            }
            // Try to handle as String for initialText
            else if (args is String) {
              return EventCreationView(initialText: args);
            }
            // Default case
            else {
              return const EventCreationView();
            }
          } catch (e) {
            // Fallback in case of any casting errors
            debugPrint('Error in eventCreationRoute: $e');
            return const EventCreationView();
          }
        },
        AppConstants.textExtractionRoute: (context) {
          final extractedText =
              ModalRoute.of(context)?.settings.arguments as String?;
          return TextExtractionView(initialText: extractedText);
        },
        AppConstants.onboardingRoute: (context) => const OnboardingView(),
        AppConstants.cameraCaptureRoute: (context) => const CameraCaptureView(),
        AppConstants.savedEventsRoute: (context) => const SavedEventsView(),
        AppConstants.eventDetailRoute: (context) {
          final event =
              ModalRoute.of(context)?.settings.arguments as EventModel;
          return EventDetailView(event: event, onEventUpdated: () {});
        },
        AppConstants.privacyPolicyRoute: (context) => const PrivacyPolicyView(),
        AppConstants.termsOfServiceRoute: (context) =>
            const TermsOfServiceView(),
        AppConstants.debugLogsRoute: (context) => const DebugLogsView(),
      },
    );
  }
}
