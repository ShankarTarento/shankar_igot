import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../constants/index.dart';
import '../index.dart';

class SeparatorWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80.h,
      child: Stack(
        children: [
          Container(
            height: 50,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: GradientLine(),
          ),
          Positioned(
              top: 2,
              right: 50,
              left: 50,
              child: Center(
                  child: Container(
                      height: 30.w,
                      width: 30.w,
                      decoration: BoxDecoration(
                          color: AppColors.black,
                          borderRadius: BorderRadius.circular(64)),
                      child: Center(
                        child: Text('OR',
                            style: GoogleFonts.lato(
                                color: AppColors.appBarBackground,
                                fontSize: 14)),
                      ))))
        ],
      ),
    );
  }
}
