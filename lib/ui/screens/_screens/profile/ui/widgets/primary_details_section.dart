import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/model/profile_model.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/pages/edit_primary_details_section.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/field_approval_status.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/profile_form_field_heading.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/profile_form_field_value.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/profile_section_heading.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/withdraw_request_popup.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../localization/index.dart';
import '../../model/profile_field_status_model.dart';

class PrimaryDetailSection extends StatefulWidget {
  final bool notMyUser;
  final bool isDesignationMasterEnabled;
  final bool isMyProfile;
  final Profile? profileDetails;

  const PrimaryDetailSection(
      {Key? key,
      this.notMyUser = false,
      this.isDesignationMasterEnabled = false,
      required this.isMyProfile,
      this.profileDetails})
      : super(key: key);

  @override
  State<PrimaryDetailSection> createState() => _PrimaryDetailSectionState();
}

class _PrimaryDetailSectionState extends State<PrimaryDetailSection> {
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.isMyProfile ? _myProfileView() : _otherProfileView();
  }

  Widget _myProfileView() {
    return Consumer<ProfileRepository>(builder: (BuildContext context,
        ProfileRepository profileRepository, Widget? child) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0).r,
        color: AppColors.appBarBackground,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Selector<ProfileRepository, List<ProfileFieldStatusModel>>(
                selector: (context, repo) => repo.inReview,
                builder: (context, inReviewFields, child) {
                  return ProfileSectionHeading(
                    text: AppLocalizations.of(context)!.mProfilePrimaryDetails,
                    showInfoIcon: true,
                    showEditButton: (!widget.notMyUser),
                    infoMessage: AppLocalizations.of(context)!
                        .mProfileMdoApprovalInfoMessage,
                    showWithdrawButton: inReviewFields.isNotEmpty &&
                        inReviewFields
                            .where((element) => element.name != null)
                            .isEmpty,
                    onEditPressed: inReviewFields.isNotEmpty
                        ? () => inReviewFields
                                .where((element) => element.name != null)
                                .isNotEmpty
                            ? Helper.showSnackBarMessage(
                                context: context,
                                text: AppLocalizations.of(context)!
                                    .mProfileMessageBeforeWithdrawPrimaryDetails,
                                bgColor: AppColors.greys87)
                            : _showWithdrawAlert(inReviewFields)
                        : () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: AppColors.appBarBackground,
                              isScrollControlled: true,
                              shape: _getModalShape(),
                              builder: (context) {
                                return SafeArea(
                                    child: Container(
                                  height: 0.85.sh,
                                  padding: const EdgeInsets.only(top: 32).r,
                                  child: EditPrimaryDetailsSection(
                                    isDesignationMasterEnabled:
                                        widget.isDesignationMasterEnabled,
                                    profileDetails: widget.profileDetails ??
                                        profileRepository.profileDetails,
                                  ),
                                ));
                              },
                            );
                          },
                  );
                }),
            _primaryDetailView(
                widget.profileDetails ?? profileRepository.profileDetails)
          ],
        ),
      );
    });
  }

  Widget _otherProfileView() {
    if (widget.profileDetails == null) return SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0).r,
      color: AppColors.appBarBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileSectionHeading(
              text: AppLocalizations.of(context)!.mProfilePrimaryDetails,
              showEditButton: false),
          _primaryDetailView(widget.profileDetails)
        ],
      ),
    );
  }

  Widget _primaryDetailView(Profile? profileDetails) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileFormFieldHeading(
          text: AppLocalizations.of(context)!.mStaticGroup,
        ),
        ProfileFormFieldValue(
          text: profileDetails?.group ?? EnglishLang.noValue,
          isVerified:
              profileDetails?.profileGroupStatus == UserProfileStatus.verified,
          isApprovalField: true,
          isGroup: true,
        ),
        ProfileFormFieldHeading(
          text: AppLocalizations.of(context)!.mStaticDesignation,
        ),
        ProfileFormFieldValue(
            text: profileDetails?.designation ?? EnglishLang.noValue,
            isApprovalField: true,
            isVerified: profileDetails?.profileDesignationStatus ==
                UserProfileStatus.verified),
        SizedBox(height: 8.w),
        if (widget.isMyProfile)
          FieldApprovalStatus(profileDetails: profileDetails)
      ],
    );
  }

  void _showWithdrawAlert(List<dynamic> inReviewFields) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext ctx) {
          return WithdrawRequestPopup(
            parentContext: context,
            text: AppLocalizations.of(context)!.mProfileWithdrawRequestConfirm,
            inReviewFields: inReviewFields,
            successWithdrawCallback: (value) async {
              if (value) {
                Provider.of<ProfileRepository>(context, listen: false)
                    .designationStatus(value);
              }
            },
          );
        });
  }

  RoundedRectangleBorder _getModalShape() {
    return RoundedRectangleBorder(
      side: BorderSide(color: AppColors.grey08),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(32),
        topRight: Radius.circular(32),
      ).r,
    );
  }
}
