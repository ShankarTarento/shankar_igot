import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../constants/index.dart';
import '../../../../../pages/_pages/search/utils/search_helper.dart';
import '../../../../../widgets/_common/button_widget_v2.dart';
import '../../../../../widgets/_discussion_hub/screens/discussion/add_discussion/_models/media_upload_model.dart';

import '../widgets/field_name_widget.dart';
import '../../../../../widgets/index.dart';
import '../../view_model/profile_achievement_view_model.dart';
import '../widgets/date_widget.dart';
import '../widgets/drag_file_to_upload.dart';
import '../widgets/profile_edit_hearder.dart';

class AchievementEdit extends StatefulWidget {
  final bool isUpdate;
  final bool showAll;
  final String? title;
  final String? issueOrg;
  final String? url;
  final String? description;
  final String? issueDate;
  final String? documentUrl;
  final String? documentName;
  final String? uuid;
  final VoidCallback updateCallback;
  const AchievementEdit(
      {Key? key,
      this.isUpdate = false,
      this.showAll = false,
      this.title,
      this.issueOrg,
      this.url,
      this.description,
      this.issueDate,
      this.documentUrl,
      this.documentName,
      this.uuid,
      required this.updateCallback})
      : super(key: key);
  @override
  State<AchievementEdit> createState() => _AchievementEditState();
}

