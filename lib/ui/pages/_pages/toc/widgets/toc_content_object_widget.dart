import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/learn_compatibility_constants.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/util/toc_helper.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/widgets/rate_now_pop_up.dart';

import '../../../../../constants/index.dart';
import '../../../../../models/_arguments/index.dart';
import '../../../../../models/index.dart';
import '../../../../../respositories/_respositories/in_app_review_repository.dart';
import '../../../../widgets/index.dart';
import '../util/toc_constants.dart';

class TocContentObjectWidget extends StatelessWidget {
  const TocContentObjectWidget(
      {Key? key,
      required this.content,
      required this.course,
      required this.showProgress,
      this.lastAccessContentId,
      required this.navigationItems,
      this.enrolledCourse,
      required this.courseId,
      this.batchId,
      this.isFeatured = false,
      this.startNewResourse,
      this.isPlayer = false,
      this.isCuratedProgram = false,
      this.readCourseProgress,
      this.allowAccess = false,
      required this.enrollmentList,
      required this.parentCompatibility,
      required this.contextLockingType,
      this.isMandatory})
      : super(key: key);

  final content;
  final Course course;
  final bool isFeatured, showProgress, isPlayer, isCuratedProgram;
  final String? lastAccessContentId;
  final ValueChanged<String>? startNewResourse;
  final List navigationItems;
  final Course? enrolledCourse;
  final String courseId;
  final String? batchId;
  final VoidCallback? readCourseProgress;
  final bool allowAccess;
  final List<Course> enrollmentList;
  final int parentCompatibility;
  final String contextLockingType;
  final bool? isMandatory;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: content.parentCourseId == course.id
          ? EdgeInsets.symmetric(vertical: 8).r
          : EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.appBarBackground,
        ),
        child: InkWell(
          onTap: () async {
            // _generateInteractTelemetryData(
            //     content['identifier'], content['mimeType']);
            if (isPlayer) {
              if (!content.isLocked) {
                startNewResourse!(content.contentId);
              }
            } else if (allowAccess) {
              var result;
              if ((course.courseCategory == PrimaryCategory.moderatedProgram ||
                      course.courseCategory ==
                          PrimaryCategory.inviteOnlyAssessment ||
                      course.courseCategory ==
                          PrimaryCategory.blendedProgram) &&
                  TocHelper().isProgramLive(enrolledCourse) &&
                  batchId != null) {
                result = await Navigator.pushNamed(
                  context,
                  AppUrl.tocPlayer,
                  arguments: TocPlayerModel(
                      enrolledCourse: enrolledCourse,
                      navigationItems: navigationItems,
                      isCuratedProgram: isCuratedProgram,
                      batchId: batchId,
                      lastAccessContentId: content.contentId,
                      courseId: courseId,
                      isFeatured: isFeatured,
                      enrollmentList: enrollmentList),
                );
              } else if (course.courseCategory !=
                      PrimaryCategory.moderatedProgram &&
                  course.courseCategory != PrimaryCategory.blendedProgram &&
                  course.courseCategory !=
                      PrimaryCategory.inviteOnlyAssessment &&
                  batchId != null) {
                result = await Navigator.pushNamed(
                  context,
                  AppUrl.tocPlayer,
                  arguments: TocPlayerModel(
                      enrolledCourse: enrolledCourse,
                      navigationItems: navigationItems,
                      isCuratedProgram: isCuratedProgram,
                      batchId: batchId,
                      lastAccessContentId: content.contentId,
                      courseId: courseId,
                      isFeatured: isFeatured,
                      enrollmentList: enrollmentList),
                );
              }
              if (result != null && result is Map<String, bool>) {
                Map<String, dynamic> response = result;
                if (response['isFinished']) {
                  showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          backgroundColor: AppColors.greys60,
                          builder: (ctx) => RateNowPopUp(courseDetails: course))
                      .whenComplete(() => InAppReviewRespository()
                          .triggerInAppReviewPopup(context));
                }
              }
              readCourseProgress!();
            }
          },
          child: content.mimeType != null
              ? content.mimeType == EMimeTypes.offline
                  ? Center()
                  : Column(
                      children: [
                        GlanceItem3(
                            icon: TocHelper.getMimeTypeIcon(content.mimeType),
                            text: content.name,
                            status: enrolledCourse != null &&
                                    enrolledCourse!.completionPercentage ==
                                        COURSE_COMPLETION_PERCENTAGE
                                ? 2
                                : content.status,
                            duration: content.duration,
                            isFeaturedCourse: isFeatured,
                            currentProgress: enrolledCourse != null &&
                                    enrolledCourse!.completionPercentage ==
                                        COURSE_COMPLETION_PERCENTAGE
                                ? 1
                                : double.parse(content.completionPercentage.toString()) >
                                        1
                                    ? double.parse(content.completionPercentage.toString()) /
                                        100
                                    : double.parse(content.completionPercentage
                                        .toString()),
                            showProgress: showProgress,
                            isLastAccessed:
                                content.contentId == lastAccessContentId,
                            isEnrolled:
                                isPlayer ? true : enrolledCourse != null,
                            maxQuestions: content.maxQuestions.toString(),
                            mimeType: content.mimeType,
                            isLocked: content.isLocked,
                            isL2Assessment: content.parentCourseId ==
                                    course.id &&
                                parentCompatibility >=
                                    ResourceCategoryVersion
                                        .contentCompatibility.version &&
                                contextLockingType ==
                                    EContextLockingType.courseAssessmentOnly &&
                                content.mimeType == EMimeTypes.newAssessment &&
                                TocConstants.contextLockCategories
                                    .contains(course.courseCategory),
                            isMandatory: isMandatory),
                      ],
                    )
              : Center(),
        ),
      ),
    );
  }
}
