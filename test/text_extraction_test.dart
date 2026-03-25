import 'package:flutter_test/flutter_test.dart';
import 'package:calendar_this/services/text_extraction_service_impl.dart';

void main() {
  group('Text Extraction Tests', () {
    test('TextExtractionServiceImpl is properly initialized', () {
      final service = TextExtractionServiceImpl();
      expect(service, isNotNull);
    });
    
    test('Text extraction with AI disabled returns basic result', () async {
      final service = TextExtractionServiceImpl();
      final result = await service.extractEventDetails(
        'Meeting with John tomorrow at 3pm',
        useAI: false
      );
      
      expect(result.rawText, 'Meeting with John tomorrow at 3pm');
      expect(result.extractedData['title'], 'New Event');
      expect(result.extractedData['description'], 'Meeting with John tomorrow at 3pm');
    });
    
    // Note: We can't easily test the AI extraction in a unit test
    // as it requires an actual API call. This would be better tested
    // in an integration test or with mocks.
  });
}
