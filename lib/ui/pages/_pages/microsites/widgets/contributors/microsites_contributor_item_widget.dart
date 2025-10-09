import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/ui/components/microsite_expandable_text.dart';
import 'package:igot_ui_components/ui/components/microsite_image_view.dart';
import '../../../../../../constants/_constants/color_constants.dart';

class MicroSiteContributorItemWidget extends StatelessWidget {
  final String? name;
  final String? description;
  final String? imgUrl;
  MicroSiteContributorItemWidget({this.name, this.description, this.imgUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250.w,
      margin: EdgeInsets.only(right: 16.w),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        child: Container(
          color: AppColors.appBarBackground,
          width: 0.48.sw,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MicroSiteImageView(
                imgUrl: imgUrl ?? '',
                height: 158.w,
                width: double.maxFinite,
                fit: BoxFit.contain,
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 8, left: 16, right: 16).w,
                  child: MicroSiteExpandableText(
                    text: name ?? '',
                    style: GoogleFonts.montserrat(
                      color: AppColors.greys87,
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                      height: 1.5.w,
                      letterSpacing: 0.25.w,
                    ),
                    maxLines: 1,
                    enableCollapse: true,
                  )),
              Padding(
                  padding: const EdgeInsets.only(
                          top: 4, left: 16, right: 16, bottom: 16)
                      .w,
                  child: MicroSiteExpandableText(
                    text: description ?? '',
                    style: GoogleFonts.lato(
                      color: AppColors.greys60,
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp,
                      height: 1.5.w,
                      letterSpacing: 0.25.w,
                    ),
                    maxLines: 3,
                    enableCollapse: true,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
