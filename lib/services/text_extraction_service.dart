import '../models/event_model.dart';
import 'openrouter_service.dart';

// Result of text extraction with confidence levels
class ExtractionResult {
  final String rawText;
  final Map<String, dynamic> extractedData;
  final Map<String, double> confidenceScores;

  ExtractionResult({
    required this.rawText,
    required this.extractedData,
    required this.confidenceScores,
  });

  // Convert to an event model
  EventModel toEventModel() {
    return EventModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: extractedData['title'] ?? 'New Event',
      description: extractedData['description'] ?? '',
      startTime: extractedData['startTime'] ?? DateTime.now(),
      endTime: extractedData['endTime'] ??
          DateTime.now().add(const Duration(hours: 1)),
      location: extractedData['location'] ?? '',
      attendees: extractedData['attendees'] ?? [],
      isAllDay: false,
      reminderMinutes: 30,
      originalText: rawText, // Store the original text
    );
  }
}

// Simple text extraction service that uses OpenRouter API
class TextExtractionService {
  final OpenRouterService _openRouterService = OpenRouterService();

  // Extract event details from text
  Future<ExtractionResult> extractEventDetails(String text,
      {bool? useAI}) async {
    try {
      // Default to true if not specified
      final shouldUseAI = useAI ?? true;

      if (!shouldUseAI) {
        // If AI is disabled, return a basic result
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
      final extractedData = await _openRouterService.extractEventDetails(text);

      // Check if there was an error in extraction
      if (extractedData.containsKey('error') &&
          extractedData['error'] == true) {
        throw Exception(extractedData['message'] ?? 'AI extraction failed');
      }

      // Create confidence scores map
      final Map<String, double> confidenceScores = {};

      // Process extracted data and set confidence scores
      for (final key in extractedData.keys) {
        if (extractedData[key] != null && key != 'error' && key != 'message') {
          confidenceScores[key] = 0.9; // High confidence with AI
        }
      }

      return ExtractionResult(
        rawText: text,
        extractedData: extractedData,
        confidenceScores: confidenceScores,
      );
    } catch (e) {
      // Return error result
      return ExtractionResult(
        rawText: text,
        extractedData: {
          'title': 'Extraction Error',
          'description':
              'Failed to extract details. Please try again or enter details manually.',
        },
        confidenceScores: {
          'title': 1.0,
          'description': 1.0,
        },
      );
    }
  }

  // Check if OpenRouter API key is set
  Future<bool> hasApiKey() async {
    return await _openRouterService.hasApiKey();
  }

  // Save OpenRouter API key
  Future<void> saveApiKey(String apiKey) async {
    await _openRouterService.saveApiKey(apiKey);
  }

  // Get available free AI models
  Future<List<Map<String, dynamic>>> getAvailableFreeModels() async {
    return await _openRouterService.getFreeModels();
  }
}
