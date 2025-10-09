import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../../constants/_constants/color_constants.dart';

class CourseTypeButton extends StatelessWidget {
  const CourseTypeButton({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 16,
      width: 50,
      padding: EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: title.toLowerCase() == "online"
            ? AppColors.positiveLight
            : AppColors.greys60,
      ),
      child: Center(
        child: Text(
          title,
          style: GoogleFonts.lato(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: AppColors.appBarBackground,
          ),
        ),
      ),
    );
  }
}
