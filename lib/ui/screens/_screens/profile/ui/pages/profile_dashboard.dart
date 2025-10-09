import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/common_components/constants/widget_constants.dart';
import 'package:karmayogi_mobile/ui/network_hub/constants/network_constants.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/custom_profile_fields/custom_profile_field.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/custom_profile_fields/models/org_custom_fields_data.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/custom_profile_fields/repository/custom_profile_field_repository.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/profile_top_section.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/utils/profile_constants.dart';
import 'package:karmayogi_mobile/util/app_config.dart';
import '../../../../../../constants/index.dart';
import '../../../../../../models/index.dart';
import '../../../../../pages/index.dart';
import '../../../../../widgets/_common/alert_display_card.dart';
import '../../../../../widgets/index.dart';
import '../../model/extended_profile_model.dart';
import '../../model/profile_top_section_model.dart';
import '../../view_model/profile_dashboard_view_model.dart';
import '../../utils/profile_tab.dart';
import '../../view_model/profile_tab_view_model.dart';
import '../skeleton/profile_dashboard_skeleton.dart';
import '../widgets/profile_appbar.dart';
import '../widgets/profile_banner.dart';
import 'profile_tab_page.dart';

class ProfileDashboard extends StatefulWidget {
  final String type;
  final String? userId;
  final profileParentAction;
  final UserConnectionStatus? connectionStatus;
  final Function(bool)? connectCallBack;
  final bool showMyActivity;

  const ProfileDashboard(
      {super.key,
      this.userId,
      required this.type,
      this.profileParentAction,
      this.connectionStatus,
      this.connectCallBack,
      this.showMyActivity = false});
  @override
  State<ProfileDashboard> createState() => _ProfileDashboardState();
}

