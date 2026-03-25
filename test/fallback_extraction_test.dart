import 'package:flutter_test/flutter_test.dart';
import 'package:calendar_this/services/text_extraction_service_impl.dart';

void main() {
  group('Fallback Extraction Tests', () {
    test('Fallback to basic extraction when AI is disabled', () async {
      final service = TextExtractionServiceImpl();
      
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

      // Extract event details with AI disabled
      final result = await service.extractEventDetails(sampleText, useAI: false);
      
      // Verify that the extraction returned the original text
      expect(result.rawText, equals(sampleText));
      
      // Verify that the extraction was successful
      expect(result.extractedData, isNotEmpty);
      
      // Check for expected fields
      expect(result.extractedData['title'], equals('New Event'));
      expect(result.extractedData['description'], equals(sampleText));
    });
  });
}
