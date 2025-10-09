import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';
import '../../../../../../../models/index.dart';

class OverviewIcons extends StatefulWidget {
  final CourseHierarchyModel course;
  final String? duration;
  final String? cbpDate;
  final Course courseDetails;
  const OverviewIcons(
      {Key? key,
      required this.course,
      required this.courseDetails,
      this.duration,
      this.cbpDate})
      : super(key: key);

  @override
  State<OverviewIcons> createState() => _OverviewIconsState();
}

class _OverviewIconsState extends State<OverviewIcons> {
  @override
  void initState() {
    if (widget.course.children != null) {
      for (int i = 0; i < widget.course.children!.length; i++) {
        if (widget.course.children![i].contentType == 'Course') {
          structure['course'] += 1;
          // structure['module'] += 1;
          countArtifacts(widget.course.children![i]);
        } else if (widget.course.children![i].contentType == 'Collection' ||
            widget.course.children![i].contentType == 'CourseUnit') {
          // structure['learningModule '] += 1;
          structure['module'] += 1;
          countArtifacts(widget.course.children![i]);
        } else {
          switch (widget.course.children![i].mimeType.trim()) {
            case EMimeTypes.mp4:
              structure['video'] += 1;
              break;
            case EMimeTypes.pdf:
              structure['pdf'] += 1;
              break;
            case EMimeTypes.assessment:
              structure['assessment'] += 1;
              break;
            case EMimeTypes.collection:
              structure['module'] += 1;
              break;
            case EMimeTypes.html:
              structure['html'] += 1;
              break;
            case EMimeTypes.mp3:
              structure['audio'] += 1;
              break;
            case EMimeTypes.offline:
              structure['offlineSession'] += 1;
              break;
            case EMimeTypes.externalLink:
              structure['externalLink'] += 1;
              break;
            case EMimeTypes.newAssessment:
              widget.course.children![i].primaryCategory ==
                      PrimaryCategory.practiceAssessment
                  ? structure['practiceTest'] += 1
                  : structure['finalTest'] += 1;
              break;
            default:
              structure['other'] += 1;
              break;
          }
        }
      }
    }
    super.initState();
  }

  void countArtifacts(children) {
    if (children.children != null) {
      for (int i = 0; i < children.children!.length; i++) {
        switch (children.children![i].mimeType) {
          case EMimeTypes.mp4:
            structure['video'] += 1;
            break;
          case EMimeTypes.pdf:
            structure['pdf'] += 1;
            break;
          case EMimeTypes.assessment:
            structure['assessment'] += 1;
            break;
          case EMimeTypes.collection:
            structure['module'] += 1;
            countArtifacts(children.children![i]);
            break;
          case EMimeTypes.html:
            structure['html'] += 1;
            break;
          case EMimeTypes.mp3:
            structure['audio'] += 1;
            break;
          case EMimeTypes.offline:
            structure['offlineSession'] += 1;
            break;
          case EMimeTypes.externalLink:
            structure['externalLink'] += 1;
            break;
          case EMimeTypes.newAssessment:
            children.children[i].primaryCategory ==
                    PrimaryCategory.practiceAssessment
                ? structure['practiceTest'] += 1
                : structure['finalTest'] += 1;
            break;
          default:
            structure['other'] += 1;
            break;
        }
      }
    }
  }

