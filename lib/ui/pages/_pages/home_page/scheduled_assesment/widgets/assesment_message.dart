import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AssesmentMessage extends StatefulWidget {
  final String startdate;
  const AssesmentMessage({Key? key, required this.startdate}) : super(key: key);

  @override
  State<AssesmentMessage> createState() => _AssesmentMessageState();
}

class _AssesmentMessageState extends State<AssesmentMessage> {
  Duration? _remainingTime;
  @override
  void initState() {
    print(widget.startdate);
    super.initState();
    _remainingTime = DateTime.parse(widget.startdate.replaceAll('Z', ''))
        .difference(DateTime.now());
    _startTimer();
  }

  void _startTimer() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _remainingTime = DateTime.parse(widget.startdate.replaceAll('Z', ''))
            .difference(DateTime.now());

        if ((_remainingTime?.inSeconds ?? 0) <= 0) {
          timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 8, right: 8, top: 5, bottom: 5).r,
      decoration: BoxDecoration(
        color: AppColors.appBarBackground,
        border: Border.all(color: AppColors.grey16),
        borderRadius: BorderRadius.circular(20).r,
      ),
      child: Text(
        (_remainingTime?.inSeconds ?? 0) <= 0
            ? AppLocalizations.of(context)!.mAssesmentEndsIn
            : AppLocalizations.of(context)!.mAssesmentStartsIn,
        style: GoogleFonts.lato(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.greys87),
      ),
    );
  }
}
