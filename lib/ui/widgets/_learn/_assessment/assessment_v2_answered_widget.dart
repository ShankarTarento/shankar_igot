import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../constants/index.dart';
import '../../../../feedback/constants.dart';

class AssessmentV2AnsweredStatusWidget extends StatelessWidget {
  final String value;
  final String label;
  AssessmentV2AnsweredStatusWidget({required this.value,required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: Text(
              value,
              style: GoogleFonts.lato(
                color: AppColors.darkBlue,
                fontWeight: FontWeight.w600,
                fontSize: 16.0,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: Text(
              label,
              style: GoogleFonts.lato(
                color: FeedbackColors.black60,
                fontWeight: FontWeight.w400,
                fontSize: 12.0,
              ),
            ),
          )
        ],
      ),
    );
  }
}
