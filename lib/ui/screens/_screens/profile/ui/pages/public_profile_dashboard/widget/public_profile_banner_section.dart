import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/model/extended_profile_model.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/model/profile_model.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/pages/public_profile_dashboard/widget/public_profile_top_section.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/profile_banner.dart';

class PublicProfileBannerSection extends StatelessWidget {
  final Profile profile;
  final ExtendedProfile? extendedProfile;

  const PublicProfileBannerSection({
    super.key,
    required this.profile,
    this.extendedProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileBanner(
            bannerImage: profile.profileBannerUrl != null
                ? profile.profileBannerUrl
                : null,
            isMyProfile: false,
            updateBasicProfile: () {}),
        PublicProfileTopSection(
          userId: profile.id,
          name: profile.firstName,
          userName: profile.username ?? '',
          profileImageUrl:
              profile.profileImageUrl != null ? profile.profileImageUrl : null,
          profileStatus: profile.profileStatus,
          designation: profile.designation,
          department: profile.department,
          state: extendedProfile != null &&
                  extendedProfile!.locationDetails.data.isNotEmpty
              ? extendedProfile!.locationDetails.data.first.state
              : '',
          district: extendedProfile != null &&
                  extendedProfile!.locationDetails.data.isNotEmpty
              ? extendedProfile!.locationDetails.data.first.district
              : '',
          roles: (profile.roles != null)
              ? List<String>.from(profile.roles!)
              : <String>[],
          isMyProfile: false,
        )
      ],
    );
  }
}
