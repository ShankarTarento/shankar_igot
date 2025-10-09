import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/common_components/image_widget/image_widget.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/models/ai_chat_bot_response.dart';

class AiResponseContainer extends StatelessWidget {
  final Widget icon;
  final Widget? pageDetails;
  final Function() copyToClipboard;
  final Function() onTap;
  final RetrievedChunk data;

  const AiResponseContainer({
    super.key,
    required this.icon,
    this.pageDetails,
    required this.data,
    required this.copyToClipboard,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 0.65.sw,
            child: Text(data.name,
                style: GoogleFonts.lato(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkBlue,
                )),
          ),
        ),
        SizedBox(height: 6.w),
        InkWell(
          onTap: onTap,
          child: Container(
            width: 0.40.sw,
            height: 0.130.sh,
            margin: EdgeInsets.only(bottom: 4.r),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primaryOne, width: 1.5),
              color: Colors.white,
              borderRadius: BorderRadius.circular(8).r,
            ),
            child: Stack(
              children: [
                Center(
                  child: SizedBox(
                    width: 0.35.sw,
                    child: ImageWidget(
                      imageUrl: "assets/img/resource_background.png",
                      height: 0.110.sw,
                      width: 0.35.sw,
                    ),
                  ),
                ),
                if (pageDetails != null)
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: EdgeInsets.all(4).r,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.r),
                        color: Colors.black,
                      ),
                      child: pageDetails,
                    ),
                  ),
                Positioned(child: Center(child: icon)),
              ],
            ),
          ),
        ),
        Row(
          children: [
            InkWell(
              onTap: onTap,
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
        SizedBox(height: 25.w),
      ],
    );
  }
}
