import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/models/_models/event_model.dart';
import 'package:karmayogi_mobile/services/_services/events_service.dart';
import 'package:http/http.dart';
import 'package:karmayogi_mobile/util/index.dart';

class MyEventsRepository extends ChangeNotifier {
  List<Event> todaysEvents = [];
  List<Event> upcomingEvents = [];
  List<Event> pastEvents = [];
  List<Event> allEnrolledEvents = [];
  final EventService eventService = EventService();

  Future<void> getAllEnrolledEvents() async {
    try {
      Response response = await eventService.getAllEnrolledEvents();
      allEnrolledEvents = [];
      if (response.statusCode == 200) {
        Map data = jsonDecode(utf8.decode(response.bodyBytes));
        List events = data['result']['events'] ?? [];

        allEnrolledEvents = events.map((event) {
          return Event.fromJson(event['event']);
        }).toList();

        todaysEvents.clear();
        upcomingEvents.clear();
        pastEvents.clear();

        for (Event event in allEnrolledEvents) {
          String status = Helper.getEventStatusBasedOnDate(event: event);

          switch (status) {
            case EnglishLang.today:
              todaysEvents.add(event);
              break;
            case EnglishLang.upcoming:
              upcomingEvents.add(event);
              break;
            case EnglishLang.past:
              pastEvents.add(event);
              break;
          }
        }

        todaysEvents = Helper.sortList(listOfEvents: todaysEvents);
        upcomingEvents = Helper.sortList(listOfEvents: upcomingEvents);
        pastEvents =
            Helper.sortList(listOfEvents: pastEvents, ascending: false);
      } else {
        debugPrint(
            'Failed to load events. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error occurred while fetching events: $e');
    }
    notifyListeners();
  }

  String formateTime(String time) {
    return time.substring(0, 5);
  }

  Future<List<Event>> getCalendarEnrolledEvents(
      {required String eventEndDate, required String eventStartDate}) async {
    try {
      Response response = await eventService.getEnrolledEvents(
          calendarEventEnabled: true,
          eventEndDate: eventEndDate,
          eventStartDate: eventStartDate);
      if (response.statusCode == 200) {
        Map data = jsonDecode(utf8.decode(response.bodyBytes));
        List events = data['result']['events'] ?? [];
        return events.map((event) {
          return Event.fromJson(event['event']);
        }).toList();
      }
    } catch (e) {}
    return [];
  }
}
