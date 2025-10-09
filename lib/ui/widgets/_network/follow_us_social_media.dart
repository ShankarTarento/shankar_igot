import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/configurations/social_media.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../constants/_constants/color_constants.dart';

class FollowUsOnSocialMedia extends StatelessWidget {
  const FollowUsOnSocialMedia({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        margin: EdgeInsets.fromLTRB(16, 50, 16, 30).r,
        child: Column(
          children: [
            Text(AppLocalizations.of(context)!.mStaticFollowUs,
                style: GoogleFonts.montserrat(
                    color: AppColors.greys60,
                    fontSize: 16.0.sp,
                    letterSpacing: 0.12,
                    fontWeight: FontWeight.w600)),
            SizedBox(height: 16.w),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40).r,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var socialMediaItems in SocialMedia.items)
                    InkWell(
                      onTap: () async =>
                          await canLaunchUrl(Uri.parse(socialMediaItems.url))
                              .then((value) => value
                                  ? launchUrl(Uri.parse(socialMediaItems.url),
                                      mode: LaunchMode.externalApplication)
                                  : throw 'Please try after sometime'),
                      child: SvgPicture.asset(
                        socialMediaItems.imagePath,
                        width: 32.0.w,
                        height: 32.0.w,
                      ),
                    )
                ],
              ),
            ),
            SizedBox(height: 16.w),
            Text(
              "App Version" + ' ' + APP_VERSION,
              style: GoogleFonts.lato(
                  color: AppColors.greys60,
                  fontWeight: FontWeight.w400,
                  fontSize: 12.sp,
                  letterSpacing: 0.25),
            )
          ],
        ),
      ),
    );
  }
}
