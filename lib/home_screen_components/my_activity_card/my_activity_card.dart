import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/model/profile_model.dart';
import 'package:karmayogi_mobile/models/_models/user_enrollment_info_model.dart';
import 'package:karmayogi_mobile/respositories/_respositories/learn_repository.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/ui/skeleton/widgets/myacticities_card_skeleton.dart';
import 'package:karmayogi_mobile/ui/widgets/_home/home_myactivity_content_strip.dart';
import 'package:provider/provider.dart';

class MyActivityCard extends StatefulWidget {
  const MyActivityCard({super.key});

  @override
  State<MyActivityCard> createState() => _MyActivityCardState();
}

class _MyActivityCardState extends State<MyActivityCard> {
  late Future<Profile?> profileDetails;
  late Future<UserEnrollmentInfo?>? enrollmentInfo;

  Future<Profile?> getProfileDetails() async {
    Profile? profile =
        Provider.of<ProfileRepository>(context, listen: false).profileDetails;
    if (profile == null) {
      List<Profile> profileData =
          await Provider.of<ProfileRepository>(context, listen: false)
              .getProfileDetailsById('');
      if (profileData.isNotEmpty) {
        profile = profileData.first;
      }
    }
    return profile;
  }

  @override
  void initState() {
    super.initState();
    enrollmentInfo = LearnRepository().getEnrollmentSummary();
    profileDetails = getProfileDetails();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Profile?>(
        future: profileDetails,
        builder: (context, profileSnapshot) {
          if (profileSnapshot.connectionState == ConnectionState.waiting ||
              profileSnapshot.connectionState == ConnectionState.none) {
            return _buildLoadingState();
          } else if (profileSnapshot.hasData && profileSnapshot.data != null) {
            return FutureBuilder(
                future: enrollmentInfo,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      snapshot.connectionState == ConnectionState.none) {
                    return _buildLoadingState();
                  } else if (snapshot.hasData) {
                    return HomeMyactivityContentStrip(
                      enrollmentInfo: snapshot.data,
                      profileData: profileSnapshot.data!,
                    );
                  } else {
                    return SizedBox();
                  }
                });
          } else {
            return SizedBox();
          }
        });
  }

  Widget _buildLoadingState() {
    return Container(
      margin: EdgeInsets.all(8).r,
      child: MyacticitiesCardSkeleton(),
    );
  }
}
