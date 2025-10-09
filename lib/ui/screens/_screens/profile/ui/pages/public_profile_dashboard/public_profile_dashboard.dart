import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/common_components/constants/widget_constants.dart';
import 'package:karmayogi_mobile/common_components/notification_engine/notification_icon.dart';
import 'package:karmayogi_mobile/ui/network_hub/constants/network_constants.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/pages/public_profile_dashboard/repository/public_profile_dashboard_repository.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/pages/public_profile_dashboard/skeleton/public_profile_skeleton.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/pages/public_profile_dashboard/widget/public_profile_banner_section.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/pages/public_profile_dashboard/widget/public_profile_blocked_state.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/custom_profile_fields/models/org_custom_fields_data.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/custom_profile_fields/repository/custom_profile_field_repository.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/utils/profile_constants.dart';
import 'package:karmayogi_mobile/util/app_config.dart';
import 'package:karmayogi_mobile/util/telemetry_repository.dart';
import 'package:provider/provider.dart';
import '../../../../../../../constants/index.dart';
import '../../../../../../../models/index.dart';
import '../../../../../../pages/index.dart';
import '../../../../../../widgets/index.dart';
import '../../../model/extended_profile_model.dart';
import '../../../view_model/profile_dashboard_view_model.dart';
import '../../../utils/profile_tab.dart';
import '../../../view_model/profile_tab_view_model.dart';
import '../profile_tab_page.dart';

class PublicProfileDashboard extends StatefulWidget {
  final String type;
  final String userId;
  final bool showMyActivity;

  const PublicProfileDashboard(
      {super.key,
      required this.userId,
      required this.type,
      this.showMyActivity = false});
  @override
  State<PublicProfileDashboard> createState() => _PublicProfileDashboard();
}

class _PublicProfileDashboard extends State<PublicProfileDashboard>
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
    }
    fetchData();
    _generateImpressionTelemetryData();
  }

  void _initializeTabController() async {
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
    _initializeTabController();

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
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.appBarBackground,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_sharp, size: 24.sp, color: AppColors.greys60),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Spacer(),
              NotificationIcon()
            ],
          ),
        ),
        body: SafeArea(
            child: FutureBuilder(
          future: getProfileFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              Profile profile = snapshot.data!;
              return Consumer<PublicProfileDashboardRepository>(
                  builder: (context, provider, child) {
                UserConnectionStatus? userConnectionStatus =
                    provider.userConnectionStatus;

                return buildScreenBody(
                    profile: profile,
                    status:
                        userConnectionStatus ?? UserConnectionStatus.Connect);
              });
            } else {
              return _noDataWidget();
            }
          },
        )),
      ),
    );
  }

  Widget buildScreenBody({required UserConnectionStatus status, required Profile profile}) {
    switch (status) {
      case UserConnectionStatus.BlockedOutgoing:
        return PublicProfileBlockedState(
          profile: profile,
          extendedProfile: extendedProfile,
          blockMessage:
              AppLocalizations.of(context)!.mYouHaveBlockedThisProfile,
        );
      case UserConnectionStatus.BlockedIncoming:
        return PublicProfileBlockedState(
          profile: profile,
          extendedProfile: extendedProfile,
          blockMessage: AppLocalizations.of(context)!.mBlockIncomingMessage,
        );

      default:
        return _buildVisibleDetails(status: status, profile: profile);
    }
  }

  Widget _buildVisibleDetails({required UserConnectionStatus status, required Profile profile}) {
    if (profile.profilePreference == UserProfileVisibilityControls.privateAccess) {
      return _lockedProfileView(profile: profile);
    }
    return Container(
      child: ((status != UserConnectionStatus.Approved) && (profile.profilePreference == UserProfileVisibilityControls.connectionOnlyAccess))
          ? _lockedProfileView(profile: profile)
          : _buildDashboard(profile),
    );
  }

  Widget _lockedProfileView({required Profile profile}) {
    return PublicProfileBlockedState(
      profile: profile,
      extendedProfile: extendedProfile,
      blockMessage: AppLocalizations.of(context)!.mProfileLockedProfile,
      placeholderImage: ApiUrl.baseUrl + "/assets/icons/locked.svg",
      containerDecoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8).r,
      ),
      containerMargin: EdgeInsets.only(top: 16, left: 16, right: 16).r,
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
                      child: PublicProfileBannerSection(
                        profile: profile,
                        extendedProfile: extendedProfile,
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
                            indicatorColor: Colors.white,
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
    return PublicProfileDashboardSkeleton();
  }

  Future<ProfileTab?> getProfileTabs({required String type}) async {
    Profile? profile = await getProfileFuture;
    if (profile == null) return null;

    ExtendedProfile extendedProfileData = extendedProfile ??
        ProfileTabViewModel().setDefaultServiceHistory(
            orgName: profile.department,
            designation: profile.designation,
            profile: null);
    return _buildNetworkUserProfileTab(
      profile: profile,
      extendedProfileData: extendedProfileData,
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

  Future<void> updateBasicProfile() async {
    if (widget.type == ProfileConstants.currentUser) {
      await getBasicProfile();
    }
  }

  int getMyActivityIndex(List<Widget> tabBody) {
    int index = tabBody.indexWhere(
        (element) => element.runtimeType == YourActivities().runtimeType);
    return index == -1 ? 0 : index;
  }

  void _generateImpressionTelemetryData() async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getImpressionTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.network + "${widget.userId}",
        telemetryType: TelemetryType.app,
        pageUri: TelemetryPageIdentifier.network + "${widget.userId}",
        env: TelemetryEnv.network);
    await telemetryRepository.insertEvent(eventData: eventData);
  }
}
