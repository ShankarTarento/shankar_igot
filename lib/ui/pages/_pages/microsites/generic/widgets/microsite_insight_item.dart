import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../../../constants/index.dart';

class MicroSiteInsightItem extends StatelessWidget {
  final double width;
  final double height;
  final String? label;
  final String? value;
  final Widget icon;
  final Color labelColor;
  final Color valueColor;
  final Color iconColor;
  final double? labelTextSize;
  final double? valueTextSize;
  final BoxDecoration? background;
  MicroSiteInsightItem(
      {required this.width,
      required this.height,
      this.label,
      this.value,
      required this.icon,
      required this.labelColor,
      required this.valueColor,
      required this.iconColor,
      this.labelTextSize,
      this.valueTextSize,
      this.background});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(right: 16).w,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16).w,
        width: width,
        decoration: background ??
            BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.tipsBackground,
                  AppColors.verifiedBadgeIconColor
                ],
              ),
              borderRadius: BorderRadius.all(Radius.circular(12.w)),
            ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                icon,
                Padding(
                  padding: const EdgeInsets.only(left: 8).w,
                  child: Text(
                    getFormattedValue(value ?? '0'),
                    style: GoogleFonts.montserrat(
                      color: valueColor,
                      fontWeight: FontWeight.w600,
                      fontSize: valueTextSize ?? 16.sp,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 32).w,
              child: Text(
                label ?? '',
                style: GoogleFonts.lato(
                  color: labelColor,
                  fontWeight: FontWeight.w400,
                  fontSize: labelTextSize ?? 14.sp,
                  height: 1.5.w,
                  letterSpacing: 0.25.w,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ));
  }

  String getFormattedValue(String value) {
    final number = double.parse(value);
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      decimalDigits: 2,
      symbol: '',
    );
    if (number == number.roundToDouble()) {
      return NumberFormat.currency(
        locale: 'en_IN',
        decimalDigits: 0,
        symbol: '',
      ).format(number);
    } else {
      return formatter.format(number);
    }
  }
}
