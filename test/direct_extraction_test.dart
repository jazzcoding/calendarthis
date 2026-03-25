import 'package:flutter_test/flutter_test.dart';
import 'package:calendar_this/services/openrouter_service.dart';

void main() {
  group('Direct Extraction Tests', () {
    test('Extract event details directly from OpenRouter API', () async {
      final service = OpenRouterService();
      
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

      // Call the OpenRouter API directly
      final result = await service.extractEventDetails(sampleText);
      
      // Print the result for debugging
      print('Direct API result: $result');
      
      // Check if there was an error
      if (result.containsKey('error') && result['error'] == true) {
        print('Error message: ${result['message']}');
        fail('API returned an error: ${result['message']}');
      }
      
      // Verify that the extraction was successful
      expect(result, isNotEmpty);
      expect(result['title'], isNotNull);
      expect(result['title'], contains('Spring'));
    });
  });
}
