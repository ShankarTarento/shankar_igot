import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/common_components/content_strips/service/course_strip_service.dart';
import 'package:karmayogi_mobile/common_components/models/content_strip_model.dart';
import 'package:karmayogi_mobile/common_components/view_all_courses/view_all_courses.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/common_components/common_service/home_telemetry_service.dart';
import 'package:karmayogi_mobile/models/_arguments/course_toc_model.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:karmayogi_mobile/ui/skeleton/pages/course_card_skeleton_page.dart';
import 'package:karmayogi_mobile/ui/widgets/_home/course_card.dart';
import 'package:karmayogi_mobile/ui/widgets/title_widget/title_widget.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class CarouselCourseCard extends StatefulWidget {
  final ContentStripModel stripData;

  CarouselCourseCard({Key? key, required this.stripData}) : super(key: key);

  @override
  _CarouselCourseCardState createState() => _CarouselCourseCardState();
}

class _CarouselCourseCardState extends State<CarouselCourseCard> {
  final _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  initState() {
    super.initState();
    coursesList =
        ContentStripService.getCourseData(stripData: widget.stripData);
  }

  late Future<List<Course>> coursesList;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: coursesList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CourseCardSkeletonPage();
          }
          if (snapshot.data != null && snapshot.data!.isNotEmpty) {
            List<Course> courseList = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 16).r,
              child: Column(
                children: [
                  widget.stripData.title != null
                      ? Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16).r,
                          child: TitleWidget(
                              title: Helper.capitalize(
                                  widget.stripData.title!.getText(context)),
                              showAllCallBack: () {
                                HomeTelemetryService
                                    .generateInteractTelemetryData(
                                        TelemetryIdentifier.showAll,
                                        subType:
                                            widget.stripData.telemetrySubType,
                                        isObjectNull: true);
                                Navigator.push(
                                  context,
                                  FadeRoute(
                                    page: ViewAllCourses(
                                      courseStripData: widget.stripData,
                                    ),
                                  ),
                                );
                              }),
                        )
                      : SizedBox(),
                  Container(
                    height: 320.w,
                    width: double.infinity.w,
                    margin:
                        const EdgeInsets.only(top: 16, bottom: 4, right: 16).r,
                    child: Column(
                      children: [
                        Expanded(
                          child: PageView.builder(
                            controller: _controller,
                            itemCount: courseList.length < CERTIFICATE_COUNT
                                ? courseList.length
                                : CERTIFICATE_COUNT,
                            itemBuilder: (context, index) {
                              return courseCardWidget(
                                courseList[index],
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 8.w),
                        courseList.length > 1
                            ? SmoothPageIndicator(
                                controller: _controller,
                                count: courseList.length < 4
                                    ? courseList.length
                                    : 4,
                                effect: ExpandingDotsEffect(
                                    activeDotColor: AppColors.orangeTourText,
                                    dotColor: AppColors.profilebgGrey20,
                                    dotHeight: 4.w,
                                    dotWidth: 4.r,
                                    spacing: 4.r),
                              )
                            : Center()
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return SizedBox();
          }
        });
  }

  Widget courseCardWidget(Course course) {
    return InkWell(
        onTap: () async {
          HomeTelemetryService.generateInteractTelemetryData(course.id,
              subType: widget.stripData.telemetrySubType,
              clickId: TelemetryIdentifier.cardContent,
              primaryCategory: widget.stripData.telemetryPrimaryCategory);
          Navigator.pushNamed(context, AppUrl.courseTocPage,
              arguments: CourseTocModel.fromJson({'courseId': course.id}));
        },
        child: CourseCard(course: course));
  }
}
