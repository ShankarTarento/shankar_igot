import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../constants/index.dart';

class AutoplayNextResource extends StatelessWidget {
  const AutoplayNextResource({
    Key? key,
    required this.clickedPlayNextResource,
    required this.cancelTimer,
  }) : super(key: key);

  final VoidCallback clickedPlayNextResource;
  final VoidCallback cancelTimer;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: () => clickedPlayNextResource(),
          child: Container(
            padding: EdgeInsets.all(6).r,
            child: Text(
              AppLocalizations.of(context)!.mUpNext,
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    fontSize: 16.sp,
                    letterSpacing: 0.12,
                    fontFamily: GoogleFonts.montserrat().fontFamily,
                  ),
            ),
          ),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            CircularCountDownTimer(
              duration: 30,
              fillColor: AppColors.appBarBackground,
              backgroundColor: AppColors.greys87,
              height: 50.w,
              ringColor: AppColors.greys87,
              width: 50.w,
              onComplete: () => clickedPlayNextResource(),
            ),
            Icon(
              Icons.play_arrow_rounded,
              size: 24.sp,
              color: AppColors.appBarBackground,
            ),
          ],
        ),
        InkWell(
          onTap: () => cancelTimer(),
          child: Container(
            padding: EdgeInsets.all(6).r,
            child: Text(
              AppLocalizations.of(context)!.mStaticCancel,
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    fontSize: 16.sp,
                    letterSpacing: 0.12,
                    fontFamily: GoogleFonts.montserrat().fontFamily,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
