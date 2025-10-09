import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../constants/index.dart';

class TocPlayerInNewScreen extends StatelessWidget {
  final Widget player;
  final bool isYoutubeContent, isAssessment, isSurvey, isLocked;
  final String resourcename;
  TocPlayerInNewScreen(
      {Key? key,
      required this.player,
      required this.resourcename,
      this.isYoutubeContent = false,
      this.isAssessment = false,
      this.isSurvey = false,
      this.isLocked = false})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppLocalizations.of(context)!.mOpenresource(isYoutubeContent
              ? 'Youtube'
              : isAssessment
                  ? 'Assessment'
                  : isSurvey
                      ? 'Survey'
                      : 'Scorm'),
          style: GoogleFonts.lato(
              color: AppColors.appBarBackground,
              fontWeight: FontWeight.w700,
              fontSize: 14.sp,
              letterSpacing: 0.25),
        ),
        SizedBox(
          height: 16.w,
        ),
        InkWell(
          onTap: isAssessment && isLocked
              ? null
              : () {
                  isYoutubeContent || isAssessment
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => player),
                        )
                      : Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PopScope(
                                    canPop: false,
                                    onPopInvokedWithResult:
                                        (didPop, result) async {
                                      if (didPop) {
                                        return;
                                      }
                                      await setOrientationAndPop(context);
                                    },
                                    child: Scaffold(
                                      backgroundColor: AppColors.greys,
                                      body: Scaffold(
                                        appBar: AppBar(
                                          backgroundColor: AppColors.greys,
                                          elevation: 0,
                                          titleSpacing: 0,
                                          leading: BackButton(
                                            color: AppColors.white70,
                                            onPressed: () async {
                                              await setOrientationAndPop(
                                                  context);
                                            },
                                          ),
                                          title: Row(children: [
                                            Padding(
                                                padding: const EdgeInsets.only(
                                                        left: 10)
                                                    .r,
                                                child: Text(
                                                  AppLocalizations.of(context)!
                                                      .mBack,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.lato(
                                                    color: AppColors.white70,
                                                    fontSize: 12.0.sp,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ))
                                          ]),
                                        ),
                                        body: Center(
                                            child:
                                                player), // Your current screen's content
                                      ),
                                    ),
                                  )),
                        );
                },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6).r,
            decoration: BoxDecoration(
                color: AppColors.orangeTourText,
                borderRadius: BorderRadius.circular(63).r),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                isYoutubeContent
                    ? SvgPicture.asset(
                        'assets/img/link.svg',
                        height: 24.w,
                        width: 24.w,
                        colorFilter: ColorFilter.mode(
                            AppColors.greys87, BlendMode.srcIn),
                      )
                    : isAssessment
                        ? SvgPicture.asset(
                            'assets/img/assessment_icon.svg',
                            height: 24.w,
                            width: 24.w,
                            colorFilter: ColorFilter.mode(
                                AppColors.greys87, BlendMode.srcIn),
                          )
                        : SvgPicture.asset(
                            'assets/img/resource.svg',
                            height: 24,
                            width: 24,
                            colorFilter: ColorFilter.mode(
                                AppColors.greys87, BlendMode.srcIn),
                          ),
                SizedBox(width: 6.w),
                Text(
                  AppLocalizations.of(context)!.mStaticOpen,
                  style: GoogleFonts.lato(
                      color: AppColors.deepBlue,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                      letterSpacing: 0.25),
                )
              ],
            ),
          ),
        ),
      ],
    ));
  }

  bool checkIsScorm() {
    return (!isYoutubeContent && !isAssessment && !isSurvey);
  }

  Future<void> setOrientationAndPop(context) async {
    if (checkIsScorm()) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
    Navigator.of(context).pop();
  }
}
