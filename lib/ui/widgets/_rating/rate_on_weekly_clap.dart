import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/widgets/_buttons/animated_container.dart';

class ShowInAppRateOnWeeklyClap extends StatelessWidget {
  const ShowInAppRateOnWeeklyClap({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0).r),
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
              color: AppColors.seaShell,
              borderRadius: BorderRadius.circular(16).r),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(20, 30, 20, 24).r,
                child: Column(
                  children: [
                    SvgPicture.asset(
                      'assets/img/clap_icon.svg',
                      width: 50.w,
                      height: 50.w,
                    ),
                    SizedBox(
                      height: 16.w,
                    ),
                    Text(
                      'Congratulations on your weekly clap!',
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontFamily: GoogleFonts.montserrat().fontFamily,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500),
                    )
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: AppColors.appBarBackground,
                    borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16))
                        .r),
                padding: EdgeInsets.fromLTRB(20, 24, 20, 10).r,
                child: Column(
                  children: [
                    Text(
                      'Enjoying the iGOT experience? Rate us!',
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontFamily: GoogleFonts.montserrat().fontFamily,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 12.w,
                    ),
                    SizedBox(
                      width: double.infinity.w,
                      child: ButtonClickEffect(
                        child: Text('Rate now'),
                        onTap: () {},
                      ),
                    ),
                    SizedBox(
                      height: 2.w,
                    ),
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Maybe later',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(fontWeight: FontWeight.w500),
                        ))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
