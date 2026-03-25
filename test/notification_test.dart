import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:calendar_this/services/notification_service.dart';

// Generate mock classes
@GenerateMocks([Permission, FlutterLocalNotificationsPlugin])
void main() {
  group('NotificationService Tests', () {
    test('NotificationService is a singleton', () {
      final service1 = NotificationService();
      final service2 = NotificationService();
      
      // Verify that both instances are the same
      expect(identical(service1, service2), true);
    });
    
    // Note: These tests are limited because we can't easily mock the permission_handler
    // and flutter_local_notifications plugins in unit tests.
    // For more comprehensive testing, integration tests would be needed.
    
    test('NotificationService initializes correctly', () {
      final service = NotificationService();
      
      // This is a basic test to ensure the service can be created without errors
      expect(service, isNotNull);
    });
  });
}
