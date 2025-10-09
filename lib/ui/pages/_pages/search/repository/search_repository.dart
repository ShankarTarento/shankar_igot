import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../../../../../localization/index.dart';
import '../../../../widgets/_events/models/event_enrollment_list_model.dart';
import '../models/composite_search_model.dart';
import '../models/people_search_model.dart';
import '../models/recent_search_model.dart';
import '../models/resource_search_model.dart';
import '../service/search_service.dart';
import '../utils/search_helper.dart';

class SearchRepository {
  final SearchService searchService = SearchService();

  Future<List<dynamic>> nlpSearch(String query) async {
    var _data;
    try {
      final response = await searchService.nlpSearch(query);
      _data = response;
      if (_data!.statusCode == 200) {
        var contents = jsonDecode(utf8.decode(response.bodyBytes));

        return contents['data']['keywords'];
      } else {
        return [];
      }
    } catch (_) {
      return [];
    }
  }

  Future<PeopleSearchModel?> peopleSearch(
      {String query = '',
      Map<String, dynamic>? filters,
      Map<String, dynamic>? sortBy,
      List<String>? facets,
      int offset = 0,
      int? limit}) async {
    var _data;
    PeopleSearchModel? peopleData;
    try {
      final response = await searchService.peopleSearch(
          query: query,
          filters: filters,
          sortBy: sortBy,
          facets: facets,
          offset: offset,
          limit: limit);
      _data = response;
      if (_data!.statusCode == 200) {
        var contents = json.decode(utf8.decode(_data!.bodyBytes));
        var result = contents['result']['response'];
        if (result != null) {
          peopleData = PeopleSearchModel.fromJson(result);
        }

        return peopleData;
      } else {
        return null;
      }
    } catch (_) {
      return null;
    }
  }

  Future<List<EventEnrollmentListModel>> getEventEnrollList({
    required String type,
  }) async {
    List<EventEnrollmentListModel> eventDetails = [];

    try {
      Response response = await searchService.getEventEnrollList(type: type);

      if (response.statusCode == 200) {
        var contents = json.decode(utf8.decode(response.bodyBytes));

        List<dynamic> body = contents['result']['events'] ?? [];

        for (var event in body) {
          eventDetails.add(EventEnrollmentListModel.fromJson(event));
        }
      } else {
        throw Exception(
            'Failed to load events with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred while fetching enrollment data: $e');
      return [];
    }

    return eventDetails;
  }

  Future<CompositeSearchModel?> searchExternalCourses(
      {required String query,
      List<String>? facet,
      int offset = 0,
      Map<String, dynamic>? filters,
      int? limit,
      String? sortBy}) async {
    try {
      var response = await searchService.searchExternalCourse(
          query: query,
          facet: facet,
          offset: offset,
          filters: filters,
          limit: limit,
          sortBy: sortBy);
      if (response.statusCode == 200) {
        Map<String, dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        List<Map<String, dynamic>> facet = [];
        if (body['facets'] != null && body['facets'].isNotEmpty) {
          body['facets'].forEach((key, value) {
            facet.add({'name': key, 'values': value});
          });
          body['facets'] = facet;
        }
        CompositeSearchModel data = CompositeSearchModel.fromJson(body);
        return data;
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<ResourceSearchModel?> getResourceData({
    String searchText = '',
    Map<String, dynamic>? filters,
    List<String> facets = const [],
    Duration? ttl,
    Map<String, dynamic>? sortBy,
    int limit = 1,
    int pageNo = 0,
  }) async {
    try {
      final response = await searchService.getResourceData(
          pageNo: pageNo,
          searchText: searchText,
          filters: filters,
          ttl: Duration.zero,
          facets: facets,
          sortBy: sortBy,
          limit: limit);
      Response _data = response;
      if (_data.statusCode == 200) {
        var contents = json.decode(utf8.decode(_data.bodyBytes));
        ResourceSearchModel? resourceData =
            ResourceSearchModel.fromJson(contents['result']);

        return resourceData;
      } else {
        return null;
      }
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> getSearchConfig() async {
    Map<String, dynamic>? searchConfig;
    try {
      Response response = await searchService.getSearchConfig();
      if (response.statusCode == 200) {
        var content = jsonDecode(response.body);
        searchConfig = content['result']['form']['data']['searchPage'];
      }
    } catch (e) {
      debugPrint('Exception during API call: $e');
    }
    return searchConfig ?? SearchConstants().fetchDefaultSearchConfig;
  }

  //get recent search
  Future<List<RecentSearchModel>> getRecentSearch() async {
    try {
      final response = await searchService.getRecentSearch();
      if (response!.statusCode == 200) {
        var contents = jsonDecode(utf8.decode(response.bodyBytes));
        return contents['result']['searchQueries'] != null &&
                contents['result']['searchQueries'].isNotEmpty
            ? contents['result']['searchQueries']
                .map((queryItem) => RecentSearchModel.fromJson(queryItem))
                .toList()
                .cast<RecentSearchModel>()
            : [];
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Exception during API call: $e');
      return [];
    }
  }

  //delete recent search
  Future<String> deleteRecentSearch() async {
    try {
      final response = await searchService.deleteRecentSearch();
      Map data = jsonDecode(response.body);
      if (data['result']['response'] != null) {
        return data['result']['response'];
      } else if (data['params']['errmsg'] != null) {
        return data['params']['errmsg'];
      } else {
        return EnglishLang.errorMessage;
      }
    } catch (e) {
      debugPrint(e.toString());
      return e.toString();
    }
  }

  //delete recent search with timestamp
  Future<String> deleteRecentSearchWithTimeStamp(int timestamp) async {
    try {
      final response =
          await searchService.deleteRecentSearchWithTimeStamp(timestamp);
      Map data = jsonDecode(response.body);
      if (data['result']['response'] != null) {
        return data['result']['response'];
      } else if (data['params']['errmsg'] != null) {
        return data['params']['errmsg'];
      } else {
        return EnglishLang.errorMessage;
      }
    } catch (e) {
      debugPrint(e.toString());
      return e.toString();
    }
  }

  //create suggestion
  Future<String> createRecentSuggestion(
      {required String nlpSearchQuery,
      required String searchQuery,
      required String searchCategory}) async {
    try {
      final response = await searchService.createRecentSuggestion(
          nlpSearchQuery: nlpSearchQuery,
          searchQuery: searchQuery,
          searchCategory: searchCategory);
      Map data = jsonDecode(response.body);
      if (data['result']['response'] != null) {
        return data['result']['response'];
      } else if (data['params']['errmsg'] != null) {
        return data['params']['errmsg'];
      } else {
        return EnglishLang.errorMessage;
      }
    } catch (e) {
      debugPrint(e.toString());
      return e.toString();
    }
  }
}
