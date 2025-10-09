import 'package:http/http.dart';
import 'package:igot_http_service_helper/igot_http_service.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'dart:convert';

import 'package:karmayogi_mobile/util/network_helper.dart';

class ChatbotService {
  Future<dynamic> getFaqAvailableLang() async {
    final res = await HttpService.get(
      apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.getFaqAvailableLangUrl),
       ttl: ApiTtl.getFaqLanguage,
    );
    var content;
    if (res.statusCode == 200) {
      content = jsonDecode(res.body)['payload']['languages'];
    }
    return content;
  }

  Future<dynamic> getFaqData({String? lang, String? configType}) async {
    Map data = {"lang": lang, "config_type": configType};
    print("getFaqData lang: $lang configType $configType");

    Response res = await HttpService.post(
        apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.getFaqDataUrl),
        ttl: ApiTtl.getFaqData,
        headers: NetworkHelper.registerPostHeaders(),
        body: data);
    var content;
    if (res.statusCode == 200) {
      try {
        content = jsonDecode(res.body)['payload']['config'];
      } catch (e) {
        print(e);
      }
    }
    return content;
  }
}
