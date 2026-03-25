import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../constants/app_theme.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  AppConstants.appName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Smart Calendar Assistant',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, AppConstants.homeRoute);
            },
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Create Event'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppConstants.eventCreationRoute);
            },
          ),
          ListTile(
            leading: const Icon(Icons.event),
            title: const Text('Events'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppConstants.savedEventsRoute);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('Scan from Image'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppConstants.cameraCaptureRoute);
            },
          ),
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: const Text('Extract from Text'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppConstants.textExtractionRoute);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppConstants.settingsRoute);
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Feedback'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement help and feedback functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Help & Feedback coming soon!'),
                ),
              );
            },
          ),
          // Debug logs option - only visible in debug mode
          ListTile(
            leading: const Icon(Icons.bug_report),
            title: const Text('Debug Logs'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppConstants.debugLogsRoute);
            },
          ),
        ],
      ),
    );
  }
}
