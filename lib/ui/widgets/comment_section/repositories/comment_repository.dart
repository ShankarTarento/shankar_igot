
import 'package:flutter/widgets.dart';
import 'package:karmayogi_mobile/ui/widgets/comment_section/model/comment_tree_data_model.dart';
import '../model/comment_action_model.dart';
import '../model/comment_model.dart';
import '../services/comment_service.dart';

class CommentRepository with ChangeNotifier {


  /// get comments tree
  Future<CommentTreeData?> getCommentsTree(String entityId, String entityType, String workflow) async {
    try {
      final  response = await CommentService.getCommentsTree(entityId, entityType, workflow);
      var responseData = CommentTreeData.fromJson(response['result']);

      return responseData;
    } catch (_) {
      return null;
    }
  }

  /// get first level comments
  Future<CommentModel?> getComments(String commentTreeId, String entityId, String entityType, String workflow, int pageNumber) async {
    try {
      final  response = await CommentService.getComments(commentTreeId, entityId, entityType, workflow, pageNumber);
      var responseData = CommentModel.fromJson(response['result']);

      return responseData;
    } catch (_) {
      return null;
    }
  }

  /// get reply
  Future<CommentModel?> getReply(List<String> commentList) async {
    try {
      final  response = await CommentService.getReply(commentList);
      var responseData = CommentModel.fromJson(response['result']);
      return responseData;
    } catch (_) {
      return null;
    }
  }

  Future<dynamic> addFirstComment(String entityType, String entityId, String workflow,
      String comment, String role, String userName, String userPic, String designation, String profileStatus, List<Map<String, String>> mentionedUsers) async {
    try {
      final response = await CommentService.addFirstComment(entityType, entityId, workflow,
          comment, role, userName, userPic, designation, profileStatus, mentionedUsers);
      String? responseData = response['commentTree']['commentTreeId'];
      if (responseData != null && responseData.isNotEmpty) {
        return 'ok';
      } else {
        return '';
      }
    } catch (_) {
      return '';
    }
  }

  Future<dynamic> addNewComment(String commentTreeId, List<String> hierarchyPath, String comment,
      String role, String userName, String userPic, String designation, String profileStatus, List<Map<String, String>> mentionedUsers) async {
    try {
      final response = await CommentService.addNewComment(commentTreeId, hierarchyPath, comment, role,
          userName, userPic, designation, profileStatus, [], mentionedUsers);
      String? responseData = response['commentTree']['commentTreeId'];
      if (responseData != null && responseData.isNotEmpty) {
        return 'ok';
      } else {
        return '';
      }
    } catch (_) {
      return '';
    }
  }

  Future<dynamic> addReply(String commentTreeId, List<String> hierarchyPath, String comment,
      String role, String userName, String userPic, String designation, String profileStatus, List<String> taggedUsers, List<Map<String, String>> mentionedUsers) async {
    try {
      final response = await CommentService.addNewComment(commentTreeId, hierarchyPath, comment, role,
          userName, userPic, designation, profileStatus, taggedUsers, mentionedUsers);
      var responseData = CommentModel.fromJson(response);
      return responseData;
    } catch (_) {
      return null;
    }
  }

  Future<dynamic> likeComment(String commentId, String flag, String courseId) async {
    try {
      final response = await CommentService.likeComment(commentId, flag, courseId);

      String responseCode = response['responseCode'] ?? '';
      String errMsg = response['params']?['err'] ?? '';
      return CommentActionModel(
          responseCode: responseCode,
          errMsg: errMsg
      );
    } catch (_) {
      return CommentActionModel(
          responseCode: '',
          errMsg: ''
      );
    }
  }

  Future<dynamic> reportComment(String commentId, List<String> reportReasons, String otherComment) async {
    try {
      final response = await CommentService.reportComment(commentId, reportReasons, otherComment);
      String responseCode = response['responseCode'] ?? '';
      String errMsg = response['params']?['err'] ?? '';
      String status = response['result']?['status'] ?? '';
      return CommentActionModel(
          responseCode: responseCode,
          errMsg: errMsg,
          status: status
      );
    } catch (_) {
      return CommentActionModel(
          responseCode: '',
          errMsg: '',
          status: ''
      );
    }
  }

  Future<List<String>> getReportReasons() async {
    try {
      final response = await CommentService.getReportReasons();
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

  Future<dynamic> deleteComment(String commentId, String entityType, String entityId, String workflow, String? parentId) async {
    try {
      final response = await CommentService.deleteComment(commentId, entityType, entityId, workflow, parentId);
      String responseCode = (response['commentId'] != null) ? 'ok' : response['code'] ?? '';
      String status = (response['commentId'] != null) ? 'deleted' : '';
      String errMsg = response['message'] ?? '';
      return CommentActionModel(
          responseCode: responseCode,
          errMsg: errMsg,
          status: status
      );
    } catch (_) {
      return CommentActionModel(
          responseCode: '',
          errMsg: '',
          status: ''
      );
    }
  }

  Future<dynamic> editComment(String commentTreeId, String commentId, String comment, String role, String userName, String userPic, String designation, String profileStatus, List<String> taggedUsers, List<Map<String, String>> mentionedUsers) async {
    try {
      final response = await CommentService.editComment(commentTreeId, commentId, comment, role, userName, userPic, designation, profileStatus, taggedUsers, mentionedUsers);
      String? responseData = response['comment']['commentData']['comment'];
      if (responseData != null && responseData.isNotEmpty) {
        return response['comment'];
      } else {
        return null;
      }
    } catch (_) {
      return null;
    }
  }

  Future<List<String>> getLikedComments(String entityId) async {
    try {
      final response = await CommentService.getLikedComments(entityId);
      List<String> likedComments = [];
      if (response['result']['commentId'] is List) {
        likedComments = (response['result']['commentId'] as List)
            .map((item) => item.toString())
            .toList();
      }
      return likedComments;
    } catch (_) {
      return [];
    }
  }

}
