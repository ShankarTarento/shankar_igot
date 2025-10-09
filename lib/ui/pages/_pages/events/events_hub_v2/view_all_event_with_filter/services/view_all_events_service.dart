import 'dart:convert';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/models/_models/event_model.dart';
import 'package:karmayogi_mobile/services/_services/events_service.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/event_constants.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';

class ViewAllEventsService {
  Future<List<Event>> filterEvents({
    List<String>? eventDateTimeFilter,
    String? startDateFilter,
    String? endDateFilter,
    List<String>? eventStatusFilter,
    String? searchText,
    int limit = 50,
    int offset = 0,
    bool getCuratedEvents = false,
    List<String> resourceType = const [],
    Map? sortBy,
  }) async {
    List<Event> eventsList = [];
    List<String>? startDate;
    List<String>? endDate;
    Map? startDateTimeInEpoch;
    Map? endDateTimeInEpoch;
    if (startDateFilter != null && startDateFilter.isNotEmpty) {
      startDate = [startDateFilter];
    }
    if (endDateFilter != null && endDateFilter.isNotEmpty) {
      endDate = [endDateFilter];
    }
    if (eventDateTimeFilter != null && eventDateTimeFilter.isNotEmpty) {
      Map<String, dynamic> eventDateTime =
          getEventDateTime(eventDateTimeFilter);
      startDate = eventDateTime['startDate'] ?? [];
      endDate = eventDateTime["endDate"] ?? [];
    }
    if (eventStatusFilter != null && eventStatusFilter.isNotEmpty) {
      Map<String, dynamic> eventStatus =
          getEventStatusFilteredEvents(eventStatusFilter: eventStatusFilter);

      startDateTimeInEpoch = eventStatus['startDateTimeInEpoch'];
      endDateTimeInEpoch = eventStatus["endDateTimeInEpoch"];
    }

    try {
      final response = await EventService().filterEventsV2(
          endDateTimeInEpoch: endDateTimeInEpoch,
          startDateTimeInEpoch: startDateTimeInEpoch,
          searchText: searchText,
          getCuratedEvents: getCuratedEvents,
          resourceType: resourceType,
          startDate: startDate,
          endDate: endDate,
          limit: limit,
          offset: offset,
          sortBy: sortBy);

      if (response.statusCode == 200) {
        var contents = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> events = contents['result']['Event'];
        if (events.isNotEmpty) {
          eventsList =
              events.map((dynamic item) => Event.fromJson(item)).toList();
        }

        return eventsList;
      } else {
        throw Exception('Error: ${response.statusCode.toString()}');
      }
    } catch (e) {
      print('Error occurred while filtering events: $e');
      return [];
    }
  }

  Map<String, dynamic> getEventDateTime(List<String> dateTime) {
    Map<String, dynamic> eventDateTime = {};
    switch (dateTime) {
      case [EventFilter.today]:
        eventDateTime = {
          "startDate": [
            DateTimeHelper.convertDateFormat(DateTime.now().toString(),
                inputFormat: IntentType.dateFormat4,
                desiredFormat: IntentType.dateFormat4)
          ],
          "endDate": [
            DateTimeHelper.convertDateFormat(DateTime.now().toString(),
                inputFormat: IntentType.dateFormat4,
                desiredFormat: IntentType.dateFormat4)
          ],
        };
        break;
      case [EventFilter.tomorrow]:
        eventDateTime = {
          "startDate": [
            DateTimeHelper.convertDateFormat(
                DateTime.now().add(Duration(days: 1)).toString(),
                inputFormat: IntentType.dateFormat4,
                desiredFormat: IntentType.dateFormat4)
          ],
          "endDate": [
            DateTimeHelper.convertDateFormat(
                DateTime.now().add(Duration(days: 1)).toString(),
                inputFormat: IntentType.dateFormat4,
                desiredFormat: IntentType.dateFormat4)
          ],
        };
        break;
      case [EventFilter.today, EventFilter.tomorrow] ||
            [EventFilter.tomorrow, EventFilter.today]:
        eventDateTime = {
          "startDate": [
            DateTimeHelper.convertDateFormat(DateTime.now().toString(),
                inputFormat: IntentType.dateFormat4,
                desiredFormat: IntentType.dateFormat4),
            DateTimeHelper.convertDateFormat(
                DateTime.now().add(Duration(days: 1)).toString(),
                inputFormat: IntentType.dateFormat4,
                desiredFormat: IntentType.dateFormat4),
          ],
          "endDate": [
            DateTimeHelper.convertDateFormat(DateTime.now().toString(),
                inputFormat: IntentType.dateFormat4,
                desiredFormat: IntentType.dateFormat4),
            DateTimeHelper.convertDateFormat(
                DateTime.now().add(Duration(days: 1)).toString(),
                inputFormat: IntentType.dateFormat4,
                desiredFormat: IntentType.dateFormat4),
          ]
        };
        break;
      default:
        break;
    }
    return eventDateTime;
  }

  Map<String, dynamic> getEventStatusFilteredEvents(
      {required List<String> eventStatusFilter}) {
    if (eventStatusFilter.isNotEmpty) {
      switch (eventStatusFilter[0]) {
        case EventFilter.live:
          return {
            "startDateTimeInEpoch": {
              "<=": DateTime.now().millisecondsSinceEpoch
            },
            "endDateTimeInEpoch": {">=": DateTime.now().millisecondsSinceEpoch}
          };
        case EventFilter.upcoming:
          return {
            "startDateTimeInEpoch": {
              ">=": DateTime.now().millisecondsSinceEpoch
            }
          };
        case EventFilter.past:
          return {
            "endDateTimeInEpoch": {"<=": DateTime.now().millisecondsSinceEpoch}
          };
        default:
      }
    }
    return {};
  }
}
