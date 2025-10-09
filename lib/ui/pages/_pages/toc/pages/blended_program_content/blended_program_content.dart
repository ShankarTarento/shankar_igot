import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/models/_models/batch_model.dart';
import 'package:karmayogi_mobile/models/_models/course_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/blended_program_content/widgets/led_by_instructor.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/toc_content_page.dart';

class BlendedProgramContent extends StatefulWidget {
  final Course courseDetails;
  final Batch? batch;
  final dynamic course;
  final String courseId;
  final dynamic courseHierarchyData;
  final String? lastAccessContentId;
  final List navigationItems;
  final Course? enrolledCourse;
  final List<Batch>? batches;
  final List<Course> enrollmentList;
  final bool isPlayer;
  final VoidCallback? showLatestProgress;
  final ValueChanged<String>? startNewResourse;

  const BlendedProgramContent(
      {Key? key,
      required this.courseDetails,
      this.batch,
      required this.course,
      required this.courseHierarchyData,
      required this.courseId,
      required this.lastAccessContentId,
      required this.navigationItems,
      this.enrolledCourse,
      this.batches,
      this.enrollmentList = const [],
      this.isPlayer = false,
      this.showLatestProgress,
      this.startNewResourse})
      : super(key: key);

  @override
  State<BlendedProgramContent> createState() => _BlendedProgramContentState();
}

class _BlendedProgramContentState extends State<BlendedProgramContent> {
  List<String> contentType = [];
  int selectedContentIndex = 0;
  Future<List?>? _contentFuture;

  @override
  void didChangeDependencies() {
    contentType = [
      AppLocalizations.of(context)!.mBlendedSelfPaced,
      AppLocalizations.of(context)!.mBlendedInstructorLed
    ];
    super.didChangeDependencies();
  }

  void initState() {
    super.initState();
    _contentFuture = _getContent();
  }

  Future<List> _getContent() async {
    try {
      return Future.value(widget.navigationItems);
    } catch (err) {
      return Future.value([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        children: List.generate(
          contentType.length,
          (index) => GestureDetector(
            onTap: () {
              selectedContentIndex = index;
              setState(() {});
            },
            child: Container(
              margin: EdgeInsets.only(left: 16, top: 24).r,
              padding:
                  EdgeInsets.only(top: 6, bottom: 6, left: 16, right: 16).r,
              decoration: BoxDecoration(
                border: Border.all(
                    color: selectedContentIndex == index
                        ? AppColors.darkBlue
                        : AppColors.grey08),
                borderRadius: BorderRadius.circular(16).r,
              ),
              child: Text(
                contentType[index],
                style: GoogleFonts.lato(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: selectedContentIndex == index
                      ? AppColors.darkBlue
                      : AppColors.greys60,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
      Expanded(
          child: selectedContentIndex == 0
              ? FutureBuilder(
                  future: _contentFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Container();
                    }
                    return TocContentPage(
                        courseId: widget.courseId,
                        course: widget.course,
                        courseHierarchy: widget.courseHierarchyData,
                        navigationItems: widget.navigationItems,
                        lastAccessContentId: widget.lastAccessContentId,
                        enrolledCourse: widget.enrolledCourse,
                        enrollmentList: widget.enrollmentList,
                        isPlayer: widget.isPlayer,
                        startNewResourse: widget.startNewResourse);
                  },
                )
              : widget.batch != null &&
                      widget.batch!.batchAttributes!.sessionDetailsV2.isNotEmpty
                  ? LedByInstructor(
                      isEnrolledCourse: widget.enrolledCourse != null,
                      batch: widget.batch,
                      courseDetails: widget.courseDetails,
                      batches: widget.batches ?? [],
                      showLatestProgress: widget.showLatestProgress)
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 32),
                      child: Text(AppLocalizations.of(context)!
                          .mCommonnoSessionsAvailable),
                    ))
    ]);
  }

  Future<void> removeOfflineContentFromNavigation() async {
    widget.navigationItems.removeWhere((child) {
      if (child is! List &&
          child.primaryCategory == PrimaryCategory.offlineSession) {
        return true; // remove this child
      } else if (child is List) {
        child.removeWhere((childElement) {
          if (childElement is! List &&
              childElement.primaryCategory == PrimaryCategory.offlineSession) {
            return true; // remove this childElement
          } else if (childElement is List) {
            childElement.removeWhere((childItem) {
              return childItem is! List &&
                  childItem.primaryCategory == PrimaryCategory.offlineSession;
            });
          }
          return false;
        });
      }
      return false;
    });
    widget.navigationItems
        .removeWhere((element) => element is List && element.isEmpty);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {});
    });
  }
}
