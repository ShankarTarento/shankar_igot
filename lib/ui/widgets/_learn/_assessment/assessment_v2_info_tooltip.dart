import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/ui/widgets/tooltip_widget.dart';

import '../../../../constants/index.dart';

class AssessmentV2InfoToolTip extends StatelessWidget {
  final String? sectionInstruction;
  AssessmentV2InfoToolTip({Key? key, this.sectionInstruction})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          AppLocalizations.of(context)!.mStaticQuestions,
          style: GoogleFonts.lato(
              fontWeight: FontWeight.w700,
              fontSize: 12.sp,
              color: AppColors.greys87),
        ),
        sectionInstruction != null && sectionInstruction != ''
            ? TooltipWidget(
                message: sectionInstruction!,
                iconColor: AppColors.greys60,
                iconSize: 14,
                textColor: AppColors.greys87,
                isBgColorRequired: false,
              )
            : Center(),
      ],
    );
  }
}
