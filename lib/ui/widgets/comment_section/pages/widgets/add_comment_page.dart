import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/discussion/add_discussion/_models/tag_user_data_model.dart';
import 'package:karmayogi_mobile/ui/widgets/comment_section/model/comment_request.dart';
import '../../../../../../../../constants/_constants/color_constants.dart';
import '../../../_common/page_loader.dart';
import 'comment_input_field.dart';

class AddCommentPage extends StatefulWidget {
  final String text;
  final Widget? startingIcon;
  final String hintText;
  final String emptyValidationText;
  final bool showSuffix;
  final bool isReply;
  final bool readOnly;
  final String replyText;
  final Function(CommentCreationCallbackRequest) callback;
  final Function? updateCloseCallback;
  final bool isUpdate;
  final int maxLine;
  final double height;
  final double borderRadius;
  final List<TagUserDataModel>? mentionedUsers;
  final bool enableUserTagging;

  AddCommentPage(
      {this.text = '',
      this.startingIcon,
      required this.emptyValidationText,
      required this.hintText,
      this.showSuffix = false,
      this.isReply = false,
      this.readOnly = false,
      this.replyText = '',
      required this.callback,
      this.updateCloseCallback,
      this.isUpdate = false,
      this.maxLine = 1,
      this.height = 48,
      this.borderRadius = 0,
      this.mentionedUsers,
      required this.enableUserTagging});
  @override
  _AddCommentPageState createState() => _AddCommentPageState();
}

