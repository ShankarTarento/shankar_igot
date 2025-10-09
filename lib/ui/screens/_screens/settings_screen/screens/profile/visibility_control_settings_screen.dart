import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/model/profile_model.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:provider/provider.dart';
import '../../../../../../constants/_constants/app_constants.dart';
import '../../../../../widgets/_common/page_loader.dart';

class VisibilityControlSettingsScreen extends StatefulWidget {
  const VisibilityControlSettingsScreen({super.key});

  @override
  State<VisibilityControlSettingsScreen> createState() =>
      _VisibilityControlSettingsScreen();
}

class _VisibilityControlSettingsScreen extends State<VisibilityControlSettingsScreen> {

  ValueNotifier<int?> _selectedVisibility = ValueNotifier(null);
  ValueNotifier<bool> _isLoading = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    getProfileDetails();
  }

  Future<void> getProfileDetails() async {
    _isLoading.value = true;
    Profile? profile;
    List<Profile> profileData = await Provider.of<ProfileRepository>(context, listen: false).getProfileDetailsById('');
    if (profileData.isNotEmpty) {
      profile = profileData.first;
    } else {
      profile = await Provider.of<ProfileRepository>(context, listen: false).profileDetails;
    }
    _selectedVisibility.value = profile?.profilePreference ?? UserProfileVisibilityControls.publicAccess;
    _isLoading.value = false;
  }

  Future<bool?> _updateVisibilitySettings(int visibilityAccess) async {
    try {
      _isLoading.value = true;
      Map profileData = {'profilePreference':visibilityAccess};
      final profileUpdateResponse = await ProfileRepository().updateProfileDetails(profileData);
      if (profileUpdateResponse['params']['status'] == 'success' ||
          profileUpdateResponse['params']['status'] == 'SUCCESS') {
        await Provider.of<ProfileRepository>(context, listen: false).getProfileDetailsById('');
        _selectedVisibility.value = visibilityAccess;
        Helper.showSnackBarMessage(
            context: context,
            text: AppLocalizations.of(context)!.mProfileVisibilityUpdated,
            bgColor: AppColors.positiveLight);
        _isLoading.value = false;
        return true;
      } else {
        Helper.showSnackBarMessage(
            context: context,
            text: profileUpdateResponse['params']['errmsg'] != null
                ? profileUpdateResponse['params']['errmsg']
                : AppLocalizations.of(context)!.mProfileSaveProfileErrorText,
            bgColor: Theme.of(context).colorScheme.error);
        _isLoading.value = false;
        return false;
      }
    } catch(_) {
      _isLoading.value = false;
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(AppLocalizations.of(context)!.mProfileVisibilityControl),
      ),
      body: buildLayout()
    );
  }

  Widget buildLayout() {
    return ValueListenableBuilder(
        valueListenable: _isLoading,
        builder: (BuildContext context, bool isLoading, Widget? child) {
          return Stack(
            children: [
              Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16).r,
                  child: ValueListenableBuilder(
                      valueListenable: _selectedVisibility,
                      builder: (BuildContext context, int? selectedVisibility, Widget? child) {
                        return SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: (selectedVisibility != null) ? Column(
                            children: [
                              sectionHeading(AppLocalizations.of(context)!.mProfilePublic),
                              publicVisibilityView(selectedVisibility),
                              sectionHeading(AppLocalizations.of(context)!.mProfilePrivate),
                              privateVisibilityView(selectedVisibility)
                            ],
                          ) : SizedBox.shrink(),
                        );
                      })
              ),
              if (isLoading)
                Container(
                  color: AppColors.grey16,
                  child: Center(
                    child: PageLoader(
                      strokeWidth: 2,
                      isLightTheme:  true,
                    ),
                  ),
                ),
            ],
          );
        });
  }

  Widget publicVisibilityView(int selectedVisibility) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.appBarBackground,
        borderRadius: BorderRadius.circular(12).r,
      ),
      padding: EdgeInsets.all(16).r,
      child: visibilityControlView(
        title: AppLocalizations.of(context)!.mProfileAnyone,
        description: AppLocalizations.of(context)!.mProfileAnyoneCanViewDataOnYourProfile,
        value: UserProfileVisibilityControls.publicAccess,
        groupValue: selectedVisibility,
      ),
    );
  }

  Widget privateVisibilityView(int selectedVisibility) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.appBarBackground,
        borderRadius: BorderRadius.circular(12).r,
      ),
      padding: EdgeInsets.all(16).r,
      child: Column(
        children: [
          visibilityControlView(
            title: AppLocalizations.of(context)!.mProfileConnectionOnly,
            description: '',
            value: UserProfileVisibilityControls.connectionOnlyAccess,
            groupValue: selectedVisibility,
          ),
          SizedBox(height: 8.w,),
          Divider(
            thickness: 1.w,
            color: AppColors.grey08,
          ),
          SizedBox(height: 8.w,),
          visibilityControlView(
            title: AppLocalizations.of(context)!.mProfileLockMyProfile,
            description: AppLocalizations.of(context)!.mProfileNoOneCanViewDataOnYourProfile,
            value: UserProfileVisibilityControls.privateAccess,
            groupValue: selectedVisibility,
          ),
        ],
      ),
    );
  }

  Widget sectionHeading(String heading) {
    return Container(
      padding: const EdgeInsets.only(top: 32, bottom: 16).r,
      alignment: Alignment.centerLeft,
      child: Text(
        heading,
        style: Theme.of(context).textTheme.titleSmall!.copyWith(
            color: AppColors.greys87,
            fontSize: 14.0.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.25
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget visibilityControlView({
    required String title,
    required String description,
    required int value,
    required int groupValue,
  }) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 0.72.sw,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.lato(
                      fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                if (description.isNotEmpty) ...[
                  SizedBox(height: 6.h),
                  Text(
                    description,
                    style: GoogleFonts.lato(
                        fontSize: 14.sp, fontWeight: FontWeight.normal),
                    maxLines: 2,
                  ),
                ]
              ],
            ),
          ),
          Container(
            width: 28.w,
            height: 28.w,
            child: Radio<int>(
              value: value,
              groupValue: groupValue,
              onChanged: (int? selected) {
                if (selected != null) _updateVisibilitySettings(selected);
              },
              activeColor: AppColors.darkBlue,
            ),
          )
        ],
      );
  }
}
