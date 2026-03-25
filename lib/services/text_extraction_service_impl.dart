import 'dart:io';
import 'text_extraction_service.dart';
import 'openrouter_service.dart';
import 'logging_service.dart';

/// Implementation of the text extraction service that uses OpenRouter API with DeepSeek free model
class TextExtractionServiceImpl {
  final OpenRouterService _openRouterService = OpenRouterService();

  // Flag to control AI usage - public for direct access
  bool useAI = true;

  /// Extract event details from text using AI
  Future<ExtractionResult> extractEventDetails(String text,
      {bool? useAI}) async {
    final loggingService = LoggingService();
    await loggingService.init(); // Ensure logging service is initialized

    try {
      await loggingService.log('APP', 'Starting text extraction process');

      // Use the parameter if provided, otherwise use the class field
      final shouldUseAI = useAI ?? this.useAI;
      await loggingService.log('APP', 'Using AI: $shouldUseAI');

      if (!shouldUseAI) {
        // If AI is disabled, return a basic result
        await loggingService.log('APP', 'AI disabled, using basic extraction');
        return ExtractionResult(
          rawText: text,
          extractedData: {
            'title': 'New Event',
            'description': text,
          },
          confidenceScores: {
            'title': 0.5,
            'description': 0.5,
          },
        );
      }

      // Call OpenRouter API to extract event details
      await loggingService.log('APP', 'Calling OpenRouter API');
      final extractedData = await _openRouterService.extractEventDetails(text);
      await loggingService.log('APP', 'OpenRouter API call completed');

      // Check if there was an error in extraction
      if (extractedData.containsKey('error') &&
          extractedData['error'] == true) {
        // Always fall back to basic extraction instead of throwing an error
        // This provides a better user experience
        final errorMessage = extractedData['message'] ?? 'Unknown error';
        await loggingService.log(
            'ERROR', 'API extraction error: $errorMessage');

        return ExtractionResult(
          rawText: text,
          extractedData: {
            'title': 'New Event',
            'description': text,
            'error': true,
            'message': errorMessage,
          },
          confidenceScores: {
            'title': 0.5,
            'description': 0.5,
          },
        );
      }

      // Process dates if they are strings
      await loggingService.log('APP', 'Processing extracted data');
      final processedData = _processExtractedData(extractedData);

      // Create confidence scores map
      final Map<String, double> confidenceScores = {};

      // Process extracted data and set confidence scores
      for (final key in processedData.keys) {
        if (processedData[key] != null && key != 'error' && key != 'message') {
          confidenceScores[key] = 0.9; // High confidence with AI
        }
      }

      await loggingService.log('APP', 'Extraction completed successfully');
      return ExtractionResult(
        rawText: text,
        extractedData: processedData,
        confidenceScores: confidenceScores,
      );
    } catch (e) {
      // Log the error
      await loggingService.log('ERROR', 'Exception during extraction: $e');

      // Return error result
      return ExtractionResult(
        rawText: text,
        extractedData: {
          'title': 'Extraction Error',
          'description':
              'Failed to extract details. Please try again or enter details manually.',
          'error': true,
          'message': e.toString(),
        },
        confidenceScores: {
          'title': 1.0,
          'description': 1.0,
        },
      );
    }
  }

  /// Process extracted data to convert string dates to DateTime objects
  Map<String, dynamic> _processExtractedData(Map<String, dynamic> data) {
    final result = Map<String, dynamic>.from(data);

    // Process startTime if it's a string
    if (result.containsKey('startTime') && result['startTime'] is String) {
      try {
        final startTimeStr = result['startTime'] as String;
        result['startTime'] = _parseDateTime(startTimeStr);
      } catch (e) {
        // If parsing fails, remove the key
        result.remove('startTime');
      }
    }

    // Process endTime if it's a string
    if (result.containsKey('endTime') && result['endTime'] is String) {
      try {
        final endTimeStr = result['endTime'] as String;
        result['endTime'] = _parseDateTime(endTimeStr);
      } catch (e) {
        // If parsing fails, remove the key
        result.remove('endTime');
      }
    }

    // Ensure attendees is a list
    if (result.containsKey('attendees')) {
      if (result['attendees'] is String) {
        // If attendees is a string, split it by commas
        final attendeesStr = result['attendees'] as String;
        result['attendees'] =
            attendeesStr.split(',').map((e) => e.trim()).toList();
      } else if (result['attendees'] is! List) {
        // If attendees is not a list or string, set it to an empty list
        result['attendees'] = <String>[];
      }
    }

    return result;
  }

