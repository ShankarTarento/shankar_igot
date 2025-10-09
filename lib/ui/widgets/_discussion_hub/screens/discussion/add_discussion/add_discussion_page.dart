import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:html_editor_enhanced/utils/shims/dart_ui_real.dart';
import 'package:igot_ui_components/ui/components/microsite_image_view.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/feedback/constants.dart';
import 'package:karmayogi_mobile/ui/widgets/_common/page_loader.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/helper/discussion_const.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/helper/discussion_helper.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/repositories/discussion_repository.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_models/user_community_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/discussion/add_discussion/_models/media_upload_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/discussion/add_discussion/_models/tag_user_data_model.dart';
// import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/discussion/add_discussion/_widgets/add_link_dialog.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/discussion/add_discussion/_widgets/add_media_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/discussion/add_discussion/_widgets/community_dropdown.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/discussion/discussion_view/_models/discussion_model.dart';
import 'package:karmayogi_mobile/ui/widgets/comment_section/pages/widgets/comment_profile_image_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/tooltip_widget.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:html/parser.dart' as html_parser;

class AddDiscussionPage extends StatefulWidget {
  final String? userProfileImgUrl;
  final String? userName;
  final String? userProfileStatus;
  final String? designation;
  final String communityId;
  final Function(DiscussionItemData)? postCallback;
  final DiscussionItemData? discussionItemData;

  AddDiscussionPage(
      {Key? key,
      this.userProfileImgUrl,
      this.userName,
      required this.communityId,
      this.userProfileStatus,
      this.designation,
      this.postCallback,
      this.discussionItemData})
      : super(key: key);

  @override
  AddDiscussionPageState createState() => AddDiscussionPageState();
}

class AddDiscussionPageState extends State<AddDiscussionPage> {
  late HtmlEditorController descriptionFieldController;

  List<MediaUploadModel> _selectedImages = [];
  List<MediaUploadModel> _selectedVideos = [];
  List<MediaUploadModel> _selectedDocuments = [];
  List<String> _selectedLinks = [];
  List<String> _selectedMediaType = [];
  ValueNotifier<bool> _pageLoading = ValueNotifier(false);
  ValueNotifier<bool> _isLoading = ValueNotifier(false);
  ValueNotifier<String> _errorMessage = ValueNotifier('');
  ValueNotifier<bool> _isTextAdded = ValueNotifier(false);
  ValueNotifier<bool> _emojiVisibilityNotifier = ValueNotifier<bool>(false);
  Color? errorImageColor =
      AppColors.networkBg[Random().nextInt(AppColors.networkBg.length)];
  String? _discussionId;
  bool enableEmoji = true;
  PersistentBottomSheetController? _persistentBottomSheetController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<List<UserCommunityIdData>?>? _communityFuture;
  List<UserCommunityIdData> _userJoinedCommunities = [];
  String? _communityDefaultValue = "dropdown_default";
  String _communityId = "";


  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<TagUserDataModel> _taggedUsers = [];
  List<TagUserDataModel> _filteredUsers = [];
  Map<String, String> _userIdToFirstNameMap = {};
  List<Map<String, String>> _mentionedUsers = [];
  String _lastQuery = '';
  String? _currentRequestQuery = '';


  @override
  void initState() {
    super.initState();
    descriptionFieldController = HtmlEditorController();
    loadData();
    if (widget.communityId.isEmpty) {
      _loadCommunity();
    } else {
      _communityId = widget.communityId;
    }
  }

  Future<void> _loadCommunity() async {
    _communityFuture = _getUserJoinedCommunities();
  }

  Future<List<UserCommunityIdData>> _getUserJoinedCommunities() async {
    _pageLoading.value = true;
    List<UserCommunityIdData> response = [];
    try {
      response = await Provider.of<DiscussionRepository>(context, listen: false)
          .getUserJoinedCommunities();
      _userJoinedCommunities = response;
      _pageLoading.value = false;
      return Future.value(response);
    } catch (err) {
      _pageLoading.value = false;
      return Future.value([]);
    }
  }

