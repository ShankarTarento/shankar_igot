import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';
import 'package:karmayogi_mobile/constants/_constants/api_endpoints.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/ui/network_hub/constants/network_constants.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/model/connection_relationship_model.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/model/profile_top_section_model.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/pages/edit_profile_top_section.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/edit_profile_icon.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/view_model/profile_dashboard_view_model.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/view_model/profile_top_section_view_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/pills_button_widget.dart';
import 'package:karmayogi_mobile/util/app_config.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:karmayogi_mobile/util/in_app_webview_page.dart';
import 'package:karmayogi_mobile/util/telemetry_repository.dart';

class ProfileTopSection extends StatefulWidget {
  final String? userId;
  final String name;
  final String userName;
  final String state;
  final String district;
  final String? profileImageUrl;
  final String? designation;
  final String? department;
  final String? profileStatus;
  final String? uuid;
  final List<String> roles;
  final bool isMyProfile;
  final VoidCallback updateCallback;
  final UserConnectionStatus? connectionStatus;
  final Function(bool)? connectCallBack;
  final VoidCallback updateBasicProfile;

  ProfileTopSection(
      {super.key,
      required this.userId,
      required this.name,
      required this.userName,
      required this.state,
      required this.district,
      this.profileImageUrl,
      this.designation,
      this.department,
      this.profileStatus,
      this.uuid,
      this.roles = const [],
      this.isMyProfile = true,
      required this.updateCallback,
      this.connectionStatus,
      this.connectCallBack,
      required this.updateBasicProfile});

  @override
  State<ProfileTopSection> createState() => _ProfileTopSectionState();
}

class _ProfileTopSectionState extends State<ProfileTopSection> {
  String? profileImageUrl;
  String name = '';
  String state = '';
  String district = '';
  ValueNotifier<bool> _isConnecting = ValueNotifier(false);
  ValueNotifier<UserConnectionStatus> _connectionStatus =
      ValueNotifier(UserConnectionStatus.Connect);
  Future<ConnectionRelationshipModel?>? connectionRelationFuture;

  @override
  void initState() {
    super.initState();
    name = widget.name;
    profileImageUrl = widget.profileImageUrl;
    state = widget.state;
    district = widget.district;
    if (!widget.isMyProfile) {
      connectionRelationFuture = Future.value(getConnectionRelationship());
    }
  }

  Future<ConnectionRelationshipModel?>? getConnectionRelationship() async {
    ConnectionRelationshipModel? connectionRelationshipModel =
        await ProfileDashboardViewModel()
            .getConnectionRelationship(widget.userId);
    return connectionRelationshipModel;
  }

