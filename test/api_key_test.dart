import 'package:flutter_test/flutter_test.dart';
import 'package:calendar_this/services/openrouter_service.dart';

void main() {
  group('OpenRouter API Key Tests', () {
    test('API key is valid and can fetch models', () async {
      final service = OpenRouterService();
      
      // Try to fetch available models - this will test if the API key works
      final models = await service.getAvailableModels();
      
      // If the API key is valid, we should get a non-empty list of models
      expect(models, isNotEmpty);
    });
  });
}
