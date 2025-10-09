import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/widgets/custom_image_widget.dart';

class EventTypePill extends StatelessWidget {
  final String title;
  final String imageUrl;
  const EventTypePill({super.key, required this.title, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4).r,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4).r,
          color: AppColors.fourthLinearOne),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ImageWidget(
            imageUrl: imageUrl,
            height: 14.w,
            width: 14.w,
            color: AppColors.appBarBackground,
          ),
          SizedBox(
            width: 5.w,
          ),
          Text(
            title,
            style: GoogleFonts.lato(
                color: AppColors.appBarBackground,
                fontSize: 12.sp,
                fontWeight: FontWeight.w400),
          )
        ],
      ),
    );
  }
}
