import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:karmayogi_mobile/constants/_constants/api_endpoints.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/models/_models/event_detailv2_model.dart';
import 'package:karmayogi_mobile/models/_models/event_model.dart';
import 'package:karmayogi_mobile/services/_services/events_service.dart';
import 'package:karmayogi_mobile/services/_services/learn_service.dart';

import '../../ui/pages/_pages/search/models/event_search_model.dart';
import '../../models/_models/event_summary.dart';
import '../../ui/widgets/_events/models/event_enroll_model.dart';
import '../../ui/widgets/_events/models/event_state_model.dart';

class EventRepository with ChangeNotifier {
  final EventService eventService = EventService();
  String _errorMessage = '';
  List<Event> eventsList = [];
  Response? _data;

  UserEventEnrolmentInfo _userEventEnrolmentInfo =
      UserEventEnrolmentInfo.defaultValue();
  UserEventEnrolmentInfo get userEventEnrolmentInfo => _userEventEnrolmentInfo;

  double? _eventCompletionDuration;
  double get eventCompletionDurationInSeconds =>
      _eventCompletionDuration ?? EVENT_COMPLETION_DURATION;

  Map<String, dynamic> _evenConfigData = {};
  Map<String, dynamic> get evenConfigData => _evenConfigData;
  LearnService learnService = LearnService();

  EventRepository() {
    getEventsConfig();
  }

  Future<UserEventEnrolmentInfo> getEventsSummary() async {
    try {
      final response = await eventService.getEventsSummary();
      if (response.statusCode == 200) {
        var contents = jsonDecode(response.body);
        _userEventEnrolmentInfo = UserEventEnrolmentInfo.fromJson(
            contents['result']['userEventEnrolmentInfo']);
        return _userEventEnrolmentInfo;
      } else {
        return _userEventEnrolmentInfo;
      }
    } catch (_) {
      return _userEventEnrolmentInfo;
    }
  }

  Future<List<Event>> getAllEvents({String? startDate}) async {
    try {
      final response = await eventService.getAllEvents(startDate: startDate);
      _data = response;
      if (_data?.statusCode == 200) {
        var contents = jsonDecode(_data!.body);
        List<dynamic> events = contents['result']['Event'];
        eventsList = events
            .map(
              (dynamic item) => Event.fromJson(item),
            )
            .toList();
        return eventsList;
      } else {
        _errorMessage = _data!.statusCode.toString();
        throw _errorMessage;
      }
    } catch (_) {
      return [];
    }
  }

  Future<List<Event>> getEventsForMDO() async {
    try {
      Response response = await eventService.getEventsForMDO();
      _data = response;
    } catch (_) {
      return [];
    }
    if (_data!.statusCode == 200) {
      var contents = jsonDecode(_data!.body);
      List<dynamic> events = contents['result']['Event'] != null
          ? contents['result']['Event']
          : [];
      eventsList = events
          .map(
            (dynamic item) => Event.fromJson(item),
          )
          .toList();
      return eventsList;
    } else {
      // throw 'Can\'t get events.';
      _errorMessage = _data!.statusCode.toString();
      throw _errorMessage;
    }
  }

  Future<EventDetailV2?> getEventDetailsV2(String id) async {
    try {
      Response response = await eventService.getEventDetails(id);
      if (response.statusCode == 200) {
        var contents = jsonDecode(utf8.decode(response.bodyBytes));
        var event = contents['result']['event'];
        EventDetailV2? eventDetails;

        eventDetails = EventDetailV2.fromJson(event);

        return eventDetails;
      } else {
        _errorMessage = response.statusCode.toString();
        throw 'Failed to load event details. Status Code: $_errorMessage';
      }
    } catch (error) {
      debugPrint('Error fetching event details: $error');
      throw 'Error occurred while fetching event details';
    }
  }

  Future<dynamic> getEventEnrollDetails(String eventId, String batchId) async {
    try {
      final response =
          await eventService.getEventEnrollDetails(eventId, batchId);
      if (response!.statusCode == 200) {
        var contents = jsonDecode(utf8.decode(response!.bodyBytes));
        var event = contents['result'];
        EventEnrollModel eventDetails = EventEnrollModel.fromJson(event);
        return eventDetails;
      } else {
        _errorMessage = response!.statusCode.toString();
        throw _errorMessage;
      }
    } catch (_) {
      return _;
    }
  }

  Future<dynamic> getEventStateDetails(String eventId, String batchId) async {
    try {
      final response =
          await eventService.getEventStateDetails(eventId, batchId);
      if (response!.statusCode == 200) {
        var contents = jsonDecode(utf8.decode(response!.bodyBytes));
        var event = contents['result'];
        EventStateModel eventDetails = EventStateModel.fromJson(event);
        return eventDetails;
      } else {
        _errorMessage = response!.statusCode.toString();
        throw _errorMessage;
      }
    } catch (_) {
      return _;
    }
  }

  Future<dynamic> getKarmaPointEventRead(String eventId) async {
    var response;
    try {
      response = await eventService.getKarmaPointEventRead(eventId);
    } catch (_) {
      return _;
    }
    if (response.statusCode == 200) {
      var contents = jsonDecode(response.body);
      return contents['kpList'];
    } else {
      _errorMessage = response.statusCode.toString();
      return _errorMessage;
    }
  }

