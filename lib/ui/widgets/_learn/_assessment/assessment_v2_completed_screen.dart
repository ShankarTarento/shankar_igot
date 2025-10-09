import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:igot_ui_components/ui/widgets/alert_dialog/alert_dialog.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import '../../../../util/helper.dart';
import '../../../../util/telemetry_repository.dart';
import '../../../pages/_pages/toc/model/navigation_model.dart';
import '../../index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AssessmentV2CompletedScreen extends StatefulWidget {
  final String timeSpent;
  final Map apiResponse;
  final assessmentsInfo;
  final primaryCategory;
  final CourseHierarchyModel course;
  final identifier;
  final updateContentProgress;
  final String batchId;
  final bool fromSectionalCutoff;
  final int compatibilityLevel;
  final NavigationModel resourceInfo;
  final bool isFeatured;
  final String courseCategory;
  final bool isPreRequisite;

  AssessmentV2CompletedScreen(this.timeSpent, this.apiResponse,
      {this.assessmentsInfo,
      this.primaryCategory,
      required this.course,
      this.identifier,
      this.updateContentProgress,
      required this.batchId,
      required this.fromSectionalCutoff,
      required this.compatibilityLevel,
      required this.resourceInfo,
      this.isFeatured = false,
      required this.courseCategory,
      this.isPreRequisite = false});
  @override
  _AssessmentV2CompletedScreenState createState() =>
      _AssessmentV2CompletedScreenState();
}

class _AssessmentV2CompletedScreenState
    extends State<AssessmentV2CompletedScreen> {
  get boxDecoration => BoxDecoration(
          border: Border(
        top: BorderSide(color: AppColors.grey04),
        bottom: BorderSide(color: AppColors.grey04),
      ));

  get leftPadding => 16.0;

  final List<Map<String, String>> sectionSummary = [];

  // final List<Map<String, String>> competitiveAnalysis = [
  //   {'Column 1': 'Section 1', 'Column 2': '20/25', 'Column 3': '22/25'},
  //   {'Column 1': 'Section 2', 'Column 2': '18/25', 'Column 3': '23/25'},
  //   {'Column 1': 'Section 3', 'Column 2': '13/15', 'Column 3': '14.5/25'},
  // ];

  @override
  void initState() {
    super.initState();
    generateSectionalSummary();
    if (widget.isFeatured) _publicAssessmentDialog();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppColors.primaryBlue,
    ));
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            return;
          }
          Navigator.pop(context);
        },
        child: widget.apiResponse.runtimeType != String
            ? Scaffold(
                body: SafeArea(
                  child: _buildLayout(),
                ),
                bottomSheet: _actionButton(),
              )
            : Center());
  }

  Widget _buildLayout() {
    return Container(
      color: AppColors.lightGrey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _containerBody(),
        ],
      ),
    );
  }

  Padding summaryScreenHeader(String text) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8).r,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: GoogleFonts.robotoSlab(
                color: AppColors.darkBlue,
                fontSize: 20.0.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
                padding: EdgeInsets.only(top: 8),
                width: 100.w,
                child: Divider(
                  thickness: 4.w,
                  color: AppColors.orangeDividerShade,
                )),
          ],
        ));
  }

  Widget _containerBody() {
    return Expanded(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          padding: EdgeInsets.only(bottom: 180),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AssessmentV2OverallPerformanceSummary(
                apiResponse: widget.apiResponse,
                timeSpent: widget.timeSpent,
                primaryCategory: widget.primaryCategory,
                showBack: true,
                popBack: () {
                  Navigator.pop(context);
                }),
            sectionSummary.length > 1
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    color: AppColors.appBarBackground,
                    child: SectionWiseSummaryV2(sectionSummary: sectionSummary))
                : Center(),
            SizedBox(height: 8),
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 16),
            //   color: AppColors.appBarBackground,
            //   child: CompetitiveV2Analysis(
            //     competitiveAnalysisData: competitiveAnalysis,
            //   ),
            // ),
          ]),
        ),
      ),
    );
  }

  Widget _actionButton() {
    return Container(
      height: 90.w,
      padding: EdgeInsets.fromLTRB(16, 16, 16, 32).r,
      decoration: BoxDecoration(color: AppColors.appBarBackground),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 58.w,
            width: 0.44.sw,
            child: TextButton(
              onPressed: () async {
                await Navigator.push(
                    context,
                    FadeRoute(
                        page: AssessmentV2Insights(
                            timeSpent: widget.timeSpent,
                            apiResponse: widget.apiResponse,
                            batchId: widget.batchId,
                            course: widget.course,
                            identifier: widget.identifier,
                            primaryCategory: widget.primaryCategory,
                            updateContentProgress: widget.updateContentProgress,
                            assessmentsInfo: widget.assessmentsInfo,
                            compatibilityLevel: widget.compatibilityLevel,
                            showBack: false,
                            resourceInfo: widget.resourceInfo,
                            isFeatured: widget.isFeatured,
                            courseCategory: widget.courseCategory,
                            isPreRequisite: widget.isPreRequisite)));
              },
              style: TextButton.styleFrom(
                backgroundColor: AppColors.appBarBackground,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4)).r,
                    side: BorderSide(color: AppColors.primaryBlue)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/img/insights.svg',
                    colorFilter:
                        ColorFilter.mode(AppColors.darkBlue, BlendMode.srcIn),
                    height: 20.w,
                  ),
                  Text(
                    '  ${AppLocalizations.of(context)!.mAssessmentInsights}  +',
                    style: GoogleFonts.lato(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            height: 58.w,
            width: 0.44.sw,
            child: TextButton(
              onPressed: () async {
                _generateInteractTelemetryData();
                await Navigator.pushReplacement(
                    context,
                    FadeRoute(
                        page: CourseAssessmentPlayer(
                            widget.course,
                            widget.identifier,
                            widget.updateContentProgress,
                            widget.batchId,
                            parentCourseId: widget.course.identifier,
                            compatibilityLevel: widget.compatibilityLevel,
                            resourceNavigateItems: widget.resourceInfo,
                            isFeatured: widget.isFeatured,
                            courseCategory: widget.courseCategory,
                            isPreRequisite: widget.isPreRequisite)));
              },
              style: TextButton.styleFrom(
                backgroundColor: AppColors.appBarBackground,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4)).r,
                    side: BorderSide(color: AppColors.primaryBlue))
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/img/reattempt.svg',
                    colorFilter:
                        ColorFilter.mode(AppColors.darkBlue, BlendMode.srcIn),
                    height: 20.w,
                  ),
                  Text(
                    '  ${AppLocalizations.of(context)!.mAssessmentReattemptTest}',
                    style: GoogleFonts.lato(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void generateSectionalSummary() {
    if (widget.apiResponse['children'] != null) {
      widget.apiResponse['children'].forEach((section) {
        sectionSummary.add({
          'sectionName': section['name'],
          'score':
              '${Helper.handleNumber(section['sectionMarks'])}/${section['totalMarks']}'
        });
      });
    }
  }

  Future _publicAssessmentDialog() async {
    if ((widget.apiResponse['pass'] ?? false) == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
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
                subtitle: AppLocalizations.of(context)!
                    .mAssessmentGuestCongratulationMessage,
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
      });
    }
  }

  void _generateInteractTelemetryData() async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.assessmentReattemptPageUri,
        contentId: widget.identifier,
        subType: AssessmentType.questionWeightage,
        env: TelemetryEnv.learn,
        objectType: widget.primaryCategory,
        clickId: TelemetryIdentifier.reattemptTest);
    await telemetryRepository.insertEvent(eventData: eventData);
  }
}
