import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';
import '../services/text_extraction_service_impl.dart';
import '../services/text_extraction_service.dart';
import '../services/intent_service.dart';
import '../services/preferences_service.dart';
import '../services/local_event_service.dart';
import '../services/logging_service.dart';
import '../services/calendar_integration_service.dart';
import '../constants/app_theme.dart';
import '../constants/app_constants.dart';
import '../widgets/app_loading_indicator.dart';
import '../widgets/app_bottom_nav.dart';

class TextExtractionView extends StatefulWidget {
  final String? initialText;

  const TextExtractionView({super.key, this.initialText});

  @override
  State<TextExtractionView> createState() => _TextExtractionViewState();
}

class _TextExtractionViewState extends State<TextExtractionView>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final TextExtractionServiceImpl _extractionService =
      TextExtractionServiceImpl();
  final PreferencesService _preferencesService = PreferencesService();
  final LocalEventService _localEventService = LocalEventService();
  final CalendarIntegrationService _calendarService =
      CalendarIntegrationService();

  // Animation controller for results panel
  late AnimationController _animationController;

  bool _isUsingAI = false;
  bool _isExtracting = false;
  ExtractionResult? _extractionResult;

  // Form controllers for editing extracted data
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  DateTime _startDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();

  DateTime _endDate = DateTime.now().add(const Duration(hours: 1));
  TimeOfDay _endTime =
      TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1)));

  List<String> _attendees = [];

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _checkAIStatus();
    _setupIntentListener();

    // Set initial text if provided
    if (widget.initialText != null && widget.initialText!.isNotEmpty) {
      _textController.text = widget.initialText!;
      // Automatically extract event details if text is provided
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _extractEventDetails();
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _textController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _setupIntentListener() {
    // Initialize the intent service
    final intentService = IntentService();
    intentService.init();

    // Listen for shared text from other apps
    intentService.textStream.listen((sharedText) {
      if (mounted && sharedText.isNotEmpty) {
        setState(() {
          _textController.text = sharedText;
        });

        // Automatically extract event details if text is received
        _extractEventDetails();
      }
    });
  }

  Future<void> _checkAIStatus() async {
    try {
      // Initialize preferences service
      await _preferencesService.init();

      // Get AI preference
      final useAI = _preferencesService.getUseAI();

      // Initialize logging service
      final loggingService = LoggingService();
      await loggingService.init();

      // Log the AI status
      await loggingService.log('APP', 'AI extraction enabled: $useAI');

      // Update state
      setState(() {
        _isUsingAI = useAI;
      });

      // Log the OpenRouter API key status
      final hasApiKey = await _extractionService.hasApiKey();
      await loggingService.log('APP', 'Has OpenRouter API key: $hasApiKey');
    } catch (e) {
      // If there's an error, log it and use default value (true)
      setState(() {
        _isUsingAI = true;
      });

      // Try to log the error
      try {
        final loggingService = LoggingService();
        await loggingService.init();
        await loggingService.log('ERROR', 'Error checking AI status: $e');
      } catch (_) {
        // Ignore errors in error handling
      }
    }
  }

  Future<void> _extractEventDetails() async {
    final text = _textController.text;
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please enter some text to extract event details from.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Reset form fields before extracting new data
    _resetFormFields();

    setState(() {
      _isExtracting = true;
    });

    // Initialize logging service
    final loggingService = LoggingService();
    await loggingService.init();
    await loggingService.log(
        'APP', 'Starting text extraction with AI: $_isUsingAI');

    try {
      // Check if we have an API key before attempting extraction
      final hasApiKey = await _extractionService.hasApiKey();
      await loggingService.log('APP', 'Has OpenRouter API key: $hasApiKey');

      if (_isUsingAI && !hasApiKey) {
        // If AI is enabled but we don't have an API key, show a message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'OpenRouter API key not set. Please add your API key in Settings.'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: () {
                  Navigator.pushNamed(context, AppConstants.settingsRoute);
                },
              ),
            ),
          );
        }

        // Continue with basic extraction
        await loggingService.log(
            'APP', 'Falling back to basic extraction due to missing API key');
      }

      // Perform the extraction
      final result =
          await _extractionService.extractEventDetails(text, useAI: _isUsingAI);

      // Log the extraction result
      await loggingService.log('APP', 'Extraction completed');
      if (result.extractedData.containsKey('error')) {
        await loggingService.log(
            'ERROR', 'Extraction error: ${result.extractedData['message']}');
      }

      setState(() {
        _extractionResult = result;
        _isExtracting = false;
      });

      // Check if there was an error in extraction
      if (result.extractedData.containsKey('error') &&
          result.extractedData['error'] == true) {
        // Show a user-friendly message
        if (mounted) {
          final errorMessage = result.extractedData['message'] as String? ??
              'AI extraction unavailable. Using basic extraction instead.';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Details',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('AI Extraction Issue'),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(errorMessage),
                            const SizedBox(height: 16),
                            const Text(
                              'Suggestions:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text('• Check your internet connection'),
                            const Text(
                                '• Verify your OpenRouter API key in Settings'),
                            const Text('• Try again in a few moments'),
                            const Text('• Try with different text'),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        }
      }

      // Populate form fields with extracted data
      _populateFormFields(result);

      // Log the populated fields
      await loggingService.log(
          'APP', 'Form fields populated with extracted data');
    } catch (e) {
      // Log the error
      await loggingService.log('ERROR', 'Exception during extraction: $e');

      setState(() {
        _isExtracting = false;
      });

      if (mounted) {
        // Show a more user-friendly error message
        final errorMessage = e.toString().replaceAll('Exception: ', '');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI extraction error: $errorMessage'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Details',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('AI Extraction Error'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(errorMessage),
                          const SizedBox(height: 16),
                          const Text(
                            'Suggestions:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text('• Check your internet connection'),
                          const Text('• Try again in a few moments'),
                          const Text('• Try with different text'),
                          const Text('• Try disabling AI extraction'),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }

      // Create a basic extraction result as fallback
      final fallbackResult = ExtractionResult(
        rawText: text,
        extractedData: {
          'title': 'New Event',
          'description': text,
        },
        confidenceScores: {
          'title': 0.5,
          'description': 0.5,
        },
      );

      setState(() {
        _extractionResult = fallbackResult;
      });

      // Populate form fields with basic data
      _populateFormFields(fallbackResult);

      await loggingService.log('APP', 'Used fallback extraction due to error');
    }
  }

  void _populateFormFields(ExtractionResult result) {
    setState(() {
      // Access data from the extractedData map
      _titleController.text = result.extractedData['title'] as String? ?? '';
      _descriptionController.text =
          result.extractedData['description'] as String? ?? '';
      _locationController.text =
          result.extractedData['location'] as String? ?? '';

      // Handle start date and time
      if (result.extractedData.containsKey('startTime') &&
          result.extractedData['startTime'] is DateTime) {
        final DateTime extractedStartTime =
            result.extractedData['startTime'] as DateTime;

        // Update the state variables with the extracted date and time
        _startDate = DateTime(
          extractedStartTime.year,
          extractedStartTime.month,
          extractedStartTime.day,
        );

        _startTime = TimeOfDay(
          hour: extractedStartTime.hour,
          minute: extractedStartTime.minute,
        );
      }

      // Handle end date and time
      if (result.extractedData.containsKey('endTime') &&
          result.extractedData['endTime'] is DateTime) {
        final DateTime extractedEndTime =
            result.extractedData['endTime'] as DateTime;

        // Update the state variables with the extracted date and time
        _endDate = DateTime(
          extractedEndTime.year,
          extractedEndTime.month,
          extractedEndTime.day,
        );

        _endTime = TimeOfDay(
          hour: extractedEndTime.hour,
          minute: extractedEndTime.minute,
        );

        // No debug printing
      } else {
        // If no end time was extracted, set it to 1 hour after start time
        _endDate = _startDate;
        _endTime = TimeOfDay(
          hour: (_startTime.hour + 1) % 24,
          minute: _startTime.minute,
        );
      }

      if (result.extractedData.containsKey('attendees')) {
        _attendees =
            List<String>.from(result.extractedData['attendees'] as List? ?? []);
      }
    });
  }

  // Reset all form fields and state variables to default values
  void _resetFormFields() {
    // Reset form fields
    _titleController.clear();
    _descriptionController.clear();
    _locationController.clear();

    // Reset date and time to current values
    final now = DateTime.now();
    _startDate = now;
    _startTime = TimeOfDay.fromDateTime(now);

    _endDate = now.add(const Duration(hours: 1));
    _endTime = TimeOfDay.fromDateTime(now.add(const Duration(hours: 1)));

    // Clear attendees
    _attendees = [];

    // No need to reset AI processing flag anymore
  }

  void _clearText() {
    setState(() {
      // Clear text input
      _textController.clear();
      _extractionResult = null;

      // Reset all form fields
      _resetFormFields();
    });
  }

  /// Returns a color based on the confidence score
  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) {
      return AppTheme.secondaryColor; // High confidence - green
    } else if (confidence >= 0.5) {
      return AppTheme.accentColor; // Medium confidence - yellow
    } else {
      return AppTheme.errorColor; // Low confidence - red
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        // Create a new DateTime object to ensure it's properly updated
        _startDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
        );

        // If end date is before start date, update it
        if (_endDate.isBefore(_startDate)) {
          _endDate = DateTime(
            _startDate.year,
            _startDate.month,
            _startDate.day,
          );
        }
      });
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;

        // No debug printing
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: _startDate.add(const Duration(days: 365 * 5)),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        // Create a new DateTime object to ensure it's properly updated
        _endDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
        );

        // No debug printing
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null && picked != _endTime) {
      setState(() {
        _endTime = picked;

        // No debug printing
      });
    }
  }

  Future<void> _createEvent() async {
    // Validate form fields
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an event title'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Show loading indicator with custom widget
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: AppLoadingIndicator(
            message: 'Creating event...',
            showBackground: true,
            size: 50,
          ),
        );
      },
    );

    try {
      // No debug printing

      // Create DateTime objects from the selected date and time
      final startDateTime = DateTime(
        _startDate.year,
        _startDate.month,
        _startDate.day,
        _startTime.hour,
        _startTime.minute,
      );

      // Create a variable for end date time that can be modified
      DateTime endDateTime = DateTime(
        _endDate.year,
        _endDate.month,
        _endDate.day,
        _endTime.hour,
        _endTime.minute,
      );

      // Validate that end time is after start time
      if (endDateTime.isBefore(startDateTime)) {
        // If end is before start, adjust end to be 1 hour after start

        final adjustedEndDateTime = startDateTime.add(const Duration(hours: 1));

        // Update the state variables
        _endDate = DateTime(
          adjustedEndDateTime.year,
          adjustedEndDateTime.month,
          adjustedEndDateTime.day,
        );

        _endTime = TimeOfDay(
          hour: adjustedEndDateTime.hour,
          minute: adjustedEndDateTime.minute,
        );

        // Use the adjusted end time
        endDateTime = adjustedEndDateTime;
      }

      // Create event model
      final event = EventModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title:
            _titleController.text.isEmpty ? 'New Event' : _titleController.text,
        description: _descriptionController.text,
        startTime: startDateTime,
        endTime: endDateTime,
        location: _locationController.text,
        attendees: _attendees,
        isAllDay: false,
        reminderMinutes: 30,
        originalText: _textController.text, // Save the original text
      );

      // No debug printing

      // Create the event using the improved LocalEventService
      // The service now has built-in retry and fallback mechanisms
      bool success = false;
      String? errorMessage;

      try {
        // Save to local database using the improved service
        success = await _localEventService.saveEvent(event);

        if (!success) {
          errorMessage =
              "Failed to save event. The database operation returned false.";
        }
      } catch (e) {
        success = false;
        errorMessage = e.toString();
      }

      // If the event wasn't saved, log the error to our debug logs
      if (!success) {
        final loggingService = LoggingService();
        await loggingService.log(
            'ERROR', 'Failed to save event: $errorMessage');
        await loggingService.log('EVENT', 'Event data: ${event.toMap()}');
      }

      // Close loading indicator
      if (mounted) Navigator.pop(context);

      if (success) {
        if (mounted) {
          // Show success dialog
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    const Text('Event Created'),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Event "${event.title}" has been created successfully.'),
                    const SizedBox(height: 16),
                    Text(
                      'Date: ${DateFormat('EEE, MMM d, yyyy').format(event.startTime)}',
                      style: AppTheme.body2Style,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Time: ${DateFormat('h:mm a').format(event.startTime)} - ${DateFormat('h:mm a').format(event.endTime)}',
                      style: AppTheme.body2Style,
                    ),
                    if (event.location.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Location: ${event.location}',
                        style: AppTheme.body2Style,
                      ),
                    ],
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );

          // Ask user if they want to save to device calendar
          if (mounted) {
            await _calendarService.showSaveToCalendarDialog(context, event);
          }

          // Return to previous screen with a result to trigger refresh
          if (mounted) {
            Navigator.pop(context, true); // Pass true to indicate success
          }
        }
      } else {
        if (mounted) {
          // Show a more detailed error message
          final errorDetails = errorMessage != null && errorMessage.isNotEmpty
              ? 'Error: $errorMessage'
              : 'Failed to create event. Please try again.';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorDetails),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Details',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Error Details'),
                      content: SingleChildScrollView(
                        child: Text(
                          'Failed to save event to database.\n\n'
                          'Technical details:\n$errorMessage',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Close loading indicator
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating event: $e'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Details',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Error Details'),
                    content: SingleChildScrollView(
                      child: Text(
                        'An unexpected error occurred while creating the event.\n\n'
                        'Technical details:\n$e\n\n'
                        'Stack trace:\n${StackTrace.current}',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extract Event Details'),
        actions: [
          IconButton(
            icon: Icon(
                _isUsingAI ? Icons.auto_awesome : Icons.auto_awesome_outlined),
            tooltip: _isUsingAI ? 'Using AI' : 'Not using AI',
            onPressed: () {
              setState(() {
                _isUsingAI = !_isUsingAI;
              });
              _preferencesService.setUseAI(_isUsingAI);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isUsingAI
                      ? 'AI extraction enabled'
                      : 'AI extraction disabled'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Help',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Text Extraction Help'),
                  content: const SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How to use:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('1. Enter or paste text containing event details'),
                        Text('2. Tap "Extract Event Details" to analyze'),
                        Text('3. Review and edit the extracted information'),
                        Text('4. Tap "Create Event" to save'),
                        SizedBox(height: 16),
                        Text(
                          'Tips:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                            '• Include date, time, and location for best results'),
                        Text('• Toggle AI for improved extraction accuracy'),
                        Text('• You can edit any field after extraction'),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
      body: SafeArea(
        child: Column(
          children: [
            // Input Card
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Row(
                        children: [
                          const Icon(Icons.text_fields,
                              color: AppTheme.primaryColor),
                          const SizedBox(width: AppTheme.spacingSmall),
                          Text(
                            'Enter Text to Extract',
                            style: AppTheme.subtitle1Style.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Chip(
                            label: Text(
                              _isUsingAI ? 'AI Enabled' : 'Basic Mode',
                              style: AppTheme.captionStyle.copyWith(
                                color: _isUsingAI
                                    ? AppTheme.primaryColor
                                    : AppTheme.textSecondaryColor,
                              ),
                            ),
                            backgroundColor: _isUsingAI
                                ? AppTheme.surfaceColor
                                : AppTheme.surfaceColor,
                            avatar: Icon(
                              _isUsingAI
                                  ? Icons.auto_awesome
                                  : Icons.auto_fix_normal,
                              size: 16,
                              color: _isUsingAI
                                  ? AppTheme.primaryColor
                                  : AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingMedium),

                      // Text input field
                      TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          hintText:
                              'Example: Meeting with John tomorrow at 3pm at Coffee Shop',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _clearText,
                          ),
                          contentPadding:
                              const EdgeInsets.all(AppTheme.spacingMedium),
                        ),
                        maxLines: 5,
                        style: AppTheme.body1Style,
                      ),
                      const SizedBox(height: AppTheme.spacingMedium),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed:
                                  _isExtracting ? null : _extractEventDetails,
                              icon: _isExtracting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : const Icon(Icons.search),
                              label: Text(_isExtracting
                                  ? 'Extracting...'
                                  : 'Extract Event Details'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppTheme.spacingMedium,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacingSmall),
                          IconButton(
                            onPressed: _clearText,
                            icon: const Icon(Icons.refresh),
                            tooltip: 'Reset',
                            style: IconButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Results Section
            if (_isExtracting)
              const Expanded(
                child: Center(
                  child: AppLoadingIndicator(
                    message: 'Analyzing text...',
                    showBackground: true,
                  ),
                ),
              )
            else if (_extractionResult != null)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMedium,
                    vertical: AppTheme.spacingSmall,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Results header
                      Card(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppTheme.spacingMedium),
                          child: Row(
                            children: [
                              const Icon(Icons.edit_note,
                                  color: AppTheme.primaryColor),
                              const SizedBox(width: AppTheme.spacingSmall),
                              Text(
                                'Edit Extracted Details',
                                style: AppTheme.subtitle1Style.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingMedium),

                      // Event details form
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppTheme.spacingMedium),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.info_outline,
                                      color: AppTheme.primaryColor),
                                  const SizedBox(width: AppTheme.spacingSmall),
                                  Text(
                                    'Event Information',
                                    style: AppTheme.subtitle2Style.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: AppTheme.spacingLarge),

                              // Title field with confidence indicator
                              TextField(
                                controller: _titleController,
                                decoration: InputDecoration(
                                  labelText: 'Event Title',
                                  hintText: 'Enter event title',
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.event),
                                  suffixIcon: _extractionResult != null &&
                                          _extractionResult!.confidenceScores
                                              .containsKey('title')
                                      ? Tooltip(
                                          message:
                                              'Confidence: ${(_extractionResult!.confidenceScores['title']! * 100).toInt()}%',
                                          child: Icon(
                                            Icons.check_circle,
                                            color: _getConfidenceColor(
                                                _extractionResult!
                                                            .confidenceScores[
                                                        'title'] ??
                                                    0),
                                          ),
                                        )
                                      : null,
                                ),
                                style: AppTheme.body1Style,
                                textCapitalization:
                                    TextCapitalization.sentences,
                              ),
                              const SizedBox(height: AppTheme.spacingMedium),

                              // Description field
                              TextField(
                                controller: _descriptionController,
                                decoration: InputDecoration(
                                  labelText: 'Description',
                                  hintText: 'Enter event description',
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.description),
                                  suffixIcon: _extractionResult != null &&
                                          _extractionResult!.confidenceScores
                                              .containsKey('description')
                                      ? Tooltip(
                                          message:
                                              'Confidence: ${(_extractionResult!.confidenceScores['description']! * 100).toInt()}%',
                                          child: Icon(
                                            Icons.check_circle,
                                            color: _getConfidenceColor(
                                                _extractionResult!
                                                            .confidenceScores[
                                                        'description'] ??
                                                    0),
                                          ),
                                        )
                                      : null,
                                ),
                                maxLines: 3,
                                style: AppTheme.body1Style,
                                textCapitalization:
                                    TextCapitalization.sentences,
                              ),
                              const SizedBox(height: AppTheme.spacingMedium),

                              // Location field with enhanced UI
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Location',
                                    style: AppTheme.captionStyle.copyWith(
                                      color: AppTheme.textSecondaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppTheme.dividerColor,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: Icon(Icons.location_on,
                                              color: AppTheme.primaryColor),
                                        ),
                                        Expanded(
                                          child: TextField(
                                            controller: _locationController,
                                            decoration: InputDecoration(
                                              hintText: 'Enter location',
                                              border: InputBorder.none,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 12,
                                              ),
                                              suffixIcon:
                                                  _extractionResult != null &&
                                                          _extractionResult!
                                                              .confidenceScores
                                                              .containsKey(
                                                                  'location')
                                                      ? Tooltip(
                                                          message:
                                                              'Confidence: ${(_extractionResult!.confidenceScores['location']! * 100).toInt()}%',
                                                          child: Icon(
                                                            Icons.check_circle,
                                                            color: _getConfidenceColor(
                                                                _extractionResult!
                                                                            .confidenceScores[
                                                                        'location'] ??
                                                                    0),
                                                          ),
                                                        )
                                                      : null,
                                            ),
                                            style: AppTheme.body1Style,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingMedium),

                      // Date & Time Card with enhanced UI
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppTheme.spacingMedium),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.event_available,
                                      color: AppTheme.primaryColor),
                                  const SizedBox(width: AppTheme.spacingSmall),
                                  Text(
                                    'Date & Time',
                                    style: AppTheme.subtitle2Style.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                  if (_extractionResult != null &&
                                      _extractionResult!.confidenceScores
                                          .containsKey('startTime'))
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Tooltip(
                                        message:
                                            'Date confidence: ${(_extractionResult!.confidenceScores['startTime']! * 100).toInt()}%',
                                        child: Icon(
                                          Icons.check_circle,
                                          size: 16,
                                          color: _getConfidenceColor(
                                              _extractionResult!
                                                          .confidenceScores[
                                                      'startTime'] ??
                                                  0),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const Divider(height: AppTheme.spacingLarge),

                              // Start date/time section with enhanced UI
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Start',
                                    style: AppTheme.subtitle2Style,
                                  ),
                                  const SizedBox(height: AppTheme.spacingSmall),
                                  Row(
                                    children: [
                                      // Start date selector
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () =>
                                              _selectStartDate(context),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: AppTheme.dividerColor,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.calendar_today,
                                                    size: 20,
                                                    color:
                                                        AppTheme.primaryColor),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    DateFormat(
                                                            'EEE, MMM d, yyyy')
                                                        .format(_startDate),
                                                    style: AppTheme.body1Style,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                          width: AppTheme.spacingSmall),

                                      // Start time selector
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () =>
                                              _selectStartTime(context),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: AppTheme.dividerColor,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.access_time,
                                                    size: 20,
                                                    color:
                                                        AppTheme.primaryColor),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    _startTime.format(context),
                                                    style: AppTheme.body1Style,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppTheme.spacingMedium),

                              // End date/time section with enhanced UI
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'End',
                                        style: AppTheme.subtitle2Style,
                                      ),
                                      if (_extractionResult != null &&
                                          _extractionResult!.confidenceScores
                                              .containsKey('endTime'))
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Tooltip(
                                            message:
                                                'End time confidence: ${(_extractionResult!.confidenceScores['endTime']! * 100).toInt()}%',
                                            child: Icon(
                                              Icons.check_circle,
                                              size: 16,
                                              color: _getConfidenceColor(
                                                  _extractionResult!
                                                              .confidenceScores[
                                                          'endTime'] ??
                                                      0),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: AppTheme.spacingSmall),
                                  Row(
                                    children: [
                                      // End date selector
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () => _selectEndDate(context),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: AppTheme.dividerColor,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.calendar_today,
                                                    size: 20,
                                                    color:
                                                        AppTheme.primaryColor),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    DateFormat(
                                                            'EEE, MMM d, yyyy')
                                                        .format(_endDate),
                                                    style: AppTheme.body1Style,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                          width: AppTheme.spacingSmall),

                                      // End time selector
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () => _selectEndTime(context),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: AppTheme.dividerColor,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.access_time,
                                                    size: 20,
                                                    color:
                                                        AppTheme.primaryColor),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    _endTime.format(context),
                                                    style: AppTheme.body1Style,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingLarge),

                      // Create event button with enhanced UI
                      Card(
                        elevation: 0,
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withAlpha(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppTheme.spacingMedium),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.event_available,
                                      color: AppTheme.primaryColor),
                                  const SizedBox(width: AppTheme.spacingSmall),
                                  Expanded(
                                    child: Text(
                                      'Ready to create your event?',
                                      style: AppTheme.subtitle2Style.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppTheme.spacingMedium),
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton.icon(
                                  onPressed: _createEvent,
                                  icon: const Icon(Icons.add_circle_outline),
                                  label: const Text('CREATE EVENT'),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: AppTheme.primaryColor,
                                    textStyle: AppTheme.buttonStyle.copyWith(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingMedium),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.text_snippet_outlined,
                        size: 80,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withAlpha(128),
                      ),
                      const SizedBox(height: AppTheme.spacingMedium),
                      Text(
                        'Enter text and tap "Extract Event Details"',
                        style: AppTheme.subtitle1Style.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppTheme.spacingLarge),
                      SizedBox(
                        width: 240,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {
                                _textController.text =
                                    '''🌿 Spring Gathering: Community & Connection 🌿

We're bringing the neighborhood together for a relaxing afternoon of good vibes, open conversations, and meaningful moments.

📅 Date: Sunday, May 5
🕓 Time: 4:00 PM – 8:00 PM
📍 Location: Willow Park, under the big oak tree
✨ Expect: acoustic live music, tea + snack stations, open mic, and cozy picnic spots.

Bring a blanket, your favorite mug, and your open heart. 💛 This is a space to connect, create, and just be.

🎟️ Free & open to all – families, friends, and furry companions welcome!

Let's slow down and reconnect with what matters. 🌼
#SpringGathering2025 #CommunityVibes''';
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Try with example text'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
