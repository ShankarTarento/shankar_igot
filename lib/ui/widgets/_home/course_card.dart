import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/index.dart';
import '../../../localization/index.dart';
import '../../../models/index.dart';
import '../../pages/_pages/toc/widgets/language_count_widget.dart';
import '../_common/rating_widget.dart';
import '../index.dart';
import 'course_card_banner.dart';
import 'course_card_description_widget.dart';

class CourseCard extends StatelessWidget {
  final Course course;

  final bool isVertical;
  final bool isFeatured;

  CourseCard(
      {required this.course, this.isVertical = false, this.isFeatured = false});

  Widget generateCourse(context) {
    var courseWidgets = Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: isFeatured ? MainAxisSize.min : MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //Image
        CourseCardBanner(
          appIcon: course.appIcon,
          redirectUrl: course.redirectUrl,
          creatorIcon: course.creatorIcon,
          duration: course.duration,
          isFeatured: isFeatured,
          isExternalCourse: course.isExternalCourse,
          isBlendedProgram: (course.courseCategory).toLowerCase() ==
              (EnglishLang.blendedProgram).toLowerCase(),
          isCourseCompleted:
              course.completionPercentage == COURSE_COMPLETION_PERCENTAGE,
          programDuration: course.programDuration,
          endDate: course.endDate,
          isApar: course.isApar,
        ),
        //Primary type
        course.isExternalCourse
            ? SizedBox()
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: isFeatured ? 12 : 2).r,
                      child: PrimaryCategoryWidget(
                          contentType: course.courseCategory),
                    ),
                    SizedBox(width: 8.w),
                  ],
                ),
              ),

        CourseCardDescriptionWidget(course: course, isFeatured: isFeatured),
        course.languageMap.languages.isNotEmpty
            ? LanguageCountWidget(
                languages: course.languageMap.languages,
                padding: EdgeInsets.only(left: 16, top: 6, bottom: 6).r)
            : Center(),
        course.rating != 0 || course.additionalTags.isNotEmpty
            ? Padding(
                padding: EdgeInsets.only(left: 16, bottom: 12).r,
                child: RatingWidget(
                  rating: course.rating.toString(),
                  additionalTags: course.additionalTags,
                ),
              )
            : Center()
      ],
    );

    return courseWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: COURSE_CARD_WIDTH.w,
      margin: isVertical
          ? EdgeInsets.only(bottom: 14).r
          : EdgeInsets.only(left: 16, bottom: 0).r,
      padding: EdgeInsets.only(bottom: isVertical ? 16 : 0).r,
      decoration: BoxDecoration(
        color: AppColors.appBarBackground,
        border: Border.all(color: AppColors.grey08),
        borderRadius: BorderRadius.circular(12).r,
      ),
      child: generateCourse(context),
    );
  }
}
