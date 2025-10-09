import 'dart:async';
import 'dart:math';
import 'package:animations/animations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/ui/components/microsite_image_view.dart';
import 'package:karmayogi_mobile/constants/_constants/api_endpoints.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_api/user_action_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/helper/discussion_const.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/repositories/discussion_repository.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_models/community_detail_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_models/user_community_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/community_about_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/community_banner_image_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/community_detail_view_skeleton.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/community_guideline_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/community_members.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/community_tab.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/pills_button_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/discussion/discussion_view/discussion_view_wrapper.dart';
import 'package:karmayogi_mobile/ui/widgets/comment_section/model/comment_action_model.dart';
import 'package:karmayogi_mobile/ui/widgets/comment_section/pages/widgets/confirmation_dialog.dart';
import 'package:karmayogi_mobile/ui/widgets/comment_section/pages/widgets/report_comment_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/comment_section/repositories/comment_repository.dart';
import 'package:karmayogi_mobile/ui/widgets/hubs_custom_app_bar.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

class CommunityDetailView extends StatefulWidget {
  final String communityId;
  final bool? showCommunityGuidelines;
  CommunityDetailView({Key? key, required this.communityId, this.showCommunityGuidelines}) : super(key: key);
  CommunityDetailViewState createState() => CommunityDetailViewState();
}

