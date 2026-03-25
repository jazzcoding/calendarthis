import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/event_model.dart';
import '../views/camera_capture_view.dart';
import '../views/debug_logs_view.dart';
import '../views/event_creation_view.dart';
import '../views/event_detail_view.dart';
import '../views/home_view.dart';
import '../views/onboarding_view.dart';
import '../views/privacy_policy_view.dart';
import '../views/saved_events_view.dart';
import '../views/settings_view.dart';
import '../views/splash_view.dart';
import '../views/text_extraction_view.dart';
import 'animations.dart';

/// A class that generates routes with custom transitions
class RouteGenerator {
  // Private constructor to prevent instantiation
  RouteGenerator._();

  /// Generate a route with the appropriate transition
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case AppConstants.splashRoute:
        return AppPageTransitions.fade(
          page: const SplashView(),
          settings: settings,
        );

      case AppConstants.homeRoute:
        return AppPageTransitions.fade(
          page: const HomeView(),
          settings: settings,
        );

      case AppConstants.settingsRoute:
        return AppPageTransitions.slideRightToLeft(
          page: const SettingsView(),
          settings: settings,
        );

      case AppConstants.eventCreationRoute:
        Widget page;
        try {
          if (args is EventModel) {
            page = EventCreationView(event: args);
          } else if (args is DateTime) {
            page = EventCreationView(selectedDate: args);
          } else if (args is Map<String, dynamic>) {
            // Handle map arguments for initialTab
            final initialTab = args['initialTab'] as int?;
            final initialText = args['initialText'] as String?;
            page = EventCreationView(
              initialTab: initialTab,
              initialText: initialText,
            );
          } else if (args is String) {
            // Handle string argument for initialText
            page = EventCreationView(initialText: args);
          } else {
            page = const EventCreationView();
          }
        } catch (e) {
          debugPrint('Error in eventCreationRoute: $e');
          page = const EventCreationView();
        }
        return AppPageTransitions.slideBottomToTop(
          page: page,
          settings: settings,
        );

      case AppConstants.textExtractionRoute:
        final extractedText = args as String?;
        return AppPageTransitions.slideRightToLeft(
          page: TextExtractionView(initialText: extractedText),
          settings: settings,
        );

      case AppConstants.onboardingRoute:
        return AppPageTransitions.fade(
          page: const OnboardingView(),
          settings: settings,
        );

      case AppConstants.cameraCaptureRoute:
        return AppPageTransitions.slideRightToLeft(
          page: const CameraCaptureView(),
          settings: settings,
        );

      case AppConstants.savedEventsRoute:
        return AppPageTransitions.slideRightToLeft(
          page: const SavedEventsView(),
          settings: settings,
        );

      case AppConstants.eventDetailRoute:
        if (args is EventModel) {
          return AppPageTransitions.scale(
            page: EventDetailView(event: args, onEventUpdated: () {}),
            settings: settings,
          );
        }
        return _errorRoute(settings);

      case AppConstants.privacyPolicyRoute:
        return AppPageTransitions.slideRightToLeft(
          page: const PrivacyPolicyView(),
          settings: settings,
        );

      case AppConstants.debugLogsRoute:
        return AppPageTransitions.slideRightToLeft(
          page: const DebugLogsView(),
          settings: settings,
        );

      default:
        return _errorRoute(settings);
    }
  }

  /// Generate an error route
  static Route<dynamic> _errorRoute(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('Page not found'),
        ),
      ),
    );
  }
}
