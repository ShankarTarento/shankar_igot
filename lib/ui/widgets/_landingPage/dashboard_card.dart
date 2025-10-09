import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../constants/_constants/color_constants.dart';

class DashboardCard extends StatelessWidget {
  final String count;
  final String text;
  final String chart;
  final parentContext;
  const DashboardCard(
      {Key? key,required this.chart,required this.text,required this.count, this.parentContext})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 12, 4, 8).r,
      height: MediaQuery.of(parentContext).orientation == Orientation.portrait
          ? 0.2.sh
          : 0.2.sw,
      width: 0.4125.sw,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(
                      8.0) //                 <--- border radius here
                  )
              .r,
          border: Border.all(color: AppColors.grey08)),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$count',
              style: GoogleFonts.montserrat(
                  color: AppColors.orangeBackground,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.22.w),
            ),
            SizedBox(
              height: 4.w,
            ),
            Text(
              '$text',
              style: GoogleFonts.montserrat(
                  color: AppColors.secondaryBlack,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  height: 1.22.w),
            ),
            Container(
              alignment: Alignment.topLeft,
              width: double.infinity.w,
              padding: EdgeInsets.only(top: 8).r,
              child: Image.asset(
                '$chart',
                width:
                    MediaQuery.of(context).orientation == Orientation.portrait
                        ? 0.35.sw
                        : 0.3.sw,
                fit: BoxFit.fitWidth,
              ),
            )
          ],
        ),
      ),
    );
  }
}
