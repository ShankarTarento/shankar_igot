import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/utils/profile_constants.dart';
import 'package:provider/provider.dart';

import '../../../../../../constants/index.dart';
import '../../../../../../util/telemetry_repository.dart';
import '../../model/profile_dashboard_arg_model.dart';
import '../../../../../widgets/_common/user_image_widget.dart';

class ProfilePicture extends StatelessWidget {
  final profileParentAction;
  final bool isFromDrawer;
  final GlobalKey<ScaffoldState>? drawerKey;

  ProfilePicture(
      {this.profileParentAction, this.isFromDrawer = false, this.drawerKey});

  void _generateInteractTelemetryData(
      {required String contentId, required BuildContext context}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.homePageId,
        contentId: contentId,
        subType: TelemetrySubType.profile.toLowerCase(),
        env: TelemetryEnv.home);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileRepository>(
        builder: (context, profileRepository, _) {
      return InkWell(
          onTap: () {
            if (isFromDrawer) {
              Navigator.pushNamed(context, AppUrl.profileDashboard,
                  arguments: ProfileDashboardArgModel(
                      type: ProfileConstants.currentUser,
                      profileParentAction: profileParentAction));
            } else {
              _generateInteractTelemetryData(
                  contentId: TelemetryIdentifier.profileIcon, context: context);
              if (drawerKey != null) {
                drawerKey!.currentState!.openDrawer();
              }
            }
          },
          child: profileRepository.profileDetails != null
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    UserImageWidget(
                      imgUrl:
                          profileRepository.profileDetails?.profileImageUrl ??
                              '',
                      errorText:
                          (profileRepository.profileDetails?.firstName != null
                                  ? profileRepository.profileDetails!.firstName
                                  : '') +
                              ' ' +
                              (profileRepository.profileDetails != null
                                  ? profileRepository.profileDetails!.surname
                                  : ''),
                      errorImageColor: AppColors.deepBlue,
                      errorTextFontSize: 12.sp,
                      height: isFromDrawer ? 52.w : 35.w,
                      width: isFromDrawer ? 52.w : 35.w,
                      fit: BoxFit.contain,
                    ),
                    profileRepository.profileDetails?.profileStatus ==
                            UserProfileStatus.verified
                        ? Positioned(
                            bottom: isFromDrawer ? 2.5.w : 0.w,
                            right: isFromDrawer ? 2.5.w : 0.w,
                            child: Center(
                              child: CircleAvatar(
                                backgroundColor: AppColors.positiveLight,
                                radius: 5.0.r,
                                child: SvgPicture.asset(
                                  'assets/img/approved.svg',
                                  width: 10.0.w,
                                  height: 10.0.w,
                                ),
                              ),
                            ),
                          )
                        : Center()
                  ],
                )
              : _profileImgErrorWidget());
    });
  }

  Widget _profileImgErrorWidget() {
    return ClipRRect(
      borderRadius: BorderRadius.all(
        Radius.circular(100.w),
      ),
      child: Container(
        height: isFromDrawer ? 52.w : 35.w,
        width: isFromDrawer ? 52.w : 35.w,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.grey04,
            shape: BoxShape.circle,
          ),
          child: Center(
              child: Icon(
            Icons.person_outline_rounded,
            color: AppColors.grey16,
            size: 24.w,
          )),
        ),
      ),
    );
  }
}
