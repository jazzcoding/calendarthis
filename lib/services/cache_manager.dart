import 'package:flutter/foundation.dart';
import 'dart:async';
import 'local_event_service.dart';
import 'text_extraction_service_impl.dart';
import 'openrouter_service.dart';

/// A service to manage all caches in the app
class CacheManager {
  static final CacheManager _instance = CacheManager._internal();
  
  factory CacheManager() {
    return _instance;
  }
  
  CacheManager._internal();
  
  // Services with caches
  final LocalEventService _localEventService = LocalEventService();
  final TextExtractionServiceImpl _textExtractionService = TextExtractionServiceImpl();
  final OpenRouterService _openRouterService = OpenRouterService();
  
  // Timer for periodic cache cleaning
  Timer? _cacheCleanupTimer;
  
  /// Initialize the cache manager
  void init() {
    // Start periodic cache cleanup
    _cacheCleanupTimer = Timer.periodic(const Duration(minutes: 30), (_) {
      cleanAllCaches();
    });
    
    if (kDebugMode) {
      print('Cache manager initialized with 30-minute cleanup interval');
    }
  }
  
  /// Clean all caches in the app
  void cleanAllCaches() {
    if (kDebugMode) {
      print('Starting cache cleanup...');
    }
    
    // Clean event cache
    _localEventService.cleanCache();
    
    // Clean text extraction cache
    _textExtractionService.cleanCache();
    
    // OpenRouter cache is cleaned by the text extraction service
    
    if (kDebugMode) {
      print('Cache cleanup completed');
    }
  }
  
  /// Dispose the cache manager
  void dispose() {
    _cacheCleanupTimer?.cancel();
    _textExtractionService.dispose();
  }
}
