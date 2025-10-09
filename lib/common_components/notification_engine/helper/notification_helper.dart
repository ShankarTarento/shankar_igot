import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/common_components/image_widget/image_widget.dart';
import 'package:karmayogi_mobile/common_components/notification_engine/constants/notification_constants.dart';
import 'package:karmayogi_mobile/common_components/notification_engine/models/notification_model.dart';
import 'package:karmayogi_mobile/common_components/notification_engine/models/notification_stats.dart';
import 'package:karmayogi_mobile/constants/_constants/api_endpoints.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/app_routes.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_arguments/course_toc_model.dart';
import 'package:karmayogi_mobile/services/_services/profile_service.dart';
import 'package:karmayogi_mobile/ui/learn_hub/learn_hub.dart';
import 'package:karmayogi_mobile/ui/network_hub/constants/network_constants.dart';
import 'package:karmayogi_mobile/ui/network_hub/network_hub.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/events_details/events_details_screenv2.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/events_hub.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/pages/profile_dashboard.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_screens/community_detail_view.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/pages/public_profile_dashboard/repository/public_profile_dashboard_repository.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/utils/profile_constants.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_screens/community_home.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/discussion/discussion_detailed_view/discussion_detailed_view.dart';
import 'package:karmayogi_mobile/util/app_navigator_observer.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:karmayogi_mobile/util/helper.dart';

