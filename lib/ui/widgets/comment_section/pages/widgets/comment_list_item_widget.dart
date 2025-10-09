import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/ui/components/view_more_text.dart';
import 'package:karmayogi_mobile/ui/widgets/comment_section/model/comment_request.dart';
import 'package:karmayogi_mobile/ui/widgets/comment_section/pages/widgets/report_comment_widget.dart';
import 'package:provider/provider.dart';
import 'package:simple_moment/simple_moment.dart';
import '../../../../../../../../constants/_constants/color_constants.dart';
import '../../../../../constants/_constants/app_constants.dart';
import '../../model/comment_action_model.dart';
import '../../model/comment_data_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../model/comment_model.dart';
import '../../model/user_data_model.dart';
import '../../repositories/comment_repository.dart';
import 'add_comment_page.dart';
import 'comment_profile_image_widget.dart';
import 'comment_view_skeleton.dart';
import 'confirmation_dialog.dart';

class CommentListItemWidget extends StatefulWidget {
  final CommentDataModel commentDataModel;
  final List<UserDataModel> taggedUsers;
  final List<UserDataModel> users;
  final List<String> userLikedComments;
  final CourseDetails? courseDetails;
  final bool isReply;
  final String? parentId;
  final String userName;
  final String userId;
  final String profileImageUrl;
  final String commentTreeId;
  final String userRole;
  final String designation;
  final String profileStatus;
  final List<String> replies;
  final bool enableLike;
  final bool enableReport;
  final bool enableReply;
  final bool enableTag;
  final bool enableEdit;
  final bool enableDelete;
  final bool enableAction;
  final String entityType;
  final String entityId;
  final String workflow;
  final Function(String) updateChildCallback;
  final Function(String) deleteCommentCallback;
  final Function(Map<String, dynamic>) likeCallback;
  final bool enableUserTagging;
  CommentListItemWidget(
      {Key? key,
      required this.commentDataModel,
      required this.taggedUsers,
      required this.users,
      required this.userLikedComments,
      this.courseDetails,
      this.isReply = false,
      this.parentId,
      required this.userName,
      required this.userId,
      required this.profileImageUrl,
      required this.commentTreeId,
      required this.userRole,
      required this.designation,
      required this.profileStatus,
      required this.replies,
      this.enableLike = false,
      this.enableReport = false,
      this.enableReply = false,
      this.enableTag = false,
      this.enableEdit = false,
      this.enableDelete = false,
      this.enableAction = true,
      required this.entityType,
      required this.entityId,
      required this.workflow,
      required this.updateChildCallback,
      required this.deleteCommentCallback,
      required this.likeCallback,
      required this.enableUserTagging})
      : super(key: key);

  @override
  _CommentListItemWidgetState createState() {
    return new _CommentListItemWidgetState();
  }
}

