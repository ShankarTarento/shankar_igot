
import 'package:karmayogi_mobile/constants/_constants/api_endpoints.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/env/env.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/helper/discussion_const.dart';

class DiscussionHelper {
  static convertPortalImageUrl(String? url) {
    String? splitValue;
    if (url != null) {
      if (APP_ENVIRONMENT == Environment.dev) {
        splitValue = EnvironmentValues.igot.name;
      } else if (APP_ENVIRONMENT == Environment.qa) {
        splitValue = EnvironmentValues.igotqa.name;
      } else if (APP_ENVIRONMENT == Environment.uat) {
        splitValue = EnvironmentValues.igotuat.name;
      } else if (APP_ENVIRONMENT == Environment.prod) {
        splitValue = EnvironmentValues.igotprod.name;
      }
      List urlParts = (url.contains(splitValue!))
          ? url.split(splitValue)
          : url.split(EnvironmentValues.igot.name);
      return Env.host + "/${Azure.bucket}" + urlParts.last;
    }
  }

  static bool isPDF(String? url) {
    try {
      if (url == null || url.isEmpty) {
        return false;
      }
      Uri uri = Uri.parse(url);
      String? fileExtension = uri.pathSegments.isNotEmpty
          ? uri.pathSegments.last.split('.').last.toLowerCase()
          : '';
      return fileExtension == 'pdf';
    } catch (e) {
      return false;
    }
  }

  static String? extractCommunityIdFromString(String url) {
    try {
      if (url.isEmpty) return "";

      Uri uri = Uri.parse(url);
      int communityIndex = uri.pathSegments.indexOf('community');
      return (communityIndex != -1 && communityIndex + 1 < uri.pathSegments.length)
          ? uri.pathSegments[communityIndex + 1]
          : "";
    } catch (_) {
      return "";
    }
  }

  static int getHtmlTextLength(String description) {
    RegExp regExp = RegExp(r'<[^>]+>', multiLine: true, caseSensitive: false);
    String plainText = description.replaceAll(regExp, ''); // Remove all HTML tags
    return plainText.replaceAll(' ', '').length;
  }

  static getLikeEndPoint(String postType) {
    switch (postType) {
      case PostTypeConst.question:
        return ApiUrl.discussionPostLike;
      case PostTypeConst.answerPost:
        return ApiUrl.discussionReplyLike;
      case PostTypeConst.answerPostReply:
        return ApiUrl.discussionAnswerPostReplyLike;
      default:
        return ApiUrl.discussionPostLike;
    }
  }

  static getDislikeEndPoint(String postType) {
    switch (postType) {
      case PostTypeConst.question:
        return ApiUrl.discussionPostDislike;
      case PostTypeConst.answerPost:
        return ApiUrl.discussionReplyDislike;
      case PostTypeConst.answerPostReply:
        return ApiUrl.discussionAnswerPostReplyDislike;
      default:
        return ApiUrl.discussionPostDislike;
    }
  }

  static getDeleteEndPoint(String postType) {
    switch (postType) {
      case PostTypeConst.question:
        return ApiUrl.discussionPostDelete;
      case PostTypeConst.answerPost:
        return ApiUrl.discussionReplyDelete;
      case PostTypeConst.answerPostReply:
        return ApiUrl.discussionAnswerPostReplyDelete;
      default:
        return ApiUrl.discussionPostDelete;
    }
  }
}