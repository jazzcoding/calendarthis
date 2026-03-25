# Integration Tests for CalendarThis!

This directory contains integration tests for the CalendarThis! app. These tests verify that the app's main features work correctly from end to end.

## Running the Tests

### On a Connected Device or Emulator

To run the integration tests on a connected device or emulator, use the following command:

```bash
flutter test integration_test/event_creation_test.dart
```

### With Test Driver (for Collecting Performance Metrics)

To run the tests with the test driver (which allows collecting performance metrics), use:

```bash
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/event_creation_test.dart
```

## Test Cases

The integration tests cover the following scenarios:

1. **Create event from text extraction**
   - Navigate to text extraction view
   - Enter text with event details
   - Extract event details
   - Verify and edit extracted fields
   - Create the event
   - Verify the event appears in the event list

2. **Create event manually**
   - Navigate to event creation view
   - Fill in event details
   - Save the event
   - Verify the event appears in the event list

3. **Edit existing event**
   - Navigate to event list view
   - Find and tap on an existing event
   - Edit the event details
   - Save the updated event
   - Verify the updated event appears in the list

4. **Delete event**
   - Navigate to event list view
   - Find an existing event
   - Delete the event
   - Verify the event is no longer in the list

## Notes

- These tests require calendar permissions to be granted on the device
- The tests may fail if the device's calendar app is not properly set up
- Some tests may need to be adjusted based on the specific UI of your app
- Make sure to run the tests on a device with a clean state or reset the app's data before running the tests
