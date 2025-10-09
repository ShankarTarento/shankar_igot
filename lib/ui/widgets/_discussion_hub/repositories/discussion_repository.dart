import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:karmayogi_mobile/models/_api/user_action_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_models/community_detail_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_models/community_member_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_models/community_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_models/user_community_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/discussion/add_discussion/_models/tag_user_data_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/discussion/discussion_view/_models/discussion_model.dart';
import 'package:karmayogi_mobile/ui/widgets/comment_section/model/comment_action_model.dart';
import '../../../pages/_pages/search/models/community_search_model.dart';
import '../services/discussion_service.dart';

class DiscussionRepository with ChangeNotifier {
  /// get discussions
  Future<DiscussionModel?> getDiscussion(
      int pageNumber, String searchQuery, String communityId) async {
    try {
      final response = searchQuery.isNotEmpty
          ? await DiscussionService.searchDiscussion(
          pageNumber, searchQuery, communityId)
          : await DiscussionService.getDiscussion(pageNumber, communityId);

      var responseData =
      DiscussionModel.fromJson(response['result']['search_results']);
      return responseData;
    } catch (_) {
      return null;
    }
  }

  /// get discussions
  Future<DiscussionModel?> getMediaDiscussion(int pageNumber,
      String searchQuery, String communityId, List<String> categoryType) async {
    try {
      final response = await DiscussionService.getMediaDiscussion(
          pageNumber, searchQuery, communityId, categoryType);
      var responseData =
      DiscussionModel.fromJson(response['result']['search_results']);

      return responseData;
    } catch (_) {
      return null;
    }
  }

  /// get bookmarked discussions
  Future<DiscussionModel?> getBookmarkedDiscussion(
      int pageNumber, String searchQuery, String communityId) async {
    try {
      final response = await DiscussionService.getBookmarkedDiscussion(
          pageNumber, searchQuery, communityId);
      var responseData =
      DiscussionModel.fromJson(response['result']['search_results']);

      return responseData;
    } catch (_) {
      return null;
    }
  }

  /// get global discussions
  Future<DiscussionModel?> getGlobalDiscussion(
      int pageNumber, String searchQuery, String communityId) async {
    try {
      final response = await DiscussionService.getGlobalDiscussion(
          pageNumber, searchQuery, communityId);
      var responseData =
      DiscussionModel.fromJson(response['result']['search_results']);

      return responseData;
    } catch (_) {
      return null;
    }
  }

  /// get my discussions
  Future<DiscussionModel?> getMyDiscussion(
      int pageNumber, String searchQuery, String communityId) async {
    try {
      final response = await DiscussionService.getMyDiscussion(
          pageNumber, searchQuery, communityId);
      var responseData =
      DiscussionModel.fromJson(response['result']['search_results']);

      return responseData;
    } catch (_) {
      return null;
    }
  }

  /// get reply
  Future<DiscussionModel?> getReply(String communityId,
      String parentDiscussionId, int pageNumber, bool isAnswerPostReply) async {
    try {
      final response = await DiscussionService.getReply(
          communityId, parentDiscussionId, pageNumber, isAnswerPostReply);
      var responseData =
      DiscussionModel.fromJson(response['result']['search_results']);

      return responseData;
    } catch (_) {
      return null;
    }
  }

  /// get discussion enrich data
  Future<DiscussionEnrichData?> getEnrichData(String requestType,
      List<Map<String, dynamic>> communityFilters, List<String> filter) async {
    try {
      final response = await DiscussionService.getEnrichData(
          requestType, communityFilters, filter);
      var responseData =
      DiscussionEnrichData.fromJson(response['result']['search_results']);

      return responseData;
    } catch (_) {
      return null;
    }
  }

  Future<dynamic> likeComment(String discussionId, String endPoint) async {
    try {
      final response =
      await DiscussionService.likeComment(discussionId, endPoint);

      String responseCode = response['responseCode'] ?? '';
      String errMsg = response['params']?['errMsg'] ?? '';
      return CommentActionModel(responseCode: responseCode, errMsg: errMsg);
    } catch (_) {
      return CommentActionModel(responseCode: '', errMsg: '');
    }
  }

  Future<dynamic> dislikeComment(String discussionId, String endPoint) async {
    try {
      final response =
      await DiscussionService.dislikeComment(discussionId, endPoint);

      String responseCode = response['responseCode'] ?? '';
      String errMsg = response['params']?['errMsg'] ?? '';
      return CommentActionModel(responseCode: responseCode, errMsg: errMsg);
    } catch (_) {
      return CommentActionModel(responseCode: '', errMsg: '');
    }
  }

