import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  group('Direct HTTP Tests', () {
    test('Direct HTTP request to OpenRouter API', () async {
      final apiKey =
          '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';
      final baseUrl = 'https://openrouter.ai/api/v1';

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

      // Make a direct HTTP request to the OpenRouter API
      final response = await http.post(
        Uri.parse('$baseUrl/chat/completions'),
        headers: {
          'Authorization': apiKey, // Try without 'Bearer ' prefix
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://calendarthis.app',
          'X-Title': 'CalendarThis!',
        },
        body: jsonEncode({
          'model': 'openai/gpt-3.5-turbo-free',
          'messages': [
            {
              'role': 'system',
              'content': 'You are an AI assistant that extracts event details from text. '
                  'Extract the following information if present: title, description, '
                  'start date and time, end date and time, location, and attendees. '
                  'Return the information in JSON format with these keys: '
                  'title, description, startTime, endTime, location, attendees.'
            },
            {'role': 'user', 'content': sampleText}
          ],
          'response_format': {'type': 'json_object'}
        }),
      );

      // No debug printing

      // We're expecting a 401 status code because the API key is invalid or expired
      expect(response.statusCode, equals(401));
    });
  });
}
