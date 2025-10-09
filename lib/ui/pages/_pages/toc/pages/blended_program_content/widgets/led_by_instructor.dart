import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:karmayogi_mobile/services/_services/learn_service.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/blended_program_content/widgets/session_details.dart';
import '../../../../../../../constants/index.dart';
import 'course_type_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LedByInstructor extends StatefulWidget {
  final List<Batch> batches;
  final Batch? batch;
  final Course courseDetails;
  final bool isEnrolledCourse;
  final VoidCallback? showLatestProgress;
  const LedByInstructor(
      {Key? key,
      this.batch,
      required this.courseDetails,
      required this.batches,
      required this.isEnrolledCourse,
      this.showLatestProgress})
      : super(key: key);

  @override
  State<LedByInstructor> createState() => _LedByInstructorState();
}

class _LedByInstructorState extends State<LedByInstructor> {
  bool isExpanded = false;
  BatchAttribute? selectedBatchAttributes;
  List<SessionDetailV2>? sessionList;
  final LearnService learnService = LearnService();

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  Future<void> fetchData() async {
    sessionList = await getBatchAttributes();
    if (widget.batch != null) {
      await _readContentProgress(
          widget.batch!.batchId, widget.courseDetails.id);
    }
  }

  @override
  void didUpdateWidget(LedByInstructor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (((oldWidget.batch != null && widget.batch != null) &&
            (oldWidget.batch!.batchId != widget.batch!.batchId)) ||
        (oldWidget.batch == null && widget.batch != null)) {
      getBatchAttributes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(color: AppColors.appBarBackground),
        margin: EdgeInsets.only(
          top: 16,
        ).r,
        child: ExpansionTile(
          onExpansionChanged: (value) {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4).r,
          childrenPadding: EdgeInsets.only(bottom: 50).r,
          initiallyExpanded: true,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CourseTypeButton(
                      title: AppLocalizations.of(context)!.mStaticOffline),
                  SizedBox(
                    width: 8.w,
                  ),
                  CourseTypeButton(
                      title: AppLocalizations.of(context)!.mStaticOnline),
                ],
              ),
              SizedBox(
                height: 8.w,
              ),
              Text(
                widget.batch != null ? widget.batch!.name : '',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.w500,
                      fontFamily: GoogleFonts.montserrat().fontFamily,
                    ),
              )
            ],
          ),
          trailing: !isExpanded
              ? Icon(
                  Icons.arrow_drop_up,
                  color: AppColors.darkBlue,
                )
              : Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.darkBlue,
                ),
          children: [
            ...List.generate(
                selectedBatchAttributes != null
                    ? selectedBatchAttributes!.sessionDetailsV2.length
                    : 0,
                (index) => sessionList != null
                    ? SessionDetails(
                        isEnrolledCourse: widget.isEnrolledCourse,
                        selectedBatchAttributes: selectedBatchAttributes!,
                        batch: widget.batch,
                        courseDetails: widget.courseDetails,
                        session: sessionList![index],
                        onAttendanceMarked: () async {
                          await _readContentProgress(
                              widget.batch!.batchId, widget.courseDetails.id);
                          if (widget.batch != null) {
                            if (widget.showLatestProgress != null) {
                              widget.showLatestProgress!();
                            }
                          }
                        },
                      )
                    : Center()),
            SizedBox(
              height: 200.w,
            )
          ],
        ),
      ),
    );
  }

  Future<List<SessionDetailV2>?> getBatchAttributes() async {
    List<SessionDetailV2>? list;
    if (widget.batch != null) {
      selectedBatchAttributes = widget.batch!.batchAttributes;
      list = widget.batch!.batchAttributes!.sessionDetailsV2;
      return list;
    }
    return null;
  }

  Future<void> _readContentProgress(batchId, courseId) async {
    var response = await learnService.readContentProgress(courseId, batchId, language: widget.courseDetails.language);
    if (response['result']['contentList'] != null) {
      var contentProgressList = response['result']['contentList'];
      if (contentProgressList != null) {
        for (int i = 0; i < contentProgressList.length; i++) {
          if (contentProgressList[i]['progress'] == 100 &&
              contentProgressList[i]['status'] == 2) {
            sessionList = sessionList!.map((element) {
              if (element.sessionId == contentProgressList[i]['contentId']) {
                element.sessionAttendanceStatus = true;
                element.lastCompletedTime =
                    contentProgressList[i]['lastCompletedTime'];
              }
              return element;
            }).toList();
          }
        }
      }
    }
    setState(() {});
  }
}
