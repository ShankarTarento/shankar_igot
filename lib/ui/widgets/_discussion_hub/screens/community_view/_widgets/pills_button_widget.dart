import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/widgets/_common/page_loader.dart';

class PillsButtonWidget extends StatelessWidget {

  final String title;
  final Widget? prefix;
  final Function? onTap;
  final BoxDecoration? decoration;
  final Color? textColor;
  final double? textFontSize;
  final ValueNotifier<bool>? isLoading;
  final bool? isLightTheme;
  final double? verticalPadding;
  final double? horizontalPadding;

  const PillsButtonWidget({super.key, required this.title, this.prefix, this.onTap,
    this.decoration, this.textColor, this.textFontSize, this.isLoading, this.isLightTheme, this.verticalPadding, this.horizontalPadding});

  @override
  Widget build(BuildContext context) {
    return _pillsButton();
  }

  Widget _pillsButton() {
    return GestureDetector(
      onTap: () {
        if (onTap != null)
          onTap!();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: verticalPadding ?? 8.w, horizontal: horizontalPadding ?? 16.w),
        decoration: decoration ?? BoxDecoration(
            border: Border.all(color: AppColors.grey40),
            borderRadius: BorderRadius.all(const Radius.circular(50.0).r),
            color: AppColors.appBarBackground
        ),
        child: (isLoading != null)
            ? ValueListenableBuilder(
            valueListenable: isLoading!,
            builder: (BuildContext context, bool isLoading, Widget? child) {
              return isLoading
                  ? Container(
                    alignment: Alignment.center,
                    child: SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: Center(
                          child: PageLoader(
                            strokeWidth: 2,
                            isLightTheme: isLightTheme ?? false,
                          ),
                        )
                    ),
                  )
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                          if (prefix != null)
                            Padding(padding: EdgeInsets.only(right: 4).w,
                                child: prefix
                            ),
                          Text(
                            title,
                            style: GoogleFonts.lato(
                              color: textColor ?? AppColors.grey40,
                              fontWeight: FontWeight.w700,
                              fontSize: textFontSize ?? 12.0.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                  );
            })
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (prefix != null)
              Padding(
                  padding: EdgeInsets.only(right: 4).w,
                  child: prefix
              ),
            Text(
              title,
              style: GoogleFonts.lato(
                color: textColor ?? AppColors.grey40,
                fontWeight: FontWeight.w700,
                fontSize: textFontSize ?? 12.0.sp,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        )
      ),
    );
  }

}
