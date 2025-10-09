import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/ui/widgets/_common/rating_widget.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';

import '../../../constants/index.dart';
import '../../../localization/index.dart';
import '../../../models/_arguments/index.dart';
import '../../../models/index.dart';
import '../../../util/helper.dart';
import '../../../util/telemetry_repository.dart';
import '../../pages/_pages/toc/widgets/language_count_widget.dart';
import '../index.dart';

class BrowseCard extends StatelessWidget {
  final Course course;
  final bool isProgram;
  final bool isCuratedProgram;
  final bool isFeatured;
  final bool isModerated;
  final bool isBlendedProgram;
  final String? telemetrySubType;
  final String? telemetryPageId;

  BrowseCard(
      {required this.course,
      this.isProgram = false,
      this.isBlendedProgram = false,
      this.isCuratedProgram = false,
      this.isFeatured = false,
      this.isModerated = false,
      this.telemetrySubType,
      this.telemetryPageId});

  void _generateInteractTelemetryData(
      {required String contentId,
      String? objectType,
      required BuildContext context}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: telemetryPageId != null
            ? telemetryPageId!
            : TelemetryPageIdentifier.topicCoursesPageId,
        contentId: contentId,
        subType: telemetrySubType != null
            ? telemetrySubType!
            : TelemetrySubType.courseCard,
        env: TelemetryEnv.explore,
        objectType: objectType,
        clickId: TelemetryIdentifier.cardContent);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  @override
  Widget build(BuildContext context) {
    var imageExtension;
    imageExtension = course.appIcon != ""
        ? course.appIcon.substring(course.appIcon.length - 3)
        : "";
    return InkWell(
        onTap: () async {
          _generateInteractTelemetryData(
              contentId: course.id,
              objectType: course.courseCategory,
              context: context);

          if (course.isExternalCourse) {
            Navigator.pushNamed(context, AppUrl.externalCourseTocPage,
                arguments: CourseTocModel(
                    courseId: course.contentId,
                    externalId: course.externalId,
                    contentType: course.courseCategory));
          } else {
            Navigator.pushNamed(context, AppUrl.courseTocPage,
                arguments: CourseTocModel(
                    courseId: course.id,
                    isBlendedProgram: isBlendedProgram,
                    isModeratedContent: isModerated));
          }
        },
        child: Container(
            width: double.infinity.w,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4).r,
            padding: EdgeInsets.all(16).r,
            decoration: BoxDecoration(
                color: AppColors.appBarBackground,
                borderRadius: BorderRadius.circular(12).r,
                border: Border.all(color: AppColors.grey08)),
            child: Column(
              children: [
                //Primary type
                !course.isExternalCourse
                    ? PrimaryCategoryWidget(
                        contentType: course.courseCategory, addedMargin: true)
                    : SizedBox(),
                SizedBox(
                  height: 6.w,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ClipRRect(
                        child:
                            Stack(fit: StackFit.passthrough, children: <Widget>[
                      ClipRRect(
                          borderRadius: BorderRadius.circular(12).r,
                          child: imageExtension != 'svg'
                              ? CachedNetworkImage(
                                  imageUrl: fetchImageUrl(),
                                  fit: BoxFit.fill,
                                  height: 80.w,
                                  width: 139.w,
                                  memCacheWidth: 172,
                                  memCacheHeight: 172,
                                  placeholder: (context, url) {
                                    return Padding(
                                      padding: EdgeInsets.only(top: 100).r,
                                      child: PageLoader(),
                                    );
                                  },
                                  errorWidget: (context, obj, stack) =>
                                      Image.asset(
                                        'assets/img/image_placeholder.jpg',
                                        width: double.infinity.w,
                                        height: 139.w,
                                        fit: BoxFit.contain,
                                      ))
                              : SvgPicture.network(fetchImageUrl(),
                                  fit: BoxFit.fitWidth,
                                  height: 100.w,
                                  width: 139.w,
                                  placeholderBuilder: (context) => Image.asset(
                                        'assets/img/image_placeholder.jpg',
                                        width: 139.w,
                                        height: 100.w,
                                        fit: BoxFit.fitWidth,
                                      ))),
                      !isFeatured
                          ? Positioned(
                              bottom: 4,
                              right: 4,
                              child: course.duration != null
                                  ? course.isExternalCourse
                                      ? int.tryParse(course.duration!) != null
                                          ? DurationWidget(
                                              DateTimeHelper.getTimeFormatInHrs(
                                                  int.parse(course.duration!)))
                                          : SizedBox()
                                      : (course.courseCategory).toLowerCase() ==
                                                  (EnglishLang.blendedProgram)
                                                      .toLowerCase() &&
                                              course.duration == '0' &&
                                              course.programDuration == null
                                          ? Center()
                                          : course.programDuration != null &&
                                                  course.programDuration!
                                                      .isNotEmpty
                                              ? DurationWidget(
                                                  course.programDuration! +
                                                      ' days')
                                              : DurationWidget(isFeatured
                                                  ? ('LEARNING HOURS: \t \t' +
                                                      DateTimeHelper.getTimeFormat(
                                                          course.duration))
                                                  : DateTimeHelper.getTimeFormat(
                                                      course.duration))
                                  : (course.raw['content'] != null &&
                                          course.raw['content']['duration'] !=
                                              null)
                                      ? DurationWidget(DateTimeHelper.getTimeFormat(course.raw['content']['duration']))
                                      : Text(''),
                            )
                          : Center(),
                      Positioned(
                        top: 0,
                        left: 0,
                        child: course.endDate != null
                            ? ShowDateWidget(endDate: course.endDate!)
                            : Text(''),
                      )
                    ])),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TitleBoldWidget(
                              course.name,
                              fontSize: 14,
                              maxLines: 2,
                            ),
                            SizedBox(height: 8.w),
                            //Source
                            Row(
                              children: [
                                (course.creatorIcon != '' && !isFeatured)
                                    ? Container(
                                        padding: EdgeInsets.all(8).r,
                                        decoration: BoxDecoration(
                                            color: AppColors.appBarBackground,
                                            border: Border.all(
                                                color: AppColors.grey16,
                                                width: 1),
                                            borderRadius: BorderRadius.all(
                                                    const Radius.circular(4.0))
                                                .r),
                                        child: Image.network(
                                          course.creatorIcon,
                                          height: 16.w,
                                          width: 16.w,
                                          fit: BoxFit.cover,
                                          cacheWidth: 16,
                                          cacheHeight: 16,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Image.asset(
                                            'assets/img/igot_creator_icon.png',
                                            height: 16.w,
                                            width: 16.w,
                                          ),
                                        ),
                                      )
                                    : !isFeatured
                                        ? Container(
                                            padding: EdgeInsets.all(4).r,
                                            decoration: BoxDecoration(
                                                color:
                                                    AppColors.appBarBackground,
                                                border: Border.all(
                                                    color: AppColors.grey16,
                                                    width: 1),
                                                borderRadius: BorderRadius.all(
                                                        const Radius.circular(
                                                            4.0))
                                                    .r),
                                            child: Image.network(
                                              course.creatorLogo,
                                              height: 16.w,
                                              width: 16.w,
                                              fit: BoxFit.cover,
                                              cacheWidth: 24,
                                              cacheHeight: 24,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Image.asset(
                                                'assets/img/igot_creator_icon.png',
                                                height: 16.w,
                                                width: 16.w,
                                              ),
                                            ),
                                          )
                                        : Center(),
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.topLeft,
                                    padding:
                                        EdgeInsets.only(left: 16, right: 16).r,
                                    child: Text(
                                      course.source != ''
                                          ? 'By ' + course.source
                                          : '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall!
                                          .copyWith(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12.sp,
                                              height: 1.5.w),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            course.languageMap.languages.isNotEmpty
                                ? LanguageCountWidget(
                                    languages: course.languageMap.languages)
                                : Center(),
                            //Rating
                            course.rating != 0 ||
                                    course.additionalTags.isNotEmpty
                                ? Padding(
                                    padding: EdgeInsets.only(top: 16).r,
                                    child: RatingWidget(
                                        rating: course.rating.toString(),
                                        additionalTags: course.additionalTags,
                                        isFromBrowse: true),
                                  )
                                : Center(),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ],
            )));
  }

  String fetchImageUrl() {
    return course.redirectUrl != null
        ? course.appIcon
        : Helper.convertImageUrl(
            course.appIcon,
          );
  }
}
