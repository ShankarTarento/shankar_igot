import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/models/_models/course_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/learn/widgets/course_card_strip.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/mdo_channels/screens/mdo_channel_screen/widgets/state_learning_week/slw_repository/slw_repository.dart';
import 'package:karmayogi_mobile/ui/skeleton/pages/course_card_skeleton_page.dart';

class SlwCourseStrip extends StatefulWidget {
  final String title;
  final String type;
  final String mdoOrgId;
  const SlwCourseStrip(
      {super.key,
      required this.title,
      required this.type,
      required this.mdoOrgId});

  @override
  State<SlwCourseStrip> createState() => _SlwCourseStripState();
}

class _SlwCourseStripState extends State<SlwCourseStrip> {
  late Future<List<Course>> getCourseRecentlyFuture;
  @override
  void initState() {
    getCourseRecentlyFuture = SlwRepository()
        .getLearningContent(type: widget.type, mdoId: widget.mdoOrgId);

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
            telemetryPageIdentifier: TelemetryPageIdentifier.mdoChannelUri,
            telemetrySubType: TelemetrySubType.mdoChannelCourses,
          );
        }
        return SizedBox();
      },
    );
  }
}