class CommunityDetailViewState extends State<CommunityDetailView>
    with TickerProviderStateMixin {
  Future<CommunityDetailModel?>? _communityDetailFuture;
  CommunityDetailModel? communityResponseData;
  List<UserCommunityIdData> userJoinedCommunities = [];

  bool isReporting = false;
  bool _showCommunityGuidelines = false;
  ValueNotifier<bool> _isJoining = ValueNotifier(false);
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _showCommunityGuidelines = widget.showCommunityGuidelines ?? false;
    _loadCommunity();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller = TabController(
        length: CommunityTab.communityDetailItems(context: context).length,
        vsync: this,
        initialIndex: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadCommunity() async {
    _communityDetailFuture = _getCommunityDetails(context);
  }

  Future<CommunityDetailModel?> _getCommunityDetails(context) async {
    try {
      CommunityDetailModel? response =
          await Provider.of<DiscussionRepository>(context, listen: false)
              .getCommunityDetails(widget.communityId);
      if (response != null) {
        communityResponseData = await response;
        userJoinedCommunities = await _getUserJoinedCommunities();
        communityResponseData?.isUserJoinedCommunity =
            await _isUserJoinedCommunity(
                widget.communityId, userJoinedCommunities);
      } else {
        Helper.showSnackBarMessage(
            context: context,
            text: AppLocalizations.of(context)!.mStaticSomethingWrongTryLater,
            bgColor: AppColors.negativeLight);
        Future.delayed(Duration(seconds: 3), () {
          Navigator.of(context).pop();
          return null;
        });
      }
      if (communityResponseData != null) {
        if (_showCommunityGuidelines) {
          if (mounted) {
            await _acceptCommunityGuidelines(
                widget.communityId,
                communityResponseData?.communityGuideLines ?? AppLocalizations.of(context)!.mDiscussionDefaultCommunityGuidelines,
                displayOnly: true
            );
            _showCommunityGuidelines = false;
          }
        }
        return Future.value(communityResponseData);
      } else {
        return null;
      }
    } catch (err) {
      return null;
    }
  }

  Future<List<UserCommunityIdData>> _getUserJoinedCommunities() async {
    List<UserCommunityIdData> response = [];
    try {
      response = await Provider.of<DiscussionRepository>(context, listen: false)
          .getUserJoinedCommunities();
      return response;
    } catch (err) {
      return [];
    }
  }

  bool _isUserJoinedCommunity(
      String communityId, List<UserCommunityIdData> userJoinedCommunityList) {
    var community = userJoinedCommunityList.firstWhere(
      (item) => item.communityId.toString() == communityId,
      orElse: () => UserCommunityIdData(
          communityId: "", communityName: ''), // return a default instance
    );
    if ((community.communityId ?? '').isNotEmpty) {
      return true;
    }
    return false;
  }

  Future<void> _joinCommunity(bool isJoin, String communityId) async {
    _isJoining.value = true;
    UserActionModel? response;
    try {
      if (isJoin)
        response =
            await Provider.of<DiscussionRepository>(context, listen: false)
                .joinCommunity(communityId);
      else
        response =
            await Provider.of<DiscussionRepository>(context, listen: false)
                .leftCommunity(communityId);

      if ((response?.responseCode ?? '').toString().toLowerCase() == 'ok') {
        setState(() {
          _loadCommunity();
        });
        if (isJoin) {
          Helper.showSnackBarMessage(
              context: context,
              text: AppLocalizations.of(context)!
                  .mDiscussionCommunityJoinedSuccessfully,
              bgColor: AppColors.positiveLight);
        } else {
          Helper.showSnackBarMessage(
              context: context,
              text: AppLocalizations.of(context)!
                  .mDiscussionCommunityLeftSuccessfully,
              bgColor: AppColors.positiveLight);
        }
        setState(() {});
      } else {
        if ((response?.errMsg ?? '').isNotEmpty) {
          Helper.showSnackBarMessage(
              context: context,
              text: response?.errMsg ?? '',
              bgColor: AppColors.negativeLight);
        }
      }
      _isJoining.value = false;
    } catch (err) {
      _isJoining.value = false;
    }
  }

  Future<void> _acceptCommunityGuidelines(String communityId, String communityGuidelines, {bool displayOnly = false}) async {
    if (!_isJoining.value) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: AppColors.grey04.withValues(alpha: 0.36),
        builder: (BuildContext context) {
          return CommunityGuidelineWidget(
            guidelines: communityGuidelines,
            displayOnly: displayOnly,
            onSubmitCallback: () {
              _joinCommunity(true, communityId);
            },
          );
        },
      );
    }
  }

  Future<void> _shareCommunity() async {
    await SharePlus.instance.share(ShareParams(
        uri: Uri.parse(
            "${ApiUrl.baseUrl}/app/discussion-forum-v2/community/${widget.communityId}")));
  }

  Future<void> _reportCommunity(Map<String, dynamic> data) async {
    _report(context, widget.communityId, data['reportReasons'] ?? [],
        data['otherComment'] ?? '');
  }

  Future<void> _report(context, String commentId, List<String> reportReasons,
      String otherComment) async {
    isReporting = true;
    CommentActionModel? response;
    try {
      response = await Provider.of<DiscussionRepository>(context, listen: false)
          .reportCommunity(widget.communityId, reportReasons, otherComment);
      if ((response?.responseCode ?? '').toString().toLowerCase() == 'ok') {
        Helper.showSnackBarMessage(
            context: context,
            text: AppLocalizations.of(context)!.mStaticReportedMsg,
            bgColor: AppColors.positiveLight);
      } else {
        if ((response?.errMsg ?? '').isNotEmpty) {
          Helper.showSnackBarMessage(
              context: context,
              text: response?.errMsg ?? '',
              bgColor: AppColors.negativeLight);
        }
      }
      isReporting = false;
    } catch (err) {
      isReporting = false;
      throw err;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HubsCustomAppBar(),
      body: SafeArea(
        child: FutureBuilder(
          future: _communityDetailFuture,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              return buildUI();
            } else {
              return CommunityDetailViewSkeleton();
            }
          },
        ),
      ),
    );
  }

  Widget buildUI() {
    return PageTransitionSwitcher(
      transitionBuilder: (
        Widget child,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) {
        return FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
      duration: Duration(milliseconds: 500),
      child: DefaultTabController(
        length: CommunityTab.communityDetailItems(context: context).length,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              eventBannerWidget(),
              SliverAppBar(
                pinned: true,
                backgroundColor: AppColors.lightBackground,
                automaticallyImplyLeading: false,
                flexibleSpace: Container(
                  height: 40.w,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(width: 1.w, color: AppColors.grey08),
                    ),
                  ),
                  margin: EdgeInsets.only(left: 16, right: 16, top: 16).r,
                  child: TabBar(
                    isScrollable: true,
                    controller: _controller,
                    onTap: (index) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    indicator: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.darkBlue,
                          width: 2.0.w,
                        ),
                      ),
                    ),
                    indicatorColor: AppColors.appBarBackground,
                    labelPadding: EdgeInsets.only(right: 8.0).r,
                    unselectedLabelColor: AppColors.greys60,
                    labelColor: AppColors.greys,
                    labelStyle: GoogleFonts.lato(
                      fontSize: 14.0.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.greys87,
                    ),
                    indicatorSize: TabBarIndicatorSize.label,
                    unselectedLabelStyle: Theme.of(context)
                        .textTheme
                        .headlineSmall!
                        .copyWith(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.greys60),
                    tabs: [
                      tabItemView(
                          AppLocalizations.of(context)!.mDiscussionFeeds),
                      tabItemView(AppLocalizations.of(context)!.mStaticAbout),
                      // tabItemView(AppLocalizations.of(context)!.mDiscussionPinned),
                      // tabItemView(AppLocalizations.of(context)!.mDiscussionLinks),
                      tabItemView(
                          AppLocalizations.of(context)!.mDiscussionDocs),
                      tabItemView(
                          AppLocalizations.of(context)!.mDiscussionMembers),
                      tabItemView(
                          AppLocalizations.of(context)!.mDiscussionYourPost),
                      tabItemView(
                          AppLocalizations.of(context)!.mDiscussionBookmarked)
                    ],
                  ),
                ),
              ),
            ];
          },

          /// TabBar view
          body: Container(
            color: AppColors.lightBackground,
            child: FutureBuilder(
                future: Future.delayed(Duration(milliseconds: 500)),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  return TabBarView(
                    controller: _controller,
                    children: [
                      DiscussionViewWrapper(
                        discussionType: DiscussionType.feeds,
                        communityId: widget.communityId,
                        topicId: communityResponseData?.topicId ?? 0,
                        isUserJoinedCommunity:
                            (communityResponseData?.isUserJoinedCommunity ??
                                false),
                        onJoinCallback: () {
                          if (communityResponseData?.isUserJoinedCommunity ??
                              false) {
                            _leaveCommunityAlert();
                          } else {
                            _acceptCommunityGuidelines(
                                widget.communityId,
                                communityResponseData?.communityGuideLines ??
                                    AppLocalizations.of(context)!
                                        .mDiscussionDefaultCommunityGuidelines);
                          }
                        },
                        isLoading: _isJoining,
                        showAddDiscussion: true,
                      ),
                      CommunityAboutWidget(
                        communityId: widget.communityId,
                        communityResponseData: communityResponseData,
                      ),
                      DiscussionViewWrapper(
                        discussionType: DiscussionType.docs,
                        communityId: widget.communityId,
                        topicId: communityResponseData?.topicId ?? 0,
                        isUserJoinedCommunity:
                            (communityResponseData?.isUserJoinedCommunity ??
                                false),
                        onJoinCallback: () {
                          if (communityResponseData?.isUserJoinedCommunity ??
                              false) {
                            _leaveCommunityAlert();
                          } else {
                            _acceptCommunityGuidelines(
                                widget.communityId,
                                communityResponseData?.communityGuideLines ??
                                    AppLocalizations.of(context)!
                                        .mDiscussionDefaultCommunityGuidelines);
                          }
                        },
                        isLoading: _isJoining,
                        showAddDiscussion: false,
                      ),
                      CommunityMembers(
                        communityId: widget.communityId,
                      ),
                      DiscussionViewWrapper(
                        discussionType: DiscussionType.yourPost,
                        communityId: widget.communityId,
                        topicId: communityResponseData?.topicId ?? 0,
                        isUserJoinedCommunity:
                            (communityResponseData?.isUserJoinedCommunity ??
                                false),
                        onJoinCallback: () {
                          if (communityResponseData?.isUserJoinedCommunity ??
                              false) {
                            _leaveCommunityAlert();
                          } else {
                            _acceptCommunityGuidelines(
                                widget.communityId,
                                communityResponseData?.communityGuideLines ??
                                    AppLocalizations.of(context)!
                                        .mDiscussionDefaultCommunityGuidelines);
                          }
                        },
                        isLoading: _isJoining,
                        showAddDiscussion: false,
                      ),
                      DiscussionViewWrapper(
                        discussionType: DiscussionType.bookmarked,
                        communityId: widget.communityId,
                        topicId: communityResponseData?.topicId ?? 0,
                        isUserJoinedCommunity:
                            (communityResponseData?.isUserJoinedCommunity ??
                                false),
                        onJoinCallback: () {
                          if (communityResponseData?.isUserJoinedCommunity ??
                              false) {
                            _leaveCommunityAlert();
                          } else {
                            _acceptCommunityGuidelines(
                                widget.communityId,
                                communityResponseData?.communityGuideLines ??
                                    AppLocalizations.of(context)!
                                        .mDiscussionDefaultCommunityGuidelines);
                          }
                        },
                        isLoading: _isJoining,
                        showAddDiscussion: false,
                      ),
                    ],
                  );
                }),
          ),
        ),
      ),
    );
  }

  Widget tabItemView(String title) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16).r,
      child: Tab(
        child: Padding(
          padding: EdgeInsets.all(5.0).r,
          child: Text(
            title,
          ),
        ),
      ),
    );
  }

  Widget eventBannerWidget() {
    return SliverToBoxAdapter(
      child: Container(
        color: AppColors.lightBackground,
        padding: const EdgeInsets.only(left: 16, top: 16, right: 16).w,
        child: Wrap(
          children: [
            /// Background Banner Image
            Center(
              child: CommunityBannerImageWidget(
                imgUrl: communityResponseData?.posterImageUrl,
                height: 90.w,
                width: double.maxFinite,
                fit: BoxFit.fill,
              ),
            ),

            /// Content Section
            Container(
              margin: EdgeInsets.only(top: 16).r,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 0.8.sw,
                        child: Text(
                          communityResponseData?.communityName ?? '',
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: AppColors.greys,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20.sp,
                                  ),
                        ),
                      ),
                      Spacer(),
                      _optionItems()
                    ],
                  ),
                  SizedBox(height: 16.w),

                  /// Join community button
                  if (!(communityResponseData?.isUserJoinedCommunity ?? false))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16).r,
                      child: PillsButtonWidget(
                        title:
                            (communityResponseData?.isUserJoinedCommunity ??
                                    false)
                                ? AppLocalizations.of(context)!
                                    .mDiscussionCommunityJoined
                                : AppLocalizations.of(context)!
                                    .mDiscussionCommunityJoin,
                        onTap: () {
                          if (communityResponseData?.isUserJoinedCommunity ??
                              false) {
                            _leaveCommunityAlert();
                          } else {
                            _acceptCommunityGuidelines(
                                widget.communityId,
                                communityResponseData?.communityGuideLines ??
                                    AppLocalizations.of(context)!
                                        .mDiscussionDefaultCommunityGuidelines);
                          }
                        },
                        decoration: BoxDecoration(
                            border: Border.all(color: AppColors.darkBlue),
                            borderRadius:
                                BorderRadius.all(const Radius.circular(50.0).r),
                            color:
                                (communityResponseData?.isUserJoinedCommunity ??
                                        false)
                                    ? null
                                    : AppColors.darkBlue),
                        textColor:
                            (communityResponseData?.isUserJoinedCommunity ??
                                    false)
                                ? AppColors.darkBlue
                                : AppColors.appBarBackground,
                        textFontSize: 14.sp,
                        isLoading: _isJoining,
                        isLightTheme:
                            (communityResponseData?.isUserJoinedCommunity ??
                                    false)
                                ? true
                                : false,
                      ),
                    ),
                  // _updatesOnPostView(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _optionItems() {
    return Container(
      margin: EdgeInsets.only(left: 4).w,
      alignment: Alignment.topRight,
      child: PopupMenuTheme(
        data: PopupMenuThemeData(
          color: AppColors.appBarBackground,
          textStyle: TextStyle(
            color: AppColors.greys,
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: PopupMenuButton<int>(
          child: SizedBox(
            width: 24.w,
            height: 24.w,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Container(
                child: Icon(
                  Icons.more_vert,
                  size: 24.w,
                  color: AppColors.greys60,
                ),
              ),
            ),
          ),
          itemBuilder: (context) => [
            // _popUpMenuItem(value: 1, text: AppLocalizations.of(context)!.mStaticFlag, icon: Icons.flag_outlined, iconColor: AppColors.negativeLight),
            if (communityResponseData?.isUserJoinedCommunity ?? false)
              _popUpMenuItem(
                  value: 2,
                  text: AppLocalizations.of(context)!.mDiscussionCommunityLeave,
                  icon: Icons.logout_outlined,
                  iconColor: AppColors.negativeLight),
            _popUpMenuItem(
                value: 3,
                text: AppLocalizations.of(context)!.mStaticShare,
                icon: Icons.share,
                iconColor: AppColors.darkBlue),
          ],
          onSelected: (value) {
            if (value == 1) {
              _flagCommunity();
            } else if (value == 2) {
              _leaveCommunityAlert();
            } else if (value == 3) {
              _shareCommunity();
            }
          },
        ),
      ),
    );
  }

  PopupMenuEntry<int> _popUpMenuItem(
      {required int value,
      required String text,
      required IconData icon,
      required Color iconColor}) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 24.w,
          ),
          Padding(
            padding: EdgeInsets.only(left: 8, right: 8).r,
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: AppColors.greys,
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,
                  ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _flagCommunity() async {
    if (!isReporting) {
      isReporting = true;
      List<String> response = [];
      try {
        response = await Provider.of<CommentRepository>(context, listen: false)
            .getReportReasons();
        if (response.isNotEmpty) {
          await showModalBottomSheet(
              isScrollControlled: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8).r,
                        topRight: Radius.circular(8))
                    .r,
                side: BorderSide(
                  color: AppColors.grey08,
                ),
              ),
              context: context,
              builder: (ctx) => ReportCommentWidget(
                    commentId: widget.communityId,
                    reportReason: response,
                    onSubmitCallback: _reportCommunity,
                  ));
        } else {
          Helper.showSnackBarMessage(
              context: context,
              text: AppLocalizations.of(context)!.mStaticSomethingWrongTryLater,
              bgColor: AppColors.negativeLight);
        }
        isReporting = false;
      } catch (err) {
        isReporting = false;
        throw err;
      }
    }
  }

