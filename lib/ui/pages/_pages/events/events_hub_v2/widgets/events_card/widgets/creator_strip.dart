import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/widgets/custom_image_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CreatorStrip extends StatelessWidget {
  final String? creatorIconUrl;
  final String creatorName;
  final double fontSize;

  const CreatorStrip(
      {super.key,
      this.creatorIconUrl,
      required this.creatorName,
      this.fontSize = 12});

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          creatorIconUrl != null
              ? Container(
                  decoration: BoxDecoration(
                      color: AppColors.appBarBackground,
                      border: Border.all(color: AppColors.grey16, width: 1),
                      borderRadius:
                          BorderRadius.all(const Radius.circular(4.0)).r),
                  child: Container(
                      height: 16.w,
                      width: 17.w,
                      margin: EdgeInsets.all(3).r,
                      child: ImageWidget(
                        imageUrl: creatorIconUrl!,
                      )),
                )
              : Container(
                  decoration: BoxDecoration(
                      color: AppColors.appBarBackground,
                      border: Border.all(color: AppColors.grey16, width: 1),
                      borderRadius:
                          BorderRadius.all(const Radius.circular(4.0)).r),
                  child: Container(
                    height: 16.w,
                    width: 17.w,
                    margin: EdgeInsets.all(3).r,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/img/igot_creator_icon.png'),
                      ),
                    ),
                  ),
                ),
          SizedBox(
            width: 4.w,
          ),
          Text(
            AppLocalizations.of(context)!.mCommonBy + " " + creatorName,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: GoogleFonts.lato(
              color: AppColors.greys60,
              fontSize: fontSize.sp,
            ),
          ),
        ]);
  }
}
