import 'package:flutter/material.dart';

class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // Colors - Primary
  static const Color primaryColor = Color(0xFF4285F4); // Google Blue
  static const Color secondaryColor = Color(0xFF34A853); // Google Green
  static const Color accentColor = Color(0xFFFBBC05); // Google Yellow
  static const Color errorColor = Color(0xFFEA4335); // Google Red

  // Colors - Neutral
  static const Color textPrimaryColor = Color(0xFF202124);
  static const Color textSecondaryColor = Color(0xFF5F6368);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color surfaceColor = Color(0xFFF8F9FA);
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color disabledColor = Color(0xFFBDBDBD);

  // Spacing
  static const double spacingTiny = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  static const double spacingHuge = 48.0;

  // Layout Padding
  static const double screenPadding = 16.0;
  static const double contentPadding = 24.0;
  static const double cardPadding = 16.0;

  // Component Sizes
  static const double appBarHeight = 56.0;
  static const double bottomNavHeight = 56.0;
  static const double drawerWidth = 280.0;
  static const double calendarDaySize = 40.0;
  static const double minTouchTarget = 48.0;

  // Animation Durations
  static const Duration animationDurationStandard = Duration(milliseconds: 300);
  static const Duration animationDurationQuick = Duration(milliseconds: 150);

  // Text Styles
  static const TextStyle heading1Style = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static const TextStyle heading2Style = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static const TextStyle heading3Style = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500, // Medium
    color: textPrimaryColor,
  );

  static const TextStyle subtitle1Style = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500, // Medium
    color: textSecondaryColor,
  );

  static const TextStyle subtitle2Style = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500, // Medium
    color: textSecondaryColor,
  );

  static const TextStyle body1Style = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimaryColor,
  );

  static const TextStyle body2Style = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textSecondaryColor,
  );

  static const TextStyle buttonStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500, // Medium
    color: primaryColor,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondaryColor,
  );

  // Legacy styles for backward compatibility
  static const TextStyle headingStyle = heading2Style;
  static const TextStyle subheadingStyle = subtitle1Style;
  static const TextStyle bodyStyle = body1Style;

  // Light Theme
  static ThemeData lightTheme = ThemeData.light(
    useMaterial3: true,
  ).copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
      surface: surfaceColor,
      // Using surfaceContainerHighest instead of deprecated background/surfaceVariant
      surfaceContainerHighest: backgroundColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimaryColor,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: backgroundColor,
    dividerColor: dividerColor,
    disabledColor: disabledColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      iconTheme: IconThemeData(
        color: Colors.white,
        size: 24,
      ),
      toolbarHeight: appBarHeight,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: buttonStyle.copyWith(color: Colors.white),
        minimumSize: const Size(88, 48), // Ensures minimum touch target size
        elevation: 2,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: buttonStyle,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        minimumSize: const Size(64, 36),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: buttonStyle,
        minimumSize: const Size(88, 48), // Ensures minimum touch target size
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: backgroundColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: textSecondaryColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: textSecondaryColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      labelStyle: subtitle2Style,
      hintStyle: body2Style.copyWith(color: disabledColor),
      errorStyle: captionStyle.copyWith(color: errorColor),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: backgroundColor,
      margin: const EdgeInsets.all(spacingSmall),
    ),
    iconTheme: const IconThemeData(
      color: textSecondaryColor,
      size: 24,
    ),
    textTheme: const TextTheme(
      displayLarge: heading1Style,
      displayMedium: heading2Style,
      displaySmall: heading3Style,
      headlineMedium: subtitle1Style,
      headlineSmall: subtitle2Style,
      bodyLarge: body1Style,
      bodyMedium: body2Style,
      labelLarge: buttonStyle,
      bodySmall: captionStyle,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceColor,
      disabledColor: disabledColor.withAlpha(25), // ~10% opacity
      selectedColor: primaryColor.withAlpha(25), // ~10% opacity
      secondarySelectedColor: secondaryColor.withAlpha(25), // ~10% opacity
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelStyle: body2Style,
      secondaryLabelStyle: body2Style.copyWith(color: secondaryColor),
      brightness: Brightness.light,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: dividerColor),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: backgroundColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: textSecondaryColor,
      selectedLabelStyle: captionStyle,
      unselectedLabelStyle: captionStyle,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      elevation: 8,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      titleTextStyle: heading3Style,
      contentTextStyle: body1Style,
      elevation: 24,
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData.dark(
    useMaterial3: true,
  ).copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onError: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF202124),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      iconTheme: IconThemeData(
        color: Colors.white,
        size: 24,
      ),
      toolbarHeight: appBarHeight,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: buttonStyle.copyWith(color: Colors.white),
        minimumSize: const Size(88, 48),
        elevation: 2,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(spacingSmall),
    ),
    iconTheme: const IconThemeData(
      color: Colors.white70,
      size: 24,
    ),
  );
}
