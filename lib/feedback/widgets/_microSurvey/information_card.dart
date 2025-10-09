import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/index.dart';

class InformationCard extends StatelessWidget {
  final int ?scenarioNumber;
  final IconData ?icon;
  final String information;
  final Color ?iconColor;

  InformationCard(
      this.scenarioNumber, this.icon, this.information, this.iconColor);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, top: 8, right: 24).r,
      child: Container(
        height: 48.w,
        color: AppColors.grey04,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 19).r,
              child: Icon(icon, size: 20.sp, color: iconColor),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 11).r,
              child: Container(
                width: 0.7.sw,
                child: Text(
                  information,
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
