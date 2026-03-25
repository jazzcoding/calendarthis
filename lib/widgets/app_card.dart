import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

enum AppCardType {
  standard,
  outlined,
  elevated,
  event,
}

class AppCard extends StatelessWidget {
  final Widget child;
  final AppCardType type;
  final Color? borderColor;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final BorderRadius? borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.type = AppCardType.standard,
    this.borderColor,
    this.onTap,
    this.padding,
    this.margin,
    this.elevation,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final cardTheme = Theme.of(context).cardTheme;
    
    // Default values
    final defaultPadding = const EdgeInsets.all(AppTheme.cardPadding);
    final defaultMargin = cardTheme.margin ?? const EdgeInsets.all(AppTheme.spacingSmall);
    final defaultBorderRadius = cardTheme.shape != null 
        ? (cardTheme.shape as RoundedRectangleBorder).borderRadius as BorderRadius
        : BorderRadius.circular(12);
    final defaultElevation = cardTheme.elevation ?? 2.0;
    
    // Apply card style based on type
    BoxDecoration decoration;
    
    switch (type) {
      case AppCardType.standard:
        decoration = BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: borderRadius ?? defaultBorderRadius,
        );
        break;
      case AppCardType.outlined:
        decoration = BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: borderRadius ?? defaultBorderRadius,
          border: Border.all(
            color: borderColor ?? AppTheme.dividerColor,
            width: 1,
          ),
        );
        break;
      case AppCardType.elevated:
        decoration = BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: borderRadius ?? defaultBorderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: elevation ?? defaultElevation,
              offset: const Offset(0, 2),
            ),
          ],
        );
        break;
      case AppCardType.event:
        decoration = BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: borderRadius ?? defaultBorderRadius,
          border: Border(
            left: BorderSide(
              color: borderColor ?? AppTheme.primaryColor,
              width: 4,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: elevation ?? defaultElevation,
              offset: const Offset(0, 2),
            ),
          ],
        );
        break;
    }
    
    final cardContent = Container(
      padding: padding ?? defaultPadding,
      decoration: decoration,
      child: child,
    );
    
    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? defaultBorderRadius,
        child: Container(
          margin: margin ?? defaultMargin,
          child: cardContent,
        ),
      );
    }
    
    return Container(
      margin: margin ?? defaultMargin,
      child: cardContent,
    );
  }
}
