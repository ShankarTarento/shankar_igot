import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/custom_profile_fields/models/custom_profile_data.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/custom_profile_fields/widgets/custom_profile_fields_view.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/utils/profile_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/ui/widgets/custom_tabs.dart';

class CustomProfileFieldScreen extends StatelessWidget {
  final String type;
  final List<CustomProfileData> customProfileData;
  final Function({required List<CustomProfileData> customProfileData})
      showCustomEditFields;
  const CustomProfileFieldScreen({
    super.key,
    required this.type,
    required this.customProfileData,
    required this.showCustomEditFields,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBarBackground,
      bottomNavigationBar: type == ProfileConstants.customProfileTab &&
              customProfileData.isNotEmpty
          ? Container(
              color: AppColors.appBarBackground,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => CustomTabs()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0).r,
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.mContinue,
                  style: GoogleFonts.lato(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.appBarBackground,
                  ),
                ),
              ),
            )
          : SizedBox.shrink(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.mOrgSpecificDetails,
                  style: GoogleFonts.lato(
                      fontSize: 16.sp, fontWeight: FontWeight.w600),
                ),
                Spacer(),
                InkWell(
                  onTap: () {
                    showCustomEditFields(customProfileData: customProfileData);
                  },
                  child: customProfileData.isNotEmpty
                      ? Icon(
                          Icons.edit,
                          size: 20.sp,
                          color: AppColors.darkBlue,
                        )
                      : Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.darkBlue,
                              width: 1.w,
                            ),
                            borderRadius: BorderRadius.circular(50).r,
                          ),
                          padding: EdgeInsets.only(
                                  left: 8, right: 8, top: 4, bottom: 4)
                              .r,
                          child: Text(
                              "+ " + AppLocalizations.of(context)!.mStaticAdd,
                              style: GoogleFonts.lato(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkBlue,
                              )),
                        ),
                ),
              ],
            ),
            SizedBox(height: 16.w),
            Column(
              children: [
                CustomProfileFieldsView(
                  customProfileData: customProfileData,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
