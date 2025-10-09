import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import './../../../../constants/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomepageAssessmentCompleted extends StatefulWidget {
  HomepageAssessmentCompleted();
  @override
  _HomepageAssessmentCompletedState createState() =>
      _HomepageAssessmentCompletedState();
}

class _HomepageAssessmentCompletedState
    extends State<HomepageAssessmentCompleted> {
  @override
  Widget build(BuildContext context) {
    return Center(
        // padding: const EdgeInsets.only(top: 100),
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.check_circle_outline,
            size: 50.0.w, color: AppColors.positiveLight),
        Container(
          padding: const EdgeInsets.only(top: 20).r,
          child: Text(
            AppLocalizations.of(context)!.mStaticYouGotRight,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Container(
          padding: const EdgeInsets.only(top: 20).r,
          child: Text(
            AppLocalizations.of(context)!.mStaticMorePowerToYou,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontSize: 20.sp,
                ),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(top: 20).r,
          width: 1.sw / 2 - 50.w,
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              backgroundColor: AppColors.customBlue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4).r,
                  side: BorderSide(color: AppColors.grey16))
            ),
            child: Text(
              AppLocalizations.of(context)!.mStaticDone,
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
        )
      ],
    ));
  }
}