  @override
  didUpdateWidget(ProfileTopSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.name != widget.name) {
      name = widget.name;
    }
    if (oldWidget.state != widget.state) {
      state = widget.state;
    }
    if (oldWidget.district != widget.district) {
      district = widget.district;
    }
    if (oldWidget.profileImageUrl != widget.profileImageUrl) {
      profileImageUrl = widget.profileImageUrl;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: !widget.isMyProfile
          ? null
          : () async {
              showModalBottomSheet(
                context: context,
                backgroundColor: AppColors.appBarBackground,
                isScrollControlled: true,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: AppColors.grey08),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ).r,
                ),
                builder: (context) {
                  return Container(
                    height: 0.85.sh,
                    child: EditProfileTopSection(
                        firstName: name,
                        state: state,
                        district: district,
                        uuid: widget.uuid,
                        onUpdateCallback:
                            (ProfileTopSectionModel updatedProfile) {
                          name = updatedProfile.firstName.isNotEmpty
                              ? updatedProfile.firstName
                              : name;
                          state = updatedProfile.state.isNotEmpty
                              ? updatedProfile.state
                              : state;
                          district = updatedProfile.district.isNotEmpty
                              ? updatedProfile.district
                              : district;

                          if (((profileImageUrl == null ||
                                      profileImageUrl!.isEmpty) &&
                                  updatedProfile.profileImageUrl.isNotEmpty) ||
                              (profileImageUrl != null &&
                                  profileImageUrl!.isNotEmpty &&
                                  updatedProfile.profileImageUrl.isEmpty) ||
                              (state.isNotEmpty && widget.state.isEmpty) ||
                              (state.isEmpty && widget.state.isNotEmpty) ||
                              (district.isNotEmpty &&
                                  widget.district.isEmpty) ||
                              (district.isEmpty &&
                                  widget.district.isNotEmpty)) {
                            widget.updateBasicProfile();
                          }
                          profileImageUrl =
                              updatedProfile.profileImageUrl.isNotEmpty
                                  ? updatedProfile.profileImageUrl
                                  : profileImageUrl;
                          if (updatedProfile.state.isNotEmpty ||
                              updatedProfile.district.isNotEmpty) {
                            widget.updateCallback();
                          }
                          if (mounted) {
                            setState(() {});
                          }
                        }),
                  );
                },
              );
            },
      child: Container(
        color: AppColors.appBarBackground,
        padding: EdgeInsets.only(top: 16, left: 16, right: 16).r,
        child: Column(children: [
          Row(children: [
            EditProfileIcon(
                parentContext: context,
                profileImageUrl: profileImageUrl ?? '',
                firstName: name,
                isMyProfile: widget.isMyProfile),
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserNameWidget(context, firstName: name),
                SizedBox(height: 4.w),
                TextWidget(
                    context,
                    ProfileTopSectionViewModel().formatDesignationAndDepartment(
                        designation: widget.designation ?? '',
                        department: widget.department ?? '')),
                SizedBox(height: 4.w),
                state.isEmpty && district.isEmpty
                    ? Center()
                    : TextWidget(context,
                        '$state${state.isNotEmpty && district.isNotEmpty ? ',' : ''} $district'),
                // Mentor tag should be dispalyed if the user has the mentor role
                Visibility(
                  visible: (AppConfiguration.mentorshipEnabled) &&
                      widget.roles.isNotEmpty &&
                      widget.roles.contains(Roles.mentor.toUpperCase()),
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          FadeRoute(
                              page: InAppWebViewPage(
                                  parentContext: context,
                                  url: ApiUrl.mentorshipUrl)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkBlue,
                        minimumSize: Size(0, 25.w),
                      ),
                      child: Text(
                          AppLocalizations.of(context)!
                              .mProfileViewMyMentorProfile,
                          style: Theme.of(context).textTheme.labelSmall)),
                )
              ],
            )
          ]),
          SizedBox(height: 8.w),
          if (!widget.isMyProfile) _connectButton()
        ]),
      ),
    );
  }

  Widget UserNameWidget(BuildContext context, {required String firstName}) {
    return SizedBox(
      width: 0.67.sw,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              Helper.capitalizeFirstLetter(firstName).trim(),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(color: AppColors.deepBlue),
            ),
          ),
          if (widget.profileStatus == UserProfileStatus.verified)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0).r,
              child: Icon(
                Icons.check_circle,
                size: 20.sp,
                color: AppColors.positiveLight,
              ),
            ),
          if (widget.userName.isNotEmpty)
            Expanded(
              child: Text(
                ' (${widget.userName})',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(color: AppColors.greys60),
              ),
            ),
        ],
      ),
    );
  }

  SizedBox TextWidget(BuildContext context, String text) {
    return SizedBox(
      width: 0.65.sw,
      child: Text(text,
          style: Theme.of(context)
              .textTheme
              .labelMedium!
              .copyWith(color: AppColors.greys60)),
    );
  }

  Widget _connectButton() {
    return FutureBuilder(
      future: connectionRelationFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          final status = snapshot.data?.status;
          if (status?.isNotEmpty == true) {
            _connectionStatus.value = _getConnectionStatusFromString(status!);
          } else if (widget.connectionStatus != null) {
            _connectionStatus.value = widget.connectionStatus!;
          }
          return ValueListenableBuilder(
              valueListenable: _connectionStatus,
              builder: (BuildContext context,
                  UserConnectionStatus userConnectionStatus, Widget? child) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8).w,
                  child: PillsButtonWidget(
                    title: getConnectionButtonTitle(userConnectionStatus),
                    onTap: () {
                      switch (userConnectionStatus) {
                        case UserConnectionStatus.Connect:
                          return _createConnectionRequest();
                        case UserConnectionStatus.Pending:
                          return;
                        case UserConnectionStatus.Approved:
                          return;
                        default:
                      }
                    },
                    decoration: BoxDecoration(
                        border: Border.all(color: AppColors.darkBlue),
                        borderRadius:
                            BorderRadius.all(const Radius.circular(50.0).r),
                        color: (userConnectionStatus ==
                                UserConnectionStatus.Approved)
                            ? AppColors.darkBlue
                            : Color.fromRGBO(232, 237, 245, 1)),
                    textColor:
                        (userConnectionStatus == UserConnectionStatus.Approved)
                            ? AppColors.appBarBackground
                            : AppColors.darkBlue,
                    textFontSize: 14.sp,
                    isLoading: _isConnecting,
                    isLightTheme:
                        (userConnectionStatus == UserConnectionStatus.Approved)
                            ? false
                            : true,
                    prefix: getConnectionButtonThumb(userConnectionStatus),
                  ),
                );
              });
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8).w,
            child: ContainerSkeleton(
              width: 1.sw,
              height: 40.w,
              radius: 50.r,
            ),
          );
        }
      },
    );
  }

  UserConnectionStatus _getConnectionStatusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return UserConnectionStatus.Pending;
      case 'approved':
        return UserConnectionStatus.Approved;
      case 'rejected':
        return UserConnectionStatus.Connect;
      default:
        return UserConnectionStatus.Connect;
    }
  }

  void _createConnectionRequest() async {
    try {
      _isConnecting.value = true;
      _generateInteractTelemetryData();
      bool createConnectionRequest = await ProfileTopSectionViewModel()
          .createConnectionRequest(
              context: context,
              connectionId: widget.userId ?? '',
              userNameTo: widget.name,
              userDepartmentTo: widget.department ?? '');
      _isConnecting.value = false;
      if (createConnectionRequest) {
        _connectionStatus.value = UserConnectionStatus.Pending;
        if (widget.connectCallBack != null) {
          widget.connectCallBack!(true);
        }
      }
    } catch (_) {
      _isConnecting.value = false;
    }
  }

  Widget getConnectionButtonThumb(UserConnectionStatus userConnectionStatus) {
    return ProfileTopSectionViewModel()
            .connectionThumbMap[userConnectionStatus]
            ?.call() ??
        Icon(
          Icons.person_add_alt_1_rounded,
          color: AppColors.darkBlue,
          size: 16.sp,
        );
  }

  String getConnectionButtonTitle(UserConnectionStatus userConnectionStatus) {
    final localization = AppLocalizations.of(context)!;

    final Map<UserConnectionStatus, String Function()> _connectionTitleMap = {
      UserConnectionStatus.Connect: () => localization.mStaticConnect,
      UserConnectionStatus.Pending: () => localization.mProfilePending,
      UserConnectionStatus.Approved: () => localization.mStaticConnected,
    };

    return _connectionTitleMap[userConnectionStatus]?.call() ??
        localization.mStaticConnect;
  }
  
  void _generateInteractTelemetryData() async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.userProfilePageId,
        contentId: widget.userId ?? '',
        subType: TelemetrySubType.click,
        env: TelemetryEnv.network,
        objectType: TelemetryObjectType.user);
    await telemetryRepository.insertEvent(eventData: eventData);
  }
}
