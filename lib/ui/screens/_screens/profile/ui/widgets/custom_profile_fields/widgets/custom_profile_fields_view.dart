import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/api_endpoints.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/custom_profile_fields/constants/custom_field_constats.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/custom_profile_fields/models/custom_profile_data.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/profile_form_field_heading.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/profile_form_field_value.dart';
import 'package:karmayogi_mobile/ui/skeleton/widgets/container_skeleton.dart';
import 'package:karmayogi_mobile/util/helper.dart';

class CustomProfileFieldsView extends StatefulWidget {
  final List<CustomProfileData> customProfileData;

  const CustomProfileFieldsView({super.key, required this.customProfileData});

  @override
  State<CustomProfileFieldsView> createState() =>
      _CustomProfileFieldsViewState();
}

class _CustomProfileFieldsViewState extends State<CustomProfileFieldsView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.customProfileData.isNotEmpty
          ? List.generate(widget.customProfileData.length, (index) {
              return buildCustomFields(
                  customField: widget.customProfileData[index]);
            })
          : [
              SizedBox(height: 20.w),
              Center(
                  child: CachedNetworkImage(
                      width: 100.w,
                      height: 80.w,
                      fit: BoxFit.contain,
                      imageUrl: ApiUrl.baseUrl +
                          '/assets/mobile_app/assets/empty.gif',
                      placeholder: (context, url) => ContainerSkeleton(
                            width: 100.w,
                            height: 80.w,
                          ),
                      errorWidget: (context, url, error) => Container(
                          width: 100.w,
                          height: 80.w,
                          color: AppColors.appBarBackground))),
            ],
    );
  }

  Widget buildCustomFields({
    required CustomProfileData customField,
  }) {
    if (customField.type == CustomFieldConstants.text) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileFormFieldHeading(
              text: Helper.capitalizeFirstLetter(customField.attributeName)),
          ProfileFormFieldValue(
            text: Helper.capitalizeFirstLetter(customField.value ?? ""),
          ),
          SizedBox(height: 4.w),
        ],
      );
    } else if (customField.type == CustomFieldConstants.masterList) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12.w),
          Text(
            Helper.capitalizeFirstLetter(customField.attributeName),
            style: GoogleFonts.lato(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          ...customField.values!.map((value) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileFormFieldHeading(
                    text: Helper.capitalizeFirstLetter(value.attributeName)),
                ProfileFormFieldValue(
                  text: Helper.capitalizeFirstLetter(value.value),
                ),
              ],
            );
          }).toList(),
          SizedBox(height: 8.w),
        ],
      );
    } else {
      return SizedBox.shrink();
    }
  }
}
