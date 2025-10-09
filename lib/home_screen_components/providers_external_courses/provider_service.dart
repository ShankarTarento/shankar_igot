import 'dart:convert';

import 'package:karmayogi_mobile/common_components/models/content_strip_model.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/common_components/common_service/common_service.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:http/http.dart';

class ProviderService {
  static Future<List<Course>> getExternalCourses(
      {required ContentStripModel stripData}) async {
    List<Course> externalCourses = [];
    try {
      Response response = await CommonService.postRequest(
        apiUrl: stripData.apiUrl,
        ttl: ApiTtl.compositeSearch,
        request: stripData.request!,
      );

      if (response.statusCode == 200) {
        var contents = jsonDecode(utf8.decode(response.bodyBytes));
        List data = contents['data'] ?? [];

        for (var course in data) {
          externalCourses.add(Course.fromJson(course));
        }
      } else {
        print(
            'Error: Failed to fetch data, Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
    return externalCourses;
  }
}
