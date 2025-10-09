import 'dart:async';
import 'dart:math';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/ui/widgets/comment_section/model/comment_tree_data_model.dart';
import 'package:karmayogi_mobile/ui/widgets/comment_section/pages/widgets/add_comment_page.dart';
import 'package:karmayogi_mobile/ui/widgets/comment_section/pages/widgets/comment_profile_image_widget.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../../../../constants/_constants/color_constants.dart';
import '../model/comment_data_model.dart';
import '../model/comment_model.dart';
import '../model/comment_request.dart';
import '../model/user_data_model.dart';
import '../repositories/comment_repository.dart';
import 'widgets/comment_list_item_widget.dart';
import 'widgets/comment_view_skeleton.dart';

class CommentsView extends StatefulWidget {
  final CommentRequest commentRequest;

  CommentsView({Key? key, required this.commentRequest}) : super(key: key);
  _CommentsViewState createState() => _CommentsViewState();
}

class _CommentsViewState extends State<CommentsView>
    with TickerProviderStateMixin {
  Future<CommentModel?>? _commentsFuture;
  CommentModel? commentResponseData;
  CommentTreeData? commentTreeData;
  List<String> _userLikedComments = [];

  bool _isLoading = false;
  bool _addingComment = false;
  Color? errorImageColor =
      AppColors.networkBg[Random().nextInt(AppColors.networkBg.length)];
  String _commentTreeId = '';
  String _tagCommentId = '';
  int pageNo = 1;

  @override
  void initState() {
    super.initState();
    if (widget.commentRequest.tagCommentId != null) {
      _tagCommentId = widget.commentRequest.tagCommentId ?? '';
    }
    _loadComments();
  }

  Future<void> _loadComments() async {
    _commentsFuture = _getComments(context);
  }

  @override
  void didUpdateWidget(covariant CommentsView oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  Future<CommentModel?> _getComments(context) async {
    try {
      _isLoading = true;
      if (pageNo == 1) {
        CommentTreeData? commentTreeDataResponse = await _getCommentsTree(context);
        if (commentTreeDataResponse != null) {
          commentTreeData = commentTreeDataResponse;
          if ((commentTreeData?.comments??[]).isNotEmpty) {
            CommentModel? response =
            await Provider.of<CommentRepository>(context, listen: false)
                .getComments(
                _commentTreeId,
                widget.commentRequest.entityId,
                widget.commentRequest.entityType,
                widget.commentRequest.workflow,
                pageNo);
            if (response != null) {
              _commentTreeId = response.commentTreeId ?? "";

              /// for comment details: display single comment and its replies
              if (_tagCommentId.isNotEmpty) {
                CommentModel? singleCommentData = await Provider.of<CommentRepository>(context, listen: false).getReply([_tagCommentId]);
                commentResponseData = singleCommentData;
              } else {
                commentResponseData = response;
              }
              _userLikedComments = await _likedComments();
            }
          }
        }
      } else {
        CommentModel? response =
            await Provider.of<CommentRepository>(context, listen: false)
                .getComments(
                    _commentTreeId,
                    widget.commentRequest.entityId,
                    widget.commentRequest.entityType,
                    widget.commentRequest.workflow,
                    pageNo);

        List<CommentDataModel>? comments = commentResponseData?.comments ?? [];
        List<UserDataModel>? taggedUsers =
            commentResponseData?.taggedUsers ?? [];
        List<UserDataModel>? users = commentResponseData?.users ?? [];
        if (response != null) {
          comments.addAll(response.comments ?? []);
          taggedUsers.addAll(response.taggedUsers ?? []);
          users.addAll(response.users ?? []);
          CommentModel commentModel = CommentModel(
              commentCount: response.commentCount,
              comments: comments,
              taggedUsers: taggedUsers,
              users: users);
          commentResponseData = commentModel;
        }
      }
      if (commentResponseData != null) {
        _isLoading = false;
        _addingComment = false;
        return Future.value(commentResponseData);
      } else {
        _isLoading = false;
        _addingComment = false;
        return null;
      }
    } catch (err) {
      _isLoading = false;
      _addingComment = false;
      return null;
    }
  }

  Future<CommentTreeData?> _getCommentsTree(context) async {
    try {
      CommentTreeData? response = await Provider.of<CommentRepository>(context, listen: false).getCommentsTree(
          widget.commentRequest.entityId,
          widget.commentRequest.entityType,
          widget.commentRequest.workflow);
      return response;
    } catch (err) {
      return null;
    }
  }

  Future<List<String>> _likedComments() async {
    List<String> response = [];
    try {
      response = await Provider.of<CommentRepository>(context, listen: false)
          .getLikedComments(widget.commentRequest.entityId);
      return response;
    } catch (err) {
      return [];
    }
  }

  _loadMore() {
    if (commentResponseData != null) {
      if ((commentResponseData?.comments ?? []).length <
          (commentResponseData?.commentCount ?? 0)) {
        setState(() {
          pageNo = pageNo + 1;
          _loadComments();
        });
      }
    }
  }

  Future addCommentCallback(CommentCreationCallbackRequest commentData) async {
    try {
      var _response = '';
      if (_commentTreeId == '') {
        _response = await Provider.of<CommentRepository>(context, listen: false)
            .addFirstComment(
                widget.commentRequest.entityType,
                widget.commentRequest.entityId,
                widget.commentRequest.workflow,
                commentData.comment ?? '',
                widget.commentRequest.userRole ?? '',
                widget.commentRequest.userName ?? '',
                widget.commentRequest.userProfileImage ?? '',
                widget.commentRequest.designation ?? '',
                widget.commentRequest.profileStatus ?? '',
                commentData.mentionedUser ?? []);
      } else {
        _response = await Provider.of<CommentRepository>(context, listen: false)
            .addNewComment(
                _commentTreeId,
                [],
                commentData.comment ?? '',
                widget.commentRequest.userRole ?? '',
                widget.commentRequest.userName ?? '',
                widget.commentRequest.userProfileImage ?? '',
                widget.commentRequest.designation ?? '',
                widget.commentRequest.profileStatus ?? '',
                commentData.mentionedUser ?? []);
      }
      if (_response == 'ok') {
        setState(() {
          pageNo = 1;
          _addingComment = true;
          _loadComments();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context)!.mStaticCommentPostedText),
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
      FocusScope.of(context).unfocus();
    } catch (err) {
      return err;
    }
  }

  List<String> _getReplies(String commentId) {
    List<CommentDataModel>? comments = commentTreeData?.comments ?? [];
    List<String> relyList = [];
    if (comments.isNotEmpty) {
      for (var comment in comments) {
        if (comment.commentId != null &&
            comment.commentId.toString() == commentId) {
          if (comment.children != null) {
            relyList = comment.children!
                .map((child) => child.commentId)
                .where((id) => id != null)
                .map((id) => id!)
                .toList();
          }
          break;
        }
      }
    }
    return relyList;
  }

  bool isLiked(String commentId) {
    return (_userLikedComments.contains(commentId));
  }

  Future<void> likeCallback(Map<String, dynamic> likeData) async {
    if (likeData.containsKey('isLike') && likeData.containsKey('commentId')) {
      bool isLike = likeData['isLike'] ?? false;
      String commentId = likeData['commentId'];

      if (isLike) {
        if (!_userLikedComments.contains(commentId)) {
          _userLikedComments.add(commentId);
        }
      } else {
        _userLikedComments.remove(commentId);
      }
    }
  }

  Future<void> deleteCommentCallback(String commentId) async {
    try {
      if (commentResponseData?.comments != null &&
          (commentResponseData!.comments ?? []).isNotEmpty) {
        (commentResponseData?.comments ?? []).remove(commentId);
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() async {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          if (!_isLoading) {
            _loadMore();
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
          if (widget.commentRequest.showHeading ?? false)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0).w,
              child: Text(
                AppLocalizations.of(context)!.mStaticComments,
                style: GoogleFonts.lato(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          (_tagCommentId.isEmpty)
              ? _postCommentView()
              : _backToAllCommentAction(),
          FutureBuilder(
            future: _commentsFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return (_isLoading)
                    ? CommentViewSkeleton(itemCount: (_tagCommentId.isNotEmpty) ? 1 : 10,)
                    : Container();
              }
              return Wrap(
                alignment: WrapAlignment.start,
                children: [
                  if ((commentResponseData?.comments ?? []).isNotEmpty &&
                      !_addingComment)
                    _commentsListView(),
                  if (_isLoading)
                    CommentViewSkeleton(
                      itemCount: (_tagCommentId.isNotEmpty) ? 1 : 10,
                    ),
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

  Widget _postCommentView() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16).w,
      child: AddCommentPage(
        startingIcon: CommentProfileImageWidget(
            profilePic: widget.commentRequest.userProfileImage ?? '',
            name: widget.commentRequest.userName ?? '',
            errorImageColor: errorImageColor ?? AppColors.primaryOne,
            iconSize: 40.w),
        hintText: widget.commentRequest.enableAction
            ? "${AppLocalizations.of(context)!.mStaticAddAComment}..."
            : "${AppLocalizations.of(context)!.mStaticEnrollToComment}...",
        emptyValidationText: AppLocalizations.of(context)!.mStaticCommentError,
        callback: addCommentCallback,
        showSuffix: true,
        isReply: false,
        readOnly: !widget.commentRequest.enableAction,
        maxLine: 1,
        height: 55.w,
        borderRadius: 50.r,
        enableUserTagging: widget.commentRequest.enableUserTagging
      ),
    );
  }

  Widget _commentsListView() {
    return AnimationLimiter(
      child: Column(
        children: List.generate(
          (commentResponseData?.comments ?? []).length,
          (index) {
            (commentResponseData?.comments ?? [])[index].isLiked = isLiked(
                (commentResponseData?.comments ?? [])[index].commentId ?? '');
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 475),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: CommentListItemWidget(
                    commentDataModel:
                        (commentResponseData?.comments ?? [])[index],
                    taggedUsers: commentResponseData?.taggedUsers ?? [],
                    users: commentResponseData?.users ?? [],
                    userLikedComments: _userLikedComments,
                    courseDetails: commentResponseData?.courseDetails,
                    userName: widget.commentRequest.userName ?? '',
                    userId: widget.commentRequest.userId ?? '',
                    profileImageUrl:
                        widget.commentRequest.userProfileImage ?? '',
                    commentTreeId: _commentTreeId,
                    userRole: widget.commentRequest.userRole ?? '',
                    designation: widget.commentRequest.designation ?? '',
                    profileStatus: widget.commentRequest.profileStatus ?? '',
                    replies: _getReplies(
                        (commentResponseData?.comments ?? [])[index]
                                .commentId ??
                            ''),
                    enableLike: widget.commentRequest.enableLike,
                    enableReport: widget.commentRequest.enableReport,
                    enableReply: widget.commentRequest.enableReply,
                    enableEdit: widget.commentRequest.enableEdit,
                    enableDelete: widget.commentRequest.enableDelete,
                    updateChildCallback: (value) {},
                    deleteCommentCallback: deleteCommentCallback,
                    likeCallback: likeCallback,
                    enableAction: widget.commentRequest.enableAction,
                    entityType: widget.commentRequest.entityType,
                    entityId: widget.commentRequest.entityId,
                    workflow: widget.commentRequest.workflow,
                    enableUserTagging: widget.commentRequest.enableUserTagging
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _backToAllCommentAction() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8).r,
      child: GestureDetector(
        onTap: () {
          if (widget.commentRequest.backToAllCommentsCallback != null) {
            widget.commentRequest.backToAllCommentsCallback!();
          }
          setState(() {
            _tagCommentId = '';
            pageNo = 1;
            _addingComment = true;
            _loadComments();
          });
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
                padding: EdgeInsets.only(right: 4).w,
                child: Icon(
                    Icons.arrow_back_outlined,
                    size: 18.w, color: AppColors.darkBlue
                )
            ),
            Text(
              AppLocalizations.of(context)!.mCommentBackToAllComments,
              style: GoogleFonts.lato(
                color: AppColors.darkBlue,
                fontWeight: FontWeight.w400,
                fontSize: 14.0.sp,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
