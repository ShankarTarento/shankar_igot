import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/pages/edit_about_me.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/horizontal_separator.dart';
import 'package:provider/provider.dart';
import '../../../../../../constants/index.dart';
import '../../../../../skeleton/index.dart';
import 'view_more_text_widget.dart';

class ProfileAboutMe extends StatelessWidget {
  final bool isMyProfile;
  final String aboutMe;
  final VoidCallback updateBasicProfile;
  const ProfileAboutMe(
      {Key? key,
      required this.isMyProfile,
      required this.aboutMe,
      required this.updateBasicProfile})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isMyProfile
        ? _myProfileView(context)
        : _aboutMeView(context, aboutMe);
  }

  Widget _myProfileView(BuildContext context) {
    return Consumer<ProfileRepository>(builder: (BuildContext context,
        ProfileRepository profileRepository, Widget? child) {
      dynamic employmentDetails =
          profileRepository.profileDetails?.employmentDetails;
      return _aboutMeView(context, employmentDetails?['aboutme'] ?? '');
    });
  }

  Widget _aboutMeView(BuildContext context, String aboutMe) {
    if (!isMyProfile && aboutMe.isEmpty) return SizedBox.shrink();
    return Container(
      color: AppColors.appBarBackground,
      width: 1.0.sw,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16).r,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppLocalizations.of(context)!.mProfileAboutMe,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(color: AppColors.greys)),
                    if (isMyProfile)
                      InkWell(
                        onTap: () {
                          showBottomSheet(
                            context: context,
                            backgroundColor: AppColors.appBarBackground,
                            builder: (context) {
                              return SafeArea(
                                  child: Padding(
                                      padding: const EdgeInsets.only(top: 32).r,
                                      child: EditAboutMe(
                                          aboutMe: aboutMe,
                                          updateBasicProfile:
                                              updateBasicProfile)));
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 24).r,
                          child: Icon(
                            Icons.edit,
                            size: 16.sp,
                            color: AppColors.darkBlue,
                          ),
                        ),
                      )
                  ],
                ),
                SizedBox(height: 8.w),
                aboutMe.isNotEmpty
                    ? ViewMoreTextWidget(text: aboutMe)
                    : SizedBox(
                        width: 1.0.sw,
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
            ),
          ),
          const HorizontalSeparator(),
        ],
      ),
    );
  }
}