class _AchievementEditState extends State<AchievementEdit> {
  ValueNotifier<bool> isChanged = ValueNotifier(false);
  TextEditingController titleController = TextEditingController();
  TextEditingController issueOrgController = TextEditingController();
  TextEditingController urlController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  ValueNotifier<MediaUploadModel?> selectedFile =
      ValueNotifier<MediaUploadModel?>(null);
  ValueNotifier<String?> titleErrorText = ValueNotifier<String?>(null);
  ValueNotifier<String?> issueOrgErrorText = ValueNotifier<String?>(null);
  ValueNotifier<String?> urlErrorText = ValueNotifier<String?>(null);
  ValueNotifier<String?> descriptionErrorText = ValueNotifier<String?>(null);
  DateTime? issuedDate;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.title ?? '';
    issueOrgController.text = widget.issueOrg ?? '';
    urlController.text = widget.url ?? '';
    descriptionController.text = widget.description ?? '';
    issuedDate = DateTime.tryParse(widget.issueDate ?? '');
    if (widget.documentUrl != null && widget.documentUrl!.isNotEmpty) {
      selectedFile.value = MediaUploadModel(
          fileUrl: widget.documentUrl,
          fileName: widget.documentName,
          isUploaded: true,
          isErrorFile: false);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    issueOrgController.dispose();
    urlController.dispose();
    descriptionController.dispose();
    isChanged.dispose();
    titleErrorText.dispose();
    issueOrgErrorText.dispose();
    urlErrorText.dispose();
    descriptionErrorText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 32).r,
          child: GestureDetector(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: Padding(
                  padding: const EdgeInsets.all(16.0).r,
                  child: Column(children: [
                    ProfileEditHeader(
                        title:
                            AppLocalizations.of(context)!.mProfileAchievements,
                        callback: () => Navigator.pop(context)),
                    Expanded(
                        child: SingleChildScrollView(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                          // Title
                          FieldNameWidget(
                              isMandatory: true,
                              fieldName:
                                  AppLocalizations.of(context)!.mStaticTitle),
                          SizedBox(height: 8.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              getTextField(
                                  titleController,
                                  AppLocalizations.of(context)!
                                      .mProfileAchievementTitleLabel,
                                  maxLength: 250, onChanged: (value) {
                                if (value.isEmpty) {
                                  titleErrorText.value =
                                      AppLocalizations.of(context)!
                                          .mStaticTitleIsEmpty;
                                  isChanged.value = false;
                                } else if (RegExpressions
                                    .alphabetsWithAmbresandHyphenSlashParentheses
                                    .hasMatch(value)) {
                                  titleErrorText.value = null;
                                  bool status = checkChanges();
                                  if (status != isChanged.value) {
                                    isChanged.value = status;
                                    setState(() {});
                                  }
                                } else {
                                  titleErrorText.value =
                                      AppLocalizations.of(context)!
                                          .mProfileAchievementError('() & - /');
                                  isChanged.value = false;
                                }
                              }),
                              ValueListenableBuilder(
                                  valueListenable: titleErrorText,
                                  builder: (context, value, child) {
                                    return Visibility(
                                      visible: value != null,
                                      child: Text(value ?? '',
                                          maxLines: 2,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall!
                                              .copyWith(
                                                  color:
                                                      AppColors.negativeLight)),
                                    );
                                  })
                            ],
                          ),
                          // Issuing Organisation
                          FieldNameWidget(
                              fieldName: AppLocalizations.of(context)!
                                  .mProfileIssuingOrg),
                          SizedBox(height: 8.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              getTextField(
                                  issueOrgController,
                                  AppLocalizations.of(context)!
                                      .mProfileAchievementIssueOrgLabel,
                                  maxLength: 250, onChanged: (value) {
                                if (value.isEmpty ||
                                    RegExpressions
                                        .alphabetsWithAmbresandParentheses
                                        .hasMatch(value)) {
                                  issueOrgErrorText.value = null;
                                  bool status = checkChanges();
                                  if (status != isChanged.value) {
                                    isChanged.value = status;
                                    setState(() {});
                                  }
                                } else {
                                  issueOrgErrorText.value =
                                      AppLocalizations.of(context)!
                                          .mProfileAchievementError('() &');
                                  isChanged.value = false;
                                }
                              }),
                              ValueListenableBuilder(
                                  valueListenable: issueOrgErrorText,
                                  builder: (context, value, child) {
                                    return Visibility(
                                      visible: value != null,
                                      child: Text(value ?? '',
                                          maxLines: 2,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall!
                                              .copyWith(
                                                  color:
                                                      AppColors.negativeLight)),
                                    );
                                  })
                            ],
                          ),
                          // Issue Date
                          FieldNameWidget(
                            fieldName:
                                AppLocalizations.of(context)!.mProfileIssueDate,
                          ),
                          DateWidget(
                              date: issuedDate,
                              endDate: DateTime.now(),
                              updateDate: (picked) => setState(() {
                                    issuedDate = picked;
                                    bool status = checkChanges();
                                    if (status != isChanged.value) {
                                      isChanged.value = status;
                                    }
                                  })),
                          // Upload from System
                          FieldNameWidget(
                            fieldName: AppLocalizations.of(context)!
                                .mProfileUploadFromSystem,
                          ),
                          SizedBox(height: 8.w),
                          DragFileToUpload(
                              documentUrl: widget.documentUrl,
                              documentName: widget.documentName,
                              enabled: urlController.text.isEmpty,
                              uploadCallback: (MediaUploadModel? file) {
                                urlController.text = '';
                                selectedFile.value = file;
                                bool status = checkChanges();
                                if (status != isChanged.value) {
                                  isChanged.value = status;
                                }
                              }),
                          // URL
                          Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8).r,
                                child: Text(
                                  AppLocalizations.of(context)!.mProfileUrl,
                                  style:
                                      Theme.of(context).textTheme.displayLarge,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              TooltipWidget(
                                message: AppLocalizations.of(context)!
                                    .mProfileProvideLinkForAchievement,
                              )
                            ],
                          ),
                          ValueListenableBuilder<MediaUploadModel?>(
                              valueListenable: selectedFile,
                              builder: (context, value, child) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    getTextField(
                                        urlController,
                                        AppLocalizations.of(context)!
                                            .mProfileUrl,
                                        enabled: value == null,
                                        onChanged: (value) {
                                      if (value.isEmpty ||
                                          value.contains('http') ||
                                          value.contains('https')) {
                                        urlErrorText.value = null;
                                        bool status = checkChanges();
                                        if (status != isChanged.value) {
                                          isChanged.value = status;
                                          setState(() {});
                                        }
                                      } else {
                                        urlErrorText.value =
                                            AppLocalizations.of(context)!
                                                .mStaticInvalidLink;
                                        isChanged.value = false;
                                      }
                                    }),
                                    ValueListenableBuilder(
                                        valueListenable: urlErrorText,
                                        builder: (context, value, child) {
                                          return Visibility(
                                            visible: value != null,
                                            child: Text(value ?? '',
                                                maxLines: 2,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall!
                                                    .copyWith(
                                                        color: AppColors
                                                            .negativeLight)),
                                          );
                                        })
                                  ],
                                );
                              }),
                          // Description
                          FieldNameWidget(
                            fieldName: AppLocalizations.of(context)!
                                .mProfileDescription,
                          ),
                          SizedBox(height: 8.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              getTextField(
                                  descriptionController,
                                  AppLocalizations.of(context)!
                                      .mProfileAchievementDescriptionLabel,
                                  minLines: 8,
                                  maxLines: 8,
                                  radius: 8,
                                  maxLength: 500, onChanged: (value) {
                                if (value.isEmpty ||
                                    RegExpressions
                                        .alphabetWithAmbresandDotCommaSlashBracketHyphen
                                        .hasMatch(value)) {
                                  descriptionErrorText.value = null;
                                  bool status = checkChanges();
                                  if (status != isChanged.value) {
                                    isChanged.value = status;
                                    setState(() {});
                                  }
                                } else {
                                  descriptionErrorText.value =
                                      AppLocalizations.of(context)!
                                          .mProfileAchievementError(
                                              '( ) & - / . , ');
                                  isChanged.value = false;
                                }
                              }),
                              ValueListenableBuilder(
                                  valueListenable: descriptionErrorText,
                                  builder: (context, value, child) {
                                    return Visibility(
                                      visible: value != null,
                                      child: Text(value ?? '',
                                          maxLines: 2,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall!
                                              .copyWith(
                                                  color:
                                                      AppColors.negativeLight)),
                                    );
                                  })
                            ],
                          ),
                          SizedBox(height: 40.w)
                        ]))),
                    Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                            width: 0.8.sw,
                            child: ValueListenableBuilder(
                                valueListenable: isChanged,
                                builder: (BuildContext context, bool isChanged,
                                    Widget? child) {
                                  return ButtonWidgetV2(
                                      text: widget.isUpdate
                                          ? AppLocalizations.of(context)!
                                              .mCommonupdate
                                          : AppLocalizations.of(context)!
                                              .mEditProfileAdd,
                                      textColor: AppColors.appBarBackground,
                                      // isLoading: savePressed,
                                      bgColor: isChanged
                                          ? AppColors.darkBlue
                                          : AppColors.grey40,
                                      onTap: isChanged
                                          ? () async {
                                              widget.isUpdate
                                                  ? titleController.text.isEmpty
                                                      ? SearchHelper().showOverlayMessage(
                                                          AppLocalizations.of(context)!
                                                              .mStaticPleaseFillAllMandatory,
                                                          context,
                                                          duration: 3)
                                                      : await ProfileAchievementViewModel().updateAchievements(context,
                                                          title: titleController.text !=
                                                                  widget.title
                                                              ? titleController
                                                                  .text
                                                              : '',
                                                          issuedOrganisation:
                                                              issueOrgController.text != widget.issueOrg
                                                                  ? issueOrgController
                                                                      .text
                                                                  : '',
                                                          issueDate: issuedDate != null && issuedDate!.toIso8601String() != widget.issueDate
                                                              ? issuedDate!
                                                                  .toIso8601String()
                                                              : '',
                                                          url: urlController.text != widget.url
                                                              ? urlController.text
                                                              : null,
                                                          uuid: widget.uuid ?? '',
                                                          uploadedDocument: selectedFile.value != null ? selectedFile.value!.file : null,
                                                          uploadedDocumentUrl: selectedFile.value == null && widget.documentUrl != null ? '' : null,
                                                          description: descriptionController.text != widget.description ? descriptionController.text.trim() : null)
                                                  : await ProfileAchievementViewModel().addAchievements(context, title: titleController.text, issuedOrganisation: issueOrgController.text, issueDate: issuedDate?.toIso8601String() ?? '', url: urlController.text.isNotEmpty ? urlController.text : null, description: descriptionController.text.isNotEmpty ? descriptionController.text : null, uploadedDocument: selectedFile.value != null ? selectedFile.value!.file : null);
                                              widget.updateCallback();
                                            }
                                          : null);
                                })))
                  ]))),
        ),
      ),
    );
  }

  Widget getTextField(TextEditingController controller, String hintText,
      {int maxLines = 1,
      int minLines = 1,
      bool enabled = true,
      int? maxLength,
      required Function(String) onChanged,
      double radius = 63}) {
    return TextField(
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      enabled: enabled,
      controller: controller,
      onChanged: (value) {
        onChanged(value);
      },
      style: Theme.of(context)
          .textTheme
          .labelLarge!
          .copyWith(color: AppColors.greys),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 2).r,
        hintText: hintText,
        hintStyle: Theme.of(context).textTheme.labelLarge,
        filled: !enabled,
        fillColor: AppColors.grey16,
        counterStyle: Theme.of(context)
            .textTheme
            .labelSmall!
            .copyWith(color: AppColors.grey40),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius).r,
          borderSide: BorderSide(color: AppColors.grey24),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius).r,
          borderSide: BorderSide(color: AppColors.grey24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius).r,
          borderSide: BorderSide(color: AppColors.darkBlue),
        ),
      ),
    );
  }

  bool checkChanges() {
    final bool titleChanged =
        titleController.text.isNotEmpty && titleController.text != widget.title;
    final bool orgChanged = issueOrgController.text.isNotEmpty &&
        issueOrgController.text != widget.issueOrg;
    final bool urlChanged =
        urlController.text.isNotEmpty && urlController.text != widget.url;
    final bool descChanged = descriptionController.text.isNotEmpty &&
        descriptionController.text != widget.description;
    final bool dateChanged =
        issuedDate != null && issuedDate!.toIso8601String() != widget.issueDate;
    final bool fileChanged = selectedFile.value != null ||
        (selectedFile.value == null && widget.documentUrl != null);

    final bool titleValid = RegExpressions
            .alphabetsWithAmbresandHyphenSlashParentheses
            .hasMatch(titleController.text) ||
        titleController.text.isEmpty;
    final bool orgValid = RegExpressions.alphabetsWithAmbresandParentheses
            .hasMatch(issueOrgController.text) ||
        issueOrgController.text.isEmpty;
    final bool urlValid = urlController.text.isEmpty ||
        urlController.text.contains('http') ||
        urlController.text.contains('https');
    final bool descValid = RegExpressions
            .alphabetWithAmbresandDotCommaSlashBracketHyphen
            .hasMatch(descriptionController.text) ||
        descriptionController.text.isEmpty;

    final bool anyChanged = titleChanged ||
        orgChanged ||
        urlChanged ||
        descChanged ||
        dateChanged ||
        fileChanged;
    final bool allValid = titleValid && orgValid && urlValid && descValid;

    return anyChanged && allValid;
  }
}
