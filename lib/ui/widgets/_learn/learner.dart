import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import './../../../constants/index.dart';
import './../../../util/helper.dart';

class Learner extends StatelessWidget {
  final String name;
  final String? designation;

  Learner({required this.name, this.designation});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.appBarBackground,
      margin: EdgeInsets.only(bottom: 5.0).r,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom:
                    BorderSide(color: AppColors.lightBackground, width: 2.0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(15.0).r,
                  child: Container(
                    height: 48.w,
                    width: 48.w,
                    decoration: BoxDecoration(
                      color: AppColors.networkBg[
                          Random().nextInt(AppColors.networkBg.length)],
                      borderRadius:
                          BorderRadius.all(const Radius.circular(4.0)).r,
                    ),
                    child: Center(
                      child: Text(Helper.getInitialsNew(name),
                          style: GoogleFonts.lato(
                              color: AppColors.appBarBackground)),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                        Container(
                          width: 0.75.sw,
                          child: Padding(
                            padding: EdgeInsets.only(top: 10.0).r,
                            child: Text(
                              designation != null ? designation! : '',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(
                                    fontSize: 14.0.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
