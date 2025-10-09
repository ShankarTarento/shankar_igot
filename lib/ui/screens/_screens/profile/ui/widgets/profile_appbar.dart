import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/models/_models/option_item_model.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/option_boottosheet_content.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:provider/provider.dart';
import '../../../../../../constants/index.dart';
import '../../../../../../respositories/index.dart';
import '../../../settings_screen/models/settings_request_model.dart';
import '../../model/profile_field_status_model.dart';
import '../../model/profile_top_section_model.dart';
import '../../utils/profile_constants.dart';
import '../../view_model/profile_appbar_view_model.dart';
import '../pages/edit_profile_top_section.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileAppbar extends StatelessWidget {
  final String? name;
  final String? userId;
  final String? state;
  final String? district;
  final String? profileImageUrl;
  final String? uuid;
  final bool isDesignationMasterEnabled;
  final bool isMyProfile;
  final bool notMyUser;
  final Function(ProfileTopSectionModel) onUpdateCallback;

  const ProfileAppbar(
      {super.key,
      this.name,
      this.userId,
      this.state,
      this.district,
      this.profileImageUrl,
      this.uuid,
      this.isDesignationMasterEnabled = false,
      this.notMyUser = false,
      required this.isMyProfile,
      required this.onUpdateCallback});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16).r,
      color: AppColors.appBarBackground,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Visibility(
            visible: !notMyUser,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              padding: EdgeInsets.only(right: 50).r,
              icon: Icon(Icons.arrow_back_ios,
                  color: AppColors.greys60, size: 20.sp),
            ),
          ),
          (isMyProfile)
              ? Container(
                  margin: EdgeInsets.only(left: 4).w,
                  alignment: Alignment.topRight,
                  child: PopupMenuTheme(
                    data: PopupMenuThemeData(
                      color: AppColors.appBarBackground,
                      textStyle: TextStyle(
                        color: AppColors.greys,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Selector<ProfileRepository,
                            List<ProfileFieldStatusModel>>(
                        selector: (context, repository) => repository.inReview,
                        builder: (context, inReviewFields, child) {
                          return PopupMenuButton<String>(
                            child: SizedBox(
                              width: 24.w,
                              height: 24.w,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: Container(
                                  child: Icon(
                                    Icons.more_vert,
                                    size: 24.w,
                                    color: AppColors.darkBlue,
                                  ),
                                ),
                              ),
                            ),
                            itemBuilder: (context) {
                              final sortedMenuItems = [
                                ...ProfilMenu.getMenuItems(
                                    showWithdraw: inReviewFields.isNotEmpty &&
                                        (inReviewFields
                                            .where((element) =>
                                                element.name != null)
                                            .isNotEmpty))
                              ]..sort(
                                  (a, b) => a['index'].compareTo(b['index']));
                              return sortedMenuItems.map((menuItem) {
                                final item = menuItem['item'] as String;
                                final label =
                                    ProfilMenu.getMenuItemLabel(item, context);
                                return PopupMenuItem<String>(
                                  value: item,
                                  child: Text(label),
                                );
                              }).toList();
                            },
                            onSelected: (value) {
                              switch (value) {
                                case ProfilMenu.editProfile:
                                  showModalBottomSheet(
                                    context: context,
                                    backgroundColor: AppColors.appBarBackground,
                                    isScrollControlled: true,
                                    builder: (context) {
                                      return EditProfileTopSection(
                                          firstName: name ?? '',
                                          state: state ?? '',
                                          district: district ?? '',
                                          uuid: uuid ?? '',
                                          onUpdateCallback: onUpdateCallback);
                                    },
                                  );
                                  break;
                                case ProfilMenu.transferRequest:
                                  ProfileAppbarViewModel().doTransferRequest(
                                      context: context,
                                      isDesignationMasterEnabled:
                                          isDesignationMasterEnabled);
                                  break;
                                case ProfilMenu.withdrawRequest:
                                  ProfileAppbarViewModel().doWithdrawRequest(
                                      context: context,
                                      isDesignationMasterEnabled:
                                          isDesignationMasterEnabled,
                                      isWithdrawTransferRequest: inReviewFields
                                          .where(
                                              (element) => element.name != null)
                                          .isNotEmpty,
                                      fieldStatusList: inReviewFields);
                                  break;
                                case ProfilMenu.settings:
                                  Navigator.pushNamed(
                                      context,
                                      AppUrl.settingsPage,
                                      arguments: SettingsRequestModel(
                                        notMyUser: notMyUser,
                                      )
                                  );
                                  break;
                                case ProfilMenu.signOut:
                                  ProfileAppbarViewModel().doSignOut(context);
                                  break;
                                default:
                                  break;
                              }
                            },
                          );
                        }),
                  ),
                )
              : GestureDetector(
                  onTap: () {
                    _showOptionBottomSheet(
                        context: context,
                        height: 0.1.sh,
                        options: [
                          OptionItemModel(
                              level: AppLocalizations.of(context)!
                                  .mProfileCopyProfileLink,
                              value: 'copyLink')
                        ],
                        onItemSelected: (optionItemModel) async {
                          if (optionItemModel.value == 'copyLink') {
                            await Clipboard.setData(ClipboardData(
                                text:
                                    '${ApiUrl.baseUrl}/app/person-profile/${userId}'));
                            Helper.showSnackBarMessage(
                                context: context,
                                text: AppLocalizations.of(context)!
                                    .mContentSharePageLinkCopied,
                                bgColor: AppColors.positiveLight);
                          }
                        });
                  },
                  child: SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Container(
                        child: Icon(
                          Icons.more_vert,
                          size: 24.w,
                          color: AppColors.darkBlue,
                        ),
                      ),
                    ),
                  ),
                )
        ],
      ),
    );
  }

  PopupMenuItem<int> popup_menu_item_widget(
      BuildContext context, int value, String text) {
    return PopupMenuItem<int>(
        value: value,
        child: Text(text,
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: AppColors.greys60)));
  }

  void _showOptionBottomSheet(
      {required BuildContext context,
      required List<OptionItemModel> options,
      required double height,
      required Function(OptionItemModel) onItemSelected}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => OptionBottomSheetContent(
        items: options,
        onItemSelected: onItemSelected,
        height: height,
      ),
    );
  }
}
