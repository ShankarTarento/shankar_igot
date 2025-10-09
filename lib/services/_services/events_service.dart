import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:igot_http_service_helper/igot_http_service.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/util/network_helper.dart';

class EventService {
  final _storage = FlutterSecureStorage();

  Future<dynamic> getAllEvents({String? startDate}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      "locale": ["en"],
      "query": "",
      "request": {
        "query": "",
        "filters": {
          "status": ["Live"],
          "contentType": "Event",
          "category": "Event",
          "startDate": startDate
        },
        "sort_by": {"startDate": "desc"}
      }
    };

    //var body = json.encode(data);

    Response response = await HttpService.post(
        ttl: Duration(minutes: 1),
        apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.getAllEvents),
        headers: NetworkHelper.postHeaders(token!, wid!, rootOrgId!),
        body: data);

    return response;
  }

  Future<dynamic> getEventsForMDO() async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      "locale": ["en"],
      "query": "",
      "request": {
        "query": "",
        "filters": {
          "status": ["Live"],
          "contentType": "Event",
          "category": "Event",
          "createdFor": ["$rootOrgId"]
        },
        "sort_by": {"startDate": "desc"}
      }
    };

    var body = json.encode(data);

    Response response = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getAllEvents),
        headers: NetworkHelper.postHeaders(token!, wid!, rootOrgId!),
        body: body);
    return response;
  }

  Future<dynamic> getEventDetails(String id) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);

    Response response = await get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.readEvent + '$id'),
        headers: NetworkHelper.discussionGetHeaders(token!, wid!));
    return response;
  }

  Future<dynamic> enrollToEvent(String eventId, String batchId) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);
    Map data = {
      "request": {"userId": wid, "eventId": eventId, "batchId": batchId}
    };
    var body = jsonEncode(data);

    Response res = await post(Uri.parse(ApiUrl.baseUrl + ApiUrl.enrollToEvent),
        headers: NetworkHelper.curatedProgramPostHeaders(token!, wid!, rootOrgId!),
        body: body);

    if (res.statusCode == 200) {
      var contents = jsonDecode(res.body);
      return contents['result']['response'];
    } else {
      var contents = jsonDecode(res.body);

      return contents['params']['errmsg'] ?? 'Unable to auto enroll a batch';
    }
  }

  Future<Map> updateEventProgress(
      String eventId,
      String batchId,
      int status,
      String contentType,
      List<double> current,
      double maxSize,
      double completionPercentage,
      double totalWatchTime,
      double stateMetaData) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    List dateTime = DateTime.now().toUtc().toString().split('.');

    Map data = {
      "request": {
        "userId": wid,
        "events": [
          {
            "eventId": eventId,
            "batchId": batchId,
            "status": status,
            "lastAccessTime": '${dateTime[0]}:00+0000',
            "progressdetails": {
              "max_size": maxSize,
              "current": current,
              "duration": totalWatchTime.toInt(),
              "stateMetaData": stateMetaData,
              "mimeType": contentType
            },
            "completionPercentage": completionPercentage
          }
        ]
      }
    };

    var body = json.encode(data);
    Response res = await patch(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.updateEventProgress),
        headers: NetworkHelper.postHeaders(token!, wid!, rootOrgId!),
        body: body);
    if (res.statusCode == 200) {
      var contents = jsonDecode(res.body);
      return contents;
    } else {
      throw 'Can\'t update content progress';
    }
  }

  Future<dynamic> getEventEnrollDetails(String eventId, String batchId) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await get(
        Uri.parse(ApiUrl.baseUrl +
            ApiUrl.eventEnrolRead +
            '$wid?eventId=$eventId&batchId=$batchId'),
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));
    return response;
  }

  Future<dynamic> getEventStateDetails(String eventId, String batchId) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await post(
      Uri.parse(ApiUrl.baseUrl +
          ApiUrl.eventStateRead +
          '?batchId=$batchId&eventId=$eventId'),
      headers: NetworkHelper.postHeaders(token!, wid!, rootOrgId!),
    );
    return response;
  }

  Future<dynamic> getEventEnrollList() async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.eventList + '$wid'),
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));
    return response;
  }

  Future<dynamic> getKarmaPointEventRead(String eventId) async {
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);
    String? token = await _storage.read(key: Storage.authToken);
    var body = json.encode({
      "request": {
        "filters": {"contextType": "Event", "contextId": eventId}
      }
    });
    String url = ApiUrl.baseUrl + ApiUrl.karmapointCourseRead;
    final response = await post(Uri.parse(url),
        headers: NetworkHelper.profilePostHeaders(token!, wid!, rootOrgId!),
        body: body);
    return response;
  }

  Future<dynamic> getKeySpeakersEvents(String orgBookmarkId) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      "locale": ["en"],
      "query": "",
      "request": {
        "query": "",
        "filters": {
          "status": ["Live"],
          "contentType": "Event",
          "category": "Event",
          "onBehalfOf": orgBookmarkId
        },
        "sort_by": {"startDate": "desc"}
      }
    };

    Response response = await HttpService.post(
        ttl: Duration(minutes: 1),
        apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.getAllEvents),
        headers: NetworkHelper.postHeaders(token!, wid!, rootOrgId!),
        body: data);

    return response;
  }

  Future<dynamic> filterEvents(
      {String? searchText,
      int limit = 50,
      int offset = 0,
      bool getCuratedEvents = false,
      String resourceType = '',
      List<String>? facets,
      Map<String, dynamic>? filters,
      Map<String, dynamic>? sortBy}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? deptId = await _storage.read(key: Storage.deptId);

    Map<String, dynamic> data = {
      "request": {
        "query": searchText,
        "filters": {
          "courseCategory": [],
          "contentType": ["Event"],
          "status": ["Live"],
          "createdFor": getCuratedEvents ? [SPV_ADMIN_ROOT_ORG_ID] : [],
          "resourceType": resourceType.isNotEmpty ? resourceType : null,
        },
        "sort_by": sortBy ?? {"startDate": "desc"},
        "facets": facets ?? ["mimeType"],
        "limit": limit,
        "offset": offset,
        "fields": []
      }
    };

    if (filters != null) {
      Map<String, dynamic> existingFilters =
          data['request']['filters'] as Map<String, dynamic>;
      Map<String, dynamic> newFilters = {};

      filters.forEach((key, newValues) {
        newFilters[key] = newValues;
      });
      newFilters.keys.forEach((key) {
        existingFilters.remove(key);
      });
      Map<String, dynamic> merged = {
        ...existingFilters,
        ...newFilters,
      };
      data['request']['filters'] = merged;
    }

    var response = await HttpService.post(
      apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.getTrendingCoursesV4),
      body: data,
      headers: NetworkHelper.postHeaders(token!, wid!, deptId!),
    );

    return response;
  }

  Future<Response> filterEventsV2({
    String? searchText,
    int limit = 50,
    int offset = 0,
    List<String>? startDate,
    List<String>? endDate,
    Map? startDateTimeInEpoch,
    Map? endDateTimeInEpoch,
    bool getCuratedEvents = false,
    Map? sortBy,
    List<String> resourceType = const [],
  }) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? deptId = await _storage.read(key: Storage.deptId);

    Map<String, dynamic> data = {
      "request": {
        "query": searchText,
        "filters": {
          "courseCategory": [],
          "contentType": ["Event"],
          "status": ["Live"],
          "createdFor": getCuratedEvents ? [SPV_ADMIN_ROOT_ORG_ID] : [],
          "resourceType": resourceType.isNotEmpty ? resourceType : null,
          "startDate": startDate != null && startDate.isNotEmpty
              ? {">=": startDate}
              : null,
          "endDate":
              endDate != null && endDate.isNotEmpty ? {"<=": endDate} : null,
          "startDateTimeInEpoch": startDateTimeInEpoch,
          "endDateTimeInEpoch": endDateTimeInEpoch
        },
        "sort_by": sortBy ?? {"startDate": "desc"},
        "facets": ["mimeType"],
        "limit": limit,
        "offset": offset,
        "fields": []
      }
    };

    var response = await HttpService.post(
      apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.getTrendingCoursesV4),
      body: data,
      headers: NetworkHelper.postHeaders(token!, wid!, deptId!),
    );

    return response;
  }

  Future<Response> getEventConfig() async {
    try {
      Map data = {
        "request": {
          "type": "page",
          "subType": "events",
          "action": "page-configuration",
          "component": "portal",
          "rootOrgId": "*"
        }
      };

      var response = await HttpService.post(
        ttl: Duration(minutes: 5),
        apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.getMicroSiteFormData),
        body: data,
        headers: NetworkHelper.postHeaders('', '', ''),
      );

      return response;
    } catch (e) {
      debugPrint('Error occurred while fetching event config: $e');

      rethrow;
    }
  }

  Future<Response> getAllEnrolledEvents() async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? deptId = await _storage.read(key: Storage.deptId);

    Map request = {
      "request": {
        "retiredCoursesEnabled": true,
        "status": "All",
      }
    };

    Response response = await HttpService.post(
      apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.eventList + '$wid'),
      body: request,
      headers: NetworkHelper.postHeaders(token!, wid!, deptId!),
    );

    return response;
  }

  Future<Response> getEvents({required String apiUrl}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? deptId = await _storage.read(key: Storage.deptId);
    Response response = await HttpService.get(
      apiUri: Uri.parse(ApiUrl.baseUrl + apiUrl),
      headers: NetworkHelper.postHeaders(token!, wid!, deptId!),
    );
    return response;
  }

  Future<Response> getEnrolledEvents(
      {String? eventType,
      String? eventEndDate,
      String? eventStartDate,
      bool? calendarEventEnabled}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? deptId = await _storage.read(key: Storage.deptId);

    Map request = {
      "request": {
        "retiredCoursesEnabled": true,
        "status": "All",
        "calendarEventEnabled": calendarEventEnabled ?? false,
        "eventType": eventType ?? null,
        "eventEndDate": eventEndDate ?? null,
        "eventStartDate": eventStartDate ?? null
      }
    };

    Response response = await HttpService.post(
      body: request,
      apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.eventListV2 + '$wid'),
      headers: NetworkHelper.postHeaders(token!, wid!, deptId!),
    );
    return response;
  }

  Future<Response> getEventsSummary() async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? deptId = await _storage.read(key: Storage.deptId);

    Response response = await HttpService.get(
      ttl: ApiTtl.eventSummary,
      apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.eventsSummary),
      headers: NetworkHelper.postHeaders(token!, wid!, deptId!),
    );
    return response;
  }
}