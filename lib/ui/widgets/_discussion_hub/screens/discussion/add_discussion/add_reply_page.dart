import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html_editor_enhanced/utils/shims/dart_ui_real.dart';
import 'package:igot_ui_components/ui/components/microsite_image_view.dart';
import 'package:karmayogi_mobile/ui/widgets/_common/page_loader.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/helper/discussion_const.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/helper/discussion_helper.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/repositories/discussion_repository.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/discussion/add_discussion/_models/media_upload_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/discussion/add_discussion/_models/tag_user_data_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/discussion/add_discussion/_widgets/add_media_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/discussion/add_discussion/_widgets/reply_input_field.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/discussion/discussion_view/_models/discussion_model.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:provider/provider.dart';
import '../../../../../../../../constants/_constants/color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddReplyPage extends StatefulWidget {
  final String parentDiscussionId;
  final String? parentPostId;
  final String communityId;
  final Widget? startingIcon;
  final String hintText;
  final bool readOnly;
  final String replyText;
  final Function(DiscussionItemData) callback;
  final Function? updateCloseCallback;
  final bool isUpdate;
  final DiscussionItemData? discussionItemData;
  final Color cardBackgroundColor;
  final bool isAnswerPostReply;

  AddReplyPage(
      {required this.parentDiscussionId,
      this.parentPostId,
      required this.communityId,
      this.startingIcon,
      required this.hintText,
      this.readOnly = false,
      this.replyText = '',
      required this.callback,
      this.updateCloseCallback,
      this.isUpdate = false,
      this.discussionItemData,
      required this.cardBackgroundColor,
      required this.isAnswerPostReply});
  @override
  AddReplyPageState createState() => AddReplyPageState();
}

