import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/services/_services/profile_service.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/learn/course_sharing/chips_input.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/learn/course_sharing/course_sharing_user_data_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_buttons/animated_container.dart';
import '../../../../../constants/_constants/api_endpoints.dart';
import '../../../../../constants/_constants/app_constants.dart'
    show RegExpressions;
import '../../../../../constants/_constants/color_constants.dart';
import '../../../../../respositories/_respositories/profile_repository.dart';
import '../../../../../util/helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../widgets/_common/page_loader.dart';
import '../../../../widgets/title_regular_grey60.dart';

class CourseSharingPage extends StatefulWidget {
  final String courseId;
  final String courseName;
  final String coursePosterImageUrl;
  final String courseProvider;
  final String primaryCategory;
  final Function(String) callback;
  final bool isCourse;

  CourseSharingPage(this.courseId, this.courseName, this.coursePosterImageUrl,
      this.courseProvider, this.primaryCategory, this.callback,
      {this.isCourse = true});
  @override
  _CourseSharingPageState createState() => _CourseSharingPageState();
}

class _CourseSharingPageState extends State<CourseSharingPage>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  final ProfileService profileService = ProfileService();
  final ProfileRepository profileRepository = ProfileRepository();
  List<CourseSharingUserDataModel> selectedRecipients =
      <CourseSharingUserDataModel>[];
  List<CourseSharingUserDataModel> recipientList =
      <CourseSharingUserDataModel>[];
  int searchSize = 250;
  int maxRecipient = 30;
  bool showDialogWidget = false;
  String dialogType = "warning";
  String dialogMessage = "";

  @override
  void initState() {
    super.initState();
  }

  Future<List> _getRecipientList(String query, int limit) async {
    try {
      var response = await profileRepository.getRecipientList(query, limit);
      recipientList = [];
      recipientList = response
          .map((userData) => CourseSharingUserDataModel.fromJson(userData))
          .toList();
    } catch (err) {
      throw err;
    }
    return recipientList;
  }

  Widget getAnimatedWidget() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 26.0).r,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 16, top: 16).r,
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
              ),
              Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.only(left: 16).r,
                child: Image(
                  image: AssetImage('assets/img/karmasahayogi.png'),
                  height: 160.w,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.appBarBackground,
              borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15))
                  .r,
            ),
            child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16).r,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.mContentSharePageHeading,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            letterSpacing: 0.12,
                          ),
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16).r,
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: ChipsInput<CourseSharingUserDataModel>(
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.only(top: 4.0, left: 46)
                                        .r, // Move hint text to the top
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8.0)),
                                  borderSide: BorderSide(
                                    color: AppColors.darkBlue
                                        .withValues(alpha: 1.0), // Border color
                                    width: 1.0.w, // Border width
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8.0)).r,
                                  borderSide: BorderSide(
                                    color: AppColors.darkBlue
                                        .withValues(alpha: 1.0), // Border color
                                    width: 1.0.w, // Border width
                                  ),
                                ),

                                prefixStyle: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(
                                      letterSpacing: 0.25,
                                    ),
                                hintStyle: GoogleFonts.lato(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12.sp,
                                    letterSpacing: 0.25),
                              ),
                              findSuggestions: _findSuggestions,
                              onChanged: _onChanged,
                              chipBuilder: (BuildContext context,
                                  ChipsInputState<CourseSharingUserDataModel>
                                      state,
                                  CourseSharingUserDataModel profile) {
                                return Container(
                                  // alignment: Alignment.centerLeft,
                                  child: InputChip(
                                    key: ObjectKey(profile),
                                    label: Text(
                                      profile.firstName ?? "",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            letterSpacing: 0.25,
                                          ),
                                    ),
                                    deleteIcon: Icon(
                                      Icons.close_sharp,
                                      color:
                                          AppColors.darkBlue.withValues(alpha: 1.0),
                                      size: 24.0.sp, // Adjust icon size
                                    ),
                                    backgroundColor: AppColors.grey08,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.0)
                                          .r, // Adjust border radius
                                    ),
                                    padding:
                                        EdgeInsets.only(left: 16.0, right: 16.0)
                                            .r,
                                    onDeleted: () {
                                      setState(() {
                                        selectedRecipients.remove(profile);
                                        state.deleteChip(selectedRecipients);
                                      });
                                    },
                                    onSelected: (_) => _onChipTapped(profile),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                );
                              },
                              suggestionBuilder: (BuildContext context,
                                  ChipsInputState<CourseSharingUserDataModel>
                                      state,
                                  CourseSharingUserDataModel profile) {
                                return ListTile(
                                  key: ObjectKey(profile),
                                  leading: (((profile
                                                  .profileDetails!
                                                  .personalDetails!
                                                  .profileImageUrl) ??
                                              "") !=
                                          '')
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(63).r,
                                          child: Image(
                                            height: 32.w,
                                            width: 32.w,
                                            fit: BoxFit.fitWidth,
                                            image: NetworkImage(profile
                                                        .profileDetails!
                                                        .personalDetails!
                                                        .profileImageUrl !=
                                                    null
                                                ? Helper.convertGCPImageUrl(
                                                    profile
                                                        .profileDetails!
                                                        .personalDetails!
                                                        .profileImageUrl!)
                                                : ''),
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    SizedBox.shrink(),
                                          ),
                                        )
                                      : Container(
                                          height: 32.w,
                                          width: 32.w,
                                          decoration: BoxDecoration(
                                            color: AppColors.deepBlue,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                                Helper.getInitialsNew(
                                                    (profile.firstName != null
                                                            ? profile.firstName!
                                                            : '') +
                                                        ' ' +
                                                        (profile.firstName !=
                                                                null
                                                            ? profile.firstName!
                                                            : '')),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall!
                                                    .copyWith(
                                                      fontSize: 12.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    )),
                                          ),
                                        ),
                                  title: Text(
                                    profile.firstName!,
                                    style: GoogleFonts.lato(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16.sp,
                                        letterSpacing: 0.25),
                                  ),
                                  subtitle: Text(
                                    profile.maskedEmail!,
                                    style: GoogleFonts.lato(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14.sp,
                                        letterSpacing: 0.25),
                                  ),
                                  onTap: () {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    state.resetSuggestion();
                                    if (alreadyInList(profile.userId!)) {
                                      setState(() {
                                        showDialogWidget = true;
                                        dialogType = "warning";
                                        dialogMessage = AppLocalizations.of(
                                                context)!
                                            .mContentSharePageSimilarEmailWarning;
                                      });
                                      Future.delayed(Duration(seconds: 3), () {
                                        if (mounted)
                                          setState(() {
                                            showDialogWidget = false;
                                          });
                                      });
                                    } else {
                                      if (selectedRecipients.length.toInt() <
                                          maxRecipient.toInt()) {
                                        setState(() {
                                          selectedRecipients.add(profile);
                                        });
                                        state.selectSuggestion(
                                            selectedRecipients);
                                      } else {
                                        setState(() {
                                          showDialogWidget = true;
                                          dialogType = "warning";
                                          dialogMessage = AppLocalizations.of(
                                                  context)!
                                              .mContentSharePageEmailLimitWarning;
                                        });
                                        Future.delayed(Duration(seconds: 3),
                                            () {
                                          if (mounted)
                                            setState(() {
                                              showDialogWidget = false;
                                            });
                                        });
                                      }
                                    }
                                  },
                                );
                              },
                              onPerformAction: (TextInputAction action,
                                  String text,
                                  ChipsInputState<CourseSharingUserDataModel>
                                      state) {
                                if (action == TextInputAction.done) {
                                  _validateEmail(text, state);
                                }
                              },
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 0.7.sw,
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .mContentSharePageNote,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium!
                                      .copyWith(
                                        letterSpacing: 0.25,
                                      ),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Text(
                                "${selectedRecipients.length}/$maxRecipient emails",
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium!
                                    .copyWith(
                                      letterSpacing: 0.25,
                                    ),
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          if (showDialogWidget) _showDialog(),
                        ],
                      ),
                    ),
                    Spacer(),
                    Padding(
                        padding: const EdgeInsets.only(bottom: 4).r,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                await Clipboard.setData(ClipboardData(
                                    text: widget.isCourse
                                        ? "${ApiUrl.baseUrl}/app/toc/${widget.courseId}"
                                        : "${ApiUrl.baseUrl}/app/event-hub/home/${widget.courseId}"));
                                setState(() {
                                  showDialogWidget = true;
                                  dialogType = "success";
                                  dialogMessage = AppLocalizations.of(context)!
                                      .mContentSharePageLinkCopied;
                                });
                                Future.delayed(Duration(seconds: 3), () {
                                  if (mounted)
                                    setState(() {
                                      showDialogWidget = false;
                                    });
                                });
                              },
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                        AppLocalizations.of(context)!.mCopyLink,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall!
                                            .copyWith(
                                              letterSpacing: 0.5,
                                            )),
                                    SizedBox(width: 8.w),
                                    Icon(
                                      Icons.link,
                                      color:
                                          AppColors.darkBlue.withValues(alpha: 1.0),
                                      size: 20.sp,
                                    )
                                  ]),
                            ),
                            SizedBox(
                              width: 26.w,
                            ),
                            ButtonClickEffect(
                                onTap: () async {
                                  if ((selectedRecipients).isNotEmpty) {
                                    if (isLoading) return;
                                    setState(() {
                                      isLoading = true;
                                    });
                                    await submitForm();
                                  } else {
                                    setState(() {
                                      showDialogWidget = true;
                                      dialogType = "warning";
                                      dialogMessage = AppLocalizations.of(
                                              context)!
                                          .mContentSharePageEmptyEmailWarning;
                                    });
                                    Future.delayed(Duration(seconds: 3), () {
                                      if (mounted)
                                        setState(() {
                                          showDialogWidget = false;
                                        });
                                    });
                                  }
                                },
                                opacity: 1.0,
                                child: Container(
                                  width: 80.w,
                                  child: isLoading
                                      ? Padding(
                                          padding: const EdgeInsets.all(8.0).r,
                                          child: Container(
                                              padding: EdgeInsets.only(
                                                      left: 20, right: 20)
                                                  .r,
                                              child: PageLoader(
                                                  strokeWidth: 2,
                                                  isLightTheme: false)),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!
                                                  .mStaticSend,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displaySmall!
                                                  .copyWith(
                                                    letterSpacing: 0.5,
                                                  ),
                                            ),
                                            SizedBox(width: 8.w),
                                            Icon(
                                              Icons.send,
                                              color: AppColors.avatarText,
                                              size: 20.sp,
                                            )
                                          ],
                                        ),
                                )),
                          ],
                        ))
                  ],
                )),
          ),
        ),
      ],
    );
  }

  void _validateEmail(
      String value, ChipsInputState<CourseSharingUserDataModel> state) {
    RegExp regExp = RegExpressions.validEmail;
    if (value.isNotEmpty) {
      String matchedString = regExp.stringMatch(value) ?? "";
      if (matchedString.isNotEmpty && matchedString.length == value.length) {
        if (alreadyInList(value)) {
          setState(() {
            showDialogWidget = true;
            dialogType = "warning";
            dialogMessage = AppLocalizations.of(context)!
                .mContentSharePageSimilarEmailWarning;
          });
          Future.delayed(Duration(seconds: 3), () {
            if (mounted)
              setState(() {
                showDialogWidget = false;
              });
          });
        } else {
          if (selectedRecipients.length.toInt() < maxRecipient.toInt()) {
            CourseSharingUserDataModel profile = CourseSharingUserDataModel(
                firstName: value,
                profileDetails: ProfileDetails(
                    personalDetails: PersonalDetails(
                        profileImageUrl: "", primaryEmail: value)),
                maskedEmail: value,
                userId: value);

            setState(() {
              selectedRecipients.add(profile);
            });
            state.selectSuggestion(selectedRecipients);
          } else {
            setState(() {
              showDialogWidget = true;
              dialogType = "warning";
              dialogMessage = AppLocalizations.of(context)!
                  .mContentSharePageEmailLimitWarning;
            });
            Future.delayed(Duration(seconds: 3), () {
              if (mounted)
                setState(() {
                  showDialogWidget = false;
                });
            });
          }
        }
      } else {
        setState(() {
          showDialogWidget = true;
          dialogType = "warning";
          dialogMessage =
              AppLocalizations.of(context)!.mContentSharePageInvalidEmailError;
        });
        Future.delayed(Duration(seconds: 3), () {
          if (mounted)
            setState(() {
              showDialogWidget = false;
            });
        });
      }
    }
  }

  void _onChipTapped(CourseSharingUserDataModel profile) {}

  void _onChanged(List<CourseSharingUserDataModel> data) {}

  Future<List<CourseSharingUserDataModel>> _findSuggestions(
      String query) async {
    if (selectedRecipients.length.toInt() < maxRecipient.toInt()) {
      if (query.length != 0 && query.length >= 1) {
        await _getRecipientList(query, searchSize);
        return recipientList;
      } else {
        return [];
      }
    } else {
      recipientList = [];
      setState(() {
        showDialogWidget = true;
        dialogType = "warning";
        dialogMessage =
            AppLocalizations.of(context)!.mContentSharePageEmailLimitWarning;
      });
      Future.delayed(Duration(seconds: 3), () {
        if (mounted)
          setState(() {
            showDialogWidget = false;
          });
      });
      return [];
    }
  }

  bool alreadyInList(String userId) {
    for (int i = 0; i < selectedRecipients.length; i++) {
      if (selectedRecipients[i].userId.toString() == userId.toString()) {
        return true;
      }
    }
    return false; // Return the original email if the format is invalid
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
        duration: Duration(seconds: 1), // Duration for the animation
        curve: Curves.fastOutSlowIn, // Animation curve (e.g., ease-in-out)
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).orientation == Orientation.portrait
                ? 1.sh
                : 1.sw,
            child: getAnimatedWidget(),
          ),
        ));
  }

  submitForm() async {
    var recipients = [];

    for (int i = 0; i < selectedRecipients.length; i++) {
      var _recipient = {};
      _recipient["userId"] = selectedRecipients[i].userId;
      _recipient["email"] =
          selectedRecipients[i].profileDetails!.personalDetails!.primaryEmail;
      recipients.add(_recipient);
    }
    var formResponse = await profileService.shareCourse(
        recipients,
        widget.courseId,
        widget.courseName,
        widget.coursePosterImageUrl,
        widget.courseProvider,
        widget.primaryCategory);
    if (formResponse == "success") {
      widget.callback(formResponse);
      Navigator.of(context).pop();
    } else {
      setState(() {
        showDialogWidget = true;
        dialogType = "error";
        dialogMessage =
            AppLocalizations.of(context)!.mContentSharePageSharingError;
      });
      Future.delayed(Duration(seconds: 3), () {
        if (mounted)
          setState(() {
            showDialogWidget = false;
          });
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  Widget _showDialog() {
    return Container(
      margin: EdgeInsets.only(top: 16).r,
      padding: EdgeInsets.all(16).r,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12).r,
          color: (dialogType == "success")
              ? AppColors.positiveLight
              : AppColors.negativeLight),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Container(
              child: TitleRegularGrey60(
                dialogMessage,
                fontSize: 14.sp,
                color: AppColors.appBarBackground,
                maxLines: 3,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 4, 0).r,
            child: Icon(
              (dialogType == "success") ? Icons.check : Icons.info_outline,
              color: AppColors.appBarBackground,
              size: 24.sp,
            ),
          ),
        ],
      ),
    );
  }
}
