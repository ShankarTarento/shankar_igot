import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html_editor_enhanced/utils/shims/dart_ui_real.dart';
import 'package:igot_ui_components/ui/components/view_more_text.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/app_routes.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/helper/discussion_const.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/helper/discussion_helper.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/repositories/discussion_repository.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/pills_button_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/discussion/add_discussion/add_discussion_page.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/discussion/add_discussion/add_reply_page.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/discussion/discussion_view/_models/discussion_item_request.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/discussion/discussion_view/_models/discussion_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/discussion/discussion_view/_widgets/media_view_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/comment_section/model/comment_action_model.dart';
import 'package:karmayogi_mobile/ui/widgets/comment_section/pages/widgets/comment_profile_image_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/comment_section/pages/widgets/comment_view_skeleton.dart';
import 'package:karmayogi_mobile/ui/widgets/comment_section/pages/widgets/confirmation_dialog.dart';
import 'package:karmayogi_mobile/ui/widgets/comment_section/pages/widgets/report_comment_widget.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:provider/provider.dart';
import 'package:simple_moment/simple_moment.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DiscussionItemWidget extends StatefulWidget {
  final DiscussionItemRequest discussionItemRequest;
  const DiscussionItemWidget({
    Key? key,
    required this.discussionItemRequest,
  }) : super(key: key);

  @override
  _DiscussionItemWidgetState createState() {
    return new _DiscussionItemWidgetState();
  }
}

