import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/app_constants.dart';
import '../models/event_model.dart';
import '../services/local_event_service.dart';
import '../services/calendar_integration_service.dart';
import '../widgets/app_bottom_nav.dart';

class EventDetailView extends StatefulWidget {
  final EventModel event;
  final Function onEventUpdated;

  const EventDetailView({
    super.key,
    required this.event,
    required this.onEventUpdated,
  });

  @override
  State<EventDetailView> createState() => _EventDetailViewState();
}

class _EventDetailViewState extends State<EventDetailView> {
  final LocalEventService _localEventService = LocalEventService();
  final CalendarIntegrationService _calendarService =
      CalendarIntegrationService();
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editEvent,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareEvent,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteEvent,
            color: Colors.red,
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      body: _isDeleting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event title
                  Text(
                    widget.event.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),

                  // Date and time
                  _buildInfoSection(
                    'Date & Time',
                    Icons.access_time,
                    widget.event.isAllDay
                        ? [
                            Text(
                                'All day: ${_formatDate(widget.event.startTime)}'),
                          ]
                        : [
                            Text(
                                'Start: ${_formatDateTime(widget.event.startTime)}'),
                            const SizedBox(height: 4),
                            Text(
                                'End: ${_formatDateTime(widget.event.endTime)}'),
                            const SizedBox(height: 4),
                            Text(
                                'Duration: ${_calculateDuration(widget.event.startTime, widget.event.endTime)}'),
                          ],
                  ),

                  // Description
                  if (widget.event.description.isNotEmpty)
                    _buildInfoSection(
                      'Description',
                      Icons.description,
                      [Text(widget.event.description)],
                    ),

                  // Location
                  if (widget.event.location.isNotEmpty)
                    _buildInfoSection(
                      'Location',
                      Icons.location_on,
                      [
                        Row(
                          children: [
                            Expanded(child: Text(widget.event.location)),
                            TextButton.icon(
                              icon: const Icon(Icons.map),
                              label: const Text('View Map'),
                              onPressed: () {
                                // TODO: Implement map view
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Map view coming soon!'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),

                  // Attendees
                  if (widget.event.attendees.isNotEmpty)
                    _buildInfoSection(
                      'Attendees',
                      Icons.people,
                      widget.event.attendees
                          .map(
                            (attendee) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  const Icon(Icons.person, size: 16),
                                  const SizedBox(width: 4),
                                  Text(attendee),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),

                  // Reminder
                  if (widget.event.reminderMinutes > 0)
                    _buildInfoSection(
                      'Reminder',
                      Icons.notifications,
                      [Text('${widget.event.reminderMinutes} minutes before')],
                    ),

                  // Add to device calendar button
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _addToDeviceCalendar,
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('Add to Device Calendar'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoSection(String title, IconData icon, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  void _editEvent() {
    Navigator.pushNamed(
      context,
      AppConstants.eventCreationRoute,
      arguments: widget.event,
    ).then((_) => widget.onEventUpdated());
  }

  void _shareEvent() {
    final String eventDetails = '''
${widget.event.title}
${widget.event.isAllDay ? 'All day: ${_formatDate(widget.event.startTime)}' : 'From: ${_formatDateTime(widget.event.startTime)}\nTo: ${_formatDateTime(widget.event.endTime)}'}
${widget.event.location.isNotEmpty ? 'Location: ${widget.event.location}' : ''}
${widget.event.description.isNotEmpty ? 'Description: ${widget.event.description}' : ''}
''';

    Share.share(eventDetails.trim());
  }

  Future<void> _addToDeviceCalendar() async {
    try {
      // Use the new dialog method from calendar service
      await _calendarService.showSaveToCalendarDialog(context, widget.event);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding to device calendar: $e'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _deleteEvent() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content:
            Text('Are you sure you want to delete "${widget.event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);

              setState(() {
                _isDeleting = true;
              });

              // Delete the event
              final success =
                  await _localEventService.deleteEvent(widget.event.id);

              if (mounted) {
                setState(() {
                  _isDeleting = false;
                });
              }

              // Show result
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Event deleted successfully'
                          : 'Failed to delete event',
                    ),
                  ),
                );
              }

              // Go back and refresh events list if successful
              if (success && mounted) {
                widget.onEventUpdated();
                Navigator.pop(context);
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Helper methods for formatting date and time
  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _calculateDuration(DateTime start, DateTime end) {
    final duration = end.difference(start);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '$hours hour${hours > 1 ? 's' : ''} ${minutes > 0 ? '$minutes minute${minutes > 1 ? 's' : ''}' : ''}';
    } else {
      return '$minutes minute${minutes > 1 ? 's' : ''}';
    }
  }
}
