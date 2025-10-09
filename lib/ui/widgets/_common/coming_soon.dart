import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import './../../../constants/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ComingSoon extends StatelessWidget {
  final bool isBottomBarItem;
  final bool removeGoToWebButton;
  ComingSoon({this.isBottomBarItem = false, this.removeGoToWebButton = false});

  Future<void> _launchURL(url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      // if (await launchUrl(Uri.parse(url))) {
      //   await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      // } else {
      //   throw 'Could not launch $url';
      // }
    } catch (e) {
      throw '$url: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Center(
          child: Column(
            children: [
              Container(
                child: Padding(
                  padding:
                      EdgeInsets.only(top: removeGoToWebButton ? 150 : 72).r,
                  child: SvgPicture.asset(
                    'assets/img/coming-soon-new.svg',
                    alignment: Alignment.center,
                    // width: MediaQuery.of(context).size.width,
                    // height: MediaQuery.of(context).size.height,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 32).r,
                child: Text(
                  AppLocalizations.of(context)!.mCommonComing,
                  style: GoogleFonts.lato(
                    color: AppColors.darkBlue,
                    fontWeight: FontWeight.w500,
                    fontSize: 26.sp,
                  ),
                ),
              ),
              Text(
                AppLocalizations.of(context)!.mCommonSoon,
                style: GoogleFonts.lato(
                  color: AppColors.darkBlue,
                  fontWeight: FontWeight.w500,
                  fontSize: 36.sp,
                ),
              ),
              !removeGoToWebButton
                  ? Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 16).r,
                          child: Text(
                            AppLocalizations.of(context)!
                                .mCommonFeatureAvailableinPortal,
                            style: GoogleFonts.lato(
                              color: AppColors.greys87,
                              fontWeight: FontWeight.w500,
                              fontSize: 16.sp,
                              height: 1.5.w,
                              letterSpacing: 0.25,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 32).r,
                          child: SizedBox(
                            height: 48.w,
                            width: 272.w,
                            child: TextButton(
                              onPressed: () {
                                _launchURL(AppUrl.webAppUrl);
                              },
                              style: TextButton.styleFrom(
                                  backgroundColor: AppColors.scaffoldBackground,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4).r,
                                      side: BorderSide(
                                          color: AppColors.darkBlue))),
                              child: Text(
                                AppLocalizations.of(context)!
                                    .mCommonGoToWebPortal,
                                style: GoogleFonts.lato(
                                    color: AppColors.darkBlue,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14.sp,
                                    letterSpacing: 0.5,
                                    height: 1.5.w),
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  : Center(),
              !isBottomBarItem
                  ? Padding(
                      padding:
                          EdgeInsets.only(top: removeGoToWebButton ? 32 : 16).r,
                      child: SizedBox(
                        height: 48.w,
                        width: 272.w,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.darkBlue,

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4).w,
                            )
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.mStaticGoBack,
                            style: GoogleFonts.lato(
                                color: AppColors.appBarBackground,
                                fontWeight: FontWeight.w700,
                                fontSize: 14.sp,
                                letterSpacing: 0.5,
                                height: 1.5.w),
                          ),
                        ),
                      ),
                    )
                  : Center(),
            ],
          ),
        )
      ],
    );
  }
}
