import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'cache_service.dart';
import 'logging_service.dart';

/// Service for interacting with OpenRouter API to access free AI models
class OpenRouterService {
  static const String _baseUrl = 'https://openrouter.ai/api/v1';
  static const String _apiKeyStorageKey = 'openrouter_api_key';
  static const String _defaultApiKey =
      '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';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Cache for API responses
  final CacheService<String, dynamic> _modelsCache =
      CacheService<String, dynamic>(maxSize: 5, ttlMs: 3600000); // 1 hour TTL
  final CacheService<String, Map<String, dynamic>> _extractionCache =
      CacheService<String, Map<String, dynamic>>(
          maxSize: 50, ttlMs: 1800000); // 30 minutes TTL

  /// Get the API key - returns custom key if set, otherwise returns default key
  Future<String?> getApiKey() async {
    try {
      // Try to get custom API key from secure storage
      final customKey = await _secureStorage.read(key: _apiKeyStorageKey);

      final apiKey = (customKey != null && customKey.isNotEmpty)
          ? customKey
          : _defaultApiKey;

      // Return custom key if it exists, otherwise return default key
      return apiKey;
    } catch (e) {
      // Return default key if there's an error accessing secure storage
      return _defaultApiKey;
    }
  }

  /// Save the API key
  Future<void> saveApiKey(String apiKey) async {
    try {
      await _secureStorage.write(key: _apiKeyStorageKey, value: apiKey);
    } catch (e) {
      // Silently handle error
    }
  }

  /// Delete the API key
  Future<void> deleteApiKey() async {
    try {
      await _secureStorage.delete(key: _apiKeyStorageKey);
    } catch (e) {
      // Silently handle error
    }
  }

  /// Check if API key is set - always returns true since we have a default key
  Future<bool> hasApiKey() async {
    return true;
  }

