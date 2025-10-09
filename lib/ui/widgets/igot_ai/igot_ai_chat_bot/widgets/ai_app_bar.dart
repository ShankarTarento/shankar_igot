import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/ai_widgets/ai_bot_icon.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AiAppBar extends StatelessWidget {
  const AiAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      pinned: true,
      expandedHeight: 75.w,
      flexibleSpace: Container(
        height: 75.w,
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: AppColors.aiAppBarGradient),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const AiBotIcon(
                  showCheckIcon: true,
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppLocalizations.of(context)!.mIgotAi,
                        style: GoogleFonts.lato(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.appBarBackground,
                        )),
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      AppLocalizations.of(context)!.mAiIntro,
                      style: GoogleFonts.lato(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.appBarBackground,
                      ),
                    )
                  ],
                ),
                Spacer(),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close,
                    color: AppColors.appBarBackground,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
