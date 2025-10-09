import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import './../constants/index.dart';

class DateTimeHelper {
  static getTimeFormat(duration) {
    Duration parsedDuration = Duration(seconds: int.parse(duration));

    int hours = parsedDuration.inHours;
    int minutes = parsedDuration.inMinutes;
    int balMin = (minutes - hours * 60);
    int balSec = parsedDuration.inSeconds - (balMin * 60) - (hours * 60 * 60);

    if (balSec > 30) {
      balMin = balMin + 1;
    }

    String time;
    if (hours > 0) {
      time = hours.toString() + 'h ' + balMin.toString() + 'm';
    } else {
      time = minutes.toString() + ' m';
    }
    return time;
  }

  static int convertTimeToSeconds(String timeString) {
    final regex = RegExp(r'(\d+)\s*h\s*(\d+)\s*m|(\d+)\s*m');

    final match = regex.firstMatch(timeString);

    if (match != null) {
      if (match.group(1) != null && match.group(2) != null) {
        int hours = int.parse(match.group(1)!);
        int minutes = int.parse(match.group(2)!);
        return (hours * 3600) + (minutes * 60);
      } else if (match.group(3) != null) {
        int minutes = int.parse(match.group(3)!);
        return minutes * 60;
      }
    }

    return 0;
  }

  static formatTimeForEvents(time) {
    String timeHourFormat = time.substring(0, 5);
    return timeHourFormat;
  }

  static String getTimeFormatInHrs(int durationInMinutes) {
    if (durationInMinutes < 60) {
      return '${durationInMinutes}m';
    } else {
      int hours = durationInMinutes ~/ 60;
      int minutes = durationInMinutes % 60;
      if (minutes > 0) {
        return '${hours}h ${minutes}m';
      } else {
        return '${hours}h';
      }
    }
  }

  static TimeOfDay getTimeIn24HourFormat(String timeIn12HourFormat) {
    List timeSplits = timeIn12HourFormat.split(':'); // eg. 12:30 PM
    String hourString = timeSplits.first;
    String minString = timeSplits.last.split(' ').first;
    int min = int.parse(minString);
    int hour = int.parse(hourString);
    hour =
        (hour != 12 && timeSplits.last.toString().toLowerCase().contains('pm'))
            ? hour + 12
            : hour;

    return TimeOfDay(hour: hour, minute: min);
  }

  static String getDateTimeInFormat(String dateTime,
      {String? desiredDateFormat}) {
    if (desiredDateFormat == null) {
      desiredDateFormat = IntentType.dateFormat;
    }
    final DateFormat formatter = DateFormat(desiredDateFormat);
    return formatter.format(DateTime.parse(dateTime));
  }

  static getFullTimeFormat(duration, {bool timelyDurationFlag = false}) {
    int hours = Duration(seconds: int.parse(duration)).inHours;
    int minutes = Duration(seconds: int.parse(duration)).inMinutes;
    int seconds = Duration(seconds: int.parse(duration)).inSeconds;
    String time;
    if (hours > 0) {
      if ((minutes - hours * 60) > 0) {
        time = hours.toString() +
            (timelyDurationFlag
                ? hours == 1
                    ? ' hour '
                    : ' hours '
                : 'h ') +
            (minutes - hours * 60).toString() +
            (timelyDurationFlag
                ? (minutes - hours * 60) == 1
                    ? ' minute '
                    : ' minutes '
                : 'm ');
      } else {
        time = hours.toString() +
            (timelyDurationFlag
                ? hours == 1
                    ? ' hour '
                    : ' hours '
                : 'h ');
      }
    } else if (minutes > 0) {
      if ((seconds - minutes * 60) > 0) {
        time = minutes.toString() +
            (timelyDurationFlag
                ? minutes == 1
                    ? ' minute '
                    : ' minutes '
                : 'm ') +
            (seconds - minutes * 60).toString() +
            (timelyDurationFlag
                ? seconds - minutes * 60 == 1
                    ? ' second '
                    : ' seconds '
                : 's');
      } else {
        time = minutes.toString() +
            (timelyDurationFlag
                ? minutes == 1
                    ? ' minute '
                    : ' minutes '
                : 'm ');
      }
    } else {
      time = seconds.toString() +
          (timelyDurationFlag
              ? seconds == 1
                  ? ' second '
                  : ' seconds '
              : 's');
    }
    return time;
  }

