import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/models/_models/course_model.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import '../../../models/_arguments/index.dart';

class MyLearningCard extends StatelessWidget {
  final Course course;
  final bool isMandatory;

  MyLearningCard(this.course, {this.isMandatory = false});

  @override
  Widget build(BuildContext context) {
    var imageExtension;
    if (course.raw['content']['appIcon'] != null) {
      imageExtension = course.raw['content']['appIcon']
          .substring(course.raw['content']['appIcon'].length - 3);
    }
    return InkWell(
        onTap: () async {
          Navigator.pushNamed(context, AppUrl.courseTocPage,
              arguments: CourseTocModel(
                courseId: course.id,
                isBlendedProgram:
                    course.courseCategory == PrimaryCategory.blendedProgram,
              ));
        },
        child: Container(
          width: double.infinity.w,
          color: AppColors.appBarBackground,
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.all(16).r,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 8).r,
                        height: 64.w,
                        width: 64.w,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4).r,
                          child: imageExtension != 'svg'
                              ? CachedNetworkImage(
                                  imageUrl: fetchImageUrl(),
                                  fit: BoxFit.fill,
                                  height: 64.w,
                                  width: 10.w,
                                  memCacheWidth: 172,
                                  memCacheHeight: 172,
                                  errorWidget: (context, error, stackTrace) =>
                                      Image.asset(
                                    'assets/img/image_placeholder.jpg',
                                    height: 64.w,
                                    width: 10.w,
                                    fit: BoxFit.fitWidth,
                                  ),
                                )
                              : SvgPicture.network(fetchImageUrl(),
                                  fit: BoxFit.fill,
                                  height: 64.w,
                                  width: 10.w,
                                  placeholderBuilder: (context) => Image.asset(
                                        'assets/img/image_placeholder.jpg',
                                        height: 64.w,
                                        width: 40.w,
                                        fit: BoxFit.fitWidth,
                                      )),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16).r,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 4).r,
                              child: Container(
                                width: 1.sw / 1.5,
                                child: Text(
                                  course.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4).r,
                              child: Container(
                                width: 1.sw / 1.5,
                                child: Text(
                                  course.licence,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall!
                                      .copyWith(
                                        fontSize: 14.sp,
                                      ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8).r,
                              child: Row(
                                children: [
                                  Container(
                                    height: 24.w,
                                    width: 24.w,
                                    decoration: BoxDecoration(
                                      color: AppColors.appBarBackground,
                                      borderRadius: BorderRadius.all(
                                          const Radius.circular(4.0).r),
                                      // shape: BoxShape.circle,
                                    ),
                                    child: Image.network(
                                      course.creatorLogo,
                                      height: 16.w,
                                      width: 16.w,
                                      fit: BoxFit.cover,
                                      cacheWidth: 24,
                                      cacheHeight: 24,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Image.asset(
                                        'assets/img/igot_creator_icon.png',
                                        height: 16.w,
                                        width: 16.w,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8).r,
                                    child: Container(
                                      height: 24.w,
                                      // width: 85,
                                      decoration: BoxDecoration(
                                        color: AppColors.appBarBackground,
                                        border:
                                            Border.all(color: AppColors.grey08),
                                        borderRadius: BorderRadius.all(
                                                const Radius.circular(4.0))
                                            .r,
                                        // shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // assets/img/course_icon.svg
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(left: 8)
                                                      .r,
                                              child: SvgPicture.asset(
                                                'assets/img/course_icon.svg',
                                                width: 16.0.w,
                                                height: 16.0.w,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                      left: 6, right: 8)
                                                  .r,
                                              child: Text(
                                                course.courseCategory
                                                    .toUpperCase(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headlineSmall!
                                                    .copyWith(
                                                      fontSize: 10.sp,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            isMandatory == true
                                ? Container(
                                    width: 0.7.sw,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                                  top: 16, bottom: 8)
                                              .r,
                                          child: Text(
                                            'Deadline: ' +
                                                ((course.batch != null &&
                                                        course.batch!.endDate
                                                            .isNotEmpty)
                                                    ? DateFormat.yMMMd()
                                                        .format(DateTime.parse(
                                                            course.batch!
                                                                .endDate))
                                                        .toString()
                                                    : ''),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                  height: 1.429.w,
                                                  letterSpacing: 0.25.r,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Center(),
                            course.duration != null
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 8).r,
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 0).r,
                                          child: course.duration != null
                                              ? Text(
                                                  DateTimeHelper.getTimeFormat(
                                                      course.duration),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headlineSmall!
                                                      .copyWith(
                                                        fontSize: 14.0.sp,
                                                      ),
                                                )
                                              : Text(''),
                                        ),
                                      ],
                                    ),
                                  )
                                : Center(),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              LinearProgressIndicator(
                minHeight: 8.w,
                backgroundColor: AppColors.grey16,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.darkBlue,
                ),
                value: course.completionPercentage != null
                    ? course.completionPercentage! / 100
                    : 0,
              ),
            ],
          ),
        ));
  }

  String fetchImageUrl() {
    return course.redirectUrl != null
        ? course.appIcon
        : Helper.convertImageUrl(
            course.appIcon,
          );
  }
}
