import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:karmayogi_mobile/constants/index.dart';

import './../../services/index.dart';
import 'package:http/http.dart' as http;

class LogoutService extends BaseService {
  LogoutService(HttpClient client) : super(client);

  // calling revoke API upon logout for the user who is already logged in through Parichay
  static Future<dynamic> doKeyCloakLogout() async {
    final _storage = FlutterSecureStorage();

    String? clientId = await _storage.read(key: Storage.clientId);

    String? refreshToken = await _storage.read(key: Storage.refreshToken);

    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
      HttpHeaders.acceptHeader: '*/*',
    };

    Map data = {"refresh_token": "$refreshToken", "client_id": "$clientId"};

    if (clientId == iGotClient.parichayClientId) {
      data['client_secret'] = PARICHAY_KEYCLOAK_CLIENT_SECRET;
    }

    final response = await http.post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.keyCloakLogout),
        headers: headers,
        body: data);
    return response.statusCode;
  }

  // calling revoke API upon logout for the user who is already logged in through Parichay
  static Future<dynamic> doParichayLogout() async {
    final _storage = FlutterSecureStorage();

    String? parichayToken = await _storage.read(key: Storage.parichayAuthToken);
    Map<String, String> headers = {'Authorization': "$parichayToken"};

    final response = await http.get(
        Uri.parse(ApiUrl.parichayBaseUrl + ApiUrl.revokeToken),
        headers: headers);

    return response.statusCode;
  }
}
