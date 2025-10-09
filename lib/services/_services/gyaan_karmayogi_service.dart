import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:igot_http_service_helper/services/http_service.dart';
import 'package:karmayogi_mobile/constants/_constants/api_endpoints.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';
import 'package:http/http.dart';
import 'package:karmayogi_mobile/util/network_helper.dart';

class GyaanKarmayogiApiService {
  final _storage = FlutterSecureStorage();
  final String coursesUrl = ApiUrl.baseUrl + ApiUrl.getTrendingCourses;

  Future<Response> getGyaanKarmayogiData(
      {List<String>? sectors,
      String? searchQuery,
      List<String>? subSector,
      List<String>? createdFor,
      List<String>? contentType,
      List<String>? resourceCategory}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map requestBody = {
      "request": {
        "query": searchQuery,
        "fields": [
          "sectorDetails_v1.sectorName",
          "sectorDetails_v1.subSectorName",
          "resourceCategory",
          "contextStateOrUTs",
          "contextYear",
          "contextSDGs",
        ],
        "exists": ["sectorDetails_v1.sectorName", "resourceCategory"],
        "filters": {
          "contentType": contentType ?? ["Resource"],
          "mimeType": [
            "application/pdf",
            "video/mp4",
            'text/x-url',
            'video/x-youtube',
            'audio/mpeg',
            "application/vnd.ekstep.content-collection"
          ],
          "status": ["Live"],
          "sectorDetails_v1.sectorName": sectors,
          "sectorDetails_v1.subSectorName": subSector,
          "resourceCategory": resourceCategory,
          "createdFor": createdFor,
        },
        "limit": 0,
        "sort_by": {"lastUpdatedOn": "desc"},
        "facets": [
          "resourceCategory",
          "sectorDetails_v1.sectorName",
          "sectorDetails_v1.subSectorName",
          "createdFor",
          "contextStateOrUTs",
          "contextYear",
          "contextSDGs",
        ]
      }
    };
    Response response = await HttpService.post(
        apiUri: Uri.parse(coursesUrl),
        headers: NetworkHelper.postHeaders(token!, wid!, rootOrgId!),
        body: requestBody);
    return response;
  }

  Future<Response> getGyaanKarmaYogiResources(
      {List<String>? sectors,
      String? searchQuery,
      List<String>? subSector,
      List<String>? resourceCategory,
      List<String>? createdFor,
      List<String>? contentType,
      List<String>? contextSDGs,
      List<String>? contextStateOrUTs,
      List<String>? contextYear}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);
    Map requestBody = {
      "request": {
        "query": searchQuery,
        "filters": {
          "contentType": contentType ?? ["Resource"],
          "mimeType": [
            "application/pdf",
            "video/mp4",
            'text/x-url',
            'video/x-youtube',
            'audio/mpeg',
            "application/vnd.ekstep.content-collection"
          ],
          "status": ["Live"],
          "resourceCategory": resourceCategory,
          "sectorDetails_v1.sectorName": sectors,
          "sectorDetails_v1.subSectorName": subSector,
          "createdFor": createdFor,
          "contextSDGs": contextSDGs,
          "contextStateOrUTs": contextStateOrUTs,
          "contextYear": contextYear
        },
        "sort_by": {"lastUpdatedOn": "desc"},
        "facets": [
          "resourceCategory",
          "sector",
        ]
      }
    };
    Response response = await HttpService.post(
        apiUri: Uri.parse(coursesUrl),
        headers: NetworkHelper.postHeaders(token!, wid!, rootOrgId!),
        body: requestBody);

    return response;
  }

  Future<Response> getAvailableSectors() async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);
    final String coursesUrl = ApiUrl.baseUrl + ApiUrl.getTrendingCourses;

    Map requestBody = {
      "request": {
        "exists": ["sectorDetails_v1.sectorName", "resourceCategory"],
        "query": "",
        "filters": {
          "contentType": ["Resource", "Course"],
          "status": ["Live"],
        },
        "limit": 0,
        "sort_by": {"lastUpdatedOn": "desc"},
        "facets": ["resourceCategory", "sectorDetails_v1.sectorName"]
      }
    };
    Response response = await HttpService.post(
        ttl: Duration(minutes: 10),
        apiUri: Uri.parse(coursesUrl),
        headers: NetworkHelper.postHeaders(
          token!,
          wid!,
          rootOrgId!,
        ),
        body: requestBody);
    return response;
  }

  Future<Response> getSectorsData() async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await HttpService.get(
        ttl: Duration(minutes: 10),
        apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.getSectorData),
        headers: NetworkHelper.getHeaders(
          token!,
          wid!,
          rootOrgId!,
        ));
    return response;
  }

  Future<Response> getGyaanConfig() async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await HttpService.get(
      ttl: Duration(minutes: 10),
      apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.gyaanKarmayogiConfig),
      headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!),
    );
    return response;
  }

  Future<Response> getResourceDetails({required String id}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);
    Response res = await get(Uri.parse(ApiUrl.baseUrl + ApiUrl.getCourse + id),
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));
    return res;
  }
}
