import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/pages/edit_other_details_section.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/profile_form_field_heading.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/profile_form_field_value.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/profile_section_heading.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../util/date_time_helper.dart';

class OtherDetailsSection extends StatelessWidget {
  const OtherDetailsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0).r,
      color: AppColors.appBarBackground,
      child: Consumer<ProfileRepository>(builder: (BuildContext context,
          ProfileRepository profileRepository, Widget? child) {
        dynamic personalDetails =
            profileRepository.profileDetails?.personalDetails;
        dynamic employmentDetails =
            profileRepository.profileDetails?.employmentDetails;
        dynamic cadreDetails = profileRepository.profileDetails?.cadreDetails;
        return Column(
          children: [
            ProfileSectionHeading(
                text: AppLocalizations.of(context)!.mProfileOtherDetails,
                onEditPressed: () {
                  showBottomSheet(
                    context: context,
                    backgroundColor: AppColors.appBarBackground,
                    builder: (context) {
                      return SafeArea(
                          child: Padding(
                              padding: const EdgeInsets.only(top: 32).r,
                              child: EditOtherDetailsSection()));
                    },
                  );
                },
                showEditButton: true),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileFormFieldHeading(
                    text: AppLocalizations.of(context)!.mProfileEmployeeId),

                ProfileFormFieldValue(text: employmentDetails['employeeCode']),
                ProfileFormFieldHeading(
                    text: AppLocalizations.of(context)!.mRegisteremail),
                ProfileFormFieldValue(
                    text: profileRepository.profileDetails?.primaryEmail),
                ProfileFormFieldHeading(
                    text: AppLocalizations.of(context)!.mProfileMobileNumber),
                ProfileFormFieldValue(
                    text: (((personalDetails['mobile'] != null &&
                                personalDetails['mobile']
                                    .toString()
                                    .isNotEmpty) &&
                            (personalDetails['phoneVerified'] != null &&
                                (personalDetails['phoneVerified'] is String
                                    ? bool.parse(
                                        personalDetails['phoneVerified'])
                                    : personalDetails['phoneVerified'])))
                        ? (EnglishLang.countryCodeIN +
                            personalDetails['mobile'].toString())
                        : EnglishLang.noValue)),
                ProfileFormFieldHeading(
                    text: AppLocalizations.of(context)!.mProfileGender),
                ProfileFormFieldValue(
                    text: personalDetails['gender'] != null
                        ? Helper.capitalize(personalDetails['gender'])
                        : null),
                ProfileFormFieldHeading(
                    text: AppLocalizations.of(context)!.mProfileDOB),
                ProfileFormFieldValue(
                    text: personalDetails['dob'] != null &&
                            personalDetails['dob'].toString().isNotEmpty
                        ? DateTimeHelper.convertDatetimetoDDMonthYYYY(
                            personalDetails['dob'])
                        : null),
                ProfileFormFieldHeading(
                    text: AppLocalizations.of(context)!.mProfileMotherTongue),
                ProfileFormFieldValue(
                    text: personalDetails['domicileMedium'],
                    showDefaultText: true),
                ProfileFormFieldHeading(
                    text: AppLocalizations.of(context)!.mProfileCategory),
                ProfileFormFieldValue(text: personalDetails['category']),
                ProfileFormFieldHeading(
                    text: AppLocalizations.of(context)!.mProfileOfficePincode),
                ProfileFormFieldValue(text: personalDetails['pincode']),
                ProfileFormFieldHeading(
                    text: AppLocalizations.of(context)!.mEhrmsId),
                ProfileFormFieldValue(
                    text: profileRepository.profileDetails?.ehrmsId),
                ProfileFormFieldHeading(
                    text: AppLocalizations.of(context)!.mDateOfRetirement),
                ProfileFormFieldValue(
                    text: profileRepository.profileDetails?.dateOfRetirement ??
                        'NA'),

                ///cadre section start
                ProfileFormFieldHeading(
                    text: AppLocalizations.of(context)!
                        .mAreYouFromOrganizedService),
                if (cadreDetails == null) ProfileFormFieldValue(text: ('')),
                if (cadreDetails != null)
                  ProfileFormFieldValue(
                      text: ((cadreDetails['civilServiceType'] ?? '') != '')
                          ? Helper.capitalize(EnglishLang.yes)
                          : Helper.capitalize(EnglishLang.no)),

                if (cadreDetails?['civilServiceType']?.isNotEmpty ?? false)
                  ProfileFormFieldHeading(
                      text: AppLocalizations.of(context)!
                          .mStaticTypeOfCivilService),
                if (cadreDetails?['civilServiceType']?.isNotEmpty ?? false)
                  ProfileFormFieldValue(text: cadreDetails['civilServiceType']),

                if (cadreDetails?['civilServiceName']?.isNotEmpty ?? false)
                  ProfileFormFieldHeading(
                      text: AppLocalizations.of(context)!.mStaticService),
                if (cadreDetails?['civilServiceName']?.isNotEmpty ?? false)
                  ProfileFormFieldValue(text: cadreDetails['civilServiceName']),

                if (cadreDetails?['cadreName']?.isNotEmpty ?? false)
                  ProfileFormFieldHeading(
                      text: AppLocalizations.of(context)!.mProfileCadre),
                if (cadreDetails?['cadreName']?.isNotEmpty ?? false)
                  ProfileFormFieldValue(text: cadreDetails['cadreName']),

                if ((cadreDetails?['cadreBatch'] ?? "").toString().isNotEmpty)
                  ProfileFormFieldHeading(
                      text: AppLocalizations.of(context)!.mStaticBatch),
                if ((cadreDetails?['cadreBatch'] ?? "").toString().isNotEmpty)
                  ProfileFormFieldValue(
                      text: cadreDetails['cadreBatch'].toString()),

                if (cadreDetails?['cadreControllingAuthorityName']
                        ?.isNotEmpty ??
                    false)
                  ProfileFormFieldHeading(
                      text: AppLocalizations.of(context)!
                          .mProfileCadreControllingAuthority),
                if (cadreDetails?['cadreControllingAuthorityName']
                        ?.isNotEmpty ??
                    false)
                  ProfileFormFieldValue(
                      text: cadreDetails['cadreControllingAuthorityName']),

                if (cadreDetails?['isOnCentralDeputation'] != null) ...[
                  ProfileFormFieldHeading(
                      text: AppLocalizations.of(context)!.mProfileCentralDeputation),
                  ProfileFormFieldValue(
                      text: (cadreDetails['isOnCentralDeputation'] ?? false) ? Helper.capitalize(EnglishLang.yes) : Helper.capitalize(EnglishLang.no)),
                ]
                ///cadre section end
              ],
            ),
          ],
        );
      }),
    );
  }
}
