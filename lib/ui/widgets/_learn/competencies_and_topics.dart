import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/models/index.dart';

import '../../../constants/_constants/color_constants.dart';

class CompetenciesAndTopicsCard extends StatelessWidget {
  final CourseTopics? courseTopics;
  final String name;
  final int count;
  final Color cardColor;
  final bool isTopic;

  CompetenciesAndTopicsCard(
      {this.name = '',
      this.count = 0,
      required this.cardColor,
      this.courseTopics,
      this.isTopic = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6).r,
      child: Container(
        height: 150.w,
        width: 0.45.sw,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(const Radius.circular(4.0)).r,
          color: cardColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 16, bottom: 4).r,
              child: Text(
                isTopic ? courseTopics?.name??'' : name,
                maxLines: 2,
                style: GoogleFonts.lato(
                    color: AppColors.white70,
                    fontSize: 14.0.sp,
                    fontWeight: FontWeight.w700),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16).r,
              child: Text(
                isTopic
                    ? courseTopics!.noOfHoursConsumed.toString() +
                        ' hours in last week'
                    : count.toString() + ' hours in last week',
                style: GoogleFonts.lato(
                    color: AppColors.white70,
                    fontSize: 12.0.sp,
                    fontWeight: FontWeight.w400),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
