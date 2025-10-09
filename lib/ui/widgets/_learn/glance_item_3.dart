import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:karmayogi_mobile/ui/widgets/tooltip_widget.dart';
import './../../../constants/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GlanceItem3 extends StatefulWidget {
  final String icon;
  final String text;
  final int status;
  final bool isEnrolled;
  final bool showContent = true;
  final String duration, mimeType;
  final bool isFeaturedCourse;
  final currentProgress;
  final bool showProgress, isExpanded, isLastAccessed;
  final String maxQuestions;
  final bool isLocked;
  final bool isL2Assessment;
  final bool? isMandatory;

  const GlanceItem3(
      {Key? key,
      required this.icon,
      required this.text,
      required this.status,
      required this.duration,
      this.isFeaturedCourse = false,
      this.currentProgress,
      this.showProgress = false,
      this.isExpanded = false,
      this.isLastAccessed = false,
      this.isEnrolled = false,
      this.maxQuestions = '',
      this.mimeType = '',
      required this.isLocked,
      this.isL2Assessment = false,
      this.isMandatory})
      : super(key: key);

  @override
  _GlanceItem3State createState() => _GlanceItem3State();
}

class _GlanceItem3State extends State<GlanceItem3> {
// class GlanceItem3 extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10).r,
      color: widget.isLastAccessed && widget.showProgress
          ? AppColors.darkBlue
          : widget.isExpanded
              ? AppColors.whiteGradientOne
              : AppColors.appBarBackground,
      // height: 74,
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          (!widget.isFeaturedCourse && widget.showProgress)
              ? Padding(
                  padding: const EdgeInsets.only(left: 5, top: 10).w,
                  child: (widget.status == 2)
                      ? Icon(
                          widget.isLastAccessed && widget.showProgress
                              ? Icons.check_circle_outline
                              : Icons.check_circle,
                          size: 22.sp,
                          color: widget.isLastAccessed && widget.showProgress
                              ? AppColors.appBarBackground
                              : AppColors.darkBlue)
                      : Padding(
                          padding: const EdgeInsets.only(top: 4, right: 0).w,
                          child: widget.showProgress
                              ? Container(
                                  height: 20.w,
                                  width: 20.w,
                                  child: CircularProgressIndicator(
                                      backgroundColor: AppColors.grey16,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        ((widget.currentProgress != null &&
                                                    widget.currentProgress !=
                                                        '') &&
                                                double.parse(widget
                                                        .currentProgress
                                                        .toString()) <
                                                    1)
                                            ? AppColors.primaryOne
                                            : widget.isLastAccessed &&
                                                    widget.showProgress
                                                ? AppColors.appBarBackground
                                                : AppColors.darkBlue,
                                      ),
                                      strokeWidth: 3.w,
                                      value: (widget.currentProgress != null &&
                                              widget.currentProgress != '')
                                          ? double.parse(
                                              widget.currentProgress.toString())
                                          : 0.0),
                                )
                              : Center(),
                        ),
                )
              : Center(),
          widget.isL2Assessment && widget.isEnrolled
              ? Padding(
                  padding: const EdgeInsets.only(left: 5, top: 10).w,
                  child: Icon(widget.isLocked ? Icons.lock : Icons.lock_open,
                      color: widget.isLocked
                          ? AppColors.orangeTourText
                          : AppColors.positiveLight,
                      size: 20.sp),
                )
              : Center(),
          Container(
            width: 0.75.sw,
            padding: const EdgeInsets.only(left: 8, top: 6).w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.isL2Assessment && widget.isEnrolled
                    ? Container(
                        padding: EdgeInsets.all(8).r,
                        color: widget.isLocked
                            ? AppColors.seaShell
                            : AppColors.positiveLight.withValues(alpha: 0.1),
                        child: Text(
                            widget.isLocked
                                ? AppLocalizations.of(context)!.mContentLocked
                                : AppLocalizations.of(context)!
                                    .mContentUnLocked,
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium!
                                .copyWith(
                                    color: widget.isLocked
                                        ? AppColors.mandatoryRed
                                        : AppColors.positiveLight)))
                    : SizedBox(),
                Text(
                  widget.text,
                  style: GoogleFonts.lato(
                      height: 1.5.w,
                      decoration: TextDecoration.none,
                      color: widget.isLastAccessed && widget.showProgress
                          ? AppColors.appBarBackground
                          : AppColors.greys87,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, top: 4).r,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SvgPicture.asset(
                        widget.icon,
                        colorFilter: ColorFilter.mode(
                            widget.isLastAccessed && widget.showProgress
                                ? AppColors.appBarBackground
                                : widget.icon == "assets/img/audio.svg"
                                    ? AppColors.grey40
                                    : AppColors.greys87,
                            BlendMode.srcIn),
                        height: 16.w,
                        width: 16.w,
                        // alignment: Alignment.topLeft,
                      ),
                      (!(widget.mimeType == EMimeTypes.assessment ||
                                  widget.mimeType ==
                                      EMimeTypes.newAssessment) ||
                              (widget.maxQuestions == '' &&
                                  widget.mimeType == EMimeTypes.assessment))
                          ? Padding(
                              padding: const EdgeInsets.only(left: 4).r,
                              child: Text(
                                widget.duration,
                                style: GoogleFonts.lato(
                                    height: 1.5.w,
                                    decoration: TextDecoration.none,
                                    color: widget.isLastAccessed &&
                                            widget.showProgress
                                        ? AppColors.appBarBackground
                                        : AppColors.greys60,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w400),
                              ),
                            )
                          : Center(),
                      if (widget.maxQuestions != '' &&
                          (widget.mimeType == EMimeTypes.assessment ||
                              widget.mimeType == EMimeTypes.newAssessment))
                        Padding(
                          padding: const EdgeInsets.only(left: 8).r,
                          child: Text(
                            '${widget.maxQuestions} ${(widget.maxQuestions == 1) ? AppLocalizations.of(context)!.mStaticQuestion.toString().toLowerCase() : AppLocalizations.of(context)!.mStaticQuestions.toString().toLowerCase()}',
                            style: GoogleFonts.lato(
                                height: 1.5.w,
                                decoration: TextDecoration.none,
                                color:
                                    widget.isLastAccessed && widget.showProgress
                                        ? AppColors.appBarBackground
                                        : AppColors.greys60,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400),
                          ),
                        )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
          if (widget.isMandatory != null)
            Padding(
              padding: const EdgeInsets.only(left: 5, top: 10).w,
              child: TooltipWidget(
                iconSize: 18,
                message: (widget.isMandatory??false) ? AppLocalizations.of(context)!.mBlendedPreEnrollmentMandatoryResourceMsg : AppLocalizations.of(context)!.mBlendedPreEnrollmentOptionalResourceMsg,
                icon: Icons.info_outline_rounded,
                iconColor: widget.isLastAccessed
                    ? AppColors.appBarBackground
                    : AppColors.darkBlue,
              ),
            )
        ],
      ),
    );
  }
}
