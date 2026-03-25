import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class PreferencesService {
  static final PreferencesService _instance = PreferencesService._internal();

  factory PreferencesService() {
    return _instance;
  }

  PreferencesService._internal();

  late SharedPreferences _prefs;

  // Initialize the preferences service
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Check if this is the first launch of the app
  bool isFirstLaunch() {
    return _prefs.getBool(AppConstants.prefIsFirstLaunch) ?? true;
  }

  // Set first launch status
  Future<void> setFirstLaunch(bool isFirst) async {
    await _prefs.setBool(AppConstants.prefIsFirstLaunch, isFirst);
  }

  // Get the time format (12h/24h)
  bool getUse24HourFormat() {
    return _prefs.getBool(AppConstants.prefTimeFormat) ?? false;
  }

  // Set the time format
  Future<void> setUse24HourFormat(bool use24Hour) async {
    await _prefs.setBool(AppConstants.prefTimeFormat, use24Hour);
  }

  // Get the date format
  String getDateFormat() {
    return _prefs.getString(AppConstants.prefDateFormat) ?? 'MM/DD/YYYY';
  }

  // Set the date format
  Future<void> setDateFormat(String format) async {
    await _prefs.setString(AppConstants.prefDateFormat, format);
  }

  // Get the language
  String getLanguage() {
    return _prefs.getString(AppConstants.prefLanguage) ?? 'English';
  }

  // Set the language
  Future<void> setLanguage(String language) async {
    await _prefs.setString(AppConstants.prefLanguage, language);
  }

  // Get dark mode setting
  bool getDarkMode() {
    return _prefs.getBool('dark_mode') ?? false;
  }

  // Set dark mode setting
  Future<void> setDarkMode(bool darkMode) async {
    await _prefs.setBool('dark_mode', darkMode);
  }

  // Clear all preferences
  Future<void> clearPreferences() async {
    await _prefs.clear();
  }

  // API key methods
  Future<void> saveApiKey(String apiKey) async {
    await _prefs.setString('api_key', apiKey);
  }

  String? getApiKey() {
    return _prefs.getString('api_key');
  }

  // AI usage preference
  Future<void> setUseAI(bool useAI) async {
    await _prefs.setBool('use_ai', useAI);
  }

  bool getUseAI() {
    return _prefs.getBool('use_ai') ?? true; // Default to true
  }

  // Notification preferences

  // Get event reminder notifications setting
  bool getEventReminderNotifications() {
    return _prefs.getBool('event_reminder_notifications') ??
        true; // Default to true
  }

  // Set event reminder notifications setting
  Future<void> setEventReminderNotifications(bool enabled) async {
    await _prefs.setBool('event_reminder_notifications', enabled);
  }

  // Get app update notifications setting
  bool getAppUpdateNotifications() {
    return _prefs.getBool('app_update_notifications') ??
        true; // Default to true
  }

  // Set app update notifications setting
  Future<void> setAppUpdateNotifications(bool enabled) async {
    await _prefs.setBool('app_update_notifications', enabled);
  }

  // Get reminder time (minutes before event)
  int getReminderTime() {
    return _prefs.getInt('reminder_time') ?? 30; // Default to 30 minutes
  }

  // Set reminder time
  Future<void> setReminderTime(int minutes) async {
    await _prefs.setInt('reminder_time', minutes);
  }
}