  void loadData() {
    if (widget.discussionItemData != null) {
      _pageLoading.value = true;
      _discussionId = widget.discussionItemData?.discussionId;
      if (widget.discussionItemData?.mediaCategory != null) {
        if ((widget.discussionItemData?.mediaCategory?.image ?? [])
            .isNotEmpty) {
          _selectedImages = _getMediaData(
              widget.discussionItemData?.mediaCategory?.image ?? []);
          _selectedMediaType.add(MediaConst.image);
        }
        if ((widget.discussionItemData?.mediaCategory?.video ?? [])
            .isNotEmpty) {
          _selectedVideos = _getMediaData(
              widget.discussionItemData?.mediaCategory?.video ?? []);
          _selectedMediaType.add(MediaConst.video);
        }
        if ((widget.discussionItemData?.mediaCategory?.document ?? [])
            .isNotEmpty) {
          _selectedDocuments = _getMediaData(
              widget.discussionItemData?.mediaCategory?.document ?? []);
          _selectedMediaType.add(MediaConst.file);
        }
        if ((widget.discussionItemData?.mediaCategory?.link ?? []).isNotEmpty) {
          _selectedLinks = widget.discussionItemData?.mediaCategory?.link ?? [];
          _selectedMediaType.add(MediaConst.link);
        }
      }
      if ((widget.discussionItemData?.mentionedUsers ?? []).isNotEmpty) {
        _taggedUsers = widget.discussionItemData?.mentionedUsers??[];
        for (final item in _taggedUsers) {
          if ((item.userId ?? '').isNotEmpty) {
            _userIdToFirstNameMap[item.userId!] = item.userName ?? '';
          }
        }
      }
      Future.delayed(Duration(seconds: 1), () {
        _pageLoading.value = false;
      });
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

  Future<String> _getDescriptionContent() async {
    String htmlContent = await descriptionFieldController.getText();
    return htmlContent;
  }

  List<String> _getMediaUrls(List<MediaUploadModel> mediaList) {
    return mediaList
        .where((element) => element.isUploaded && element.fileUrl != null)
        .map((element) => element.fileUrl ?? '')
        .toList();
  }

  Future<Map<String, List<String>>> getMediaCategory() async {
    Map<String, List<String>> _mediaCategory = {};

    if (_selectedImages.isNotEmpty) {
      List<String> mediaUrls = await _getMediaUrls(_selectedImages);
      if (mediaUrls.isNotEmpty) _mediaCategory[MediaConst.image] = mediaUrls;
    }
    if (_selectedVideos.isNotEmpty) {
      List<String> mediaUrls = await _getMediaUrls(_selectedVideos);
      if (mediaUrls.isNotEmpty) _mediaCategory[MediaConst.video] = mediaUrls;
    }
    if (_selectedDocuments.isNotEmpty) {
      List<String> mediaUrls = await _getMediaUrls(_selectedDocuments);
      if (mediaUrls.isNotEmpty) _mediaCategory[MediaConst.file] = mediaUrls;
    }
    if (_selectedLinks.isNotEmpty) {
      _mediaCategory[MediaConst.link] = _selectedLinks;
    }
    return _mediaCategory;
  }

  bool hasMediaFiles() {
    return _selectedImages.isNotEmpty ||
        _selectedVideos.isNotEmpty ||
        _selectedDocuments.isNotEmpty;
  }

  Future<void> _saveDiscussion(BuildContext context,
      {String? discussionId}) async {
    String _description = await _getDescriptionContent();
    String? validationMessage = validateDescription(_description);

    if (validationMessage != null) {
      _errorMessage.value = validationMessage;
      return;
    }

    _isLoading.value = true;
    try {
      bool _errorInFileUpload = false;
      DiscussionItemData? response;
      if (discussionId != null) {
        if (hasMediaFiles()) {
          if (_selectedImages.isNotEmpty) {
            await Future.wait(
              _selectedImages.asMap().entries.map((entry) async {
                if (!(entry.value.isUploaded)) {
                  String fileUrl = await uploadMedia(
                      entry.value.file!, discussionId, _communityId, entry.key);
                  if (fileUrl.isNotEmpty) {
                    setState(() {
                      _selectedImages[entry.key].fileUrl = fileUrl;
                      _selectedImages[entry.key].isUploaded = true;
                    });
                  } else {
                    setState(() {
                      _selectedImages[entry.key].isErrorFile = true;
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
          if (_selectedVideos.isNotEmpty) {
            await Future.wait(
              _selectedVideos.asMap().entries.map((entry) async {
                if (!(entry.value.isUploaded)) {
                  String fileUrl = await uploadMedia(
                      entry.value.file!, discussionId, _communityId, entry.key);
                  if (fileUrl.isNotEmpty) {
                    setState(() {
                      _selectedVideos[entry.key].fileUrl = fileUrl;
                      _selectedVideos[entry.key].isUploaded = true;
                    });
                  } else {
                    setState(() {
                      _selectedVideos[entry.key].isErrorFile = true;
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
          if (_selectedDocuments.isNotEmpty) {
            await Future.wait(
              _selectedDocuments.asMap().entries.map((entry) async {
                if (!(entry.value.isUploaded)) {
                  String fileUrl = await uploadMedia(
                      entry.value.file!, discussionId, _communityId, entry.key);
                  if (fileUrl.isNotEmpty) {
                    setState(() {
                      _selectedDocuments[entry.key].fileUrl = fileUrl;
                      _selectedDocuments[entry.key].isUploaded = true;
                    });
                  } else {
                    setState(() {
                      _selectedDocuments[entry.key].isErrorFile = true;
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

        /// Update post
        Map<String, List<String>> _mediaCategory = await getMediaCategory();
        response = await Provider.of<DiscussionRepository>(context, listen: false).updateDiscussion(
            discussionId: discussionId,
            type: "question",
            description: _description,
            communityId: _communityId,
            categoryType: _selectedMediaType,
            mediaCategory: _mediaCategory,
            mentionedUsers: _mentionedUsers
        );
      } else {
        /// create discussion
        response = await Provider.of<DiscussionRepository>(context, listen: false).postDiscussion(
            type: "question",
            description: _description,
            communityId: _communityId,
            mentionedUsers: _mentionedUsers
        );
      }

      if (response != null) {
        if ((discussionId == null) &&
            (hasMediaFiles() || _selectedLinks.isNotEmpty)) {
          Helper.showSnackBarMessage(
              context: context,
              text:
                  AppLocalizations.of(context)?.mDiscussionUploadingMedia ?? '',
              bgColor: AppColors.positiveLight);
          _discussionId = response.discussionId;
          await _saveDiscussionMedia(context, response.discussionId ?? '');
        } else {
          Navigator.of(context).pop();
          if (widget.postCallback != null) {
            widget.postCallback!(response);
          }
          Helper.showSnackBarMessage(
              context: context,
              text: AppLocalizations.of(context)?.mStaticCommentPostedCreated ??
                  '',
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

  Future<void> _saveDiscussionMedia(
      BuildContext context, String discussionId) async {
    bool _errorInFileUpload = false;
    try {
      if (_selectedImages.isNotEmpty) {
        await Future.wait(
          _selectedImages.asMap().entries.map((entry) async {
            if (!(entry.value.isUploaded)) {
              String fileUrl = await uploadMedia(
                  entry.value.file!, discussionId, _communityId, entry.key);
              if (fileUrl.isNotEmpty) {
                setState(() {
                  _selectedImages[entry.key].fileUrl = fileUrl;
                  _selectedImages[entry.key].isUploaded = true;
                });
              } else {
                setState(() {
                  _selectedImages[entry.key].isErrorFile = true;
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
      if (_selectedVideos.isNotEmpty) {
        await Future.wait(
          _selectedVideos.asMap().entries.map((entry) async {
            if (!(entry.value.isUploaded)) {
              String fileUrl = await uploadMedia(
                  entry.value.file!, discussionId, _communityId, entry.key);
              if (fileUrl.isNotEmpty) {
                setState(() {
                  _selectedVideos[entry.key].fileUrl = fileUrl;
                  _selectedVideos[entry.key].isUploaded = true;
                });
              } else {
                setState(() {
                  _selectedVideos[entry.key].isErrorFile = true;
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
      if (_selectedDocuments.isNotEmpty) {
        await Future.wait(
          _selectedDocuments.asMap().entries.map((entry) async {
            if (!(entry.value.isUploaded)) {
              String fileUrl = await uploadMedia(
                  entry.value.file!, discussionId, _communityId, entry.key);
              if (fileUrl.isNotEmpty) {
                setState(() {
                  _selectedDocuments[entry.key].fileUrl = fileUrl;
                  _selectedDocuments[entry.key].isUploaded = true;
                });
              } else {
                setState(() {
                  _selectedDocuments[entry.key].isErrorFile = true;
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

        ///Update post media
        Map<String, List<String>> _mediaCategory = await getMediaCategory();
        response =
            await Provider.of<DiscussionRepository>(context, listen: false)
                .saveDiscussionMedia(
          discussionId: discussionId,
          communityId: _communityId,
          categoryType: _selectedMediaType,
          mediaCategory: _mediaCategory,
        );
        if (response != null) {
          Navigator.of(context).pop();
          if (widget.postCallback != null) {
            widget.postCallback!(response);
          }
          Helper.showSnackBarMessage(
              context: context,
              text: AppLocalizations.of(context)?.mStaticCommentPostedCreated ??
                  '',
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

  String? validateDescription(String description) {
    String cleanedDescription =
        description.trim().replaceAll(RegExp(r'<br\s*/?>'), '');
    var textLength = DiscussionHelper.getHtmlTextLength(cleanedDescription);

    if ((_communityId.isEmpty) || (_communityId == _communityDefaultValue)) {
      return AppLocalizations.of(context)?.mDiscussionPleaseSelectCommunity;
    }

    if (cleanedDescription.isEmpty) {
      return AppLocalizations.of(context)?.mDiscussionPostMinLengthText;
    }

    if (textLength < 3) {
      return AppLocalizations.of(context)?.mDiscussionPostMinLengthText;
    }

    if (textLength > 3000) {
      return AppLocalizations.of(context)?.mDiscussionPostMaxLengthText;
    }

    return null;
  }

  Future<void> addFileCallBack(Map<String, dynamic> selectedMedia) async {
    MediaSource fileType = await selectedMedia["filetype"];
    File file = await selectedMedia["file"];
    setState(() {
      if (fileType == MediaSource.image) {
        _selectedMediaType.add(MediaConst.image);
        _selectedImages.add(MediaUploadModel(
            file: file, isUploaded: false, isErrorFile: false));
      } else if (fileType == MediaSource.video) {
        _selectedMediaType.add(MediaConst.video);
        _selectedVideos.add(MediaUploadModel(
            file: file, isUploaded: false, isErrorFile: false));
      } else if (fileType == MediaSource.file) {
        _selectedMediaType.add(MediaConst.file);
        _selectedDocuments.add(MediaUploadModel(
            file: file, isUploaded: false, isErrorFile: false));
      }
    });
  }

  bool isMediaUploadEnabled(MediaSource selectedMediaType) {
    int totalSelectedMediaCount = _selectedImages.length +
        _selectedVideos.length +
        _selectedDocuments.length;
    if (totalSelectedMediaCount >= maxMediaUploadCount) {
      return false;
    }
    return true;
  }

  String _getFileName(String filePath) {
    return filePath.split('/').last.split('\\').last;
  }

  Future<void> _findSuggestions(String query) async {
    if (query.length < 1 || query == _lastQuery) return;
    _currentRequestQuery = query;
    try {
      final users = await getUserListForTagging(query);
      if (_currentRequestQuery == query) {
        setState(() {
          _filteredUsers = users;
          _lastQuery = query;
        });
      }
    } catch (e) {}
  }

  Future<List<TagUserDataModel>> getUserListForTagging(String searchText) async {
    List<TagUserDataModel> response = [];
    try {
      response = await Provider.of<DiscussionRepository>(context, listen: false).getUserListForTagging(searchText);
      return response;
    } catch (err) {
      return [];
    }
  }

  void _removeOverlay() {
    try {
      _overlayEntry?.remove();
      _overlayEntry = null;
    } catch (e) {}
  }

  void _handleTaggedUsers(List<TagUserDataModel> users) {
    _mentionedUsers = users.map((u) => {
      "userId": u.userId??'',
      "userName": u.userName??'',
    }).toList();
  }

  void _onTextChanged() async {
    final rawHtml = await descriptionFieldController.getText();
    final document = html_parser.parse(rawHtml);
    final text = document.body?.text ?? '';
    final cleanedDescription = text.replaceAll('\u00A0', ' ').trim(); // \u00A0 is &nbsp;

    final match = RegExp(r'@(\w+)$').firstMatch(cleanedDescription);

    if (match != null) {
      final keyword = match.group(1)!;
      await _findSuggestions(keyword.toLowerCase());
      _showOverlay();
    } else {
      _removeOverlay();
    }

    final mentionedUserIds = _userIdToFirstNameMap.entries
        .where((entry) => cleanedDescription.contains('@${entry.value}'))
        .map((entry) => entry.key)
        .toSet();

    _taggedUsers.removeWhere((user) => !mentionedUserIds.contains(user.userId));
    _handleTaggedUsers(_taggedUsers);
  }

  void _onUserSelected(TagUserDataModel user) async {
    final rawHtml = await descriptionFieldController.getText();

    final document = html_parser.parse(rawHtml);
    final plainText = document.body?.text.replaceAll('\u00A0', ' ') ?? '';
    final match = RegExp(r'@(\w+)$').firstMatch(plainText);

    if (match != null) {
      final start = match.start;
      final end = match.end;
      final tagDisplayName = user.userName ?? '';
      final newText = plainText.replaceRange(start, end, "@$tagDisplayName\u200B &nbsp;");


      descriptionFieldController.setText(newText);
      descriptionFieldController.disable();
      descriptionFieldController.enable();
      _removeOverlay();

      if (user.userId != null) {
        _userIdToFirstNameMap[user.userId!] = tagDisplayName;
      }
      if (!_taggedUsers.any((u) => u.userId == user.userId)) {
        _taggedUsers.add(user);
        _handleTaggedUsers(_taggedUsers);
      }
    }
  }


  Color _getUserColorByFirstAndLast(String name) {
    try {
      if (name.trim().isEmpty || AppColors.networkBg.isEmpty) {
        return AppColors.grey40;
      }
      final trimmedName = name.trim().toUpperCase();
      final firstCharCode = trimmedName.codeUnitAt(0);
      final lastCharCode = trimmedName.codeUnitAt(trimmedName.length - 1);

      final combinedHash = (firstCharCode + lastCharCode) % AppColors.networkBg.length;

      return AppColors.networkBg[combinedHash];
    } catch (e) {
      return AppColors.grey40;
    }
  }

  void _showOverlay() {
    _removeOverlay();
    if (!mounted) return;
    final overlay = Overlay.of(context);
    if (_filteredUsers.isEmpty) return;
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 1.sw - 32.w,
        child: CompositedTransformFollower(
          offset: Offset(0, 40.h),
          link: _layerLink,
          showWhenUnlinked: false,
          child: Container(
            margin: EdgeInsets.only(top: 180).r,
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(8.r),
              color: AppColors.appBarBackground,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.appBarBackground,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.grey40,
                      blurRadius: 8.r,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxHeight: 140.h
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: _filteredUsers.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[200]),
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      return InkWell(
                        onTap: () => _onUserSelected(user),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                          child: Row(
                            children: [
                              CommentProfileImageWidget(
                                  profilePic: "",
                                  name: user.firstName??'',
                                  errorImageColor: _getUserColorByFirstAndLast(user.firstName??''),
                                  iconSize: 28.w
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.firstName??'',
                                      style: GoogleFonts.lato(
                                        color: AppColors.greys60,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14.sp,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      '@${user.userName}',
                                      style: GoogleFonts.lato(
                                        color: AppColors.grey40,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12.sp,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  @override
  void dispose() async {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _dismissEmojiPicker();
        _removeOverlay();
      },
      child: Container(
        margin: EdgeInsets.only(
                top: 40,
                bottom: (MediaQuery.of(context).viewInsets.bottom > 0) ? 2 : 40,
                left: 8,
                right: 8)
            .w,
        child: Stack(
          children: [
            ValueListenableBuilder(
                valueListenable: _pageLoading,
                builder: (BuildContext context, bool loading, Widget? child) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12).r,
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: AppColors.grey16),
                          borderRadius:
                              BorderRadius.all(const Radius.circular(12.0).r),
                          color: AppColors.appBarBackground),
                      child: widget.communityId.isNotEmpty
                          ? _buildLayout(loading)
                          : _buildLayoutWithCommunity(loading),
                    ),
                  );
                }),
            _appbarView(),
          ],
        ),
      ),
    );
  }

  Widget _buildLayoutWithCommunity(bool loading) {
    return FutureBuilder(
      future: _communityFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return (loading)
              ? Center(
                  child: PageLoader(
                    isLightTheme: true,
                  ),
                )
              : Container();
        } else {
          return _buildLayout(loading);
        }
      },
    );
  }

  Widget _buildLayout(bool loading) {
    return Container(
        child: loading
            ? Center(
                child: PageLoader(
                  isLightTheme: true,
                ),
              )
            : Scaffold(
                key: _scaffoldKey,
                backgroundColor: Colors.transparent,
                body: Stack(
                  children: [
                    buildLayout(), // Your main content
                    Positioned(
                      left: 16.w,
                      right: 0,
                      bottom: 0.28.sh,
                      child: CompositedTransformTarget(
                          link: _layerLink,
                          child: Container(
                            width: double.maxFinite,
                            height: 140.w,
                          )
                      ), // Your bottom view
                    ),
                    Positioned(
                      bottom: 0, // Adjust position
                      left: 0,
                      right: 0,
                      child: bottomView(), // Your bottom view
                    ),
                  ],
                ),
              ));
  }

  Widget _appbarView() {
    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 8).r,
      child: Align(
          alignment: Alignment.topRight,
          child: InkWell(
            onTap: () async {
              Navigator.of(context).pop();
            },
            child: Container(
              alignment: Alignment.center,
              height: 36.w,
              width: 36.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.grey40,
              ),
              child: Icon(
                Icons.close,
                color: AppColors.whiteGradientOne,
                size: 16.sp,
              ),
            ),
          )),
    );
  }

  Widget buildLayout() {
    return Container(
      height: 1.sh,
      margin: EdgeInsets.only(top: 16).r,
      decoration: BoxDecoration(color: AppColors.appBarBackground),
      child: SingleChildScrollView(
          child: Container(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80).r,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _userProfileSelectionView(),
                  SizedBox(height: 16.w),
                  _communityDropDownView(),
                  SizedBox(height: 16.w),
                  _descriptionFormFieldView(),
                  SizedBox(height: 8.w),
                  _descriptionInfoView(),
                  SizedBox(height: 16.w),
                  _mediaListView(),
                  SizedBox(height: 250.w),
                ],
              ))),
    );
  }

  Widget _descriptionInfoView() {
    return Container(
      padding: EdgeInsets.all(8).r,
      decoration: BoxDecoration(
          color: AppColors.primaryOne.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8).r,),
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

  Widget _userProfileSelectionView() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, right: 16).r,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 4).r,
            child: CommentProfileImageWidget(
                profilePic: widget.userProfileImgUrl ?? '',
                name: widget.userName ?? '',
                errorImageColor: errorImageColor ?? AppColors.primaryOne,
                iconSize: 46.w),
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
                            widget.userName ?? '',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(
                                  color: AppColors.greys60,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20.sp,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if ((widget.userProfileStatus ?? '').toLowerCase() ==
                            UserProfileStatus.verified.toLowerCase())
                          Container(
                            height: 20.w,
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(
                              left: 4,
                            ).r,
                            child: CircleAvatar(
                              backgroundColor: AppColors.positiveLight,
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
                    if (((widget.designation ?? '').isNotEmpty) &&
                        (widget.designation ?? '').toLowerCase() != 'null')
                      Text(
                        widget.designation ?? '',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
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
    );
  }

  Widget _communityDropDownView() {
    return (widget.communityId.isEmpty)
        ? Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8).w,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)?.mDiscussionPostingIn ?? '',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: AppColors.greys87,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp),
                      textAlign: TextAlign.left,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8).r,
                      child: TooltipWidget(
                        message: AppLocalizations.of(context)
                                ?.mDiscussionSelectCommunityHelperText ??
                            '',
                        iconSize: 18.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                  margin: const EdgeInsets.only(top: 8).r,
                  padding: const EdgeInsets.fromLTRB(16, 0, 4, 0).r,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: AppColors.appBarBackground,
                      border: Border.all(color: AppColors.grey16),
                      borderRadius: BorderRadius.circular(12).r),
                  child: CommunityDropdown(
                    items: _userJoinedCommunities,
                    selectedItem: (widget.communityId.isNotEmpty)
                        ? widget.communityId
                        : _communityDefaultValue,
                    defaultText: AppLocalizations.of(context)
                        ?.mDiscussionSelectCommunity,
                    defaultValue: _communityDefaultValue,
                    parentAction: (selectedCommunityId) async {
                      _communityId = selectedCommunityId;
                      String _description = await _getDescriptionContent();
                      if (_communityId != _communityDefaultValue) {
                        String? validationMessage =
                            validateDescription(_description);
                        if (validationMessage != null) {
                          _isTextAdded.value = false;
                          _errorMessage.value = '';
                        } else {
                          _isTextAdded.value = true;
                          _errorMessage.value = '';
                        }
                      }
                    },
                  )),
            ],
          )
        : SizedBox.shrink();
  }

  Widget _descriptionFormFieldView() {
    return Column(
      children: [
        _richTextView(),
        ValueListenableBuilder(
            valueListenable: _errorMessage,
            builder:
                (BuildContext context, String errorMessage, Widget? child) {
              return errorMessage.isNotEmpty
                  ? Container(
                      width: double.maxFinite,
                      margin: EdgeInsets.only(top: 16).r,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12).r,
                          color: AppColors.negativeLight),
                      padding: EdgeInsets.all(16.0).w,
                      child: Text(
                        errorMessage,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: AppColors.appBarBackground,
                              fontWeight: FontWeight.w400,
                              fontSize: 12.0.sp,
                            ),
                      ))
                  : Container();
            })
      ],
    );
  }

  Widget _richTextView() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12).r,
      child: Container(
        padding: EdgeInsets.all(4).r,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey16),
          borderRadius: BorderRadius.all(const Radius.circular(12.0).r),
          color: AppColors.appBarBackground,
        ),
        child: HtmlEditor(
          controller: descriptionFieldController,
          htmlEditorOptions: HtmlEditorOptions(
            hint: AppLocalizations.of(context)?.mDiscussionDescriptionHintText,
            shouldEnsureVisible: false,
            initialText: ((widget.discussionItemData != null) ? (widget.discussionItemData?.description??'') : ''),
            autoAdjustHeight: false,
            adjustHeightForKeyboard: false,
          ),
          htmlToolbarOptions: HtmlToolbarOptions(
            toolbarPosition: ToolbarPosition.aboveEditor,
            toolbarType: ToolbarType.nativeScrollable,
            toolbarItemHeight: 32.w,
            defaultToolbarButtons: [
              FontButtons(clearAll: false),
              ColorButtons(),
              InsertButtons(
                  picture: false,
                  video: false,
                  audio: false,
                  table: false,
                  hr: false,
                  link: false,
                  otherFile: false
              ),
              ListButtons(listStyles: false),
              ParagraphButtons(
                  textDirection: false, lineHeight: false, caseConverter: false),
              FontSettingButtons(fontSizeUnit: false),
              StyleButtons(),
            ],
            buttonColor: AppColors.disabledTextGrey,
            buttonFillColor: AppColors.darkBlue,
            buttonSelectedColor: AppColors.appBarBackground,
            textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: AppColors.disabledTextGrey,
              fontWeight: FontWeight.w600,
              fontSize: 12.0.sp,
            ),
            gridViewHorizontalSpacing: 8.w,
            gridViewVerticalSpacing: 8.w,
          ),
          otherOptions: OtherOptions(
            height: 400.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              border: Border.fromBorderSide(
                  BorderSide(color: AppColors.appBarBackground, width: 0)
              ),
            ),
          ),
          callbacks: Callbacks(onBeforeCommand: (String? currentHtml) {},
            // onInit: () async {
            //   // descriptionFieldController.setFullScreen();
            // },

            onFocus: () {
              _dismissEmojiPicker();
            },
            onChangeContent: (String? changedText) {
              String? validationMessage = validateDescription(changedText??'');
              if (validationMessage != null) {
                _isTextAdded.value = false;
              } else {
                _isTextAdded.value = true;
                _errorMessage.value = '';
              }
              _onTextChanged();
            },
            onNavigationRequestMobile: (String url) {
              return NavigationActionPolicy.CANCEL;
            },
          ),
        ),
      ),
    );
  }

  Widget _mediaListView() {
    return Container(
        padding: EdgeInsets.only(bottom: 16).r,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_selectedImages.isNotEmpty) _imageView(_selectedImages),
            if (_selectedVideos.isNotEmpty) _videoView(_selectedVideos),
            if (_selectedDocuments.isNotEmpty) _fileView(_selectedDocuments),
            if (_selectedLinks.isNotEmpty) _linkView(_selectedLinks),
          ],
        ));
  }

  Widget _imageView(List<MediaUploadModel> mediaList) {
    return Container(
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
                                    height: 0.5.sw,
                                    width: double.maxFinite,
                                    fit: BoxFit.contain,
                                  )
                                : Image.file(
                                    mediaList[i].file!,
                                    height: 0.5.sw,
                                    width: double.maxFinite,
                                    fit: BoxFit.contain,
                                  ),
                          ),
                        ),
                        if (mediaList[i].isErrorFile)
                          Center(
                            child: ClipRect(
                              child: BackdropFilter(
                                  filter:
                                      ImageFilter.blur(sigmaX: 10, sigmaY: 10),
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
                                                    color:
                                                        AppColors.negativeLight,
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
                                  _selectedImages.remove(mediaList[i]);
                                  if (_selectedImages.isEmpty &&
                                      _selectedMediaType
                                          .contains(MediaConst.image)) {
                                    _selectedMediaType.remove(MediaConst.image);
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

  Widget _videoView(List<MediaUploadModel> mediaList) {
    return Container(
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
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 8).r,
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: mediaList[i].isErrorFile
                            ? AppColors.negativeLight
                            : AppColors.grey08,
                      ),
                      borderRadius:
                          BorderRadius.all(const Radius.circular(4.0).r),
                      color: mediaList[i].isErrorFile
                          ? (AppColors.negativeLight.withValues(alpha: 0.2))
                          : FeedbackColors.unRatedColor),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 60.w,
                        width: 60.w,
                        color: AppColors.greys60,
                        child: Icon(
                          Icons.play_circle_fill_rounded,
                          color: AppColors.appBarBackground,
                          size: 24.w,
                        ),
                      ),
                      SizedBox(
                        width: 8.w,
                      ),
                      Container(
                        width: 0.5.sw,
                        child: (mediaList[i].isUploaded)
                            ? Text(
                                _getFileName(mediaList[i].fileUrl ?? ''),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium!
                                    .copyWith(
                                      color: mediaList[i].isErrorFile
                                          ? AppColors.negativeLight
                                          : AppColors.disabledTextGrey,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.0.sp,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              )
                            : Text(
                                _getFileName(mediaList[i].file!.path),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium!
                                    .copyWith(
                                      color: mediaList[i].isErrorFile
                                          ? AppColors.negativeLight
                                          : AppColors.disabledTextGrey,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.0.sp,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                      ),
                      Spacer(),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _selectedVideos.remove(mediaList[i]);
                            if (_selectedVideos.isEmpty &&
                                _selectedMediaType.contains(MediaConst.video)) {
                              _selectedMediaType.remove(MediaConst.video);
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
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
      ],
    )));
  }

  Widget _fileView(List<MediaUploadModel> mediaList) {
    return Container(
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
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 8).r,
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: mediaList[i].isErrorFile
                            ? AppColors.negativeLight
                            : AppColors.grey08,
                      ),
                      borderRadius:
                          BorderRadius.all(const Radius.circular(4.0).r),
                      color: mediaList[i].isErrorFile
                          ? (AppColors.negativeLight.withValues(alpha: 0.2))
                          : FeedbackColors.unRatedColor),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 60.w,
                        width: 60.w,
                        color: AppColors.appBarBackground,
                        child: Icon(
                          Icons.description_outlined,
                          color: AppColors.greys60,
                          size: 40.w,
                        ),
                      ),
                      SizedBox(
                        width: 8.w,
                      ),
                      Container(
                        width: 0.5.sw,
                        child: (mediaList[i].isUploaded)
                            ? Text(
                                _getFileName(mediaList[i].fileUrl ?? ''),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium!
                                    .copyWith(
                                      color: mediaList[i].isErrorFile
                                          ? AppColors.negativeLight
                                          : AppColors.disabledTextGrey,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.0.sp,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              )
                            : Text(
                                _getFileName(mediaList[i].file!.path),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium!
                                    .copyWith(
                                      color: mediaList[i].isErrorFile
                                          ? AppColors.negativeLight
                                          : AppColors.disabledTextGrey,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.0.sp,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                      ),
                      Spacer(),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _selectedDocuments.remove(mediaList[i]);
                            if (_selectedDocuments.isEmpty &&
                                _selectedMediaType.contains(MediaConst.file)) {
                              _selectedMediaType.remove(MediaConst.file);
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
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
      ],
    )));
  }

  Widget _linkView(List<String> mediaList) {
    return Container(
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
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 8).r,
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.grey08,
                      ),
                      borderRadius:
                          BorderRadius.all(const Radius.circular(4.0).r),
                      color: FeedbackColors.unRatedColor),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 60.w,
                        width: 60.w,
                        color: AppColors.appBarBackground,
                        child: Icon(
                          Icons.link_outlined,
                          color: AppColors.greys60,
                          size: 40.w,
                        ),
                      ),
                      SizedBox(
                        width: 8.w,
                      ),
                      Container(
                          width: 0.5.sw,
                          child: Text(
                            mediaList[i],
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium!
                                .copyWith(
                                  color: AppColors.disabledTextGrey,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.0.sp,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          )),
                      Spacer(),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _selectedLinks.remove(mediaList[i]);
                            if (_selectedLinks.isEmpty &&
                                _selectedMediaType.contains(MediaConst.link)) {
                              _selectedMediaType.remove(MediaConst.link);
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
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
      ],
    )));
  }

  Widget bottomView() {
    return _discussionActionWidget();
  }

  Widget _discussionActionWidget() {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16).r,
        decoration: BoxDecoration(
            border: Border.all(color: AppColors.grey08),
            borderRadius: BorderRadius.all(const Radius.circular(0.0).r),
            color: Color.fromRGBO(244, 246, 250, 1)),
        child: Row(
          children: [
            if (enableEmoji)
              Padding(
                padding: const EdgeInsets.only(right: 8).r,
                child: GestureDetector(
                  onTap: () {
                    _openEmojiPicker(context);
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
                descriptionFieldController.clearFocus();
                addFileCallBack(selectedMedia);
              },
              enableImageUpload: isMediaUploadEnabled(MediaSource.image),
              enableVideoUpload: isMediaUploadEnabled(MediaSource.video),
              enableFileUpload: isMediaUploadEnabled(MediaSource.file),
            ),
            // Padding(
            //   padding: const EdgeInsets.only(left: 8, right: 8).r,
            //   child: GestureDetector(
            //     onTap: () {
            //       descriptionFieldController.clearFocus();
            //       _addLinkView(context);
            //     },
            //     child: Icon(
            //       Icons.link_outlined,
            //       size: 24.w,
            //       color: AppColors.darkBlue,
            //     ),
            //   ),
            // ),
            Spacer(),
            AnimatedContainer(
              height: 40.w,
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
        ));
  }

  void _openEmojiPicker(BuildContext context) {
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    if (!_emojiVisibilityNotifier.value) {
      _persistentBottomSheetController =
          _scaffoldKey.currentState!.showBottomSheet(
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
          bottom: 0.w,
          left: 0.w,
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
      onEmojiSelected: (category, emoji) async {
        try {
          descriptionFieldController.insertHtml(emoji.emoji);
          descriptionFieldController.disable();
          descriptionFieldController.enable();
        } catch (e) {
          descriptionFieldController.enable();
        }
      },
      onBackspacePressed: () {},
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
          showBackspaceButton: false,
          backgroundColor: AppColors.lightGreyBluish,
          buttonIconColor: AppColors.grey,
        ),
        searchViewConfig: const SearchViewConfig(),
      ),
    );
  }

  Widget _actionButton(bool isTextAdded) {
    return ElevatedButton(
        onPressed: () async {
          FocusScope.of(context).unfocus();
          if (_isLoading.value == false) {
            _saveDiscussion(context, discussionId: _discussionId);
          }
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
}
