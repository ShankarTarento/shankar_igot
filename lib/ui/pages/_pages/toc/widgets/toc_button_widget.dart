import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/respositories/index.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/widgets/rate_now_pop_up.dart';
import 'package:provider/provider.dart';

import '../../../../../constants/index.dart';
import '../../../../../igot_app.dart';
import '../../../../../localization/index.dart';
import '../../../../../models/_arguments/index.dart';
import '../../../../../models/index.dart';
import '../../../../../services/_services/smartech_service.dart';
import '../../../../../util/index.dart';
import '../../../../widgets/buttons/button_with_border.dart';
import '../enroll_moderated_program.dart';
import 'PreEnrollLanguageSelector.dart';

class TocButtonWidget extends StatefulWidget {
  final bool isStandAloneAssesment;
  final Course? enrolledCourse;
  final bool isModerated;
  final List navigationItems;
  final bool isCuratedProgram;
  final Course courseDetails;
  final String? batchId;
  final String? recommendationId;
  final String courseId;
  final String? lastAccessContentId;
  final Batch? selectedBatch;
  final VoidCallback readCourseProgress, updateEnrolmentList;
  final List resourceNavigateItems;
  final bool isFeatured;
  final List<Course> enrollmentList;
  final int? numberOfCourseRating;
  final bool isLearningPathContent;
  final double? courseRating;
  final bool isAITutor;
  const TocButtonWidget(
      {Key? key,
      required this.isStandAloneAssesment,
      this.isModerated = false,
      this.enrolledCourse,
      required this.courseDetails,
      required this.navigationItems,
      this.isCuratedProgram = false,
      this.batchId,
      this.recommendationId,
      required this.courseId,
      this.lastAccessContentId,
      this.selectedBatch,
      required this.readCourseProgress,
      required this.updateEnrolmentList,
      required this.resourceNavigateItems,
      this.isFeatured = false,
      required this.enrollmentList,
      this.numberOfCourseRating,
      required this.isLearningPathContent,
      this.courseRating,
      this.isAITutor = false})
      : super(key: key);
  @override
  State<TocButtonWidget> createState() => _TocButtonWidgetState();
}

class _TocButtonWidgetState extends State<TocButtonWidget> {
  final LearnRepository learnRepository = LearnRepository();
  double progress = 0;
  ValueNotifier<bool> isEnabled = ValueNotifier<bool>(false);
  bool isModeratedMultiBatchCourse = false;
  Course? enrolledCourse;
  List<Course> enrollmentList = [];
  String? batchId;
  String? baseLanguage;

  @override
  void initState() {
    super.initState();
    batchId = widget.batchId;
    enrollmentList = widget.enrollmentList;
    isModeratedMultiBatchCourse = isModeratedWithMultipleBatch();
    if (!isModeratedMultiBatchCourse) {
      enrolledCourse = widget.enrolledCourse;
      if (!widget.isFeatured) {
        progress = checkProgress();
      } else {
        updateAccess(true);
      }
    }
  }

