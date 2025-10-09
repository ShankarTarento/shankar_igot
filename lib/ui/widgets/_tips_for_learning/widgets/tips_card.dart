import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/ui/widgets/_tips_for_learning/data_models/tips_model.dart';
import '../../../../constants/_constants/color_constants.dart';
import '../../../../util/helper.dart';

class TipsCard extends StatelessWidget {
  final TipsModel tip;
  const TipsCard({Key? key, required this.tip}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 16).r,
      width: 1.sw,
      height: 75.w,
      decoration: BoxDecoration(
          color: AppColors.appBarBackground,
          borderRadius: BorderRadius.circular(8).r),
      padding: EdgeInsets.all(14).r,
      child: Row(
        children: [
          SizedBox(
            height: 40.w,
            width: 40.w,
            child: Image.network(
              tip.imagePath,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(
            width: 16.w,
          ),
          FutureBuilder<Locale>(
              future: Helper.getLocale(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return SizedBox(
                    width: 0.67.sw,
                    child: Text(
                      tip.tip.getText(context),
                      style: GoogleFonts.lato(
                          fontSize: 12.sp, fontWeight: FontWeight.w400),
                    ),
                  );
                } else {
                  return SizedBox();
                }
              })
        ],
      ),
    );
  }
}