  /// Bookmark comment
  Future<dynamic> bookmarkComment(
      String discussionId, String communityId) async {
    try {
      final response =
      await DiscussionService.bookmarkComment(discussionId, communityId);

      String responseCode = response['responseCode'] ?? '';
      String errMsg = response['params']?['err'] ?? '';
      return CommentActionModel(responseCode: responseCode, errMsg: errMsg);
    } catch (_) {
      return CommentActionModel(responseCode: '', errMsg: '');
    }
  }

  /// Bookmark comment
  Future<dynamic> unBookmarkComment(
      String discussionId, String communityId) async {
    try {
      final response =
      await DiscussionService.unBookmarkComment(discussionId, communityId);

      String responseCode = response['responseCode'] ?? '';
      String errMsg = response['params']?['err'] ?? '';
      return CommentActionModel(responseCode: responseCode, errMsg: errMsg);
    } catch (_) {
      return CommentActionModel(responseCode: '', errMsg: '');
    }
  }

  Future<dynamic> reportDiscussion(String discussionId, String discussionText,
      List<String> reportReasons, String otherComment, String postType) async {
    try {
      final response = await DiscussionService.reportDiscussion(
          discussionId, discussionText, reportReasons, otherComment, postType);
      String responseCode = response['responseCode'] ?? '';
      String errMsg = response['params']?['err'] ?? '';
      String status = response['result']?['status'] ?? '';
      return CommentActionModel(
          responseCode: responseCode, errMsg: errMsg, status: status);
    } catch (_) {
      return CommentActionModel(responseCode: '', errMsg: '', status: '');
    }
  }

  Future<List<String>> getReportReasons() async {
    try {
      final response = await DiscussionService.getReportReasons();
      List<String> reportReasons = [];
      if (response['result']['response']['value'] is List) {
        reportReasons = (response['result']['response']['value'] as List)
            .map((item) => item.toString())
            .toList();
      }
      return reportReasons;
    } catch (_) {
      return [];
    }
  }

  Future<dynamic> deleteDiscussion(String discussionId, String endPoint) async {
    try {
      final response =
      await DiscussionService.deleteDiscussion(discussionId, endPoint);
      String responseCode = await (response['responseCode'] != null)
          ? response['responseCode']
          : '';
      String errMsg = response['message'] ?? '';
      return CommentActionModel(
          responseCode: responseCode, errMsg: errMsg, status: '');
    } catch (_) {
      return CommentActionModel(responseCode: '', errMsg: '', status: '');
    }
  }

  /// get community
  Future<CommunityModel?> getCommunity(
      {required int pageNumber,
        String? searchQuery,
        String? topicName,
        int? pageSize,
        List<String>? facets,
        String orderBy = '',
        String orderDirection = ''}) async {
    try {
      final response = await DiscussionService.getCommunity(
          pageNumber,
          searchQuery ?? '',
          topicName,
          pageSize ?? 20,
          facets ?? [],
          orderBy,
          orderDirection);
      var responseData =
      CommunityModel.fromJson(response['result']['search_results']);

      return responseData;
    } catch (_) {
      return null;
    }
  }

  /// get popular community
  Future<CommunityModel?> getPopularCommunity() async {
    try {
      final response = await DiscussionService.getPopularCommunity();
      var responseData = CommunityModel.fromJson(response['result']);

      return responseData;
    } catch (_) {
      return null;
    }
  }

  /// get community details
  Future<CommunityDetailModel?> getCommunityDetails(String communityId) async {
    try {
      final response = await DiscussionService.getCommunityDetails(communityId);
      var responseData =
      CommunityDetailModel.fromJson(response['result']['communityDetails']);

      return responseData;
    } catch (_) {
      return null;
    }
  }

  /// join community
  Future<dynamic> joinCommunity(String communityId) async {
    try {
      final response = await DiscussionService.joinCommunity(communityId);

      String responseCode = response['responseCode'] ?? '';
      String errMsg = response['params']?['err'] ?? '';
      return UserActionModel(responseCode: responseCode, errMsg: errMsg);
    } catch (_) {
      return UserActionModel(responseCode: '', errMsg: '');
    }
  }

  /// join community
  Future<dynamic> leftCommunity(String communityId) async {
    try {
      final response = await DiscussionService.leftCommunity(communityId);

      String responseCode = response['responseCode'] ?? '';
      String errMsg = response['params']?['err'] ?? '';
      return UserActionModel(responseCode: responseCode, errMsg: errMsg);
    } catch (_) {
      return UserActionModel(responseCode: '', errMsg: '');
    }
  }

