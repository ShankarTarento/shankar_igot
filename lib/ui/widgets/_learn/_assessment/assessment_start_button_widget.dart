import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:igot_ui_components/ui/widgets/alert_dialog/alert_dialog.dart';
import 'package:karmayogi_mobile/constants/_constants/learn_compatibility_constants.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/_assessment/_models/guest_data_model.dart';

import '../../../../constants/index.dart';
import '../../../../localization/index.dart';
import '../../../../models/_models/assessment_info_model.dart';
import '../../../../models/_models/assessment_save_point_model.dart';
import '../../../../models/index.dart';
import '../../../pages/_pages/toc/model/navigation_model.dart';
import '../../index.dart';
import 'assessment_sections.dart';
import 'assessment_v2_sections.dart';

class AssessmentStartBtnWidget extends StatelessWidget {
  final CourseHierarchyModel course;
  final retakeInfo;
  final String identifier;
  final String parentCourseId;
  final Map? microSurvey;
  final questionSet;
  final AssessmentInfo? assessmentInfo;
  final ValueChanged<Map> parentAction;
  final ValueChanged<bool>? playNextResource;
  final String batchId;
  final bool isConfirmed;
  final int compatibilityLevel;
  final SavePointModel? savePointInfo;
  final NavigationModel resourceInfo;
  final bool isFeatured;
  final String courseCategory;
  final GuestDataModel? guestUserData;
  final bool isPreRequisite;
  final String? preEnrolmentAssessmentId;
  final String? preRequisiteMimeType;