  @override
  void didUpdateWidget(TocButtonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    isModeratedMultiBatchCourse = isModeratedWithMultipleBatch();
    if (!isModeratedMultiBatchCourse) {
      enrolledCourse = widget.enrolledCourse;
      if (!widget.isFeatured) {
        progress = checkProgress();
      } else {
        updateAccess(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return isModeratedMultiBatchCourse
        ? EnrollModeratedProgram(
            selectedBatch: widget.selectedBatch,
            batches: widget.courseDetails.batches!,
            onEnrollPressed: (BuildContext context) async {
              await enrollModeratedProgram(context);
              if (widget.isAITutor) {
                Navigator.of(context).pop();
              }
            },
          )
        : SizedBox(
            height: 40.w,
            width: 1.sw,
            child: ValueListenableBuilder<bool>(
                valueListenable: isEnabled,
                builder: (context, value, _) {
                  return ButtonWithBorder(
                      onPressCallback: () async {
                        if (isEnabled.value) {
                          if (enrolledCourse == null && !widget.isFeatured) {
                            if (widget.courseDetails.languageMap.languages
                                .isNotEmpty) {
                              await showLanguageSelectionBtmSheet();
                            } else if (!widget.isFeatured) {
                              enrollCourse(context: context);
                            }
                          } else if (!widget.isFeatured) {
                            if (enrolledCourse!.batchId != null) {
                              navigateToContent(
                                  batchId: enrolledCourse!.batchId!,
                                  navigationItems: widget.navigationItems);
                            }
                          } else {
                            //Featured Course
                            navigateToContent(
                                batchId:
                                    widget.courseDetails.batches!.first.batchId,
                                navigationItems: widget.navigationItems);
                          }
                        }
                      },
                      bgColor: isEnabled.value
                          ? AppColors.darkBlue
                          : AppColors.black40,
                      borderColor: isEnabled.value
                          ? AppColors.darkBlue
                          : AppColors.grey04,
                      text: widget.isFeatured
                          // navigatorKey.currentState!.context is used to handle context issue from dialog widgets
                          ? AppLocalizations.of(
                                  navigatorKey.currentState!.context)!
                              .mStaticView
                          : checkButtonStatus(),
                      textStyle: TextStyle(
                          color: AppColors.appBarBackground,
                          fontSize: !isEnabled.value && widget.isAITutor
                              ? 10.sp
                              : 15.sp),
                      maxLines: 3);
                }),
          );
  }

  bool isModeratedWithMultipleBatch() {
    return (widget.enrolledCourse == null &&
        widget.isModerated &&
        widget.courseDetails.batches != null &&
        widget.courseDetails.batches!.isNotEmpty &&
        (widget.courseDetails.batches![0].enrollmentType == 'invite-only' ||
            widget.courseDetails.batches![0].endDate.isNotEmpty));
  }

  String checkButtonStatus() {
    switch (widget.courseDetails.courseCategory) {
      case PrimaryCategory.inviteOnlyProgram:
        return checkInviteOnlyProgramStatus();
      case PrimaryCategory.inviteOnlyAssessment:
        return checkInviteOnlyAssessmentStatus();
      case EnglishLang.standaloneAssessment:
        updateAccess(true);
        return getAssessmentStatus();
      case PrimaryCategory.moderatedAssessment:
        updateAccess(true);
        return getAssessmentStatus();
      default:
        updateAccess(true);
        return getStatus();
    }
  }

  void updateAccess(value) {
    Future.delayed(Duration.zero, () {
      isEnabled.value = value;
    });
  }

  String checkInviteOnlyProgramStatus() {
    // navigatorKey.currentState!.context is used to handle context issue from dialog widgets
    if (enrolledCourse == null) {
      return AppLocalizations.of(navigatorKey.currentState!.context)!
          .mLearnYouAreNotInvitedProgram;
    } else if (hasDateNotReached()) {
      return AppLocalizations.of(navigatorKey.currentState!.context)!
          .mLearnBatchNotStarted;
    } else if (isDateInRangeInclusive()) {
      updateAccess(true);
      return getStatus();
    }
    return AppLocalizations.of(navigatorKey.currentState!.context)!
        .mLearnNoActiveBatches;
  }

  String checkInviteOnlyAssessmentStatus() {
    // navigatorKey.currentState!.context is used to handle context issue from dialog widgets
    if (enrolledCourse == null) {
      return AppLocalizations.of(navigatorKey.currentState!.context)!
          .mLearnYouAreNotInvitedAssessment;
    } else if (hasDateNotReached()) {
      return InviteOnlyBatchStatus.batchNotStarted;
    } else if (isDateInRangeInclusive()) {
      updateAccess(true);
      return getAssessmentStatus();
    }
    return AppLocalizations.of(navigatorKey.currentState!.context)!
        .mLearnNoActiveBatches;
  }

  String getStatus() {
    // navigatorKey.currentState!.context is used to handle context issue from dialog widgets
    if (enrolledCourse == null) {
      return AppLocalizations.of(navigatorKey.currentState!.context)!
          .mStaticEnroll;
    } else if (enrolledCourse!.completionPercentage ==
            COURSE_COMPLETION_PERCENTAGE ||
        progress == 1) {
      return AppLocalizations.of(navigatorKey.currentState!.context)!
          .mLearnStartAgain;
    } else if (progress == 0) {
      return AppLocalizations.of(navigatorKey.currentState!.context)!
          .mStaticStart;
    } else if (progress > 0 && progress < 1) {
      return AppLocalizations.of(navigatorKey.currentState!.context)!
          .mStaticResume;
    } else {
      return AppLocalizations.of(navigatorKey.currentState!.context)!
          .mStaticStart;
    }
  }

  String getAssessmentStatus() {
    // navigatorKey.currentState!.context is used to handle context issue from dialog widgets
    if (enrolledCourse == null) {
      return AppLocalizations.of(navigatorKey.currentState!.context)!
          .mStaticEnroll;
    } else if (progress >= 0 && progress < 1) {
      return AppLocalizations.of(navigatorKey.currentState!.context)!
          .mLearnTakeTest;
    } else {
      return AppLocalizations.of(navigatorKey.currentState!.context)!
          .mAssessmentTakeTestAgain;
    }
  }

  bool hasDateNotReached() {
    DateTime today = Helper.trimDate(DateTime.now());
    DateTime start =
        Helper.trimDate(DateTime.parse(enrolledCourse!.batch!.startDate));
    return start.isAfter(today);
  }

  bool isDateInRangeInclusive() {
    DateTime today = Helper.trimDate(DateTime.now());
    DateTime start =
        Helper.trimDate(DateTime.parse(enrolledCourse!.batch!.startDate));
    DateTime end =
        Helper.trimDate(DateTime.parse(enrolledCourse!.batch!.endDate));
    return (today.isAtSameMomentAs(start) || today.isAfter(start)) &&
        (today.isAtSameMomentAs(end) || today.isBefore(end));
  }

  double checkProgress() {
    if (enrolledCourse != null) {
      double totalProgress = 0;
      widget.resourceNavigateItems.forEach((element) {
        if (element is! List) {
          if (element.status == 2) {
            totalProgress += 1;
          } else {
            totalProgress +=
                double.parse(element.completionPercentage.toString());
          }
        }
      });
      return totalProgress / widget.resourceNavigateItems.length;
    } else {
      return 0;
    }
  }

  Future<void> enrollCourse({required BuildContext context}) async {
    if (widget.isCuratedProgram && !widget.isModerated) {
      await enrollCuratedWithoutModerated(context);
    } else if (widget.courseDetails.courseCategory ==
        PrimaryCategory.comprehensiveAssessmentProgram) {
      await enrollCuratedWithoutModerated(context);
    } else if (widget.isModerated &&
        (widget.courseDetails.courseCategory == EnglishLang.program ||
            widget.courseDetails.courseCategory ==
                PrimaryCategory.moderatedProgram) &&
        enrolledCourse == null) {
      await enrollModeratedProgram(context);
    } else {
      await autoEnroll(context);
    }
  }

  Future<void> autoEnroll(BuildContext context) async {
    String courseId = widget.courseDetails.id;
    widget.courseDetails.languageMap.languages[baseLanguage];
    courseId =  Helper.getBaseCourseId(widget.courseDetails)?? courseId;

    var response = await learnRepository.autoEnrollBatch(
        courseId: courseId,
        language:
            widget.courseDetails.languageMap.languages[baseLanguage]?.name);
// navigatorKey.currentState!.context is used to handle context issue from dialog widgets
    if (response.runtimeType == String) {
      Helper.showToastMessage(navigatorKey.currentState!.context,
          message: response);
    } else {
      await fetchEnrolInfo(courseId);

      trackCourseEnrolled();
      Helper.showToastMessage(navigatorKey.currentState!.context,
          message: AppLocalizations.of(navigatorKey.currentState!.context)!
              .mStaticEnrolledSuccessfully);
    }
  }

  Future<void> enrollModeratedProgram(BuildContext context) async {
    late String selectedBatchId;
    if (isModeratedMultiBatchCourse) {
      selectedBatchId = widget.selectedBatch!.batchId;
    } else {
      selectedBatchId = widget.courseDetails.batches!.first.batchId;
    }
    String response = await learnRepository.enrollProgram(
        courseId: widget.courseDetails.id,
        programId: widget.courseDetails.id,
        batchId: selectedBatchId);
    // navigatorKey.currentState!.context is used to handle context issue from dialog widgets
    if (response.toLowerCase() == EnglishLang.success.toLowerCase()) {
      await fetchEnrolInfo(widget.courseDetails.id);
      trackCourseEnrolled();
      Helper.showToastMessage(navigatorKey.currentState!.context,
          message: AppLocalizations.of(navigatorKey.currentState!.context)!
              .mStaticEnrolledSuccessfully);
    } else {
      Helper.showToastMessage(navigatorKey.currentState!.context,
          message:
              '${AppLocalizations.of(navigatorKey.currentState!.context)!.mStaticEnrollmentFailed}, ${response}');
    }
  }

  Future<void> enrollCuratedWithoutModerated(BuildContext context) async {
    String message = await learnRepository.enrollToCuratedProgram(
        widget.courseDetails.id, widget.courseDetails.batches![0].batchId);
// navigatorKey.currentState!.context is used to handle context issue from dialog widgets
    if (message.toLowerCase() == EnglishLang.success.toLowerCase()) {
      await fetchEnrolInfo(widget.courseDetails.id);
      trackCourseEnrolled();
      Helper.showToastMessage(navigatorKey.currentState!.context,
          message: AppLocalizations.of(navigatorKey.currentState!.context)!
              .mStaticEnrolledSuccessfully);
    } else {
      Helper.showToastMessage(navigatorKey.currentState!.context,
          message: message.isNotEmpty
              ? message
              : AppLocalizations.of(navigatorKey.currentState!.context)!
                  .mStaticEnrollmentFailed);
    }
  }

  Future<void> fetchEnrolInfo(String id) async {
    await generateInteractTelemetryData();
    List<Course> response =
        await learnRepository.getCourseEnrollDetailsByIds(courseIds: [id]);
    if (response.isNotEmpty) {
      widget.updateEnrolmentList();
      widget.readCourseProgress();
      enrollmentList = response;
      enrolledCourse = response
          .cast<Course?>()
          .firstWhere((course) => course!.id == id, orElse: () => null);

      if (enrolledCourse != null && enrolledCourse!.batchId != null) {
        navigateToContent(batchId: enrolledCourse!.batchId!);
      }

      if (widget.isAITutor) {
        Navigator.of(context).pop();
      } else {
        setState(() {});
      }
    }
  }

  navigateToContent({required String batchId, List? navigationItems}) async {
    // navigatorKey.currentState!.context is used to handle context issue from dialog widgets
    var result = await Navigator.pushNamed(
      navigatorKey.currentState!.context,
      AppUrl.tocPlayer,
      arguments: TocPlayerModel(
          enrolledCourse: enrolledCourse,
          navigationItems: navigationItems,
          isCuratedProgram: widget.isCuratedProgram,
          batchId: batchId,
          lastAccessContentId: widget.lastAccessContentId,
          courseId: widget.courseId,
          isFeatured: widget.isFeatured,
          enrollmentList: enrollmentList),
    );
    if (result != null && result is Map<String, bool>) {
      Map<String, dynamic> response = result;
      if (response['isFinished']) {
        await showModalBottomSheet(
            isScrollControlled: true,
            context: navigatorKey.currentState!.context,
            backgroundColor: AppColors.greys60,
            builder: (ctx) => RateNowPopUp(
                  courseDetails: widget.courseDetails,
                )).whenComplete(() => InAppReviewRespository()
            .triggerInAppReviewPopup(navigatorKey.currentState!.context));
      }
    }
    widget.readCourseProgress();
  }

  Future<void> generateInteractTelemetryData() async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.courseEnrollPageId
            .replaceAll(':do_ID', widget.courseId),
        contentId: widget.courseId,
        subType: TelemetrySubType.enroll,
        env: TelemetryEnv.learn,
        objectType: widget.courseDetails.courseCategory,
        clickId: widget.courseId,
        targetId: widget.recommendationId,
        targetType:
            widget.recommendationId != null ? TelemetrySubType.igotAI : null);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  void trackCourseEnrolled() async {
    try {
      bool _isContentEnrolmentEnabled = await Provider.of<LearnRepository>(
              navigatorKey.currentState!.context,
              listen: false)
          .isSmartechEventEnabled(eventName: SMTTrackEvents.contentEnrolment);
      if (_isContentEnrolmentEnabled) {
        SmartechService.trackCourseEnrolled(
          courseCategory: widget.courseDetails.courseCategory,
          courseName: widget.courseDetails.name,
          image: widget.courseDetails.appIcon,
          contentUrl: "${ApiUrl.baseUrl}/app/toc/${widget.courseDetails.id}",
          doId: widget.courseId.toString(),
          courseDuration: int.parse(widget.courseDetails.duration.toString()),
          learningPathContent: widget.isLearningPathContent ? 1 : 0,
          provider: widget.courseDetails.source,
          courseRating: widget.courseRating,
          numberOfCourseRating: widget.numberOfCourseRating,
        );
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> showLanguageSelectionBtmSheet() async {
    await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)).r,
        ),
        builder: (context) {
          return PreEnrollanguageSelectorWidget(
            course: widget.courseDetails,
            changeSelectionCallback: (value) {
              baseLanguage = value;
              setState(() {
                if (!widget.isFeatured) {
                  enrollCourse(context: context);
                }
              });
            },
          );
        });
  }
}
