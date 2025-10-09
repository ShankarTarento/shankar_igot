import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:karmayogi_mobile/util/network_helper.dart';
import 'dart:convert';
import 'dart:async';
import '../../util/telemetry_repository.dart';
import './../../constants/index.dart';

class TelemetryService {
  final String telemetryUrl = ApiUrl.baseUrl + ApiUrl.getTelemetryUrl;
  final String telemetryPublicUrl =
      ApiUrl.baseUrl + ApiUrl.getPublicTelemetryUrl;
  final _storage = FlutterSecureStorage();

  Future<dynamic> triggerEvent(eventData, {bool isPublic = false}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String messageId = await TelemetryRepository.generateMessageId();
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      'id': TELEMETRY_ID,
      'ver': APP_VERSION,
      'params': {'msgid': '$messageId'},
      'ets': DateTime.now().millisecondsSinceEpoch,
      'events': eventData
    };

    var body = json.encode(data);
    try {
      Response res = !isPublic
          ? await post(Uri.parse(telemetryUrl),
              headers: NetworkHelper.postHeaders(token!, wid!, rootOrgId!), body: body)
          : await post(Uri.parse(telemetryPublicUrl),
              headers: NetworkHelper.registerPostHeaders(), body: body);
      var response = jsonDecode(res.body);
      if (response['responseCode'] == 'SUCCESS') {
        return response;
      } else {
        throw 'Can\'t send telemetry event.';
      }
    } catch (e) {
      throw 'Can\'t send telemetry event.';
    }
  }
}
