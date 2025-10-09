import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_models/event_model.dart';
import 'package:table_calendar/table_calendar.dart';

class EventsCalendar extends StatefulWidget {
  final List<Event> events;
  final Function(DateTime selectedDate) selectedDate;
  final DateTime? selectedDay;

  const EventsCalendar(
      {super.key,
      required this.events,
      this.selectedDay,
      required this.selectedDate});

  @override
  State<EventsCalendar> createState() => _EventsCalendarState();
}

class _EventsCalendarState extends State<EventsCalendar> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;

  Set<DateTime> _highlightedDates = {};

  @override
  void initState() {
    super.initState();
    // getEventStartDate();
    _selectedDay = widget.selectedDay ?? DateTime.now();
    _focusedDay = widget.selectedDay ?? DateTime.now();
  }

  @override
  void didUpdateWidget(covariant EventsCalendar oldWidget) {
    if (oldWidget.events != widget.events) {
      getEventStartDate();
    }
    super.didUpdateWidget(oldWidget);
  }

  void getEventStartDate() {
    _highlightedDates =
        widget.events.map((event) => DateTime.parse(event.startDate)).toSet();
    setState(() {});
  }

  List<Event> getEventsForDay(DateTime day) {
    return widget.events
        .where((event) =>
            DateTime.parse(event.startDate).day == day.day &&
            DateTime.parse(event.startDate).month == day.month &&
            DateTime.parse(event.startDate).year == day.year)
        .toList();
  }

  bool _isHighlighted(DateTime day) {
    return _highlightedDates.contains(DateTime(day.year, day.month, day.day));
  }

  Widget _buildDayCell(DateTime day, TextStyle textStyle,
      {Color? backgroundColor}) {
    return Container(
      height: 36.w,
      width: 40.w,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(30.0).r,
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: textStyle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.appBarBackground,
        borderRadius: BorderRadius.circular(8).r,
      ),
      padding: EdgeInsets.all(12).r,
      child: TableCalendar(
        availableGestures: AvailableGestures.horizontalSwipe,
        weekNumbersVisible: false,
        daysOfWeekVisible: true,
        headerStyle: HeaderStyle(
          headerMargin: EdgeInsets.all(0),
          headerPadding: EdgeInsets.all(0),
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: GoogleFonts.lato(
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
          ),
        ),
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          widget.selectedDate(selectedDay);

          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onPageChanged: (focusedDay) {
          if (focusedDay.month == DateTime.now().month &&
              focusedDay.year == DateTime.now().year) {
            _selectedDay = DateTime.now();
          } else {
            _selectedDay = focusedDay;
          }

          widget.selectedDate(_selectedDay);
          setState(() {
            _focusedDay = focusedDay;
          });
        },
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          todayTextStyle: TextStyle(color: AppColors.appBarBackground),
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (_isHighlighted(date)) {
              DateTime today = DateTime.now();
              DateTime dateOnly = DateTime(date.year, date.month, date.day);
              DateTime todayOnly = DateTime(today.year, today.month, today.day);
              Color dotColor = dateOnly.isAfter(todayOnly) ||
                      dateOnly.isAtSameMomentAs(todayOnly)
                  ? AppColors.mandatoryRed
                  : AppColors.grey40;
              return Container(
                height: 5.w,
                width: 5.w,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              );
            }
            return SizedBox.shrink();
          },
          defaultBuilder: (context, day, focusedDay) {
            return _buildDayCell(
              day,
              GoogleFonts.lato(
                color: day.isAfter(DateTime.now())
                    ? AppColors.greys
                    : AppColors.grey40,
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
            );
          },
          todayBuilder: (context, day, focusedDay) {
            return _buildDayCell(
              day,
              GoogleFonts.lato(
                color: AppColors.greys,
                fontSize: 12.sp,
              ),
              backgroundColor: AppColors.currentDateBackground,
            );
          },
          selectedBuilder: (context, day, focusedDay) {
            return _buildDayCell(
              day,
              GoogleFonts.lato(
                color: AppColors.appBarBackground,
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
              backgroundColor: AppColors.primaryOne,
            );
          },
        ),
      ),
    );
  }
}
