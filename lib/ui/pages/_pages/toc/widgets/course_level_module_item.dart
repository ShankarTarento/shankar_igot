import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/util/toc_helper.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';

import '../../../../../constants/index.dart';
import '../../../../../models/index.dart';
import '../../../../widgets/index.dart';
import '../../../index.dart';

class CourseLevelModuleItem extends StatefulWidget {
  final index, content;
  final Course course;
  final CourseHierarchyModel courseHierarchyInfo;
  final List<Course> enrollmentList;
  final bool isCuratedProgram,
      isProgram,
      isFeatured,
      showCertificateIcon,
      showProgress,
      isPlayer,
      allowAccess;
  final String? batchId;
  final String? lastAccessContentId;
  final List<Map> showCertificate;
  final ValueChanged<String>? startNewResourse;
  final Course? enrolledCourse;
  final VoidCallback? readCourseProgress;

  const CourseLevelModuleItem(
      {Key? key,
      required this.index,
      required this.content,
      required this.course,
      required this.courseHierarchyInfo,
      required this.enrollmentList,
      this.batchId,
      required this.showCertificate,
      this.lastAccessContentId,
      this.enrolledCourse,
      this.showCertificateIcon = false,
      this.isCuratedProgram = false,
      this.showProgress = false,
      this.isProgram = false,
      this.isFeatured = false,
      this.isPlayer = false,
      this.startNewResourse,
      this.readCourseProgress,
      this.allowAccess = false})
      : super(key: key);

  @override
  State<CourseLevelModuleItem> createState() => _CourseLevelModuleItemState();
}

