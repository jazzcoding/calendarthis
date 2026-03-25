import 'package:flutter/material.dart';
import '../models/event_model.dart';

/// Utility class for event-related operations
class EventUtils {
  /// Private constructor to prevent instantiation
  EventUtils._();
  
  /// Converts a list of events to a map of events by day
  static Map<DateTime, List<EventModel>> groupEventsByDay(List<EventModel> events) {
    final eventsByDay = <DateTime, List<EventModel>>{};
    
    for (final event in events) {
      // Create a date key without time
      final dateKey = DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );
      
      if (eventsByDay[dateKey] == null) {
        eventsByDay[dateKey] = [];
      }
      
      eventsByDay[dateKey]!.add(event);
      
      // If the event spans multiple days, add it to each day
      if (!isSameDay(event.startTime, event.endTime)) {
        DateTime currentDay = dateKey.add(const Duration(days: 1));
        final endDay = DateTime(
          event.endTime.year,
          event.endTime.month,
          event.endTime.day,
        );
        
        while (!isSameDay(currentDay, endDay.add(const Duration(days: 1)))) {
          if (eventsByDay[currentDay] == null) {
            eventsByDay[currentDay] = [];
          }
          
          eventsByDay[currentDay]!.add(event);
          currentDay = currentDay.add(const Duration(days: 1));
        }
      }
    }
    
    return eventsByDay;
  }
  
  /// Checks if two dates are the same day
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
  
  /// Returns a color based on the event type or title
  static Color getEventColor(EventModel event) {
    // Simple hash function to generate a consistent color based on the event title
    final hash = event.title.hashCode;
    
    // List of pleasant colors for events
    const colors = [
      Color(0xFF4285F4), // Google Blue
      Color(0xFF34A853), // Google Green
      Color(0xFFFBBC05), // Google Yellow
      Color(0xFFEA4335), // Google Red
      Color(0xFF9C27B0), // Purple
      Color(0xFF3F51B5), // Indigo
      Color(0xFF03A9F4), // Light Blue
      Color(0xFF009688), // Teal
      Color(0xFF8BC34A), // Light Green
      Color(0xFFFF9800), // Orange
    ];
    
    return colors[hash.abs() % colors.length];
  }
}
