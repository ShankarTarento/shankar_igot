import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/ui/widgets/alert_dialog/alert_dialog.dart';
import 'package:karmayogi_mobile/constants/_constants/learn_compatibility_constants.dart';
import 'package:karmayogi_mobile/models/_models/assessment_info_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/_assessment/_models/guest_data_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/_assessment/_widget/guest_detail_form.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import '../../../../constants/index.dart';
import '../../../../models/_models/assessment_save_point_model.dart';
import '../../../../models/index.dart';
import '../../../../respositories/_respositories/assessment_repository.dart';
import '../../../pages/_pages/toc/model/assessment_response_data_model.dart';
import '../../../pages/_pages/toc/model/navigation_model.dart';
import '../../../pages/_pages/toc/util/assessment_view_model.dart';
import '../../../pages/_pages/toc/util/toc_helper.dart';
import '../../../skeleton/pages/assessment_instruction_skeleton.dart';
import '../../_common/page_loader.dart';
import '../_assessment/assessment_start_button_widget.dart';
import './../../../../feedback/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CourseAssessmentPlayer extends StatefulWidget {
  final CourseHierarchyModel course;
  final String identifier;
  final ValueChanged<Map> parentAction;
  final String batchId;
  final String parentCourseId;
  final int compatibilityLevel;
  final ValueChanged<bool>? playNextResource;
  final NavigationModel resourceNavigateItems;
  final bool isFeatured;
  final String courseCategory;
  final bool isPreRequisite;
  CourseAssessmentPlayer(
      this.course, this.identifier, this.parentAction, this.batchId,
      {required this.parentCourseId,
      required this.resourceNavigateItems,
      this.playNextResource,
      this.compatibilityLevel = 0,
      this.isFeatured = false,
      required this.courseCategory,
      this.isPreRequisite = false});
  @override
  _CourseAssessmentPlayerState createState() => _CourseAssessmentPlayerState();
}

class _CourseAssessmentPlayerState extends State<CourseAssessmentPlayer> {
  Map? _microSurvey;
  AssessmentInfo? _assessmentInfo;
  var _retakeInfo;
  var _questionSet = [];
  bool isConfirmed = false;
  Future<dynamic>? futureGetAssessmentData;
  SavePointModel? savePointInfo;
  bool isV2Assessment = false;
  NavigationModel? resourceInfo;
  AssessmentRepository assessmentRepository = AssessmentRepository();
  GuestDataModel? _guestUserData;
  String? _preRequisiteCollectionIdentifier;

  @override
  void initState() {
    super.initState();
    futureGetAssessmentData = _loadData();
  }

  Future<dynamic> _loadData() async {
    resourceInfo = await TocHelper.getResourceInfo(
        context: context,
        resourceId: widget.identifier,
        isFeatured: widget.isFeatured,
        resourceNavigateItems: widget.resourceNavigateItems);

    if (widget.isFeatured) {
      return await _loadPublicAssessmentData();
    } else {
      return await _getAssessmentData();
    }
  }

