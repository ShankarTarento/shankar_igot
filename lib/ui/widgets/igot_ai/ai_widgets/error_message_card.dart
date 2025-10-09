import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/ai_widgets/ai_bot_icon.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ErrorMessageCard extends StatefulWidget {
  final Function() onRetry;
  const ErrorMessageCard({super.key, required this.onRetry});

  @override
  State<ErrorMessageCard> createState() => _ErrorMessageCardState();
}

class _ErrorMessageCardState extends State<ErrorMessageCard> {
  bool _showRetryButton = true;

  void onRetry() {
    setState(() {
      _showRetryButton = false;
    });
    widget.onRetry();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiBotIcon(),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(12).r,
                constraints: BoxConstraints(maxWidth: 0.65.sw),
                decoration: BoxDecoration(
                  color: AppColors.redBgShade.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.zero,
                    topRight: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ).r,
                ),
                child: Text(
                  AppLocalizations.of(context)!.mIgotAiErrorMessage,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              _showRetryButton
                  ? ElevatedButton(
                      onPressed: onRetry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          side: BorderSide(color: AppColors.darkBlue),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.refresh,
                            size: 18.sp,
                            color: AppColors.darkBlue,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            AppLocalizations.of(context)!.mStaticRetry,
                            style: GoogleFonts.lato(
                              color: AppColors.darkBlue,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ],
      ),
    );
  }
}
