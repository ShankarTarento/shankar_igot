import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../../constants/_constants/color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../model/microsites_training_calender_data_model.dart';

class MicroSitesTrainingCalendarItemView extends StatefulWidget {
  final bool isShowAllEvents;
  final List<EventDataModel>? eventDataModelList;
  final String? monthName;
  final int? year;
  final int? startDate;

  MicroSitesTrainingCalendarItemView({
    this.isShowAllEvents = false,
    this.eventDataModelList,
    this.monthName,
    this.year,
    this.startDate,
    Key? key,
  }) : super(key: key);

  @override
  _MicroSitesTrainingCalendarItemViewState createState() {
    return _MicroSitesTrainingCalendarItemViewState();
  }
}

class _MicroSitesTrainingCalendarItemViewState
    extends State<MicroSitesTrainingCalendarItemView> {
  List<MicroSitesTrainingCalenderItems> trainingCalenderItems = [];
  int eventCountToDisplay = 1;

  @override
  void initState() {
    super.initState();
    getEventDataWithDates(widget.monthName!, widget.year!, widget.startDate!);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: _calendarListView());
  }

  Widget _calendarListView() {
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: (widget.isShowAllEvents)
            ? trainingCalenderItems.length
            : (trainingCalenderItems.length > eventCountToDisplay)
                ? eventCountToDisplay
                : trainingCalenderItems.length,
        itemBuilder: (context, index) {
          return _calendarItemView(
              trainingCalenderItem: trainingCalenderItems[index]);
        });
  }

  Widget _calendarItemView(
      {MicroSitesTrainingCalenderItems? trainingCalenderItem}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4).w,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              width: 60.w,
              padding: EdgeInsets.all(4).w,
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    trainingCalenderItem!.dayOfMonth!.toUpperCase(),
                    style: GoogleFonts.montserrat(
                      color: AppColors.greys87,
                      fontWeight: widget.isShowAllEvents
                          ? FontWeight.w400
                          : FontWeight.w700,
                      fontSize: widget.isShowAllEvents ? 12.sp : 14.sp,
                      height: 1.5.w,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  (getCurrentDate().toString() ==
                          trainingCalenderItem.formattedDateOfMonth.toString())
                      ? Container(
                          height: widget.isShowAllEvents ? 24.sp : 32.sp,
                          width: 32.sp,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(100.sp)),
                              color: AppColors.positiveLight),
                          alignment: Alignment.center,
                          child: Text(
                            trainingCalenderItem.dateOfMonth!,
                            style: GoogleFonts.montserrat(
                              color: AppColors.appBarBackground,
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      : Text(
                          trainingCalenderItem.dateOfMonth!,
                          style: GoogleFonts.montserrat(
                            color: AppColors.greys87,
                            fontWeight: FontWeight.w700,
                            fontSize: 14.sp,
                            height: 1.5.w,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                  Text(
                    trainingCalenderItem.month!.toUpperCase(),
                    style: GoogleFonts.montserrat(
                      color: AppColors.greys87,
                      fontWeight: widget.isShowAllEvents
                          ? FontWeight.w400
                          : FontWeight.w700,
                      fontSize: widget.isShowAllEvents ? 12.sp : 14.sp,
                      height: 1.5.w,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              )),
          eventView(trainingCalenderItem.events!)
        ],
      ),
    );
  }

  Widget eventView(List<EventDataModel> events) {
    return Expanded(
      child: events.isNotEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...List.generate(
                  events.length,
                  (index) => Container(
                      margin: EdgeInsets.symmetric(vertical: 4).w,
                      padding: EdgeInsets.all(8).w,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10.w)),
                          border: Border.all(color: AppColors.grey16),
                          color: AppColors.seaShell),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            events[index].name!,
                            style: GoogleFonts.lato(
                              color: AppColors.greys87,
                              fontWeight: FontWeight.w400,
                              fontSize: 14.sp,
                              height: 1.5.h,
                            ),
                          ),
                          if (((events[index].endTime ?? '').toString() !=
                                  '') ||
                              ((events[index].endTime ?? '').toString() != ''))
                            Padding(
                              padding: EdgeInsets.only(top: 8).w,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(right: 8),
                                    child: Icon(
                                      Icons.access_time,
                                      size: 18.w,
                                      color: AppColors.greys60,
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      '${getFormattedTime(events[index].startTime!)} to ${getFormattedTime(events[index].endTime!)}',
                                      style: GoogleFonts.lato(
                                        color: AppColors.greys87,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          if ((events[index].endDate ?? '').toString() != '')
                            Padding(
                              padding: EdgeInsets.only(top: 8).w,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(right: 8).w,
                                    child: Icon(
                                      Icons.calendar_today,
                                      size: 18.w,
                                      color: AppColors.greys60,
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      '${getFormattedDate(events[index].startDate!)} to ${getFormattedDate(events[index].endDate!)}',
                                      style: GoogleFonts.lato(
                                        color: AppColors.greys87,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          if (getAddress(events[index].venue ?? '', "")
                                  .toString() !=
                              '')
                            Padding(
                              padding: EdgeInsets.only(top: 8).w,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(right: 8).w,
                                    child: Icon(
                                      Icons.location_on,
                                      size: 18.w,
                                      color: AppColors.greys60,
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      getAddress(events[index].venue ?? '', ""),
                                      style: GoogleFonts.lato(
                                        color: AppColors.greys87,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          if (getAddress(events[index].location ?? '',
                                      events[index].eventType ?? '')
                                  .toString() !=
                              '')
                            Padding(
                              padding: EdgeInsets.only(top: 8).w,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(right: 8).w,
                                    child: Icon(
                                      Icons.location_on,
                                      size: 18.w,
                                      color: AppColors.greys60,
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      getAddress(events[index].location ?? '',
                                          events[index].eventType ?? ''),
                                      style: GoogleFonts.lato(
                                        color: AppColors.greys87,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                        ],
                      )),
                )
              ],
            )
          : Container(
              margin: EdgeInsets.symmetric(vertical: 4).w,
              padding: EdgeInsets.all(16).w,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10.w)),
                  color: AppColors.appBarBackground,
                  border: Border.all(color: AppColors.grey16)),
              child: Text(
                AppLocalizations.of(context)!.mStaticNoTraining,
                style: GoogleFonts.lato(
                  color: AppColors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: 14.sp,
                  height: 1.5.w,
                ),
              ),
            ),
    );
  }

  String getCurrentDate() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  void getEventDataWithDates(String monthName, int year, int startDate) {
    List<DateTime> dates = getDatesForMonth(monthName, year, startDate);

    DateFormat dayFormatter = DateFormat('EEE'); // Day with three letters
    DateFormat dateFormatter = DateFormat('dd'); // Date as two digits
    DateFormat monthFormatter = DateFormat('MMM'); // Month with three letters
    DateFormat completeDateFormatter = DateFormat('yyyy-MM-dd');

    dates.forEach((date) {
      List<EventDataModel> events = [];
      widget.eventDataModelList!.forEach((element) {
        if (element.startDate.toString() ==
            completeDateFormatter.format(date).toString()) {
          events.add(element);
        }
      });
      trainingCalenderItems.add(MicroSitesTrainingCalenderItems(
          dayOfMonth: dayFormatter.format(date),
          dateOfMonth: dateFormatter.format(date),
          month: monthFormatter.format(date),
          formattedDateOfMonth: completeDateFormatter.format(date),
          events: events));
    });
  }

  List<DateTime> getDatesForMonth(String monthName, int year, int startDate) {
    int month = getMonthNumber(monthName);
    DateTime firstDay = DateTime(year, month, startDate);
    DateTime lastDay = DateTime(year, month + 1, 0);

    List<DateTime> dates = [];
    for (int i = firstDay.day; i <= lastDay.day; i++) {
      dates.add(DateTime(year, month, i));
    }

    return dates;
  }

  int getMonthNumber(String monthName) {
    switch (monthName.toLowerCase()) {
      case 'january':
        return 1;
      case 'february':
        return 2;
      case 'march':
        return 3;
      case 'april':
        return 4;
      case 'may':
        return 5;
      case 'june':
        return 6;
      case 'july':
        return 7;
      case 'august':
        return 8;
      case 'september':
        return 9;
      case 'october':
        return 10;
      case 'november':
        return 11;
      case 'december':
        return 12;
      default:
        throw ArgumentError('Invalid month name');
    }
  }

  String getAddress(String venue, String type) {
    if (type.isEmpty) return '';
    if (type.toLowerCase() == "offline") {
      try {
        Map<String, dynamic> venueMap = jsonDecode(venue);
        if ((venueMap['address'] ?? '') != '')
          return venueMap['address'];
        else
          return '';
      } catch (e) {
        return '';
      }
    } else {
      return type;
    }
  }

  String getFormattedTime(String time) {
    String dateTimeString = '1970-01-01T' + time;
    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      DateFormat formatter = DateFormat('hh:mm a');
      String formattedTime = formatter.format(dateTime.toLocal());
      return formattedTime;
    } catch (e) {
      return time;
    }
  }

  String getFormattedDate(String date) {
    try {
      DateTime dateTime = DateTime.parse(date);
      DateFormat formatter = DateFormat('EEE, dd MMM');
      return formatter.format(dateTime).toUpperCase();
    } catch (e) {
      return date;
    }
  }
}
