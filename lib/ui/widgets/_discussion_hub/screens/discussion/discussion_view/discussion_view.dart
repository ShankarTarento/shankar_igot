import 'dart:async';
import 'dart:math';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/my_learnings/no_data_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/helper/discussion_const.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/repositories/discussion_repository.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_models/user_community_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/discussion/add_discussion/add_discussion_page.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/discussion/discussion_view/_models/discussion_item_request.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/discussion/discussion_view/_models/discussion_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/discussion/discussion_view/_models/discussion_request.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/discussion/discussion_view/_widgets/add_discussion_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/discussion/discussion_view/_widgets/discussion_item_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/comment_section/pages/widgets/comment_profile_image_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/comment_section/pages/widgets/comment_view_skeleton.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DiscussionView extends StatefulWidget {
  final DiscussionRequest discussionRequest;
  final Function? onJoinCallback;
  final ValueNotifier<bool>? isLoading;
  final List<UserCommunityIdData>? userJoinedCommunities;

  DiscussionView(
      {Key? key,
      required this.discussionRequest,
      this.onJoinCallback,
      this.isLoading,
      this.userJoinedCommunities})
      : super(key: key);
  _DiscussionViewState createState() => _DiscussionViewState();
}

class _DiscussionViewState extends State<DiscussionView>
    with TickerProviderStateMixin {
  Future<DiscussionModel?>? _discussionFuture;
  DiscussionModel? discussionResponseData;

  bool _isLoading = false;
  bool _addingDiscussion = false;
  Color? errorImageColor =
      AppColors.networkBg[Random().nextInt(AppColors.networkBg.length)];
  int pageNo = 1;
  final _textController = TextEditingController();
  FocusNode _textFocusNode = FocusNode();
  String _previousSearchText = '';

  @override
  void initState() {
    super.initState();
    _textController.addListener(_searchDiscussion);
    _loadComments(true);
  }

  Future<void> _loadComments(bool overrideCache) async {
    _discussionFuture = _getDiscussion(context, '', overrideCache);
  }

  @override
  void didUpdateWidget(covariant DiscussionView oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  _searchDiscussion() {
    if (_textFocusNode.hasFocus &&
        _textController.text != _previousSearchText) {
      setState(() {
        _previousSearchText = _textController.text;
        if (_textController.text.length > SEARCH_START_LIMIT ||
            _textController.text.isEmpty) {
          pageNo = 1;
          _discussionFuture =
              _getDiscussion(context, _textController.text, false);
        }
      });
    }
  }

  Future<DiscussionModel?> _getDiscussion(
      context, String searchQuery, bool overrideCache) async {
    try {
      _isLoading = true;
      DiscussionModel? response;
      final discussionRepo =
          Provider.of<DiscussionRepository>(context, listen: false);
      final communityId = widget.discussionRequest.communityId;
      final discussionType = widget.discussionRequest.discussionType;

      final discussionMap = _buildDiscussionMap(
        repo: discussionRepo,
        communityId: communityId,
        pageNo: pageNo,
        searchQuery: searchQuery,
      );

      final fetcher = discussionMap[discussionType] ??
          () => discussionRepo.getDiscussion(pageNo, searchQuery, communityId);

      response = await fetcher();
      if (response != null) {
        if ((response.data ?? []).isNotEmpty) {
          DiscussionEnrichData? discussionEnrichData =
              await _getEnrichData(context, response.data ?? []);
          if (discussionEnrichData != null) {
            await updateDiscussionData(
                response.data ?? [], discussionEnrichData);
          }
          if (widget.discussionRequest.discussionType ==
              DiscussionType.globalFeeds) {
            if ((widget.userJoinedCommunities ?? []).isNotEmpty) {
              await updateCommunityName(
                  response.data ?? [], widget.userJoinedCommunities ?? []);
            }
          }
        }
        if (pageNo == 1) {
          discussionResponseData = response;
        } else {
          List<DiscussionItemData>? discussionList =
              discussionResponseData?.data ?? [];
          discussionList.addAll(response.data ?? []);
          DiscussionModel discussionModel = DiscussionModel(
            data: discussionList,
            facets: response.facets,
            totalCount: response.totalCount,
          );
          discussionResponseData = discussionModel;
        }
      }
      if (discussionResponseData != null) {
        _isLoading = false;
        _addingDiscussion = false;
        return Future.value(discussionResponseData);
      } else {
        _isLoading = false;
        _addingDiscussion = false;
        return null;
      }
    } catch (err) {
      _isLoading = false;
      _addingDiscussion = false;
      return null;
    }
  }

  Future<DiscussionEnrichData?> _getEnrichData(
      BuildContext context, List<DiscussionItemData>? data) async {
    try {
      List<Map<String, dynamic>> formattedFilterData =
          await (widget.discussionRequest.discussionType ==
                  DiscussionType.globalFeeds)
              ? getFormattedDataWithMultipleCommunityIds(data ?? [])
              : getFormattedDataWithSingleCommunityIds(
                  data ?? [], widget.discussionRequest.communityId);

      DiscussionEnrichData? response =
          await Provider.of<DiscussionRepository>(context, listen: false)
              .getEnrichData(PostTypeConst.question, formattedFilterData,
                  ["likes", "bookmarks", "reported"]);
      return response;
    } catch (err) {
      return null;
    }
  }

  List<Map<String, dynamic>> getFormattedDataWithSingleCommunityIds(
      List<DiscussionItemData> data, String communityId) {
    List<String> filteredData = data
        .map((discussionItem) => discussionItem.discussionId ?? "")
        .toList();
    return [
      {
        "communityId": communityId,
        "identifier": filteredData,
      }
    ];
  }

  List<Map<String, dynamic>> getFormattedDataWithMultipleCommunityIds(
      List<DiscussionItemData> data) {
    var groupedData = <String, List<String>>{};
    for (var discussionItem in data) {
      if (discussionItem.communityId != null &&
          discussionItem.discussionId != null) {
        groupedData
            .putIfAbsent(discussionItem.communityId!, () => [])
            .add(discussionItem.discussionId!);
      }
    }
    return groupedData.entries.map((entry) {
      return {
        "communityId": entry.key,
        "identifier": entry.value,
      };
    }).toList();
  }

  Future<void> updateDiscussionData(List<DiscussionItemData> discussionItems,
      DiscussionEnrichData discussionEnrichData) async {
    for (var discussionItem in discussionItems) {
      if (discussionEnrichData.likes != null) {
        discussionItem.isLiked =
            discussionEnrichData.likes?[discussionItem.discussionId ?? ''] ??
                false;
      }
      if (discussionEnrichData.bookmarks != null) {
        discussionItem.isBookmarked = discussionEnrichData
                .bookmarks?[discussionItem.discussionId ?? ''] ??
            false;
      }
      if (discussionEnrichData.reported != null) {
        discussionItem.isReported =
            discussionEnrichData.reported?[discussionItem.discussionId ?? ''] ??
                false;
      }
    }
  }

  Future<void> updateCommunityName(List<DiscussionItemData> discussionItems,
      List<UserCommunityIdData> userJoinedCommunityList) async {
    for (var discussionItem in discussionItems) {
      var userCommunity = userJoinedCommunityList.firstWhere(
        (userCommunity) =>
            userCommunity.communityId == discussionItem.communityId,
        orElse: () => UserCommunityIdData(communityId: "", communityName: ""),
      );
      if ((userCommunity.communityId ?? '').isNotEmpty) {
        discussionItem.communityName = userCommunity.communityName;
      }
    }
  }

  _loadMore() {
    if (discussionResponseData != null) {
      if ((discussionResponseData?.data ?? []).length <
          (discussionResponseData?.totalCount ?? 0)) {
        setState(() {
          pageNo = pageNo + 1;
          _loadComments(false);
        });
      }
    }
  }

  Future addCommentCallback() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: AppColors.grey04.withValues(alpha: 0.36),
      builder: (BuildContext context) {
        return AddDiscussionPage(
          userName: widget.discussionRequest.userName,
          userProfileImgUrl: widget.discussionRequest.userProfileImage,
          userProfileStatus: widget.discussionRequest.profileStatus,
          designation: widget.discussionRequest.designation,
          communityId: widget.discussionRequest.communityId,
          postCallback: (discussionData) {
            setState(() {
              pageNo = 1;
              discussionResponseData = null;
              _discussionFuture =
                  _getDiscussion(context, _textController.text, true);
            });
          },
        );
      },
    );
  }

  Future<void> deleteCommentCallback(String discussionId) async {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
    _textFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.axis == Axis.vertical) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            if (!_isLoading) {
              _loadMore();
            }
          }
        }
        return true;
      },
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: buildUI(),
      ),
    );
  }

  Widget buildUI() {
    return Container(
      margin: EdgeInsets.only(top: 16.0, bottom: 16).r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.discussionRequest.showSearch) _searchBarView(),
          if (widget.discussionRequest.showAddDiscussion ?? false)
            _postDiscussionView(),
          FutureBuilder(
            future: _discussionFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return (_isLoading)
                    ? CommentViewSkeleton(
                        itemCount: 10,
                      )
                    : Container();
              }
              return Wrap(
                alignment: WrapAlignment.start,
                children: [
                  if ((discussionResponseData?.data ?? []).isNotEmpty &&
                      !_addingDiscussion)
                    _discussionListView(),
                  // if ((discussionResponseData?.data??[]).isEmpty && !widget.discussionRequest.enableAction)
                  //   Stack(
                  //     children: [
                  //       _closedCommunityMaskView(),
                  //       _closedCommunityView(),
                  //     ],
                  //   ),
                  if (_isLoading)
                    CommentViewSkeleton(
                      itemCount: 10,
                    ),
                  if ((discussionResponseData?.data ?? []).isEmpty &&
                      !_addingDiscussion)
                    _noDataFound(),
                  Container(
                    height: 32.w,
                  )
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _searchBarView() {
    return Container(
      height: 40.w,
      margin: const EdgeInsets.only(top: 8, bottom: 16).w,
      child: TextFormField(
          controller: _textController,
          focusNode: _textFocusNode,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          style: GoogleFonts.lato(fontSize: 14.0.sp),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.appBarBackground,
            prefixIcon: Icon(
              Icons.search,
              size: 24.w,
              color: AppColors.disabledGrey,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 8).w,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100.w),
              borderSide: BorderSide(
                color: AppColors.appBarBackground,
                width: 1.0.w,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100.w),
              borderSide: BorderSide(color: AppColors.appBarBackground),
            ),
            hintText: AppLocalizations.of(context)!.mCommonSearch,
            hintStyle: GoogleFonts.lato(
                color: AppColors.greys60,
                fontSize: 14.0.sp,
                fontWeight: FontWeight.w400),
            counterStyle: TextStyle(
              height: double.minPositive,
            ),
            counterText: '',
          )),
    );
  }

  Widget _postDiscussionView() {
    return Padding(
      padding: EdgeInsets.only(bottom: 8).w,
      child: AddDiscussionWidget(
        startingIcon: CommentProfileImageWidget(
            profilePic: widget.discussionRequest.userProfileImage ?? '',
            name: widget.discussionRequest.userName ?? '',
            errorImageColor: errorImageColor ?? AppColors.primaryOne,
            iconSize: 40.w),
        hintText: (widget.discussionRequest.enableAction)
            ? "${AppLocalizations.of(context)!.mDiscussionCreatePost}..."
            : "${AppLocalizations.of(context)!.mDiscussionJoinCommunityToPost}...",
        callback: addCommentCallback,
        isReply: false,
        readOnly: !widget.discussionRequest.enableAction,
      ),
    );
  }

  Widget _discussionListView() {
    return AnimationLimiter(
      child: Column(
        children: List.generate(
          (discussionResponseData?.data ?? []).length,
          (index) {
            DiscussionItemRequest _discussionItemRequest =
                DiscussionItemRequest(
                    discussionType: widget.discussionRequest.discussionType,
                    discussionItemData:
                        (discussionResponseData?.data ?? [])[index],
                    userName: widget.discussionRequest.userName ?? '',
                    userId: widget.discussionRequest.userId ?? '',
                    profileImageUrl:
                        widget.discussionRequest.userProfileImage ?? '',
                    userRole: widget.discussionRequest.userRole ?? '',
                    designation: widget.discussionRequest.designation ?? '',
                    profileStatus: widget.discussionRequest.profileStatus ?? '',
                    answerPostCount: (discussionResponseData?.data ?? [])[index]
                            .answerPostCount ??
                        0,
                    enableLike: widget.discussionRequest.enableLike,
                    enableBookmark: widget.discussionRequest.enableBookmark,
                    enableReport: widget.discussionRequest.enableReport,
                    enableReply: widget.discussionRequest.enableReply,
                    enableEdit: widget.discussionRequest.enableEdit,
                    enableDelete: widget.discussionRequest.enableDelete,
                    updateChildCallback: (value) {},
                    deleteCommentCallback: deleteCommentCallback,
                    enableAction: widget.discussionRequest.enableAction,
                    cardBackgroundColor: AppColors.appBarBackground,
                    replyCardBackgroundColor:
                        AppColors.answerPostBackgroundColor,
                    parentId: (discussionResponseData?.data ?? [])[index]
                            .discussionId ??
                        '',
                    postType: PostTypeConst.question);

            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 475),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: DiscussionItemWidget(
                      discussionItemRequest: _discussionItemRequest),
                  // child: (widget.discussionRequest.enableAction)
                  //     ? DiscussionItemWidget(discussionItemRequest: _discussionItemRequest)
                  //     : _discussionItemView(_discussionItemRequest, index)
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _noDataFound() {
    return Container(
      child: NoDataWidget(
        message: (widget.discussionRequest.discussionType ==
                DiscussionType.globalFeeds)
            ? AppLocalizations.of(context)!.mDiscussionNoGlobalFeedFound
            : AppLocalizations.of(context)!.mDiscussionNoCommunityPostFound,
        maxLines: 10,
      ),
    );
  }

  Map<DiscussionType, Future<DiscussionModel?> Function()> _buildDiscussionMap({
    required DiscussionRepository repo,
    required String communityId,
    required int pageNo,
    required String searchQuery,
  }) {
    return {
      DiscussionType.feeds: () =>
          repo.getDiscussion(pageNo, searchQuery, communityId),
      DiscussionType.pinned: () =>
          repo.getDiscussion(pageNo, searchQuery, communityId),
      DiscussionType.links: () =>
          repo.getMediaDiscussion(pageNo, searchQuery, communityId, ['link']),
      DiscussionType.docs: () => repo
          .getMediaDiscussion(pageNo, searchQuery, communityId, ['document']),
      DiscussionType.yourPost: () =>
          repo.getMyDiscussion(pageNo, searchQuery, communityId),
      DiscussionType.bookmarked: () =>
          repo.getBookmarkedDiscussion(pageNo, searchQuery, communityId),
      DiscussionType.globalFeeds: () =>
          repo.getGlobalDiscussion(pageNo, searchQuery, ''),
    };
  }
}