class _ProfileDashboardState extends State<ProfileDashboard>
    with SingleTickerProviderStateMixin {
  final ScrollController dashboardScrollController = ScrollController();
  ScrollController _myActivityScrollController = ScrollController();
  Future<Profile?>? getProfileFuture;
  ExtendedProfile? extendedProfile;
  TabController? tabController;
  bool isDesignationMasterEnabled = false;
  Future<ProfileTab?>? profileTabFuture;
  ProfileDashboardViewModel profileDashboardViewModel =
      ProfileDashboardViewModel();

  @override
  void initState() {
    super.initState();
    if (widget.type == ProfileConstants.currentUser) {
      checkHomeConfig();
      if (widget.showMyActivity) {
        setupMyActivityScroll();
      }
      profileDashboardViewModel.generateTelemetryData();
    }
    fetchData();
  }

  Future<void> _initializeTabController() async {
    ProfileTab? tabItem = await getProfileTabs(type: widget.type);
    profileTabFuture = Future.value(tabItem);
    if (tabItem != null) {
      tabController = TabController(
        length: tabItem.tabBody.length,
        vsync: this,
        initialIndex:
            widget.showMyActivity ? getMyActivityIndex(tabItem.tabBody) : 0,
      );
    }
  }

  void setupMyActivityScroll() {
    if (widget.type == ProfileConstants.currentUser) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        waitForScrollAttachmentAndScroll();
      });
    }
  }

  void waitForScrollAttachmentAndScroll() async {
    while (!_myActivityScrollController.hasClients) {
      await Future.delayed(Duration(milliseconds: 50));
    }
    _myActivityScrollController.animateTo(
        (_myActivityScrollController.position.maxScrollExtent),
        duration: Duration(seconds: 1),
        curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    dashboardScrollController.dispose();
    _myActivityScrollController.dispose();
    tabController?.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    await CustomProfileFieldRepository.getOrgDetails();

    await getBasicProfile();
    await profileDashboardViewModel.getProfileInReviewFields();
    await getExtendedProfile();
    await _initializeTabController();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> getExtendedProfile() async {
    extendedProfile =
        await ProfileTabViewModel().getExtendedProfileData(widget.userId);
  }

  Future<void> getBasicProfile() async {
    Profile? profile = await profileDashboardViewModel.getProfileDetails(
        widget.userId, context);
    getProfileFuture = Future.value(profile);
  }

  Future<void> checkHomeConfig() async {
    Map<String, dynamic>? homeconfig = AppConfiguration.homeConfigData;
    Map? data;
    if (homeconfig != null) {
      for (var e in homeconfig['data']) {
        if (e['type'] == WidgetConstants.updateDesignation) {
          data = e;
        }
      }
    }
    isDesignationMasterEnabled =
        data != null && data['enabled'] != null ? data['enabled'] : false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (widget.type == ProfileConstants.notMyUser ||
            widget.type == ProfileConstants.customProfileTab) {
          SystemNavigator.pop();
        } else {
          if (!didPop) {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.whiteGradientOne,
        body: SafeArea(
            child: FutureBuilder(
          future: getProfileFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              Profile profile = snapshot.data!;
              return _buildDashboard(profile);
            } else {
              return _noDataWidget();
            }
          },
        )),
      ),
    );
  }

  Widget _buildDashboard(Profile profile) {
    return FutureBuilder<ProfileTab?>(
        future: profileTabFuture,
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            ProfileTab? profileTab = snapshot.data;
            return DefaultTabController(
              length: profileTab!.tabTitles.length,
              child: NestedScrollView(
                controller: _myActivityScrollController,
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProfileAppbar(
                            name: profile.firstName,
                            userId: profile.id ?? '',
                            state: (extendedProfile
                                        ?.locationDetails.data.isNotEmpty ??
                                    false)
                                ? extendedProfile!
                                    .locationDetails.data.first.state
                                : '',
                            district: (extendedProfile
                                        ?.locationDetails.data.isNotEmpty ??
                                    false)
                                ? extendedProfile!
                                    .locationDetails.data.first.district
                                : '',
                            uuid: (extendedProfile
                                        ?.locationDetails.data.isNotEmpty ??
                                    false)
                                ? extendedProfile!
                                    .locationDetails.data.first.uuid
                                : '',
                            isDesignationMasterEnabled:
                                isDesignationMasterEnabled,
                            isMyProfile:
                                widget.type != ProfileConstants.networkUser,
                            notMyUser:
                                widget.type == ProfileConstants.notMyUser,
                            onUpdateCallback:
                                (ProfileTopSectionModel response) async {
                              if (response.firstName.isNotEmpty ||
                                  response.profileImageUrl.isNotEmpty) {
                                await getBasicProfile();
                                await profileDashboardViewModel
                                    .getProfileInReviewFields();
                              }
                              if (response.state.isNotEmpty ||
                                  response.district.isNotEmpty) {
                                await getExtendedProfile();
                              }
                              if (mounted) {
                                setState(() {});
                              }
                            },
                          ),
                          ProfileBanner(
                              bannerImage: profile.profileBannerUrl != null
                                  ? profile.profileBannerUrl
                                  : null,
                              isMyProfile:
                                  widget.type != ProfileConstants.networkUser,
                              updateBasicProfile: updateBasicProfile),
                          ProfileTopSection(
                              userId: profile.id,
                              name: profile.firstName,
                              userName: profile.username ?? '',
                              profileImageUrl: profile.profileImageUrl != null
                                  ? profile.profileImageUrl
                                  : null,
                              profileStatus: profile.profileStatus,
                              designation: profile.designation,
                              department: profile.department,
                              state: extendedProfile != null &&
                                      extendedProfile!
                                          .locationDetails.data.isNotEmpty
                                  ? extendedProfile!
                                      .locationDetails.data.first.state
                                  : '',
                              district: extendedProfile != null &&
                                      extendedProfile!
                                          .locationDetails.data.isNotEmpty
                                  ? extendedProfile!
                                      .locationDetails.data.first.district
                                  : '',
                              uuid: extendedProfile != null &&
                                      extendedProfile!
                                          .locationDetails.data.isNotEmpty
                                  ? extendedProfile!
                                      .locationDetails.data.first.uuid
                                  : '',
                              roles: (profile.roles != null)
                                  ? List<String>.from(profile.roles!)
                                  : <String>[],
                              isMyProfile:
                                  widget.type != ProfileConstants.networkUser,
                              connectionStatus: widget.connectionStatus,
                              connectCallBack: widget.connectCallBack,
                              updateCallback: () async {
                                await getExtendedProfile();
                                if (mounted) {
                                  setState(() {});
                                }
                              },
                              updateBasicProfile: updateBasicProfile),
                          if (widget.type == ProfileConstants.notMyUser)
                            notMyUserCard(),
                          if (widget.type == ProfileConstants.customProfileTab)
                            customProfileTabMessage(),
                        ],
                      ),
                    ),
                    SliverPersistentHeader(
                        pinned: true,
                        floating: false,
                        delegate: SilverAppBarDelegate(TabBar(
                            tabAlignment: TabAlignment.start,
                            isScrollable: true,
                            indicator: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: AppColors.darkBlue,
                                  width: 2.0,
                                ),
                              ),
                            ),
                            indicatorColor: AppColors.appBarBackground,
                            labelPadding: EdgeInsets.only(top: 0.0).r,
                            unselectedLabelColor: AppColors.greys60,
                            labelColor: AppColors.darkBlue,
                            labelStyle:
                                Theme.of(context).textTheme.displayLarge,
                            unselectedLabelStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(color: AppColors.greys60),
                            controller: tabController,
                            tabs: profileTab.tabTitles
                                .map((tabItem) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                              horizontal: 16)
                                          .r,
                                      child: Tab(
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0).r,
                                          child: Text(tabItem),
                                        ),
                                      ),
                                    ))
                                .toList())))
                  ];
                },
                body: TabBarView(
                    controller: tabController, children: profileTab.tabBody),
              ),
            );
          } else {
            return _noDataWidget();
          }
        });
  }

  Widget _noDataWidget() {
    return ProfileDashboardSkeleton(
      notMyUser: widget.type == ProfileConstants.notMyUser,
      isMyProfile: widget.type == ProfileConstants.currentUser,
    );
  }

  Widget notMyUserCard() {
    return Container(
      color: AppColors.appBarBackground,
      padding: EdgeInsets.only(bottom: 8).w,
      child: AlertDisplayCard(
          message: AppLocalizations.of(context)!.mNotMyUserAlertMsg),
    );
  }

  Future<void> updateBasicProfile() async {
    if (widget.type == ProfileConstants.currentUser) {
      await getBasicProfile();
    }
  }

  Widget customProfileTabMessage() {
    return Container(
      color: AppColors.appBarBackground,
      padding: EdgeInsets.only(bottom: 8).w,
      child: AlertDisplayCard(
          message: AppLocalizations.of(context)!.mOrgDetailsWarningMessage),
    );
  }

  Future<ProfileTab?> getProfileTabs({required String type}) async {
    Profile? profile = await getProfileFuture;
    if (profile == null) return null;

    ExtendedProfile extendedProfileData = extendedProfile ??
        ProfileTabViewModel().setDefaultServiceHistory(
            orgName: profile.department,
            designation: profile.designation,
            profile: null);

    switch (type) {
      case ProfileConstants.currentUser:
        bool showCustomProfileFields = await checkCustomProfileFields();
        return showCustomProfileFields
            ? _buildCurrentUserProfileTabWithOrgSpecificDetails(
                profile: profile,
                extendedProfileData: extendedProfileData,
              )
            : _buildCurrentUserProfileTab(
                profile: profile,
                extendedProfileData: extendedProfileData,
              );
      case ProfileConstants.notMyUser:
        return _buildNotMyUserProfileTab(
          profile: profile,
          extendedProfileData: extendedProfileData,
        );
      case ProfileConstants.customProfileTab:
        return _buildCustomProfileTab();
      case ProfileConstants.networkUser:
        return _buildNetworkUserProfileTab(
          profile: profile,
          extendedProfileData: extendedProfileData,
        );
      default:
        throw Exception("Invalid type provided");
    }
  }

  ProfileTab _buildCurrentUserProfileTab({
    required Profile profile,
    required ExtendedProfile extendedProfileData,
  }) {
    return ProfileTab(
      tabBody: [
        ProfileTabPage(
            profileDetails: profile,
            notMyUser: widget.type == ProfileConstants.notMyUser,
            isDesignationMasterEnabled: isDesignationMasterEnabled,
            userId: widget.userId,
            isMyProfile: widget.type != ProfileConstants.networkUser,
            extendedProfile: extendedProfileData,
            updateBasicProfile: updateBasicProfile),
        YourActivities(),
      ],
      tabTitles: [
        AppLocalizations.of(context)!.mStaticProfile,
        AppLocalizations.of(context)!.mStaticMyActivities,
      ],
    );
  }

  ProfileTab _buildCurrentUserProfileTabWithOrgSpecificDetails({
    required Profile profile,
    required ExtendedProfile extendedProfileData,
  }) {
    return ProfileTab(
      tabBody: [
        ProfileTabPage(
          profileDetails: profile,
          notMyUser: widget.type == ProfileConstants.notMyUser,
          isDesignationMasterEnabled: isDesignationMasterEnabled,
          userId: widget.userId,
          isMyProfile: widget.type != ProfileConstants.networkUser,
          extendedProfile: extendedProfileData,
          updateBasicProfile: () => updateBasicProfile,
        ),
        YourActivities(),
        Padding(
          padding: const EdgeInsets.only(top: 24.0),
          child: CustomProfileField(
            type: widget.type,
          ),
        ),
      ],
      tabTitles: [
        AppLocalizations.of(context)!.mStaticProfile,
        AppLocalizations.of(context)!.mStaticMyActivities,
        AppLocalizations.of(context)!.mOrgSpecificDetails,
      ],
    );
  }

  ProfileTab _buildNotMyUserProfileTab(
      {required Profile profile,
      required ExtendedProfile extendedProfileData}) {
    return ProfileTab(
      tabBody: [
        ProfileTabPage(
            profileDetails: profile,
            notMyUser: widget.type == ProfileConstants.notMyUser,
            isDesignationMasterEnabled: isDesignationMasterEnabled,
            userId: widget.userId,
            isMyProfile: widget.type != ProfileConstants.networkUser,
            extendedProfile: extendedProfileData,
            updateBasicProfile: updateBasicProfile),
      ],
      tabTitles: [
        AppLocalizations.of(context)!.mStaticProfile,
      ],
    );
  }

  ProfileTab _buildCustomProfileTab() {
    return ProfileTab(
      tabBody: [
        Padding(
          padding: const EdgeInsets.only(top: 24.0),
          child: CustomProfileField(
            type: widget.type,
          ),
        ),
      ],
      tabTitles: [
        AppLocalizations.of(context)!.mOrgSpecificDetails,
      ],
    );
  }

  ProfileTab _buildNetworkUserProfileTab(
      {required Profile profile,
      required ExtendedProfile extendedProfileData}) {
    return ProfileTab(
      tabTitles: [
        AppLocalizations.of(context)!.mStaticProfile,
      ],
      tabBody: [
        ProfileTabPage(
            profileDetails: profile,
            notMyUser: widget.type == ProfileConstants.notMyUser,
            isDesignationMasterEnabled: isDesignationMasterEnabled,
            userId: widget.userId,
            isMyProfile: widget.type != ProfileConstants.networkUser,
            extendedProfile: extendedProfileData,
            updateBasicProfile: updateBasicProfile),
      ],
    );
  }

  Future<bool> checkCustomProfileFields() async {
    try {
      OrgCustomFieldsData? orgCustomFieldsData =
          await CustomProfileFieldRepository.getOrgDetails();
      if (orgCustomFieldsData != null &&
          orgCustomFieldsData.customFieldIds.isNotEmpty) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  int getMyActivityIndex(List<Widget> tabBody) {
    int index = tabBody.indexWhere(
        (element) => element.runtimeType == YourActivities().runtimeType);
    return index == -1 ? 0 : index;
  }
}
