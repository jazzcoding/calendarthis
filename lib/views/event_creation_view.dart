import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';
import '../services/local_event_service.dart';
import '../services/calendar_integration_service.dart';
import '../services/text_extraction_service_impl.dart';
import '../services/text_extraction_service.dart';
import '../services/preferences_service.dart';
import '../services/intent_service.dart';
import '../constants/app_theme.dart';
import '../constants/app_constants.dart';
import '../widgets/app_bottom_nav.dart';

class EventCreationView extends StatefulWidget {
  final EventModel? event;
  final DateTime? selectedDate;
  final String? initialText;
  final int? initialTab;

  const EventCreationView({
    super.key,
    this.event,
    this.selectedDate,
    this.initialText,
    this.initialTab,
  });

  @override
  State<EventCreationView> createState() => _EventCreationViewState();
}

class _EventCreationViewState extends State<EventCreationView>
    with SingleTickerProviderStateMixin {
  // Form keys
  final _manualFormKey = GlobalKey<FormState>();
  final _textFormKey = GlobalKey<FormState>();

  // Services
  final LocalEventService _localEventService = LocalEventService();
  final CalendarIntegrationService _calendarService =
      CalendarIntegrationService();
  final TextExtractionServiceImpl _extractionService =
      TextExtractionServiceImpl();
  final PreferencesService _preferencesService = PreferencesService();

  // Tab controller
  late TabController _tabController;

  // Manual form controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _attendeeController = TextEditingController();

  // Text extraction controllers
  final TextEditingController _textController = TextEditingController();

  // Date and time
  DateTime _startDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  DateTime _endDate = DateTime.now().add(const Duration(hours: 1));
  TimeOfDay _endTime =
      TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1)));

  // Event properties
  bool _isAllDay = false;
  int _reminderMinutes = 30;
  List<String> _attendees = [];
  bool _isEditing = false;
  String? _eventId;

  // Text extraction state
  bool _isUsingAI = true;
  bool _isExtracting = false;
  ExtractionResult? _extractionResult;

  @override
  void initState() {
    super.initState();

    // Initialize tab controller
    _tabController = TabController(length: 3, vsync: this);

    // Set initial tab if provided
    if (widget.initialTab != null) {
      _tabController.animateTo(widget.initialTab!);
    }

    // Check AI status
    _checkAIStatus();

    // Set up intent listener for shared text
    _setupIntentListener();

    if (widget.event != null) {
      // Initialize with existing event data for editing
      _isEditing = true;
      _eventId = widget.event!.id;
      _titleController.text = widget.event!.title;
      _descriptionController.text = widget.event!.description;
      _locationController.text = widget.event!.location;
      _startDate = widget.event!.startTime;
      _startTime = TimeOfDay.fromDateTime(widget.event!.startTime);
      _endDate = widget.event!.endTime;
      _endTime = TimeOfDay.fromDateTime(widget.event!.endTime);
      _isAllDay = widget.event!.isAllDay;
      _reminderMinutes = widget.event!.reminderMinutes;
      _attendees = List.from(widget.event!.attendees);
    } else if (widget.selectedDate != null) {
      // Initialize with selected date for new event
      final selectedDate = widget.selectedDate!;
      _startDate = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        TimeOfDay.now().hour,
        TimeOfDay.now().minute,
      );
      _startTime = TimeOfDay.fromDateTime(_startDate);

      // Set end date to same day, 1 hour later
      _endDate = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        _startTime.hour + 1,
        _startTime.minute,
      );
      _endTime = TimeOfDay.fromDateTime(_endDate);
    }

    // Set initial text if provided
    if (widget.initialText != null && widget.initialText!.isNotEmpty) {
      _textController.text = widget.initialText!;
      // Switch to text extraction tab
      _tabController.animateTo(1);
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
    _tabController.dispose();
    _textController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _attendeeController.dispose();
    super.dispose();
  }

  Future<void> _checkAIStatus() async {
    await _preferencesService.init();
    setState(() {
      _isUsingAI = _preferencesService.getUseAI();
    });
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
          // Switch to text extraction tab
          _tabController.animateTo(1);
        });

        // Automatically extract event details if text is received
        _extractEventDetails();
      }
    });
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

    setState(() {
      _isExtracting = true;
    });

    try {
      // Check if API key is set
      final hasApiKey = await _extractionService.hasApiKey();

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
      }

      // Perform the extraction
      final result =
          await _extractionService.extractEventDetails(text, useAI: _isUsingAI);

      setState(() {
        _isExtracting = false;
        _extractionResult = result;
      });

      // Populate form fields with extracted data
      _populateFormFields(result);
    } catch (e) {
      setState(() {
        _isExtracting = false;
      });

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error extracting event details: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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

      // Handle dates and times
      if (result.extractedData.containsKey('startTime') &&
          result.extractedData['startTime'] is DateTime) {
        _startDate = result.extractedData['startTime'] as DateTime;
        _startTime = TimeOfDay.fromDateTime(_startDate);
      }

      if (result.extractedData.containsKey('endTime') &&
          result.extractedData['endTime'] is DateTime) {
        _endDate = result.extractedData['endTime'] as DateTime;
        _endTime = TimeOfDay.fromDateTime(_endDate);
      }

      if (result.extractedData.containsKey('attendees')) {
        _attendees =
            List<String>.from(result.extractedData['attendees'] as List? ?? []);
      }
    });
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
        _startDate = picked;
        // If end date is before start date, update it
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate;
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
        _endDate = picked;
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
      });
    }
  }

  void _addAttendee() {
    final attendee = _attendeeController.text.trim();
    if (attendee.isNotEmpty) {
      setState(() {
        _attendees.add(attendee);
        _attendeeController.clear();
      });
    }
  }

  void _removeAttendee(int index) {
    setState(() {
      _attendees.removeAt(index);
    });
  }

  Future<void> _saveEvent() async {
    if (!_manualFormKey.currentState!.validate()) {
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Create DateTime objects from the selected date and time
      final startDateTime = DateTime(
        _startDate.year,
        _startDate.month,
        _startDate.day,
        _isAllDay ? 0 : _startTime.hour,
        _isAllDay ? 0 : _startTime.minute,
      );

      final endDateTime = DateTime(
        _endDate.year,
        _endDate.month,
        _endDate.day,
        _isAllDay ? 23 : _endTime.hour,
        _isAllDay ? 59 : _endTime.minute,
      );

      // Create event model
      final event = EventModel(
        id: _eventId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        startTime: startDateTime,
        endTime: endDateTime,
        location: _locationController.text,
        attendees: _attendees,
        isAllDay: _isAllDay,
        reminderMinutes: _reminderMinutes,
        originalText: '', // No original text for manually created events
      );

      // Save the event
      bool success;
      if (_isEditing) {
        success = await _localEventService.updateEvent(event);
      } else {
        success = await _localEventService.saveEvent(event);
      }

      // Close loading indicator
      if (mounted) Navigator.pop(context);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditing
                  ? 'Event updated successfully'
                  : 'Event created successfully'),
              duration: const Duration(seconds: 2),
            ),
          );

          // Ask user if they want to save to device calendar
          await _calendarService.showSaveToCalendarDialog(context, event);
        }

        // Navigate back to previous screen
        if (mounted) Navigator.pop(context);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditing
                  ? 'Failed to update event'
                  : 'Failed to create event'),
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
            content: Text('Error: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Event' : 'Add Event'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      body: Column(
        children: [
          // Tabs
          Container(
            color: AppTheme.surfaceColor,
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            child: Row(
              children: [
                _buildTab(0, Icons.calendar_today, 'Manual'),
                const SizedBox(width: 12),
                _buildTab(1, Icons.text_fields, 'From Text'),
                const SizedBox(width: 12),
                _buildPremiumTab(2, Icons.image, 'Image'),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Manual tab
                _buildManualTab(),

                // Text extraction tab
                _buildTextExtractionTab(),

                // Image extraction tab (premium)
                _buildImageExtractionTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, IconData icon, String label) {
    final isActive = _tabController.index == index;
    final primaryColor = AppTheme.primaryColor;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Material(
          elevation: isActive ? 4 : 1,
          shadowColor: isActive ? primaryColor.withAlpha(100) : Colors.black12,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () {
              _tabController.animateTo(index);
              setState(() {});
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: isActive ? primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive ? primaryColor : Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon with glow effect
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Glow effect
                      if (isActive)
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withAlpha(30),
                          ),
                        ),
                      // Icon
                      Icon(
                        icon,
                        color: isActive ? Colors.white : primaryColor,
                        size: 24,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Label
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white.withAlpha(30)
                          : primaryColor.withAlpha(15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isActive ? Colors.white : primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumTab(int index, IconData icon, String label) {
    final isActive = _tabController.index == index;
    final premiumColor = const Color(0xFF8B5CF6); // Premium purple color

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Material(
          elevation: isActive ? 4 : 1,
          shadowColor: isActive ? premiumColor.withAlpha(100) : Colors.black12,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () {
              _tabController.animateTo(index);
              setState(() {});
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: isActive ? premiumColor : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive ? premiumColor : Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Premium crown icon
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Glow effect
                      if (isActive)
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withAlpha(30),
                          ),
                        ),
                      // Icon
                      Icon(
                        icon,
                        color: isActive ? Colors.white : premiumColor,
                        size: 24,
                      ),
                      // Premium indicator dot
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive ? Colors.white : premiumColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isActive ? premiumColor : Colors.white,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Label
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white.withAlpha(30)
                          : premiumColor.withAlpha(15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isActive ? Colors.white : premiumColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildManualTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Form(
        key: _manualFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Title
            const Text(
              'Event Title *',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Enter event title',
                prefixIcon: Icon(Icons.edit_note),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Date & Time Section
            Row(
              children: [
                Icon(Icons.calendar_today, color: AppTheme.textSecondaryColor),
                const SizedBox(width: 8),
                Text(
                  'Date & Time',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Start Date & Time
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Date *',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectStartDate(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                            ),
                          ),
                          child: Text(
                            DateFormat('MMM dd, yyyy').format(_startDate),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                if (!_isAllDay)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Time *',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _selectStartTime(context),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.access_time),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                              ),
                            ),
                            child: Text(
                              _startTime.format(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // All Day Switch
            SwitchListTile(
              title: const Text('All Day'),
              value: _isAllDay,
              onChanged: (value) {
                setState(() {
                  _isAllDay = value;
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppTheme.dividerColor),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),

            const SizedBox(height: 16),

            // End Date
            const Text(
              'End Date',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectEndDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                child: Text(
                  DateFormat('MMM dd, yyyy').format(_endDate),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Location
            const Text(
              'Location',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                hintText: 'Enter location',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Description
            const Text(
              'Description',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: 'Enter event details',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 32),

            // Form actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveEvent,
                    icon: const Icon(Icons.check),
                    label: Text(_isEditing ? 'Update Event' : 'Save Event'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextExtractionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Form(
        key: _textFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI-Powered Extraction Intro
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withAlpha(13),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryColor.withAlpha(51),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AI-Powered Event Extraction',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Paste any text containing event details and our AI will automatically extract the important information.',
                          style: TextStyle(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Text Input
            const Text(
              'Paste text containing event details',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Paste your text here...',
                prefixIcon: Icon(Icons.text_snippet),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              maxLines: 5,
            ),

            const SizedBox(height: 16),

            // Extract Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isExtracting ? null : _extractEventDetails,
                icon: _isExtracting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.search),
                label: Text(
                    _isExtracting ? 'Extracting...' : 'Extract Event Details'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Extracted Event Preview (only show if we have results)
            if (_extractionResult != null) ...[
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.dividerColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search,
                              color: AppTheme.primaryColor),
                          const SizedBox(width: 8),
                          const Text(
                            'Extracted Event',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryColor.withAlpha(25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'High Confidence',
                              style: TextStyle(
                                color: AppTheme.secondaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Event details
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPreviewItem(
                            'Title',
                            _titleController.text,
                            Icons.title,
                            0.9,
                          ),
                          const SizedBox(height: 12),
                          _buildPreviewItem(
                            'Date & Time',
                            '${DateFormat('EEE, MMM d, yyyy').format(_startDate)} at ${DateFormat('h:mm a').format(_startDate)}',
                            Icons.calendar_today,
                            0.8,
                          ),
                          if (_locationController.text.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _buildPreviewItem(
                              'Location',
                              _locationController.text,
                              Icons.location_on,
                              0.7,
                            ),
                          ],
                          if (_descriptionController.text.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _buildPreviewItem(
                              'Description',
                              _descriptionController.text,
                              Icons.description,
                              0.6,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Switch to manual tab to edit details
                        _tabController.animateTo(0);
                        setState(() {});
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Details'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saveEvent,
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Add to Calendar'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
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

  Widget _buildPreviewItem(
      String label, String value, IconData icon, double confidence) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppTheme.textSecondaryColor,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.check_circle,
          color: _getConfidenceColor(confidence),
          size: 16,
        ),
      ],
    );
  }

  Widget _buildImageExtractionTab() {
    final premiumColor = const Color(0xFF8B5CF6); // Premium purple color
    final goldColor = const Color(0xFFFFD700); // Gold color for premium badge

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Premium notice
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  premiumColor.withAlpha(30),
                  goldColor.withAlpha(15),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: premiumColor.withAlpha(76),
              ),
              boxShadow: [
                BoxShadow(
                  color: premiumColor.withAlpha(20),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Premium badge in the corner
                Positioned(
                  top: -24,
                  right: -24,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          goldColor.withAlpha(50),
                          premiumColor.withAlpha(0),
                        ],
                        radius: 0.8,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                // Content
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Premium star icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            goldColor.withAlpha(100),
                            premiumColor,
                          ],
                          center: Alignment.topLeft,
                          focal: Alignment.topLeft,
                          radius: 1.2,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(40),
                            blurRadius: 4,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [Colors.white, Colors.white.withAlpha(200)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ).createShader(bounds),
                        child: const Text(
                          '✦',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Text content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Premium feature title with gradient
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                premiumColor,
                                goldColor,
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ).createShader(bounds),
                            child: const Text(
                              'Premium Feature',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Description
                          Text(
                            'Extract from Image is a premium feature. Upgrade to extract event details directly from screenshots, invitations, and photos.',
                            style: TextStyle(
                              color: AppTheme.textSecondaryColor,
                              fontSize: 14,
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

          const SizedBox(height: 24),

          // File upload area
          InkWell(
            onTap: () {
              // Show premium upgrade dialog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('This is a premium feature'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                border: Border.all(
                  color: premiumColor.withAlpha(100),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(12),
                color: premiumColor.withAlpha(5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: premiumColor.withAlpha(15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 48,
                      color: premiumColor.withAlpha(150),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Upload an image or take a photo',
                    style: TextStyle(
                      fontSize: 16,
                      color: premiumColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Supports JPG, PNG and HEIC formats',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Upgrade button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: premiumColor.withAlpha(50),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Premium features coming soon!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    goldColor,
                    Colors.white,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: const Icon(Icons.star, size: 24),
              ),
              label: const Text(
                'Upgrade to Premium',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: premiumColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                shadowColor: premiumColor.withAlpha(50),
                surfaceTintColor: goldColor.withAlpha(50),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Feature list
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Premium Features Include:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                _buildPremiumFeatureItem(
                  'Extract event details from screenshots',
                  Icons.screenshot,
                ),
                _buildPremiumFeatureItem(
                  'Scan physical invitations with your camera',
                  Icons.document_scanner,
                ),
                _buildPremiumFeatureItem(
                  'Process images from your gallery',
                  Icons.photo_library,
                ),
                _buildPremiumFeatureItem(
                  'Advanced AI recognition technology',
                  Icons.auto_awesome,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumFeatureItem(String text, IconData icon) {
    final premiumColor = const Color(0xFF8B5CF6);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: premiumColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
