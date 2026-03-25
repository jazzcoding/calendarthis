import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:calendar_this/services/text_extraction_service_impl.dart';

void main() {
  group('Text Extraction Tests', () {
    test('TextExtractionServiceImpl is properly initialized', () {
      final service = TextExtractionServiceImpl();

      // This is a basic test to ensure the service can be created without errors
      expect(service, isNotNull);
    });

    test('Image extraction returns appropriate message when camera extraction is disabled',
        () async {
      final service = TextExtractionServiceImpl();
      final tempFile = File('test_file.txt');

      // Test that the service returns a message about camera extraction being disabled
      final result = await service.extractFromImage(tempFile);

      expect(result.rawText, contains('Camera extraction is disabled'));
      expect(result.extractedData['title'], equals('Camera Extraction Disabled'));
    });
  });
}
