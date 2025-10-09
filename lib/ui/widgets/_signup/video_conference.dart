import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/models/_models/support_section_model.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class VideoConferenceWidget extends StatelessWidget {
  final double? borderRadius;
  final SupportSectionModel? data;
  const VideoConferenceWidget({Key? key, this.borderRadius, this.data})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String email = data?.plsContact ?? supportEmail;

    return Container(
        width: double.infinity.w,
        padding:
            const EdgeInsets.only(top: 30, left: 16, right: 16, bottom: 20).r,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius ?? 0).r,
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppColors.primaryThree,
              AppColors.darkBlue,
              AppColors.blue2
            ],
          ),
        ),
        child: Column(
          children: [
            SvgPicture.asset('assets/img/conference_icon.svg',
                width: 36.0.w,
                height: 36.0.w,
                colorFilter: ColorFilter.mode(AppColors.appBarBackground, BlendMode.srcIn)),
            SizedBox(
              height: 20.w,
            ),
            Text(
              data?.title ??
                  AppLocalizations.of(context)!.mContactVideoConference,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                color: AppColors.appBarBackground,
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: 16.w,
            ),
            Text(
              (data?.date != null && data?.time != null)
                  ? "${data?.date} \n ${data?.time}"
                  : AppLocalizations.of(context)!.mStaticDay +
                      ",\n 9:00 AM to 5:00 PM",
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                color: AppColors.primaryOne,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(
              height: 16.w,
            ),
            GestureDetector(
              onTap: _launchURL,
              child: Container(
                width: 160.w,
                height: 45.w,
                decoration: BoxDecoration(
                    color: AppColors.orangeTourText,
                    border:
                        Border.all(width: 1.w, color: AppColors.primaryBlue),
                    borderRadius: BorderRadius.circular(30).w),
                child: Center(
                  child: Text(
                    data?.button ??
                        AppLocalizations.of(context)!.mContactBtnJoinNow,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                        color: AppColors.appBarBackground,
                        height: 1.5.w,
                        letterSpacing: 0.25,
                        fontSize: 16.0.sp,
                        fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 16.w,
            ),
            Text(
              data?.technicalSupport ??
                  AppLocalizations.of(context)!.mContactHeaderForAnyTech,
              style: GoogleFonts.lato(
                color: AppColors.appBarBackground,
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(
              height: 8.w,
            ),
            Link(
                target: LinkTarget.blank,
                uri: Uri.parse(email),
                builder: (context, followLink) => InkWell(
                      onTap: () => Helper.mailTo(email),
                      child: Text(
                        (email),
                        style: GoogleFonts.lato(
                            color: AppColors.primaryOne,
                            fontWeight: FontWeight.w700,
                            fontSize: 16.sp,
                            letterSpacing: 0.25),
                        maxLines: 2,
                      ),
                    )),
          ],
        ));
  }

  void _launchURL() async => await canLaunchUrl(
          Uri.parse(data?.joinLink ?? EnglishLang.htmlTeamsUriLink))
      .then((value) => value
          ? launchUrl(Uri.parse(data?.joinLink ?? EnglishLang.htmlTeamsUriLink),
              mode: LaunchMode.externalApplication)
          : throw 'Please try after sometime');
}
