import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';
import 'package:karmayogi_mobile/igot_app.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/helper/discussion_const.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/repositories/discussion_repository.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_models/user_community_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/discussion/discussion_view/_models/discussion_item_request.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/discussion/discussion_view/_models/discussion_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/discussion/discussion_view/_models/discussion_request.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/discussion/discussion_view/_widgets/discussion_item_widget.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DiscussionDetailedView extends StatefulWidget {
  final String discussionId;
  final String communityId;
  const DiscussionDetailedView(
      {super.key, required this.discussionId, required this.communityId});

  @override
  State<DiscussionDetailedView> createState() => _DiscussionDetailedViewState();
}

class _DiscussionDetailedViewState extends State<DiscussionDetailedView> {
  final _storage = FlutterSecureStorage();
  late Future<DiscussionItemRequest?> _discussionItemFuture;
  @override
  void initState() {
    super.initState();
    _discussionItemFuture = _loadDiscussionItemRequest();
  }

  Future<DiscussionItemRequest?> _loadDiscussionItemRequest() async {
    try {
      final communities = await Provider.of<DiscussionRepository>(
              navigatorKey.currentContext!,
              listen: false)
          .getUserJoinedCommunities();

      final profile = await Provider.of<ProfileRepository>(
              navigatorKey.currentContext!,
              listen: false)
          .profileDetails;

      final userName = await _storage.read(key: Storage.firstName) ?? '';
      final userId = await _storage.read(key: Storage.userId) ?? '';
      final profileImageUrl =
          await _storage.read(key: Storage.profileImageUrl) ?? '';
      final profileStatus =
          await _storage.read(key: Storage.profileStatus) ?? '';

      if (userName.isEmpty) return null;

      final discussionRequest = DiscussionRequest(
        discussionType: DiscussionType.globalFeeds,
        communityId: widget.communityId,
        showAddDiscussion: communities.isNotEmpty,
        enableLike: true,
        enableBookmark: true,
        enableReport: true,
        enableReply: true,
        userName: userName,
        userId: userId,
        userProfileImage: profileImageUrl.isNotEmpty
            ? profileImageUrl
            : Helper.getInitialsNew(userName),
        userRole: profile?.roles?.first ?? '',
        designation: profile?.designation ?? '',
        profileStatus: profileStatus,
        enableAction: true,
        enableEdit: true,
        enableDelete: true,
      );

      DiscussionItemData? discussionData =
          await Provider.of<DiscussionRepository>(navigatorKey.currentContext!,
                  listen: false)
              .getDiscussionById(
                  communityId: widget.communityId,
                  discussionId: widget.discussionId);
      if (discussionData == null) return null;
      discussionData =
          await updateCommunityName(discussionItems: discussionData);

      return _createDiscussionItemRequest(discussionRequest, discussionData);
    } catch (_) {
      return null;
    }
  }

  DiscussionItemRequest _createDiscussionItemRequest(
    DiscussionRequest discussionRequest,
    DiscussionItemData discussionData,
  ) {
    return DiscussionItemRequest(
      discussionType: discussionRequest.discussionType,
      discussionItemData: discussionData,
      userName: discussionRequest.userName ?? '',
      userId: discussionRequest.userId ?? '',
      profileImageUrl: discussionRequest.userProfileImage ?? '',
      userRole: discussionRequest.userRole ?? '',
      designation: discussionRequest.designation ?? '',
      profileStatus: discussionRequest.profileStatus ?? '',
      answerPostCount: discussionData.answerPostCount ?? 0,
      enableLike: discussionRequest.enableLike,
      enableBookmark: discussionRequest.enableBookmark,
      enableReport: discussionRequest.enableReport,
      enableReply: discussionRequest.enableReply,
      enableEdit: discussionRequest.enableEdit,
      enableDelete: discussionRequest.enableDelete,
      updateChildCallback: (value) {},
      deleteCommentCallback: (id) {},
      enableAction: discussionRequest.enableAction,
      cardBackgroundColor: AppColors.appBarBackground,
      replyCardBackgroundColor: AppColors.answerPostBackgroundColor,
      parentId: discussionData.discussionId ?? '',
      postType: PostTypeConst.question,
    );
  }

  Future<DiscussionItemData> updateCommunityName({
    required DiscussionItemData discussionItems,
  }) async {
    List<UserCommunityIdData> userJoinedCommunityList =
        await Provider.of<DiscussionRepository>(navigatorKey.currentContext!,
                listen: false)
            .getUserJoinedCommunities();
    for (var community in userJoinedCommunityList) {
      if (community.communityId == discussionItems.communityId) {
        discussionItems.communityName = community.communityName;
        break;
      }
    }
    return discussionItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(AppLocalizations.of(context)!.mLearnCourseDiscussion),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0).r,
          child: FutureBuilder<DiscussionItemRequest?>(
            future: _discussionItemFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ContainerSkeleton(
                  height: 250.w,
                  width: 1.sw,
                );
              }

              if (snapshot.data != null) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 30).r,
                  child: DiscussionItemWidget(
                      discussionItemRequest: snapshot.data!),
                );
              }
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 150.0).r,
                  child: Text(
                    AppLocalizations.of(context)!.mMsgNoDataFound,
                    style: TextStyle(fontSize: 16.sp, color: AppColors.greys),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
