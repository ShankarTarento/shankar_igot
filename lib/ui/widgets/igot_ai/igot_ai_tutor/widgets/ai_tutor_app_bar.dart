import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/models/ai_tutor_type.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/igot_ai_tutor/widgets/ai_tutor_drop_down.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/ai_widgets/ai_bot_icon.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// ignore: must_be_immutable
class AiTutorAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function(AiTutorType) onTypeSelected;
  AiTutorType selectedType;
  final List<AiTutorType> aiTutorTypes;
  AiTutorAppBar(
      {super.key,
      required this.onTypeSelected,
      required this.selectedType,
      required this.aiTutorTypes});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: preferredSize.height,
      child: Column(
        children: [
          Container(
            height: 56.w,
            padding: const EdgeInsets.symmetric(horizontal: 16).r,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.aiAppBarGradient,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const AiBotIcon(showCheckIcon: true),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppLocalizations.of(context)!.migotAiTutor,
                        style: GoogleFonts.lato(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.appBarBackground,
                        )),
                    SizedBox(height: 4.w),
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
                const Spacer(),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close,
                      color: AppColors.appBarBackground),
                )
              ],
            ),
          ),
          Container(
            color: AppColors.appBarBackground,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4).r,
            child: AiTutorDropdown(
              aiTutorTypes: aiTutorTypes,
              onTypeSelected: onTypeSelected,
              selectedType: selectedType,
            ),
          )
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(120);
}
