import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/models/ai_chat_bot_response.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CollectionContainer extends StatelessWidget {
  final RetrievedChunk data;
  final Function({required RetrievedChunk data, required BuildContext context})
      onTap;
  final Function() copyToClipboard;

  const CollectionContainer({
    super.key,
    required this.data,
    required this.onTap,
    required this.copyToClipboard,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => onTap(data: data, context: context),
          child: Container(
            width: 0.65.sw,
            margin: EdgeInsets.only(bottom: 4.r),
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.darkBlue),
              borderRadius: BorderRadius.only(
                topLeft: Radius.zero,
                topRight: Radius.circular(8),
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ).r,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 0.5.sw,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.name,
                        style: GoogleFonts.lato(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkBlue,
                        ),
                      ),
                      SizedBox(height: 6.w),
                    ],
                  ),
                ),
                const Spacer(),
                Icon(Icons.chevron_right, color: AppColors.darkBlue),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 0.65.sw,
          child: Text(
            data.description,
            style: GoogleFonts.lato(
              fontSize: 14.sp,
              height: 1.3,
            ),
          ),
        ),
        SizedBox(height: 6.w),
        Row(
          children: [
            InkWell(
              onTap: () => onTap(data: data, context: context),
              child: Text(
                AppLocalizations.of(context)!.mCLickToView,
                style: GoogleFonts.lato(
                  decoration: TextDecoration.underline,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkBlue,
                ),
              ),
            ),
            SizedBox(width: 6.w),
            InkWell(
              onTap: copyToClipboard,
              child: Icon(Icons.copy, size: 20.sp),
            ),
          ],
        ),
        SizedBox(height: 20.w),
      ],
    );
  }
}
