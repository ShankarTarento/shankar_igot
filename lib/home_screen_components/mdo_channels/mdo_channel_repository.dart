import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/common_components/common_service/common_service.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/mdo_channels/model/mdo_channel_data_model.dart';
import 'package:http/http.dart';

class MdoChannelRepository {
  static Future<List<MdoChannelDataModel>> getMdoChannelRepository(
      {required String apiUrl}) async {
    List<MdoChannelDataModel> mdoChannels = [];

    try {
      Response response = await CommonService.getRequest(
          apiUrl: apiUrl, ttl: ApiTtl.compositeSearch);

      if (response.statusCode == 200) {
        var contents = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> body = contents['result']['data']['orgList'] != null
            ? contents['result']['data']['orgList']
            : [];

        for (var channel in body) {
          mdoChannels.add(MdoChannelDataModel.fromJson(channel));
        }
      } else {
        debugPrint('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('getMdoChannelRepository Error occurred: $e');
    }

    return mdoChannels;
  }
}
