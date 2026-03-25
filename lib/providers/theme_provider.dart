import 'package:flutter/material.dart';
import '../services/preferences_service.dart';

class ThemeProvider extends ChangeNotifier {
  final PreferencesService _preferencesService = PreferencesService();
  late ThemeMode _themeMode;
  bool _isInitialized = false;

  ThemeProvider() {
    _initializeTheme();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isInitialized => _isInitialized;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> _initializeTheme() async {
    await _preferencesService.init();
    final isDarkMode = _preferencesService.getDarkMode();
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setDarkMode(bool isDarkMode) async {
    await _preferencesService.setDarkMode(isDarkMode);
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    final newIsDarkMode = _themeMode == ThemeMode.light;
    await setDarkMode(newIsDarkMode);
  }
}
