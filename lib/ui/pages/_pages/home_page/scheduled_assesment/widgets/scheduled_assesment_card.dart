import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/common_components/image_widget/image_widget.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/home_page/scheduled_assesment/widgets/counter.dart';
import 'package:karmayogi_mobile/ui/widgets/primary_category_widget.dart';

import '../../../../../../constants/_constants/color_constants.dart';
import 'assesment_message.dart';

class ScheduledAssesmentCard extends StatelessWidget {
  final String title;
  final String? posterImage;
  final String provider;
  final String? providerLogo;
  final String startDate;
  final String courseId;
  final String endDate;
  final String courseCategory;
  final String? progress;

  const ScheduledAssesmentCard({
    required this.courseId,
    required this.title,
    required this.provider,
    required this.endDate,
    this.providerLogo,
    this.posterImage,
    required this.startDate,
    required this.courseCategory,
    this.progress,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey08),
        borderRadius: BorderRadius.circular(12).r,
      ),
      child: Stack(
        children: [
          Column(
            children: [
              _buildTopSection(),
              _buildBottomSection(),
            ],
          ),
          _buildAssessmentMessage(),
        ],
      ),
    );
  }

  Widget _buildTopSection() {
    return Container(
      height: 135.w,
      padding: EdgeInsets.all(16).r,
      decoration: BoxDecoration(
        color: AppColors.appBarBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(10).r),
      ),
      child: Row(
        children: [
          _buildPosterImage(),
          SizedBox(width: 8.w),
          _buildCourseDetails(),
        ],
      ),
    );
  }

  Widget _buildPosterImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4).r,
      child: posterImage != null && posterImage!.isNotEmpty
          ? ImageWidget(
              imageUrl: posterImage!,
              height: 80.w,
              width: 0.31.sw,
              boxFit: BoxFit.fill,
            )
          : Image.asset('assets/img/image_placeholder.jpg'),
    );
  }

  Widget _buildCourseDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 185.w,
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.lato(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(height: 8.w),
        SizedBox(
          width: 0.5.sw,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                PrimaryCategoryWidget(
                  addedMargin: true,
                  contentType: courseCategory,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 8.w),
        _buildProviderRow(),
      ],
    );
  }

  Widget _buildProviderRow() {
    return Row(
      children: [
        Container(
          height: 24.w,
          width: 24.w,
          padding: EdgeInsets.all(2).r,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2).r,
            border: Border.all(color: AppColors.grey16),
          ),
          child: providerLogo != null && providerLogo!.isNotEmpty
              ? Image.network(
                  providerLogo!,
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
                )
              : Image.asset('assets/img/igot_creator_icon.png'),
        ),
        SizedBox(width: 4.w),
        SizedBox(
          width: 180.w,
          child: Text(
            provider,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.lato(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildBottomSection() {
    return Container(
      height: 69.w,
      width: 1.sw,
      decoration: BoxDecoration(
        color: AppColors.assesmentCardBackground,
        border: Border.all(color: AppColors.assesmentCardBorder),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(10).r),
      ),
      child: BottomSection(
        courseId: courseId,
        startdate: startDate,
        enddate: endDate,
        progress: progress,
      ),
    );
  }

  Widget _buildAssessmentMessage() {
    return Positioned(
      top: 120.w,
      left: 0,
      right: 0,
      child: Center(
        child: AssesmentMessage(startdate: startDate),
      ),
    );
  }
}
