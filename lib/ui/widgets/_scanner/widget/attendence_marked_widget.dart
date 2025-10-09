import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ShowMarkedAttendenceWidget extends StatelessWidget {
  final String dateAndTime;
  final String message;

  ShowMarkedAttendenceWidget(
      {Key? key, required this.dateAndTime, required this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SvgPicture.asset(
              'assets/img/approved.svg',
              fit: BoxFit.fill,
            ),
            SizedBox(
              height: 12.w,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0).r,
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    letterSpacing: 0.25.r, fontWeight: FontWeight.w700),
              ),
            ),
            SizedBox(
              height: 16.w,
            ),
            Text(dateAndTime),
            SizedBox(
              height: 16.w,
            ),
            ElevatedButton(
              child: Text(AppLocalizations.of(context)!.mCommonClose),
              onPressed: () => Navigator.of(context).pop(true),
            )
          ],
        ),
      ),
    );
  }
}
