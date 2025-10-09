import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/custom_profile_fields/edit_custom_profile_fields.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/custom_profile_fields/models/custom_profile_data.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/custom_profile_fields/repository/custom_profile_field_repository.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/custom_profile_fields/widgets/custom_profile_field_screen.dart';
import 'package:karmayogi_mobile/ui/skeleton/widgets/container_skeleton.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomProfileField extends StatefulWidget {
  final String type;
  const CustomProfileField({super.key, required this.type});

  @override
  State<CustomProfileField> createState() => _CustomProfileFieldState();
}

class _CustomProfileFieldState extends State<CustomProfileField> {
  @override
  void initState() {
    customFieldDataFuture = CustomProfileFieldRepository().getCustomFieldData();
    super.initState();
  }

  late Future<List<CustomProfileData>> customFieldDataFuture;
  @override
  Widget build(BuildContext context) {
    return CustomProfileFieldRepository.getOrgCustomFieldsData != null &&
            CustomProfileFieldRepository
                .getOrgCustomFieldsData!.customFieldIds.isNotEmpty
        ? Container(
            padding: EdgeInsets.all(16.0).r,
            decoration: BoxDecoration(
              color: AppColors.appBarBackground,
              borderRadius: BorderRadius.circular(8.0).r,
            ),
            child: FutureBuilder(
                future: customFieldDataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return loadingWidget();
                  }
                  if (snapshot.data != null) {
                    List<CustomProfileData> customProfileData = snapshot.data!;

                    return CustomProfileFieldScreen(
                      type: widget.type,
                      customProfileData: customProfileData,
                      showCustomEditFields: showCustomEditFields,
                    );
                  }
                  return SizedBox();
                }),
          )
        : SizedBox();
  }

  void showCustomEditFields(
      {required List<CustomProfileData> customProfileData}) {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0).r),
      ),
      builder: (BuildContext context) {
        return EditCustomProfileFields(
          onSubmit: () {
            customFieldDataFuture =
                CustomProfileFieldRepository().getCustomFieldData();
            setState(() {});
          },
          customProfileData: customProfileData,
        );
      },
    );
  }

  Widget loadingWidget() {
    return SingleChildScrollView(
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
              Icon(
                Icons.edit,
                size: 20.sp,
                color: AppColors.darkBlue,
              ),
            ],
          ),
          SizedBox(height: 16.w),
          Column(
              children: List.generate(
            4,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0).r,
              child: ContainerSkeleton(
                height: 60.w,
                width: 1.sw,
              ),
            ),
          ))
        ],
      ),
    );
  }
}
