import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/learn_compatibility_constants.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/model/navigation_model.dart';
import '../../../../constants/index.dart';
import '../../../../feedback/constants.dart';
import '../../../../services/_services/assessment_service.dart';
import '../../../../services/_services/learn_service.dart';
import '../../../../util/faderoute.dart';
import '../../index.dart';
import 'assessment_completed_screen.dart';
import 'assessment_v2_completed_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AssessmentVerificationScreen extends StatefulWidget {
  final String timeSpent;
  final Map requestBody;
  final assessmentsInfo;
  final primaryCategory;
  final CourseHierarchyModel course;
  final identifier;
  final updateContentProgress;
  final String? batchId;
  final bool fromSectionalCutoff;
  final int compatibilityLevel;
  final String assessmentType;
  final Map<String, dynamic>? submitResponse;
  final NavigationModel resourceInfo;
  final bool isFeatured;
  final String courseCategory;
  final bool isPreRequisite;

  AssessmentVerificationScreen(this.timeSpent, this.requestBody,
      {this.assessmentsInfo,
      this.primaryCategory,
      required this.course,
      this.identifier,
      this.updateContentProgress,
      this.batchId,
      required this.fromSectionalCutoff,
      this.compatibilityLevel = 4,
      this.assessmentType = '',
      this.submitResponse,
      required this.resourceInfo,
      this.isFeatured = false,
      required this.courseCategory,
      this.isPreRequisite = false});
  @override
  _AssessmentVerificationScreenState createState() =>
      _AssessmentVerificationScreenState();
}

class _AssessmentVerificationScreenState
    extends State<AssessmentVerificationScreen> {
  late LearnService learnService;
  late int _start;
  static const int counterLimit = 4;
  static const int apiCounterLimit = 3;
  final AssessmentService assessmentService = AssessmentService();

  @override
  void initState() {
    super.initState();
    learnService = LearnService();
    _start = counterLimit;
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return _start == 0
        ? SafeArea(
            child: Scaffold(
                appBar: AppBar(
                  titleSpacing: 0,
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(Icons.clear, color: FeedbackColors.black60),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                ),
                body: Container(
                  margin: EdgeInsets.only(top: 4).r,
                  color: AppColors.appBarBackground,
                  width: double.infinity.w,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.mClickToSeeTheResults,
                        overflow: TextOverflow.fade,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              letterSpacing: 0.25.r,
                            ),
                      ),
                      TextButton(
                        child:
                            Text(AppLocalizations.of(context)!.mStaticTryAgain),
                        onPressed: () async {
                          await _submitSurvey();
                        },
                      ),
                    ],
                  ),
                )))
        : _showLoadingView();
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    new Timer.periodic(
      oneSec,
      (Timer timer) async {
        if (!mounted) return;
        if (_start < apiCounterLimit) {
          timer.cancel();
          await _submitSurvey();
          if (mounted) {
            setState(() {});
          }
        } else {
          _start--;
          setState(() {});
        }
      },
    );
  }

  Future<void> _submitSurvey() async {
    if (widget.compatibilityLevel >=
        AssessmentCompatibility.multimediaCompatibility.version) {
      if (widget.primaryCategory == PrimaryCategory.practiceAssessment) {
        await Navigator.push(
            context,
            FadeRoute(
                page: AssessmentV2Insights(
                    timeSpent: widget.timeSpent,
                    apiResponse: widget.submitResponse ?? {},
                    batchId: widget.batchId ?? "",
                    course: widget.course,
                    identifier: widget.identifier,
                    primaryCategory: widget.primaryCategory,
                    updateContentProgress: widget.updateContentProgress,
                    assessmentsInfo: widget.assessmentsInfo,
                    compatibilityLevel: widget.compatibilityLevel,
                    resourceInfo: widget.resourceInfo,
                    isFeatured: widget.isFeatured,
                    courseCategory: widget.courseCategory,
                    isPreRequisite: widget.isPreRequisite)));
      } else {
        Navigator.of(context).pop(true);
        await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AssessmentV2CompletedScreen(
                widget.timeSpent, widget.submitResponse ?? {},
                assessmentsInfo: widget.assessmentsInfo,
                primaryCategory: widget.primaryCategory,
                course: widget.course,
                identifier: widget.identifier,
                updateContentProgress: widget.updateContentProgress,
                batchId: widget.batchId ?? "",
                fromSectionalCutoff: widget.fromSectionalCutoff,
                compatibilityLevel: widget.compatibilityLevel,
                resourceInfo: widget.resourceInfo,
                isFeatured: widget.isFeatured,
                courseCategory: widget.courseCategory,
                isPreRequisite: widget.isPreRequisite)));
      }
    } else {
      var response = widget.isFeatured
          ? await assessmentService
              .getPublicAssessmentCompletionStatus(widget.requestBody)
          : await assessmentService
              .getAssessmentCompletionStatus(widget.requestBody);
      Navigator.of(context).pop(true);
      if (response is String) {
        await Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => Scaffold(body: ErrorPage())));
      }
      if (response is Map) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
          await Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => AssessmentCompletedScreen(
                  widget.timeSpent, response,
                  assessmentsInfo: widget.assessmentsInfo,
                  primaryCategory: widget.primaryCategory,
                  course: widget.course,
                  identifier: widget.identifier,
                  updateContentProgress: widget.updateContentProgress,
                  batchId: widget.batchId ?? "",
                  fromSectionalCutoff: widget.fromSectionalCutoff,
                  resourceInfo: widget.resourceInfo,
                  isFeatured: widget.isFeatured,
                  courseCategory: widget.courseCategory,
                  isPreRequisite: widget.isPreRequisite)));
        });
      }
    }
  }

  Widget _showLoadingView() {
    return PopScope(
      canPop: false,
      child: Container(
        height: double.maxFinite.w,
        width: double.maxFinite.w,
        color: AppColors.greys.withValues(alpha: 0.6),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(16, 16, 16, 4).r,
              child: Stack(alignment: Alignment.center, children: [
                SizedBox(
                  height: 150.w,
                  width: 150.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 8,
                    backgroundColor: AppColors.greys.withValues(alpha: 0),
                    valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.verifiedBadgeIconColor),
                  ),
                ),
                Center(
                    child: Column(
                  children: [
                    Text(
                      '${AppLocalizations.of(context)!.mStaticCalculating}..',
                      style: Theme.of(context).textTheme.displaySmall!.copyWith(
                            letterSpacing: 0.25.r,
                            decoration: TextDecoration.none,
                          ),
                    ),
                  ],
                )),
              ]),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8).r,
              child: Text(
                AppLocalizations.of(context)!.mAssessmentResultWaitingMessage,
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                      letterSpacing: 0.25.r,
                      decoration: TextDecoration.none,
                      fontSize: 12.sp,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
