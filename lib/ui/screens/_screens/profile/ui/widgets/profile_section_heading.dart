import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/widgets/tooltip_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileSectionHeading extends StatelessWidget {
  final String text;
  final bool showInfoIcon;
  final String? infoMessage;
  final bool showEditButton;
  final Function()? onEditPressed;
  final bool showWithdrawButton;
  const ProfileSectionHeading(
      {Key? key,
      required this.text,
      this.showInfoIcon = false,
      this.infoMessage,
      this.showEditButton = false,
      this.onEditPressed,
      this.showWithdrawButton = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              text,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(color: AppColors.greys),
            ),
            Visibility(
              visible: showInfoIcon,
              child: Padding(
                padding: const EdgeInsets.only(left: 8).r,
                child: TooltipWidget(
                  message: infoMessage.toString(),
                  iconSize: 16.sp,
                ),
              ),
            ),
          ],
        ),
        Visibility(
          visible: showEditButton || showWithdrawButton,
          child: showWithdrawButton
              ? OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      textStyle: GoogleFonts.lato(
                          fontSize: 14.sp, fontWeight: FontWeight.w700),
                      foregroundColor: AppColors.darkBlue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50).r),
                      side: BorderSide(color: AppColors.darkBlue)),
                  onPressed: onEditPressed,
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                        width: 8.w,
                      ),
                      Text(
                        AppLocalizations.of(context)!.mProfileWithdrawRequest,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lato(
                            color: AppColors.darkBlue,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ))
              : InkWell(
                  onTap: onEditPressed,
                  child: Padding(
                      padding: EdgeInsets.only(left: 24, top: 10, bottom: 10).r,
                      child: Icon(
                        Icons.edit,
                        color: AppColors.darkBlue,
                        size: 18.sp,
                      ))),
        )
      ],
    );
  }
}
