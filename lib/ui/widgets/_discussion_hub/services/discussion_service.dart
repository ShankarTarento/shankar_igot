import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/helper/discussion_const.dart';
import 'package:karmayogi_mobile/util/network_helper.dart';
import '../../../../../../../constants/_constants/api_endpoints.dart';
import '../../../../../../../constants/_constants/storage_constants.dart';
import '../../../../../../../services/_services/base_service.dart';

class DiscussionService extends BaseService {
  DiscussionService(HttpClient client) : super(client);

  /// get Discussions
  static Future<dynamic> getDiscussion(
      int pageNumber, String communityId) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map<String, dynamic> data = {
      "communityId": communityId,
      "pageNumber": pageNumber - 1
    };

    var body = json.encode(data);

    final response = await http.post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getDiscussion),
        headers: NetworkHelper.profilePostHeaders(token!, wid!, rootOrgId!),
        body: body);

    Map responseData = json.decode(utf8.decode(response.bodyBytes));

    return responseData;
  }

  /// search discussion
  static Future<dynamic> searchDiscussion(
      int pageNumber, String searchQuery, String communityId) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map<String, dynamic> data = {
      "filterCriteriaMap": {
        "communityId": communityId,
        "type": PostTypeConst.question
      },
      "requestedFields": [],
      "pageNumber": pageNumber - 1,
      "pageSize": 10,
      "orderBy": "createdOn",
      "orderDirection": "DESC",
      "searchString": searchQuery,
      "facets": [],
    };

    var body = json.encode(data);

    final response = await http.post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getDiscussionSearch),
        headers: NetworkHelper.profilePostHeaders(token!, wid!, rootOrgId!),
        body: body);

    Map responseData = json.decode(utf8.decode(response.bodyBytes));

    return responseData;
  }

  /// get Media Discussions
  static Future<dynamic> getMediaDiscussion(int pageNumber, String searchQuery,
      String communityId, List<String> categoryType) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map<String, dynamic> data = (searchQuery != '')
        ? {
      "filterCriteriaMap": {
        "communityId": communityId,
        "type": PostTypeConst.question,
        "categoryType": categoryType
      },
      "requestedFields": [],
      "pageNumber": pageNumber - 1,
      "pageSize": 10,
      "orderBy": "createdOn",
      "orderDirection": "DESC",
      "searchString": searchQuery,
      "facets": [],
    }
        : {
      "filterCriteriaMap": {
        "communityId": communityId,
        "type": PostTypeConst.question,
        "categoryType": categoryType
      },
      "requestedFields": [],
      "pageNumber": pageNumber - 1,
      "pageSize": 10,
      "orderBy": "createdOn",
      "orderDirection": "DESC",
      "facets": [],
    };

    var body = json.encode(data);

    final response = await http.post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getDiscussionSearch),
        headers: NetworkHelper.profilePostHeaders(token!, wid!, rootOrgId!),
        body: body);

    Map responseData = json.decode(utf8.decode(response.bodyBytes));

    return responseData;
  }

  /// get Bookmarked Discussions
  static Future<dynamic> getBookmarkedDiscussion(
      int pageNumber, String searchQuery, String communityId) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map<String, dynamic> data = (searchQuery != '')
        ? {
      "communityId": communityId,
      "page": pageNumber - 1,
      "pageSize": 20,
      "orderBy": "createdOn",
      "orderDirection": "DESC",
      "searchString": searchQuery,
    }
        : {
      "communityId": communityId,
      "page": pageNumber - 1,
      "pageSize": 20,
      "orderBy": "createdOn",
      "orderDirection": "DESC",
    };

    var body = json.encode(data);

    final response = await http.post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getBookmarkedDiscussion),
        headers: NetworkHelper.profilePostHeaders(token!, wid!, rootOrgId!),
        body: body);

    Map responseData = json.decode(utf8.decode(response.bodyBytes));

    return responseData;
  }

  /// get Global Discussions
  static Future<dynamic> getGlobalDiscussion(
      int pageNumber, String searchQuery, String communityId) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map<String, dynamic> data = (searchQuery != '')
        ? {
      "filterCriteriaMap": {
        "type": PostTypeConst.question,
      },
      "requestedFields": [],
      "pageNumber": pageNumber - 1,
      "pageSize": 10,
      "orderBy": "updatedOn",
      "orderDirection": "DESC",
      "searchString": searchQuery,
      "facets": [],
    }
        : {
      "filterCriteriaMap": {
        "type": PostTypeConst.question,
      },
      "requestedFields": [],
      "pageNumber": pageNumber - 1,
      "pageSize": 10,
      "orderBy": "updatedOn",
      "orderDirection": "DESC",
      "facets": [],
    };

    var body = json.encode(data);

    final response = await http.post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getGlobalFeeds),
        headers: NetworkHelper.profilePostHeaders(token!, wid!, rootOrgId!),
        body: body);

    Map responseData = json.decode(utf8.decode(response.bodyBytes));

    return responseData;
  }

  /// get my Discussions
  static Future<dynamic> getMyDiscussion(
      int pageNumber, String searchQuery, String communityId) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map<String, dynamic> data = (searchQuery != '')
        ? {
      "filterCriteriaMap": {
        "communityId": communityId,
        "type": PostTypeConst.question,
        "createdBy": wid ?? ''
      },
      "requestedFields": [],
      "pageNumber": pageNumber - 1,
      "pageSize": 10,
      "orderBy": "createdOn",
      "orderDirection": "DESC",
      "searchString": searchQuery,
      "facets": [],
    }
        : {
      "filterCriteriaMap": {
        "communityId": communityId,
        "type": PostTypeConst.question,
        "createdBy": wid ?? ''
      },
      "requestedFields": [],
      "pageNumber": pageNumber - 1,
      "pageSize": 10,
      "orderBy": "createdOn",
      "orderDirection": "DESC",
      "facets": [],
    };

    var body = json.encode(data);

    final response = await http.post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getDiscussionSearch),
        headers: NetworkHelper.profilePostHeaders(token!, wid!, rootOrgId!),
        body: body);

    Map responseData = json.decode(utf8.decode(response.bodyBytes));

    return responseData;
  }

  /// get reply
  static Future<dynamic> getReply(String communityId, String parentDiscussionId,
      int pageNumber, bool isAnswerPostReply) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map<String, dynamic> data = isAnswerPostReply
        ? {
      "filterCriteriaMap": {
        "communityId": communityId,
        "type": PostTypeConst.answerPostReply,
        "parentAnswerPostId": parentDiscussionId
      },
      "requestedFields": [],
      "pageNumber": pageNumber - 1,
      "pageSize": 10,
      "orderBy": "createdOn",
      "orderDirection": "DESC",
      "facets": []
    }
        : {
      "filterCriteriaMap": {
        "communityId": communityId,
        "type": PostTypeConst.answerPost,
        "parentDiscussionId": parentDiscussionId
      },
      "requestedFields": [],
      "pageNumber": pageNumber - 1,
      "pageSize": 10,
      "orderBy": "createdOn",
      "orderDirection": "DESC",
      "facets": []
    };

    var body = json.encode(data);

    final response = await http.post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getDiscussionSearch),
        headers: NetworkHelper.profilePostHeaders(token!, wid!, rootOrgId!),
        body: body);

    Map responseData = json.decode(utf8.decode(response.bodyBytes));

    return responseData;
  }

  /// get enrich data
  static Future<dynamic> getEnrichData(String requestType,
      List<Map<String, dynamic>> communityFilters, List<String> filter) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map<String, dynamic> data = {
      "request": {
        "communityFilters": communityFilters,
        "requestType": requestType,
        "filters": filter
      }
    };
    var body = json.encode(data);

    final response = await http.post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getEnrichData),
        headers: NetworkHelper.profilePostHeaders(token!, wid!, rootOrgId!),
        body: body);

    Map responseData = json.decode(utf8.decode(response.bodyBytes));
    return responseData;
  }

  static Future<dynamic> likeComment(
      String discussionId, String endPoint) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    final response = await http.post(
        Uri.parse("${ApiUrl.baseUrl}${endPoint}${discussionId}"),
        headers: NetworkHelper.profilePostHeaders(token!, wid!, rootOrgId!));
    var responseBody = json.decode(utf8.decode(response.bodyBytes));

    return responseBody;
  }

  static Future<dynamic> dislikeComment(
      String discussionId, String endPoint) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    final response = await http.post(
        Uri.parse("${ApiUrl.baseUrl}${endPoint}${discussionId}"),
        headers: NetworkHelper.profilePostHeaders(token!, wid!, rootOrgId!));
    var responseBody = json.decode(utf8.decode(response.bodyBytes));

    return responseBody;
  }

  /// Bookmark comment
  static Future<dynamic> bookmarkComment(
      String discussionId, String communityId) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    final response = await http.get(
        Uri.parse(
            "${ApiUrl.baseUrl + ApiUrl.discussionBookmark}${communityId}/${discussionId}"),
        headers: NetworkHelper.profilePostHeaders(token!, wid!, rootOrgId!));
    var responseBody = json.decode(utf8.decode(response.bodyBytes));

    return responseBody;
  }

  /// Un Bookmark comment
  static Future<dynamic> unBookmarkComment(
      String discussionId, String communityId) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    final response = await http.post(
        Uri.parse(
            "${ApiUrl.baseUrl + ApiUrl.discussionUnBookmark}${communityId}/${discussionId}"),
        headers: NetworkHelper.profilePostHeaders(token!, wid!, rootOrgId!));
    var responseBody = json.decode(utf8.decode(response.bodyBytes));
    return responseBody;
  }

  static Future<dynamic> reportDiscussion(
      String discussionId,
      String discussionText,
      List<String> reportReasons,
      String otherComment,
      String postType) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map<String, dynamic> data = {
      "discussionId": discussionId,
      "discussionText": discussionText,
      "reportedDueTo": reportReasons,
      "otherReasons": otherComment,
      "type": postType,
    };

    var body = json.encode(data);

    final response = await http.post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.discussionReport),
        headers: NetworkHelper.postHeaders(token!, wid!, rootOrgId!),
        body: body);
    var responseBody = json.decode(utf8.decode(response.bodyBytes));

    return responseBody;
  }

  /// get report options
  static Future<dynamic> getReportReasons() async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    final response = await http.get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.discussionReportReason),
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));

    Map responseData = json.decode(utf8.decode(response.bodyBytes));
    return responseData;
  }

  /// Delete discussion post or reply
  static Future<dynamic> deleteDiscussion(
      String discussionId, String endPoint) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    final response = await http.delete(
        Uri.parse("${ApiUrl.baseUrl}${endPoint}${discussionId}"),
        headers: NetworkHelper.profilePostHeaders(token!, wid!, rootOrgId!));
    var responseBody = json.decode(utf8.decode(response.bodyBytes));
    return responseBody;
  }

  /// get community
  static Future<dynamic> getCommunity(
      int pageNumber,
      String searchQuery,
      String? topicName,
      int pageSize,
      List<String> facets,
      String orderBy,
      String orderDirection,
      {Map<String, dynamic>? filters,
        Map<String, dynamic>? sortBy}) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map<String, dynamic> data = (topicName != null)
        ? {
      "filterCriteriaMap": {
        "status": ["active", "reported"],
        "topicName": topicName
      },
      "requestedFields": [],
      "pageNumber": pageNumber - 1,
      "pageSize": pageSize,
      "searchString": searchQuery,
      "facets": facets,
      "orderBy": orderBy,
      "orderDirection": orderDirection,
      "overrideCache": true,
      "sort_by": sortBy ?? {}
    }
        : {
      "filterCriteriaMap": {
        "status": ["active", "reported"]
      },
      "requestedFields": [],
      "pageNumber": pageNumber - 1,
      "pageSize": pageSize,
      "searchString": searchQuery,
      "facets": facets,
      "orderBy": orderBy,
      "orderDirection": orderDirection,
      "overrideCache": true,
      "sort_by": sortBy ?? {}
    };
    if (filters != null) {
      filters.forEach((key, value) {
        data['filterCriteriaMap'][key] = value;
      });
    }

    var body = json.encode(data);

    final response = await http.post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getCommunity),
        headers: NetworkHelper.discussionPostHeaders(token!, wid!, rootOrgId!),
        body: body);

    Map responseData = json.decode(utf8.decode(response.bodyBytes));
    return responseData;
  }

  /// get popular community
  static Future<dynamic> getPopularCommunity() async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map<String, dynamic> data = {"field": "countOfPeopleJoined"};

    var body = json.encode(data);

    final response = await http.post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.popularCommunity),
        headers: NetworkHelper.discussionPostHeaders(token!, wid!, rootOrgId!),
        body: body);

    Map responseData = json.decode(utf8.decode(response.bodyBytes));
    return responseData;
  }

  /// get community details
  static Future<dynamic> getCommunityDetails(String communityId) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    final response = await http.get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getCommunityDetails + communityId),
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));

    Map responseData = json.decode(utf8.decode(response.bodyBytes));
    return responseData;
  }

  ///join community
  static Future<dynamic> joinCommunity(String communityId) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map<String, dynamic> data = {"communityId": communityId};

    var body = json.encode(data);

    final response = await http.put(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getCommunityJoin),
        headers: NetworkHelper.profilePostHeaders(token!, wid!, rootOrgId!),
        body: body);
    var responseBody = json.decode(utf8.decode(response.bodyBytes));

    return responseBody;
  }

  ///left community
  static Future<dynamic> leftCommunity(String communityId) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map<String, dynamic> data = {"communityId": communityId};

    var body = json.encode(data);

    final response = await http.put(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getCommunityLeft),
        headers: NetworkHelper.profilePostHeaders(token!, wid!, rootOrgId!),
        body: body);
    var responseBody = json.decode(utf8.decode(response.bodyBytes));

    return responseBody;
  }

  /// user joined communities
  static Future<dynamic> getUserJoinedCommunities() async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    final response = await http.get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getUserAllCommunities),
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));

    Map responseData = json.decode(utf8.decode(response.bodyBytes));
    return responseData;
  }

  /// user joined communities Data
  static Future<dynamic> getUserJoinedCommunitiesListData() async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    final response = await http.get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getUserJoinedCommunities),
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));

    Map responseData = json.decode(utf8.decode(response.bodyBytes));
    return responseData;
  }

  /// post discussion
  static Future<dynamic> postDiscussion(
      String type, String description, String communityId, List<Map<String, String>> mentionedUsers) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map<String, dynamic> data = {
      "type": type,
      "description": description,
      "communityId": communityId,
      "mentionedUsers": mentionedUsers
    };

    var body = json.encode(data);
    final response = await http.post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.createCommunityPost),
        headers: NetworkHelper.profilePostHeaders(token!, wid!, rootOrgId!),
        body: body);
    var responseBody = json.decode(utf8.decode(response.bodyBytes));
    return responseBody;
  }

  /// update discussion
  static Future<dynamic> updateDiscussion(
      String discussionId,
      String type,
      String description,
      String communityId,
      List<String> categoryType,
      Map<String, List<String>> mediaCategory,
      List<Map<String, String>> mentionedUsers) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map<String, dynamic> data = {
      "discussionId": discussionId,
      "type": type,
      "description": description,
      "communityId": communityId,
      "categoryType": categoryType,
      "mediaCategory": mediaCategory,
      "mentionedUsers": mentionedUsers
    };

    var body = json.encode(data);
    final response = await http.post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.updateCommunityPost),
        headers: NetworkHelper.profilePostHeaders(token!, wid!, rootOrgId!),
        body: body);
    var responseBody = json.decode(utf8.decode(response.bodyBytes));
    return responseBody;
  }

  ///add post media
  static Future<dynamic> saveDiscussionMedia(
      String discussionId,
      String communityId,
      List<String> categoryType,
      Map<String, List<String>> mediaCategory,
      ) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map<String, dynamic> data = {
      "discussionId": discussionId,
      "communityId": communityId,
      "categoryType": categoryType,
      "mediaCategory": mediaCategory,
      "isInitialUpload": true
    };

    var body = json.encode(data);
    String url = ApiUrl.baseUrl + ApiUrl.updateCommunityPost;
    final response = await http.post(Uri.parse(url),
        headers: NetworkHelper.profilePostHeaders(token!, wid!, rootOrgId!),
        body: body);
    var responseBody = json.decode(utf8.decode(response.bodyBytes));
    return responseBody;
  }

  /// upload media
  static Future<dynamic> uploadMedia(
      File file, String discussionId, String communityId) async {
    String url =
        "${ApiUrl.baseUrl}${ApiUrl.discussionUploadFile}/${communityId}/${discussionId}";

    var formData = http.MultipartRequest('POST', Uri.parse(url))
      ..headers.addAll(NetworkHelper.formDataHeader());
    formData.files.add(await http.MultipartFile.fromPath('file', file.path));

    try {
      final response = await formData.send();
      return response;
    } catch (e) {
      print('Error: $e');
    }
  }

  /// create answer post
  static Future<dynamic> createAnswerPost(
      String parentDiscussionId,
      String parentAnswerPostId,
      String type,
      String description,
      String communityId,
      bool isAnswerPostReply,
      List<Map<String, String>> mentionedUsers) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map<String, dynamic> data = (!isAnswerPostReply)
        ? {
      "parentDiscussionId": parentDiscussionId,
      "type": type,
      "description": description,
      "communityId": communityId,
      "mentionedUsers": mentionedUsers
    }
        : {
      "parentDiscussionId": parentDiscussionId,
      "parentAnswerPostId": parentAnswerPostId,
      "type": type,
      "description": description,
      "communityId": communityId,
      "mentionedUsers": mentionedUsers
    };

    var _uri = (!isAnswerPostReply)
        ? ApiUrl.createCommunityAnswerPosts
        : ApiUrl.createCommunityAnswerPostReply;
    var body = json.encode(data);
    final response = await http.post(Uri.parse(ApiUrl.baseUrl + _uri),
        headers: NetworkHelper.profilePostHeaders(token!, wid!, rootOrgId!),
        body: body);
    var responseBody = json.decode(utf8.decode(response.bodyBytes));
    return responseBody;
  }

  /// update discussion
  static Future<dynamic> updateAnswerPost(
      String answerPostId,
      String description,
      List<String> categoryType,
      Map<String, List<String>> mediaCategory,
      bool isInitialUpload,
      bool isAnswerPostReply,
      List<Map<String, String>> mentionedUsers) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map<String, dynamic> data = (isInitialUpload)
        ? (isAnswerPostReply)
        ? {
      "answerPostId": answerPostId,
      "description": description,
      "categoryType": categoryType,
      "mediaCategory": mediaCategory,
      "isInitialUpload": isInitialUpload,
      "mentionedUsers": mentionedUsers
    }
        : {
      "answerPostReplyId": answerPostId,
      "description": description,
      "categoryType": categoryType,
      "mediaCategory": mediaCategory,
      "isInitialUpload": isInitialUpload,
      "mentionedUsers": mentionedUsers
    }
        : (isAnswerPostReply)
        ? {
      "answerPostReplyId": answerPostId,
      "description": description,
      "categoryType": categoryType,
      "mediaCategory": mediaCategory,
      "mentionedUsers": mentionedUsers
    }
        : {
      "answerPostId": answerPostId,
      "description": description,
      "categoryType": categoryType,
      "mediaCategory": mediaCategory,
      "mentionedUsers": mentionedUsers
    };

    var _uri = (isAnswerPostReply)
        ? ApiUrl.createCommunityUpdateAnswerPostReply
        : ApiUrl.createCommunityUpdateAnswerPost;
    var body = json.encode(data);
    final response = await http.post(Uri.parse(ApiUrl.baseUrl + _uri),
        headers: NetworkHelper.profilePostHeaders(token!, wid!, rootOrgId!),
        body: body);
    var responseBody = json.decode(utf8.decode(response.bodyBytes));
    return responseBody;
  }

  /// get community members
  static Future<dynamic> getCommunityMembers(
      int pageNumber, String searchQuery, String communityId) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map<String, dynamic> data = (searchQuery != '')
        ? {
      "communityId": communityId,
      "offset": pageNumber - 1,
      "limit": 50,
      "searchString": searchQuery,
    }
        : {
      "communityId": communityId,
      "offset": pageNumber - 1,
      "limit": 50,
    };

    var body = json.encode(data);

    final response = await http.post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getCommunityMembers),
        headers: NetworkHelper.profilePostHeaders(token!, wid!, rootOrgId!),
        body: body);

    Map responseData = json.decode(utf8.decode(response.bodyBytes));
    return responseData;
  }

  /// search community members
  static Future<dynamic> searchCommunityMembers(
      int pageNumber, String searchQuery, String communityId) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map<String, dynamic> data = {
      "request": {
        "filters": {
          "discussionCommunities": [communityId]
        },
        "query": searchQuery,
        "offset": pageNumber - 1,
        "limit": 50,
        "fields": []
      }
    };

    var body = json.encode(data);

    final response = await http.post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getUserDetails),
        headers: NetworkHelper.profilePostHeaders(token!, wid!, rootOrgId!),
        body: body);

    Map responseData = json.decode(utf8.decode(response.bodyBytes));
    return responseData;
  }

  static Future<dynamic> reportCommunity(String communityId,
      List<String> reportReasons, String otherComment) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map<String, dynamic> data = {
      "communityId": communityId,
      "reportedDueTo": reportReasons,
      "otherReasons": otherComment,
    };

    var body = json.encode(data);

    final response = await http.post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.reportCommunity),
        headers: NetworkHelper.postHeaders(token!, wid!, rootOrgId!),
        body: body);
    var responseBody = json.decode(utf8.decode(response.bodyBytes));
    return responseBody;
  }

  static Future<http.Response> getDiscussionById(
      {required String communityId, required String discussionId}) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    final body = jsonEncode({
      "filterCriteriaMap": {
        "type": "question",
        "communityId": communityId,
        "discussionId": discussionId,
        "isActive": true
      },
      "requestedFields": [],
      "pageNumber": 0,
      "pageSize": 5
    });

    final response = await http.post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getDiscussionSearch),
        headers: NetworkHelper.profilePostHeaders(token!, wid!, rootOrgId!),
        body: body);

    return response;
  }

  /// user list for tagging
  static Future<dynamic> getUserListForTagging(String searchText) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      "request": {
        "query": searchText,
        "filters": {
          "status": 1
        }
      }
    };

    String body = json.encode(data);

    final response = await http.post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getUsersByEndpoint),
        headers: NetworkHelper.postHeaders(token!, wid!, rootOrgId!),
        body: body);

    Map responseData = json.decode(utf8.decode(response.bodyBytes));
    return responseData;
  }
}
