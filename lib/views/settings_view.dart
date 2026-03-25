import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/app_constants.dart';
import '../constants/app_theme.dart';

import '../services/preferences_service.dart';
import '../services/text_extraction_service_impl.dart';
import '../services/openrouter_service.dart';
import '../services/notification_service.dart';
import '../widgets/app_bottom_nav.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final PreferencesService _preferencesService = PreferencesService();
  final TextExtractionServiceImpl _textExtractionService =
      TextExtractionServiceImpl();
  final OpenRouterService _openRouterService = OpenRouterService();
  final NotificationService _notificationService = NotificationService();

  // OpenRouter API key controller
  final TextEditingController _apiKeyController = TextEditingController();
  bool _isLoadingApiKey = false;
  bool _useAI = true;

  // Settings values
  late bool _use24HourFormat;
  late String _dateFormat;
  late String _language;
  late bool _darkMode;

  // Notification settings
  late bool _eventReminderNotifications;
  late bool _appUpdateNotifications;
  late int _reminderTime;
  bool _notificationPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _checkApiKey();
    _checkNotificationPermission();
    _notificationService.init();
  }

  // Check if notification permission is granted
  Future<void> _checkNotificationPermission() async {
    final isGranted = await _notificationService.checkPermissions();
    setState(() {
      _notificationPermissionGranted = isGranted;
    });
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  // Check if API key is set (always true now with default key)
  Future<void> _checkApiKey() async {
    setState(() {
      _isLoadingApiKey = true;
    });

    // We don't need to check for custom key anymore since we always have a default key
    // Just for logging purposes
    final hasCustomKey = await _openRouterService.hasCustomApiKey();
    if (kDebugMode) {
      print('Using custom API key: $hasCustomKey');
    }

    setState(() {
      // We always have an API key now (either custom or default)
      _isLoadingApiKey = false;
    });
  }

  // Load preferences from storage
  void _loadPreferences() {
    setState(() {
      _use24HourFormat = _preferencesService.getUse24HourFormat();
      _dateFormat = _preferencesService.getDateFormat();
      _language = _preferencesService.getLanguage();
      _darkMode = _preferencesService.getDarkMode();
      _useAI = _preferencesService.getUseAI();

      // Load notification settings
      _eventReminderNotifications =
          _preferencesService.getEventReminderNotifications();
      _appUpdateNotifications = _preferencesService.getAppUpdateNotifications();
      _reminderTime = _preferencesService.getReminderTime();
    });
  }

  // Update theme mode
  void _updateThemeMode(bool isDarkMode) {
    setState(() {
      _darkMode = isDarkMode;
    });
    _preferencesService.setDarkMode(isDarkMode);

    // Show a message to restart the app for theme changes to take effect
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Restart the app for theme changes to take effect'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  // Show dialog to set reminder time
  void _showReminderTimeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reminder Time'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'How many minutes before an event should we remind you?'),
            const SizedBox(height: 16),
            DropdownButton<int>(
              value: _reminderTime,
              items: const [
                DropdownMenuItem(value: 5, child: Text('5 minutes')),
                DropdownMenuItem(value: 10, child: Text('10 minutes')),
                DropdownMenuItem(value: 15, child: Text('15 minutes')),
                DropdownMenuItem(value: 30, child: Text('30 minutes')),
                DropdownMenuItem(value: 60, child: Text('1 hour')),
                DropdownMenuItem(value: 120, child: Text('2 hours')),
                DropdownMenuItem(value: 1440, child: Text('1 day')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _reminderTime = value;
                  });
                  _preferencesService.setReminderTime(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // Show dialog to set or update API key
  void _showApiKeyDialog() async {
    // Get current API key if it exists
    String? currentKey;
    bool isUsingDefaultKey = false;

    try {
      // Check if using a custom key
      final hasCustomKey = await _openRouterService.hasCustomApiKey();
      if (hasCustomKey) {
        currentKey = await _openRouterService.getApiKey();
      } else {
        // Using default key
        isUsingDefaultKey = true;
        currentKey = await _openRouterService.getApiKey();
      }
    } catch (e) {
      currentKey = null;
    }

    _apiKeyController.text = currentKey ?? '';

    if (!mounted) return;

    // Store context for later use
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('OpenRouter API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isUsingDefaultKey
                  ? 'You are currently using the default API key. You can enter your own OpenRouter API key if you prefer.'
                  : 'Enter your OpenRouter API key to use AI for text extraction. You can get a free API key at openrouter.ai.',
            ),
            const SizedBox(height: 8),
            if (isUsingDefaultKey)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(25), // ~10% opacity
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: Colors.green.withAlpha(75)), // ~30% opacity
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Default API key is already set and working',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                labelText: 'API Key',
                border: OutlineInputBorder(),
                hintText: 'sk-or-...',
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          if (!isUsingDefaultKey)
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () async {
                // Store context before async gap
                final ctx = dialogContext;

                await _openRouterService.deleteApiKey();
                if (!mounted) return;

                await _checkApiKey();
                if (!mounted) return;

                if (ctx.mounted) Navigator.pop(ctx);
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Custom API key removed. Using default key.'),
                  ),
                );
              },
              child: const Text('Use Default'),
            ),
          TextButton(
            onPressed: () async {
              // Store context before async gap
              final ctx = dialogContext;

              if (_apiKeyController.text.trim().isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid API key.'),
                  ),
                );
                return;
              }

              await _openRouterService
                  .saveApiKey(_apiKeyController.text.trim());
              if (!mounted) return;

              await _checkApiKey();
              if (!mounted) return;

              if (ctx.mounted) Navigator.pop(ctx);
              scaffoldMessenger.showSnackBar(
                const SnackBar(
                  content: Text('Custom API key saved.'),
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Time Settings',
            style: AppTheme.subheadingStyle,
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Use 24-hour format'),
                  value: _use24HourFormat,
                  onChanged: (value) {
                    setState(() {
                      _use24HourFormat = value;
                    });
                    _preferencesService.setUse24HourFormat(value);
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text('Date Format'),
                  subtitle: Text(_dateFormat),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Implement date format selection
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Date format selection coming soon!'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'App Settings',
            style: AppTheme.subheadingStyle,
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Language'),
                  subtitle: Text(_language),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Implement language selection
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Language selection coming soon!'),
                      ),
                    );
                  },
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  value: _darkMode,
                  onChanged: (value) {
                    _updateThemeMode(value);
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text('Reset Onboarding'),
                  subtitle: const Text('Show the welcome screens again'),
                  trailing: const Icon(Icons.refresh, size: 16),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Reset Onboarding'),
                        content: const Text(
                            'Are you sure you want to see the onboarding screens again?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              _preferencesService.setFirstLaunch(true);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Onboarding reset. Restart the app to see the welcome screens.'),
                                ),
                              );
                            },
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'AI Settings',
            style: AppTheme.subheadingStyle,
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Use AI for Text Extraction'),
                  subtitle: const Text('Improves extraction accuracy using AI'),
                  value: _useAI,
                  onChanged: (value) {
                    setState(() {
                      _useAI = value;
                      _textExtractionService.useAI = value;
                    });
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text('OpenRouter API Key'),
                  subtitle: FutureBuilder<bool>(
                    future: _openRouterService.hasCustomApiKey(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text('Checking API key...');
                      }

                      final hasCustomKey = snapshot.data ?? false;
                      return Text(hasCustomKey
                          ? 'Custom API key is set'
                          : 'Using default API key');
                    },
                  ),
                  trailing: _isLoadingApiKey
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showApiKeyDialog();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Notifications',
            style: AppTheme.subheadingStyle,
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Notification Permissions'),
                  subtitle: Text(_notificationPermissionGranted
                      ? 'Notifications are enabled'
                      : 'Notifications are disabled'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    // Store context for later use
                    final scaffoldMessenger = ScaffoldMessenger.of(context);

                    if (_notificationPermissionGranted) {
                      if (mounted) {
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Notification permission is already granted.'),
                          ),
                        );
                      }
                    } else {
                      final isGranted =
                          await _notificationService.requestPermissions();

                      setState(() {
                        _notificationPermissionGranted = isGranted;
                      });

                      if (mounted) {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              isGranted
                                  ? 'Notification permission granted.'
                                  : 'Notification permission denied. Please grant permission in settings.',
                            ),
                          ),
                        );
                      }
                    }
                  },
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Event Reminders'),
                  subtitle: const Text('Receive reminders for upcoming events'),
                  value: _eventReminderNotifications,
                  onChanged: _notificationPermissionGranted
                      ? (value) {
                          setState(() {
                            _eventReminderNotifications = value;
                          });
                          _preferencesService
                              .setEventReminderNotifications(value);
                        }
                      : null,
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('App Updates'),
                  subtitle: const Text(
                      'Receive notifications about app updates and features'),
                  value: _appUpdateNotifications,
                  onChanged: _notificationPermissionGranted
                      ? (value) {
                          setState(() {
                            _appUpdateNotifications = value;
                          });
                          _preferencesService.setAppUpdateNotifications(value);
                        }
                      : null,
                ),
                const Divider(),
                ListTile(
                  title: const Text('Reminder Time'),
                  subtitle: Text('$_reminderTime minutes before event'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  enabled: _notificationPermissionGranted &&
                      _eventReminderNotifications,
                  onTap: _notificationPermissionGranted &&
                          _eventReminderNotifications
                      ? () {
                          _showReminderTimeDialog();
                        }
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Permissions',
            style: AppTheme.subheadingStyle,
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Camera Access'),
                  subtitle:
                      const Text('Allow access to your camera for scanning'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    // Store context for later use
                    final scaffoldMessenger = ScaffoldMessenger.of(context);

                    final status = await Permission.camera.status;

                    if (status.isGranted) {
                      if (mounted) {
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                            content: Text('Camera access is already granted.'),
                          ),
                        );
                      }
                    } else {
                      final result = await Permission.camera.request();

                      if (mounted) {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              result.isGranted
                                  ? 'Camera access granted.'
                                  : 'Camera access denied. Please grant permission in settings.',
                            ),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'About',
            style: AppTheme.subheadingStyle,
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Version'),
                  subtitle: Text(AppConstants.appVersion),
                ),
                const Divider(),
                ListTile(
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pushNamed(
                        context, AppConstants.privacyPolicyRoute);
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text('Terms of Service'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pushNamed(
                        context, AppConstants.termsOfServiceRoute);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
