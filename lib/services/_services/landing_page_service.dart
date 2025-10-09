import 'dart:convert';

import 'package:http/http.dart';
import 'package:igot_http_service_helper/services/http_service.dart';
import 'package:karmayogi_mobile/env/env.dart';
import 'package:karmayogi_mobile/models/_models/landing_page_info_model.dart';

import '../../constants/_constants/api_endpoints.dart';
import '../../models/_models/course_model.dart';

class LandingPageService {
  Future<LandingPageInfo> getLandingPageInfo() async {
    Response contents = await HttpService.get(
      apiUri: Uri.parse(Env.configUrl),
      ttl: Duration(hours: 4),
    );
    var data = jsonDecode(contents.body);
    LandingPageInfo landingPageInfo = LandingPageInfo.fromJson(data);
    return landingPageInfo;
  }

  Future<List<Course>> getFeaturedCourses(
      {String? pathUrl, bool pointToV1 = false}) async {
    String _errorMessage;
    List<Course> courses = [];
    Response response = await HttpService.get(
      ttl: Duration(hours: 4),
      apiUri: Uri.parse(ApiUrl.baseUrl +
          (pathUrl != null
              ? pathUrl
              : pointToV1
                  ? ApiUrl.getFeaturedCoursesV1
                  : ApiUrl.getFeaturedCoursesV2)),
    );
    if (response.statusCode == 200) {
      var contents = jsonDecode(response.body);

      List<dynamic>? body = contents['result']['content'];
      if (body == null) return [];
      courses = body
          .map(
            (dynamic item) => Course.fromJson(item),
          )
          .toList();
      return courses;
    } else {
      _errorMessage = response.statusCode.toString();
      throw _errorMessage;
    }
  }

  static Future<dynamic> getUserNudgeInfo() async {
    Response response = await HttpService.get(
        apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.getUserNudgeConfig),
        ttl: Duration(minutes: 30));

    var contents = jsonDecode(response.body);
    return contents;
  }

  static Future<dynamic> getOverlayThemeData() async {
    Response response = await HttpService.get(
        apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.getOverlayThemeData),
        ttl: Duration(minutes: 1));

    var contents = jsonDecode(response.body);
    return contents;
  }
}
