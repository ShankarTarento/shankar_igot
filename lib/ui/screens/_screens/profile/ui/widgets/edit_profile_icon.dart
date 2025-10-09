import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:provider/provider.dart';
import '../../../../../../models/index.dart';
import '../../../../../../respositories/_respositories/settings_repository.dart';
import '../../../../../../respositories/index.dart';
import '../../view_model/profile_top_section_view_model.dart';
import 'arc_painter.dart';
import 'profile_image_widget.dart';

class EditProfileIcon extends StatefulWidget {
  final BuildContext parentContext;
  final String profileImageUrl;
  final String firstName;
  final String surname;
  final bool isMyProfile;
  EditProfileIcon(
      {Key? key,
      required this.parentContext,
      this.profileImageUrl = '',
      this.firstName = '',
      this.surname = '',
      this.isMyProfile = false})
      : super(key: key);

  @override
  State<EditProfileIcon> createState() => _EditProfileIconState();
}

class _EditProfileIconState extends State<EditProfileIcon> {
  ValueNotifier<MemoryImage?> selectedImage = ValueNotifier(null);
  bool isTablet = false;

  @override
  void initState() {
    super.initState();
    isTablet =
        Provider.of<SettingsRepository>(context, listen: false).itsTablet;
  }

  @override
  Widget build(BuildContext context) {
    return Selector<ProfileRepository, Profile?>(
        selector: (context, profile) => profile.profileDetails,
        builder: (context, profileDetails, child) {
          return Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            // Arc and circular image together
            CustomPaint(
              painter: widget.isMyProfile
                  ? ArcPainter(
                      percentage: profileDetails != null
                          ? profileDetails.profileCompletionPercentage
                          : 0)
                  : null,
              child: Container(
                padding: EdgeInsets.all(4.r),
                width: isTablet ? 0.15.sw : 0.2.sw,
                height: isTablet ? 0.15.sw : 0.2.sw,
                child: ClipOval(
                  child: _getImageWidget(widget.isMyProfile
                      ? profileDetails != null
                          ? (profileDetails.profileImageUrl != null
                              ? profileDetails.profileImageUrl!
                              : '')
                          : ''
                      : widget.profileImageUrl),
                ),
              ),
            ),

            // Bottom 50% container
            if (widget.isMyProfile)
              Positioned(
                bottom: isTablet ? -20.r : -10.r,
                child: Container(
                  width: isTablet ? 70.w : 50.w,
                  height: isTablet ? 40.r : 30.r,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.appBarBackground,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '${ProfileTopSectionViewModel().formatDouble(profileDetails != null ? profileDetails.profileCompletionPercentage : 0)}%',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge!
                        .copyWith(color: AppColors.darkBlue),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _getImageWidget(String profileImageUrl) {
    return ValueListenableBuilder(
        valueListenable: selectedImage,
        builder: (BuildContext context, MemoryImage? image, Widget? child) {
          return ProfileImageWidget(
              image: image,
              profileImageUrl: profileImageUrl,
              firstName: widget.firstName,
              surname: widget.surname);
        });
  }
}
