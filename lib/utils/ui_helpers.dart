import 'dart:math';

import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

/// UI helper functions for the app
class UIHelpers {
  // Private constructor to prevent instantiation
  UIHelpers._();

  /// Add a page transition animation to a widget
  static Widget addPageTransition({
    required Widget child,
    required Animation<double> animation,
    TransitionType type = TransitionType.fade,
  }) {
    switch (type) {
      case TransitionType.fade:
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      case TransitionType.scale:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      case TransitionType.slideRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
          ),
          child: child,
        );
      case TransitionType.slideUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
          ),
          child: child,
        );
    }
  }

  /// Add a loading animation to a widget
  static Widget addLoadingAnimation({
    required Widget child,
    bool isLoading = false,
    Color? color,
    double size = 24.0,
  }) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedOpacity(
          opacity: isLoading ? 0.3 : 1.0,
          duration: AppTheme.animationDurationStandard,
          child: child,
        ),
        if (isLoading)
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? Colors.blue,
              ),
            ),
          ),
      ],
    );
  }

  /// Add a shake animation to a widget
  static Widget addShakeAnimation({
    required Widget child,
    required AnimationController controller,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final sineValue = sin(controller.value * 3 * 3.1415);
        return Transform.translate(
          offset: Offset(sineValue * 10, 0),
          child: child,
        );
      },
      child: child,
    );
  }

  /// Add a pulse animation to a widget
  static Widget addPulseAnimation({
    required Widget child,
    required AnimationController controller,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + 0.1 * sin(controller.value * 2 * 3.1415),
          child: child,
        );
      },
      child: child,
    );
  }
}

/// Types of transitions for page animations
enum TransitionType {
  fade,
  scale,
  slideRight,
  slideUp,
}
