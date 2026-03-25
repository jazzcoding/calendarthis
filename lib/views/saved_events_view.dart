import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../constants/app_constants.dart';
import '../constants/app_theme.dart';
import '../models/event_model.dart';
import '../services/local_event_service.dart';
import '../utils/event_utils.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/saved_event_search_delegate.dart';

class SavedEventsView extends StatefulWidget {
  const SavedEventsView({super.key});

  @override
  State<SavedEventsView> createState() => _SavedEventsViewState();
}

class _SavedEventsViewState extends State<SavedEventsView>
    with SingleTickerProviderStateMixin {
  final LocalEventService _localEventService = LocalEventService();
  List<EventModel> _events = [];
  bool _isLoading = true;
  bool _isCalendarView = false;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // Key for the calendar to avoid reinitialization issues
  late GlobalKey _calendarKey;

  // Animation controller for view transitions
  late AnimationController _animationController;

  // Calendar expansion state
  bool _isCalendarExpanded = true;
  // Adjust calendar heights to be more responsive on different screen sizes
  double get _calendarExpandedHeight {
    // Use a smaller percentage on medium-sized screens
    final screenHeight = MediaQuery.of(context).size.height;
    if (screenHeight < 700) {
      return 0.45; // 45% for smaller screens
    } else {
      return 0.55; // 55% for larger screens
    }
  }

  final double _calendarCollapsedHeight =
      0.07; // 7% of available height when collapsed

  // Map to store events by date
  Map<DateTime, List<EventModel>> _eventsByDay = {};

  @override
  void initState() {
    super.initState();

    // Initialize calendar key
    _calendarKey = GlobalKey();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: AppTheme.animationDurationStandard,
    );

    // Start animation
    _animationController.forward();

    _loadEvents();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var events = await _localEventService.getEvents();

      // Sort events by date
      events.sort((a, b) => a.startTime.compareTo(b.startTime));

      // Group events by day using our utility function
      final eventsByDay = EventUtils.groupEventsByDay(events);

      setState(() {
        _events = events;
        _eventsByDay = eventsByDay;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading events: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _viewEventDetails(EventModel event) {
    Navigator.pushNamed(
      context,
      AppConstants.eventDetailRoute,
      arguments: event,
    ).then((_) => _loadEvents());
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy - h:mm a').format(dateTime);
  }

  List<EventModel> _getEventsForDay(DateTime day) {
    final dateKey = DateTime(day.year, day.month, day.day);
    return _eventsByDay[dateKey] ?? [];
  }

  // Helper method to check if two DateTimes have the same hour
  bool isSameHour(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day &&
        a.hour == b.hour;
  }

  // Helper method to navigate between months
  void _navigateToMonth(int monthDelta) {
    // Use Future.microtask to avoid setState during build
    Future.microtask(() {
      setState(() {
        // Always keep the calendar expanded when changing months
        _isCalendarExpanded = true;

        // Calculate the new month
        final newMonth = _focusedDay.month + monthDelta;
        final newYear =
            _focusedDay.year + (newMonth > 12 ? 1 : (newMonth < 1 ? -1 : 0));
        final adjustedMonth = newMonth > 12
            ? newMonth - 12
            : (newMonth < 1 ? newMonth + 12 : newMonth);

        // Update focused day to the first day of the new month
        _focusedDay = DateTime(newYear, adjustedMonth, 1);

        // Update selected day to be in the new month
        // If the current day number exists in the new month, keep it
        final daysInNewMonth = DateTime(newYear, adjustedMonth + 1, 0).day;
        final newDay = _selectedDay.day > daysInNewMonth
            ? daysInNewMonth
            : _selectedDay.day;

        _selectedDay = DateTime(newYear, adjustedMonth, newDay);

        // Force a rebuild of the calendar with the new key to ensure proper rendering
        _calendarKey = GlobalKey();
      });
    });
  }

  // Helper method to format duration between two DateTimes
  String _formatDuration(DateTime start, DateTime end) {
    final duration = end.difference(start);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Events'),
        centerTitle: true,
        elevation: 0,
        actions: [
          // Search icon
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final selectedEvent = await showSearch(
                context: context,
                delegate: SavedEventSearchDelegate(_events),
              );

              if (selectedEvent != null) {
                _viewEventDetails(selectedEvent);
              }
            },
            tooltip: 'Search Events',
          ),
          // View toggle icon
          IconButton(
            icon: Icon(_isCalendarView ? Icons.list : Icons.calendar_month),
            onPressed: () {
              setState(() {
                _isCalendarView = !_isCalendarView;

                // Run animation when toggling views
                if (_isCalendarView) {
                  _animationController.forward(from: 0.0);
                  _isCalendarExpanded = true;
                } else {
                  _animationController.reverse(from: 1.0);
                }
              });
            },
            tooltip: _isCalendarView
                ? 'Switch to List View'
                : 'Switch to Calendar View',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
              ? _buildEmptyState()
              : _isCalendarView
                  ? _buildCalendarView()
                  : _buildEventsList(),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.contentPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty state illustration
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_busy,
                size: 80,
                color: AppTheme.disabledColor,
              ),
            ),
            const SizedBox(height: AppTheme.spacingLarge),

            // Title
            Text(
              'No events found',
              style: AppTheme.heading3Style,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingSmall),

            // Description
            Text(
              'Create your first event by tapping the + button',
              style: AppTheme.body2Style,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingLarge),

            // Action button
            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, AppConstants.eventCreationRoute)
                      .then((_) => _loadEvents());
                },
                icon: const Icon(Icons.add),
                label: const Text('Create Event'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.spacingMedium,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate dynamic heights based on available space
        final availableHeight = constraints.maxHeight;
        final calendarHeight = availableHeight *
            (_isCalendarExpanded
                ? _calendarExpandedHeight
                : _calendarCollapsedHeight);

        return NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            // Auto-collapse calendar on scroll down
            if (scrollNotification is ScrollUpdateNotification) {
              if (scrollNotification.scrollDelta != null &&
                  scrollNotification.scrollDelta! > 10 &&
                  _isCalendarExpanded) {
                // Use Future.microtask to avoid setState during build
                Future.microtask(() {
                  setState(() {
                    _isCalendarExpanded = false;
                  });
                });
              } else if (scrollNotification.scrollDelta != null &&
                  scrollNotification.scrollDelta! < -10 &&
                  !_isCalendarExpanded) {
                // Use Future.microtask to avoid setState during build
                Future.microtask(() {
                  setState(() {
                    _isCalendarExpanded = true;
                  });
                });
              }
            }
            return false;
          },
          child: Column(
            children: [
              // Collapsible calendar section with gesture detector
              GestureDetector(
                onVerticalDragEnd: (details) {
                  // Toggle calendar expansion on vertical swipe
                  if (details.primaryVelocity != null) {
                    if (details.primaryVelocity! > 0 && !_isCalendarExpanded) {
                      // Swipe down - expand
                      Future.microtask(() {
                        setState(() {
                          _isCalendarExpanded = true;
                        });
                      });
                    } else if (details.primaryVelocity! < 0 &&
                        _isCalendarExpanded) {
                      // Swipe up - collapse
                      Future.microtask(() {
                        setState(() {
                          _isCalendarExpanded = false;
                        });
                      });
                    }
                  }
                },
                child: AnimatedContainer(
                  duration: AppTheme.animationDurationStandard,
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(13), // ~5% opacity
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  height: calendarHeight,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Calendar header with expand/collapse indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.spacingSmall,
                          horizontal: AppTheme.spacingMedium,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(
                              color: AppTheme.dividerColor,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Previous month button - flat style
                            InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () =>
                                  _navigateToMonth(-1), // Navigate back 1 month
                              splashColor: AppTheme.primaryColor.withAlpha(51),
                              highlightColor:
                                  AppTheme.primaryColor.withAlpha(25),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: const Icon(
                                  Icons.chevron_left,
                                  color: AppTheme.primaryColor,
                                  size: 28,
                                ),
                              ),
                            ),

                            // Month and year
                            Expanded(
                              child: Text(
                                DateFormat('MMMM yyyy').format(_focusedDay),
                                style: AppTheme.subtitle1Style.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            // Next month button - flat style
                            InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => _navigateToMonth(
                                  1), // Navigate forward 1 month
                              splashColor: AppTheme.primaryColor.withAlpha(51),
                              highlightColor:
                                  AppTheme.primaryColor.withAlpha(25),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: const Icon(
                                  Icons.chevron_right,
                                  color: AppTheme.primaryColor,
                                  size: 28,
                                ),
                              ),
                            ),

                            // Expand/collapse indicator - flat style
                            InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                setState(() {
                                  _isCalendarExpanded = !_isCalendarExpanded;
                                });
                              },
                              splashColor: AppTheme.primaryColor.withAlpha(51),
                              highlightColor:
                                  AppTheme.primaryColor.withAlpha(25),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  _isCalendarExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: AppTheme.primaryColor,
                                  size: 28,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Calendar - using SizedBox with fixed height to avoid overflow
                      if (_isCalendarExpanded)
                        SizedBox(
                          height: calendarHeight -
                              (MediaQuery.of(context).size.height < 700
                                  ? 60
                                  : 70), // Further reduced space below calendar
                          child: AnimatedOpacity(
                            opacity: 1.0,
                            duration: AppTheme.animationDurationQuick,
                            child: ClipRect(
                              child: TableCalendar<EventModel>(
                                key: _calendarKey,
                                firstDay: DateTime.utc(2020, 1, 1),
                                lastDay: DateTime.utc(2030, 12, 31),
                                focusedDay: _focusedDay,
                                calendarFormat: _calendarFormat,
                                eventLoader: _getEventsForDay,
                                rowHeight: MediaQuery.of(context).size.width <
                                        360
                                    ? 28 // Smaller height for narrow screens
                                    : 32, // Standard height for wider screens
                                daysOfWeekHeight: MediaQuery.of(context)
                                            .size
                                            .width <
                                        360
                                    ? 14 // Smaller height for narrow screens
                                    : 16, // Standard height for wider screens
                                headerVisible: false, // Using custom header
                                availableCalendarFormats: const {
                                  CalendarFormat.month: 'Month',
                                },
                                selectedDayPredicate: (day) {
                                  return EventUtils.isSameDay(
                                      _selectedDay, day);
                                },
                                onDaySelected: (selectedDay, focusedDay) {
                                  // Use Future.microtask to avoid setState during build
                                  Future.microtask(() {
                                    setState(() {
                                      _selectedDay = selectedDay;
                                      _focusedDay = focusedDay;
                                    });
                                  });
                                },
                                onFormatChanged: (format) {
                                  // Use Future.microtask to avoid setState during build
                                  Future.microtask(() {
                                    setState(() {
                                      _calendarFormat = format;
                                    });
                                  });
                                },
                                onPageChanged: (focusedDay) {
                                  // Always use Future.microtask to avoid setState during build
                                  // This helps prevent the calendar from collapsing during month navigation
                                  Future.microtask(() {
                                    setState(() {
                                      _focusedDay = focusedDay;
                                      // Ensure calendar stays expanded when swiping between months
                                      _isCalendarExpanded = true;

                                      // Also update the selected day to be in the new month
                                      // If the current day number exists in the new month, keep it
                                      if (_selectedDay.month !=
                                              focusedDay.month ||
                                          _selectedDay.year !=
                                              focusedDay.year) {
                                        final daysInNewMonth = DateTime(
                                          focusedDay.year,
                                          focusedDay.month + 1,
                                          0,
                                        ).day;

                                        final newDay =
                                            _selectedDay.day > daysInNewMonth
                                                ? daysInNewMonth
                                                : _selectedDay.day;

                                        _selectedDay = DateTime(
                                          focusedDay.year,
                                          focusedDay.month,
                                          newDay,
                                        );
                                      }
                                    });
                                  });
                                },
                                calendarStyle: CalendarStyle(
                                  // Day cell styling - more responsive with flexible margins
                                  cellMargin: EdgeInsets.all(
                                      MediaQuery.of(context).size.width < 360
                                          ? 0.5
                                          : 1),
                                  cellPadding: EdgeInsets.zero,
                                  defaultTextStyle:
                                      AppTheme.body1Style.copyWith(
                                    fontSize:
                                        MediaQuery.of(context).size.width < 360
                                            ? 12
                                            : 14, // Responsive font size
                                  ),
                                  weekendTextStyle:
                                      AppTheme.body1Style.copyWith(
                                    fontSize:
                                        MediaQuery.of(context).size.width < 360
                                            ? 12
                                            : 14, // Responsive font size
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                  outsideTextStyle:
                                      AppTheme.body1Style.copyWith(
                                    fontSize:
                                        MediaQuery.of(context).size.width < 360
                                            ? 12
                                            : 14, // Responsive font size
                                    color: AppTheme.disabledColor,
                                  ),

                                  // Today styling - more prominent
                                  todayDecoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppTheme.primaryColor,
                                      width: 2, // Thicker border
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  todayTextStyle: AppTheme.body1Style.copyWith(
                                    fontSize:
                                        MediaQuery.of(context).size.width < 360
                                            ? 12
                                            : 14, // Responsive font size
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),

                                  // Selected day styling - more prominent
                                  selectedDecoration: const BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  selectedTextStyle:
                                      AppTheme.body1Style.copyWith(
                                    fontSize:
                                        MediaQuery.of(context).size.width < 360
                                            ? 12
                                            : 14, // Responsive font size
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),

                                  // Event markers styling - more responsive
                                  markersMaxCount: 2,
                                  markerDecoration: const BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  markerSize: 4,
                                  markersAnchor: 0.7,
                                  markerSizeScale: 0.7,
                                  markersAutoAligned: true,
                                ),
                                daysOfWeekStyle: DaysOfWeekStyle(
                                  weekdayStyle: TextStyle(
                                    color: AppTheme.textSecondaryColor,
                                    fontSize:
                                        MediaQuery.of(context).size.width < 360
                                            ? 10
                                            : 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  weekendStyle: TextStyle(
                                    color: AppTheme.textSecondaryColor,
                                    fontSize:
                                        MediaQuery.of(context).size.width < 360
                                            ? 10
                                            : 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        // Collapsed view - just show a hint
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            'Swipe down to expand calendar',
                            style: AppTheme.captionStyle.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Selected day header with quick add button
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingMedium),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: const Border(
                    bottom: BorderSide(
                      color: AppTheme.dividerColor,
                      width: 1,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(5),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Selected date with indicator of events count
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              DateFormat('MMMM d, yyyy').format(_selectedDay),
                              style: AppTheme.subtitle1Style.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacingSmall),
                          // Event count indicator
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingSmall,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_getEventsForDay(_selectedDay).length} events',
                              style: AppTheme.captionStyle.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Quick add button
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppConstants.eventCreationRoute,
                          arguments:
                              _selectedDay, // Pass selected day to pre-fill date
                        ).then((_) => _loadEvents());
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingMedium,
                          vertical: AppTheme.spacingSmall,
                        ),
                        backgroundColor: Colors.white, // Changed to white
                        foregroundColor:
                            AppTheme.primaryColor, // Changed to primary color
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(
                              color: AppTheme.primaryColor), // Added border
                        ),
                        textStyle: AppTheme.buttonStyle.copyWith(
                          fontSize: 14,
                          color:
                              AppTheme.primaryColor, // Changed to primary color
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Events for selected day
              Expanded(
                child: _buildEventsForSelectedDay(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEventsForSelectedDay() {
    final eventsForDay = _getEventsForDay(_selectedDay);

    if (eventsForDay.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.contentPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Empty state illustration
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withAlpha(20),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 40,
                      color: AppTheme.primaryColor.withAlpha(100),
                    ),
                    Positioned(
                      bottom: 25,
                      right: 25,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.primaryColor.withAlpha(50),
                          ),
                        ),
                        child: const Icon(
                          Icons.event_busy,
                          size: 20,
                          color: AppTheme.accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingLarge),

              // Message
              Text(
                'No events on ${DateFormat('MMMM d, yyyy').format(_selectedDay)}',
                style: AppTheme.subtitle1Style.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingSmall),

              Text(
                'Create your first event for this day',
                style: AppTheme.body2Style.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingLarge),

              // Add event button
              SizedBox(
                width: 180,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppConstants.eventCreationRoute,
                      arguments:
                          _selectedDay, // Pass selected day to pre-fill date
                    ).then((_) => _loadEvents());
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Event'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.spacingMedium,
                    ),
                    backgroundColor: Colors.white, // Changed to white
                    foregroundColor:
                        AppTheme.primaryColor, // Changed to primary color
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(
                          color: AppTheme.primaryColor), // Added border
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Group events by time period (morning, afternoon, evening)
    final Map<String, List<EventModel>> eventsByTimePeriod = {
      'All Day': [],
      'Morning': [],
      'Afternoon': [],
      'Evening': [],
    };

    for (final event in eventsForDay) {
      if (event.isAllDay) {
        eventsByTimePeriod['All Day']!.add(event);
      } else {
        final hour = event.startTime.hour;
        if (hour < 12) {
          eventsByTimePeriod['Morning']!.add(event);
        } else if (hour < 17) {
          eventsByTimePeriod['Afternoon']!.add(event);
        } else {
          eventsByTimePeriod['Evening']!.add(event);
        }
      }
    }

    // Sort events within each time period
    for (final period in eventsByTimePeriod.keys) {
      eventsByTimePeriod[period]!
          .sort((a, b) => a.startTime.compareTo(b.startTime));
    }

    // Build the list with sections
    return ListView.builder(
      itemCount: eventsByTimePeriod.keys.length,
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      itemBuilder: (context, sectionIndex) {
        final timePeriod = eventsByTimePeriod.keys.elementAt(sectionIndex);
        final eventsInPeriod = eventsByTimePeriod[timePeriod]!;

        // Skip empty sections
        if (eventsInPeriod.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time period header
            Padding(
              padding: EdgeInsets.only(
                top: sectionIndex == 0 ? 0 : AppTheme.spacingMedium,
                bottom: AppTheme.spacingSmall,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingSmall,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getTimePeriodColor(timePeriod).withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getTimePeriodIcon(timePeriod),
                          size: 14,
                          color: _getTimePeriodColor(timePeriod),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timePeriod.toUpperCase(),
                          style: AppTheme.captionStyle.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getTimePeriodColor(timePeriod),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingSmall),
                      child: Container(
                        height: 1,
                        color: AppTheme.dividerColor,
                      ),
                    ),
                  ),
                  // Event count for this period
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.dividerColor),
                    ),
                    child: Text(
                      '${eventsInPeriod.length}',
                      style: AppTheme.captionStyle.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Events in this time period
            ...eventsInPeriod.map((event) {
              final eventColor = EventUtils.getEventColor(event);

              return Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spacingSmall),
                child: Card(
                  margin: EdgeInsets.zero,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () => _viewEventDetails(event),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: eventColor,
                            width: 6,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.spacingMedium),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Time indicator (for non-all-day events)
                            if (!event.isAllDay)
                              Container(
                                margin: const EdgeInsets.only(
                                    right: AppTheme.spacingSmall),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: eventColor.withAlpha(20),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  DateFormat('h:mm a').format(event.startTime),
                                  style: AppTheme.captionStyle.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: eventColor,
                                  ),
                                ),
                              ),

                            // Event details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title with duration indicator
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          event.title,
                                          style:
                                              AppTheme.subtitle2Style.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textPrimaryColor,
                                          ),
                                        ),
                                      ),
                                      if (!event.isAllDay) ...[
                                        const SizedBox(
                                            width: AppTheme.spacingSmall),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.surfaceColor,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            _formatDuration(
                                                event.startTime, event.endTime),
                                            style:
                                                AppTheme.captionStyle.copyWith(
                                              color:
                                                  AppTheme.textSecondaryColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),

                                  // Description preview (if available)
                                  if (event.description.isNotEmpty) ...[
                                    const SizedBox(
                                        height: AppTheme.spacingTiny),
                                    Text(
                                      event.description,
                                      style: AppTheme.body2Style.copyWith(
                                        color: AppTheme.textSecondaryColor,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],

                                  const SizedBox(height: AppTheme.spacingSmall),

                                  // Location and time in a row
                                  if (event.location.isNotEmpty ||
                                      !event.isAllDay)
                                    Row(
                                      children: [
                                        if (event.location.isNotEmpty) ...[
                                          const Icon(
                                            Icons.location_on,
                                            size: 14,
                                            color: AppTheme.textSecondaryColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              event.location,
                                              style: AppTheme.captionStyle,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                        if (!event.isAllDay &&
                                            event.location.isNotEmpty)
                                          const SizedBox(
                                              width: AppTheme.spacingMedium),
                                        if (!event.isAllDay) ...[
                                          const Icon(
                                            Icons.access_time,
                                            size: 14,
                                            color: AppTheme.textSecondaryColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${DateFormat('h:mm a').format(event.startTime)} - ${DateFormat('h:mm a').format(event.endTime)}',
                                            style: AppTheme.captionStyle,
                                          ),
                                        ],
                                      ],
                                    ),
                                ],
                              ),
                            ),

                            // Chevron icon
                            Container(
                              margin: const EdgeInsets.only(
                                  left: AppTheme.spacingSmall),
                              child: const Icon(
                                Icons.chevron_right,
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  // Helper method to get color for time period
  Color _getTimePeriodColor(String period) {
    switch (period) {
      case 'Morning':
        return AppTheme.primaryColor; // Blue
      case 'Afternoon':
        return AppTheme.secondaryColor; // Green
      case 'Evening':
        return AppTheme.accentColor; // Yellow
      case 'All Day':
        return AppTheme.errorColor; // Red
      default:
        return AppTheme.primaryColor;
    }
  }

  // Helper method to get icon for time period
  IconData _getTimePeriodIcon(String period) {
    switch (period) {
      case 'Morning':
        return Icons.wb_sunny;
      case 'Afternoon':
        return Icons.wb_cloudy;
      case 'Evening':
        return Icons.nightlight_round;
      case 'All Day':
        return Icons.event;
      default:
        return Icons.access_time;
    }
  }

  Widget _buildEventsList() {
    return RefreshIndicator(
      onRefresh: _loadEvents,
      color: AppTheme.primaryColor,
      backgroundColor: Colors.white,
      displacement: 40,
      child: ListView.builder(
        itemCount: _events.length,
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        itemBuilder: (context, index) {
          final event = _events[index];
          return Card(
            margin: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () => _viewEventDetails(event),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Color indicator
                    Container(
                      width: 4,
                      height: 80,
                      decoration: BoxDecoration(
                        color: EventUtils.getEventColor(event),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                    ),

                    // Event details
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.spacingMedium),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              event.title,
                              style: AppTheme.subtitle2Style.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimaryColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppTheme.spacingTiny),

                            // Date and time
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: AppTheme.textSecondaryColor,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    event.isAllDay
                                        ? 'All day: ${DateFormat('MMM dd, yyyy').format(event.startTime)}'
                                        : '${_formatDateTime(event.startTime)} - ${_formatDateTime(event.endTime)}',
                                    style: AppTheme.captionStyle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),

                            // Location (if available)
                            if (event.location.isNotEmpty) ...[
                              const SizedBox(height: AppTheme.spacingTiny),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      event.location,
                                      style: AppTheme.captionStyle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            // Description preview (if available)
                            if (event.description.isNotEmpty) ...[
                              const SizedBox(height: AppTheme.spacingTiny),
                              Text(
                                event.description,
                                style: AppTheme.captionStyle.copyWith(
                                  color: AppTheme.textSecondaryColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // Chevron icon
                    Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingMedium),
                      child: Icon(
                        Icons.chevron_right,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