class NotificationHelper {
  static String getNotificationTime(DateTime createdAt) {
    Duration difference = DateTime.now().difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} m';
    } else if (difference.inSeconds > 0) {
      return '${difference.inSeconds} s';
    } else {
      return '';
    }
  }

  static Widget getNotificationIcon(String type) {
    String imageUrl;
    Color iconColor;

    switch (type) {
      case NotificationConstants.discussion:
        imageUrl = ApiUrl.baseUrl + "/assets/icons/hubs/forum.svg";
        iconColor = AppColors.dicussionNotificationIconColor;
        break;
      case NotificationConstants.event:
        imageUrl = ApiUrl.baseUrl + "/assets/icons/hubs/event.svg";
        iconColor = AppColors.eventNotificationIconColor;
        break;
      case NotificationConstants.network:
        imageUrl = ApiUrl.baseUrl + "/assets/icons/hubs/group.svg";
        iconColor = AppColors.networkNotificationIconColor;
        break;
      case NotificationConstants.learn || NotificationConstants.content:
        imageUrl = ApiUrl.baseUrl + "/assets/icons/hubs/school.svg";
        iconColor = AppColors.learnNotificationIconColor;
        break;
      case NotificationConstants.profile:
        return Icon(Icons.person, color: AppColors.darkBlue, size: 26.w);

      default:
        return Icon(Icons.notifications, color: AppColors.yellow3, size: 26.w);
    }

    return ImageWidget(
      width: 24.w,
      height: 24.w,
      imageUrl: imageUrl,
      imageColor: iconColor,
      boxFit: BoxFit.contain,
    );
  }

  static int getAllNotificationCount(
      {required List<NotificationSubtypeStats> notificationStats}) {
    int totalCount = 0;
    notificationStats.forEach((element) {
      totalCount += element.unread;
    });
    return totalCount;
  }

  static int getNotificationCountByCategory(
      {required List<NotificationSubtypeStats> notificationStats,
      required String type}) {
    int notificationCount = 0;
    notificationStats.forEach((element) {
      if (element.name == type) {
        notificationCount += element.unread;
      }
    });
    return notificationCount;
  }

  static void handleNotificationNavigation(
      {required NotificationModel notification,
      required BuildContext context}) async {
    switch (notification.category) {
      case NotificationConstants.discussion:
        handleDiscussionNavigation(notification: notification, context: context);
        break;
      case NotificationConstants.event:
        if (notification.message.data.contentId != null) {
          Navigator.push(
              context,
              FadeRoute(
                  page: EventsDetailsScreenv2(
                eventId: notification.message.data.contentId!,
              )));
        } else {
          Navigator.push(context, FadeRoute(page: EventsHub()));
        }
        break;
      case NotificationConstants.network:
        if (notification.message.data.contentId != null) {
          UserConnectionStatus status = await getUserRelationshipStatus(
              notification.message.data.contentId!);

          if (notification.subCategory ==
              NotificationSubType.sendConnectionRequest) {
            if (status == UserConnectionStatus.Received) {
              Navigator.push(
                  context,
                  FadeRoute(
                      page: NetworkHubV2(
                    initialIndex: 1,
                    currentSubTabIndex: 1,
                  )));
            } else {
              Helper.showSnackBarMessage(
                  context: context,
                  text: AppLocalizations.of(context)!.mBrokenDeepLinkError,
                  bgColor: AppColors.darkBlue);
            }
          } else if (notification.subCategory ==
              NotificationSubType.acceptedConnectionRequest) {
            if (status == UserConnectionStatus.Approved) {
              Navigator.push(
                  context,
                  FadeRoute(
                      page: NetworkHubV2(
                    initialIndex: 1,
                  )));
            } else {
              Helper.showSnackBarMessage(
                  context: context,
                  text: AppLocalizations.of(context)!.mBrokenDeepLinkError,
                  bgColor: AppColors.darkBlue);
            }
          }
        } else {
          Navigator.push(
              context,
              FadeRoute(
                  page: NetworkHubV2(
                initialIndex: 1,
              )));
        }
        break;
      case NotificationConstants.learn:
        if (notification.message.data.contentId != null) {
          handleCourseTocNavigation(
              notification: notification,
              context: context
          );
        } else {
          Navigator.push(context, FadeRoute(page: LearnHub()));
        }
        break;
      case NotificationConstants.content:
        Helper.showSnackBarMessage(
            context: context,
            text: AppLocalizations.of(context)!
                .mLoginToContentPortalToViewNotification,
            bgColor: AppColors.darkBlue);

        break;
      case NotificationConstants.profile:
        if (notification.subCategory == NotificationSubType.profileUpdate) {
          Navigator.push(
              context,
              FadeRoute(
                  page: ProfileDashboard(type: ProfileConstants.currentUser)));
        } else {
          Helper.showSnackBarMessage(
              context: context,
              text: AppLocalizations.of(context)!
                  .mLoginToMDOPortalToViewTheNotification,
              bgColor: AppColors.darkBlue);
        }
        break;
      default:
        // Handle unknown notification type
        debugPrint("Unknown Notification Type");
        Helper.showSnackBarMessage(
            context: context,
            text: AppLocalizations.of(context)!.mNotificationOnHandleError,
            bgColor: AppColors.darkBlue);
    }
  }

  static Future<UserConnectionStatus> getUserRelationshipStatus(
      String userId) async {
    try {
      final response = await ProfileService().getConnectionRelationship(userId);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        final status = data['result']?['response']?['status'];

        if (status != null) {
          return PublicProfileDashboardRepository
              .mapStatusToUserConnectionStatus(status);
        }
      } else {
        debugPrint(
            "Failed to get user relationship status. Code: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error getting relationship status: $e");
    }

    return UserConnectionStatus.Connect;
  }

  static void handleDiscussionNavigation({required NotificationModel notification, required BuildContext context}) async {
    if (notification.message.data.communityId != null) {
      if (notification.subCategory == NotificationConstants.profanePost) {
        Navigator.push(
          context,
          FadeRoute(
            page: CommunityDetailView(
              communityId: notification.message.data.communityId!,
              showCommunityGuidelines: true,
            ),
          ),
        );
      } else {
        Navigator.push(
          context,
          FadeRoute(
            page: notification.message.data.discussionId != null
                ? DiscussionDetailedView(
              communityId: notification.message.data.communityId!,
              discussionId: notification.message.data.discussionId!,
            ) : CommunityHome(),
          ),
        );
      }
    }
    if (notification.message.data.contentId != null) {
      if (notification.subCategory == NotificationSubType.commentUserMentioned || notification.subCategory == NotificationSubType.commentReplyUserMentioned) {
        handleCourseTocNavigation(
            notification: notification,
            context: context,
            initialTabIndex: (notification.message.data.commentId != null) ? 2 : null
        );
      }
    }
  }

  static void handleCourseTocNavigation({required NotificationModel notification, required BuildContext context, int? initialTabIndex}) {
    List<Route<dynamic>> routeList = AppNavigatorObserver.instance.getRouteList() ?? [];
    bool isCourseTocPageInStack = routeList.any((route) => route.settings.name == AppUrl.courseTocPage);
    if (isCourseTocPageInStack) {
      Navigator.popUntil(context, (Route<dynamic> route) {
        return route.settings.name == AppUrl.courseTocPage;
      });
      Navigator.of(context).pop();
    }
    if (notification.message.data.contentId!.startsWith('ext')) {
      Navigator.pushNamed(
        context,
        AppUrl.externalCourseTocPage,
        arguments: CourseTocModel(
            courseId: notification.message.data.contentId ?? '',
            contentType: PrimaryCategory.externalCourse,
            tagCommentId: notification.message.data.commentId
        ),
      );
    } else {
      Navigator.pushNamed(context, AppUrl.courseTocPage,
          arguments: CourseTocModel(
            courseId: notification.message.data.contentId ?? '',
            initialTabIndex: initialTabIndex,
            tagCommentId: notification.message.data.commentId,
          )
      );
    }
  }
}
