import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/ui/widgets/_signup/video_conference.dart';
import 'package:karmayogi_mobile/util/logout.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../constants/_constants/color_constants.dart';

class ContactUs extends StatelessWidget {
  const ContactUs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          toolbarHeight: kToolbarHeight.w,
          foregroundColor: AppColors.greys,
          centerTitle: false,
          leading: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Icon(Icons.arrow_back_ios_sharp, size: 24.sp)),
          title: Text(
            AppLocalizations.of(context)!.mStaticContactUs,
            style: GoogleFonts.montserrat(
              color: AppColors.greys87,
              fontSize: 16.0.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          elevation: 0,
          titleSpacing: 0,
          backgroundColor: AppColors.appBarBackground),
      body: Column(
        children: [VideoConferenceWidget()],
      ),
      bottomSheet: modeProdRelease
          ? SizedBox()
          : BottomAppBar(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: InkWell(
                  onTap: () async {
                    await _onLogoutPressed(context);
                  },
                  child: Container(
                    width: 1.sw,
                    height: 45.w,
                    decoration: BoxDecoration(
                        color: AppColors.appBarBackground,
                        border: Border.all(
                            width: 1.w, color: AppColors.primaryBlue),
                        borderRadius: BorderRadius.circular(12).w),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)!.mSettingSignOut,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                            color: AppColors.primaryBlue,
                            letterSpacing: 0.25,
                            fontSize: 16.0.sp,
                            fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Future _onLogoutPressed(contextMain) {
    return showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8), topRight: Radius.circular(8).r),
          side: BorderSide(
            color: AppColors.grey08,
          ),
        ),
        context: contextMain,
        builder: (context) => Logout(
              contextMain: contextMain,
            ));
  }
}
