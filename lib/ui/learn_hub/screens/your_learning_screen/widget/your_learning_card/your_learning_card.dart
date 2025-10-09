import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:karmayogi_mobile/common_components/image_widget/image_widget.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/app_routes.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_arguments/course_toc_model.dart';
import 'package:karmayogi_mobile/models/_models/course_model.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';
import 'package:karmayogi_mobile/util/helper.dart';

class YourLearningCard extends StatelessWidget {
  final Course course;
  final bool isMandatory;

  const YourLearningCard(
      {required this.course, this.isMandatory = false, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _navigateToCourse(context),
      child: Container(
        width: double.infinity.w,
        color: AppColors.appBarBackground,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16).r,
              child: _buildCardHeader(context),
            ),
            _buildProgressBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCourseIcon(),
          SizedBox(width: 16.w),
          _buildCourseDetails(context),
        ],
      ),
    );
  }

  Widget _buildCourseIcon() {
    return Container(
      padding: EdgeInsets.only(top: 8).r,
      height: 64.w,
      width: 64.w,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4).r,
        child: ImageWidget(imageUrl: _fetchImageUrl()),
      ),
    );
  }

  Widget _buildCourseDetails(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(context),
          SizedBox(height: 4.h),
          _buildLicense(context),
          SizedBox(height: 8.h),
          _buildCreatorRow(context),
          if (isMandatory) _buildDeadline(context),
          if (course.duration != null) _buildDuration(context),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      course.name,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildLicense(BuildContext context) {
    return Text(
      course.licence,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: 14.sp,
          ),
    );
  }

  Widget _buildCreatorRow(BuildContext context) {
    return Row(
      children: [
        _buildCreatorLogo(),
        SizedBox(width: 8.w),
        _buildCategoryTag(context),
      ],
    );
  }

  Widget _buildCreatorLogo() {
    return Container(
      height: 24.w,
      width: 24.w,
      decoration: BoxDecoration(
        color: AppColors.appBarBackground,
        borderRadius: BorderRadius.circular(4.0).r,
      ),
      child: Image.network(
        course.creatorLogo,
        height: 24.w,
        width: 24.w,
        fit: BoxFit.cover,
        cacheWidth: 24,
        cacheHeight: 24,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          'assets/img/igot_creator_icon.png',
          height: 24.w,
          width: 24.w,
        ),
      ),
    );
  }

  Widget _buildCategoryTag(BuildContext context) {
    return Container(
      height: 24.w,
      decoration: BoxDecoration(
        color: AppColors.appBarBackground,
        border: Border.all(color: AppColors.grey08),
        borderRadius: BorderRadius.circular(4.0).r,
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8).r,
            child: SvgPicture.asset(
              'assets/img/course_icon.svg',
              width: 16.0.w,
              height: 16.0.w,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8).r,
            child: Text(
              course.courseCategory.toUpperCase(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeadline(BuildContext context) {
    final endDate = course.batch?.endDate;
    String deadlineText = '';

    if (endDate != null && endDate.isNotEmpty) {
      final parsedDate = DateTime.tryParse(endDate);
      if (parsedDate != null) {
        deadlineText = 'Deadline: ${DateFormat.yMMMd().format(parsedDate)}';
      }
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8).r,
      child: Text(
        deadlineText,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.429.w,
              letterSpacing: 0.25.r,
            ),
      ),
    );
  }

  Widget _buildDuration(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8).r,
      child: Text(
        DateTimeHelper.getTimeFormat(course.duration),
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 14.sp,
            ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return LinearProgressIndicator(
      minHeight: 8.w,
      backgroundColor: AppColors.grey16,
      valueColor: AlwaysStoppedAnimation<Color>(AppColors.darkBlue),
      value: (course.completionPercentage ?? 0) / 100,
    );
  }

  void _navigateToCourse(BuildContext context) {
    Navigator.pushNamed(
      context,
      AppUrl.courseTocPage,
      arguments: CourseTocModel(
        courseId: course.id,
        isBlendedProgram:
            course.courseCategory == PrimaryCategory.blendedProgram,
      ),
    );
  }

  String _fetchImageUrl() {
    return course.redirectUrl != null
        ? course.appIcon
        : Helper.convertImageUrl(course.appIcon);
  }
}
