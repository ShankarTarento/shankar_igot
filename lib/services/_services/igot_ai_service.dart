import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:igot_http_service_helper/igot_http_service.dart';
import 'package:http/http.dart';
import 'package:karmayogi_mobile/util/network_helper.dart';
import '../../constants/index.dart';

class IgotAIService {
  static final _storage = FlutterSecureStorage();

  Future<dynamic> generateRecommendation() async {
    String? wid = await _storage.read(key: Storage.wid);
    String? deptName = await _storage.read(key: Storage.deptName);
    String? designation = await _storage.read(key: Storage.designation);
    var body = {
      'user_id': wid,
      'department': deptName,
      'designation': designation,
      'device_type': 'mobile'
    };
    var response = await HttpService.post(
        apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.generateRecommendation),
        ttl: ApiTtl.generateAIRecommendation,
        body: body,
        headers: NetworkHelper.igotAIPostHeader());
    return response;
  }

  Future<dynamic> getAIRecommentationWithFeedbackDoId(
      {required String id}) async {
    Response response = await HttpService.get(
        apiUri: Uri.parse(
            ApiUrl.baseUrl + ApiUrl.getRecommentationWithFeedback + id),
        headers: NetworkHelper.igotAIPostHeader());

    return response;
  }

  Future<dynamic> saveFeedback(
      {required String courseId,
      required String recommendationId,
      required int rating,
      String? feedback}) async {
    String? wid = await _storage.read(key: Storage.wid);
    var body = {
      'user_id': wid,
      'recommendation_id': recommendationId,
      'course_id': courseId,
      'rating': rating,
      'comments': feedback
    };
    var response = await post(Uri.parse(ApiUrl.baseUrl + ApiUrl.saveFeedback),
        body: jsonEncode(body), headers: NetworkHelper.igotAIPostHeader());
    return response;
  }
}