  AssessmentStartBtnWidget({
    Key? key,
    required this.course,
    this.retakeInfo,
    required this.identifier,
    required this.parentCourseId,
    this.microSurvey,
    this.questionSet,
    required this.assessmentInfo,
    required this.parentAction,
    this.playNextResource,
    required this.batchId,
    this.isConfirmed = false,
    required this.compatibilityLevel,
    this.savePointInfo,
    required this.resourceInfo,
    this.isFeatured = false,
    required this.courseCategory,
    this.guestUserData,
    this.isPreRequisite = false,
    this.preEnrolmentAssessmentId,
    this.preRequisiteMimeType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: compatibilityLevel >=
                    AssessmentCompatibility.multimediaCompatibility.version
                ? EdgeInsets.fromLTRB(16, 16, 0, 16)
                : EdgeInsets.fromLTRB(16, 16, 16, 32),
            decoration: BoxDecoration(
                color: compatibilityLevel >=
                        AssessmentCompatibility.multimediaCompatibility.version
                    ? AppColors.scaffoldBackground
                    : AppColors.appBarBackground),
            child: Container(
              width: 1.sw - 35.w,
              child: TextButton(
                onPressed: !(retakeInfo != null &&
                        retakeInfo['attemptsAllowed'] ==
                            retakeInfo['attemptsMade'])
                    ? compatibilityLevel >=
                                AssessmentCompatibility
                                    .multimediaCompatibility.version &&
                            !isConfirmed
                        ? null
                        : () {
                            Navigator.pop(context);
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => resourceInfo.artifactUrl != null &&
                                      resourceInfo.artifactUrl!.isNotEmpty
                                  ? AssessmentQuestions(
                                      course,
                                      resourceInfo.name ?? '',
                                      identifier,
                                      microSurvey != null
                                          ? microSurvey
                                          : questionSet.first,
                                      markSurveyCompleted,
                                      batchId,
                                      resourceInfo.duration,
                                      isNewAssessment: resourceInfo.artifactUrl != null
                                          ? false
                                          : true,
                                      primaryCategory: resourceInfo.primaryCategory,
                                      parentCourseId: parentCourseId,
                                      isPreRequisite: isPreRequisite,
                                      preEnrolmentAssessmentId: preEnrolmentAssessmentId,
                                      language: resourceInfo.language)
                                  : (questionSet.length > 0
                                      ? compatibilityLevel >= AssessmentCompatibility.multimediaCompatibility.version
                                          ? AssessmentV2Section(
                                              course,
                                              identifier,
                                              microSurvey != null ? microSurvey : questionSet,
                                              markSurveyCompleted,
                                              batchId,
                                              assessmentInfo!.expectedDuration,
                                              isNewAssessment: resourceInfo.artifactUrl != null ? false : true,
                                              primaryCategory: assessmentInfo!.primaryCategory,
                                              objectType: assessmentInfo!.objectType,
                                              assessmentsInfo: assessmentInfo!.questions,
                                              assessmentType: assessmentInfo!.assessmentType,
                                              updateContentProgress: parentAction,
                                              parentCourseId: parentCourseId,
                                              compatibilityLevel: compatibilityLevel,
                                              savePointInfo: savePointInfo,
                                              showMark: assessmentInfo!.showMarks.toLowerCase() == EnglishLang.yes,
                                              resourceInfo: resourceInfo,
                                              isFeatured: isFeatured,
                                              courseCategory: courseCategory,
                                              guestUserData: guestUserData,
                                              isPreRequisite: isPreRequisite,
                                              preEnrolmentAssessmentId: preEnrolmentAssessmentId,
                                              preRequisiteMimeType: preRequisiteMimeType
                                          )
                                          : AssessmentSection(
                                              course,
                                              identifier,
                                              microSurvey != null
                                                  ? microSurvey
                                                  : questionSet,
                                              markSurveyCompleted,
                                              batchId,
                                              assessmentInfo!.expectedDuration,
                                              isNewAssessment: resourceInfo.artifactUrl != null ? false : true,
                                              primaryCategory: assessmentInfo!.primaryCategory,
                                              objectType: assessmentInfo!.objectType,
                                              assessmentsInfo: assessmentInfo!.questions,
                                              updateContentProgress: parentAction,
                                              parentCourseId: parentCourseId,
                                              resourceInfo: resourceInfo,
                                              isFeatured: isFeatured,
                                              courseCategory: courseCategory,
                                              guestUserData: guestUserData,
                                              isPreRequisite: isPreRequisite,
                                              preEnrolmentAssessmentId: preEnrolmentAssessmentId,
                                              preRequisiteMimeType: preRequisiteMimeType
                              )
                                      : ErrorPage()),
                            ));
                          }
                    : () => _limitExceededCallback(context),
                style: TextButton.styleFrom(
                  backgroundColor: !(retakeInfo != null &&
                          retakeInfo['attemptsAllowed'] == retakeInfo['attemptsMade'])
                      ? compatibilityLevel >= AssessmentCompatibility.multimediaCompatibility.version &&
                              !isConfirmed
                          ? AppColors.disabledGrey
                          : AppColors.primaryBlue
                      : AppColors.grey40,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50).r,
                      side: BorderSide(
                          color: compatibilityLevel >= AssessmentCompatibility.multimediaCompatibility.version &&
                                  !isConfirmed
                              ? AppColors.disabledGrey
                              : AppColors.primaryBlue)),
                ),
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.mStartAssessment,
                    style: GoogleFonts.montserrat(
                      color: compatibilityLevel >= AssessmentCompatibility.multimediaCompatibility.version &&
                              !isConfirmed
                          ? AppColors.disabledTextGrey
                          : AppColors.appBarBackground,
                      fontSize: 14.0.sp,
                      height: 1.h,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  void markSurveyCompleted(double status) {
    double surveyCompletedPercent = 0.0;
    surveyCompletedPercent = status;
    Map data = {
      'identifier': isPreRequisite ? preEnrolmentAssessmentId : identifier,
      'completionPercentage': surveyCompletedPercent / 100,
      'current': '',
      'mimeType': EMimeTypes.assessment,
    };
    parentAction(data);
    if (playNextResource != null) {
      playNextResource!(true);
    }
  }

  Future _limitExceededCallback(BuildContext context) async {
    return showDialog(
        context: context,
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