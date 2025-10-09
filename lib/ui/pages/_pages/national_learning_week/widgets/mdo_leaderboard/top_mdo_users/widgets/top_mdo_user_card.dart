import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';

class TopMdoUserCard extends StatelessWidget {
  const TopMdoUserCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.appBarBackground,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.mandatoryRed,
            child: Text('6'),
          ),
          SizedBox(
            width: 12,
          ),
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.positiveDark,
            child: Text('6'),
          ),
          SizedBox(
            width: 12,
          ),
          SizedBox(
            width: 0.35.sw,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Preet Bharat',
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Flexible(
                  child: Text(
                    'Software Engineer Engineer',
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.greys60,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/img/kp_icon.svg',
                      width: 24.w,
                      height: 24.w,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      '4,273 points',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Spacer(),
          Image.asset(
            'assets/img/Medal.png',
            width: 32.w,
            height: 32.w,
          ),
        ],
      ),
    );
  }
}
