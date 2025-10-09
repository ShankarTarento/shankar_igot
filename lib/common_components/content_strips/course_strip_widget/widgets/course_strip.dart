import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:karmayogi_mobile/common_components/models/content_strip_model.dart';
import 'package:karmayogi_mobile/common_components/show_all_card/show_all_card.dart';
import 'package:karmayogi_mobile/common_components/view_all_courses/view_all_courses.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/app_routes.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/common_components/common_service/home_telemetry_service.dart';
import 'package:karmayogi_mobile/models/_arguments/course_toc_model.dart';
import 'package:karmayogi_mobile/models/_models/course_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/my_learnings/no_data_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/_home/course_card.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CourseStrip extends StatelessWidget {
  final List<Course> courses;
  final ContentStripModel? courseStripData;
  final Function()? onTapShowAll;

  const CourseStrip({
    super.key,
    required this.courses,
    this.courseStripData,
    this.onTapShowAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300.w,
      width: double.infinity,
      margin: const EdgeInsets.only(left: 0, top: 5, bottom: 15).r,
      child: courses.isNotEmpty
          ? AnimationLimiter(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: courses.length < SHOW_ALL_CHECK_COUNT
                    ? courses.length
                    : SHOW_ALL_CHECK_COUNT,
                itemBuilder: (context, index) {
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: _buildCourseItem(context, index),
                      ),
                    ),
                  );
                },
              ),
            )
          : Center(
              child: AnimationConfiguration.staggeredList(
                position: 0,
                duration: const Duration(milliseconds: 375),
                child: FadeInAnimation(
                  child: NoDataWidget(
                    message: AppLocalizations.of(context)!.mNoResourcesFound,
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildCourseItem(BuildContext context, int index) {
    if (courses.length > SHOW_ALL_CHECK_COUNT &&
        index == SHOW_ALL_CHECK_COUNT - 1) {
      return Row(
        children: [
          _buildCourseCard(context, index),
          if (courseStripData != null)
            InkWell(
              onTap: () {
                onTapShowAll != null
                    ? onTapShowAll!()
                    : Navigator.push(
                        context,
                        FadeRoute(
                          page:
                              ViewAllCourses(courseStripData: courseStripData!),
                        ),
                      );
              },
              child: ShowAllCard(),
            ),
        ],
      );
    } else {
      return _buildCourseCard(context, index);
    }
  }

  Widget _buildCourseCard(BuildContext context, int index) {
    return InkWell(
      onTap: () async {
        HomeTelemetryService.generateInteractTelemetryData(
          courses[index].id,
          subType: courseStripData?.telemetrySubType ?? "",
          primaryCategory: courseStripData?.telemetryPrimaryCategory,
          clickId: TelemetryIdentifier.cardContent,
        );
        Navigator.pushNamed(
          context,
          AppUrl.courseTocPage,
          arguments: CourseTocModel.fromJson({'courseId': courses[index].id}),
        );
      },
      child: CourseCard(
        course: courses[index],
      ),
    );
  }
}
