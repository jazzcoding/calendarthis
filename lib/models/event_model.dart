class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final bool isAllDay;
  final List<String> attendees;
  final int reminderMinutes;
  final String
      originalText; // Store the original text that was used to create the event

  EventModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.startTime,
    required this.endTime,
    this.location = '',
    this.isAllDay = false,
    this.attendees = const [],
    this.reminderMinutes = 30,
    this.originalText = '',
  });

  // Create a copy of the event with updated fields
  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    bool? isAllDay,
    List<String>? attendees,
    int? reminderMinutes,
    String? originalText,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      isAllDay: isAllDay ?? this.isAllDay,
      attendees: attendees ?? this.attendees,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      originalText: originalText ?? this.originalText,
    );
  }

  // Convert event to a map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'location': location,
      'isAllDay': isAllDay ? 1 : 0,
      'attendees': attendees.join(','),
      'reminderMinutes': reminderMinutes,
      'originalText': originalText,
    };
  }

  // Create an event from a map
  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime']),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['endTime']),
      location: map['location'] ?? '',
      isAllDay: map['isAllDay'] == 1,
      attendees: map['attendees']?.split(',') ?? [],
      reminderMinutes: map['reminderMinutes'] ?? 30,
      originalText: map['originalText'] ?? '',
    );
  }
}
