import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AiWelcomeText extends StatelessWidget {
  final String name;
  const AiWelcomeText({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 0.7.sw,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 0.3.sh),
            Text(
              AppLocalizations.of(context)!.mCommonHey + " $name",
              style: GoogleFonts.lato(
                fontSize: 24.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.mAiChatBotWelcomeText,
              style: GoogleFonts.lato(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
