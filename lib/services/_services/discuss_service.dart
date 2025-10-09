import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:karmayogi_mobile/util/network_helper.dart';
import './../../constants/index.dart';
import './../../services/index.dart';

class DiscussService extends BaseService {
  DiscussService(HttpClient client) : super(client);

  /// Return recent discussions as response
  static Future<dynamic> getRecentDiscussion(int pageNo) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? nodebbUserId = await _storage.read(key: Storage.nodebbUserId);

    final response = await http.get(
        Uri.parse(
            ApiUrl.baseUrl + ApiUrl.recentDiscussion + '?_uid=$nodebbUserId&page=$pageNo'),
        headers: NetworkHelper.discussionGetHeaders(token!, wid!));
    // developer.log(response.body);
    Map recentDiscussionsResponse = json.decode(response.body);

    return recentDiscussionsResponse;
  }

  /// Return filtered discussions by category as response
  static Future<dynamic> getFilteredDiscussionsByCategory(
      int categoryId, int pageNo) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? nodebbUserId = await _storage.read(key: Storage.nodebbUserId);
    final response = await http.get(
        Uri.parse(ApiUrl.baseUrl +
            ApiUrl.filterDiscussionsByCategory +
            categoryId.toString() +
            '?page=$pageNo&_uid=$nodebbUserId'),
        headers: NetworkHelper.discussionGetHeaders(token!, wid!));

    Map filteredDiscussionsResponse = json.decode(response.body);

    return filteredDiscussionsResponse;
  }

  /// Return filtered discussions by tag as response
  static Future<dynamic> getFilteredDiscussionsByTag(
      String tag, int pageNo) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? nodebbUserId = await _storage.read(key: Storage.nodebbUserId);
    final response = await http.get(
        Uri.parse(ApiUrl.baseUrl +
            ApiUrl.filterDiscussionsByTag +
            tag +
            '?page=$pageNo&_uid=$nodebbUserId'),
        headers: NetworkHelper.discussionGetHeaders(token!, wid!));

    Map filteredDiscussionsResponse = json.decode(response.body);

    return filteredDiscussionsResponse;
  }

  /// Return popular discussions as response (new apis)
  static Future<dynamic> getPopularDiscussion(int pageNo) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? nodebbUserId = await _storage.read(key: Storage.nodebbUserId);

    final response = await http.get(
        Uri.parse(ApiUrl.baseUrl +
            ApiUrl.trendingDiscussion +
            '$pageNo' +
            '&_uid=$nodebbUserId'),
        headers: NetworkHelper.discussionGetHeaders(token!, wid!));

    Map popularDiscussionsResponse = json.decode(response.body);

    return popularDiscussionsResponse;
  }

  /// Return my discussions as response
  static Future<dynamic> getMyDiscussion() async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? nodebbUserId = await _storage.read(key: Storage.nodebbUserId);
    String? userName = await _storage.read(key: Storage.userName);

    final response = await http.get(
        Uri.parse(ApiUrl.baseUrl +
            ApiUrl.myDiscussions +
            userName! +
            '?_uid=$nodebbUserId'),
        headers: NetworkHelper.discussionGetHeaders(token!, wid!));

    Map myDiscussionsResponse = json.decode(response.body);
    return myDiscussionsResponse;
  }

  /// Return my upvoted discussions as response
  static Future<dynamic> getUpvotedDiscussion() async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? nodebbUserId = await _storage.read(key: Storage.nodebbUserId);
    String? userName = await _storage.read(key: Storage.userName);

    final response = await http.get(
        Uri.parse(ApiUrl.baseUrl +
            ApiUrl.myDiscussions +
            userName! +
            '/upvoted'
                '?_uid=$nodebbUserId'),
        headers: NetworkHelper.discussionGetHeaders(token!, wid!));

    Map upvotedDiscussionsResponse = json.decode(response.body);
    return upvotedDiscussionsResponse;
  }

  /// Return my upvoted discussions as response
  static Future<dynamic> getDownvotedDiscussion() async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? nodebbUserId = await _storage.read(key: Storage.nodebbUserId);
    String? userName = await _storage.read(key: Storage.userName);

    final response = await http.get(
        Uri.parse(ApiUrl.baseUrl +
            ApiUrl.myDiscussions +
            userName! +
            '/downvoted'
                '?_uid=$nodebbUserId'),
        headers: NetworkHelper.discussionGetHeaders(token!, wid!));

    Map downvotedDiscussionsResponse = json.decode(response.body);
    return downvotedDiscussionsResponse;
  }

  /// Return my discussions as response
  static Future<dynamic> getUserDiscussion(String userName) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? nodebbUserId = await _storage.read(key: Storage.nodebbUserId);

    final response = await http.get(
        Uri.parse(ApiUrl.baseUrl +
            ApiUrl.myDiscussions +
            userName +
            '?_uid=$nodebbUserId'),
        headers: NetworkHelper.discussionGetHeaders(token!, wid!));

    Map userDiscussionsResponse = json.decode(response.body);

    return userDiscussionsResponse;
  }

  /// Return trending discussions as response
  static Future<dynamic> getTrendingDiscussions(int pageNo) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? nodebbUserId = await _storage.read(key: Storage.nodebbUserId);
    // print(ApiUrl.baseUrl +
    //         ApiUrl.trendingDiscussion +
    //         '$pageNo' +
    //         '&_uid=$nodebbUserId');
    final response = await http.get(
        Uri.parse(ApiUrl.baseUrl +
            ApiUrl.trendingDiscussion +
            '$pageNo' +
            '&_uid=$nodebbUserId'),
        headers: NetworkHelper.discussionGetHeaders(token!, wid!));

    Map trendingDiscussionsResponse = json.decode(response.body);

    return trendingDiscussionsResponse;
  }

  static Future<dynamic> getSavedDiscussions(int pageNo) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? userName = await _storage.read(key: Storage.userName);
    String? nodebbUserId = await _storage.read(key: Storage.nodebbUserId);
    String url = ApiUrl.baseUrl +
        ApiUrl.savedPosts +
        userName! +
        '/bookmarks?_uid=$nodebbUserId';

    final response = await http.get(Uri.parse(url),
        headers: NetworkHelper.discussionGetHeaders(token!, wid!));
    // print('$url: ${response.statusCode}');
    Map savedPostsResponse = json.decode(response.body);

    return savedPostsResponse;
  }

  /// Return trending tags as response
  static Future<dynamic> getTrendingTags() async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? nodebbUserId = await _storage.read(key: Storage.nodebbUserId);

    final response = await http.get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.trendingTags + '?_uid=$nodebbUserId'),
        headers: NetworkHelper.discussionGetHeaders(token!, wid!));

    Map trendingTagsResponse = json.decode(response.body);

    return trendingTagsResponse;
  }

  /// Return trending tags as response
  static Future<dynamic> getDiscussionDetail(
      int tid, int pageNo, String sort) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? nodebbUserId = await _storage.read(key: Storage.nodebbUserId);

    String url = ApiUrl.baseUrl +
        ApiUrl.discussionDetail +
        '/' +
        '$tid' +
        '?page=' +
        '$pageNo' +
        '&_uid=$nodebbUserId' +
        sort;
    final response = await http.get(Uri.parse(url),
        headers: NetworkHelper.discussionGetHeaders(token!, wid!));
    // developer.log(response.body);
    Map discussionDetailResponse = json.decode(response.body);

    return discussionDetailResponse;
  }

  static Future<dynamic> postReply(int tid, String content) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? nodebbUserId = await _storage.read(key: Storage.nodebbUserId);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map<String, String> data = {
      'content': content,
      '_uid': nodebbUserId!,
    };
    var body = json.encode(data);

    final response = await http.post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.replyDiscussion + '$tid'),
        headers: NetworkHelper.discussionPostHeaders(token!, wid!, rootOrgId!),
        body: body);
    var contents = jsonDecode(response.body);

    return contents;
  }

  static Future<dynamic> postComment(int pid, int tid, String content) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? nodebbUserId = await _storage.read(key: Storage.nodebbUserId);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map<String, dynamic> data = {
      'content': content,
      'toPid': pid,
      '_uid': nodebbUserId,
    };
    var body = json.encode(data);

    final response = await http.post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.replyDiscussion + '$tid'),
        headers: NetworkHelper.discussionPostHeaders(token!, wid!, rootOrgId!),
        body: body);
    var contents = jsonDecode(response.body);
    return contents;
  }

  static Future<dynamic> postDiscussion(
      int? pid, int cid, String title, String content, List<String> tags) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? nodebbUserId = await _storage.read(key: Storage.nodebbUserId);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map<String, dynamic> data = (pid != null)
        ? {
      "uid": nodebbUserId,
      "content": content,
      "title": title,
      "tags": tags
    }
        : {
      '_uid': nodebbUserId,
      'cid': [cid],
      'title': title,
      'content': content,
      'tags': tags,
    };

    var body = json.encode(data);
    String url;
    if (pid != null) {
      url = ApiUrl.baseUrl + ApiUrl.updatePost + '$pid?_uid=$nodebbUserId';
    } else {
      url = ApiUrl.baseUrl + ApiUrl.saveDiscussion;
    }
    final response = await http.post(Uri.parse(url),
        headers: NetworkHelper.discussionPostHeaders(token!, wid!, rootOrgId!),
        body: body);
    var contents = jsonDecode(response.body);
    return contents;
  }

  static Future<dynamic> bookmarkDiscussion(mainPid, status) async {
    final _storage = FlutterSecureStorage();

    String? token = await _storage.read(key: Storage.authToken);
    String? nodebbUserId = await _storage.read(key: Storage.nodebbUserId);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    String? wid = await _storage.read(key: Storage.wid);
    String url = ApiUrl.baseUrl +
        ApiUrl.bookmark +
        '$mainPid/bookmark?_uid=$nodebbUserId';
    Map<String, dynamic> data = {
      '_uid': nodebbUserId,
    };
    var body = json.encode(data);
    Response response;
    if (!status) {
      response = await post(Uri.parse(url),
          headers: NetworkHelper.discussionPostHeaders(token!, wid!, rootOrgId!),
          body: body);
    } else {
      response = await delete(Uri.parse(url),
          headers: NetworkHelper.discussionPostHeaders(token!, wid!, rootOrgId!));
      // print(response.body);
    }
    return response;
  }

  static Future<dynamic> deleteDiscussion(int pid) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? nodebbUserId = await _storage.read(key: Storage.nodebbUserId);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    final response = await http.delete(
      Uri.parse(ApiUrl.baseUrl +
          ApiUrl.deleteDiscussion +
          '$pid' +
          '?_uid=$nodebbUserId'),
      headers: NetworkHelper.discussionPostHeaders(token!, wid!, rootOrgId!),
    );

    var contents = jsonDecode(response.body);
    return contents;
  }

  /// To get discussion for particular course
  static Future<dynamic> getDiscussionsOfCourse(String courseId) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? nodebbUserId = await _storage.read(key: Storage.nodebbUserId);
    String? rootOrgId = await _storage.read(key: Storage.deptId);
    // developer.log()

    Map data1 = {
      "request": {"identifier": "$courseId", "type": "course"}
    };

    final response = await http.post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.courseDiscussions),
        headers: NetworkHelper.discussionPostHeaders(token!, wid!, rootOrgId!),
        body: jsonEncode(data1));

    final result = jsonDecode(response.body);

    var discussionIds = [];
    result['result'].map((item) => discussionIds.add(item['cid'])).toList();

    Map data2 = {
      "request": {"cids": discussionIds}
    };

    Response discussionsResponse = await http.post(
        Uri.parse(ApiUrl.baseUrl +
            ApiUrl.courseDiscussionList +
            '?_uid=$nodebbUserId'),
        headers: NetworkHelper.discussionPostHeaders(token, wid, rootOrgId),
        body: jsonEncode(data2));

    dynamic discussions;
    if (json.decode(discussionsResponse.body)['result'][0]['statusCode'] ==
        null) {
      discussions = json.decode(discussionsResponse.body);
      return discussions;
    } else {
      throw 'Can\'t get course discussion';
    }
  }

  static Future<dynamic> getCategoryIdOfCourse(String courseId) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      "request": {"identifier": "$courseId", "type": "course"}
    };

    final response = await http.post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.courseDiscussions),
        headers: NetworkHelper.discussionPostHeaders(token!, wid!, rootOrgId!),
        body: jsonEncode(data));

    final result = jsonDecode(response.body);

    var discussionIds = [];
    if (result['result'] != null) {
      if (result['result'].length > 0) {
        result['result'].map((item) => discussionIds.add(item['cid'])).toList();
      }
    }
    return discussionIds;
  }
}
