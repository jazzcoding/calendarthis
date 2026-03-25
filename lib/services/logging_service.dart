import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A simple logging service that works in both debug and release modes
class LoggingService {
  static final LoggingService _instance = LoggingService._internal();
  
  factory LoggingService() {
    return _instance;
  }
  
  LoggingService._internal();
  
  static const String _logKey = 'app_logs';
  static const int _maxLogEntries = 100;
  
  List<String> _logs = [];
  bool _initialized = false;
  
  /// Initialize the logging service
  Future<void> init() async {
    if (_initialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      _logs = prefs.getStringList(_logKey) ?? [];
      _initialized = true;
    } catch (e) {
      // If we can't initialize, just continue with empty logs
      _logs = [];
      _initialized = true;
    }
  }
  
  /// Log a message with a tag
  Future<void> log(String tag, String message) async {
    await init();
    
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = '$timestamp [$tag] $message';
    
    // Always print in debug mode
    if (kDebugMode) {
      print(logEntry);
    }
    
    // Add to in-memory log
    _logs.add(logEntry);
    
    // Trim logs if they get too long
    if (_logs.length > _maxLogEntries) {
      _logs = _logs.sublist(_logs.length - _maxLogEntries);
    }
    
    // Save logs to persistent storage
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_logKey, _logs);
    } catch (e) {
      // If we can't save, just continue
    }
  }
  
  /// Get all logs
  Future<List<String>> getLogs() async {
    await init();
    return List.from(_logs);
  }
  
  /// Clear all logs
  Future<void> clearLogs() async {
    await init();
    _logs.clear();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_logKey);
    } catch (e) {
      // If we can't clear, just continue
    }
  }
}
