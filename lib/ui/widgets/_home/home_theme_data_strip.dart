import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../../../constants/index.dart';
import '../../../models/_models/overlay_theme_model.dart';

class HomeThemeDataStrip extends StatelessWidget {
  final OverlayThemeModel? overlayThemeUpdatesData;
  final bool showOverlayThemeUpdates;

  const HomeThemeDataStrip({super.key, this.overlayThemeUpdatesData, this.showOverlayThemeUpdates = false});

  
  @override
  Widget build(BuildContext context) {
    return overlayThemeUpdatesData != null
        ? Visibility(
            visible: showOverlayThemeUpdates &&
                overlayThemeUpdatesData != null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                overlayThemeUpdatesData!.logoUrl!= null?Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0).w,
                  child: Lottie.network(
                      ApiUrl.baseUrl + overlayThemeUpdatesData!.logoUrl!,
                      width: 80.w,
                      height: 80.w),
                ):Center(),
                overlayThemeUpdatesData!.logoText!= null?Flexible(
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0).w,
                      child: Text(
                        overlayThemeUpdatesData!.logoText!,
                        style: GoogleFonts.montserrat(
                          color: AppColors.darkBlue,
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                          letterSpacing: 0.12,
                        ),
                      ),
                    ),
                  ),
                ):Center(),
              ],
            ),
          )
        : SizedBox.shrink();
  }
}
