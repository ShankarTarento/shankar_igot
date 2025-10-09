import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:igot_http_service_helper/igot_http_service.dart';
import 'package:karmayogi_mobile/constants/_constants/api_endpoints.dart';
import 'package:http/http.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';
import 'package:karmayogi_mobile/util/network_helper.dart';

class NationalLearningWeekService {
  static final String mdoLeaderBoarddApi =
      ApiUrl.baseUrl + ApiUrl.getMdoLeaderBoard;
  final _storage = FlutterSecureStorage();

  static Future<Response?> getMdoLeaderBoard() async {
    final headers = {
      'Authorization': 'bearer ${ApiUrl.apiKey}',
    };

    try {
      final response = await HttpService.get(
          apiUri: Uri.parse(mdoLeaderBoarddApi), headers: headers);

      if (response.statusCode == 200) {
        return response;
      } else {
        debugPrint('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      debugPrint('An error occurred: $e');
    }
    return null;
  }

  static Future getMandatoryCourses() async {
    final headers = {
      'Authorization': 'bearer ${ApiUrl.apiKey}',
    };
    try {
      final response = await HttpService.get(
          apiUri: Uri.parse(
              ApiUrl.baseUrl + ApiUrl.nlwMandatoryCourses + '123456789'),
          headers: headers);
      return response;
    } catch (e) {
      debugPrint("error in getMandatoryCourses $e");
    }
  }

  static Future getExploreLearningContent({required String type}) async {
    String orgId = SPV_ADMIN_ROOT_ORG_ID;
    final headers = {
      'Authorization': 'bearer ${ApiUrl.apiKey}',
    };
    try {
      final response = await HttpService.get(
          apiUri: Uri.parse(ApiUrl.baseUrl +
              ApiUrl.getMdoCoursesData +
              '$orgId$type' +
              '/' +
              '$orgId'),
          ttl: Duration(minutes: 5),
          headers: headers);
      return response;
    } catch (e) {
      debugPrint("error in getExploreLearningContent  $e");
    }
  }

  Future<Response?> getAllEvents({
    String? startDate,
    Map<String, dynamic>? request,
  }) async {
    try {
      String? token = await _storage.read(key: Storage.authToken);
      String? wid = await _storage.read(key: Storage.wid);
      String? rootOrgId = await _storage.read(key: Storage.deptId);

      Map<String, dynamic> data = {
        "locale": ["en"],
        "query": "",
        "request": {
          "query": "",
          "filters": {
            "status": ["Live"],
            "contentType": "Event",
            "category": "Event",
            "startDate": startDate,
          },
          "sort_by": {"startDate": "desc"}
        }
      };

      if (request != null) {
        request['request']['filters']['startDate'] = startDate;
      }

      Response response = await HttpService.post(
        apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.getAllEvents),
        headers: NetworkHelper.postHeaders(token!, wid!, rootOrgId!),
        body: request ?? data,
      );

      if (response.statusCode != 200) {
        debugPrint('Error: Status code ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
      }

      return response;
    } catch (e) {
      debugPrint('An error occurred while fetching events: $e');
      return null;
    }
  }

  static Future<Response?> getWeekMetrics() async {
    final headers = {
      'Authorization': 'bearer ${ApiUrl.apiKey}',
    };

    try {
      final response = await HttpService.get(
          apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.nlwInsights),
          headers: headers);

      if (response.statusCode == 200) {
        return response;
      } else {
        debugPrint('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      debugPrint('An error occurred: $e');
    }
    return null;
  }

  Future<Response?> getUserWeekProgress() async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    try {
      final response = await HttpService.get(
          apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.nlwUserLeaderBoard),
          headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));

      if (response.statusCode == 200) {
        return response;
      } else {
        debugPrint('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      debugPrint('An error occurred: $e');
    }
    return null;
  }

  Future<Response?> getLearningContent() async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);
    Map<String, dynamic> data = {
      "request": {
        "filters": {
          "contentTagNames": ["NLWContent"]
        },
        "fields": [],
        "offset": 0,
        "limit": 500,
        "sort_by": {"lastUpdatedOn": "desc"},
        "facets": ["nlwOrgs", "nlwUserExp"]
      }
    };
    try {
      final response = await HttpService.post(
          body: data,
          apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.getTrendingCoursesV4),
          headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));

      if (response.statusCode == 200) {
        return response;
      } else {
        debugPrint(
            'getLearningContent failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      debugPrint('getLearningContent : $e');
    }
    return null;
  }
}