  /// get user joined communities
  Future<List<UserCommunityIdData>> getUserJoinedCommunities() async {
    try {
      final response = await DiscussionService.getUserJoinedCommunities();
      List<UserCommunityIdData> userJoinedCommunities = [];
      if (response['result']['communityId'] is List) {
        userJoinedCommunities = (response['result']['communityId'] as List)
            .map((item) => UserCommunityIdData.fromJson(item))
            .toList();
      }
      return userJoinedCommunities;
    } catch (_) {
      return [];
    }
  }

  /// get user joined communities list data
  Future<List<CommunityItemData>> getUserJoinedCommunitiesListData() async {
    try {
      final response =
      await DiscussionService.getUserJoinedCommunitiesListData();
      List<CommunityItemData> userJoinedCommunities = [];
      if (response['result']['communityDetails'] is List) {
        userJoinedCommunities = (response['result']['communityDetails'] as List)
            .map((item) => CommunityItemData.fromJson(item))
            .toList();
      }
      return userJoinedCommunities;
    } catch (_) {
      return [];
    }
  }

  ///Create post
  Future<DiscussionItemData?> postDiscussion(
      {required String type,
        required String description,
        required String communityId,
        required List<Map<String, String>> mentionedUsers}) async {
    try {
      final response = await DiscussionService.postDiscussion(
          type, description, communityId, mentionedUsers);
      String responseData = await response['responseCode'] ?? '';
      if (responseData.toUpperCase() == "CREATED") {
        var data = await response['result'];
        if (data != null) {
          DiscussionItemData discussionItemData =
          await DiscussionItemData.fromJson(data);
          return discussionItemData;
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (_) {
      return null;
    }
  }

  ///update post
  Future<DiscussionItemData?> updateDiscussion({
    required String discussionId,
    required String type,
    required String description,
    required String communityId,
    required List<String> categoryType,
    required Map<String, List<String>> mediaCategory,
    required List<Map<String, String>> mentionedUsers
  }) async {
    try {
      final response = await DiscussionService.updateDiscussion(discussionId,
          type, description, communityId, categoryType, mediaCategory, mentionedUsers);
      String responseData = await response['responseCode'] ?? '';
      if (responseData.toUpperCase() == "OK") {
        var data = await response['result']['data'];
        if (data != null) {
          DiscussionItemData discussionItemData =
          await DiscussionItemData.fromJson(data);
          return discussionItemData;
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (_) {
      return null;
    }
  }

  ///add post media
  Future<DiscussionItemData?> saveDiscussionMedia({
    required String discussionId,
    required String communityId,
    required List<String> categoryType,
    required Map<String, List<String>> mediaCategory,
  }) async {
    try {
      final response = await DiscussionService.saveDiscussionMedia(
          discussionId, communityId, categoryType, mediaCategory);
      String responseData = await response['responseCode'] ?? '';
      if (responseData.toUpperCase() == "OK") {
        var data = await response['result'];
        if (data != null) {
          DiscussionItemData discussionItemData =
          await DiscussionItemData.fromJson(data);
          return discussionItemData;
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (_) {
      return null;
    }
  }

  ///Upload medial file
  Future<dynamic> uploadMedia(
      File file, String discussionId, String communityId) async {
    var response;
    try {
      response =
      await DiscussionService.uploadMedia(file, discussionId, communityId);
      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        var contents = jsonDecode(responseBody);
        return contents['result']['url'];
      } else {
        return response.statusCode;
      }
    } catch (_) {
      return _;
    }
  }

  ///Create answer post
  Future<DiscussionItemData?> createAnswerPost(
      {required String parentDiscussionId,
        String? parentAnswerPostId,
        required String type,
        required String description,
        required String communityId,
        required bool isAnswerPostReply,
        required List<Map<String, String>> mentionedUsers}) async {
    try {
      final response = await DiscussionService.createAnswerPost(
          parentDiscussionId,
          parentAnswerPostId ?? '',
          type,
          description,
          communityId,
          isAnswerPostReply,
          mentionedUsers
      );
      String responseData = await response['responseCode'] ?? '';
      if (responseData.toUpperCase() == "CREATED") {
        var data = await response['result'];
        if (data != null) {
          DiscussionItemData discussionItemData =
          await DiscussionItemData.fromJson(data);
          return discussionItemData;
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (_) {
      return null;
    }
  }

  ///update answer post
  Future<DiscussionItemData?> updateAnswerPost({
    required String answerPostId,
    required String description,
    required List<String> categoryType,
    required Map<String, List<String>> mediaCategory,
    bool isInitialUpload = false,
    required bool isAnswerPostReply,
    required List<Map<String, String>> mentionedUsers
  }) async {
    try {
      final response = await DiscussionService.updateAnswerPost(
          answerPostId,
          description,
          categoryType,
          mediaCategory,
          isInitialUpload,
          isAnswerPostReply,
          mentionedUsers);
      String responseData = await response['responseCode'] ?? '';
      if (responseData.toUpperCase() == "OK") {
        var data = await response['result'];
        if (data != null) {
          DiscussionItemData discussionItemData =
          await DiscussionItemData.fromJson(data);
          return discussionItemData;
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (_) {
      return null;
    }
  }

  /// get community members
  Future<CommunityMemberModel?> getCommunityMembers(
      {required int pageNumber,
        String? searchQuery,
        required String communityId}) async {
    try {
      final response = await DiscussionService.getCommunityMembers(
          pageNumber, searchQuery ?? '', communityId);
      var responseData = CommunityMemberModel.fromJson(response['result']);
      return responseData;
    } catch (_) {
      return null;
    }
  }

  /// get community members
  Future<CommunityMemberModel?> searchCommunityMembers(
      {required int pageNumber,
        String? searchQuery,
        required String communityId}) async {
    try {
      final response = await DiscussionService.searchCommunityMembers(
          pageNumber, searchQuery ?? '', communityId);
      var responseData = response['result'];
      List<MemberDetails> members = [];
      if (responseData?['response']?['content'] != null) {
        var content = responseData['response']['content'] as List<dynamic>;
        for (var memberJson in content) {
          var member = MemberDetails(
            userId: memberJson['id'] as String?,
            firstName: memberJson['firstName'] as String?,
            userProfileImgUrl:
            memberJson['profileDetails']?['profileImageUrl'] as String?,
            userProfileStatus:
            memberJson['profileDetails']?['profileStatus'] as String?,
            department: memberJson['profileDetails']?['employmentDetails']
            ?['departmentName'] as String?,
          );
          members.add(member);
        }
        return CommunityMemberModel(
            userDetails: members,
            totalCount: responseData?['response']?['count'] ?? 0);
      } else
        return null;
    } catch (e) {
      return null;
    }
  }

  ///Report community
  Future<dynamic> reportCommunity(String communityId,
      List<String> reportReasons, String otherComment) async {
    try {
      final response = await DiscussionService.reportCommunity(
          communityId, reportReasons, otherComment);
      String responseCode = response['responseCode'] ?? '';
      String errMsg = response['params']?['err'] ?? '';
      String status = response['result']?['status'] ?? '';
      return CommentActionModel(
          responseCode: responseCode, errMsg: errMsg, status: status);
    } catch (_) {
      return CommentActionModel(responseCode: '', errMsg: '', status: '');
    }
  }

  // community search
  Future<CommunitySearchModel?> searchCommunity(
      {required int pageNumber,
        String? searchQuery,
        String? topicName,
        int? pageSize,
        List<String>? facets,
        String orderBy = '',
        String orderDirection = '',
        Map<String, dynamic>? filters,
        Map<String, dynamic>? sortBy}) async {
    try {
      final response = await DiscussionService.getCommunity(
          pageNumber,
          searchQuery ?? '',
          topicName,
          pageSize ?? 20,
          facets ?? [],
          orderBy,
          orderDirection,
          filters: filters,
          sortBy: sortBy);
      var responseData =
      CommunitySearchModel.fromJson(response['result']['search_results']);

      return responseData;
    } catch (_) {
      return null;
    }
  }

  Future<DiscussionItemData?> getDiscussionById(
      {required String communityId, required String discussionId}) async {
    try {
      final response = await DiscussionService.getDiscussionById(
          communityId: communityId, discussionId: discussionId);

      if (response.statusCode != 200) return null;

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      final data = responseData['result']?['search_results']?['data'];

      if (data is List && data.isNotEmpty) {
        DiscussionItemData discussionItemData =
        DiscussionItemData.fromJson(data.first);
        return discussionItemData;
      }

      return null;
    } catch (e) {
      debugPrint('Error fetching discussion by ID: $e');
      return null;
    }
  }

  /// user list for tagging
  Future<List<TagUserDataModel>> getUserListForTagging(String searchText) async {
    try {
      final response = await DiscussionService.getUserListForTagging(searchText);
      List<TagUserDataModel> userJoinedCommunities = [];
      if (response['result']['response']['content'] is List) {
        userJoinedCommunities = (response['result']['response']['content'] as List)
            .map((item) => TagUserDataModel.fromJson(item))
            .toList();
      }
      return userJoinedCommunities;
    } catch (_) {
      return [];
    }
  }
}
