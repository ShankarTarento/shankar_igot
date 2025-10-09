import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/common_components/image_widget/image_widget.dart';
import 'package:karmayogi_mobile/constants/_constants/api_endpoints.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/model/extended_profile_model.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/model/profile_model.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/pages/public_profile_dashboard/widget/public_profile_banner_section.dart';

class PublicProfileBlockedState extends StatelessWidget {
  final Profile profile;
  final ExtendedProfile? extendedProfile;
  final String blockMessage;
  final String? placeholderImage;
  final Decoration? containerDecoration;
  final EdgeInsetsGeometry? containerMargin;

  const PublicProfileBlockedState({
    super.key,
    required this.profile,
    this.extendedProfile,
    required this.blockMessage,
    this.placeholderImage,
    this.containerDecoration,
    this.containerMargin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PublicProfileBannerSection(
          profile: profile,
          extendedProfile: extendedProfile,
        ),
        Container(
          width: double.infinity,
          margin: containerMargin ?? EdgeInsets.only(top: 16).r,
          decoration: containerDecoration ?? BoxDecoration(
            color: Colors.white,
          ),
          padding: EdgeInsets.all(16.0).r,
          child: Column(
            children: [
              ImageWidget(
                  height: 90.w,
                  imageUrl: placeholderImage ?? ApiUrl.baseUrl + "/assets/icons/no-data.svg"),
              SizedBox(height: 16.w),
              Text(
                blockMessage,
                style: GoogleFonts.lato(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