  /// Parse a date string into a DateTime object
  DateTime _parseDateTime(String dateStr) {
    // Try different date formats
    final formats = [
      // ISO format
      RegExp(r'(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2})'),
      // ISO format without seconds
      RegExp(r'(\d{4}-\d{2}-\d{2}T\d{2}:\d{2})'),
      // ISO date only
      RegExp(r'(\d{4}-\d{2}-\d{2})'),
      // MM/DD/YYYY HH:MM
      RegExp(r'(\d{1,2}/\d{1,2}/\d{4}\s+\d{1,2}:\d{1,2})'),
      // MM/DD/YYYY
      RegExp(r'(\d{1,2}/\d{1,2}/\d{4})'),
    ];

    // Try to match each format
    for (final format in formats) {
      final match = format.firstMatch(dateStr);
      if (match != null) {
        try {
          if (dateStr.contains('T')) {
            // Parse ISO format
            return DateTime.parse(dateStr);
          } else if (dateStr.contains('/')) {
            // Parse MM/DD/YYYY format
            final parts = dateStr.split(' ');
            final dateParts = parts[0].split('/');

            int month = int.parse(dateParts[0]);
            int day = int.parse(dateParts[1]);
            int year = int.parse(dateParts[2]);

            if (parts.length > 1 && parts[1].contains(':')) {
              // Has time component
              final timeParts = parts[1].split(':');
              int hour = int.parse(timeParts[0]);
              int minute = int.parse(timeParts[1]);

              // Check for AM/PM
              if (parts.length > 2) {
                final ampm = parts[2].toLowerCase();
                if (ampm == 'pm' && hour < 12) {
                  hour += 12;
                } else if (ampm == 'am' && hour == 12) {
                  hour = 0;
                }
              }

              return DateTime(year, month, day, hour, minute);
            } else {
              // Date only
              return DateTime(year, month, day);
            }
          }
        } catch (e) {
          // Silently continue to the next format
        }
      }
    }

    // If all parsing attempts fail, try a more flexible approach
    try {
      // Check for common date words
      final now = DateTime.now();

      if (dateStr.toLowerCase().contains('today')) {
        return now;
      } else if (dateStr.toLowerCase().contains('tomorrow')) {
        return now.add(const Duration(days: 1));
      } else if (dateStr.toLowerCase().contains('next week')) {
        return now.add(const Duration(days: 7));
      }

      // If nothing works, return current date/time
      return now;
    } catch (e) {
      return DateTime.now();
    }
  }

  /// Extract text from an image (disabled)
  Future<ExtractionResult> extractFromImage(File imageFile) async {
    // Camera extraction is completely disabled
    return ExtractionResult(
      rawText: 'Camera extraction is disabled',
      extractedData: {
        'title': 'Camera Extraction Disabled',
        'description':
            'Camera extraction has been disabled. Please enter text manually.',
        'error': true,
        'message': 'Camera extraction has been disabled by administrator.',
      },
      confidenceScores: {
        'title': 1.0,
        'description': 1.0,
      },
    );
  }

  /// Check if OpenRouter API key is set
  Future<bool> hasApiKey() async {
    return await _openRouterService.hasApiKey();
  }

  /// Save OpenRouter API key
  Future<void> saveApiKey(String apiKey) async {
    await _openRouterService.saveApiKey(apiKey);
  }

  /// Get available free AI models
  Future<List<Map<String, dynamic>>> getAvailableFreeModels() async {
    return await _openRouterService.getFreeModels();
  }

  /// Clean cache - called periodically to free up memory
  void cleanCache() {
    // Forward to OpenRouter service
    _openRouterService.cleanCache();
  }

  /// Dispose resources
  void dispose() {
    // Nothing to dispose in this implementation
  }
}