class _AddCommentPageState extends State<AddCommentPage> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocus = FocusNode();
  ValueNotifier<bool> _isLoading = ValueNotifier(false);
  ValueNotifier<bool> _isTextAdded = ValueNotifier(false);
  ValueNotifier<bool> _emojiVisibilityNotifier = ValueNotifier<bool>(false);
  PersistentBottomSheetController? _persistentBottomSheetController;
  List<TagUserDataModel>? mentionedUserList = [];

  submitComment(String comment) async {
    FocusScope.of(context).unfocus();
    List<Map<String, String>> _mentionedUsers = [];
    if ((mentionedUserList??[]).isNotEmpty) {
      _mentionedUsers = mentionedUserList!
          .map((user) => {
        "userId": user.userId ?? '',
        "userName": user.userName ?? '',
      }).toList();
    }
    widget.callback(CommentCreationCallbackRequest(
      comment: comment,
      mentionedUser: _mentionedUsers,
    ));
    _commentController.clear();
  }

  @override
  void initState() {
    super.initState();
    if ((widget.mentionedUsers ?? []).isNotEmpty) {
      mentionedUserList = widget.mentionedUsers!;
    }
    _commentController.addListener(_updateTextStatus);
    _commentController.text = widget.text;
    if (widget.isUpdate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(_commentFocus);
      });
    }
  }

  void _updateTextStatus() {
    _isTextAdded.value = (_commentController.text.trim()).isNotEmpty;
  }

  void _handleTaggedUsers(List<TagUserDataModel> users) {
    mentionedUserList = users;
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
            color: (widget.isReply)
                ? AppColors.replyBackgroundColor
                : AppColors.appBarBackground,
            borderRadius: BorderRadius.all(Radius.circular(12).r),
          ),
          child: Column(
            children: [
              if (widget.replyText != '') _replyToView(),
              _commentWidget()
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
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _commentWidget() {
    return Container(
      margin: widget.isUpdate
          ? EdgeInsets.only(bottom: 0).r
          : EdgeInsets.only(left: 8, right: 8, top: 16, bottom: 16).r,
      child: Row(
        children: [
          if (widget.startingIcon != null) widget.startingIcon ?? SizedBox(),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8).r,
              child: CommentInputField(
                minLines: widget.maxLine,
                keyboardType: TextInputType.text,
                controller: _commentController,
                focusNode: _commentFocus,
                hintText: widget.hintText,
                showSuffixIcon: widget.showSuffix,
                onTap: () {
                  _dismissEmojiPicker();
                },
                suffixIcon: IconButton(
                  onPressed: () {
                    if (!widget.readOnly) _openEmojiPicker(context);
                  },
                  icon: Icon(
                    Icons.sentiment_satisfied_outlined,
                    size: 24.w,
                    color: AppColors.primaryOne,
                  ),
                ),
                readOnly: widget.readOnly,
                height: widget.height,
                borderRadius: widget.borderRadius,
                onUserTagged: _handleTaggedUsers,
                mentionedUserList: mentionedUserList,
                enableUserTagging: widget.enableUserTagging,
              ),
            ),
          ),
          (widget.isUpdate)
              ? AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  curve: Curves.bounceInOut,
                  child: ValueListenableBuilder(
                      valueListenable: _isTextAdded,
                      builder: (BuildContext context, bool isTextAdded,
                          Widget? child) {
                        return _updateActionButton(isTextAdded);
                      }),
                )
              : AnimatedContainer(
                  height: 40.w,
                  duration: Duration(milliseconds: 200),
                  curve: Curves.bounceInOut,
                  child: ValueListenableBuilder(
                      valueListenable: _isTextAdded,
                      builder: (BuildContext context, bool isTextAdded,
                          Widget? child) {
                        return widget.isReply
                            ? _isReplySection(isTextAdded)
                            : _actionButton(isTextAdded);
                      }),
                ),
        ],
      ),
    );
  }

  Widget _isReplySection(bool isTextAdded) {
    return isTextAdded ? _actionButton(isTextAdded) : SizedBox.shrink();
  }

  Widget _actionButton(bool isTextAdded) {
    return ElevatedButton(
        onPressed: () async {
          if (isTextAdded && (!widget.readOnly)) {
            if (_commentController.text.isNotEmpty) {
              if (_isLoading.value) return;
              _isLoading.value = true;
              await submitComment(_commentController.text);
              _isLoading.value = false;
            } else {
              FocusScope.of(context).requestFocus(_commentFocus);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(widget.emptyValidationText),
                  backgroundColor: AppColors.negativeLight,
                ),
              );
            }
          }
        },
        child: ValueListenableBuilder(
            valueListenable: _isLoading,
            builder: (BuildContext context, bool isLoading, Widget? child) {
              return Container(
                width: 28.w,
                alignment: Alignment.center,
                child: isLoading
                    ? Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 8).w,
                        child: SizedBox(
                            width: 16.w,
                            height: 16.w,
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
          elevation: 0,
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

  Widget _updateActionButton(bool isTextAdded) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0).w,
          child: GestureDetector(
            onTap: () async {
              if (isTextAdded && (!widget.readOnly)) {
                if (_commentController.text.isNotEmpty) {
                  if (_isLoading.value) return;
                  _isLoading.value = true;
                  FocusScope.of(context).unfocus();
                  await submitComment(_commentController.text);
                  _isLoading.value = false;
                } else {
                  FocusScope.of(context).requestFocus(_commentFocus);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(widget.emptyValidationText),
                      backgroundColor: AppColors.negativeLight,
                    ),
                  );
                }
              }
            },
            child: ValueListenableBuilder(
                valueListenable: _isLoading,
                builder: (BuildContext context, bool isLoading, Widget? child) {
                  return Container(
                    width: 20.w,
                    height: 20.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color:
                          isTextAdded ? AppColors.darkBlue : AppColors.grey16,
                      borderRadius: BorderRadius.all(Radius.circular(100)).r,
                    ),
                    child: isLoading
                        ? Padding(
                            padding:
                                EdgeInsets.symmetric(vertical: 8, horizontal: 8)
                                    .w,
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
                            Icons.check,
                            size: 16.w,
                            color: AppColors.appBarBackground,
                          ),
                  );
                }),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0).w,
          child: GestureDetector(
            onTap: () async {
              if (widget.updateCloseCallback != null) {
                FocusScope.of(context).unfocus();
                widget.updateCloseCallback!();
              }
            },
            child: ValueListenableBuilder(
                valueListenable: _isLoading,
                builder: (BuildContext context, bool isLoading, Widget? child) {
                  return Container(
                    width: 20.w,
                    height: 20.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.grey16,
                      borderRadius: BorderRadius.all(Radius.circular(100)).r,
                    ),
                    child: isLoading
                        ? Padding(
                            padding:
                                EdgeInsets.symmetric(vertical: 8, horizontal: 8)
                                    .w,
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
                            Icons.close_sharp,
                            size: 16.w,
                            color: AppColors.appBarBackground,
                          ),
                  );
                }),
          ),
        ),
      ],
    );
  }
}
