import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NationalLearningWeekDescription extends StatelessWidget {
  final String? imageUrl;
  final String? description;
  final String? title;
  const NationalLearningWeekDescription(
      {super.key, this.description, this.imageUrl, this.title});

  @override
  Widget build(BuildContext context) {
    bool isSvg =
        imageUrl != null ? imageUrl!.toLowerCase().endsWith('.svg') : false;

    return Padding(
      padding: const EdgeInsets.all(16.0).r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          imageUrl != null
              ? Center(
                  child: Container(
                      height: 130.w,
                      width: 130.w,
                      margin: EdgeInsets.only(bottom: 16).r,
                      padding: EdgeInsets.all(4).r,
                      decoration: BoxDecoration(
                          border: Border.all(color: AppColors.grey08),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.grey08,
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(65).r,
                          color: AppColors.appBarBackground),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(65).r,
                        child: isSvg
                            ? SvgPicture.network(
                                imageUrl!,
                                fit: BoxFit.contain,
                              )
                            : Image.network(
                                imageUrl!,
                                fit: BoxFit.contain,
                              ),
                      )),
                )
              : SizedBox(),
          Text(
            title ?? '',
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600, fontSize: 16.sp),
          ),
          SizedBox(
            height: 16.w,
          ),
          Text(
            description ?? '',
            style: GoogleFonts.lato(
              fontSize: 14.sp,
            ),
          )
        ],
      ),
    );
  }
}
