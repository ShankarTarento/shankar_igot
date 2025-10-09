import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import './../../../constants/index.dart';

class OutlineButtonLearn extends StatelessWidget {
  final String name;
  final String url;

  OutlineButtonLearn({required this.name, this.url = ''});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.w,
      child: ButtonTheme(
        child: OutlinedButton(
          onPressed: () {
            if (this.url != '') {
              Navigator.pushNamed(context, this.url);
            }
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(width: 1, color: AppColors.primaryThree),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4).r,
            )
          ),
          child: Text(
            name,
            style: GoogleFonts.lato(
                color: AppColors.primaryThree,
                fontSize: 14.sp,
                fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
