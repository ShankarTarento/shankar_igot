import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/util/helper.dart';

class EventTime extends StatelessWidget {
  final String eventTime;
  final String eventDate;
  final double fontSize;
  const EventTime(
      {super.key,
      this.fontSize = 12,
      required this.eventDate,
      required this.eventTime});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.calendar_month_sharp,
          color: AppColors.greys60,
          size: 24.sp,
        ),
        SizedBox(
          width: 4.w,
        ),
        Text(
          Helper.formatEventDateTime(eventDate, eventTime),
          // "Fri, Jan 24 6:00 pm ",
          style: GoogleFonts.lato(
            color: AppColors.greys60,
            fontSize: fontSize.sp,
            fontWeight: FontWeight.w400,
          ),
        )
      ],
    );
  }
}