  Future<List<Event>> filterEvents({
    String? searchText,
    int limit = 50,
    int offset = 0,
    bool getCuratedEvents = false,
    String resourceType = '',
  }) async {
    try {
      final response = await eventService.filterEvents(
          searchText: searchText,
          getCuratedEvents: getCuratedEvents,
          resourceType: resourceType,
          limit: limit,
          offset: offset);
      _data = response;
      if (_data?.statusCode == 200) {
        var contents = jsonDecode(_data!.body);
        List<dynamic> events = contents['result']['Event'];
        eventsList = events
            .map(
              (dynamic item) => Event.fromJson(item),
            )
            .toList();

        return eventsList;
      } else {
        _errorMessage = _data!.statusCode.toString();
        throw _errorMessage;
      }
    } catch (_) {
      return [];
    }
  }

  Future<void> getEventsConfig() async {
    try {
      Response response = await eventService.getEventConfig();

      if (response.statusCode == 200) {
        var contents = jsonDecode(response.body);
        _eventCompletionDuration =
            contents?['result']?['form']?['data']?['fireUpdate']?.toDouble() ??
                EVENT_COMPLETION_DURATION;

        _evenConfigData = contents['result']['form']['data'];
      } else {
        debugPrint(
            'Failed to load event config. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error occurred while fetching event config: $e');
      return null;
    }
  }

  Future<List<Event>> getFeaturedEvents() async {
    List<Event> featuredEvents = [];

    try {
      Response response =
          await eventService.getEvents(apiUrl: ApiUrl.featuredEvents);

      if (response.statusCode == 200) {
        var contents = jsonDecode(response.body);

        List<dynamic> eventDoIds = contents['result']?['events'] ?? [];
        if (eventDoIds.isNotEmpty) {
          Response eventsListResponse =
              await learnService.getRecommendationWithDoId(eventDoIds, false);

          if (eventsListResponse.statusCode == 200) {
            var eventsListContents =
                jsonDecode(utf8.decode(eventsListResponse.bodyBytes));
            List eventList = eventsListContents['result']?['Event'] ?? [];

            if (eventList.isNotEmpty) {
              for (var eventDoId in eventDoIds) {
                var matchedEvent = eventList.firstWhere(
                  (event) => event['identifier'] == eventDoId,
                  orElse: () => null,
                );
                if (matchedEvent != null) {
                  featuredEvents.add(Event.fromJson(matchedEvent));
                }
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('An error occurred while fetching featured events: $e');
    }

    return featuredEvents;
  }

  Future<List<Event>> getTrendingEvents() async {
    List<Event> trendingEvents = [];
    try {
      Response response =
          await eventService.getEvents(apiUrl: ApiUrl.trendingEvents);

      if (response.statusCode == 200) {
        var contents = jsonDecode(response.body);

        List<dynamic> eventDoIds = contents['result']?['events'] ?? [];
        if (eventDoIds.isNotEmpty) {
          Response eventsListResponse =
              await learnService.getRecommendationWithDoId(eventDoIds, false);

          if (eventsListResponse.statusCode == 200) {
            var eventsListContents =
                jsonDecode(utf8.decode(eventsListResponse.bodyBytes));
            List eventList = eventsListContents['result']?['Event'] ?? [];

            if (eventList.isNotEmpty) {
              for (var eventDoId in eventDoIds) {
                var matchedEvent = eventList.firstWhere(
                  (event) => event['identifier'] == eventDoId,
                  orElse: () => null,
                );
                if (matchedEvent != null) {
                  trendingEvents.add(Event.fromJson(matchedEvent));
                }
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('An error occurred while fetching featured events: $e');
    }

    return trendingEvents;
  }

  Future<Map<String, dynamic>> getUserEnrolledEventStatistics() async {
    try {
      Response response =
          await eventService.getEvents(apiUrl: ApiUrl.eventsSummary);
      if (response.statusCode == 200) {
        var contents = jsonDecode(response.body);
        return contents['result']['userEventEnrolmentInfo'];
      } else {
        debugPrint(
            'Failed to load user enrolled event statistics. Status code: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      debugPrint(
          'Error occurred while fetching user enrolled event statistics: $e');
      return {};
    }
  }

  Future<EventSearchModel?> compositeEventsSearch(
      {String? searchText,
      int limit = 50,
      int offset = 0,
      bool getCuratedEvents = false,
      String resourceType = '',
      List<String>? facets,
      Map<String, dynamic>? filters,
      List<String>? status,
      Map<String, dynamic>? sortBy}) async {
    try {
      final response = await eventService.filterEvents(
          searchText: searchText,
          getCuratedEvents: getCuratedEvents,
          resourceType: resourceType,
          limit: limit,
          offset: offset,
          facets: facets,
          filters: filters,
          sortBy: sortBy);
      _data = response;
      if (_data?.statusCode == 200) {
        var contents = json.decode(utf8.decode(_data!.bodyBytes));
        EventSearchModel? events =
            EventSearchModel.fromJson(contents['result']);

        return events;
      } else {
        _errorMessage = _data!.statusCode.toString();
        return null;
      }
    } catch (_) {
      return null;
    }
  }
}
