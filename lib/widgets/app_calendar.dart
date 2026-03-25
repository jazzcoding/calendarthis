import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class AppCalendar extends StatefulWidget {
  final DateTime initialDate;
  final DateTime? selectedDate;
  final ValueChanged<DateTime>? onDateSelected;
  final Map<DateTime, List<Color>>? eventMarkers;
  final bool showMonthStepper;

  AppCalendar({
    super.key,
    DateTime? initialDate,
    this.selectedDate,
    this.onDateSelected,
    this.eventMarkers,
    this.showMonthStepper = true,
  }) : initialDate = initialDate ?? DateTime.now();

  @override
  State<AppCalendar> createState() => _AppCalendarState();
}

class _AppCalendarState extends State<AppCalendar> {
  late DateTime _currentMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
    _selectedDate = widget.selectedDate ?? widget.initialDate;
  }

  @override
  void didUpdateWidget(AppCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != null &&
        widget.selectedDate != oldWidget.selectedDate) {
      _selectedDate = widget.selectedDate!;
      // Update current month if selected date is in a different month
      if (_selectedDate.month != _currentMonth.month ||
          _selectedDate.year != _currentMonth.year) {
        _currentMonth = DateTime(_selectedDate.year, _selectedDate.month);
      }
    }
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    if (widget.onDateSelected != null) {
      widget.onDateSelected!(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showMonthStepper) _buildMonthStepper(),
        _buildCalendarGrid(),
      ],
    );
  }

  Widget _buildMonthStepper() {
    final monthName = _getMonthName(_currentMonth.month);
    final year = _currentMonth.year;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _previousMonth,
            tooltip: 'Previous month',
          ),
          Text(
            '$monthName $year',
            style: AppTheme.subtitle1Style,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _nextMonth,
            tooltip: 'Next month',
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    return Column(
      children: [
        // Weekday headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _buildWeekdayHeaders(),
        ),
        const SizedBox(height: AppTheme.spacingSmall),
        // Calendar days
        ..._buildCalendarWeeks(),
      ],
    );
  }

  List<Widget> _buildWeekdayHeaders() {
    final weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return weekdays.map((day) {
      return SizedBox(
        width: AppTheme.calendarDaySize,
        height: AppTheme.calendarDaySize,
        child: Center(
          child: Text(
            day,
            style: AppTheme.body2Style.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildCalendarWeeks() {
    final List<Widget> weeks = [];
    final daysInMonth =
        _getDaysInMonth(_currentMonth.year, _currentMonth.month);
    final firstDayOfMonth =
        DateTime(_currentMonth.year, _currentMonth.month, 1);
    final firstWeekdayOfMonth =
        firstDayOfMonth.weekday % 7; // 0 for Sunday, 1 for Monday, etc.

    // Calculate days needed from previous month to fill first week
    final daysFromPreviousMonth = firstWeekdayOfMonth;

    // Calculate total days to display (including days from previous and next month)
    final totalDays = daysFromPreviousMonth + daysInMonth;
    final totalWeeks = (totalDays / 7).ceil();

    // Build each week
    for (int week = 0; week < totalWeeks; week++) {
      final weekRow = Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (dayIndex) {
          final dayNumber = (week * 7) + dayIndex + 1 - daysFromPreviousMonth;

          if (dayNumber < 1 || dayNumber > daysInMonth) {
            // Day from previous or next month
            return SizedBox(
                width: AppTheme.calendarDaySize,
                height: AppTheme.calendarDaySize);
          }

          final date =
              DateTime(_currentMonth.year, _currentMonth.month, dayNumber);
          final isToday = _isToday(date);
          final isSelected = _isSameDay(date, _selectedDate);
          final hasEvents = widget.eventMarkers != null &&
              widget.eventMarkers!.keys
                  .any((eventDate) => _isSameDay(eventDate, date));

          return _buildCalendarDay(date, isToday, isSelected, hasEvents);
        }),
      );

      weeks.add(Padding(
        padding: const EdgeInsets.only(bottom: AppTheme.spacingSmall),
        child: weekRow,
      ));
    }

    return weeks;
  }

  Widget _buildCalendarDay(
      DateTime date, bool isToday, bool isSelected, bool hasEvents) {
    // Get event markers for this date
    List<Color> eventColors = [];
    if (hasEvents && widget.eventMarkers != null) {
      widget.eventMarkers!.forEach((eventDate, colors) {
        if (_isSameDay(eventDate, date)) {
          eventColors.addAll(colors);
        }
      });
    }

    return InkWell(
      onTap: () => _selectDate(date),
      borderRadius: BorderRadius.circular(AppTheme.calendarDaySize / 2),
      child: Container(
        width: AppTheme.calendarDaySize,
        height: AppTheme.calendarDaySize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          border: isToday && !isSelected
              ? Border.all(color: AppTheme.primaryColor, width: 2)
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              date.day.toString(),
              style: AppTheme.body1Style.copyWith(
                color: isSelected
                    ? Colors.white
                    : isToday
                        ? AppTheme.primaryColor
                        : AppTheme.textPrimaryColor,
                fontWeight:
                    isToday || isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (hasEvents)
              Positioned(
                bottom: 4,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: eventColors.take(3).map((color) {
                    return Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  String _getMonthName(int month) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return monthNames[month - 1];
  }

  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
