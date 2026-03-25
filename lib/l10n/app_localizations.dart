import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'CalendarThis!'**
  String get appTitle;

  /// No description provided for @extractFromText.
  ///
  /// In en, this message translates to:
  /// **'Extract from Text'**
  String get extractFromText;

  /// No description provided for @scanFromImage.
  ///
  /// In en, this message translates to:
  /// **'Scan from Image'**
  String get scanFromImage;

  /// No description provided for @createNewEvent.
  ///
  /// In en, this message translates to:
  /// **'Create New Event'**
  String get createNewEvent;

  /// No description provided for @viewMyEvents.
  ///
  /// In en, this message translates to:
  /// **'View My Events'**
  String get viewMyEvents;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @enterOrPasteText.
  ///
  /// In en, this message translates to:
  /// **'Enter or paste text'**
  String get enterOrPasteText;

  /// No description provided for @pasteTextHint.
  ///
  /// In en, this message translates to:
  /// **'Paste an email, message, or any text containing event details...'**
  String get pasteTextHint;

  /// No description provided for @pasteFromClipboard.
  ///
  /// In en, this message translates to:
  /// **'Paste from Clipboard'**
  String get pasteFromClipboard;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @extractEventDetails.
  ///
  /// In en, this message translates to:
  /// **'Extract Event Details'**
  String get extractEventDetails;

  /// No description provided for @extractEventDetailsWithAI.
  ///
  /// In en, this message translates to:
  /// **'Extract Event Details with AI'**
  String get extractEventDetailsWithAI;

  /// No description provided for @extractingEventDetails.
  ///
  /// In en, this message translates to:
  /// **'Extracting event details...'**
  String get extractingEventDetails;

  /// No description provided for @extractingEventDetailsWithAI.
  ///
  /// In en, this message translates to:
  /// **'Extracting event details with AI...'**
  String get extractingEventDetailsWithAI;

  /// No description provided for @usingOpenRouterAI.
  ///
  /// In en, this message translates to:
  /// **'Using OpenRouter AI for better accuracy'**
  String get usingOpenRouterAI;

  /// No description provided for @extractedEventDetails.
  ///
  /// In en, this message translates to:
  /// **'Extracted Event Details'**
  String get extractedEventDetails;

  /// No description provided for @eventTitle.
  ///
  /// In en, this message translates to:
  /// **'Event Title'**
  String get eventTitle;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @dateAndTime.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get dateAndTime;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get startTime;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get endTime;

  /// No description provided for @attendees.
  ///
  /// In en, this message translates to:
  /// **'Attendees'**
  String get attendees;

  /// No description provided for @createEvent.
  ///
  /// In en, this message translates to:
  /// **'Create Event'**
  String get createEvent;

  /// No description provided for @editSourceText.
  ///
  /// In en, this message translates to:
  /// **'Edit Source Text'**
  String get editSourceText;

  /// No description provided for @eventCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Event created successfully!'**
  String get eventCreatedSuccessfully;

  /// No description provided for @failedToCreateEvent.
  ///
  /// In en, this message translates to:
  /// **'Failed to create event. Please try again.'**
  String get failedToCreateEvent;

  /// No description provided for @errorCreatingEvent.
  ///
  /// In en, this message translates to:
  /// **'Error creating event: {error}'**
  String errorCreatingEvent(String error);

  /// No description provided for @errorPreparingEvent.
  ///
  /// In en, this message translates to:
  /// **'Error preparing event: {error}'**
  String errorPreparingEvent(String error);

  /// No description provided for @calendarPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Calendar permission is required to create events.'**
  String get calendarPermissionRequired;

  /// No description provided for @noCalendarsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No calendars available. Please add a calendar to your device.'**
  String get noCalendarsAvailable;

  /// No description provided for @usingCalendar.
  ///
  /// In en, this message translates to:
  /// **'Using calendar: {calendarName}'**
  String usingCalendar(String calendarName);

  /// No description provided for @takePicture.
  ///
  /// In en, this message translates to:
  /// **'Take Picture'**
  String get takePicture;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @extractText.
  ///
  /// In en, this message translates to:
  /// **'Extract Text'**
  String get extractText;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @scanDocument.
  ///
  /// In en, this message translates to:
  /// **'Scan Document'**
  String get scanDocument;

  /// No description provided for @takePictureOrSelectImage.
  ///
  /// In en, this message translates to:
  /// **'Take a picture or select an image\ncontaining event details'**
  String get takePictureOrSelectImage;

  /// No description provided for @processingImage.
  ///
  /// In en, this message translates to:
  /// **'Processing image...'**
  String get processingImage;

  /// No description provided for @cameraPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required to use this feature.'**
  String get cameraPermissionRequired;

  /// No description provided for @pleaseSelectImage.
  ///
  /// In en, this message translates to:
  /// **'Please take or select an image first.'**
  String get pleaseSelectImage;

  /// No description provided for @errorTakingPicture.
  ///
  /// In en, this message translates to:
  /// **'Error taking picture: {error}'**
  String errorTakingPicture(String error);

  /// No description provided for @errorPickingImage.
  ///
  /// In en, this message translates to:
  /// **'Error picking image: {error}'**
  String errorPickingImage(String error);

  /// No description provided for @errorProcessingImage.
  ///
  /// In en, this message translates to:
  /// **'Error processing image: {error}'**
  String errorProcessingImage(String error);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
