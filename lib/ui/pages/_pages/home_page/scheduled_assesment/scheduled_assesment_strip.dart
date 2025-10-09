import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/app_routes.dart';
import 'package:karmayogi_mobile/models/_arguments/course_toc_model.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/home_page/scheduled_assesment/scheduled_assesment_repository.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/home_page/scheduled_assesment/widgets/scheduled_assesment_card.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../../constants/_constants/color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ScheduledAssesmentStrip extends StatefulWidget {
  const ScheduledAssesmentStrip({Key? key}) : super(key: key);

  @override
  State<ScheduledAssesmentStrip> createState() =>
      _ScheduledAssesmentStripState();
}

class _ScheduledAssesmentStripState extends State<ScheduledAssesmentStrip> {
  final PageController controller = PageController();
  late Future<List<Course>> scheduledAssesments;

  @override
  void initState() {
    super.initState();
    scheduledAssesments =
        ScheduledAssesmentRepository().getCombainedAssessmentData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Course>>(
      future: scheduledAssesments,
      builder: (context, snapshot) {
        // if (snapshot.connectionState == ConnectionState.waiting) {
        //   return Padding(
        //     padding: EdgeInsets.all(16.0).r,
        //     child: ScheduledAssesmentSkeleton(),
        //   );
        // }

        final courses = snapshot.data;
        if (courses == null || courses.isEmpty) {
          return const SizedBox.shrink();
        }

        final displayCourses = courses
            .where((course) =>
                (_getStartDate(course) != null && _getEndDate(course) != null))
            .take(5)
            .toList();
        if (displayCourses.isEmpty) {
          return const SizedBox.shrink();
        }
        return SizedBox(
          height: 300.w,
          child: Column(
            children: [
              _buildTitle(context),
              _buildAssessmentPageView(displayCourses),
              _buildPageIndicator(displayCourses.length),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.w),
      child: Row(
        children: [
          Text(
            AppLocalizations.of(context)!.mScheduledAssesment,
            style: GoogleFonts.montserrat(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentPageView(List<Course> courses) {
    return SizedBox(
      height: 240.w,
      child: PageView.builder(
        controller: controller,
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          final startDate = _getStartDate(course);
          final endDate = _getEndDate(course);

          if (startDate == null || endDate == null)
            return const SizedBox.shrink();

          return Padding(
            padding: EdgeInsets.all(16.0.r),
            child: InkWell(
              onTap: () => _navigateToCourse(course),
              child: ScheduledAssesmentCard(
                courseCategory: course.courseCategory,
                endDate: endDate,
                courseId: course.id,
                provider: course.source,
                startDate: startDate,
                title: course.name,
                providerLogo: course.creatorLogo,
                posterImage: course.raw['posterImage'] ??
                    course.raw['content']['posterImage'] ??
                    '',
                progress: course.status,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPageIndicator(int count) {
    return SmoothPageIndicator(
      controller: controller,
      count: count,
      effect: ExpandingDotsEffect(
        activeDotColor: AppColors.orangeTourText,
        dotColor: AppColors.profilebgGrey20,
        dotHeight: 4.w,
        dotWidth: 4.w,
        spacing: 4,
      ),
    );
  }

  void _navigateToCourse(Course course) {
    Navigator.pushNamed(
      context,
      AppUrl.courseTocPage,
      arguments: CourseTocModel.fromJson({'courseId': course.id}),
    );
  }

  String? _getStartDate(Course course) {
    return course.assesmentBatch?.startDate ??
        course.startDate ??
        course.raw['content']['startDate'];
  }

  String? _getEndDate(Course course) {
    return course.assesmentBatch?.endDate ??
        course.endDate ??
        course.raw['content']['endDate'];
  }
}
