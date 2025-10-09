import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import './../../../constants/index.dart';

class ActionLabel extends StatelessWidget {
  final IconData icon;
  final String text;

  ActionLabel({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10).r,
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 15).r,
      decoration: BoxDecoration(
        color: AppColors.appBarBackground,
        borderRadius: BorderRadius.all(const Radius.circular(4.0)).r,
        border: Border.all(color: AppColors.darkBlue),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.darkBlue,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8).r,
            child: Text(
              text,
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    fontWeight: FontWeight.w500,
                    fontFamily: GoogleFonts.montserrat().fontFamily,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
