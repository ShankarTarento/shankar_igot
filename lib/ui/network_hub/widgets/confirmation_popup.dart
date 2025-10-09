import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConfirmationDialog extends StatelessWidget {
  final String message;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final String? confirmLabel;
  final String? cancelLabel;
  final BuildContext parentContext;

  const ConfirmationDialog({
    super.key,
    required this.message,
    required this.onConfirm,
    required this.onCancel,
    this.confirmLabel,
    this.cancelLabel,
    required this.parentContext,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.all(16.r),
      title: Center(
        child: Icon(
          Icons.error_outline_outlined,
          color: AppColors.primaryOne,
          size: 60.sp,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: GoogleFonts.lato(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.darkBlue,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDialogButton(
                label: cancelLabel ??
                    AppLocalizations.of(parentContext)!.mStaticNo,
                textColor: AppColors.darkBlue,
                backgroundColor: Colors.white,
                borderColor: AppColors.darkBlue,
                onPressed: onCancel,
              ),
              SizedBox(width: 20.w),
              _buildDialogButton(
                label: confirmLabel ??
                    AppLocalizations.of(parentContext)!.mStaticYes,
                textColor: Colors.white,
                backgroundColor: AppColors.darkBlue,
                onPressed: onConfirm,
              ),
            ],
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildDialogButton({
    required String label,
    required Color textColor,
    required Color backgroundColor,
    Color? borderColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12).r,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100).r,
          side: borderColor != null
              ? BorderSide(color: borderColor, width: 1.5)
              : BorderSide.none,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.lato(
          color: textColor,
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
