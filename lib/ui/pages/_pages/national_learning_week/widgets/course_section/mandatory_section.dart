import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/models/_models/course_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/learn/widgets/course_card_strip.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/national_learning_week/services/national_learning_week_view_model.dart';
import 'package:karmayogi_mobile/ui/skeleton/pages/course_card_skeleton_page.dart';

class MandatorySection extends StatefulWidget {
  final String title;
  const MandatorySection({super.key, required this.title});

  @override
  State<MandatorySection> createState() => _MandatorySectionState();
}

class _MandatorySectionState extends State<MandatorySection> {
  late Future<List<Course>> getCourseRecentlyFuture;
  @override
  void initState() {
    getCourseRecentlyFuture =
        NationalLearningWeekViewModel().getMandatoryCourses();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getCourseRecentlyFuture,
      builder: (BuildContext context, AsyncSnapshot<List<Course>> courses) {
        if (courses.connectionState == ConnectionState.waiting) {
          return Container(
            height: 296.w,
            child: ListView.separated(
              itemBuilder: (context, index) => const CourseCardSkeletonPage(),
              separatorBuilder: (context, index) => SizedBox(width: 8.w),
              itemCount: 3,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
            ),
          );
        }
        if (courses.data != null && courses.data!.isNotEmpty) {
          return CourseCardStrip(
            showFullLength: true,
            title: widget.title,
            courses: courses.data,
            telemetryEnv: TelemetryEnv.nationalLearningWeek,
            telemetryPageIdentifier:
                TelemetryPageIdentifier.nationalLearningWeekUri,
            telemetrySubType: 'mandatory-courses',
          );
        }
        return SizedBox();
      },
    );
  }
}