class AddReplyPageState extends State<AddReplyPage> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocus = FocusNode();
  ValueNotifier<bool> _isLoading = ValueNotifier(false);
  ValueNotifier<bool> _isTextAdded = ValueNotifier(false);
  ValueNotifier<bool> _emojiVisibilityNotifier = ValueNotifier<bool>(false);
  ValueNotifier<List<MediaUploadModel>> _selectedImages =
      ValueNotifier<List<MediaUploadModel>>([]);
  List<String> _selectedMediaType = [];
  PersistentBottomSheetController? _persistentBottomSheetController;
  String? _discussionId;
  List<TagUserDataModel>? mentionedUserList = [];
  List<Map<String, String>> _mentionedUsers = [];

  Future<void> addFileCallBack(Map<String, dynamic> selectedMedia) async {
    MediaSource fileType = await selectedMedia["filetype"];
    File file = await selectedMedia["file"];
    setState(() {
      if (fileType == MediaSource.image) {
        if (!_selectedMediaType.contains(MediaConst.image))
          _selectedMediaType.add(MediaConst.image);
        _selectedImages.value.add(MediaUploadModel(
            file: file, isUploaded: false, isErrorFile: false));
      }
    });
    _isTextAdded.value = ((_commentController.text.trim()).isNotEmpty ||
        _selectedImages.value.isNotEmpty);
  }

  resetWidget() async {
    FocusScope.of(context).unfocus();
    _discussionId = null;
    _commentController.clear();
    setState(() {
      _selectedImages.value.clear();
    });
  }

  submitComment() async {
    FocusScope.of(context).unfocus();
    if (_isLoading.value == false) {
      _saveDiscussion(context, discussionId: _discussionId);
    }
  }

  String? validateDescription(String description) {
    if ((description.isEmpty) && _selectedImages.value.isEmpty) {
      return AppLocalizations.of(context)?.mDiscussionPostMinLengthText;
    }

    if ((description.length < 3) && _selectedImages.value.isEmpty) {
      return AppLocalizations.of(context)?.mDiscussionPostMinLengthText;
    }

    if (description.length > 1000) {
      return AppLocalizations.of(context)?.mDiscussionPostMaxLengthText;
    }

    return null;
  }

  bool hasMediaFiles() {
    return _selectedImages.value.isNotEmpty;
  }

  Future<Map<String, List<String>>> getMediaCategory() async {
    Map<String, List<String>> _mediaCategory = {};

    if (_selectedImages.value.isNotEmpty) {
      List<String> mediaUrls = await _getMediaUrls(_selectedImages.value);
      if (mediaUrls.isNotEmpty) _mediaCategory[MediaConst.image] = mediaUrls;
    }
    return _mediaCategory;
  }

  List<String> _getMediaUrls(List<MediaUploadModel> mediaList) {
    return mediaList
        .where((element) => element.isUploaded && element.fileUrl != null)
        .map((element) => element.fileUrl ?? '')
        .toList();
  }

  String _getFileName(String filePath) {
    return filePath.split('/').last.split('\\').last;
  }

  Future<void> _saveDiscussion(BuildContext context,
      {String? discussionId}) async {
    String? validationMessage = validateDescription(_commentController.text);

    if (validationMessage != null) {
      Helper.showSnackBarMessage(
          context: context,
          text: "${validationMessage}",
          bgColor: AppColors.negativeLight);
      return;
    }

    _isLoading.value = true;
    try {
      bool _errorInFileUpload = false;
      DiscussionItemData? response;
      if (discussionId != null) {
        if (hasMediaFiles()) {
          if (_selectedImages.value.isNotEmpty) {
            await Future.wait(
              _selectedImages.value.asMap().entries.map((entry) async {
                if (!(entry.value.isUploaded)) {
                  String fileUrl = await uploadMedia(entry.value.file!,
                      discussionId, widget.communityId, entry.key);
                  if (fileUrl.isNotEmpty) {
                    setState(() {
                      _selectedImages.value[entry.key].fileUrl = fileUrl;
                      _selectedImages.value[entry.key].isUploaded = true;
                    });
                  } else {
                    setState(() {
                      _selectedImages.value[entry.key].isErrorFile = true;
                    });
                    Helper.showSnackBarMessage(
                        context: context,
                        text:
                            "${AppLocalizations.of(context)?.mDiscussionPostUploadError} ${_getFileName(entry.value.file!.path)}",
                        bgColor: AppColors.negativeLight);
                    _errorInFileUpload = true;
                  }
                }
              }),
            );
          }
        }
        if (_errorInFileUpload) {
          _isLoading.value = false;
          return;
        }
        ;

        /// Update answer post
        Map<String, List<String>> _mediaCategory = await getMediaCategory();
        response =
            await Provider.of<DiscussionRepository>(context, listen: false)
                .updateAnswerPost(
                    answerPostId: discussionId,
                    description: _commentController.text,
                    categoryType: _selectedMediaType,
                    mediaCategory: _mediaCategory,
                    isInitialUpload: false,
                    isAnswerPostReply: widget.isAnswerPostReply,
                    mentionedUsers: _mentionedUsers);
      } else {
        /// create answer post
        if (widget.isAnswerPostReply) {
          response =
              await Provider.of<DiscussionRepository>(context, listen: false)
                  .createAnswerPost(
                      parentDiscussionId: widget.parentPostId ?? '',
                      parentAnswerPostId: widget.parentDiscussionId,
                      type: PostTypeConst.answerPostReply,
                      description: _commentController.text,
                      communityId: widget.communityId,
                      isAnswerPostReply: true,
                      mentionedUsers: _mentionedUsers);
        } else {
          response =
              await Provider.of<DiscussionRepository>(context, listen: false)
                  .createAnswerPost(
                      parentDiscussionId: widget.parentDiscussionId,
                      type: PostTypeConst.answerPost,
                      description: _commentController.text,
                      communityId: widget.communityId,
                      isAnswerPostReply: false,
                      mentionedUsers: _mentionedUsers);
        }
      }

      if (response != null) {
        if ((discussionId == null) && hasMediaFiles()) {
          Helper.showSnackBarMessage(
              context: context,
              text:
                  AppLocalizations.of(context)?.mDiscussionUploadingMedia ?? '',
              bgColor: AppColors.positiveLight);
          _discussionId = response.discussionId;
          await _saveDiscussionMedia(context, response.discussionId ?? '');
        } else {
          resetWidget();
          widget.callback(response);
          if (widget.updateCloseCallback != null) widget.updateCloseCallback!();
          Helper.showSnackBarMessage(
              context: context,
              text:
                  AppLocalizations.of(context)?.mStaticCommentPostedText ?? '',
              bgColor: AppColors.positiveLight);
        }
      } else {
        Helper.showSnackBarMessage(
            context: context,
            text: AppLocalizations.of(context)?.mStaticErrorMessage ?? '',
            bgColor: AppColors.negativeLight);
      }
    } catch (err) {
      Helper.showSnackBarMessage(
          context: context,
          text: AppLocalizations.of(context)?.mStaticErrorMessage ?? '',
          bgColor: AppColors.negativeLight);
    }

    _isLoading.value = false;
  }

  Future<String> uploadMedia(File selectedFile, String discussionId,
      String communityId, int index) async {
    try {
      var response =
          await Provider.of<DiscussionRepository>(context, listen: false)
              .uploadMedia(selectedFile, discussionId, communityId);
      if (response.runtimeType == int) {
        return '';
      } else {
        return DiscussionHelper.convertPortalImageUrl(response);
      }
    } catch (err) {
      return '';
    }
  }

  Future<void> _saveDiscussionMedia(
      BuildContext context, String discussionId) async {
    bool _errorInFileUpload = false;
    try {
      if (_selectedImages.value.isNotEmpty) {
        await Future.wait(
          _selectedImages.value.asMap().entries.map((entry) async {
            if (!(entry.value.isUploaded)) {
              String fileUrl = await uploadMedia(entry.value.file!,
                  discussionId, widget.communityId, entry.key);
              if (fileUrl.isNotEmpty) {
                setState(() {
                  _selectedImages.value[entry.key].fileUrl = fileUrl;
                  _selectedImages.value[entry.key].isUploaded = true;
                });
              } else {
                setState(() {
                  _selectedImages.value[entry.key].isErrorFile = true;
                });
                Helper.showSnackBarMessage(
                    context: context,
                    text:
                        "${AppLocalizations.of(context)?.mDiscussionPostUploadError} ${_getFileName(entry.value.file!.path)}",
                    bgColor: AppColors.negativeLight);
                _errorInFileUpload = true;
              }
            }
          }),
        );
      }

      if (!_errorInFileUpload) {
        DiscussionItemData? response;

        /// Update answer post
        Map<String, List<String>> _mediaCategory = await getMediaCategory();
        response =
            await Provider.of<DiscussionRepository>(context, listen: false)
                .updateAnswerPost(
                    answerPostId: discussionId,
                    description: _commentController.text,
                    categoryType: _selectedMediaType,
                    mediaCategory: _mediaCategory,
                    isInitialUpload: true,
                    isAnswerPostReply: widget.isAnswerPostReply,
                    mentionedUsers: _mentionedUsers);
        if (response != null) {
          resetWidget();
          widget.callback(response);
          if (widget.updateCloseCallback != null) widget.updateCloseCallback!();
          Helper.showSnackBarMessage(
              context: context,
              text:
                  AppLocalizations.of(context)?.mStaticCommentPostedText ?? '',
              bgColor: AppColors.positiveLight);
        } else {
          Helper.showSnackBarMessage(
              context: context,
              text: AppLocalizations.of(context)?.mStaticErrorMessage ?? '',
              bgColor: AppColors.negativeLight);
        }
      }
    } catch (err) {
      Helper.showSnackBarMessage(
          context: context,
          text: AppLocalizations.of(context)?.mStaticErrorMessage ?? '',
          bgColor: AppColors.negativeLight);
    }
  }

  @override
  void initState() {
    super.initState();
    if ((widget.discussionItemData?.mentionedUsers ?? []).isNotEmpty) {
      mentionedUserList = widget.discussionItemData?.mentionedUsers ?? [];
    }
    _commentController.addListener(_updateTextStatus);
    loadData();
    if (widget.isUpdate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(_commentFocus);
      });
    }
  }

  void loadData() {
    if (widget.discussionItemData != null) {
      _discussionId = widget.discussionItemData?.discussionId;
      _commentController.text = widget.discussionItemData?.description ?? '';
      if (widget.discussionItemData?.mediaCategory != null) {
        if ((widget.discussionItemData?.mediaCategory?.image ?? [])
            .isNotEmpty) {
          _selectedImages.value = _getMediaData(
              widget.discussionItemData?.mediaCategory?.image ?? []);
          _selectedMediaType.add(MediaConst.image);
        }
      }
    }
  }

  List<MediaUploadModel> _getMediaData(List<String> mediaList) {
    List<MediaUploadModel> _mediaList = [];
    try {
      mediaList.forEach((url) {
        _mediaList.add(MediaUploadModel(
          isUploaded: true,
          isErrorFile: false,
          fileUrl: url,
        ));
      });
      return _mediaList;
    } catch (err) {
      return _mediaList;
    }
  }

  void _updateTextStatus() {
    _isTextAdded.value = ((_commentController.text.trim()).isNotEmpty ||
        _selectedImages.value.isNotEmpty);
  }

  bool isMediaUploadEnabled(MediaSource selectedMediaType) {
    switch (selectedMediaType) {
      case MediaSource.image:
        return (_selectedImages.value.length < maxImageUploadCount);
      default:
        return false;
    }
  }

  void _handleTaggedUsers(List<TagUserDataModel> users) {
    mentionedUserList = users;
    _mentionedUsers = users
        .map((u) => {
              "userId": u.userId ?? '',
              "userName": u.userName ?? '',
            })
        .toList();
  }

  @override
  void dispose() {
    _dismissEmojiPicker();
    _commentController.removeListener(_updateTextStatus);
    _commentController.dispose();
    _commentFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _dismissEmojiPicker();
      },
      child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: widget.cardBackgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(12).r),
          ),
          child: Column(
            children: [
              if (widget.replyText != '') _replyToView(),
              _commentWidget(),
            ],
          )),
    );
  }

  Widget _replyToView() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.only(left: 16, right: 16, top: 16).r,
      child: Text(
        widget.replyText,
        style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: AppColors.darkBlue,
              fontWeight: FontWeight.w600,
              fontSize: 12.sp,
            ),
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _commentWidget() {
    return Container(
        margin: widget.isUpdate
            ? EdgeInsets.only(bottom: 0).r
            : EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16).r,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          curve: Curves.bounceInOut,
          child: ValueListenableBuilder(
              valueListenable: _isTextAdded,
              builder: (BuildContext context, bool isTextAdded, Widget? child) {
                return ValueListenableBuilder(
                    valueListenable: _selectedImages,
                    builder: (BuildContext context,
                        List<MediaUploadModel> mediaList, Widget? child) {
                      return Row(
                        crossAxisAlignment:
                            (mediaList.isNotEmpty || isTextAdded)
                                ? CrossAxisAlignment.start
                                : CrossAxisAlignment.center,
                        children: [
                          if (widget.startingIcon != null)
                            widget.startingIcon ?? SizedBox(),
                          Expanded(
                            child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 8).r,
                                decoration: BoxDecoration(
                                    border:
                                        Border.all(color: AppColors.darkBlue),
                                    borderRadius: BorderRadius.all(
                                        Radius.circular((mediaList.isNotEmpty ||
                                                    isTextAdded)
                                                ? 20
                                                : 50)
                                            .r),
                                    color: AppColors.appBarBackground),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                            (mediaList.isNotEmpty ||
                                                    isTextAdded)
                                                ? 20
                                                : 50)
                                        .r,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: addReplyView(
                                              isTextAdded, mediaList),
                                        ),
                                        if (mediaList.isEmpty && (!isTextAdded))
                                          _mediaActionWidget(),
                                      ],
                                    ))),
                          ),
                        ],
                      );
                    });
              }),
        ));
  }

  Widget addReplyView(bool isTextAdded, List<MediaUploadModel> mediaList) {
    return Column(
      children: [
        descriptionView(),
        if (mediaList.isNotEmpty)
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            curve: Curves.bounceInOut,
            child: _imageView(mediaList),
          ),
        if (mediaList.isNotEmpty || isTextAdded)
          AnimatedContainer(
              duration: Duration(milliseconds: 200),
              curve: Curves.bounceInOut,
              child: _ActionItemsWidget(isTextAdded)),
      ],
    );
  }

  Widget descriptionView() {
    return Container(
      padding: EdgeInsets.only(left: 4, right: 4).r,
      child: ReplyInputField(
        keyboardType: TextInputType.multiline,
        controller: _commentController,
        focusNode: _commentFocus,
        hintText: widget.hintText,
        onTap: _dismissEmojiPicker,
        readOnly: false,
        onUserTagged: _handleTaggedUsers,
        mentionedUserList: mentionedUserList,
      ),
    );
  }

  Widget _ActionItemsWidget(bool isTextAdded) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8).r,
        decoration: BoxDecoration(
            border: Border.all(color: AppColors.grey08),
            color: Color.fromRGBO(244, 246, 250, 1)),
        child: Column(
          children: [
            _descriptionInfoView(),
            Row(
              children: [
                _mediaActionWidget(),
                if (widget.isUpdate) _closeEdit(),
                Spacer(),
                AnimatedContainer(
                  height: 32.w,
                  duration: Duration(milliseconds: 200),
                  curve: Curves.bounceInOut,
                  child: ValueListenableBuilder(
                      valueListenable: _isTextAdded,
                      builder:
                          (BuildContext context, bool isTextAdded, Widget? child) {
                        return _actionButton(isTextAdded);
                      }),
                ),
              ],
            ),
          ],
        ));
  }

  Widget _mediaActionWidget() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 0).r,
          child: GestureDetector(
            onTap: () {
              if (!widget.readOnly) _openEmojiPicker(context);
            },
            child: Icon(
              Icons.sentiment_satisfied_outlined,
              size: 24.w,
              color: AppColors.primaryOne,
            ),
          ),
        ),
        AddMediaWidget(
          parentContext: context,
          uploadCallback: (selectedMedia) {
            FocusScope.of(context).unfocus();
            addFileCallBack(selectedMedia);
          },
          enableImageUpload: isMediaUploadEnabled(MediaSource.image),
          enableVideoUpload: false,
          enableFileUpload: false,
          allowAllMedia: false,
        ),
      ],
    );
  }

  Widget _closeEdit() {
    return InkWell(
      onTap: () {
        if (widget.updateCloseCallback != null) {
          widget.updateCloseCallback!();
        }
      },
      child: Container(
        width: 24.w,
        height: 24.w,
        decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.grey08,
            ),
            borderRadius: BorderRadius.all(const Radius.circular(50.0).r),
            color: AppColors.grey08),
        child: Icon(
          Icons.close_sharp,
          color: AppColors.disabledTextGrey,
          size: 16.w,
        ),
      ),
    );
  }

  Widget _actionButton(bool isTextAdded) {
    return ElevatedButton(
        onPressed: () async {
          if (isTextAdded) submitComment();
        },
        child: ValueListenableBuilder(
            valueListenable: _isLoading,
            builder: (BuildContext context, bool loading, Widget? child) {
              return Container(
                width: 28.w,
                alignment: Alignment.center,
                child: loading
                    ? Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 8).w,
                        child: SizedBox(
                            width: 12.w,
                            height: 12.w,
                            child: Center(
                              child: PageLoader(
                                strokeWidth: 2,
                                isLightTheme: false,
                              ),
                            )),
                      )
                    : Icon(
                        Icons.send_rounded,
                        size: 24.w,
                        color: AppColors.appBarBackground,
                      ),
              );
            }),
        style: ElevatedButton.styleFrom(
          backgroundColor: isTextAdded ? AppColors.darkBlue : AppColors.grey16,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(63).r,
          ),
        ));
  }

  void _openEmojiPicker(BuildContext context) {
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    if (!_emojiVisibilityNotifier.value) {
      _persistentBottomSheetController = Scaffold.of(context).showBottomSheet(
        (context) {
          return Container(
            height: 300.w,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8).w,
            color: AppColors.lightGreyBluish,
            alignment: Alignment.bottomCenter,
            child: _emojiView(),
          );
        },
      );
      setState(() {
        _emojiVisibilityNotifier.value = true;
      });
      _persistentBottomSheetController!.closed.whenComplete(() {
        setState(() {
          _emojiVisibilityNotifier.value = false;
        });
      });
    }
  }

  void _dismissEmojiPicker() {
    if (_persistentBottomSheetController != null) {
      _persistentBottomSheetController!.close();
    }
  }

  Widget _emojiView() {
    return Stack(
      children: [
        _emojiWidget(),
        Positioned(
          bottom: 0.w, // Adjust position as needed
          left: 0.w, // Adjust position as needed
          child: IconButton(
            icon: Icon(
              Icons.keyboard_arrow_down,
            ),
            color: AppColors.grey,
            onPressed: () {
              _dismissEmojiPicker();
            },
            iconSize: 28.w,
          ),
        ),
      ],
    );
  }

  Widget _emojiWidget() {
    return EmojiPicker(
      onEmojiSelected: (category, emoji) {},
      onBackspacePressed: () {},
      textEditingController: _commentController,
      config: Config(
        height: 300.w,
        checkPlatformCompatibility: true,
        emojiViewConfig: EmojiViewConfig(
          emojiSizeMax: 28 *
              (Theme.of(context).platform == TargetPlatform.iOS ? 1.0 : 0.8),
        ),
        viewOrderConfig: const ViewOrderConfig(
          top: EmojiPickerItem.categoryBar,
          middle: EmojiPickerItem.emojiView,
          bottom: EmojiPickerItem.searchBar,
        ),
        skinToneConfig: const SkinToneConfig(),
        categoryViewConfig: const CategoryViewConfig(),
        bottomActionBarConfig: BottomActionBarConfig(
          showSearchViewButton: false,
          showBackspaceButton: true,
          backgroundColor: AppColors.lightGreyBluish,
          buttonIconColor: AppColors.grey,
        ),
        searchViewConfig: const SearchViewConfig(),
      ),
    );
  }

  Widget _imageView(List<MediaUploadModel> mediaList) {
    return Container(
        margin: EdgeInsets.all(8).r,
        child: AnimationLimiter(
            child: Wrap(
          alignment: WrapAlignment.start,
          children: [
            for (int i = 0; i < mediaList.length; i++)
              AnimationConfiguration.staggeredList(
                position: i,
                duration: const Duration(milliseconds: 300),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: Container(
                        margin: EdgeInsets.only(top: 8.0).r,
                        child: Stack(
                          children: [
                            Center(
                              child: Container(
                                child: (mediaList[i].isUploaded)
                                    ? MicroSiteImageView(
                                        imgUrl: mediaList[i].fileUrl ?? '',
                                        height: 147.w,
                                        width: double.maxFinite,
                                        fit: BoxFit.fill,
                                      )
                                    : Image.file(
                                        mediaList[i].file!,
                                        height: 147.w,
                                        width: double.maxFinite,
                                        fit: BoxFit.fill,
                                      ),
                              ),
                            ),
                            if (mediaList[i].isErrorFile)
                              Center(
                                child: ClipRect(
                                  child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                          sigmaX: 10, sigmaY: 10),
                                      child: Container(
                                          height: 135.w,
                                          margin: EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 8),
                                          width: double.maxFinite,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.error_outline,
                                                size: 24.w,
                                                color: AppColors.negativeLight,
                                              ),
                                              SizedBox(height: 8.w),
                                              Text(
                                                AppLocalizations.of(context)!
                                                    .mDiscussionPostErrorToUploadFile,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge!
                                                    .copyWith(
                                                        color: AppColors
                                                            .negativeLight,
                                                        fontSize: 14.sp,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ))),
                                ),
                              ),
                            Positioned(
                              top: 4.w,
                              right: 4.w,
                              child: Align(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedImages.value
                                          .remove(mediaList[i]);
                                      if (_selectedImages.value.isEmpty &&
                                          _selectedMediaType
                                              .contains(MediaConst.image)) {
                                        _selectedMediaType
                                            .remove(MediaConst.image);
                                      }
                                    });
                                  },
                                  child: Container(
                                    width: 24.w,
                                    height: 24.w,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          color: AppColors.grey08,
                                        ),
                                        borderRadius: BorderRadius.all(
                                            const Radius.circular(4.0).r),
                                        color: AppColors.appBarBackground),
                                    child: Icon(
                                      Icons.delete,
                                      color: AppColors.negativeLight,
                                      size: 18.w,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        )),
                  ),
                ),
              )
          ],
        )));
  }

  Widget _descriptionInfoView() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8).r,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
              Icons.info,
              color: AppColors.primaryBlue,
              size: 16.sp
          ),
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              AppLocalizations.of(context)?.mDiscussionPostModerationInfoMessage ?? '',
              style: GoogleFonts.lato(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w400,
                fontSize: 12.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
