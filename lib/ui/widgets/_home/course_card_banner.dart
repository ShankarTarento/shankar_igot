import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';

import '../../../constants/index.dart';
import '../../../localization/index.dart';
import '../../../util/index.dart';
import '../../pages/_pages/search/utils/search_helper.dart';
import '../index.dart';
import 'course_tag_widget.dart';

class CourseCardBanner extends StatelessWidget {
  final String appIcon;
  final String creatorIcon;
  final String? endDate;
  final String? redirectUrl;
  final String? duration;
  final String? programDuration;
  final String? language;
  final bool isFeatured;
  final bool isExternalCourse;
  final bool isBlendedProgram;
  final bool isCourseCompleted;
  final bool pointToProd;
  final bool isEvent;
  final double bottomRadius;
  final String? createdOn;
  final bool? isApar;

  const CourseCardBanner(
      {super.key,
      required this.appIcon,
      required this.creatorIcon,
      this.endDate,
      this.redirectUrl,
      this.duration,
      this.programDuration,
      this.language,
      this.isFeatured = false,
      this.isExternalCourse = false,
      this.isBlendedProgram = false,
      this.isCourseCompleted = false,
      this.pointToProd = false,
      this.isEvent = false,
      this.bottomRadius = 0,
      this.createdOn,
      this.isApar = false});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        child: Stack(fit: StackFit.passthrough, children: <Widget>[
      appIcon.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(bottomRadius),
                      bottomRight: Radius.circular(bottomRadius))
                  .r,
              child: Helper.getImageExtension(appIcon) != 'svg'
                  ? CachedNetworkImage(
                      imageUrl: fetchImageUrl(),
                      fit: BoxFit.fill,
                      width: double.infinity,
                      height: 130.w,
                      memCacheWidth: 172,
                      memCacheHeight: 172,
                      errorWidget: (context, error, stackTrace) => Image.asset(
                        'assets/img/image_placeholder.jpg',
                        width: double.infinity.w,
                        height: 125.w,
                        fit: BoxFit.fitWidth,
                      ),
                    )
                  : SvgPicture.network(fetchImageUrl(),
                      fit: BoxFit.fill,
                      width: 0.35.sw,
                      height: 130.w,
                      placeholderBuilder: (context) => Image.asset(
                            'assets/img/image_placeholder.jpg',
                            width: 0.35.sw,
                            height: 125.w,
                            fit: BoxFit.fitWidth,
                          )))
          : Image.asset(
              'assets/img/image_placeholder.jpg',
              width: double.infinity.w,
              height: 125.w,
              fit: BoxFit.fitWidth,
            ),
      Positioned(
        top: 8.w,
        right: 8.w,
        left: 8.w,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            createdOn != null && checkIsRecentlyAdded(createdOn!)
                ? Container(
                    padding: EdgeInsets.all(4).r,
                    decoration: BoxDecoration(
                      color: AppColors.negativeLight,
                      borderRadius: BorderRadius.circular(6).r,
                    ),
                    child: Text(AppLocalizations.of(context)!.mSearchNew,
                        style: Theme.of(context).textTheme.labelSmall))
                : SizedBox(),
            creatorIcon != ''
                ? InkWell(
                    onTap: () {},
                    child: Container(
                        margin: EdgeInsets.all(8).r,
                        decoration: BoxDecoration(
                          color: AppColors.appBarBackground,
                          borderRadius:
                              BorderRadius.all(const Radius.circular(4.0)).r,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.grey08,
                              blurRadius: 3.r,
                              spreadRadius: 0.r,
                              offset: Offset(
                                3,
                                3,
                              ),
                            ),
                          ],
                        ),
                        height: 48.w,
                        width: 48.w,
                        child: Image.network(
                          creatorIcon,
                          height: 48.w,
                          width: 48.w,
                          fit: BoxFit.cover,
                          cacheWidth: 24,
                          cacheHeight: 24,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset(
                            'assets/img/igot_creator_icon.png',
                            height: 48.w,
                            width: 48.w,
                          ),
                        )))
                : SizedBox()
          ],
        ),
      ),
      Positioned(
          bottom: 4.w,
          right: 4.w,
          child: Row(
            children: [
              language != null && language!.isNotEmpty
                  ? Padding(
                      padding: EdgeInsets.only(right: 4).r,
                      child: LanguageWidget(language!),
                    )
                  : SizedBox(),
              duration != null
                  ? isExternalCourse || isEvent
                      ? DurationWidget(DateTimeHelper.getTimeFormatInHrs(
                          int.parse(duration!)))
                      : isBlendedProgram &&
                              duration == '0' &&
                              programDuration == null
                          ? Center()
                          : programDuration != null &&
                                  programDuration!.isNotEmpty
                              ? DurationWidget(programDuration == "1"
                                  ? '${programDuration} day'
                                  : '${programDuration} days')
                              : DurationWidget(isFeatured
                                  ? ('LEARNING HOURS: \t \t' +
                                      DateTimeHelper.getTimeFormat(duration))
                                  : DateTimeHelper.getTimeFormat(duration))
                  : Text(''),
            ],
          )),
      isCourseCompleted
          ? SizedBox()
          : Positioned(
              top: 0,
              left: 0,
              child: endDate != null
                  ? ShowDateWidget(endDate: endDate!)
                  : Text(''),
            ),

      /// Enable the block for APAR tag - start
      if (isApar ?? false)
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
                        .r))),

      /// Enable the block for APAR tag - end
    ]));
  }

  String fetchImageUrl() {
    return redirectUrl != null || isExternalCourse
        ? appIcon
        : Helper.convertImageUrl(appIcon, pointToProd: pointToProd);
  }

  bool checkIsRecentlyAdded(String lastUpdatedOn) {
    int difference =
        DateTime.now().difference(DateTime.parse(lastUpdatedOn)).inDays;
    return difference <= SearchConstants.courseFreshnessLimit;
  }
}
