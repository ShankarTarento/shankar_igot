import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/models/_arguments/toc_player_model.dart';
import 'package:karmayogi_mobile/models/_models/batch_model.dart';
import 'package:karmayogi_mobile/models/_models/blended_program_enroll_response_model.dart';
import 'package:karmayogi_mobile/models/_models/course_hierarchy_model.dart';
import 'package:karmayogi_mobile/models/_models/course_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/model/content_state_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/screen/pre_enrollment_player/screen/pre_toc_player_screen.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/util/toc_helper.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/model/profile_model.dart';
import 'package:karmayogi_mobile/respositories/_respositories/learn_repository.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/services/_services/learn_service.dart';
import 'package:karmayogi_mobile/services/_services/smartech_service.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/about_tab/widgets/blended_program_user_form/survey_form_bottom_sheet.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/about_tab/widgets/select_batch_bottom_sheer.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/about_tab/widgets/withdraw_request_button.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/services/toc_services.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../../../../respositories/_respositories/in_app_review_repository.dart';
import '../../../widgets/rate_now_pop_up.dart';

class EnrollBlendedProgramButton extends StatefulWidget {
  final List<Batch> batches;
  final lastAccessContentId;
  final navigationItems;
  final String courseId;
  final Course courseDetails;
  final Batch? selectedBatch;
  final Course? enrolledCourse;
  final VoidCallback? readCourseProgress;
  final int? numberOfCourseRating;
  final bool isLearningPathContent;
  final double? courseRating;
  final bool isFeatured;
  final List<Course> enrollmentList;
  EnrollBlendedProgramButton(
      {Key? key,
        required this.batches,
        required this.lastAccessContentId,
        required this.navigationItems,
        required this.courseId,
        required this.courseDetails,
        this.selectedBatch,
        this.enrolledCourse,
        this.readCourseProgress,
        this.isFeatured = false,
        this.numberOfCourseRating,
        required this.isLearningPathContent,
        this.courseRating,
        this.enrollmentList = const []})
      : super(key: key);

  @override
  State<EnrollBlendedProgramButton> createState() =>
      _EnrollBlendedProgramButtonState();
}

