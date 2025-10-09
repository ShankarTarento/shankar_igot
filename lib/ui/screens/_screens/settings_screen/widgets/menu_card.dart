import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';

class MenuCard extends StatelessWidget {
  final Function() onTapCallBack;
  final Widget? prefixImage;
  final String title;
  const MenuCard({
    super.key,
    required this.onTapCallBack,
    this.prefixImage,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTapCallBack,
        child: Container(
            decoration: BoxDecoration(
              color: AppColors.appBarBackground,
            ),
            padding: const EdgeInsets.all(15).r,
            margin: const EdgeInsets.only(bottom: 5).r,
            child: Row(
              children: <Widget>[
                Container(
                    padding: const EdgeInsets.only(right: 20).r,
                    child: prefixImage ?? SizedBox()),
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.lato(
                      color: AppColors.greys87,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            )));
  }
}
