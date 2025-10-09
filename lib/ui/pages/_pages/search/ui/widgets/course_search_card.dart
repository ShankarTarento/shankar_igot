import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_models/course_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/search/ui/widgets/course_progress_status_widget.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/widgets/language_count_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/_home/course_card_banner.dart';
import 'package:karmayogi_mobile/ui/widgets/_home/course_card_description_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/primary_category_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CourseSearchCard extends StatelessWidget {
  final Course course;
  const CourseSearchCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16).r,
      padding: EdgeInsets.all(16).r,
      decoration: BoxDecoration(
          color: AppColors.appBarBackground,
          borderRadius: BorderRadius.circular(16).r),
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(children: [
              SizedBox(
                width: 0.32.sw,
                height: 75.w,
                child: CourseCardBanner(
                    appIcon: course.appIcon,
                    creatorIcon: course.creatorIcon,
                    duration: course.duration,
                    language: course.language,
                    bottomRadius: 12,
                    createdOn: course.createdOn,
                    isExternalCourse: course.isExternalCourse),
              ),
              if (course.completionPercentage != null &&
                  course.completionPercentage! > 0)
                CourseProgressStatusWidget(
                    completionPercentage:
                        double.parse(course.completionPercentage!.toString()),
                    issuedCertificates: course.issuedCertificates,
                    name: course.name,
                    courseId: course.id,
                    courseCategory: course.courseCategory,
                    batchId: course.batchId)
            ]),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            //Primary type
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0).r,
                              child: PrimaryCategoryWidget(
                                  contentType: course.courseCategory),
                            ),
                          ]),
                    ),
                    CourseCardDescriptionWidget(
                        course: course, isFeatured: false),
                    course.languageMap.languages.isNotEmpty
                        ? LanguageCountWidget(
                            languages: course.languageMap.languages,
                            padding: EdgeInsets.only(left: 16, top: 5).r)
                        : Center(),
                    course.rating != 0 || course.additionalTags.isNotEmpty
                        ? Container(
                            width: 1.0.sw - 260.w,
                            padding:
                                EdgeInsets.only(left: 16, top: 5, bottom: 15),
                            child: Wrap(children: [
                              Row(children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    right: course.rating.toString() != '0.0'
                                        ? 5
                                        : 0,
                                  ).r,
                                  child: course.rating.toString() != '0.0'
                                      ? Icon(
                                          Icons.star,
                                          size: 16.sp,
                                          color: AppColors.primaryOne,
                                        )
                                      : Center(),
                                ),
                                course.rating.toString() != '0.0'
                                    ? Text(
                                        course.rating.toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall!
                                            .copyWith(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12.sp,
                                            ),
                                      )
                                    : Center()
                              ]),
                              course.additionalTags.isNotEmpty
                                  ? SizedBox(
                                      height: 25.w,
                                      child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount:
                                              course.additionalTags.length,
                                          itemBuilder:
                                              (BuildContext context, index) {
                                            return Container(
                                                margin:
                                                    EdgeInsets.only(left: 4).r,
                                                padding: EdgeInsets.symmetric(
                                                        vertical: 2,
                                                        horizontal: 4)
                                                    .r,
                                                decoration: BoxDecoration(
                                                  gradient:
                                                      LinearGradient(colors: [
                                                    AppColors.fourthLinearOne,
                                                    AppColors.fourthLinearTwo
                                                  ]),
                                                  borderRadius:
                                                      BorderRadius.circular(4)
                                                          .r,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.whatshot,
                                                      color: AppColors
                                                          .appBarBackground,
                                                      size: 16.sp,
                                                    ),
                                                    SizedBox(width: 4.w),
                                                    Text(
                                                        getTagsText(
                                                            context,
                                                            course
                                                                .additionalTags[
                                                                    index]
                                                                .toString()),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .labelSmall)
                                                  ],
                                                ));
                                          }),
                                    )
                                  : Center(),
                            ]),
                          )
                        : Center(),
                    course.endDate != null
                        ? Padding(
                            padding: const EdgeInsets.only(top: 16).r,
                            child: Row(children: [
                              Container(
                                margin: EdgeInsets.only(
                                  left: 16,
                                ).r,
                                decoration: BoxDecoration(
                                    color: AppColors.appBarBackground,
                                    border: Border.all(
                                        color: AppColors.grey16, width: 1),
                                    borderRadius: BorderRadius.all(
                                            const Radius.circular(4.0))
                                        .r),
                                child: Image.asset(
                                    'assets/img/igot_creator_icon.png',
                                    height: 16.w,
                                    width: 17.w),
                              ),
                              Container(
                                alignment: Alignment.topLeft,
                                padding: EdgeInsets.only(left: 8, right: 16).r,
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .mStaticAcbpBannerTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium!
                                      .copyWith(color: AppColors.greys60),
                                ),
                              )
                            ]),
                          )
                        : SizedBox()
                  ]),
            )
          ]),
    );
  }

  String getTagsText(BuildContext context, String tag) {
    switch (tag) {
      case 'mostEnrolled':
        return AppLocalizations.of(context)!.mStaticMostEnrolled;

      case 'mostTreanding':
        return AppLocalizations.of(context)!.mHomeLabelMostTrending;

      default:
        return tag;
    }
  }
}
