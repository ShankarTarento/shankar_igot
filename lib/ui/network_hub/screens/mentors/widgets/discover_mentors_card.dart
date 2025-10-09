import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:karmayogi_mobile/util/in_app_webview_page.dart';

class DiscoverMentorsCard extends StatelessWidget {
  const DiscoverMentorsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.w),
        image: DecorationImage(
          image: AssetImage('assets/img/discover_mentor_background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0.r),
        child: Row(
          children: [
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.mDiscoverMentorMessage,
                style: GoogleFonts.lato(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 4.w),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  FadeRoute(
                      page: InAppWebViewPage(
                          parentContext: context,
                          url: ApiUrl.baseUrl +
                              "/mentorship/tabs/mentor-directory")),
                );
              },
              child: Container(
                padding: EdgeInsets.all(2).r,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Colors.purpleAccent,
                    Colors.blueAccent,
                  ]),
                  borderRadius: BorderRadius.circular(50.w),
                ),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.w),
                  decoration: BoxDecoration(
                    color: Color(0xff1B2133),
                    borderRadius: BorderRadius.circular(50.w),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.mExploreDiscoverMentors,
                    style: GoogleFonts.lato(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