  /// Check if a custom API key is set (different from default)
  Future<bool> hasCustomApiKey() async {
    try {
      final customKey = await _secureStorage.read(key: _apiKeyStorageKey);
      return customKey != null && customKey.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get available models from OpenRouter
  Future<List<Map<String, dynamic>>> getAvailableModels() async {
    try {
      // Check cache first
      final cachedModels = _modelsCache.get('available_models');
      if (cachedModels != null) {
        return List<Map<String, dynamic>>.from(cachedModels);
      }

      final apiKey = await getApiKey();

      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API key not set');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/models'),
        headers: {
          'Authorization': 'Bearer $apiKey', // With Bearer prefix
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final models = List<Map<String, dynamic>>.from(data['data'] ?? []);

        // Update cache
        _modelsCache.put('available_models', models);

        return models;
      } else if (response.statusCode == 401) {
        // Handle authentication error gracefully
        return []; // Return empty list instead of throwing an exception
      } else {
        throw Exception('Failed to load models: ${response.statusCode}');
      }
    } catch (e) {
      return [];
    }
  }

  /// Get free models from OpenRouter
  Future<List<Map<String, dynamic>>> getFreeModels() async {
    final models = await getAvailableModels();
    return models.where((model) => model['pricing']['prompt'] == 0).toList();
  }

  /// Extract event details from text using AI
  Future<Map<String, dynamic>> extractEventDetails(String text,
      {String? modelId}) async {
    final loggingService = LoggingService();
    await loggingService.init(); // Ensure logging service is initialized

    try {
      // Use DeepSeek free model by default unless explicitly overridden
      final model = modelId ?? 'deepseek/deepseek-coder';
      final cacheKey = '${text.hashCode}_$model';

      await loggingService.log(
          'API', 'Starting extraction with text length: ${text.length}');

      // Check cache first
      final cachedResult = _extractionCache.get(cacheKey);
      if (cachedResult != null) {
        await loggingService.log('API', 'Using cached extraction result');
        return cachedResult;
      }

      final apiKey = await getApiKey();
      await loggingService.log(
          'API', 'API key retrieved (${apiKey != null ? "not null" : "null"})');

      if (apiKey == null || apiKey.isEmpty) {
        await loggingService.log('ERROR', 'API key is null or empty');
        return {
          'error': true,
          'message': 'API key not set',
          'title': 'New Event',
          'description': text
        };
      }

      // Log the API call attempt for debugging
      await loggingService.log(
          'API', 'Attempting OpenRouter API call with model: $model');

      try {
        // Create the request body
        final requestBody = {
          'model': model,
          'messages': [
            {
              'role': 'system',
              'content': 'You are an AI assistant that extracts event details from text. '
                  'Extract the following information if present: title, description, '
                  'start date and time, end date and time, location, and attendees. '
                  'Return the information in JSON format with these keys: '
                  'title, description, startTime, endTime, location, attendees. '
                  'Important guidelines:\n'
                  '1. For dates, use ISO format (YYYY-MM-DDTHH:MM:SS) for precise datetime extraction\n'
                  '2. For times, use 24-hour format in the ISO string\n'
                  '3. If no end date is specified, do not include endTime in the response\n'
                  '4. If no specific start time is mentioned, only include the date in startTime\n'
                  '5. If the text is ambiguous, make reasonable assumptions based on context\n'
                  '6. If information is completely missing, omit that field from the JSON\n'
                  '7. For title, extract a concise event title that summarizes the event\n'
                  '8. For location, extract the full location details including address if available\n'
                  '9. For attendees, return an array of names or email addresses\n'
                  '10. If the text mentions "tomorrow", "next week", etc., convert to actual dates\n'
                  '11. Always include a title field, even if you have to generate one based on the content'
            },
            {'role': 'user', 'content': text}
          ],
          'response_format': {'type': 'json_object'}
        };

        final requestBodyJson = jsonEncode(requestBody);
        await loggingService.log('API', 'Request body prepared');

        // Try with Bearer prefix and a space
        final response = await http.post(
          Uri.parse('$_baseUrl/chat/completions'),
          headers: {
            'Authorization': 'Bearer $apiKey', // With Bearer prefix
            'Content-Type': 'application/json',
            'HTTP-Referer': 'https://calendarthis.app',
            'X-Title': 'CalendarThis!',
          },
          body: requestBodyJson,
        );

        await loggingService.log(
            'API', 'Response status code: ${response.statusCode}');

        if (response.statusCode == 200) {
          await loggingService.log('API', 'Received 200 OK response');

          try {
            final data = jsonDecode(response.body);
            await loggingService.log(
                'API', 'Response body parsed successfully');

            if (data.containsKey('choices') &&
                data['choices'] is List &&
                data['choices'].isNotEmpty &&
                data['choices'][0].containsKey('message') &&
                data['choices'][0]['message'].containsKey('content')) {
              final content = data['choices'][0]['message']['content'];
              await loggingService.log(
                  'API', 'Content extracted from response');

              // Parse the JSON content from the response
              try {
                // DeepSeek model often returns JSON wrapped in markdown code blocks
                // Remove markdown formatting if present
                String cleanContent = content;
                if (content.trim().startsWith('```json') || content.trim().startsWith('```')) {
                  // Extract content between markdown code blocks
                  final startIndex = content.indexOf('{');
                  final endIndex = content.lastIndexOf('}') + 1;

                  if (startIndex >= 0 && endIndex > startIndex) {
                    cleanContent = content.substring(startIndex, endIndex);
                  }
                }

                final result = jsonDecode(cleanContent);
                await loggingService.log(
                    'API', 'JSON content parsed successfully');

                // Ensure title is present
                if (!result.containsKey('title') || result['title'] == null) {
                  result['title'] = 'New Event';
                  await loggingService.log(
                      'API', 'Added default title to result');
                }

                // Update cache
                _extractionCache.put(cacheKey, result);
                await loggingService.log('API', 'Result cached successfully');

                return result;
              } catch (jsonError) {
                await loggingService.log(
                    'ERROR', 'Error parsing JSON content: $jsonError');
                await loggingService.log(
                    'ERROR', 'Content that failed to parse: $content');
                return {
                  'error': true,
                  'message': 'Failed to parse AI response: $jsonError',
                  'title': 'New Event',
                  'description': text
                };
              }
            } else {
              await loggingService.log(
                  'ERROR', 'Unexpected response structure: ${response.body}');
              return {
                'error': true,
                'message': 'Unexpected API response structure',
                'title': 'New Event',
                'description': text
              };
            }
          } catch (parseError) {
            await loggingService.log(
                'ERROR', 'Error parsing response body: $parseError');
            await loggingService.log(
                'ERROR', 'Response body: ${response.body}');
            return {
              'error': true,
              'message': 'Failed to parse API response: $parseError',
              'title': 'New Event',
              'description': text
            };
          }
        } else if (response.statusCode == 401) {
          // Handle authentication error - API key might be invalid or expired
          await loggingService.log(
              'ERROR', 'Authentication error: Invalid or expired API key');
          return {
            'error': true,
            'message': 'API key is invalid or expired.',
            'title': 'New Event',
            'description': text
          };
        } else {
          // Get error message from response if available
          String errorMessage =
              'Failed to extract event details: ${response.statusCode}';
          try {
            final errorData = jsonDecode(response.body);
            await loggingService.log(
                'ERROR', 'Error response body: ${response.body}');

            if (errorData.containsKey('error')) {
              if (errorData['error'] is Map) {
                errorMessage = errorData['error']['message'] ?? errorMessage;
              } else if (errorData['error'] is String) {
                errorMessage = errorData['error'];
              }
            }
            await loggingService.log('ERROR', 'API error: $errorMessage');
          } catch (parseError) {
            // If we can't parse the error response, use the default message
            await loggingService.log(
                'ERROR', 'Could not parse error response: $parseError');
            await loggingService.log(
                'ERROR', 'Error response body: ${response.body}');
          }

          return {
            'error': true,
            'message': errorMessage,
            'title': 'New Event',
            'description': text
          };
        }
      } catch (httpError) {
        // Handle HTTP errors
        await loggingService.log('ERROR', 'HTTP error: $httpError');
        return {
          'error': true,
          'message': 'Network error: $httpError',
          'title': 'New Event',
          'description': text
        };
      }
    } catch (e) {
      // Return error result
      final errorMessage = e.toString().replaceAll('Exception: ', '');

      // Log the error
      await loggingService.log('ERROR', 'Text extraction error: $errorMessage');

      return {
        'error': true,
        'message': errorMessage,
        'title': 'New Event',
        'description': text
      };
    }
  }

  /// Clean expired cache entries
  void cleanCache() {
    _modelsCache.cleanExpired();
    _extractionCache.cleanExpired();
  }

  /// Test connection to OpenRouter API
  /// This is used for diagnostics to verify network connectivity
  Future<http.Response> testConnection() async {
    try {
      final apiKey = await getApiKey();
      // Make a simple GET request to the models endpoint
      return await http.get(
        Uri.parse('$_baseUrl/models'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      );
    } catch (e) {
      // If the request fails, create a fake response with the error
      return http.Response(
        '{"error": true, "message": "Connection failed: $e"}',
        0, // Status code 0 indicates a connection failure
      );
    }
  }
}
