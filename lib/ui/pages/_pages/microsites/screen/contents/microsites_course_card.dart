import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/ui/widgets/_common/rating_widget.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';

import '../../../../../../constants/_constants/app_routes.dart';
import '../../../../../../constants/_constants/color_constants.dart';
import '../../../../../../constants/_constants/telemetry_constants.dart';
import '../../../../../../localization/_langs/english_lang.dart';
import '../../../../../../models/_arguments/course_toc_model.dart';
import '../../../../../../models/_models/course_model.dart';
import '../../../../../../util/helper.dart';
import '../../../../../../util/telemetry_repository.dart';
import '../../../../../widgets/_home/duration_widget.dart';
import '../../../../../widgets/custom_image_widget.dart';
import '../../../../../widgets/show_date_widget.dart';
import '../../../../../widgets/title_bold_widget.dart';
import '../../../toc/widgets/language_count_widget.dart';

class MicroSitesCourseCard extends StatelessWidget {
  final Course course;
  final bool isProgram;
  final bool isCuratedProgram;
  final bool isFeatured;
  final bool isModerated;
  final bool isBlendedProgram;

  MicroSitesCourseCard(
      {required this.course,
      this.isProgram = false,
      this.isBlendedProgram = false,
      this.isCuratedProgram = false,
      this.isFeatured = false,
      this.isModerated = false});

  void _generateInteractTelemetryData(
      {required String contentId, required BuildContext context}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.topicCoursesPageId,
        contentId: contentId,
        subType: TelemetrySubType.courseCard,
        env: EnglishLang.explore,
        objectType: TelemetrySubType.courseCard);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () async {
          _generateInteractTelemetryData(
              contentId: course.id, context: context);
          // String batchId = '';
          // if (course.raw['cumulativeTracking'] != null) {
          //   if (course.raw['cumulativeTracking']) {
          //     course.raw['batches']
          //         .forEach((batch) => batchId = batch['batchId']);
          //   }
          // }

          Navigator.pushNamed(context, AppUrl.courseTocPage,
              arguments: CourseTocModel.fromJson({
                'courseId': course.id,
                'isBlendedProgram': isBlendedProgram,
                'isModeratedContent': isModerated
              }));
        },
        child: Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4).w,
            padding: EdgeInsets.all(16).w,
            decoration: BoxDecoration(
                color: AppColors.appBarBackground,
                borderRadius: BorderRadius.circular(12.w),
                border: Border.all(color: AppColors.grey08)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Stack(fit: StackFit.passthrough, children: <Widget>[
                      Container(
                        height: 100.w,
                        width: 139.w,
                        decoration: BoxDecoration(
                          color: AppColors.appBarBackground,
                          borderRadius:
                              BorderRadius.all(const Radius.circular(4.0)),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.grey08,
                              blurRadius: 3,
                              spreadRadius: 0,
                              offset: Offset(
                                3,
                                3,
                              ),
                            ),
                          ],
                        ),
                        child: ImageWidget(
                            imageUrl: course.appIcon,
                            height: 100.w,
                            width: 139.w),
                      ),
                      !isFeatured
                          ? Positioned(
                              bottom: 4,
                              right: 4,
                              child: course.duration != null
                                  ? (course.courseCategory).toLowerCase() ==
                                              (EnglishLang.blendedProgram)
                                                  .toLowerCase() &&
                                          course.duration == '0' &&
                                          course.programDuration == null
                                      ? Center()
                                      : course.programDuration != null &&
                                              course.programDuration!.isNotEmpty
                                          ? DurationWidget(
                                              course.programDuration ??
                                                  "" + ' days')
                                          : DurationWidget(isFeatured
                                              ? ('LEARNING HOURS: \t \t' +
                                                  DateTimeHelper.getTimeFormat(
                                                      course.duration))
                                              : DateTimeHelper.getTimeFormat(
                                                  course.duration))
                                  : (course.raw['content'] != null &&
                                          course.raw['content']['duration'] !=
                                              null)
                                      ? DurationWidget(
                                          DateTimeHelper.getTimeFormat(course
                                              .raw['content']['duration']))
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
                    ]),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TitleBoldWidget(
                              course.name,
                              fontSize: 14.sp,
                              maxLines: 2,
                            ),
                            SizedBox(height: 8.w),
                            //Source
                            Row(
                              children: [
                                (course.creatorIcon != '' && !isFeatured)
                                    ? Container(
                                        padding: EdgeInsets.all(8).w,
                                        decoration: BoxDecoration(
                                            color: AppColors.appBarBackground,
                                            border: Border.all(
                                                color: AppColors.grey16,
                                                width: 1),
                                            borderRadius: BorderRadius.all(
                                                const Radius.circular(4.0))),
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
                                            padding: EdgeInsets.all(4).w,
                                            decoration: BoxDecoration(
                                                color:
                                                    AppColors.appBarBackground,
                                                border: Border.all(
                                                    color: AppColors.grey16,
                                                    width: 1),
                                                borderRadius: BorderRadius.all(
                                                    const Radius.circular(
                                                        4.0))),
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
                                        EdgeInsets.only(left: 4, right: 8).w,
                                    child: Text(
                                      course.source != ''
                                          ? 'By ' + course.source
                                          : '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.lato(
                                        color: AppColors.greys87,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12.0.sp,
                                        height: 1.5.w,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.w),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/img/play_course.svg',
                                  width: 20.0.w,
                                  height: 20.0.w,
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 4, right: 8)
                                          .w,
                                  child: Text(
                                    course.courseCategory != ''
                                        ? Helper().capitalizeFirstCharacter(
                                            course.courseCategory)
                                        : '',
                                    style: GoogleFonts.lato(
                                      color: AppColors.greys60,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.w),
                            course.languageMap.languages.isNotEmpty
                                ? LanguageCountWidget(
                                    languages: course.languageMap.languages,
                                    padding: EdgeInsets.only(
                                            left: 16, top: 6, bottom: 6)
                                        .r)
                                : Center(),
                            //Rating
                            Padding(
                              padding: EdgeInsets.only(top: 5, bottom: 15).r,
                              child: RatingWidget(
                                  rating: course.rating.toString(),
                                  additionalTags: course.additionalTags),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ],
            )));
  }
}