class _DiscussionItemWidgetState extends State<DiscussionItemWidget>
    with TickerProviderStateMixin {
  DiscussionItemData? _discussionData;
  final dateNow = Moment.now();
  Color? errorImageColor =
      AppColors.networkBg[Random().nextInt(AppColors.networkBg.length)];
  ValueNotifier<bool> _showReplySection = ValueNotifier(false);
  ValueNotifier<bool> _showTagSection = ValueNotifier(false);
  ValueNotifier<bool> _showInEditMode = ValueNotifier(false);
  ValueNotifier<String> _formattedDetails = ValueNotifier("");

  late AnimationController _upVoteAnimationController;
  late AnimationController _bookmarkAnimationController;
  late AnimationController _reportAnimationController;
  late AnimationController _commentAnimationController;
  bool isVoting = false;
  bool isBookmarking = false;
  bool isReporting = false;
  bool isUpdating = false;

  Future<DiscussionModel?>? _commentsFuture;
  bool _isLoading = false;
  bool _loadReply = false;
  int _answerPostCount = 0;

  DiscussionModel? _discussionReplyData;
  int pageNo = 1;
  bool _hasMoreComments = false;

  @override
  void initState() {
    super.initState();
    _discussionData = widget.discussionItemRequest.discussionItemData;
    _answerPostCount = widget.discussionItemRequest.answerPostCount;
    _loadReply = _answerPostCount != 0;
    _loadData();
  }

  void _loadData() async {
    _upVoteAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
      value: 1.0,
      lowerBound: 1.0,
      upperBound: 1.2,
    );
    _bookmarkAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
      value: 1.0,
      lowerBound: 1.0,
      upperBound: 1.2,
    );
    _reportAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
      value: 1.0,
      lowerBound: 1.0,
      upperBound: 1.2,
    );
    _commentAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
      value: 1.0,
      lowerBound: 1.0,
      upperBound: 1.2,
    );
    await formatDetails((_discussionData?.description??'').trim());
  }

  Future<void> _loadComments({required bool isAnswerPostReply}) async {
    _commentsFuture = _getReply(context, isAnswerPostReply);
  }

  Future<DiscussionModel?> _getReply(context, bool isAnswerPostReply) async {
    try {
      _isLoading = true;
      DiscussionModel? response;
      if (isAnswerPostReply) {
        response = await Provider.of<DiscussionRepository>(context,
                listen: false)
            .getReply(
                widget.discussionItemRequest.discussionItemData.communityId ??
                    "",
                widget.discussionItemRequest.discussionItemData.discussionId ??
                    '',
                pageNo,
                true);
      } else {
        response = await Provider.of<DiscussionRepository>(context,
                listen: false)
            .getReply(
                widget.discussionItemRequest.discussionItemData.communityId ??
                    "",
                widget.discussionItemRequest.parentId,
                pageNo,
                false);
      }
      if (response != null) {
        if ((response.data ?? []).isNotEmpty) {
          DiscussionEnrichData? discussionEnrichData =
              await _getEnrichData(context, response.data ?? []);
          if (discussionEnrichData != null) {
            await updateDiscussionData(
                response.data ?? [], discussionEnrichData);
          }
        }

        if (pageNo == 1) {
          _discussionReplyData = response;
        } else {
          List<DiscussionItemData>? discussionList =
              _discussionReplyData?.data ?? [];
          discussionList.addAll(response.data ?? []);
          DiscussionModel discussionModel = DiscussionModel(
            data: discussionList,
            facets: response.facets,
            totalCount: response.totalCount,
          );
          setState(() {
            _discussionReplyData = discussionModel;
          });
        }
      }
      _hasMoreComments = (_discussionReplyData?.data ?? []).length <
          (_discussionReplyData?.totalCount ?? 0);
      if (_discussionReplyData != null) {
        _isLoading = false;
        return Future.value(_discussionReplyData);
      } else {
        _isLoading = false;
        return null;
      }
    } catch (err) {
      _isLoading = false;
      return null;
    }
  }

  Future<DiscussionEnrichData?> _getEnrichData(
      BuildContext context, List<DiscussionItemData>? data) async {
    try {
      DiscussionEnrichData? response =
          await Provider.of<DiscussionRepository>(context, listen: false)
              .getEnrichData(
                  PostTypeConst.answerPost,
                  getFormattedDataWithSingleCommunityIds(
                      data ?? [],
                      widget.discussionItemRequest.discussionItemData
                              .communityId ??
                          ""),
                  ["likes", "reported"]);
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

  String _getDateNow(String date) {
    DateTime parsedDate = DateTime.parse(date);

    DateTime dateNow = DateTime.now();

    if (parsedDate.isAfter(dateNow)) {
      return "Just now";
    }

    int years = dateNow.year - parsedDate.year;
    int months = dateNow.month - parsedDate.month;
    int days = dateNow.day - parsedDate.day;

    if (months < 0) {
      years -= 1;
      months += 12;
    }
    if (days < 0) {
      months -= 1;
      days += DateTime(dateNow.year, dateNow.month, 0).day;
    }
    Duration difference = dateNow.difference(parsedDate);
    int totalDays = difference.inDays;

    if (totalDays < 1) {
      int seconds = difference.inSeconds;
      if (seconds < 60) {
        return '${seconds}s'; // seconds
      } else if (seconds < 3600) {
        int minutes = difference.inMinutes;
        return '${minutes}m'; // minutes
      } else {
        int hours = difference.inHours;
        return '${hours}h'; // hours
      }
    } else if (totalDays < 30) {
      return '${totalDays}d'; // days
    } else if (totalDays >= 30 && totalDays < 365) {
      return '${months}mth'; // months
    } else {
      return '${years}yr'; // years
    }
  }

  Future<void> _likeComment(context, discussionId, bool isLike) async {
    isVoting = true;
    CommentActionModel? response;
    try {
      if (isLike) {
        response =
            await Provider.of<DiscussionRepository>(context, listen: false)
                .likeComment(
                    discussionId,
                    DiscussionHelper.getLikeEndPoint(
                        widget.discussionItemRequest.postType));
      } else {
        response =
            await Provider.of<DiscussionRepository>(context, listen: false)
                .dislikeComment(
                    discussionId,
                    DiscussionHelper.getDislikeEndPoint(
                        widget.discussionItemRequest.postType));
      }
      if ((response?.responseCode ?? '').toString().toLowerCase() == 'ok') {
        widget.discussionItemRequest.discussionItemData.isLiked = isLike;
        _discussionData?.upVoteCount =
            (_discussionData?.upVoteCount ?? (isLike ? 0 : 1)) +
                (isLike ? 1 : -1);
        setState(() {});
      } else {
        if ((response?.errMsg ?? '').isNotEmpty) {
          Helper.showSnackBarMessage(
              context: context,
              text: response?.errMsg ?? '',
              bgColor: AppColors.negativeLight);
        }
      }
      isVoting = false;
    } catch (err) {
      isVoting = false;
      throw err;
    }
    _upVoteAnimationController
        .forward()
        .then((value) => _upVoteAnimationController.reverse());
  }

  Future<void> _bookmarkComment(
      context, discussionId, bool isBookmarked) async {
    isBookmarking = true;
    CommentActionModel? response;
    try {
      if (isBookmarked) {
        response = await Provider.of<DiscussionRepository>(context,
                listen: false)
            .unBookmarkComment(
                discussionId,
                widget.discussionItemRequest.discussionItemData.communityId ??
                    "");
      } else {
        response = await Provider.of<DiscussionRepository>(context,
                listen: false)
            .bookmarkComment(
                discussionId,
                widget.discussionItemRequest.discussionItemData.communityId ??
                    "");
      }

      if ((response?.responseCode ?? '').toString().toLowerCase() == 'ok') {
        widget.discussionItemRequest.discussionItemData.isBookmarked =
            !isBookmarked;
        Helper.showSnackBarMessage(
            context: context,
            text: isBookmarked
                ? AppLocalizations.of(context)!.mDiscussionPostUnBookmarked
                : AppLocalizations.of(context)!.mDiscussionPostBookmarked,
            bgColor: AppColors.positiveLight);
        setState(() {});
      } else {
        if ((response?.errMsg ?? '').isNotEmpty) {
          Helper.showSnackBarMessage(
              context: context,
              text: response?.errMsg ?? '',
              bgColor: AppColors.negativeLight);
        }
      }
      isBookmarking = false;
    } catch (err) {
      isBookmarking = false;
      throw err;
    }
    _bookmarkAnimationController
        .forward()
        .then((value) => _bookmarkAnimationController.reverse());
  }

  Future<void> _reportComment(Map<String, dynamic> data) async {
    _report(
        context,
        widget.discussionItemRequest.discussionItemData.discussionId ?? '',
        widget.discussionItemRequest.discussionItemData.description ?? '',
        data['reportReasons'] ?? [],
        data['otherComment'] ?? '');
  }

  Future<void> _report(context, String discussionId, String discussionText,
      List<String> reportReasons, String otherComment) async {
    isReporting = true;
    CommentActionModel? response;
    try {
      response = await Provider.of<DiscussionRepository>(context, listen: false)
          .reportDiscussion(discussionId, discussionText, reportReasons,
              otherComment, widget.discussionItemRequest.postType);
      if ((response?.responseCode ?? '').toString().toLowerCase() == 'ok') {
        widget.discussionItemRequest.discussionItemData.status =
            await response?.status ?? '';
        widget.discussionItemRequest.discussionItemData.isReported = true;
        _showReplySection.value = false;
        _showTagSection.value = false;
        setState(() {});
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
    _reportAnimationController
        .forward()
        .then((value) => _reportAnimationController.reverse());
  }

  Future updateChild(String commentId) async {
    _answerPostCount++;
    if (mounted) {
      setState(() {
        _discussionReplyData = null;
        pageNo = 1;
        _loadReply = true;
      });
    }
  }

  Future deleteCommentCallback(String commentId) async {
    _answerPostCount--;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _deleteComment(context, discussionId) async {
    isUpdating = true;
    CommentActionModel? response;
    try {
      response = await Provider.of<DiscussionRepository>(context, listen: false)
          .deleteDiscussion(
              discussionId,
              DiscussionHelper.getDeleteEndPoint(
                  widget.discussionItemRequest.postType));
      if ((response?.responseCode ?? '').toString().toLowerCase() == 'ok') {
        widget.discussionItemRequest.discussionItemData.isActive = false;
        _showReplySection.value = false;
        _showTagSection.value = false;
        widget.discussionItemRequest.deleteCommentCallback(discussionId);
        FocusScope.of(context).unfocus();
        Helper.showSnackBarMessage(
            context: context,
            text: AppLocalizations.of(context)!.mDiscussionDeletedText,
            bgColor: AppColors.positiveLight);
      } else {
        if ((response?.errMsg ?? '').isNotEmpty) {
          Helper.showSnackBarMessage(
              context: context,
              text: response?.errMsg ?? '',
              bgColor: AppColors.negativeLight);
        }
      }
      isUpdating = false;
    } catch (err) {
      isUpdating = false;
      throw err;
    }
  }

  Future<void> _flagComment() async {
    if (!isReporting) {
      isReporting = true;
      List<String> response = [];
      try {
        response =
            await Provider.of<DiscussionRepository>(context, listen: false)
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
                    commentId: widget.discussionItemRequest.discussionItemData
                            .discussionId ??
                        '',
                    reportReason: response,
                    onSubmitCallback: _reportComment,
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

  Future<void> _deleteCommentAlert() async {
    if (!isUpdating) {
      FocusScope.of(context).unfocus();
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext cxt) {
            return ConfirmationDialogWidget(
              title: AppLocalizations.of(context)!.mStaticDelete,
              subtitle: widget.discussionItemRequest.isReply
                  ? AppLocalizations.of(context)!.mDiscussionDeleteReplyAlertMsg
                  : AppLocalizations.of(context)!.mDiscussionDeletePostAlertMsg,
              primaryButtonText: AppLocalizations.of(context)!.mStaticDelete,
              onPrimaryButtonPressed: () {
                _deleteComment(
                    context,
                    widget.discussionItemRequest.discussionItemData
                            .discussionId ??
                        '');
                Navigator.of(cxt).pop();
              },
              secondaryButtonText: AppLocalizations.of(context)!.mStaticCancel,
              onSecondaryButtonPressed: () => Navigator.of(cxt).pop(),
            );
          });
    }
  }

  bool isEdited(String createdDate, String lastUpdatedDate) {
    if (createdDate.isEmpty || lastUpdatedDate.isEmpty) return false;
    try {
      DateTime createdDatetime = DateTime.parse(createdDate);
      DateTime lastUpdatedDatetime = DateTime.parse(lastUpdatedDate);

      return !createdDatetime.isAtSameMomentAs(lastUpdatedDatetime);
    } catch (e) {
      return false;
    }
  }

  Future<void> formatDetails(String inputText) async {

    try {
      await Future.delayed(const Duration(milliseconds: 200));

      if (inputText.isEmpty) return;

      final plainMentionRegex = RegExp(r'@(\w+)', multiLine: true);

      final spanMentionRegex = RegExp(
        r'<span class="mention" data-mention="(@\w+)">.*?</span>',
        caseSensitive: false,
      );

      String formattedText = inputText.replaceAllMapped(spanMentionRegex, (match) {
        final mention = match.group(1)!; // the @username
        return '<span style="color: #1b4ca1;">$mention</span>';
      });

      formattedText = formattedText.replaceAllMapped(plainMentionRegex, (match) {
        final mention = match.group(0)!;
        return '<span style="color: #1b4ca1;">$mention</span>';
      });

      _formattedDetails.value = formattedText;
    } catch (e) { }
  }


  @override
  Widget build(BuildContext context) {
    if (_discussionData == null) return Container();

    /// Check if the discussion is active
    bool isActive =
        widget.discussionItemRequest.discussionItemData.isActive ?? false;

    /// Check if the discussion is bookmarked or not (only if it's a bookmarked type)
    bool isBookmarked = (widget.discussionItemRequest.discussionType ==
            DiscussionType.bookmarked) &&
        (widget.discussionItemRequest.discussionItemData.isBookmarked ?? false);

    /// Only proceed if the discussion is active and either bookmarked or not a bookmarked discussion
    if (isActive &&
        ((widget.discussionItemRequest.discussionType !=
                    DiscussionType.bookmarked ||
                isBookmarked) ||
            widget.discussionItemRequest.isReply)) {
      return ((widget.discussionItemRequest.discussionItemData.status ?? '')
                  .toLowerCase() !=
              'suspended')
          ? Stack(
              children: [
                _activeCommentView(),
                if (widget
                        .discussionItemRequest.discussionItemData.isReported ??
                    false)
                  _suspendedMaskView(),
                if (widget
                        .discussionItemRequest.discussionItemData.isReported ??
                    false)
                  _suspendedView(),
              ],
            )
          : SizedBox.shrink();
    }

    return Container();
  }

  Widget _activeCommentView() {
    return Container(
        width: double.maxFinite,
        margin:
            EdgeInsets.only(top: widget.discussionItemRequest.isReply ? 4 : 8)
                .r,
        padding: EdgeInsets.only(
                bottom: widget.discussionItemRequest.isReply ? 0 : 4)
            .r,
        decoration: (!widget.discussionItemRequest.isReply)
            ? BoxDecoration(
                color: widget.discussionItemRequest.cardBackgroundColor,
                border: Border.all(color: AppColors.grey16),
                borderRadius: BorderRadius.all(const Radius.circular(12.0).r),
              )
            : null,
        child: Column(
          children: [
            Container(
              decoration: (widget.discussionItemRequest.isReply)
                  ? BoxDecoration(
                      color: widget.discussionItemRequest.cardBackgroundColor,
                      border: Border.all(color: AppColors.grey16),
                      borderRadius:
                          BorderRadius.all(const Radius.circular(12.0).r),
                    )
                  : null,
              padding: EdgeInsets.all(16).r,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Global feed
                  if ((widget.discussionItemRequest.discussionType ==
                          DiscussionType.globalFeeds) &&
                      !widget.discussionItemRequest.isReply)
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppUrl.communityPage,
                          arguments: widget.discussionItemRequest
                              .discussionItemData.communityId,
                        );
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 8).r,
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(const Radius.circular(50.0).r),
                            color: AppColors.grey08),
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 4.0, right: 8).w,
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          "${AppLocalizations.of(context)!.mDiscussionPostingIn} ",
                                      style: GoogleFonts.lato(
                                        color: AppColors.disabledTextGrey,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 10.0.sp,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          "@ ${widget.discussionItemRequest.discussionItemData.communityName}",
                                      style: GoogleFonts.lato(
                                        color: AppColors.darkBlue,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 10.0.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  /// pinned by
                  if (widget.discussionItemRequest.discussionType ==
                      DiscussionType.pinned)
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 8).r,
                      decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.all(const Radius.circular(50.0).r),
                          color: (widget.discussionItemRequest.enableAction)
                              ? AppColors.primaryOne.withValues(alpha: 0.2)
                              : AppColors.grey08),
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Transform.rotate(
                            angle: 45 * 3.141592653589793 / 180,
                            child: Icon(
                              CupertinoIcons.pin_fill,
                              size: 10.w,
                              color: AppColors.disabledTextGrey,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 4.0, right: 8).w,
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        "${AppLocalizations.of(context)!.mDiscussionPinnedBy} ",
                                    style: GoogleFonts.lato(
                                      color: AppColors.disabledTextGrey,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 10.0.sp,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "@",
                                    style: GoogleFonts.lato(
                                      color: AppColors.darkBlue,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 10.0.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  ///tools
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Spacer(),
                      if (isEdited(
                          widget.discussionItemRequest.discussionItemData
                                  .createdOn ??
                              '',
                          widget.discussionItemRequest.discussionItemData
                                  .updatedOn ??
                              ''))
                        Padding(
                          padding: const EdgeInsets.only(right: 2.0).r,
                          child: Text(
                            "(${AppLocalizations.of(context)!.mCommentEdited})",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: AppColors.grey40,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12.sp,
                                ),
                          ),
                        ),
                      Text(
                        _getDateNow((widget.discussionItemRequest
                                    .discussionItemData.updatedOn !=
                                null)
                            ? (widget.discussionItemRequest.discussionItemData
                                    .updatedOn ??
                                '')
                            : (widget.discussionItemRequest.discussionItemData
                                    .createdOn ??
                                '')),
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: AppColors.greys60,
                              fontWeight: FontWeight.w400,
                              fontSize: 12.sp,
                            ),
                      ),
                      // _connectPillsButton(
                      //     title: AppLocalizations.of(context)!.mStaticFollow,
                      //     prefix: Icon(
                      //       Icons.add,
                      //       size: 16.w,
                      //       color: (widget.discussionItemRequest.enableAction) ? AppColors.primaryOne : AppColors.disabledTextGrey,
                      //     ),
                      //     onTap: (){}
                      // ),
                      if (widget.discussionItemRequest.enableAction)
                        _optionItems(),
                    ],
                  ),

                  /// User detail
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 4).r,
                        child: CommentProfileImageWidget(
                            profilePic:
                                _discussionData?.createdBy?.userProfileImgUrl ??
                                    '',
                            name: _discussionData?.createdBy?.firstName ?? '',
                            errorImageColor:
                                errorImageColor ?? AppColors.primaryOne,
                            iconSize: widget.discussionItemRequest.isReply
                                ? 32.w
                                : 46.w),
                      ),
                      Container(
                        width: 0.6.sw,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0).r,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        _discussionData?.createdBy?.firstName ??
                                            '',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall!
                                            .copyWith(
                                              color: AppColors.greys60,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16.sp,
                                            ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if ((_discussionData?.createdBy
                                                    ?.userProfileStatus ??
                                                '')
                                            .toLowerCase() ==
                                        UserProfileStatus.verified
                                            .toLowerCase())
                                      Container(
                                        height: 20.w,
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.only(
                                          left: 4,
                                        ).r,
                                        child: CircleAvatar(
                                          backgroundColor:
                                              AppColors.positiveLight,
                                          radius: 5.0.r,
                                          child: SvgPicture.asset(
                                            'assets/img/approved.svg',
                                            width: 12.0.w,
                                            height: 12.0.w,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                if (((_discussionData?.createdBy?.designation ??
                                            '')
                                        .isNotEmpty) &&
                                    (_discussionData?.createdBy?.designation ??
                                                '')
                                            .toLowerCase() !=
                                        'null')
                                  Text(
                                    _discussionData?.createdBy?.designation ??
                                        '',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          color: AppColors.greys60,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12.sp,
                                        ),
                                  ),
                              ]),
                        ),
                      ),
                    ],
                  ),

                  /// Edit reply
                  ValueListenableBuilder(
                      valueListenable: _showInEditMode,
                      builder: (BuildContext context, bool showInEditMode,
                          Widget? child) {
                        return showInEditMode
                            ? Padding(
                                padding: EdgeInsets.only(top: 16).r,
                                child: AddReplyPage(
                                    parentDiscussionId:
                                        widget.discussionItemRequest.parentId,
                                    communityId: widget.discussionItemRequest
                                            .discussionItemData.communityId ??
                                        "",
                                    hintText: (widget.discussionItemRequest
                                            .isAnswerPostReply)
                                        ? AppLocalizations.of(context)!
                                            .mStaticReplyToThisComment
                                        : AppLocalizations.of(context)!
                                            .mStaticAddAComment,
                                    callback: editPostCallback,
                                    updateCloseCallback: closeEdit,
                                    readOnly: false,
                                    isUpdate: true,
                                    discussionItemData: widget
                                        .discussionItemRequest
                                        .discussionItemData,
                                    cardBackgroundColor: Colors.transparent,
                                    isAnswerPostReply: widget
                                        .discussionItemRequest
                                        .isAnswerPostReply),
                              )
                            : _postContentView();
                      }),

                  /// post hash tags
                  if ((_discussionData?.tags ?? []).isNotEmpty)
                    _tagListView(_discussionData?.tags ?? []),
                  Divider(
                    color: AppColors.grey08,
                    thickness: 1.w,
                  ),

                  /// action items
                  _actionItems(),
                ],
              ),
            ),
            if (!widget.discussionItemRequest.isReply)
              Padding(
                padding: const EdgeInsets.only(left: 16).r,
                child: ValueListenableBuilder(
                    valueListenable: _showReplySection,
                    builder: (BuildContext context, bool showReplySection,
                        Widget? child) {
                      if ((showReplySection && _loadReply)) {
                        _loadReply = false;
                        _loadComments(isAnswerPostReply: false);
                      }
                      return showReplySection
                          ? _commentsReplies(isAnswerPostReply: false)
                          : Container();
                    }),
              ),
            if (widget.discussionItemRequest.isReply)
              Padding(
                padding: const EdgeInsets.only(left: 16).r,
                child: ValueListenableBuilder(
                    valueListenable: _showTagSection,
                    builder: (BuildContext context, bool showTagSection,
                        Widget? child) {
                      if ((showTagSection && _loadReply)) {
                        _loadReply = false;
                        _loadComments(isAnswerPostReply: true);
                      }
                      return showTagSection
                          ? _commentsReplies(isAnswerPostReply: true)
                          : Container();
                    }),
              )
          ],
        ));
  }

  Widget _postContentView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// description
        if ((_discussionData?.description??'').isNotEmpty)
          ValueListenableBuilder(
              valueListenable: _formattedDetails,
              builder: (BuildContext context, String formattedDetails, Widget? child) {
                return formattedDetails.isNotEmpty ? Padding(
                  padding: EdgeInsets.only(top: 2).r,
                  child: ViewMoreText(
                    text: formattedDetails,
                    viewLessText:
                    AppLocalizations.of(context)!.mStaticReadLess,
                    viewMoreText:
                    AppLocalizations.of(context)!.mStaticReadMore,
                    maxCharacter: 500,
                    maxLines: 5,
                    style: GoogleFonts.lato(
                      color: AppColors.greys60,
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp,
                      height: 1.5.h,
                    ),
                    moreLessStyle: GoogleFonts.lato(
                      color: AppColors.darkBlue,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                      height: 1.5.h,
                    ),
                  ),
                ) : SizedBox.shrink();
              }),
        /// Image
        if ((_discussionData?.mediaCategory?.image ?? []).isNotEmpty)
          DiscussionMediaViewWidget(
              mediaUrls: _discussionData?.mediaCategory?.image ?? [],
              contentType: MediaConst.image),
        if ((_discussionData?.mediaCategory?.video ?? []).isNotEmpty)
          DiscussionMediaViewWidget(
              mediaUrls: _discussionData?.mediaCategory?.video ?? [],
              contentType: MediaConst.video),
        if ((_discussionData?.mediaCategory?.document ?? []).isNotEmpty)
          DiscussionMediaViewWidget(
              mediaUrls: _discussionData?.mediaCategory?.document ?? [],
              contentType: MediaConst.file),
        if ((_discussionData?.mediaCategory?.link ?? []).isNotEmpty)
          DiscussionMediaViewWidget(
              mediaUrls: _discussionData?.mediaCategory?.link ?? [],
              contentType: MediaConst.link),
      ],
    );
  }
  
  Widget _tagListView(List<String> tags) {
    return Container(
        padding: EdgeInsets.only(top: 16, bottom: 16).r,
        child: Wrap(
          alignment: WrapAlignment.start,
          children: [
            AnimationLimiter(
                child: Wrap(
              alignment: WrapAlignment.start,
              children: [
                for (int i = 0; i < tags.length; i++)
                  AnimationConfiguration.staggeredList(
                    position: i,
                    duration: const Duration(milliseconds: 300),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: InkWell(
                            onTap: () {},
                            child: Container(
                              margin: EdgeInsets.only(
                                top: 8.0,
                                right: 8.0,
                              ).r,
                              padding: EdgeInsets.fromLTRB(20, 8, 20, 8).r,
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.grey08),
                                borderRadius: BorderRadius.all(
                                    const Radius.circular(50.0).r),
                              ),
                              child: Wrap(
                                children: [
                                  Text(tags[i],
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium!
                                          .copyWith(
                                            color: AppColors.disabledTextGrey,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14.0.sp,
                                          )),
                                ],
                              ),
                            )),
                      ),
                    ),
                  )
              ],
            )),
          ],
        ));
  }

  Widget _suspendedMaskView() {
    return Positioned(
      bottom: 0.w,
      right: 0.w,
      left: 0.w,
      top: 0.w,
      child: Container(
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: AppColors.grey08,
          border: Border.all(color: AppColors.positiveLight),
          borderRadius: BorderRadius.all(const Radius.circular(12.0).r),
        ),
        margin: EdgeInsets.symmetric(vertical: 8).r,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0).w,
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: AppColors.appBarBackground
                    .withValues(alpha: 0.3), // Adjust opacity as needed
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _suspendedView() {
    return Positioned(
      child: Align(
        alignment: FractionalOffset.center,
        child: Padding(
          padding: const EdgeInsets.all(16.0).r,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 36.w,
                color: AppColors.positiveLight,
              ),
              SizedBox(height: 16.w),
              Text(
                AppLocalizations.of(context)!.mDiscussionReported,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: AppColors.positiveLight,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.w),
              Text(
                AppLocalizations.of(context)!.mDiscussionReportedMessage,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: AppColors.greys87,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400),
                // overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.w),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PillsButtonWidget(
                    title: AppLocalizations.of(context)!.mDiscussionShowPost,
                    onTap: () {
                      setState(() {
                        widget.discussionItemRequest.discussionItemData
                            .isReported = false;
                      });
                    },
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.darkBlue),
                      borderRadius:
                          BorderRadius.all(const Radius.circular(4.0).r),
                    ),
                    textColor: AppColors.darkBlue,
                    textFontSize: 14.sp,
                    isLightTheme: false,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionItems() {
    return Padding(
      padding: EdgeInsets.only(top: 16.0).w,
      child: Column(
        children: [
          Container(
              width: double.maxFinite,
              alignment: Alignment.centerLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (widget.discussionItemRequest.enableLike)
                    _voteDiscussionWidget(
                      animationController: _upVoteAnimationController,
                      count: (_discussionData?.upVoteCount ?? 0).toString(),
                      category: ((_discussionData?.upVoteCount ?? 0) == 1)
                          ? AppLocalizations.of(context)!.mDiscussionUpvote
                          : AppLocalizations.of(context)!.mDiscussionUpvote,
                      activeColor: AppColors.darkBlue,
                      onVote: () {
                        if (!isVoting &&
                            widget.discussionItemRequest.enableAction) {
                          _likeComment(
                              context,
                              widget.discussionItemRequest.discussionItemData
                                      .discussionId ??
                                  '',
                              !(widget.discussionItemRequest.discussionItemData
                                      .isLiked ??
                                  false));
                        }
                      },
                    ),
                  if (!widget.discussionItemRequest.isReply &&
                      widget.discussionItemRequest.enableReply)
                    ValueListenableBuilder(
                        valueListenable: _showReplySection,
                        builder: (BuildContext context, bool showReplySection,
                            Widget? child) {
                          return _showReplyWidget(
                              image: Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()..scale(-1.0, 1.0),
                                child: Icon(
                                  Icons.message,
                                  size: 24.w,
                                  color: AppColors.greys60,
                                ),
                              ),
                              showReplySection: showReplySection,
                              category:
                                  "${(_answerPostCount == 1) ? AppLocalizations.of(context)!.mStaticComment : AppLocalizations.of(context)!.mStaticComments}",
                              count: _answerPostCount,
                              animationController: _commentAnimationController);
                        }),
                  if ((widget.discussionItemRequest.enableTag &&
                          widget.discussionItemRequest.enableReply) &&
                      widget.discussionItemRequest.enableAction)
                    _showTagWidget(
                        animationController: _commentAnimationController),
                  Spacer(),
                  if (widget.discussionItemRequest.enableBookmark)
                    _bookmarkDiscussionWidget(
                      animationController: _bookmarkAnimationController,
                      count: (_discussionData?.upVoteCount ?? 0).toString(),
                      category: ((_discussionData?.upVoteCount ?? 0) == 1)
                          ? AppLocalizations.of(context)!.mDiscussionUpvote
                          : AppLocalizations.of(context)!.mDiscussionUpvote,
                      activeColor: AppColors.darkBlue,
                      onBookmark: () {
                        if (!isBookmarking &&
                            widget.discussionItemRequest.enableAction) {
                          _bookmarkComment(
                              context,
                              widget.discussionItemRequest.discussionItemData
                                      .discussionId ??
                                  '',
                              (widget.discussionItemRequest.discussionItemData
                                      .isBookmarked ??
                                  false));
                        }
                      },
                    ),
                ],
              )),
          if (!widget.discussionItemRequest.enableAction)
            SizedBox(
              height: 16.w,
            ),
          if (widget.discussionItemRequest.enableAction)
            ValueListenableBuilder(
                valueListenable: _showReplySection,
                builder: (BuildContext context, bool showReplySection,
                    Widget? child) {
                  return showReplySection
                      ? Padding(
                          padding: EdgeInsets.only(
                                  top: 16,
                                  bottom: widget.discussionItemRequest.isReply
                                      ? 8
                                      : 0)
                              .r,
                          child: AddReplyPage(
                            parentDiscussionId:
                                widget.discussionItemRequest.parentId,
                            communityId: widget.discussionItemRequest
                                    .discussionItemData.communityId ??
                                "",
                            startingIcon: CommentProfileImageWidget(
                                profilePic: widget
                                    .discussionItemRequest.profileImageUrl,
                                name: widget.discussionItemRequest.userName,
                                errorImageColor:
                                    errorImageColor ?? AppColors.primaryOne,
                                iconSize: 32.w),
                            hintText: AppLocalizations.of(context)!
                                .mStaticAddAComment,
                            callback: replyPostCallback,
                            readOnly:
                                !widget.discussionItemRequest.enableAction,
                            cardBackgroundColor: widget
                                .discussionItemRequest.replyCardBackgroundColor,
                            isAnswerPostReply: false,
                          ),
                        )
                      : _tagUserReply();
                })
        ],
      ),
    );
  }

  Widget _tagUserReply() {
    return ValueListenableBuilder(
        valueListenable: _showTagSection,
        builder: (BuildContext context, bool showTagSection, Widget? child) {
          return showTagSection
              ? Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 8).r,
                  child: AddReplyPage(
                    parentDiscussionId: widget.discussionItemRequest
                            .discussionItemData.discussionId ??
                        '',
                    parentPostId: widget.discussionItemRequest.parentId,
                    communityId: widget.discussionItemRequest.discussionItemData
                            .communityId ??
                        '',
                    startingIcon: CommentProfileImageWidget(
                        profilePic:
                            widget.discussionItemRequest.profileImageUrl,
                        name: widget.discussionItemRequest.userName,
                        errorImageColor:
                            errorImageColor ?? AppColors.primaryOne,
                        iconSize: 32.w),
                    hintText:
                        AppLocalizations.of(context)!.mStaticReplyToThisComment,
                    callback: tagPostCallback,
                    readOnly: !widget.discussionItemRequest.enableAction,
                    cardBackgroundColor:
                        widget.discussionItemRequest.cardBackgroundColor,
                    isAnswerPostReply: true,
                  ))
              : Container();
        });
  }

  Widget _showReplyWidget(
      {required Widget image,
      required bool showReplySection,
      required String category,
      required int count,
      required AnimationController animationController}) {
    return GestureDetector(
      onTap: () {
        _commentAnimationController
            .forward()
            .then((value) => _commentAnimationController.reverse());
        _showReplySection.value = !_showReplySection.value;
      },
      child: Container(
        margin: EdgeInsets.only(left: 8).r,
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16).r,
        decoration: BoxDecoration(
            border: Border.all(color: AppColors.grey08),
            borderRadius: BorderRadius.all(const Radius.circular(50.0).r),
            color: (widget.discussionItemRequest.enableAction)
                ? null
                : AppColors.grey08),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(right: 2).r,
              child: Icon(
                showReplySection ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                size: 24.w,
                color: AppColors.greys60,
              ),
            ),
            ScaleTransition(scale: animationController, child: image),
            Padding(
              padding: EdgeInsets.only(left: 4.0, right: 8).w,
              child: Text(
                "${count.toString()}",
                style: GoogleFonts.lato(
                  color: AppColors.disabledTextGrey,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.0.sp,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _showTagWidget({required AnimationController animationController}) {
    return GestureDetector(
      onTap: () {
        _commentAnimationController
            .forward()
            .then((value) => _commentAnimationController.reverse());
        _showTagSection.value = !_showTagSection.value;
      },
      child: Container(
        margin: EdgeInsets.only(left: 8).r,
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16).r,
        decoration: BoxDecoration(
            border: Border.all(color: AppColors.grey08),
            borderRadius: BorderRadius.all(const Radius.circular(50.0).r),
            color: (widget.discussionItemRequest.enableAction)
                ? null
                : AppColors.grey08),
        child: Row(
          children: [
            ValueListenableBuilder(
                valueListenable: _showTagSection,
                builder:
                    (BuildContext context, bool showTagSection, Widget? child) {
                  return Padding(
                    padding: EdgeInsets.only(right: 2).r,
                    child: Icon(
                      showTagSection
                          ? Icons.arrow_drop_up
                          : Icons.arrow_drop_down,
                      size: 24.w,
                      color: AppColors.greys60,
                    ),
                  );
                }),
            ScaleTransition(
              scale: animationController,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..scale(-1.0, 1.0),
                child: Icon(
                  Icons.message,
                  size: 24.w,
                  color: AppColors.greys60,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 4.0, right: 8).w,
              child: Text(
                "${_answerPostCount}",
                style: GoogleFonts.lato(
                  color: AppColors.disabledTextGrey,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.0.sp,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _commentsReplies({required bool isAnswerPostReply}) {
    return FutureBuilder(
      future: _commentsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return (_isLoading)
              ? CommentViewSkeleton(
                  itemCount: 3,
                )
              : Container();
        }
        return Wrap(
          alignment: WrapAlignment.start,
          children: [
            Wrap(
              children: [
                if ((_discussionReplyData?.data ?? []).isNotEmpty &&
                    !_isLoading)
                  _commentsListView(
                      isAnswerPostReply, _discussionReplyData?.data ?? []),
                if (_isLoading)
                  CommentViewSkeleton(
                    itemCount: 3,
                  ),
                if (_hasMoreComments && !_isLoading)
                  GestureDetector(
                    onTap: () {
                      pageNo = pageNo + 1;
                      _loadComments(isAnswerPostReply: isAnswerPostReply);
                    },
                    child: Container(
                      width: double.maxFinite,
                      margin: EdgeInsets.symmetric(vertical: 16).r,
                      padding: EdgeInsets.symmetric(vertical: 16).r,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.appBarBackground,
                        border: Border.all(color: AppColors.darkBlue),
                        borderRadius:
                            BorderRadius.all(const Radius.circular(50.0).r),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.mStaticLoadMore,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: AppColors.darkBlue,
                              fontWeight: FontWeight.w400,
                              fontSize: 12.sp,
                            ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _commentsListView(
      bool isAnswerPostReply, List<DiscussionItemData> commentList) {
    return (commentList.isNotEmpty)
        ? AnimationLimiter(
            child: Column(
              children: List.generate(
                commentList.length,
                (index) {
                  DiscussionItemRequest _discussionItemRequest =
                      DiscussionItemRequest(
                          discussionType:
                              widget.discussionItemRequest.discussionType,
                          discussionItemData:
                              (_discussionReplyData?.data ?? [])[index],
                          isReply: true,
                          isAnswerPostReply: isAnswerPostReply,
                          parentId: widget.discussionItemRequest.parentId,
                          userName: widget.discussionItemRequest.userName,
                          userId: widget.discussionItemRequest.userId,
                          profileImageUrl:
                              widget.discussionItemRequest.profileImageUrl,
                          userRole: widget.discussionItemRequest.userRole,
                          designation: widget.discussionItemRequest.designation,
                          profileStatus:
                              widget.discussionItemRequest.profileStatus,
                          answerPostCount:
                              (_discussionReplyData?.data ?? [])[index]
                                      .answerPostRepliesCount ??
                                  0,
                          enableLike: widget.discussionItemRequest.enableLike,
                          enableBookmark: false,
                          enableReply: widget.discussionItemRequest.enableReply,
                          enableTag: isAnswerPostReply ? false : true,
                          enableReport:
                              widget.discussionItemRequest.enableReport,
                          enableAction:
                              widget.discussionItemRequest.enableAction,
                          enableEdit: widget.discussionItemRequest.enableEdit,
                          enableDelete:
                              widget.discussionItemRequest.enableDelete,
                          updateChildCallback: updateChild,
                          deleteCommentCallback: deleteCommentCallback,
                          cardBackgroundColor: isAnswerPostReply
                              ? AppColors.tagPostBackgroundColor
                              : AppColors.answerPostBackgroundColor,
                          replyCardBackgroundColor: isAnswerPostReply
                              ? AppColors.tagPostBackgroundColor
                              : AppColors.answerPostBackgroundColor,
                          postType: isAnswerPostReply
                              ? PostTypeConst.answerPostReply
                              : PostTypeConst.answerPost);

                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 475),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: DiscussionItemWidget(
                          discussionItemRequest: _discussionItemRequest,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          )
        : Container();
  }

  Widget _voteDiscussionWidget(
      {required AnimationController animationController,
      required String count,
      required String category,
      required Function onVote,
      required Color activeColor}) {
    return InkWell(
        onTap: () {
          onVote();
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16).r,
          decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey08),
              borderRadius: BorderRadius.all(const Radius.circular(50.0).r),
              color: (widget.discussionItemRequest.enableAction)
                  ? null
                  : AppColors.grey08),
          child: Row(
            children: [
              ScaleTransition(
                  scale: animationController,
                  child: Icon(
                    Icons.thumb_up,
                    size: 24.w,
                    color: (widget.discussionItemRequest.discussionItemData
                                .isLiked ??
                            false)
                        ? AppColors.positiveLight
                        : AppColors.greys60,
                  )),
              Padding(
                padding: EdgeInsets.only(left: 4.0, right: 8).w,
                child: Text(
                  "$count",
                  style: GoogleFonts.lato(
                    color: AppColors.disabledTextGrey,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.0.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ));
  }

  Widget _bookmarkDiscussionWidget(
      {required AnimationController animationController,
      required String count,
      required String category,
      required Function onBookmark,
      required Color activeColor}) {
    return InkWell(
        onTap: () {
          onBookmark();
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8).r,
          child: ScaleTransition(
              scale: animationController,
              child: (widget.discussionItemRequest.discussionItemData
                          .isBookmarked ??
                      false)
                  ? Icon(
                      Icons.bookmark,
                      size: 24.w,
                      color: AppColors.darkBlue,
                    )
                  : Icon(
                      Icons.bookmark_border_outlined,
                      size: 24.w,
                      color: (widget.discussionItemRequest.enableAction)
                          ? AppColors.greys60
                          : AppColors.grey08,
                    )),
        ));
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
          child: Icon(
            Icons.more_vert,
            size: 24.w,
            color: AppColors.greys60,
          ),
          itemBuilder: (context) => [
            if (widget.discussionItemRequest.enableReport &&
                (_discussionData?.createdBy?.userId ?? "") !=
                    widget.discussionItemRequest.userId)
              _popUpMenuItem(
                  value: 1,
                  text: AppLocalizations.of(context)!.mDiscussionReport,
                  icon: Icons.flag_outlined,
                  iconColor: AppColors.primaryOne),
            if (widget.discussionItemRequest.enableEdit &&
                (_discussionData?.createdBy?.userId ?? "") ==
                    widget.discussionItemRequest.userId)
              _popUpMenuItem(
                  value: 2,
                  text: AppLocalizations.of(context)!.mStaticEdit,
                  icon: Icons.edit,
                  iconColor: AppColors.darkBlue),
            if (widget.discussionItemRequest.enableDelete &&
                (_discussionData?.createdBy?.userId ?? "") ==
                    widget.discussionItemRequest.userId)
              _popUpMenuItem(
                  value: 3,
                  text: AppLocalizations.of(context)!.mStaticDelete,
                  icon: Icons.delete,
                  iconColor: AppColors.primaryOne)
          ],
          onSelected: (value) {
            if (value == 1) {
              _flagComment();
            } else if (value == 2) {
              if (widget.discussionItemRequest.isReply) {
                _showInEditMode.value = true;
              } else {
                _editPostCallback();
              }
            } else if (value == 3) {
              _deleteCommentAlert();
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

  ///Edit existing post
  Future _editPostCallback() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: AppColors.grey04.withValues(alpha: 0.36),
      builder: (BuildContext context) {
        return AddDiscussionPage(
          userName: widget.discussionItemRequest.userName,
          userProfileImgUrl: widget.discussionItemRequest.profileImageUrl,
          userProfileStatus: widget.discussionItemRequest.profileStatus,
          designation: widget.discussionItemRequest.designation,
          communityId:
              widget.discussionItemRequest.discussionItemData.communityId ?? '',
          postCallback: (discussionData) {
            _discussionData?.mediaCategory = MediaCategory(
              image: discussionData.mediaCategory?.image ?? [],
              video: discussionData.mediaCategory?.video ?? [],
              document: discussionData.mediaCategory?.document ?? [],
              link: discussionData.mediaCategory?.link ?? [],
            );
            Future.delayed(Duration(microseconds: 400), () {
              setState(() {
                _discussionData?.description = discussionData.description;
                _discussionData?.mentionedUsers = discussionData.mentionedUsers;
                _discussionData?.updatedOn = discussionData.updatedOn;
              });
            });
          },
          discussionItemData: _discussionData,
        );
      },
    );
  }

  void closeEdit() {
    _showInEditMode.value = false;
  }

  Future replyPostCallback(DiscussionItemData discussionData) async {
    if (discussionData.discussionId != null) {
      _answerPostCount++;
      _showTagSection.value = false;
      if (mounted) {
        setState(() {
          _discussionReplyData = null;
          pageNo = 1;
          _loadReply = true;
        });
      }
    }
  }

  Future tagPostCallback(DiscussionItemData discussionData) async {
    if (discussionData.discussionId != null) {
      _answerPostCount++;
      if (mounted) {
        setState(() {
          _discussionReplyData = null;
          pageNo = 1;
          _loadReply = true;
        });
      }
    }
  }

  Future editPostCallback(DiscussionItemData discussionData) async {
    if (discussionData.discussionId != null) {
      _discussionData?.mediaCategory = MediaCategory(
        image: discussionData.mediaCategory?.image ?? [],
      );
      Future.delayed(Duration(microseconds: 400), () {
        setState(() {
          _discussionData?.description = discussionData.description;
          _discussionData?.updatedOn = discussionData.updatedOn;
        });
      });
    }
  }
}
