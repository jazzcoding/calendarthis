# CalendarThis!

CalendarThis! is a Flutter app that extracts event details from messages/images to create calendar events across different platforms.

## Features

- Extract event details from text messages, emails, and other text content
- Android context menu integration for selecting text in any app
- Share text from any app to extract event details
- Create calendar events on device and third-party calendars
- AI-powered text understanding for improved accuracy
- Intelligent form auto-fill with confidence indicators
- User-friendly interface for editing and confirming event details
- View and manage events in a list or calendar view

## AI Integration

CalendarThis! uses OpenRouter to access free AI models for enhanced text understanding capabilities:

- **Improved Accuracy**: AI models understand context and extract information more accurately than regex patterns
- **Better Language Support**: AI can handle different languages and formats
- **Higher Confidence**: AI extraction provides higher confidence scores for extracted data
- **Fallback Mechanism**: If AI fails or is unavailable, the app falls back to regex-based extraction

### Setting Up OpenRouter

1. Create an account at [OpenRouter](https://openrouter.ai/)
2. Get your API key from the dashboard
3. In the app, go to Settings > AI Settings > OpenRouter API Key
4. Enter your API key and save

## Android Context Menu Integration

CalendarThis! now supports Android's context menu integration, allowing users to select text in any app and extract event details directly.

### How to Test Android Context Menu Integration

1. Install the app on an Android device
2. Open any app that contains text (e.g., Messages, Email, Browser)
3. Select text that contains event details (e.g., "Meeting with John tomorrow at 3 PM")
4. Tap on the three dots in the context menu
5. Select "CalendarThis!" from the menu
6. The app will open and automatically extract event details from the selected text
7. Review and edit the extracted details if needed
8. Tap "Create Event" to add the event to your calendar

### Share Intent Integration

You can also share text from any app to CalendarThis!:

1. In any app, select text or use the share button
2. Choose "Share" from the menu
3. Select "CalendarThis!" from the share sheet
4. The app will open and process the shared text

## Getting Started

### Prerequisites

- Flutter SDK (version 3.6.2 or higher)
- Dart SDK (version 3.0.0 or higher)
- Android Studio or VS Code with Flutter extensions

### Installation

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Connect a device or start an emulator
4. Run `flutter run` to start the app

## Dependencies

- **State Management**: provider, flutter_bloc
- **Calendar Integration**: device_calendar, add_2_calendar
- **OCR and Text Processing**: ~~google_ml_kit, flutter_tesseract_ocr~~ (removed due to compatibility issues)
- **AI Integration**: http, flutter_secure_storage
- **UI Components**: flutter_form_builder, intl
- **Storage**: shared_preferences, sqflite

## License

This project is licensed under the MIT License - see the LICENSE file for details.
