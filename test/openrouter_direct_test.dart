import 'package:flutter_test/flutter_test.dart';
import 'package:calendar_this/services/openrouter_service.dart';
import 'package:calendar_this/services/logging_service.dart';
import 'dart:convert';

void main() {
  group('OpenRouter API Tests', () {
    late OpenRouterService service;
    late LoggingService loggingService;

    setUp(() {
      service = OpenRouterService();
      loggingService = LoggingService();
      loggingService.init();
    });

    test('API Key is accessible', () async {
      final apiKey = await service.getApiKey();
      await loggingService.log(
          'TEST', 'API Key available: ${apiKey != null && apiKey.isNotEmpty}');
      expect(apiKey, isNotNull);
      expect(apiKey!.isNotEmpty, true);
    });

    test('Extract event details with simple text', () async {
      // Simple text that should be easy to parse
      final simpleText = 'Meeting with John tomorrow at 3pm at Coffee Shop';

      try {
        // Call the OpenRouter API directly
        final result = await service.extractEventDetails(simpleText);

        // Log the result for debugging
        await loggingService.log(
            'TEST', 'Simple text API result: ${jsonEncode(result)}');

        // Check if there was an error
        if (result.containsKey('error') && result['error'] == true) {
          await loggingService.log(
              'TEST', 'Error message: ${result['message']}');
          fail('API returned an error: ${result['message']}');
        }

        // Verify that the extraction was successful
        expect(result, isNotEmpty);
        expect(result['title'], isNotNull);
      } catch (e) {
        await loggingService.log('ERROR', 'Exception during API call: $e');
        fail('Exception during API call: $e');
      }
    });

    test('Extract event details from structured text', () async {
      final sampleText = '''🌿 Spring Gathering: Community & Connection 🌿

We're bringing the neighborhood together for a relaxing afternoon of good vibes, open conversations, and meaningful moments.

📅 Date: Sunday, May 5
🕓 Time: 4:00 PM – 8:00 PM
📍 Location: Willow Park, under the big oak tree
✨ Expect: acoustic live music, tea + snack stations, open mic, and cozy picnic spots.

Bring a blanket, your favorite mug, and your open heart. 💛 This is a space to connect, create, and just be.

🎟️ Free & open to all – families, friends, and furry companions welcome!

Let's slow down and reconnect with what matters. 🌼
#SpringGathering2025 #CommunityVibes''';

      try {
        // Call the OpenRouter API directly
        final result = await service.extractEventDetails(sampleText);

        // Log the result for debugging
        await loggingService.log('TEST',
            'Structured text API result length: ${jsonEncode(result).length}');

        // Check if there was an error
        if (result.containsKey('error') && result['error'] == true) {
          await loggingService.log(
              'TEST', 'Error message: ${result['message']}');
          fail('API returned an error: ${result['message']}');
        }

        // Verify that the extraction was successful
        expect(result, isNotEmpty);
        expect(result['title'], isNotNull);
        expect(result['location'], isNotNull);
      } catch (e) {
        await loggingService.log('ERROR', 'Exception during API call: $e');
        fail('Exception during API call: $e');
      }
    });

    test('Network request to OpenRouter base URL works', () async {
      try {
        // Make a simple GET request to the OpenRouter base URL
        final response = await service.testConnection();

        await loggingService.log(
            'TEST', 'Connection test status code: ${response.statusCode}');

        // Even if we get a 401 or other error, the network connection works
        // We just want to make sure we can reach the server
        expect(response.statusCode, isNot(equals(0)));
      } catch (e) {
        await loggingService.log('ERROR', 'Network connection failed: $e');
        fail('Network connection failed: $e');
      }
    });
  });
}
