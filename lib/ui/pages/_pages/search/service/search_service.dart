import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:igot_http_service_helper/igot_http_service.dart';
import 'package:http/http.dart';
import 'package:karmayogi_mobile/util/network_helper.dart';

import '../../../../../constants/index.dart';
import '../utils/search_helper.dart';

class SearchService {
  final _storage = FlutterSecureStorage();
  Future<dynamic> nlpSearch(String query) async {
    var body = {'query': query, 'synonyms': false};
    var response = await HttpService.post(
        apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.nlpSearch),
        ttl: ApiTtl.search,
        body: body,
        headers: NetworkHelper.signUpPostHeaders());
    return response;
  }

  Future<dynamic> peopleSearch(
      {String query = '',
      Map<String, dynamic>? filters,
      Map<String, dynamic>? sortBy,
      List<String>? facets,
      int offset = 0,
      int? limit}) async {
    String? token = await _storage.read(key: Storage.authToken);
    var body = {
      'request': {
        'filters': filters ?? {},
        'facets': facets ?? [],
        'fields': [],
        'query': query,
        'limit': limit ?? 100,
        'offset': offset,
        'sort_by': sortBy ?? {'firstName': 'asc'}
      }
    };
    var response = await HttpService.post(
        apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.peopleSearch),
        ttl: ApiTtl.search,
        body: body,
        headers: NetworkHelper.postHeader(token!));
    return response;
  }

  Future<dynamic> getEventEnrollList({
    required String type,
  }) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    var body = {
      'request': {
        'retiredCoursesEnabled': false,
        'status': type,
      }
    };
    var response = await HttpService.post(
        apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.eventList + wid!),
        body: body,
        headers: NetworkHelper.postHeader(token!));
    return response;
  }

  Future<dynamic> searchExternalCourse(
      {required String query,
      List<String>? facet,
      required int offset,
      Map<String, dynamic>? filters,
      int? limit,
      String? sortBy}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? deptId = await _storage.read(key: Storage.deptId);
    Map<String, dynamic> data = {
      'filterCriteriaMap': filters ?? {},
      'requestedFields': [],
      'pageNumber': offset,
      'pageSize': limit ?? 100,
      'facets': facet ?? ['topic'],
      'orderBy': sortBy ?? 'createdOn',
      'orderDirection': 'desc',
      'searchString': query
    };
    try {
      Response response = await post(
          Uri.parse(ApiUrl.baseUrl + ApiUrl.externalCourseSearch),
          headers: NetworkHelper.postHeaders(token!, wid!, deptId!),
          body: jsonEncode(data));
      return response;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<dynamic> getResourceData(
      {String searchText = '',
      Map<String, dynamic>? filters,
      List<String> facets = const [],
      Duration? ttl,
      Map<String, dynamic>? sortBy,
      int limit = 1,
      int pageNo = 0}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? deptId = await _storage.read(key: Storage.deptId);

    Map<String, dynamic> data = {
      'request': {
        'filters': {
          'contentType': 'Resource',
          'mimeType': [
            'application/pdf',
            'video/mp4',
            'text/x-url',
            'audio/mpeg',
            'application/vnd.ekstep.content-collection'
          ],
          'resourceCategory': []
        },
        'exists': [
          SearchFilterFacet.sector,
          SearchFilterFacet.resourceCategory
        ],
        'limit': limit,
        'sort_by': sortBy ?? {'lastUpdatedOn': 'desc'},
        'fields': [],
        'facets': facets,
        'offset': 0,
        'query': searchText
      }
    };

    if (filters != null) {
      Map<String, dynamic> existingFilters =
          data['request']['filters'] as Map<String, dynamic>;
      Map<String, dynamic> newFilters = {};

      filters.forEach((key, newValues) {
        newFilters[key] = newValues;
      });
      newFilters.keys.forEach((key) {
        existingFilters.remove(key);
      });
      Map<String, dynamic> merged = {
        ...existingFilters,
        ...newFilters,
      };
      data['request']['filters'] = merged;
    }

    var response = await HttpService.post(
      apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.getTrendingCoursesV4),
      ttl: ttl ?? ApiTtl.compositeSearch,
      body: data,
      headers: NetworkHelper.postHeaders(token!, wid!, deptId!),
    );

    return response;
  }

  Future<dynamic> getSearchConfig() async {
    Map request = {
      'request': {
        'type': 'page',
        'subType': 'mobile-configuration',
        'action': 'app-configuration',
        'component': 'mobile',
        'rootOrgId': '*'
      }
    };
    Response response = await HttpService.post(
      body: request,
      ttl: ApiTtl.searchConfig,
      headers: NetworkHelper.postHeaders('', '', ''),
      apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.getMicroSiteFormData),
    );
    return response;
  }

  //get recent search
  Future<dynamic> getRecentSearch() async {
    String? token = await _storage.read(key: Storage.authToken);

    Response response = await HttpService.get(
        apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.recentSearchRead),
        headers: NetworkHelper.postHeader(token!));

    return response;
  }

  //delete recent search
  Future<dynamic> deleteRecentSearch() async {
    String? token = await _storage.read(key: Storage.authToken);

    Response response = await HttpService.delete(
        apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.recentSearchDelete),
        headers: NetworkHelper.postHeader(token!));

    return response;
  }

  //delete recent search with timestamp
  Future<dynamic> deleteRecentSearchWithTimeStamp(int timestamp) async {
    String? token = await _storage.read(key: Storage.authToken);

    Response response = await HttpService.delete(
        apiUri: Uri.parse(
            ApiUrl.baseUrl + ApiUrl.recentSearchDeleteTimestamp + '$timestamp'),
        headers: NetworkHelper.postHeader(token!));

    return response;
  }

  // Create suggestion
  Future<dynamic> createRecentSuggestion(
      {required String nlpSearchQuery,
      required String searchQuery,
      required String searchCategory}) async {
    String? token = await _storage.read(key: Storage.authToken);
    Map request = {
      'nlpSearchQuery': nlpSearchQuery,
      'searchQuery': searchQuery,
      'searchCategory': searchCategory
    };
    Response response = await HttpService.post(
      body: request,
      headers: NetworkHelper.postHeader(token!),
      apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.recentSearchCreate),
    );
    return response;
  }
}
