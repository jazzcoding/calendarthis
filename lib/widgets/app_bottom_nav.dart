import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height < 700 ? 4 : 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                context,
                icon: Icons.home,
                label: 'Home',
                index: 0,
                route: AppConstants.homeRoute,
              ),
              _buildNavItem(
                context,
                icon: Icons.calendar_today,
                label: 'Calendar',
                index: 1,
                route: AppConstants.savedEventsRoute,
              ),
              _buildNavItem(
                context,
                icon: Icons.edit,
                label: 'Extract',
                index: 2,
                route: AppConstants.textExtractionRoute,
              ),
              _buildNavItem(
                context,
                icon: Icons.settings,
                label: 'Settings',
                index: 3,
                route: AppConstants.settingsRoute,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    required String route,
  }) {
    final isSelected = index == currentIndex;
    final color = isSelected ? const Color(0xFF4361ee) : Colors.grey.shade600;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (index != currentIndex) {
            Navigator.pushReplacementNamed(context, route);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width < 360 ? 8 : 12,
              vertical: MediaQuery.of(context).size.height < 700 ? 4 : 8),
          decoration: isSelected
              ? BoxDecoration(
                  color: const Color(0xFF4361ee).withAlpha(20),
                  borderRadius: BorderRadius.circular(16),
                )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: color,
                size: MediaQuery.of(context).size.width < 360 ? 20 : 22,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: MediaQuery.of(context).size.width < 360 ? 10 : 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
