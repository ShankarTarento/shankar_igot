import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:igot_http_service_helper/services/http_service.dart';
import 'package:karmayogi_mobile/constants/_constants/api_endpoints.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';
import 'package:karmayogi_mobile/util/network_helper.dart';

class CommonService {
  static final _storage = FlutterSecureStorage();

  static Future<Response> getRequest(
      {required String apiUrl, Duration? ttl}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await HttpService.get(
      ttl: ttl != null ? ttl : null,
      apiUri: Uri.parse(ApiUrl.baseUrl + apiUrl),
      headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!),
    );
    return response;
  }

  static Future<Response> postRequest(
      {required String apiUrl,
      Duration? ttl,
      required Map<String, dynamic> request,
      int? offset}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);
    if (offset != null) {
      request['request']['offset'] = offset;
    }
    Response response = await HttpService.post(
      body: request,
      ttl: ttl != null ? ttl : null,
      apiUri: Uri.parse(ApiUrl.baseUrl + apiUrl),
      headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!),
    );
    return response;
  }
}