  Map structure = {
    'video': 0,
    'pdf': 0,
    'assessment': 0,
    'Session': 0,
    'module': 0,
    'other': 0,
    'html': 0,
    'course': 0,
    'practiceTest': 0,
    'finalTest': 0,
    'audio': 0,
    'externalLink': 0,
    'offlineSession': 0,
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        height: 55.w,
        child: Row(children: [
          widget.cbpDate != null && widget.cbpDate != ''
              ? cbpEnddateWidget(date: widget.cbpDate!)
              : SizedBox(),
          widget.duration != null &&
                  calculateDuration(duration: widget.duration!) != "0 m"
              ? detailsWidget(
                  icon: Icons.access_time_sharp,
                  title: calculateDuration(duration: widget.duration!))
              : Center(),
          structure['course'] > 0
              ? detailsWidget(
                  imagepath: 'assets/img/course_icon.svg',
                  title: structure['course'].toString() +
                      (structure['course'] == 1 ? ' Course' : ' Courses'))
              : Center(),
          structure['module'] > 0
              ? detailsWidget(
                  imagepath: 'assets/img/icons-file-types-module.svg',
                  title: structure['module'].toString() +
                      (structure['module'] == 1 ? ' Module' : ' Modules'))
              : Center(),
          structure['offlineSession'] > 0
              ? detailsWidget(
                  imagepath: 'assets/img/icons-file-types-module.svg',
                  title: structure['offlineSession'].toString() +
                      (structure['offlineSession'] == 1
                          ? ' Session'
                          : ' Sessions'))
              : Center(),
          structure['video'] > 0
              ? detailsWidget(
                  imagepath: 'assets/img/icons-av-play.svg',
                  title: structure['video'].toString() +
                      (structure['video'] == 1 ? ' Video' : ' Videos'))
              : Center(),
          structure['pdf'] > 0
              ? detailsWidget(
                  imagepath: 'assets/img/icons-file-types-pdf-alternate.svg',
                  title: structure['pdf'].toString() +
                      (structure['pdf'] == 1 ? ' PDF' : ' PDFs'))
              : Center(),
          structure['audio'] > 0
              ? detailsWidget(
                  imagepath: 'assets/img/audio.svg',
                  title: structure['audio'].toString() +
                      (structure['audio'] == 1 ? ' Audio' : ' Audios'))
              : Center(),
          structure['assessment'] > 0
              ? detailsWidget(
                  imagepath: 'assets/img/assessment_icon.svg',
                  title: structure['assessment'].toString() +
                      (structure['assessment'] == 1
                          ? ' Assessment'
                          : ' Assessments'))
              : Center(),
          structure['externalLink'] > 0
              ? detailsWidget(
                  imagepath: 'assets/img/web_page.svg',
                  title: structure['externalLink'].toString() +
                      (structure['externalLink'] == 1
                          ? ' Web page'
                          : ' Web pages'))
              : Center(),
          structure['html'] > 0
              ? detailsWidget(
                  imagepath: 'assets/img/link.svg',
                  title: structure['html'].toString() +
                      (structure['html'] == 1
                          ? ' Interactive Content'
                          : ' Interactive Contents'))
              : Center(),
          structure['practiceTest'] > 0
              ? detailsWidget(
                  imagepath: 'assets/img/assessment_icon.svg',
                  title: structure['practiceTest'].toString() +
                      (structure['practiceTest'] == 1
                          ? ' Practice test'
                          : ' Practice tests'))
              : Center(),
          structure['finalTest'] > 0
              ? detailsWidget(
                  imagepath: 'assets/img/assessment_icon.svg',
                  title: structure['finalTest'].toString() +
                      (structure['finalTest'] == 1
                          ? ' Final test'
                          : ' Final tests'))
              : Center(),
          widget.courseDetails.learningMode != null
              ? detailsWidget(
                  imagepath: 'assets/img/instructor_led.svg',
                  title: widget.courseDetails.learningMode!)
              : Center(),
          if (widget.courseDetails.languageMap.languages.isNotEmpty)
            detailsWidget(
              icon: Icons.translate,
              title: (widget.courseDetails.languageMap.languages.entries.length)
                      .toString() +
                  ' ' +
                  AppLocalizations.of(context)!.mAboutLanguagesAvailable,
            ),
          widget.course.license != null
              ? detailsWidget(
                  icon: Icons.key,
                  title: widget.course.license!,
                )
              : Center(),
          detailsWidget(
            imagepath: 'assets/img/rupee.svg',
            title: "Free",
          )
        ]),
      ),
    );
  }

  Widget detailsWidget(
      {required String title, String? imagepath, IconData? icon}) {
    return Container(
      height: 60.w,
      width: 68.w,
      margin: const EdgeInsets.only(right: 16.0).r,
      child: Column(
        children: [
          if (imagepath != null)
            SvgPicture.asset(
              imagepath,
              alignment: Alignment.center,
              height: 20.w,
              width: 20.w,
              colorFilter: ColorFilter.mode(Color(0xff1B4CA1), BlendMode.srcIn),
              fit: BoxFit.cover,
            ),
          if (icon != null)
            Icon(
              icon,
              color: AppColors.darkBlue,
              size: 20.sp,
            ),
          SizedBox(
            height: 2.w,
          ),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.lato(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }

  String calculateDuration({required duration}) {
    int durationInMinutes = int.parse(duration) ~/ 60.toInt();

    int hours = (durationInMinutes ~/ 60).toInt();
    int remainingMinutes = durationInMinutes % 60;
    if (hours > 0) {
      if (remainingMinutes > 0) {
        return '$hours h $remainingMinutes m';
      } else {
        return '$hours h';
      }
    } else {
      return '$remainingMinutes m';
    }
  }

  Widget cbpEnddateWidget({required String date}) {
    int dateDiff = getTimeDiff(date);
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 0, 20, 0).r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_month_rounded,
            color: AppColors.darkBlue,
            size: 20.sp,
          ),
          Container(
            margin: EdgeInsets.only(top: 5).r,
            padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4).r,
            decoration: BoxDecoration(
                color: dateDiff < 0
                    ? AppColors.negativeLight
                    : dateDiff < 30
                        ? AppColors.verifiedBadgeIconColor
                        : AppColors.positiveLight,
                borderRadius: BorderRadius.all(const Radius.circular(4.0).r)),
            child: Text(
              DateTimeHelper.getDateTimeInFormat(widget.cbpDate!,
                  desiredDateFormat: IntentType.dateFormat2),
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    fontSize: 12.sp,
                    color: AppColors.appBarBackground,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  int getTimeDiff(String date1) {
    return DateTime.parse(
            DateFormat('yyyy-MM-dd').format(DateTime.parse(date1)))
        .difference(
            DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now())))
        .inDays;
  }
}
