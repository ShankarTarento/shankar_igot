import 'dart:convert';
import 'package:karmayogi_mobile/common_components/models/content_strip_model.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/common_components/common_service/common_service.dart';
import 'package:karmayogi_mobile/models/_models/provider_model.dart';
import 'package:http/http.dart';
import 'package:karmayogi_mobile/util/app_config.dart';
import 'package:karmayogi_mobile/util/helper.dart';

class TrainingInstitutesService {
  static Future<List<ProviderCardModel>> getProviders(
      {required ContentStripModel stripData}) async {
    List<ProviderCardModel> providers = [];
    Map<String, dynamic>? data = AppConfiguration.homeConfigData;
    if (data == null) return [];
    String orgBookmarkId = Helper.getid(data['micrositeMobile']);
    try {
      Response response = await CommonService.getRequest(
        apiUrl: stripData.apiUrl + orgBookmarkId,
        ttl: ApiTtl.getListOfProviders,
      );

      if (response.statusCode == 200) {
        var contents = jsonDecode(utf8.decode(response.bodyBytes));
        List data =
            jsonDecode(contents['result']['content']['featuredProviders']);
        for (var provider in data) {
          providers.add(ProviderCardModel.fromJson(provider));
        }
      } else {
        print(
            'Error: Failed to fetch data, Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }

    return providers;
  }
}
