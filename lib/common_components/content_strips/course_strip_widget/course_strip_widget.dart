import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';
import 'package:karmayogi_mobile/common_components/constants/widget_constants.dart';
import 'package:karmayogi_mobile/common_components/content_strips/course_strip_widget/widgets/course_strip.dart';
import 'package:karmayogi_mobile/common_components/content_strips/service/course_strip_service.dart';
import 'package:karmayogi_mobile/common_components/models/content_strip_model.dart';
import 'package:karmayogi_mobile/common_components/view_all_courses/view_all_courses.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/models/_models/course_model.dart';
import 'package:karmayogi_mobile/ui/skeleton/pages/course_card_skeleton_page.dart';
import 'package:karmayogi_mobile/ui/widgets/title_widget/title_widget.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:karmayogi_mobile/util/helper.dart';

class CourseStripWidget extends StatefulWidget {
  final ContentStripModel courseStripData;
  final String type;
  final Function()? onTapShowAll;
  const CourseStripWidget(
      {super.key,
      this.onTapShowAll,
      required this.courseStripData,
      this.type = WidgetConstants.courseStrip});

  @override
  State<CourseStripWidget> createState() => _CourseStripWidgetState();
}

class _CourseStripWidgetState extends State<CourseStripWidget> {
  late Future<List<Course>> courseStripDataFuture;

  @override
  void initState() {
    super.initState();

    getData();
  }

  void getData() {
    switch (widget.type) {
      case WidgetConstants.enrollmentCourseStrip:
        courseStripDataFuture = ContentStripService.getEnrollmentListCourses(
            stripData: widget.courseStripData);
        break;
      case WidgetConstants.featuredCourseStrip:
        courseStripDataFuture = getFeaturedCourses();
        break;
      default:
        try {
          courseStripDataFuture = ContentStripService.getCourseData(
              stripData: widget.courseStripData,
              addDateFilter: widget.courseStripData.request != null &&
                  widget
                          .courseStripData
                          .request?['request']['filters']['primaryCategory']
                          .first
                          .toString()
                          .toLowerCase() ==
                      PrimaryCategory.blendedProgram.toLowerCase());
        } catch (e) {
          courseStripDataFuture = ContentStripService.getCourseData(
              stripData: widget.courseStripData, addDateFilter: false);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: courseStripDataFuture,
        builder: (BuildContext context, AsyncSnapshot<List<Course>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Padding(
              padding: const EdgeInsets.only(left: 16.0).r,
              child: Column(
                children: [
                  Row(
                    children: [
                      ContainerSkeleton(
                        height: 32.w,
                        width: 200.w,
                      ),
                      Spacer(),
                      ContainerSkeleton(
                        height: 32.w,
                        width: 100.w,
                      ),
                      SizedBox(
                        width: 16.w,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8.w,
                  ),
                  CourseCardSkeletonPage(),
                  SizedBox(
                    height: 32.w,
                  ),
                ],
              ),
            );
          }
          if ((snapshot.data != null && snapshot.data!.length > 0)) {
            List<Course> courses = [];

            courses = snapshot.data!;

            return courses.isNotEmpty ||
                    widget.courseStripData.showNoResourceFound
                ? Column(
                    children: [
                      widget.courseStripData.title != null
                          ? Padding(
                              padding: const EdgeInsets.only(
                                      top: 12, left: 16, right: 16)
                                  .r,
                              child: TitleWidget(
                                  toolTipMessage:
                                      widget.courseStripData.toolTipMessage !=
                                              null
                                          ? Helper.capitalize(widget
                                              .courseStripData.toolTipMessage!
                                              .getText(context))
                                          : null,
                                  title: Helper.capitalize(widget
                                      .courseStripData.title!
                                      .getText(context)),
                                  showAllCallBack:
                                      courses.length > SHOW_ALL_CHECK_COUNT
                                          ? () {
                                              widget.onTapShowAll != null
                                                  ? widget.onTapShowAll!()
                                                  : Navigator.push(
                                                      context,
                                                      FadeRoute(
                                                        page: ViewAllCourses(
                                                            courseStripData: widget
                                                                .courseStripData,
                                                            type: widget.type),
                                                      ),
                                                    );
                                            }
                                          : null),
                            )
                          : SizedBox(),
                      SizedBox(
                        height: 16.w,
                      ),
                      CourseStrip(
                        onTapShowAll: widget.onTapShowAll,
                        courses: courses,
                        courseStripData: widget.courseStripData,
                      ),
                      SizedBox(
                        height: 12.w,
                      ),
                    ],
                  )
                : SizedBox();
          }
          return SizedBox();
        });
  }

  Future<List<Course>> getFeaturedCourses() async {
    List<Course> featuredCourses = await ContentStripService.getCourseData(
        stripData: widget.courseStripData, addDateFilter: false);
    featuredCourses.removeWhere((course) =>
        course.primaryCategory.toLowerCase() ==
        PrimaryCategory.landingPageResource.toLowerCase());
    return featuredCourses;
  }
}