class _CourseLevelModuleItemState extends State<CourseLevelModuleItem> {
  int index = 0;
  double progressValue = 0;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    index = widget.index;
    if (widget.showProgress) {
      progressValue = getCompletionStatus(widget.content[index]);
      isExpanded = TocHelper.containsLastAccessedContent(
          widget.content[index], widget.lastAccessContentId);
    }
  }

  @override
  void didUpdateWidget(CourseLevelModuleItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    isExpanded = false;
    index = widget.index;
    if (widget.showProgress) {
      progressValue = getCompletionStatus(widget.content[index]);
      isExpanded = TocHelper.containsLastAccessedContent(
          widget.content[index], widget.lastAccessContentId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      for (int j = 0; j < widget.content[index].length; j++)
        (widget.content[index][j] is List &&
                widget.content[index][j][0] != null)
            ? Container(
                margin: EdgeInsets.only(top: 16).r,
                decoration: BoxDecoration(
                    border: Border.all(
                        color: isExpanded
                            ? AppColors.darkBlue
                            : AppColors.appBarBackground),
                    color: isExpanded
                        ? AppColors.darkBlue
                        : AppColors.appBarBackground),
                child: ExpansionTile(
                  onExpansionChanged: (value) {
                    setState(() {
                      isExpanded = value;
                    });
                  },
                  initiallyExpanded: isExpanded,
                  tilePadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 4).r,
                  childrenPadding: EdgeInsets.zero.r,
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: Container(
                        padding: const EdgeInsets.only(left: 6).r,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${index + 1}  ${widget.content[index][j][0].courseName}',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.montserrat(
                                  height: 1.5.w,
                                  decoration: TextDecoration.none,
                                  color: isExpanded
                                      ? AppColors.appBarBackground
                                      : AppColors.greys87,
                                  fontSize: 16.sp,
                                  fontWeight: isExpanded
                                      ? FontWeight.w700
                                      : FontWeight.w500),
                            ),
                            SizedBox(height: 4.w),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CourseAtGlanceWidget(
                                  courseInfo: widget.content[index][j][0],
                                  courseHierarchyInfo:
                                      widget.courseHierarchyInfo,
                                  isExpanded: isExpanded,
                                  isCourse: true,
                                ),
                              ],
                            ),
                            SizedBox(height: 8.w),
                            !widget.isFeatured &&
                                    widget.showProgress &&
                                    progressValue != 0
                                ? (widget.enrolledCourse != null &&
                                            widget.enrolledCourse!
                                                    .completionPercentage ==
                                                100) ||
                                        progressValue == 1
                                    ? TocDownloadCertificateWidget(
                                        courseId: widget.content[index][j][0]
                                            .parentCourseId,
                                        isPlayer: widget.isPlayer,
                                        isExpanded: isExpanded &&
                                            widget.enrolledCourse != null,
                                        enrolledCourse:
                                            getEnrolledCourse(i: index, j: j))
                                    : LinearProgressIndicatorWidget(
                                        value: progressValue,
                                        isExpnaded: isExpanded,
                                        isCourse: true)
                                : Center()
                          ],
                        ),
                      )),
                    ],
                  ),
                  trailing: isExpanded
                      ? Icon(
                          Icons.arrow_drop_up,
                          color: AppColors.appBarBackground,
                        )
                      : Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.darkBlue,
                        ),
                  children: [
                    for (var k = 0; k < widget.content[index].length; k++, j++)
                      Container(
                        color: AppColors.appBarBackground,
                        child: (widget.content[index][k] is List &&
                                widget.content[index][k][0] != null
                            ? ModuleItem(
                                course: widget.course,
                                moduleIndex: k,
                                moduleName:
                                    widget.content[index][k][0].moduleName,
                                glanceListItems: widget.content[index][k],
                                navigation: widget.content[index],
                                batchId: widget.batchId,
                                isFeatured: widget.isFeatured,
                                duration:
                                    getModuleDuration(widget.content[index][k]),
                                parentCourseId:
                                    widget.content[index][k][0].parentCourseId,
                                showProgress: widget.showProgress,
                                courseHierarchyInfo: widget.courseHierarchyInfo,
                                itemCount: widget.content[index][k].length,
                                lastAccessContentId: widget.lastAccessContentId,
                                startNewResourse: widget.startNewResourse,
                                isPlayer: widget.isPlayer,
                                navigationItems: widget.content,
                                enrolledCourse: widget.enrolledCourse,
                                readCourseProgress: () =>
                                    widget.readCourseProgress!(),
                                allowAccess: widget.allowAccess,
                                enrollmentList: widget.enrollmentList)
                            : (widget.content[index][k] != null)
                                ? Column(
                                    children: [
                                      TocContentObjectWidget(
                                          content: widget.content[index][k],
                                          course: widget.course,
                                          showProgress: widget.showProgress,
                                          lastAccessContentId:
                                              widget.lastAccessContentId,
                                          startNewResourse:
                                              widget.startNewResourse,
                                          isPlayer: widget.isPlayer,
                                          enrolledCourse: widget.enrolledCourse,
                                          navigationItems: widget.content,
                                          courseId: widget.course.id,
                                          batchId: widget.batchId,
                                          isCuratedProgram:
                                              widget.isCuratedProgram,
                                          allowAccess: widget.allowAccess,
                                          isFeatured: widget.isFeatured,
                                          enrollmentList: widget.enrollmentList,
                                          parentCompatibility:
                                              widget.course.compatibilityLevel,
                                          contextLockingType:
                                              widget.course.contextLockingType),
                                    ],
                                  )
                                : Center()),
                      )
                  ],
                ),
              )
            : Center()
    ]);
  }

  Course? getEnrolledCourse({required int i, required int j}) {
    return widget.enrollmentList.cast<Course?>().firstWhere(
        (course) => course!.id == widget.content[i][j][0].parentCourseId,
        orElse: () => null);
  }

  String getModuleDuration(content) {
    int totalDurationInMilliSeconds = 0;
    content.forEach((item) {
      totalDurationInMilliSeconds +=
          DateTimeHelper.getMilliSecondsFromTimeFormat(item.duration);
    });
    return DateTimeHelper.getFullTimeFormat(
        totalDurationInMilliSeconds.toString());
  }

  bool isLastAccessedContentExist() {
    for (var content in widget.content) {
      if (content is List) {
        for (var childContent in content) {
          if (childContent is List) {
            for (var subContent in childContent) {
              if (subContent.contentId == widget.lastAccessContentId) {
                return true;
              }
            }
          } else if (childContent.contentId == widget.lastAccessContentId) {
            return true;
          }
        }
      } else if (content.contentId == widget.lastAccessContentId) {
        return true;
      }
    }
    return false;
  }

  double getCompletionStatus(content) {
    if (content is List) {
      double totalprogress = 0;
      int resourceCount = 0;
      content.forEach((element) {
        if (element is List) {
          element.forEach((child) {
            if (child is List) {
              child.forEach((innerChild) {
                if (innerChild.status == 2) {
                  totalprogress += 1;
                  resourceCount++;
                } else {
                  totalprogress +=
                      double.parse(innerChild.completionPercentage.toString());
                  resourceCount++;
                }
              });
            } else {
              if (child.status == 2) {
                totalprogress += 1;
                resourceCount++;
              } else {
                totalprogress +=
                    double.parse(child.completionPercentage.toString());
                resourceCount++;
              }
            }
          });
        } else {
          if (element.status == 2) {
            totalprogress += 1;
            resourceCount++;
          } else {
            totalprogress +=
                double.parse(element.completionPercentage.toString());
            resourceCount++;
          }
        }
      });
      return totalprogress / resourceCount;
    } else {
      return double.parse(content.completionPercentage.toString());
    }
  }
}
