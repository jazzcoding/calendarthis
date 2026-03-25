import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:calendar_this/main.dart' as app;
import 'package:calendar_this/constants/app_constants.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Event Creation Flow Tests', () {
    testWidgets('Create event from text extraction', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Skip onboarding if it appears
      final skipButton = find.text('Skip');
      if (skipButton.evaluate().isNotEmpty) {
        await tester.tap(skipButton);
        await tester.pumpAndSettle();
      }

      // Navigate to text extraction view
      final extractFromTextButton = find.text('Extract from Text');
      expect(extractFromTextButton, findsOneWidget);
      await tester.tap(extractFromTextButton);
      await tester.pumpAndSettle();

      // Enter text with event details
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);
      await tester.enterText(textField, 'Meeting with John tomorrow at 3 PM at Coffee Shop');
      await tester.pumpAndSettle();

      // Extract event details
      final extractButton = find.text('Extract Event Details');
      expect(extractButton, findsOneWidget);
      await tester.tap(extractButton);
      await tester.pumpAndSettle(const Duration(seconds: 5)); // Wait for extraction

      // Verify extracted fields
      expect(find.text('Extracted Event Details'), findsOneWidget);
      
      // Edit title field if needed
      final titleField = find.ancestor(
        of: find.text('Event Title'),
        matching: find.byType(TextFormField),
      );
      expect(titleField, findsOneWidget);
      await tester.tap(titleField);
      await tester.pumpAndSettle();
      await tester.enterText(titleField, 'Meeting with John');
      await tester.pumpAndSettle();

      // Create the event
      final createEventButton = find.text('Create Event');
      expect(createEventButton, findsOneWidget);
      await tester.tap(createEventButton);
      await tester.pumpAndSettle(const Duration(seconds: 3)); // Wait for event creation

      // Verify navigation to event list
      expect(find.text('My Events'), findsOneWidget);
      
      // Verify the event appears in the list
      expect(find.text('Meeting with John'), findsOneWidget);
    });

    testWidgets('Create event manually', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Skip onboarding if it appears
      final skipButton = find.text('Skip');
      if (skipButton.evaluate().isNotEmpty) {
        await tester.tap(skipButton);
        await tester.pumpAndSettle();
      }

      // Navigate to event creation view
      final createEventButton = find.text('Create New Event');
      expect(createEventButton, findsOneWidget);
      await tester.tap(createEventButton);
      await tester.pumpAndSettle();

      // Fill in event details
      final titleField = find.byKey(const Key('event_title_field'));
      expect(titleField, findsOneWidget);
      await tester.enterText(titleField, 'Team Meeting');
      await tester.pumpAndSettle();

      final descriptionField = find.byKey(const Key('event_description_field'));
      expect(descriptionField, findsOneWidget);
      await tester.enterText(descriptionField, 'Weekly team sync');
      await tester.pumpAndSettle();

      final locationField = find.byKey(const Key('event_location_field'));
      expect(locationField, findsOneWidget);
      await tester.enterText(locationField, 'Conference Room A');
      await tester.pumpAndSettle();

      // Save the event
      final saveButton = find.text('Save Event');
      expect(saveButton, findsOneWidget);
      await tester.tap(saveButton);
      await tester.pumpAndSettle(const Duration(seconds: 3)); // Wait for event creation

      // Verify navigation to event list
      expect(find.text('My Events'), findsOneWidget);
      
      // Verify the event appears in the list
      expect(find.text('Team Meeting'), findsOneWidget);
    });

    testWidgets('Edit existing event', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Skip onboarding if it appears
      final skipButton = find.text('Skip');
      if (skipButton.evaluate().isNotEmpty) {
        await tester.tap(skipButton);
        await tester.pumpAndSettle();
      }

      // Navigate to event list view
      final viewEventsButton = find.text('View My Events');
      expect(viewEventsButton, findsOneWidget);
      await tester.tap(viewEventsButton);
      await tester.pumpAndSettle();

      // Find and tap on an existing event
      final eventCard = find.text('Team Meeting');
      expect(eventCard, findsOneWidget);
      await tester.tap(eventCard);
      await tester.pumpAndSettle();

      // Tap on edit button
      final editButton = find.text('Edit');
      expect(editButton, findsOneWidget);
      await tester.tap(editButton);
      await tester.pumpAndSettle();

      // Update event title
      final titleField = find.byKey(const Key('event_title_field'));
      expect(titleField, findsOneWidget);
      await tester.enterText(titleField, 'Updated Team Meeting');
      await tester.pumpAndSettle();

      // Save the updated event
      final saveButton = find.text('Save Event');
      expect(saveButton, findsOneWidget);
      await tester.tap(saveButton);
      await tester.pumpAndSettle(const Duration(seconds: 3)); // Wait for event update

      // Verify navigation to event list
      expect(find.text('My Events'), findsOneWidget);
      
      // Verify the updated event appears in the list
      expect(find.text('Updated Team Meeting'), findsOneWidget);
    });

    testWidgets('Delete event', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Skip onboarding if it appears
      final skipButton = find.text('Skip');
      if (skipButton.evaluate().isNotEmpty) {
        await tester.tap(skipButton);
        await tester.pumpAndSettle();
      }

      // Navigate to event list view
      final viewEventsButton = find.text('View My Events');
      expect(viewEventsButton, findsOneWidget);
      await tester.tap(viewEventsButton);
      await tester.pumpAndSettle();

      // Find an existing event and open the menu
      final eventCard = find.text('Updated Team Meeting');
      expect(eventCard, findsOneWidget);
      
      // Find and tap the menu button for this event
      final menuButton = find.byIcon(Icons.more_vert).first;
      await tester.tap(menuButton);
      await tester.pumpAndSettle();

      // Tap on delete option
      final deleteOption = find.text('Delete');
      expect(deleteOption, findsOneWidget);
      await tester.tap(deleteOption);
      await tester.pumpAndSettle();

      // Confirm deletion
      final confirmButton = find.text('Delete').last;
      expect(confirmButton, findsOneWidget);
      await tester.tap(confirmButton);
      await tester.pumpAndSettle(const Duration(seconds: 3)); // Wait for deletion

      // Verify the event is no longer in the list
      expect(find.text('Updated Team Meeting'), findsNothing);
    });
  });
}
