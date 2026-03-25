import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/event_model.dart';
import 'logging_service.dart';

class CalendarIntegrationService {
  // Singleton pattern
  static final CalendarIntegrationService _instance =
      CalendarIntegrationService._internal();

  factory CalendarIntegrationService() {
    return _instance;
  }

  final LoggingService _logger = LoggingService();

  CalendarIntegrationService._internal() {
    _logger.init();
  }

  // Convert our EventModel to Add2Calendar Event
  Event _convertToCalendarEvent(EventModel event) {
    // Create description with attendees included
    String fullDescription = event.description;

    // Add attendees to description if there are any
    if (event.attendees.isNotEmpty) {
      fullDescription += '\n\nAttendees:\n';
      for (final attendee in event.attendees) {
        fullDescription += '- $attendee\n';
      }
    }

    return Event(
      title: event.title,
      description: fullDescription,
      location: event.location,
      startDate: event.startTime,
      endDate: event.endTime,
      allDay: event.isAllDay,
    );
  }

  // Check and request calendar permissions
  Future<bool> _checkCalendarPermissions() async {
    try {
      // Check current permission status
      PermissionStatus status = await Permission.calendarWriteOnly.status;

      // If permission is not granted, request it
      if (!status.isGranted) {
        await _logger.log('Calendar', 'Requesting calendar permissions');
        status = await Permission.calendarWriteOnly.request();
      }

      return status.isGranted;
    } catch (e) {
      await _logger.log('Calendar', 'Error checking calendar permissions: $e');
      return false;
    }
  }

  // Show a dialog asking if the user wants to save the event to the device calendar
  Future<void> showSaveToCalendarDialog(
      BuildContext context, EventModel event) async {
    await _logger.log(
        'Calendar', 'Showing save to calendar dialog for: ${event.title}');

    // Check if context is still valid
    if (!context.mounted) {
      await _logger.log(
          'Calendar', 'Context is no longer mounted, aborting dialog');
      return;
    }

    // Show the dialog and wait for user response
    final shouldSave = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Save to Device Calendar?'),
          content: Text(
              'Would you like to save "${event.title}" to your device calendar?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext)
                    .pop(false); // User chose not to save
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true); // User chose to save
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    // If user chose to save (and didn't dismiss the dialog)
    if (shouldSave == true) {
      // Check if context is still valid
      if (!context.mounted) {
        await _logger.log(
            'Calendar', 'Context is no longer mounted after dialog, aborting');
        return;
      }

      // Show info message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Opening calendar app...'),
          duration: Duration(seconds: 2),
        ),
      );

      // Add to device calendar
      final result = await addEventToDefaultCalendar(event);

      // Check if context is still valid
      if (!context.mounted) {
        await _logger.log('Calendar',
            'Context is no longer mounted after adding to calendar, aborting');
        return;
      }

      // Show result message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result
              ? 'Event added to device calendar'
              : 'Failed to add event to device calendar. Please check app permissions.'),
          duration: const Duration(seconds: 4),
          action: result
              ? null
              : SnackBarAction(
                  label: 'Settings',
                  onPressed: () {
                    // Open app settings
                    openAppSettings();
                  },
                ),
        ),
      );
    } else {
      await _logger.log(
          'Calendar', 'User chose not to save event to device calendar');
    }
  }

  // Add event to default calendar
  Future<bool> addEventToDefaultCalendar(EventModel event) async {
    try {
      await _logger.log(
          'Calendar', 'Adding event to default calendar: ${event.title}');

      // Check permissions first
      bool hasPermission = await _checkCalendarPermissions();
      if (!hasPermission) {
        await _logger.log('Calendar', 'Calendar permissions not granted');
        return false;
      }

      // Log event details for debugging
      await _logger.log(
          'Calendar',
          'Event details: '
              'title=${event.title}, '
              'start=${event.startTime}, '
              'end=${event.endTime}, '
              'location=${event.location}, '
              'allDay=${event.isAllDay}');

      final calendarEvent = _convertToCalendarEvent(event);

      // Log the converted event
      await _logger.log(
          'Calendar',
          'Converted event: '
              'title=${calendarEvent.title}, '
              'start=${calendarEvent.startDate}, '
              'end=${calendarEvent.endDate}, '
              'location=${calendarEvent.location}, '
              'allDay=${calendarEvent.allDay}');

      // This will open the default calendar app with the event details pre-filled
      await _logger.log('Calendar', 'Calling Add2Calendar.addEvent2Cal');
      final result = await Add2Calendar.addEvent2Cal(calendarEvent);

      await _logger.log('Calendar', 'Event added to calendar: $result');

      return result;
    } catch (e, stackTrace) {
      await _logger.log('Calendar', 'Error adding event to calendar: $e');
      await _logger.log('Calendar', 'Stack trace: $stackTrace');
      return false;
    }
  }
}