class _CommentListItemWidgetState extends State<CommentListItemWidget>
    with TickerProviderStateMixin {
  CommentData? _commentData;
  final dateNow = Moment.now();
  Color? errorImageColor =
      AppColors.networkBg[Random().nextInt(AppColors.networkBg.length)];
  ValueNotifier<bool> _showReplySection = ValueNotifier(false);
  ValueNotifier<bool> _showTagSection = ValueNotifier(false);
  ValueNotifier<bool> _showInEditMode = ValueNotifier(false);
  ValueNotifier<String> _formattedComment = ValueNotifier("");

  late AnimationController _upVoteAnimationController;
  late AnimationController _reportAnimationController;
  late AnimationController _commentAnimationController;
  bool isVoting = false;
  bool isReporting = false;
  bool isUpdating = false;

  Future<CommentModel?>? _commentsFuture;
  bool _isLoading = false;
  bool _loadReply = false;
  List<String> _commentReplies = [];

  bool _hasMoreComments = false;
  int _currentPage = 0;
  int _pageSize = 5;
  List<CommentDataModel> _comments = [];
  List<UserDataModel> _taggedUsers = [];
  List<UserDataModel> _users = [];
  UserDataModel? _user;

  @override
  void initState() {
    super.initState();
    _commentData = widget.commentDataModel.commentData;
    _commentReplies = widget.replies;
    _loadReply = _commentReplies.isNotEmpty;
    _loadUserData(_commentData?.commentSource?.userId ?? '');
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
    await formatComment((_commentData?.comment??'').trim());
  }

  Future<void> _loadComments() async {
    _commentsFuture = _getComments(context);
  }

  Future<CommentModel?> _getComments(context) async {
    try {
      _isLoading = true;

      List<String> reversedReplies = _commentReplies.reversed.toList();
      int startIndex = _currentPage * _pageSize;
      int endIndex = startIndex + _pageSize;
      List<String> paginatedReplies = reversedReplies.sublist(
        startIndex,
        endIndex > reversedReplies.length ? reversedReplies.length : endIndex,
      );

      CommentModel? response =
          await Provider.of<CommentRepository>(context, listen: false)
              .getReply(paginatedReplies);
      if (response != null) {
        setState(() {
          _comments.addAll(response.comments ?? []);
          _taggedUsers.addAll(response.taggedUsers ?? []);
          _users.addAll(response.users ?? []);
          _isLoading = false;
          _hasMoreComments = _commentReplies.length > _comments.length;
          _currentPage++;
        });
        return Future.value(response);
      }
      return null;
    } catch (err) {
      _isLoading = false;
      return null;
    }
  }

  Future<void> formatComment(String inputText) async {

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

      String formattedMessage = """${_commentData?.taggedUsers?.isNotEmpty ?? false ? '<span style="color: #1B4CA1;"><b>${AppLocalizations.of(context)!.mStaticReplyingTo} ${getTaggedUserName((_commentData?.taggedUsers)![0])}</b></span> ' : ''}${formattedText}""";

    _formattedComment.value = formattedMessage;
    } catch (e) { }
  }

  String _getDateNow(String date) {
    DateTime parsedDate = DateTime.parse(date);

    DateTime dateNow = DateTime.now();

    if (parsedDate.isAfter(dateNow)) {
      return "";
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

  Future<void> _likeComment(
      context, commentId, displayDeleteTools, bool isLike) async {
    if (displayDeleteTools) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          AppLocalizations.of(context)!.mStaticCantVoteMsg,
          style: GoogleFonts.lato(
            fontSize: 12.0.sp,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        duration: Duration(seconds: 3),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
      _upVoteAnimationController
          .forward()
          .then((value) => _upVoteAnimationController.reverse());
    } else {
      isVoting = true;
      CommentActionModel? response;
      try {
        response = await Provider.of<CommentRepository>(context, listen: false)
            .likeComment(commentId, 'like', widget.entityId);
        if ((response?.responseCode ?? '').toString().toLowerCase() == 'ok') {
          if (isLike) {
            widget.commentDataModel.isLiked = true;
            _commentData?.like = ((_commentData?.like ?? 0) + 1);
          } else {
            widget.commentDataModel.isLiked = false;
            _commentData?.like = ((_commentData?.like ?? 1) - 1);
          }
          widget.likeCallback({
            'isLike': isLike,
            'commentId': commentId,
          });
          setState(() {});
        } else {
          if ((response?.errMsg ?? '').isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response?.errMsg ?? ''),
                backgroundColor: AppColors.negativeLight,
              ),
            );
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
  }

  Future<void> _reportComment(Map<String, dynamic> data) async {
    _report(context, widget.commentDataModel.commentId ?? '',
        data['reportReasons'] ?? [], data['otherComment'] ?? '');
  }

  Future<void> _report(context, String commentId, List<String> reportReasons,
      String otherComment) async {
    isReporting = true;
    CommentActionModel? response;
    try {
      response = await Provider.of<CommentRepository>(context, listen: false)
          .reportComment(commentId, reportReasons, otherComment);
      if ((response?.responseCode ?? '').toString().toLowerCase() == 'ok') {
        widget.commentDataModel.status = await response?.status ?? '';
        _showReplySection.value = false;
        _showTagSection.value = false;
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.mStaticReportedMsg),
            backgroundColor: AppColors.positiveLight,
          ),
        );
      } else {
        if ((response?.errMsg ?? '').isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response?.errMsg ?? ''),
              backgroundColor: AppColors.negativeLight,
            ),
          );
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
    _commentReplies.add(commentId);
    if (mounted) {
      setState(() {
        _comments = [];
        _taggedUsers = [];
        _users = [];
        _hasMoreComments = _commentReplies.length > _comments.length;
        _currentPage = 0;
        _loadReply = true;
      });
    }
  }

  Future deleteCommentCallback(String commentId) async {
    _commentReplies.remove(commentId);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _deleteComment(context, commentId) async {
    isUpdating = true;
    CommentActionModel? response;
    try {
      response = await Provider.of<CommentRepository>(context, listen: false)
          .deleteComment(commentId, widget.entityType, widget.entityId,
              widget.workflow, widget.parentId);
      if ((response?.responseCode ?? '').toString().toLowerCase() == 'ok') {
        widget.commentDataModel.status = await response?.status ?? '';
        _showReplySection.value = false;
        _showTagSection.value = false;
        widget.deleteCommentCallback(commentId);
        FocusScope.of(context).unfocus();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.mCommentDeletedText),
            backgroundColor: AppColors.positiveLight,
          ),
        );
      } else {
        if ((response?.errMsg ?? '').isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response?.errMsg ?? ''),
              backgroundColor: AppColors.negativeLight,
            ),
          );
        }
      }
      isUpdating = false;
    } catch (err) {
      isUpdating = false;
      throw err;
    }
  }

  Future addCommentCallback(CommentCreationCallbackRequest commentData) async {
    try {
      CommentModel? response =
          await Provider.of<CommentRepository>(context, listen: false).addReply(
              widget.commentTreeId,
              ["${widget.commentDataModel.commentId ?? ''}"],
              commentData.comment ?? '',
              widget.userRole,
              widget.userName,
              widget.profileImageUrl,
              widget.designation,
              widget.profileStatus,
              ['${_user?.userId ?? ''}'],
              commentData.mentionedUser ?? []);
      if (response != null) {
        if (response.comment != null) {
          _commentReplies.add(response.comment?.commentId ?? "");
          if (mounted) {
            setState(() {
              _comments = [];
              _taggedUsers = [];
              _users = [];
              _hasMoreComments = _commentReplies.length > _comments.length;
              _currentPage = 0;
              _loadReply = true;
            });
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.mStaticReplyPostedText),
              backgroundColor: AppColors.positiveLight,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.mStaticErrorMessage),
              backgroundColor: AppColors.negativeLight,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.mStaticErrorMessage),
            backgroundColor: AppColors.negativeLight,
          ),
        );
      }
    } catch (err) {
      return err;
    }
  }

  Future addTagCallback(CommentCreationCallbackRequest commentData) async {
    try {
      CommentModel? response =
          await Provider.of<CommentRepository>(context, listen: false).addReply(
              widget.commentTreeId,
              ["${widget.parentId ?? ''}"],
              commentData.comment ?? '',
              widget.userRole,
              widget.userName,
              widget.profileImageUrl,
              widget.designation,
              widget.profileStatus,
              ['${_user?.userId ?? ''}'],
              commentData.mentionedUser ?? []);
      if (response != null) {
        if (response.comment != null) {
          widget.updateChildCallback(response.comment?.commentId ?? "");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.mStaticReplyPostedText),
              backgroundColor: AppColors.positiveLight,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.mStaticErrorMessage),
              backgroundColor: AppColors.negativeLight,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.mStaticErrorMessage),
            backgroundColor: AppColors.negativeLight,
          ),
        );
      }
    } catch (err) {
      return err;
    }
  }

  Future editCommentCallback(CommentCreationCallbackRequest commentData) async {
    try {
      var response =
          await Provider.of<CommentRepository>(context, listen: false)
              .editComment(
                  widget.commentTreeId,
                  widget.commentDataModel.commentId ?? '',
                  commentData.comment ?? '',
                  widget.userRole,
                  widget.userName,
                  widget.profileImageUrl,
                  widget.designation,
                  widget.profileStatus,
                  widget.isReply ? ['${_user?.userId ?? ''}'] : [],
                  commentData.mentionedUser ?? []);

      closeEdit();
      if (response != null) {
        CommentDataModel responseData = CommentDataModel.fromJson(response);
        widget.commentDataModel.commentData?.comment = await responseData.commentData?.comment ?? '';
        widget.commentDataModel.commentData?.mentionedUsers = await responseData.commentData?.mentionedUsers ?? [];
        widget.commentDataModel.lastUpdatedDate = await responseData.lastUpdatedDate;
        formatComment((widget.commentDataModel.commentData?.comment??''));
        _showReplySection.value = false;
        _showTagSection.value = false;
        if (mounted) {
          setState(() {});
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.mCommentUpdatedText),
            backgroundColor: AppColors.positiveLight,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.mStaticErrorMessage),
            backgroundColor: AppColors.negativeLight,
          ),
        );
      }
    } catch (err) {
      return err;
    }
  }

  void closeEdit() {
    _showInEditMode.value = false;
  }

  Future<void> _flagComment() async {
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
                    commentId: widget.commentDataModel.commentId ?? '',
                    reportReason: response,
                    onSubmitCallback: _reportComment,
                  ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  AppLocalizations.of(context)!.mStaticSomethingWrongTryLater),
              backgroundColor: AppColors.negativeLight,
            ),
          );
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
              subtitle: AppLocalizations.of(context)!.mCommentDeleteAlertMsg,
              primaryButtonText: AppLocalizations.of(context)!.mStaticDelete,
              onPrimaryButtonPressed: () {
                _deleteComment(
                    context, widget.commentDataModel.commentId ?? '');
                Navigator.of(cxt).pop();
              },
              secondaryButtonText: AppLocalizations.of(context)!.mStaticCancel,
              onSecondaryButtonPressed: () => Navigator.of(cxt).pop(),
            );
          });
    }
  }

  String getTaggedUserName(String userId) {
    return widget.taggedUsers
            .firstWhere(
              (user) => user.userId == userId,
              orElse: () => UserDataModel(
                  userId: '',
                  firstName: '',
                  userProfileImgUrl: '',
                  designation: '',
                  department: ''),
            )
            .firstName ??
        '';
  }

  UserDataModel getUserData(String userId) {
    return widget.users.firstWhere(
      (user) => user.userId == userId,
      orElse: () => UserDataModel(
        userId: '',
        firstName: '',
        userProfileImgUrl: '',
        designation: '',
        department: '',
        userProfileStatus: '',
      ),
    );
  }

  bool isLiked(String commentId) {
    return (widget.userLikedComments.contains(commentId));
  }

  bool isEdited(String createdDate, String lastUpdatedDate) {
    try {
      DateTime createdDatetime = DateTime.parse(createdDate);
      DateTime lastUpdatedDatetime = DateTime.parse(lastUpdatedDate);

      return !createdDatetime.isAtSameMomentAs(lastUpdatedDatetime);
    } catch (e) {
      return false;
    }
  }

  bool isAuthor(String userId) {
    return widget.courseDetails?.authors.any((item) {
          return (item.id?.toString().trim() == userId.trim());
        }) ??
        false;
  }

  bool isCurator(String userId) {
    return widget.courseDetails?.curators.any((item) {
          return (item.id?.toString().trim() == userId.trim());
        }) ??
        false;
  }

  Future<void> _loadUserData(String userId) async {
    UserDataModel fetchedUser = getUserData(userId);
    setState(() {
      _user = fetchedUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    return (_commentData != null &&
            (widget.commentDataModel.status ?? '').toLowerCase() != 'deleted')
        ? Stack(
            children: [
              _activeCommentView(),
              if ((widget.commentDataModel.status ?? '').toLowerCase() ==
                  'suspended')
                _suspendedMaskView(),
            ],
          )
        : Container();
  }

  Widget _activeCommentView() {
    return Container(
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: (widget.isReply)
              ? AppColors.replyBackgroundColor
              : AppColors.appBarBackground,
          border: Border.all(color: AppColors.grey16),
          borderRadius: BorderRadius.all(const Radius.circular(12.0).r),
        ),
        margin: EdgeInsets.symmetric(vertical: 8).r,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16).r,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Spacer(),
                      if (isEdited(widget.commentDataModel.createdDate ?? '',
                          widget.commentDataModel.lastUpdatedDate ?? ''))
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
                        _getDateNow(
                            widget.commentDataModel.lastUpdatedDate ?? ''),
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: AppColors.greys60,
                              fontWeight: FontWeight.w400,
                              fontSize: 12.sp,
                            ),
                      ),
                      if (widget.enableAction) _optionItems(),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 0).r,
                        child: CommentProfileImageWidget(
                            profilePic:
                                (_user?.userProfileImgUrl?.isNotEmpty == true
                                    ? _user!.userProfileImgUrl!
                                    : (_commentData?.commentSource?.userPic
                                                ?.isNotEmpty ==
                                            true
                                        ? _commentData!.commentSource!.userPic!
                                        : '')),
                            name: (_user?.firstName?.isNotEmpty == true
                                ? _user!.firstName!
                                : (_commentData?.commentSource?.userName
                                            ?.isNotEmpty ==
                                        true
                                    ? _commentData!.commentSource!.userName!
                                    : '')),
                            errorImageColor:
                                errorImageColor ?? AppColors.primaryOne,
                            iconSize: widget.isReply ? 32.w : 46.w),
                      ),
                      Container(
                        width: 0.65.sw,
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
                                        (_user?.firstName?.isNotEmpty == true
                                                ? _user!.firstName!
                                                : (_commentData
                                                            ?.commentSource
                                                            ?.userName
                                                            ?.isNotEmpty ==
                                                        true
                                                    ? _commentData!
                                                        .commentSource!
                                                        .userName!
                                                    : ''))
                                            .trim(),
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
                                    if ((_user?.userProfileStatus ?? '')
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
                                    if (isAuthor(_user?.userId ?? ''))
                                      Container(
                                        height: 20.w,
                                        alignment: Alignment.center,
                                        padding:
                                            EdgeInsets.symmetric(horizontal: 16)
                                                .r,
                                        margin:
                                            EdgeInsets.only(left: 4, right: 4)
                                                .r,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: AppColors.darkBlue),
                                            borderRadius: BorderRadius.all(
                                                const Radius.circular(50.0).r),
                                            color: AppColors.darkBlue
                                                .withValues(alpha: 0.1)),
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .mLearnCourseAuthor,
                                          style: GoogleFonts.lato(
                                            color: AppColors.darkBlue,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 10.0.sp,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    if (isCurator(_user?.userId ?? ''))
                                      Container(
                                        height: 20.w,
                                        alignment: Alignment.center,
                                        padding:
                                            EdgeInsets.symmetric(horizontal: 16)
                                                .r,
                                        margin:
                                            EdgeInsets.only(left: 4, right: 4)
                                                .r,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: AppColors.darkBlue),
                                            borderRadius: BorderRadius.all(
                                                const Radius.circular(50.0).r),
                                            color: AppColors.darkBlue
                                                .withValues(alpha: 0.1)),
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .mLearnCourseCurator,
                                          style: GoogleFonts.lato(
                                            color: AppColors.darkBlue,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 10.0.sp,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )
                                  ],
                                ),
                                if (((_user?.designation ?? '').isNotEmpty) &&
                                    (_user?.designation ?? '').toLowerCase() !=
                                        'null')
                                  Text(
                                    _user?.designation != null
                                        ? _user!.designation.toString().trim()
                                        : '',
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
                  ValueListenableBuilder(
                      valueListenable: _showInEditMode,
                      builder: (BuildContext context, bool showInEditMode,
                          Widget? child) {
                        return showInEditMode
                            ? Padding(
                                padding: EdgeInsets.only(top: 16).r,
                                child: AddCommentPage(
                                    text: _commentData?.comment ?? '',
                                    hintText: widget.isReply
                                        ? "${AppLocalizations.of(context)!.mStaticAddAReply}..."
                                        : "${AppLocalizations.of(context)!.mStaticAddAComment}...",
                                    emptyValidationText:
                                        AppLocalizations.of(context)!
                                            .mStaticCommentError,
                                    replyText: widget.isReply
                                        ? '${AppLocalizations.of(context)!.mStaticReplyingTo} ${_user?.firstName != null ? _user!.firstName.toString().trim() : ''}'
                                        : '',
                                    callback: editCommentCallback,
                                    updateCloseCallback: closeEdit,
                                    showSuffix: true,
                                    isReply: widget.isReply,
                                    maxLine: 5,
                                    height: 80.w,
                                    borderRadius: 8.r,
                                    isUpdate: true,
                                    enableUserTagging: widget.enableUserTagging,
                                    mentionedUsers: _commentData?.mentionedUsers??[],),
                              )
                            : ValueListenableBuilder(
                                valueListenable: _formattedComment,
                                builder: (BuildContext context, String formattedComment, Widget? child) {
                                  return formattedComment.isNotEmpty ? Padding(
                                    padding: EdgeInsets.only(top: 16).r,
                                    child: ViewMoreText(
                                      text: formattedComment,
                                      viewLessText: AppLocalizations.of(context)!
                                          .mStaticReadLess,
                                      viewMoreText: AppLocalizations.of(context)!
                                          .mStaticReadMore,
                                      maxLines: 5,
                                      style: GoogleFonts.lato(
                                        color: widget.isReply
                                            ? AppColors.greys60
                                            : AppColors.greys,
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
                                });
                      }),
                  _actionItems(),
                  if (!widget.isReply)
                    ValueListenableBuilder(
                        valueListenable: _showReplySection,
                        builder: (BuildContext context, bool showReplySection,
                            Widget? child) {
                          if ((showReplySection && _loadReply)) {
                            _loadReply = false;
                            _loadComments();
                          }
                          return showReplySection
                              ? _commentsReplies()
                              : Container();
                        })
                ],
              ),
            ),
          ],
        ));
  }

  Widget _suspendedMaskView() {
    return Positioned(
      bottom: 0.w,
      right: 0.w,
      left: 0.w,
      top: 0.w,
      child: Center(
        child: Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
            color: AppColors.grey08,
            border: Border.all(color: AppColors.grey16),
            borderRadius: BorderRadius.all(const Radius.circular(12.0).r),
          ),
          margin: EdgeInsets.symmetric(vertical: 8).r,
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
            alignment: Alignment.centerLeft,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.enableLike)
                    _voteDiscussionWidget(
                      animationController: _upVoteAnimationController,
                      count: (_commentData?.like ?? 0).toString(),
                      category: ((_commentData?.like ?? 0) == 1)
                          ? AppLocalizations.of(context)!.mStaticLike
                          : AppLocalizations.of(context)!.mStaticLikes,
                      activeColor: AppColors.darkBlue,
                      onVote: () {
                        if (!isVoting && widget.enableAction) {
                          _likeComment(
                              context,
                              widget.commentDataModel.commentId ?? 0,
                              false,
                              !(widget.commentDataModel.isLiked ?? false));
                        }
                      },
                    ),
                  if (!widget.isReply && widget.enableReply)
                    ValueListenableBuilder(
                        valueListenable: _showReplySection,
                        builder: (BuildContext context, bool showReplySection,
                            Widget? child) {
                          return _showReplyWidget(
                              image: Icon(
                                showReplySection
                                    ? Icons.arrow_drop_up_sharp
                                    : Icons.arrow_drop_down_sharp,
                                size: 24.w,
                                color: AppColors.greys60,
                              ),
                              category:
                                  "${(_commentReplies.length == 1) ? AppLocalizations.of(context)!.mDiscussReply : AppLocalizations.of(context)!.mDiscussReplies}",
                              count: _commentReplies.length,
                              animationController: _commentAnimationController);
                        }),
                  if ((widget.enableTag && widget.enableReply) &&
                      widget.enableAction)
                    _showTagWidget(
                        animationController: _commentAnimationController)
                ],
              ),
            ),
          ),
          if (!widget.enableAction)
            SizedBox(
              height: 16.w,
            ),
          if (widget.enableAction)
            ValueListenableBuilder(
                valueListenable: _showReplySection,
                builder: (BuildContext context, bool showReplySection,
                    Widget? child) {
                  return showReplySection
                      ? Padding(
                          padding: EdgeInsets.only(top: 16, bottom: 8).r,
                          child: AddCommentPage(
                            startingIcon: CommentProfileImageWidget(
                                profilePic: widget.profileImageUrl,
                                name: widget.userName,
                                errorImageColor:
                                    errorImageColor ?? AppColors.primaryOne,
                                iconSize: 32.w),
                            hintText: widget.enableAction
                                ? "${AppLocalizations.of(context)!.mStaticAddAReply}..."
                                : "${AppLocalizations.of(context)!.mStaticEnrollToReply}...",
                            emptyValidationText:
                                AppLocalizations.of(context)!.mStaticReplyError,
                            callback: addCommentCallback,
                            isReply: true,
                            replyText:
                                '${AppLocalizations.of(context)!.mStaticReplyingTo} ${_user?.firstName != null ? _user!.firstName.toString().trim() : ''}',
                            readOnly: !widget.enableAction,
                            maxLine: 1,
                            height: 48.w,
                            borderRadius: 50.r,
                            showSuffix: true,
                            enableUserTagging: widget.enableUserTagging
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
                  child: AddCommentPage(
                    startingIcon: CommentProfileImageWidget(
                        profilePic: widget.profileImageUrl,
                        name: widget.userName,
                        errorImageColor:
                            errorImageColor ?? AppColors.primaryOne,
                        iconSize: 32.w),
                    hintText: widget.enableAction
                        ? "${AppLocalizations.of(context)!.mStaticAddAReply}..."
                        : "${AppLocalizations.of(context)!.mStaticEnrollToReply}...",
                    emptyValidationText:
                        AppLocalizations.of(context)!.mStaticReplyError,
                    callback: addTagCallback,
                    isReply: true,
                    replyText:
                        '${AppLocalizations.of(context)!.mStaticReplyingTo} ${_user?.firstName != null ? _user!.firstName.toString().trim() : ''}',
                    readOnly: !widget.enableAction,
                    maxLine: 1,
                    height: 48.w,
                    borderRadius: 50.r,
                    showSuffix: true,
                    enableUserTagging: widget.enableUserTagging
                  ),
                )
              : Container();
        });
  }

  Widget _showReplyWidget(
      {required Widget image,
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
            color: (widget.enableAction) ? null : AppColors.grey08),
        child: Row(
          children: [
            ScaleTransition(scale: animationController, child: image),
            Padding(
              padding: EdgeInsets.only(left: 4.0, right: 8).w,
              child: Text(
                "${category} (${count.toString()})",
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
            color: (widget.enableAction) ? null : AppColors.grey08),
        child: Row(
          children: [
            ScaleTransition(
              scale: animationController,
              child: Icon(
                Icons.messenger_outlined,
                size: 24.w,
                color: AppColors.darkBlue,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 4.0, right: 8).w,
              child: Text(
                AppLocalizations.of(context)!.mDiscussReply,
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

  Widget _commentsReplies() {
    return FutureBuilder(
      future: _commentsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }
        return Wrap(
          alignment: WrapAlignment.start,
          children: [
            Wrap(
              children: [
                if ((_comments.isNotEmpty) && !_isLoading)
                  _commentsListView(_comments, _taggedUsers, _users),
                if (_isLoading)
                  CommentViewSkeleton(
                    itemCount: 3,
                  ),
                if (_hasMoreComments && !_isLoading)
                  GestureDetector(
                    onTap: () {
                      _loadComments();
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

  Widget _commentsListView(List<CommentDataModel> commentList,
      List<UserDataModel> taggedUsers, List<UserDataModel> users) {
    return (commentList.isNotEmpty)
        ? AnimationLimiter(
            child: Column(
              children: List.generate(
                commentList.length,
                (index) {
                  _comments[index].isLiked =
                      isLiked(commentList[index].commentId ?? '');
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 475),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: CommentListItemWidget(
                          commentDataModel: commentList[index],
                          taggedUsers: taggedUsers,
                          users: users,
                          userLikedComments: widget.userLikedComments,
                          courseDetails: widget.courseDetails,
                          isReply: true,
                          parentId: widget.commentDataModel.commentId ?? '',
                          userName: widget.userName,
                          userId: widget.userId,
                          profileImageUrl: widget.profileImageUrl,
                          commentTreeId: widget.commentTreeId,
                          userRole: widget.userRole,
                          designation: widget.designation,
                          profileStatus: widget.profileStatus,
                          replies: [],
                          enableLike: widget.enableLike,
                          enableReply: widget.enableReply,
                          enableTag: true,
                          enableReport: widget.enableReport,
                          enableAction: widget.enableAction,
                          enableEdit: widget.enableEdit,
                          enableDelete: widget.enableDelete,
                          updateChildCallback: updateChild,
                          deleteCommentCallback: deleteCommentCallback,
                          likeCallback: widget.likeCallback,
                          entityType: widget.entityType,
                          entityId: widget.entityId,
                          workflow: widget.workflow,
                          enableUserTagging: widget.enableUserTagging
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
              color: (widget.enableAction) ? null : AppColors.grey08),
          child: Row(
            children: [
              ScaleTransition(
                  scale: animationController,
                  child: Icon(
                    Icons.thumb_up,
                    size: 24.w,
                    color: (widget.commentDataModel.isLiked ?? false)
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
            if (widget.enableReport && (_user?.userId ?? "") != widget.userId)
              _popUpMenuItem(
                  value: 1,
                  text: AppLocalizations.of(context)!.mStaticFlag,
                  icon: Icons.flag_outlined,
                  iconColor: AppColors.primaryOne),
            if (widget.enableEdit && (_user?.userId ?? "") == widget.userId)
              _popUpMenuItem(
                  value: 2,
                  text: AppLocalizations.of(context)!.mStaticEdit,
                  icon: Icons.edit,
                  iconColor: AppColors.darkBlue),
            if (widget.enableDelete && (_user?.userId ?? "") == widget.userId)
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
              _showInEditMode.value = true;
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
}