  Future<dynamic> _loadPublicAssessmentData() async {
    final completer = Completer();
    if (resourceInfo != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (resourceInfo!.primaryCategory ==
                PrimaryCategory.practiceAssessment ||
            AssessmentViewModel().isAssessmentWithFileURL(resourceInfo!)) {
          showDialog(
              context: context,
              builder: (BuildContext cxt) {
                return AlertDialogWidget(
                  dialogRadius: 8,
                  subtitle:
                      AppLocalizations.of(context)!.mStaticLoginToAccessContent,
                  primaryButtonText: AppLocalizations.of(context)!.mStaticOk,
                  onPrimaryButtonPressed: () async {
                    Navigator.of(cxt).pop();
                    Navigator.of(context).pop();
                    completer.complete();
                  },
                  primaryButtonTextStyle: GoogleFonts.lato(
                    color: AppColors.appBarBackground,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.0.sp,
                    height: 1.5.w,
                  ),
                  primaryButtonBgColor: AppColors.darkBlue,
                );
              });
        } else {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            isDismissible: false,
            enableDrag: false,
            backgroundColor: AppColors.grey04.withValues(alpha: 0.36),
            builder: (BuildContext context) {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 32).r,
                  child: GuestDetailForm(
                    submitCallback: (guestUSerDetails) async {
                      _guestUserData = await guestUSerDetails;
                      final result = await _getAssessmentData();
                      setState(() {});
                      completer.complete(result);
                      return result;
                    },
                    closeCallback: () {
                      Navigator.pop(context);
                      completer.complete();
                    },
                  ),
                ),
              );
            },
          );
        }
      });
    }
  }

  Future<dynamic> _getAssessmentData() async {
    var response;
    try {
      AssessmentResponseDataModel? assessmentData;
      if (widget.isPreRequisite) {
        AssessmentChild? assessmentChild =
            await AssessmentViewModel().getPreRequisiteAssessmentData(
          identifier: widget.identifier,
          isFeatured: widget.isFeatured,
        );
        if (assessmentChild != null) {
          _preRequisiteCollectionIdentifier = assessmentChild.identifier;
          assessmentData = await AssessmentViewModel().getAssessmentData(
              context: context,
              resourceInfo: resourceInfo,
              parentCourseId: widget.parentCourseId,
              courseCategory: widget.courseCategory,
              courseId: widget.course.identifier,
              identifier: assessmentChild.identifier,
              compatibilityLevel: widget.compatibilityLevel,
              isFeatured: widget.isFeatured,
              guestUserData: _guestUserData);
        } else {
          Helper.showSnackBarMessage(
              context: context,
              text: AppLocalizations.of(context)!.mStaticSomethingWrongTryLater,
              bgColor: AppColors.blackLegend,
              durationInSec: 5);
        }
      } else {
        assessmentData = await AssessmentViewModel().getAssessmentData(
            context: context,
            resourceInfo: resourceInfo,
            parentCourseId: widget.parentCourseId,
            courseCategory: widget.courseCategory,
            courseId: widget.course.identifier,
            identifier: widget.identifier,
            compatibilityLevel: widget.compatibilityLevel,
            isFeatured: widget.isFeatured,
            guestUserData: _guestUserData);
      }

      _questionSet.clear();
      if (assessmentData != null) {
        if (assessmentData.assessmentInfo != null &&
            assessmentData.assessmentInfo!.errMessage == null) {
          _assessmentInfo = assessmentData.assessmentInfo;
        } else if (assessmentData.assessmentInfo != null &&
            assessmentData.assessmentInfo!.errMessage != null) {
          Helper.showSnackBarMessage(
              context: context,
              text: assessmentData.assessmentInfo!.errMessage,
              bgColor: AppColors.blackLegend,
              durationInSec: 5);
          Future.delayed(
              Duration(seconds: 5), (() => Navigator.of(context).pop()));
        }
        _questionSet = assessmentData.questionSet;
        _retakeInfo = assessmentData.retakeInfo;
        response = assessmentData.assessmentResponse;
      }
      return _retakeInfo != null
          ? _retakeInfo['attemptsMade'] >= _retakeInfo['attemptsAllowed']
              ? AssessmentQuestionStatus.retakeNotAllowed
              : response
          : response;
    } catch (e) {
      print("Error fetching assessment data: $e");
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppColors.primaryBlue,
    ));
    return SafeArea(
      child: FutureBuilder(
          future: futureGetAssessmentData,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.data != null &&
                snapshot.data != AssessmentQuestionStatus.retakeNotAllowed) {
              _microSurvey = snapshot.data;
            }
            if (snapshot.hasData || _assessmentInfo != null) {
              if (widget.compatibilityLevel >=
                  AssessmentCompatibility.multimediaCompatibility.version) {
                if (snapshot.data != null &&
                    snapshot.data ==
                        AssessmentQuestionStatus.retakeNotAllowed &&
                    _assessmentInfo == null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _limitExceededCallback(context);
                  });
                  return Scaffold(
                    body: Center(
                        child: Container(
                      padding: EdgeInsets.all(32).r,
                    )),
                  );
                } else {
                  return Scaffold(
                    appBar: PreferredSize(
                      preferredSize:
                          Size.fromHeight(70.w), // Set the preferred height
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.scaffoldBackground,
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.grey16,
                              width: 2.0.w,
                            ),
                          ),
                        ),
                        child: AppBar(
                          backgroundColor: AppColors.scaffoldBackground,
                          automaticallyImplyLeading: false,
                          shadowColor: Colors.transparent,
                          toolbarHeight: 70.w,
                          leading: InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            child: Icon(
                              Icons.arrow_back_ios,
                              color: AppColors.grey40,
                              size: 24.w,
                            ),
                          ),
                          title: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20).r,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: _cardHeadingItems()),
                                  SizedBox(
                                      width: 1.0.sw / 2.3,
                                      child: AssessmentStartBtnWidget(
                                          assessmentInfo: _assessmentInfo!,
                                          batchId: widget.batchId,
                                          course: widget.course,
                                          identifier: (widget.isPreRequisite) ? (_preRequisiteCollectionIdentifier??'') : widget.identifier,
                                          microSurvey: _microSurvey,
                                          parentAction: widget.parentAction,
                                          parentCourseId: widget.parentCourseId,
                                          playNextResource:
                                              widget.playNextResource,
                                          questionSet: _questionSet,
                                          retakeInfo: _retakeInfo,
                                          isConfirmed: isConfirmed,
                                          compatibilityLevel:
                                              widget.compatibilityLevel,
                                          savePointInfo: savePointInfo,
                                          resourceInfo: resourceInfo!,
                                          isFeatured: widget.isFeatured,
                                          courseCategory: widget.courseCategory,
                                          guestUserData: _guestUserData,
                                          isPreRequisite: widget.isPreRequisite,
                                          preEnrolmentAssessmentId: (widget.isPreRequisite) ? widget.identifier : null,
                                          preRequisiteMimeType: (widget.isPreRequisite) ? (widget.resourceNavigateItems.mimeType ?? '') : "",
                                      ))
                                ],
                              )),
                        ),
                      ),
                    ),
                    body: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 20)
                                .r,
                            child: SingleChildScrollView(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(resourceInfo!.name ?? '',
                                    style: GoogleFonts.lato(
                                      color: AppColors.greys87,
                                      fontSize: 20.0.sp,
                                      fontWeight: FontWeight.w400,
                                    )),
                                SizedBox(
                                  height: 32.w,
                                ),
                                _assessmentInfo != null
                                    ? HtmlWidget(
                                        Helper.decodeHtmlEntities(
                                            _assessmentInfo!.description),
                                        textStyle: TextStyle(fontSize: 14.sp),
                                      )
                                    : Center(),
                                SizedBox(
                                  height: 32.w,
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 20.w,
                                      height: 20.w,
                                      child: Checkbox(
                                        value: isConfirmed,
                                        activeColor: AppColors.darkBlue,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            isConfirmed = value!;
                                          });
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    SizedBox(
                                      width: 0.8.sw,
                                      child: Wrap(
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              text: AppLocalizations.of(
                                                      context)!
                                                  .mAssessmentInstructionAgreeStatemetPrefix,
                                              style: GoogleFonts.lato(
                                                color: AppColors.greys,
                                                fontSize: 16.0.sp,
                                                height: 1.5.w,
                                                fontWeight: FontWeight.w400,
                                              ),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text: AppLocalizations.of(
                                                          context)!
                                                      .mAssessmentInstructionAgreeStatemetMiddle,
                                                  style: GoogleFonts.lato(
                                                    color: AppColors.greys,
                                                    fontSize: 16.0.sp,
                                                    height: 1.5,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                TextSpan(
                                                    text: AppLocalizations.of(
                                                            context)!
                                                        .mAssessmentInstructionAgreeStatemetSuffix,
                                                    style: GoogleFonts.lato(
                                                      color: AppColors.greys,
                                                      fontSize: 16.0.sp,
                                                      height: 1.5.w,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    )),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              } else {
                return Scaffold(
                  body: SafeArea(
                    child: _buildLayout(),
                  ),
                  bottomSheet: AssessmentStartBtnWidget(
                      assessmentInfo: _assessmentInfo,
                      batchId: widget.batchId,
                      course: widget.course,
                      identifier: (widget.isPreRequisite) ? (_preRequisiteCollectionIdentifier??'') : widget.identifier,
                      microSurvey: _microSurvey,
                      parentAction: widget.parentAction,
                      parentCourseId: widget.parentCourseId,
                      playNextResource: widget.playNextResource,
                      questionSet: _questionSet,
                      retakeInfo: _retakeInfo,
                      compatibilityLevel: widget.compatibilityLevel,
                      resourceInfo: resourceInfo!,
                      isFeatured: widget.isFeatured,
                      courseCategory: widget.courseCategory,
                      guestUserData: _guestUserData,
                      isPreRequisite: widget.isPreRequisite,
                      preEnrolmentAssessmentId: (widget.isPreRequisite) ? widget.identifier : null,
                      preRequisiteMimeType: (widget.isPreRequisite) ? (widget.resourceNavigateItems.mimeType ?? '') : "",
                  ),
                );
              }
            } else {
              return widget.compatibilityLevel >=
                      AssessmentCompatibility.multimediaCompatibility.version
                  ? AssessmentInstructionSkeleton(
                      primaryCategory:
                          widget.resourceNavigateItems.primaryCategory,
                    )
                  : Scaffold(
                      appBar: AppBar(
                          elevation: 0,
                          leading: IconButton(
                              icon: Icon(
                                Icons.close,
                                color: AppColors.greys87,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              }),
                          title: Padding(
                              padding: const EdgeInsets.only(left: 0).r,
                              child: Text(
                                '',
                                style: GoogleFonts.lato(
                                  color: AppColors.greys87,
                                  fontSize: 16.0.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ))),
                      body: PageLoader());
            }
          }),
    );
  }

  Widget _getAppbar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppBar(
          backgroundColor: AppColors.primaryBlue,
          titleSpacing: 0,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close,
                size: 20.sp, color: AppColors.appBarBackground),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32).r,
            child: Text(
              resourceInfo!.name ?? '',
              style: GoogleFonts.montserrat(
                color: AppColors.appBarBackground,
                fontSize: 24.0.sp,
                fontWeight: FontWeight.w600,
              ),
            )),
      ],
    );
  }

  Widget _buildLayout() {
    return Container(
      color: AppColors.primaryBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_getAppbar(), _containerBody()],
      ),
    );
  }

  Widget _containerBody() {
    return Expanded(
        child: ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16.0),
        topRight: Radius.circular(16.0),
      ).r,
      child: Container(
          padding:
              const EdgeInsets.only(left: 24, top: 24, right: 24, bottom: 90).r,
          color: AppColors.appBarBackground,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _cardHeadingItems(),
                Divider(
                  thickness: 1,
                  color: AppColors.grey16,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 16).r,
                  child: Text(
                    AppLocalizations.of(context)!.mStaticSummary,
                    style: GoogleFonts.lato(
                      color: AppColors.greys60,
                      fontSize: 14.0.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                _informationCard(),
              ],
            ),
          )),
    ));
  }

  Widget _cardHeadingItems() {
    int questionCount = 0;
    if (_microSurvey == null) {
      _questionSet.forEach((set) {
        questionCount += int.parse(set.length.toString());
      });
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: (resourceInfo!.primaryCategory ==
                      PrimaryCategory.practiceAssessment &&
                  widget.compatibilityLevel <
                      AssessmentCompatibility.multimediaCompatibility.version
              ? practiceScenario4summary(context)
              : scenario4summary(context))
          .map(
            (informationCard) => _headingItem(
                informationCard.icon,
                informationCard.scenarioNumber == 1
                    ? '${_microSurvey != null ? _microSurvey!['questions'].length : _questionSet.isNotEmpty ? questionCount : _assessmentInfo!.maxQuestions} ${AppLocalizations.of(context)!.mCommonQuestions}'
                    : informationCard.scenarioNumber == 2
                        ? (_retakeInfo != null
                            ? '${AppLocalizations.of(context)!.mStaticMaximum} ${_retakeInfo['attemptsAllowed']} ${AppLocalizations.of(context)!.mStaticRetakeAssesmentMessage} ${_retakeInfo['attemptsMade']} ${AppLocalizations.of(context)!.mStaticTime}'
                            : AppLocalizations.of(context)!
                                .mStaticUnlimitedRetakes)
                        : (_assessmentInfo != null &&
                                _assessmentInfo!.expectedDuration != null
                            ? DateTimeHelper.getFullTimeFormat(
                                _assessmentInfo!.expectedDuration.toString(),
                                timelyDurationFlag: true)
                            : resourceInfo!.duration.toString().contains('-')
                                ? resourceInfo!.duration
                                    .toString()
                                    .split('-')
                                    .last
                                : DateTimeHelper.getFullTimeFormat(
                                    resourceInfo!.duration.toString())),
                informationCard.iconColor),
          )
          .toList(),
    );
  }

  Widget _headingItem(IconData icon, String information, Color iconColor) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8, right: 6).r,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20.sp, color: iconColor),
            Padding(
              padding: const EdgeInsets.only(top: 4).r,
              child: Container(
                alignment: Alignment.centerLeft,
                width: 0.7.sw,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    information,
                    style: GoogleFonts.lato(
                        color: AppColors.greys87,
                        fontSize: 14.0.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _informationCard() {
    return Container(
      width: double.infinity.w,
      padding: EdgeInsets.only(bottom: 24).r,
      margin: EdgeInsets.only(bottom: 16).r,
      decoration: BoxDecoration(
        color: AppColors.appBarBackground,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: (resourceInfo!.primaryCategory ==
                        PrimaryCategory.practiceAssessment
                    ? practiceScenario4Info(context)
                    : isV2Assessment
                        ? scenarioV2Info(context)
                        : scenario4Info(context))
                .map(
                  (informationCard) =>
                      _informationItem(informationCard.information),
                )
                .toList(),
          )
        ],
      ),
    );
  }

  Widget _informationItem(String information) {
    return Container(
      margin: EdgeInsets.only(top: 8, bottom: 8).r,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6).r,
            child: Icon(Icons.circle, size: 6.sp, color: AppColors.primaryOne),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16).r,
            child: Container(
              width: 0.8.sw,
              child: Text(
                information,
                style: GoogleFonts.lato(
                  color: AppColors.greys87,
                  fontSize: 14.0.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future _limitExceededCallback(BuildContext context) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext cxt) {
          return AlertDialogWidget(
            dialogRadius: 8,
            icon: SvgPicture.asset(
              'assets/img/file_info_icon.svg',
              colorFilter:
                  ColorFilter.mode(AppColors.darkBlue, BlendMode.srcIn),
              width: 38.0.w,
              height: 40.0.w,
            ),
            subtitle:
                AppLocalizations.of(context)!.mAssessmentRetakeLimitExceed,
            primaryButtonText: AppLocalizations.of(context)!.mStaticOk,
            onPrimaryButtonPressed: () async {
              Navigator.of(cxt).pop();
              Navigator.of(context).pop();
            },
            primaryButtonTextStyle: GoogleFonts.lato(
              color: AppColors.appBarBackground,
              fontWeight: FontWeight.w700,
              fontSize: 14.0.sp,
              height: 1.5.w,
            ),
            primaryButtonBgColor: AppColors.darkBlue,
          );
        });
  }
}
