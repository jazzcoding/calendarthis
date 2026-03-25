// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CalendarThis!';

  @override
  String get extractFromText => 'Extract from Text';

  @override
  String get scanFromImage => 'Scan from Image';

  @override
  String get createNewEvent => 'Create New Event';

  @override
  String get viewMyEvents => 'View My Events';

  @override
  String get settings => 'Settings';

  @override
  String get enterOrPasteText => 'Enter or paste text';

  @override
  String get pasteTextHint =>
      'Paste an email, message, or any text containing event details...';

  @override
  String get pasteFromClipboard => 'Paste from Clipboard';

  @override
  String get clear => 'Clear';

  @override
  String get extractEventDetails => 'Extract Event Details';

  @override
  String get extractEventDetailsWithAI => 'Extract Event Details with AI';

  @override
  String get extractingEventDetails => 'Extracting event details...';

  @override
  String get extractingEventDetailsWithAI =>
      'Extracting event details with AI...';

  @override
  String get usingOpenRouterAI => 'Using OpenRouter AI for better accuracy';

  @override
  String get extractedEventDetails => 'Extracted Event Details';

  @override
  String get eventTitle => 'Event Title';

  @override
  String get description => 'Description';

  @override
  String get location => 'Location';

  @override
  String get dateAndTime => 'Date & Time';

  @override
  String get startDate => 'Start Date';

  @override
  String get startTime => 'Start Time';

  @override
  String get endDate => 'End Date';

  @override
  String get endTime => 'End Time';

  @override
  String get attendees => 'Attendees';

  @override
  String get createEvent => 'Create Event';

  @override
  String get editSourceText => 'Edit Source Text';

  @override
  String get eventCreatedSuccessfully => 'Event created successfully!';

  @override
  String get failedToCreateEvent => 'Failed to create event. Please try again.';

  @override
  String errorCreatingEvent(String error) {
    return 'Error creating event: $error';
  }

  @override
  String errorPreparingEvent(String error) {
    return 'Error preparing event: $error';
  }

  @override
  String get calendarPermissionRequired =>
      'Calendar permission is required to create events.';

  @override
  String get noCalendarsAvailable =>
      'No calendars available. Please add a calendar to your device.';

  @override
  String usingCalendar(String calendarName) {
    return 'Using calendar: $calendarName';
  }

  @override
  String get takePicture => 'Take Picture';

  @override
  String get gallery => 'Gallery';

  @override
  String get extractText => 'Extract Text';

  @override
  String get processing => 'Processing...';

  @override
  String get scanDocument => 'Scan Document';

  @override
  String get takePictureOrSelectImage =>
      'Take a picture or select an image\ncontaining event details';

  @override
  String get processingImage => 'Processing image...';

  @override
  String get cameraPermissionRequired =>
      'Camera permission is required to use this feature.';

  @override
  String get pleaseSelectImage => 'Please take or select an image first.';

  @override
  String errorTakingPicture(String error) {
    return 'Error taking picture: $error';
  }

  @override
  String errorPickingImage(String error) {
    return 'Error picking image: $error';
  }

  @override
  String errorProcessingImage(String error) {
    return 'Error processing image: $error';
  }
}
