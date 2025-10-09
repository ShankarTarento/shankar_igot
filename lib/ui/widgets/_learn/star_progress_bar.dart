import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import './../../../constants/index.dart';

class StarProgressBar extends StatelessWidget {
  final String text;
  final double progress;

  StarProgressBar({required this.text,required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10).r,
      child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Container(
          width: 50.w,
          child: Text(
            text,
            style: GoogleFonts.lato(
                color: AppColors.greys87,
                fontSize: 14.0.sp,
                fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(
          child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: LinearProgressIndicator(
                minHeight: 8.w,
                backgroundColor: AppColors.grey16,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryOne,
                ),
                value: progress,
              )),
        )
      ]),
    );
  }
}
