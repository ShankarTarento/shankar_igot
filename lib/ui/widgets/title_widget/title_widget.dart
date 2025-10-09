import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import '../../../constants/_constants/color_constants.dart';
import '../_learn/content_info.dart';

class TitleWidget extends StatelessWidget {
  final String title;
  final String? toolTipMessage;
  final Function()? showAllCallBack;
  final double titleFontSize;
  final double showAllFontSize;
  final String? buttonText;

  const TitleWidget(
      {Key? key,
      this.titleFontSize = 17,
      this.showAllFontSize = 14,
      required this.title,
      this.toolTipMessage,
      this.showAllCallBack,
      this.buttonText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 0.6.sw,
          child: Row(
            children: [
              Flexible(
                child: Text(
                  Helper.capitalizeEachWordFirstCharacter(title),
                  style: GoogleFonts.lato(
                    color: AppColors.greys87,
                    fontWeight: FontWeight.w700,
                    fontSize: titleFontSize.sp,
                    letterSpacing: 0.12.r,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              toolTipMessage != null
                  ? ContentInfo(infoMessage: toolTipMessage!)
                  : SizedBox()
            ],
          ),
        ),
        Spacer(),
        showAllCallBack != null
            ? InkWell(
                onTap: showAllCallBack,
                child: Row(
                  children: [
                    Text(
                      buttonText ?? AppLocalizations.of(context)!.mLearnShowAll,
                      style: GoogleFonts.lato(
                        color: AppColors.darkBlue,
                        fontWeight: FontWeight.w400,
                        fontSize: showAllFontSize.sp,
                        letterSpacing: 0.12.r,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.darkBlue,
                      size: 20.w,
                    )
                  ],
                ))
            : SizedBox()
      ],
    );
  }
}
