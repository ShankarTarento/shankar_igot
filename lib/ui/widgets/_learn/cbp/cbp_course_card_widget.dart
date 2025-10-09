import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:karmayogi_mobile/ui/widgets/_home/course_tag_widget.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';
import '../../../../constants/index.dart';
import '../../../../localization/index.dart';
import '../../../../models/index.dart';
import '../../../../util/helper.dart';
import '../../../pages/_pages/toc/widgets/language_count_widget.dart';
import '../../_common/rating_widget.dart';
import '../../index.dart';

class CbpCourseCard extends StatelessWidget {
  final Course course;
  const CbpCourseCard({Key? key, required this.course}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var imageExtension;
    if (course.appIcon.isNotEmpty) {
      imageExtension = course.appIcon.substring(course.appIcon.length - 3);
    }
    var imgExtension;
    if (course.raw['content'] != null &&
        course.raw['content']['posterImage'] != null) {
      imgExtension = course.raw['content']['posterImage']
          .substring(course.raw['content']['posterImage'].length - 3);
    }
    return Container(
        margin: EdgeInsets.only(bottom: 16).r,
        padding: EdgeInsets.all(16).r,
        decoration: BoxDecoration(
            color: AppColors.appBarBackground,
            borderRadius: BorderRadius.circular(12).r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PrimaryCategoryWidget(
                contentType: course.courseCategory, addedMargin: true),
            SizedBox(height: 8.w),
            Row(
              children: [
                ClipRRect(
                    child: Stack(fit: StackFit.passthrough, children: <Widget>[
                  course.appIcon.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          child: imageExtension != 'svg'
                              ? Image.network(
                                  fetchImageUrl(),
                                  fit: BoxFit.fill,
                                  width: 0.35.sw,
                                  height: 100.w,
                                  cacheWidth: 172,
                                  cacheHeight: 172,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset(
                                    'assets/img/image_placeholder.jpg',
                                    width: 0.35.sw,
                                    height: 100.w,
                                    fit: BoxFit.fitWidth,
                                  ),
                                )
                              : SvgPicture.network(fetchImageUrl(),
                                  fit: BoxFit.fill,
                                  width: 0.35.sw,
                                  height: 100.w,
                                  placeholderBuilder: (context) => Image.asset(
                                        'assets/img/image_placeholder.jpg',
                                        width: 0.35.sw,
                                        height: 100.w,
                                        fit: BoxFit.fitWidth,
                                      )))
                      : course.raw['content'] != null
                          ? ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)).r,
                              child: course.raw['content']['posterImage'] !=
                                      null
                                  ? imgExtension != 'svg'
                                      ? Image.network(
                                          fetchImageUrl(),
                                          fit: BoxFit.fill,
                                          width: 0.3.sw,
                                          height: 100.w,
                                          cacheWidth: 172,
                                          cacheHeight: 172,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Image.asset(
                                            'assets/img/image_placeholder.jpg',
                                            width: 0.3.sw,
                                            height: 100.w,
                                            fit: BoxFit.fitWidth,
                                          ),
                                        )
                                      : SvgPicture.network(fetchImageUrl(),
                                          fit: BoxFit.fill,
                                          width: 0.3.sw,
                                          height: 100.w,
                                          placeholderBuilder: (context) =>
                                              Image.asset(
                                                'assets/img/image_placeholder.jpg',
                                                width: 0.3.sw,
                                                height: 100.w,
                                                fit: BoxFit.fitWidth,
                                              ))
                                  : Image.asset(
                                      'assets/img/image_placeholder.jpg',
                                      width: 0.3.sw,
                                      height: 100.w,
                                      fit: BoxFit.fitWidth,
                                    ),
                            )
                          : Image.asset(
                              'assets/img/image_placeholder.jpg',
                              width: 0.35.sw,
                              height: 100.w,
                              fit: BoxFit.fitWidth,
                            ),
                  Positioned(
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
                                    course.programDuration! + ' days')
                                : DurationWidget(DateTimeHelper.getTimeFormat(
                                    course.duration))
                        : (course.raw['content'] != null &&
                                course.raw['content']['duration'] != null)
                            ? DurationWidget(DateTimeHelper.getTimeFormat(
                                course.raw['content']['duration']))
                            : Text(''),
                  ),
                  course.completionPercentage == COURSE_COMPLETION_PERCENTAGE
                      ? SizedBox()
                      : Positioned(
                          top: course.raw['cbPlanEndDate'] != null ? 4 : 0,
                          left: course.raw['cbPlanEndDate'] != null ? 4 : 0,
                          child: course.raw['cbPlanEndDate'] != null
                              ? Container(
                                  margin: EdgeInsets.all(4).r,
                                  padding: EdgeInsets.all(4).r,
                                  decoration: BoxDecoration(
                                      color: AppColors.appBarBackground,
                                      border: Border.all(
                                          color: AppColors.grey16, width: 1),
                                      borderRadius: BorderRadius.all(
                                              const Radius.circular(6.0))
                                          .r),
                                  child: Text(
                                    DateTimeHelper.getDateTimeInFormat(
                                        course.raw['cbPlanEndDate'].toString(),
                                        desiredDateFormat:
                                            IntentType.dateFormat2),
                                    style: GoogleFonts.lato(
                                      color: AppColors.greys87,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10.0.sp,
                                    ),
                                  ))
                              : course.endDate != null
                                  ? dateWidget(course.endDate!, context)
                                  : Text(''),
                        ),
                      /// Enable the block for APAR tag - start
                      if (course.isApar)
                        Positioned(
                            top: 0.w,
                            right: 0.w,
                            child: CourseTagWidget(
                                tag: EnglishLang.aparTag,
                                bgColor: AppColors.positiveLight,
                                textColor: Colors.white,
                                backgroundDecoration: BoxDecoration(
                                    color: Colors.transparent.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(12.0),
                                        bottomLeft: Radius.circular(8.0))
                                        .r)
                            )
                        ),
                      /// Enable the block for APAR tag - end
                ])),
                Flexible(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16).r,
                        child: Container(
                          height: 40.w,
                          child: Text(
                            course.raw['courseName'] != null
                                ? course.raw['courseName']
                                : course.raw['name'] != null
                                    ? course.raw['name']
                                    : '',
                            style: GoogleFonts.lato(
                                color: AppColors.greys87,
                                fontWeight: FontWeight.w700,
                                fontSize: 14.sp,
                                letterSpacing: 0.25,
                                height: 1.429.w),
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ),
                      //Source
                      Row(
                        children: [
                          (course.creatorIcon != '')
                              ? Container(
                                  margin: EdgeInsets.only(top: 8),
                                  decoration: BoxDecoration(
                                      color: AppColors.appBarBackground,
                                      border: Border.all(
                                          color: AppColors.grey16, width: 1),
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
                                  ))
                              : course.creatorLogo.isNotEmpty
                                  ? Container(
                                      margin:
                                          EdgeInsets.only(top: 6, left: 16).r,
                                      decoration: BoxDecoration(
                                          color: AppColors.appBarBackground,
                                          border: Border.all(
                                              color: AppColors.grey16,
                                              width: 1),
                                          borderRadius: BorderRadius.all(
                                                  const Radius.circular(4.0))
                                              .r),
                                      child: Image.network(
                                        course.creatorLogo,
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
                                  : SizedBox.shrink(),
                          Expanded(
                            child: Container(
                              alignment: Alignment.topLeft,
                              padding: EdgeInsets.only(left: 16, right: 16).r,
                              child: Text(
                                course.source != ''
                                    ? 'By ' + course.source
                                    : '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.lato(
                                  color: AppColors.greys60,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12.0.sp,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.w),
                      course.languageMap.languages.isNotEmpty
                          ? LanguageCountWidget(
                              languages: course.languageMap.languages,
                              padding:
                                  EdgeInsets.only(left: 16, top: 6, bottom: 6)
                                      .r)
                          : Center(),
                      //Rating
                      Padding(
                        padding:
                            EdgeInsets.only(left: 16, top: 5, bottom: 15).r,
                        child: RatingWidget(
                            rating: course.rating.toString(),
                            additionalTags: course.additionalTags),
                      )
                    ]))
              ],
            ),
          ],
        ));
  }

  String fetchImageUrl() {
    return course.redirectUrl != null
        ? course.appIcon
        : Helper.convertImageUrl(
            course.appIcon,
          );
  }

  Widget dateWidget(String endDate, BuildContext context) {
    int dateDiff = getTimeDiff(endDate, DateTime.now().toString());
    return Container(
      decoration: BoxDecoration(
          color: Colors.transparent.withValues(alpha: 0.5),
          borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  bottomRight: Radius.circular(8.0))
              .r),
      child: Container(
          margin: EdgeInsets.all(8).r,
          padding: EdgeInsets.all(4).r,
          decoration: BoxDecoration(
              color: dateDiff < 0
                  ? AppColors.negativeLight
                  : dateDiff < 30
                      ? AppColors.verifiedBadgeIconColor
                      : AppColors.positiveLight,
              borderRadius: BorderRadius.all(const Radius.circular(6.0)).r),
          child: Text(
            dateDiff < 0
                ? AppLocalizations.of(context)!.mStaticOverdue
                : DateTimeHelper.getDateTimeInFormat(endDate,
                    desiredDateFormat: IntentType.dateFormat2),
            style: GoogleFonts.lato(
                color: AppColors.appBarBackground,
                fontWeight: FontWeight.w400,
                fontSize: 10.0.sp,
                letterSpacing: 0.5),
          )),
    );
  }

  int getTimeDiff(String date1, String date2) {
    return DateTime.parse(
            DateFormat('yyyy-MM-dd').format(DateTime.parse(date1)))
        .difference(DateTime.parse(
            DateFormat('yyyy-MM-dd').format(DateTime.parse(date2))))
        .inDays;
  }
}