  static int getMilliSecondsFromTimeFormat(String duration) {
    List data = duration.split(' ');
    int totalDuration = 0;
    RegExp regex = RegExp(
        r'^\s*\d+\s*(h|hr|hour|hrs|m|min|minute|mins|s|sec|second|secs)\s*$',
        caseSensitive: false);
    data.removeWhere((element) => !(regex.hasMatch(element)));
    if (data.isEmpty) {
      return int.parse(duration);
    }
    for (var i = 0; i < data.length; i++) {
      int value =
          int.parse(data[i].toString().substring(0, data[i].length - 1));
      if (data[i].contains('h')) {
        totalDuration = totalDuration + (value * 60 * 60);
      } else if (data[i].contains('m')) {
        totalDuration = totalDuration + (value * 60);
      } else if (data[i].contains('s')) {
        totalDuration = totalDuration + value;
      }
    }
    return totalDuration;
  }

  static getMonth(String month) {
    int intMonth = 0;
    switch (month) {
      case 'Jan':
        intMonth = 1;
        break;
      case 'Feb':
        intMonth = 2;
        break;
      case 'Mar':
        intMonth = 3;
        break;
      case 'Apr':
        intMonth = 4;
        break;
      case 'May':
        intMonth = 5;
        break;
      case 'Jun':
        intMonth = 6;
        break;
      case 'Jul':
        intMonth = 7;
        break;
      case 'Aug':
        intMonth = 8;
        break;
      case 'Sep':
        intMonth = 9;
        break;
      case 'Oct':
        intMonth = 10;
        break;
      case 'Nov':
        intMonth = 11;
        break;
      case 'Dec':
        intMonth = 12;
        break;
      default:
    }
    return intMonth;
  }

  static DateTime convertDDMMYYYYtoDateTime(String date) {
    DateTime parsedDate =
        DateFormat(DateFormatString.ddMMyyyy).parse(date.toString());
    return parsedDate;
  }

  static String convertDateFormat(String date,
      {required String inputFormat, required String desiredFormat}) {
    DateTime parsedDate = DateFormat(inputFormat).parse(date.toString());
    return DateFormat(desiredFormat).format(parsedDate);
  }

  static bool checkDateFormat(String dateStr, {required String dateFormatStr}) {
    try {
      DateFormat dateFormat = DateFormat(dateFormatStr);
      dateFormat.parseStrict(dateStr);
      return true;
    } catch (e) {
      return false;
    }
  }

  static String convertDatetimetoDDMMYYYY(DateTime date) {
    return date.toString().split(' ').first.split('-').reversed.join('-');
  }

  static String convertDatetimetoDDMonthYYYY(String date) {
    if (checkDateFormat(date, dateFormatStr: DateFormatString.yyyyMMdd)) {
      date = convertDateFormat(date,
          inputFormat: DateFormatString.yyyyMMdd,
          desiredFormat: DateFormatString.ddMMyyyy);
    }
    // Parse the date string eg: 10-12-1986
    DateTime parsedDate =
        DateFormat(DateFormatString.ddMMyyyy).parse(date.toString());
    // Format the date to eg: '10 Dec 1986'
    String formattedDate =
        DateFormat(DateFormatString.ddMonthyyyy).format(parsedDate);
    return formattedDate;
  }

  static String formatDate(DateTime dateTime) {
    DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    return dateFormat.format(dateTime);
  }

  static bool isDateXDaysBefore(int timeInMilliSeconds) {
    if (timeInMilliSeconds == '') return false;
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timeInMilliSeconds);
    DateTime currentDate = DateTime.now();
    DateTime xDaysAgo =
        currentDate.subtract(Duration(days: RATING_DURATION_IN_DAYS));
    return dateTime.isBefore(xDaysAgo);
  }

  static DateTime getDateTimeFormatFromDateString(String dateString) {
    // String dateString = "27-05-2024 09.11.16";
    DateFormat dateFormat = DateFormat("dd-MM-yyyy HH.mm.ss");
    DateTime dateTime = dateFormat.parse(dateString);
    return dateTime;
  }

  static String convertTo12HourFormat(String time24hr) {
    if (time24hr.isEmpty)
      return time24hr;
    else if (time24hr.contains("+") || time24hr.contains("-")) {
      DateTime dateTime = DateFormat("hh:mm:ss").parse(time24hr);
      return DateFormat("hh:mm a").format(dateTime);
    }
    final time = DateFormat.Hm().parse(time24hr); // Parse time
    final formattedTime =
        DateFormat.jm().format(time); // Format to 12-hour format with AM/PM
    return formattedTime;
  }

  static String getDateTimeFormatYYYYMMDD(String dateString) {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    DateTime dateTime = dateFormat.parse(dateString);
    return DateFormat("yyyy-MM-dd").format(dateTime);
  }
}