class _EnrollBlendedProgramButtonState
    extends State<EnrollBlendedProgramButton> {
  var formId = 1694586265488;
  var workflowDetails;
  Map<String, dynamic>? enrolledBatch;
  bool _disableButton = false;
  Batch? enrolledBatchDetails;
  bool isWithdrawPopupShowing = false, isAllBatchEnrollmentDateFinished = false;
  String wfId = '';
  bool startCourse = true;

  final LearnService learnService = LearnService();
  bool showWithdrawBtnForEnrolled = false;

  bool enableRequestWithdrawBtn = true,
      isBatchStarted = false,
      isRequestRejected = false,
      isRequestRemoved = false;
  ValueNotifier<bool> showBlendedProgramReqButton = ValueNotifier<bool>(false);
  bool showStart = false, enableWithdrawBtn = false;

  bool enableStartButton = false;

  Future<Map?> getForm(id) async {
    var surveyForm = await Provider.of<LearnRepository>(context, listen: false)
        .getSurveyForm(id);
    return surveyForm;
  }

  String? enrollStatus;
  ValueNotifier<bool> isPreEnrollRequisiteCompleted = ValueNotifier(false);
  late Future<bool?> _isPreRequisiteMandatoryFuture;

  @override
  void initState() {
    ///enable for For Pre-enrollment assessment - block start
    if (widget.courseDetails.preEnrolmentResources != null)
      _isPreRequisiteMandatoryFuture = _readPreRequisiteContentProgress();
    ///enable for For Pre-enrollment assessment - block end
    checkEnrolledBlendedProgram();
    userSearch();
    setState(() {});
    super.initState();
  }

  setEnrollStatus(String value) async {
    enrollStatus = value;
    if (value == 'Confirm') {
      await enrollBlendedCourse();
      await userSearch();
    }
  }

  userSearch() async {
    workflowDetails = [];
    List batchList = [];
    widget.batches.forEach((item) {
      batchList.add(item.batchId);
    });
    try {
      String courseId = widget.courseDetails.id;
      workflowDetails = await learnService.userSearch(courseId, batchList);
      checkWorkflowStatus();
    } catch (e) {
      print(e);
    }
  }

  void checkWorkflowStatus() {
    if (workflowDetails != null && workflowDetails.isNotEmpty) {
      if (workflowDetails[0]['wfInfo'] != null) {
        List workflowStates = workflowDetails[0]['wfInfo'] ?? [];
        if (workflowStates.isNotEmpty) {
          workflowStates.sort((a, b) {
            return DateTime.fromMillisecondsSinceEpoch(a['lastUpdatedOn'])
                .compareTo(
                DateTime.fromMillisecondsSinceEpoch(b['lastUpdatedOn']));
          });

          widget.batches.forEach((batch) {
            if (workflowStates.last['applicationId'] == batch.batchId &&
                (workflowStates.last['currentStatus'] ==
                    WFBlendedProgramStatus.REJECTED.name ||
                    workflowStates.last['currentStatus'] ==
                        WFBlendedProgramStatus.REMOVED.name ||
                    workflowStates.last['currentStatus'] ==
                        WFBlendedProgramStatus.SEND_FOR_MDO_APPROVAL.name ||
                    workflowStates.last['currentStatus'] ==
                        WFBlendedProgramStatus.SEND_FOR_PC_APPROVAL.name)) {
              enrolledBatchDetails = batch;
              Provider.of<TocServices>(context, listen: false)
                  .setBatchDetails(selectedBatch: enrolledBatchDetails!);
            }
          });

          bool withdrawStatus = false;
          showWithdrawBtn(workflowStates.last['currentStatus']);
          for (int i = 0; i < WFBlendedWithdrawCheck.values.length; i++) {
            if (WFBlendedWithdrawCheck.values[i].name ==
                workflowStates.last['currentStatus']) {
              withdrawStatus = true;
              enableRequestWithdraw(workflowStates.last['currentStatus'],
                  workflowStates.last['serviceName']);

              if (!enableRequestWithdrawBtn) {
                List batches = widget.courseDetails.batches ?? [];
                batches.forEach((batch) {
                  if (batch.batchId == workflowStates.last['applicationId']) {
                    if (DateTime.parse(batch.startDate)
                        .isBefore(DateTime.now()) ||
                        DateTime.parse(batch.startDate)
                            .isAtSameMomentAs(DateTime.now())) {
                      if (!isWithdrawPopupShowing) {
                        isWithdrawPopupShowing = true;
                        _showWithdrawPopUp();
                      }
                    }
                  }
                });
              }
              break;
            }
          }
          if (withdrawStatus) {
            wfId = workflowStates.last['wfId'];
            enrolledBatch = workflowStates.last;
            showBlendedProgramReqButton.value = true;
          } else if (workflowStates.last['currentStatus'] ==
              WFBlendedProgramStatus.APPROVED.name) {
            setState(() {
              showStart = true;
              enrolledBatch = workflowStates.last;
            });
          } else if (workflowStates.last['currentStatus'] ==
              WFBlendedProgramStatus.WITHDRAWN.name) {
            showBlendedProgramReqButton.value = false;
          } else if (workflowStates.last['currentStatus'] ==
              WFBlendedProgramStatus.REJECTED.name ||
              workflowStates.last['currentStatus'] ==
                  WFBlendedProgramStatus.REMOVED.name) {
            showBlendedProgramReqButton.value = true;
          }
        } else {
          showBlendedProgramReqButton.value = false;
          showWithdrawBtn(WFBlendedProgramStatus.WITHDRAWN.name);
        }
      }
    } else {
      enrolledBatchDetails = widget.selectedBatch;
      showBlendedProgramReqButton.value = false;
      showWithdrawBtn(WFBlendedProgramStatus.WITHDRAWN.name);
    }
  }

  void showWithdrawBtn(currentStatus) {
    isRequestRejected = false;
    isRequestRemoved = false;
    showWithdrawBtnForEnrolled = false;
    if (WFBlendedWithdrawCheck.SEND_FOR_MDO_APPROVAL.name == currentStatus ||
        WFBlendedWithdrawCheck.SEND_FOR_PC_APPROVAL.name == currentStatus) {
      showWithdrawBtnForEnrolled = true;
      showBlendedProgramReqButton.value = true;
    } else if (WFBlendedWithdrawCheck.REJECTED.name == currentStatus) {
      isRequestRejected = true;
      showBlendedProgramReqButton.value = true;
    } else if (WFBlendedWithdrawCheck.REMOVED.name == currentStatus) {
      isRequestRemoved = true;
      showBlendedProgramReqButton.value = true;
    } else if (WFBlendedProgramStatus.WITHDRAWN.name == currentStatus) {
      showStart = false;
      showBlendedProgramReqButton.value = false;
    }

    setState(() {});
  }

  void enableRequestWithdraw(currentStatus, serviceName) {
    setState(() {
      if (WFBlendedProgramAprovalTypes.twoStepMDOAndPCApproval.name ==
          serviceName &&
          WFBlendedWithdrawCheck.SEND_FOR_PC_APPROVAL.name == currentStatus) {
        enableRequestWithdrawBtn = false;
        // _showPopUP();
      } else if (WFBlendedProgramAprovalTypes.twoStepPCAndMDOApproval.name ==
          serviceName &&
          WFBlendedWithdrawCheck.SEND_FOR_MDO_APPROVAL.name == currentStatus) {
        enableRequestWithdrawBtn = false;
      } else {
        enableRequestWithdrawBtn = true;
        // _showPopUP();
      }
    });
  }

  Future<void> unEnrollBlendedCourse() async {
    await learnService.requestUnenroll(
        batchId: enrolledBatchDetails!.batchId,
        courseId: widget.courseDetails.id,
        wfId: wfId,
        state: enrolledBatch!['currentStatus'],
        action: WFBlendedProgramStatus.WITHDRAW.name);
    userSearch();
  }

  _showWithdrawPopUp() => {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) =>
            OverflowBar(alignment: MainAxisAlignment.center, children: [
              AlertDialog(
                content: Text(
                    AppLocalizations.of(context)!
                        .mStaticYourEnrollmentIsNotApproved,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp,
                      letterSpacing: 0.25,
                      color: AppColors.greys87,
                    )),
                actionsAlignment: MainAxisAlignment.center,
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      isWithdrawPopupShowing = false;
                      Navigator.of(context).pop();
                    },
                    style: ButtonStyle(
                      shape:
                      WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(4.0).w,
                              side: BorderSide(
                                  color: AppColors.darkBlue,
                                  width: 1.5.w))),
                      backgroundColor: WidgetStateProperty.all<Color>(
                          AppColors.appBarBackground),
                    ),
                    // padding: EdgeInsets.all(15.0),
                    child: Text(
                      EnglishLang.cancel,
                      style: GoogleFonts.lato(
                        color: AppColors.darkBlue,
                        fontSize: 14.0.sp,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() async {
                        await unEnrollBlendedCourse();
                        isWithdrawPopupShowing = false;
                        Navigator.of(context)
                          ..pop()
                          ..pop();
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(
                          AppColors.darkBlue),
                    ),
                    child: Text(
                      EnglishLang.withdraw,
                      style: GoogleFonts.lato(
                        color: AppColors.appBarBackground,
                        fontSize: 14.0.sp,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                ],
              )
            ]))
  };

  enrollBlendedCourse() async {
    String courseId = widget.courseDetails.id;
    if (enrollStatus == 'Confirm') {
      var batchDetails = await learnService.requestToEnroll(
          batchId: widget.selectedBatch!.batchId,
          courseId: courseId,
          state: WFBlendedProgramStatus.INITIATE.name,
          action: WFBlendedProgramStatus.INITIATE.name);
      if (batchDetails is String) {
        await userSearch();
        Helper.showToastMessage(context, message: batchDetails.toString());
        return;
      }
      if (batchDetails is BlendedProgramEnrollResponseModel) {
        Helper.showToastMessage(context,
            message:
            AppLocalizations.of(context)!.mStaticEnrollmentSentForReview);
        showWithdrawBtnForEnrolled = true;
        await userSearch();
        /** SMT track course enroll **/
        trackCourseEnrolled();
        setState(() {});

        return;
      }
    }
  }

  checkEnrolledBlendedProgram() async {
    if (widget.enrolledCourse != null) {
      if (widget.enrolledCourse?.batch?.startDate != null &&
          widget.enrolledCourse?.batch?.endDate != null) {
        DateTime nowWithoutTime = DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day);
        DateTime startDateWithoutTime =
        DateTime.parse(widget.enrolledCourse!.batch!.startDate)
            .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
        DateTime endDateWithoutTime =
        DateTime.parse(widget.enrolledCourse!.batch!.endDate)
            .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
        enableStartButton = (nowWithoutTime.isAfter(startDateWithoutTime) ||
            nowWithoutTime == startDateWithoutTime) &&
            nowWithoutTime.isBefore(endDateWithoutTime.add(Duration(days: 1)));
      }
      showStart = true;
    } else {
      showStart = false;
    }
    setState(() {});
  }

  String getProgress() {
    if (widget.enrolledCourse != null) {
      if (widget.enrolledCourse!.completionPercentage! / 100 > 0 &&
          widget.enrolledCourse!.completionPercentage! / 100 < 1) {
        return AppLocalizations.of(context)!.mStaticResume;
      } else if (widget.enrolledCourse!.completionPercentage! / 100 == 1) {
        return AppLocalizations.of(context)!.mStartAgain;
      } else {
        return AppLocalizations.of(context)!.mLearnStart;
      }
    } else {
      return AppLocalizations.of(context)!.mLearnStart;
    }
  }

  void trackCourseEnrolled() async {
    try {
      bool _isContentEnrolmentEnabled =
      await Provider.of<LearnRepository>(context, listen: false)
          .isSmartechEventEnabled(
          eventName: SMTTrackEvents.contentEnrolment);
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
      debugPrint(e.toString());
    }
  }

  void showBottomSheet({Map? response, required bool isCadreProgram}) async {
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ).r,
          side: BorderSide(
            color: AppColors.grey08,
          ),
        ),
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
                height: 0.9.sh,
                child: SurveyFormBottomSheet(
                  isCadreProgram: isCadreProgram,
                  title: widget.courseDetails.name,
                  courseId: '${widget.courseDetails.id}',
                  courseIdName:
                  '${widget.courseDetails.id},${widget.courseDetails.name}',
                  formId: formId,
                  response: response,
                  selectedBatch: widget.selectedBatch!,
                  setEnrollStatus: (value) {
                    setEnrollStatus(value);
                  },
                )),
          );
        });
  }

  bool checkIsCadreProgram() {
    try {
      Profile? profileDetails =
          Provider.of<ProfileRepository>(context, listen: false).profileDetails;
      List<String> cadreServiceList = [];
      if (widget.selectedBatch?.batchAttributes?.raw['cadreList'] is List) {
        cadreServiceList = List<String>.from(
            widget.selectedBatch!.batchAttributes!.raw['cadreList']);
      }

      if (profileDetails != null) {
        String? userCadreService =
        profileDetails.cadreDetails?['civilServiceName'];
        if (userCadreService != null) {
          String userCadreServiceId =
          userCadreService.toLowerCase().replaceAll(' ', '');

          List<String> cadreServiceListId = cadreServiceList
              .map((service) => service.toLowerCase().replaceAll(' ', ''))
              .toList();
          if (cadreServiceListId.contains(userCadreServiceId)) {
            return true;
          } else {
            Helper.showSnackBarMessage(
                durationInSec: 4,
                context: context,
                text: AppLocalizations.of(context)!
                    .mDoptBlendedProgramEligibilityMessage1 +
                    " " +
                    widget.courseDetails.name +
                    " " +
                    AppLocalizations.of(context)!
                        .mDoptBlendedProgramEligibilityMessage2,
                bgColor: AppColors.darkBlue);
            return false;
          }
        } else {
          Helper.showSnackBarMessage(
              context: context,
              text: AppLocalizations.of(context)!
                  .mNonEligibleServiceMessageForDoptBlendedProgram,
              bgColor: AppColors.darkBlue);
          return false;
        }
      } else {
        Helper.showSnackBarMessage(
            context: context,
            text: AppLocalizations.of(context)!
                .mNonEligibleServiceMessageForDoptBlendedProgram,
            bgColor: AppColors.darkBlue);
        return false;
      }
    } catch (e) {
      print('Error: $e');
      Helper.showSnackBarMessage(
          context: context,
          text: AppLocalizations.of(context)!.mStaticSomethingWrong,
          bgColor: AppColors.darkBlue);
      return false;
    }
  }

  void onPreEnrollmentButtonClick() async {
    var result = await Navigator.push(
        context,
        FadeRoute(
            page: PreTocPlayerScreen(
              arguments: TocPlayerModel(
                  courseId: widget.courseId,
                  lastAccessContentId: widget.lastAccessContentId,
                  isFeatured: widget.isFeatured,
                  isCuratedProgram: false,
                  enrollmentList: widget.enrollmentList),
            )));
    if (result != null && result is Map<String, bool>) {
      Map<String, dynamic> response = result;
      if (response['isFinished']) {
        _isPreRequisiteMandatoryFuture = _readPreRequisiteContentProgress();
      }
    }
    // widget.readCourseProgress!();
  }

  Future<bool> _readPreRequisiteContentProgress() async {
    try {
      final children =
          widget.courseDetails.preEnrolmentResources?.children ?? [];
      if (children.isEmpty) return false;

      final contentIds = TocHelper.getContentIdsFromCourse(children);
      if (contentIds.isEmpty) return false;

      final mandatoryIds = getMandatoryPreRequisiteContentIds(children);
      if (mandatoryIds.isEmpty) return false;

      final contentProgress =
      await Provider.of<LearnRepository>(context, listen: false)
          .readPreRequisiteContentProgress(contentIds);

      final isCompleted = await isPreEnrollmentRequisiteCompleted(
          contentProgress, mandatoryIds);
      if (isCompleted) {
        isPreEnrollRequisiteCompleted.value = true;
        return false;
      } else {
        return true;
      }
    } catch (e) {
      return false;
    }
  }

  Set<String> getMandatoryPreRequisiteContentIds(
      List<CourseHierarchyModelChild?> children) {
    return children
        .where((child) => child?.isMandatory == true)
        .map((child) => child?.identifier)
        .whereType<String>()
        .toSet();
  }

  Future<bool> isPreEnrollmentRequisiteCompleted(
      List<ContentStateModel> contentProgress,
      Set<String> mandatoryIds,
      ) async {
    if (contentProgress.isEmpty) return false;

    final progressMap = {
      for (var item in contentProgress) item.contentId: item.status,
    };

    return mandatoryIds.every((id) => (progressMap[id] ?? 0) >= 2);
  }

  @override
  Widget build(BuildContext context) {
    if (showStart) {
      return _startView();
    }
    if (showWithdrawBtnForEnrolled) {
      return WithdrawRequest(
        courseDetails: widget.courseDetails,
        selectedBatch: enrolledBatchDetails,
        withdrawFunction: () async {
          await unEnrollBlendedCourse();
          showWithdrawBtnForEnrolled = false;

          Provider.of<TocServices>(context, listen: false).setInitialBatch(
            batches: widget.batches,
            courseId: widget.courseId,
          );

          setState(() {});
        },
      );
    }
    return _enrollmentView();
  }

  Widget _startView() {
    if (widget.selectedBatch == null) return _emptyBatchView();
    return SizedBox(
      height: 40.w,
      width: 1.sw,
      child: ElevatedButton(
        onPressed: () async {
          if (enableStartButton) {
            var result = await Navigator.pushNamed(context, AppUrl.tocPlayer,
                arguments: TocPlayerModel(
                    batchId: widget.enrolledCourse!.batchId,
                    courseId: widget.courseId,
                    enrolledCourse: widget.enrolledCourse,
                    navigationItems: widget.navigationItems,
                    lastAccessContentId: widget.lastAccessContentId,
                    isFeatured: widget.isFeatured,
                    isCuratedProgram: false,
                    enrollmentList: widget.enrollmentList));
            if (result != null && result is Map<String, bool>) {
              Map<String, dynamic> response = result;
              if (response['isFinished']) {
                showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    backgroundColor: AppColors.greys60,
                    builder: (ctx) => RateNowPopUp(
                      courseDetails: widget.courseDetails,
                    )).whenComplete(() =>
                    InAppReviewRespository().triggerInAppReviewPopup(context));
              }
            }
            widget.readCourseProgress!();
          }
        },
        style: ButtonStyle(
          overlayColor: WidgetStateProperty.all<Color>(Colors.transparent),
          backgroundColor: enableStartButton
              ? WidgetStateProperty.all<Color>(AppColors.darkBlue)
              : WidgetStateProperty.all<Color>(
              AppColors.darkBlue.withValues(alpha:0.5)),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(63.0).r,
            ),
          ),
        ),
        child: Text(
          getProgress(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _enrollmentView() {
    // return _requestToEnrollView(false, false);
    ///enable for For Pre-enrollment assessment - block start
    if (widget.courseDetails.preEnrolmentResources == null) {
      return _requestToEnrollView(false, false);
    }
    return _preEnrollmentView();
    ///enable for For Pre-enrollment assessment - block end
  }

  Widget _preEnrollmentView() {
    return FutureBuilder<bool?>(
        future: _isPreRequisiteMandatoryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox.shrink();
          }
          return ValueListenableBuilder(
              valueListenable: isPreEnrollRequisiteCompleted,
              builder: (BuildContext context,
                  bool _isPreEnrollRequisiteCompleted, Widget? child) {
                return ((snapshot.data ?? false) &&
                    !_isPreEnrollRequisiteCompleted)
                    ? _preEnrollButtonView()
                    : _requestToEnrollView(
                    _isPreEnrollRequisiteCompleted, true);
              });
        });
  }

  Widget _preEnrollButtonView() {
    return SizedBox(
      height: 40.w,
      width: 1.sw,
      child: ElevatedButton(
        onPressed: () => onPreEnrollmentButtonClick(),
        style: ButtonStyle(
          overlayColor: WidgetStateProperty.all<Color>(Colors.transparent),
          backgroundColor: WidgetStateProperty.all<Color>(AppColors.darkBlue),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(63.0).r,
            ),
          ),
        ),
        child: Text(
          AppLocalizations.of(context)!.mBlendedPreEnrollmentRequisites,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _requestToEnrollView(
      bool isPreEnrollRequisiteCompleted, bool showPreEnrollButton) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12).r,
        color: AppColors.appBarBackground,
      ),
      child: Container(
        padding: EdgeInsets.only(bottom: 16).r,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12).r,
            color: AppColors.orangeTourText.withValues(alpha:0.2)),
        width: 1.sw,
        child: Column(children: [
          if (widget.selectedBatch == null) _emptyBatchView(),
          if (widget.selectedBatch != null) ...[
            if (showPreEnrollButton)
              _optionalRequisiteWithCompletion(isPreEnrollRequisiteCompleted),
            Container(
              margin:
              EdgeInsets.only(bottom: 10, left: 16, top: 16, right: 16).r,
              padding: EdgeInsets.all(12).r,
              decoration: BoxDecoration(
                  color: AppColors.appBarBackground,
                  borderRadius: BorderRadius.circular(4).r,
                  border: Border.all(color: AppColors.primaryOne)),
              width: 1.sw,
              child: Row(
                children: [
                  SizedBox(
                    width: 1.sw / 1.6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.selectedBatch!.name,
                          style: GoogleFonts.lato(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(
                          height: 4.w,
                        ),
                        Text(
                          "${DateTimeHelper.getDateTimeInFormat(widget.selectedBatch!.startDate, desiredDateFormat: IntentType.dateFormat2)} to  ${DateTimeHelper.getDateTimeInFormat(widget.selectedBatch!.endDate, desiredDateFormat: IntentType.dateFormat2)}",
                          style: GoogleFonts.lato(
                            fontWeight: FontWeight.w400,
                            fontSize: 12.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    ),
                  ),
                  Spacer(),
                  IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                            context: context,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ).r,
                              side: BorderSide(
                                color: AppColors.grey08,
                              ),
                            ),
                            builder: (BuildContext context) {
                              return Consumer<TocServices>(
                                  builder: (context, tocServices, _) {
                                    return SelectBatchBottomSheet(
                                      batches: widget.batches,
                                      batch: tocServices.batch,
                                    );
                                  });
                            });
                      },
                      icon: Icon(Icons.keyboard_arrow_down))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16).r,
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.mStaticLastEnrollDate,
                        style: GoogleFonts.lato(
                          fontWeight: FontWeight.w400,
                          fontSize: 12.sp,
                          height: 1.5.w,
                        ),
                      ),
                      Text(
                        enrolledBatchDetails != null
                            ? DateTimeHelper.getDateTimeInFormat(
                            enrolledBatchDetails!.enrollmentEndDate,
                            desiredDateFormat: IntentType.dateFormat)
                            : DateTimeHelper.getDateTimeInFormat(
                            widget.selectedBatch!.enrollmentEndDate,
                            desiredDateFormat: IntentType.dateFormat),
                        style: GoogleFonts.lato(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.sp,
                          height: 1.5.w,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: showBlendedProgramReqButton.value ||
                        (!showStart && isAllBatchEnrollmentDateFinished) ||
                        (showStart && !isBatchStarted) && false
                        ? null
                        : !_disableButton
                        ? () async {
                      startCourse = true;
                      if (widget.courseDetails.courseCategory ==
                          PrimaryCategory.blendedProgram &&
                          widget.courseDetails.batches != null) {
                        if (widget.courseDetails.wfSurveyLink != '') {
                          var surveyFormLink =
                              widget.courseDetails.wfSurveyLink;
                          formId = int.parse(
                              surveyFormLink.split('/').last);

                          if (true && !showStart) {
                            var response = await getForm(formId);
                            userSearch();
                            if (response != null) {
                              if (widget.selectedBatch != null &&
                                  widget
                                      .selectedBatch!
                                      .batchAttributes
                                      ?.raw['cadreList'] !=
                                      null &&
                                  (widget
                                      .selectedBatch!
                                      .batchAttributes!
                                      .raw['cadreList'] as List)
                                      .isNotEmpty) {
                                if (checkIsCadreProgram()) {
                                  showBottomSheet(
                                      isCadreProgram: true,
                                      response: response);
                                }
                              } else {
                                showBottomSheet(
                                    isCadreProgram: false,
                                    response: response);
                              }
                            }
                          }
                        } else {
                          if (widget.selectedBatch != null &&
                              widget.selectedBatch!.batchAttributes
                                  ?.raw['cadreList'] !=
                                  null &&
                              (widget.selectedBatch!.batchAttributes!
                                  .raw['cadreList'] as List)
                                  .isNotEmpty) {
                            if (checkIsCadreProgram()) {
                              showBottomSheet(
                                isCadreProgram: true,
                              );
                            }
                          } else {
                            showBottomSheet(
                              isCadreProgram: false,
                            );
                          }
                        }
                      }
                    }
                        : null,
                    style: ButtonStyle(
                      backgroundColor:
                      WidgetStateProperty.all<Color>(AppColors.primaryOne),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(63.0).r,
                        ),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.mLearnRequestToEnroll,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  ),
                ],
              ),
            )
          ]
        ]),
      ),
    );
  }

  Widget _optionalRequisiteWithCompletion(bool isPreEnrollRequisiteCompleted) {
    return GestureDetector(
      onTap: () => onPreEnrollmentButtonClick(),
      child: Container(
        margin: EdgeInsets.only(left: 16, right: 16, top: 8).r,
        padding: const EdgeInsets.all(8).r,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50).r,
            border: Border.all(
                color: isPreEnrollRequisiteCompleted
                    ? AppColors.positiveLight
                    : AppColors.darkBlue)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isPreEnrollRequisiteCompleted
                  ? AppLocalizations.of(context)!
                  .mBlendedPreEnrollmentRequisitesCompleted
                  : AppLocalizations.of(context)!
                  .mBlendedPreEnrollmentRequisites,
              style: GoogleFonts.lato(
                  fontSize: 14.sp,
                  color: isPreEnrollRequisiteCompleted
                      ? AppColors.positiveLight
                      : AppColors.darkBlue,
                  fontWeight: FontWeight.w700),
            ),
            if (isPreEnrollRequisiteCompleted)
              Padding(
                padding: const EdgeInsets.only(left: 8).r,
                child: SvgPicture.asset(
                  'assets/img/approved.svg',
                  width: 20.w,
                  height: 20.w,
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _emptyBatchView() {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12).r,
          color: AppColors.appBarBackground,
        ),
        child: Container(
          padding: EdgeInsets.all(16).r,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12).r,
              color: AppColors.orangeTourText.withValues(alpha:0.2)),
          width: 1.sw,
          child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              margin: EdgeInsets.only(bottom: 10).r,
              padding: EdgeInsets.all(12).r,
              height: 50.w,
              decoration: BoxDecoration(
                  color: AppColors.appBarBackground,
                  borderRadius: BorderRadius.circular(4).r,
                  border: Border.all(color: AppColors.black40)),
              width: 1.sw,
            ),
            Text(
              AppLocalizations.of(context)!.mLearnNoActiveBatches,
              style: GoogleFonts.lato(
                  color: AppColors.textHeadingColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: 5.w,
            ),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.mStaticLastEnrollDate,
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.w400,
                        fontSize: 12.sp,
                        height: 1.5.w,
                      ),
                    ),
                    Text(
                      enrolledBatchDetails != null
                          ? enrolledBatchDetails!.enrollmentEndDate
                          : "",
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                        height: 1.5.w,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    elevation: WidgetStateProperty.all(0),
                    backgroundColor:
                    WidgetStateProperty.all<Color>(AppColors.black40),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(63.0).w,
                      ),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.mLearnRequestToEnroll,
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                      color: AppColors.appBarBackground,
                    ),
                  ),
                ),
              ],
            ),
          ]),
        ));
  }
}