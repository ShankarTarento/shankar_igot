import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../models/index.dart';
import '../../model/extended_profile_model.dart';
import '../../view_model/profile_tab_view_model.dart';
import '../widgets/achievements.dart';
import '../widgets/educational_qualifications.dart';
import '../widgets/horizontal_separator.dart';
import '../widgets/other_details_section.dart';
import '../widgets/primary_details_section.dart';
import '../widgets/profile_data_strip.dart';
import '../widgets/profile_about_me.dart';
import '../widgets/service_history.dart';

class ProfileTabPage extends StatefulWidget {
  final Profile profileDetails;
  final bool notMyUser;
  final bool isDesignationMasterEnabled;
  final bool isMyProfile;
  final String? userId;
  final ExtendedProfile extendedProfile;
  final VoidCallback updateBasicProfile;

  const ProfileTabPage(
      {super.key,
      required this.profileDetails,
      this.notMyUser = false,
      this.isDesignationMasterEnabled = false,
      this.isMyProfile = false,
      this.userId,
      required this.extendedProfile,
      required this.updateBasicProfile});

  @override
  State<ProfileTabPage> createState() => _ProfileTabPageState();
}

class _ProfileTabPageState extends State<ProfileTabPage> {
  Future<ExtendedProfile>? futureExtendedProfile;
  @override
  void initState() {
    super.initState();
    futureExtendedProfile = Future.value(widget.extendedProfile);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: futureExtendedProfile,
        builder: (context, snapshot) {
          return ListView(
            children: [
              if (widget.isMyProfile)
                ProfileDataStrip(
                    karmapoint: widget.profileDetails.karmaPoints,
                    certificateCount: widget.profileDetails.certificateCount,
                    postCount: widget.profileDetails.postCount),
              SizedBox(height: 8.w),
              ProfileAboutMe(
                  isMyProfile: widget.isMyProfile,
                  aboutMe:
                      widget.profileDetails.employmentDetails?['aboutme'] ?? '',
                  updateBasicProfile: widget.updateBasicProfile),
              PrimaryDetailSection(
                  notMyUser: widget.notMyUser,
                  isDesignationMasterEnabled: widget.isDesignationMasterEnabled,
                  isMyProfile: widget.isMyProfile,
                  profileDetails: widget.profileDetails),
              if (widget.isMyProfile) HorizontalSeparator(),
              if (widget.isMyProfile) OtherDetailsSection(),
              SizedBox(height: 8.w),
              ServiceHistory(
                  serviceList: snapshot.data != null
                      ? snapshot.data!.serviceHistory.data
                      : [],
                  count: snapshot.data != null
                      ? snapshot.data!.serviceHistory.count
                      : 0,
                  userId: widget.userId,
                  isMyProfile: widget.isMyProfile,
                  updateCallback: () async => await fetchData()),
              SizedBox(height: 8.w),
              EducationalQualifications(
                  educationList: snapshot.data != null
                      ? snapshot.data!.educationalQualifications.data
                      : [],
                  count: snapshot.data != null
                      ? snapshot.data!.educationalQualifications.count
                      : 0,
                  userId: widget.userId,
                  isMyProfile: widget.isMyProfile,
                  updateCallback: () async {
                    if (snapshot.data == null ||
                        (snapshot.data != null &&
                            snapshot.data!.educationalQualifications.data
                                .isEmpty)) {
                      widget.updateBasicProfile();
                    }
                    await fetchData();
                  }),
              SizedBox(height: 8.w),
              Achievements(
                  achievementList: snapshot.data != null
                      ? snapshot.data!.achievements.data
                      : [],
                  userId: widget.userId,
                  isMyProfile: widget.isMyProfile,
                  count: snapshot.data != null
                      ? snapshot.data!.achievements.count
                      : 0,
                  updateCallback: () async => await fetchData()),
              SizedBox(height: 100.w)
            ],
          );
        });
  }

  Future<void> fetchData() async {
    ExtendedProfile? profile =
        await ProfileTabViewModel().getExtendedProfileData(widget.userId);
    futureExtendedProfile = Future.value(ProfileTabViewModel()
        .setDefaultServiceHistory(
            orgName: widget.profileDetails.department,
            designation: widget.profileDetails.designation,
            profile: profile));
    if (mounted) {
      setState(() {});
    }
  }
}
