import 'dart:async';
import 'package:flutter/services.dart';

class IntentService {
  static const MethodChannel _channel = MethodChannel('com.calendarthis/intent');
  
  // Singleton pattern
  static final IntentService _instance = IntentService._internal();
  factory IntentService() => _instance;
  IntentService._internal();
  
  // Stream controller for received text
  final StreamController<String> _textStreamController = StreamController<String>.broadcast();
  Stream<String> get textStream => _textStreamController.stream;
  
  // Initialize the service
  Future<void> init() async {
    // Set up method call handler
    _channel.setMethodCallHandler(_handleMethodCall);
    
    // Check if app was launched with shared text
    try {
      final String? initialText = await _channel.invokeMethod<String>('getInitialText');
      if (initialText != null && initialText.isNotEmpty) {
        _textStreamController.add(initialText);
      }
    } catch (e) {
      print('Error getting initial text: $e');
    }
  }
  
  // Handle method calls from native code
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'receivedText':
        final String text = call.arguments as String;
        _textStreamController.add(text);
        return true;
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: 'Method ${call.method} not implemented',
        );
    }
  }
  
  // Dispose resources
  void dispose() {
    _textStreamController.close();
  }
}