/*
  Widget _updatesOnPostView() {
    return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.appBarBackground,
          borderRadius: BorderRadius.all(Radius.circular(12).r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.mDiscussionUpdatesOnYourPosts,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 16.w,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.arrow_upward,
                  size: 16.w,
                  color: AppColors.darkBlue,
                ),
                SizedBox(width: 8.w,),
                Text(
                  "${0} ${AppLocalizations.of(context)!.mDiscussionUpdatesOnYourPosts}",
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                    color: AppColors.darkBlue
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.w,),
            Text(
              "",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w400,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 16.w,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.mode_comment_rounded,
                  size: 16.w,
                  color: AppColors.darkBlue,
                ),
                SizedBox(width: 8.w,),
                Text(
                  "${0} ${AppLocalizations.of(context)!.mDiscussionCommentOnYourPost}",
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      color: AppColors.darkBlue
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.w,),
            Text(
              "",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w400,
                fontSize: 14.sp,
              ),
            ),
          ],
        )
    );
  }
*/
  Widget profileImage() {
    return ((communityResponseData?.imageUrl != null) &&
            communityResponseData?.imageUrl != '')
        ? ClipRRect(
            borderRadius: BorderRadius.all(
              Radius.circular(100.w),
            ),
            child: Container(
                height: 80.w,
                width: 80.w,
                decoration: BoxDecoration(
                  color: AppColors.appBarBackground,
                  shape: BoxShape.circle,
                ),
                child: MicroSiteImageView(
                    imgUrl: communityResponseData?.imageUrl ?? '',
                    height: 80.w,
                    width: 80.w,
                    radius: 80.w,
                    fit: BoxFit.contain)),
          )
        : ClipRRect(
            borderRadius: BorderRadius.all(
              Radius.circular(100.w),
            ),
            child: Container(
              child: Container(
                height: 80.w,
                width: 80.w,
                decoration: BoxDecoration(
                  color: AppColors
                      .networkBg[Random().nextInt(AppColors.networkBg.length)],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    Helper.getInitialsNew(
                        communityResponseData?.communityName ?? ''),
                    style: GoogleFonts.lato(
                        color: AppColors.avatarText,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.0.sp),
                  ),
                ),
              ),
            ),
          );
  }

  Future<void> _leaveCommunityAlert() async {
    if (!_isJoining.value) {
      FocusScope.of(context).unfocus();
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext cxt) {
            return ConfirmationDialogWidget(
              title: AppLocalizations.of(context)!.mDiscussionCommunityLeave,
              subtitle:
                  AppLocalizations.of(context)!.mDiscussionLeaveCommunityAlert,
              primaryButtonText:
                  AppLocalizations.of(context)!.mDiscussionCommunityLeave,
              onPrimaryButtonPressed: () {
                _joinCommunity(false, widget.communityId);
                Navigator.of(cxt).pop();
              },
              secondaryButtonText: AppLocalizations.of(context)!.mStaticCancel,
              onSecondaryButtonPressed: () => Navigator.of(cxt).pop(),
            );
          });
    }
  }
}
