import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:animations/animations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:karmayogi_mobile/app_upgrade_strip.dart';
import 'package:karmayogi_mobile/home_screen_components/utils/home_components_helper.dart';
import 'package:karmayogi_mobile/igot_app.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/model/profile_model.dart';
import 'package:karmayogi_mobile/respositories/_respositories/tab_state_repository.dart';
import 'package:karmayogi_mobile/services/_services/smartech_service.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/custom_profile_fields/models/custom_profile_data.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/custom_profile_fields/models/org_custom_fields_data.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/custom_profile_fields/repository/custom_profile_field_repository.dart';
import 'package:karmayogi_mobile/ui/widgets/base_scaffold.dart';
import 'package:karmayogi_mobile/util/app_config.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/my_learnings/my_learning_v2.dart/my_learning_v2.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../models/_models/deeplink_model.dart';
import '../../constants/index.dart';
import '../../respositories/index.dart';
import '../../util/deeplinks/deeplink_service.dart';
import '../../util/index.dart';
import '../../util/deeplinks/smt_deeplink_service.dart';
import '../pages/index.dart';
import '../screens/_screens/_getStart/intro_get_start.dart';
import '../screens/_screens/profile/utils/profile_helper.dart';
import '../screens/index.dart';
import 'index.dart';

class CustomTabs extends StatefulWidget {
  final int customIndex;
  final String? token;
  final bool isFromSignIn;
  final int tabIndex;
  final int pillIndex;
  final int? searchCategoryIndex;

  const CustomTabs(
      {Key? key,
      this.customIndex = 0,
      this.token,
      this.isFromSignIn = false,
      this.tabIndex = 0,
      this.pillIndex = 0,
      this.searchCategoryIndex})
      : super(key: key);

  @override
  _CustomTabsState createState() => _CustomTabsState();

  static void setTabItem(BuildContext context, int index, bool callSetState,
      {int tabIndex = 0, int pillIndex = 0, bool isFromHome = false}) {
    _CustomTabsState? state =
        context.findAncestorStateOfType<_CustomTabsState>();
    state!.setTabItems(index,
        callSetState: callSetState,
        tab: tabIndex,
        pill: pillIndex,
        isFromHome: isFromHome);
  }
}

GlobalKey<ScaffoldState> drawerKey = GlobalKey();

class _CustomTabsState extends State<CustomTabs>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late StreamSubscription _connectivitySubscription;
  final _storage = FlutterSecureStorage();
  Future<void>? _getProfileDetailsFuture;
  bool _isDeviceConnected = false;
  final ValueNotifier<bool> _enableNetworkConnectivityAlert = ValueNotifier(false);
  int _currentIndex = 0, tabIndex = 0, pillIndex = 0;
  int _unSeenNotificationsCount = 0;
  TabController? _controller;
  bool _pageInitialized = false;
  List<Profile>? _profileDetails;
  bool _showGetStarted = false;
  // SpeechRecognizer _speechRecognizer;
  bool isRestrictedUser = false;
  bool isFromHomeShowAll = false;

  @override
  void initState() {
    super.initState();
    AppConfiguration.getAiChatBotConfig();
    WidgetsBinding.instance.addObserver(this);
    tabIndex = widget.tabIndex;
    _performDeepLinking();
    setDefaultStorageValues();
    _getConnectivity();
    _getAllData(isFromInitState: true);
    showSurveyPopup();
    _generateTelemetryRequiredData();
    deeplinkServiceListener();
    Provider.of<EventRepository>(context, listen: false).getEventsSummary();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TabStateRepository>(context, listen: false)
          .addListener(_onTabChange);
    });
  }

  void _onTabChange() {
    final tabProvider = Provider.of<TabStateRepository>(context, listen: false);
    setTabItems(tabProvider.customTabIndex, callSetState: true);
  }

  void deeplinkServiceListener() {
    if (Platform.isIOS) {
      SMTDeeplinkService.instance.stream.listen((event) {
        if (event) _performDeepLinking();
      });
    }
  }

  // @override
  // void didUpdateWidget(covariant CustomTabs oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   _getAllData();
  // }

  _getAllData({bool isFromInitState = false}) async {
    _getFaqData();
    if (!await ProfileHelper().isRestrictedUser()) _getGetStartedStatus();
    _setAppOpenStatus();
    _getProfileDetailsFuture = _getProfileDetails();
    _initTabController(widget.customIndex,
        callSetState: true, isFromInitState: true);
  }

  _performDeepLinking() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(seconds: 1), () async {
        final deepLinkData = await _storage.read(key: Storage.deepLinkPayload);
        if (deepLinkData != null) {
          DeepLink deepLink = DeepLink.fromJson(jsonDecode(deepLinkData));
          if (deepLink.url != null && deepLink.url!.isNotEmpty) {
            if (deepLink.category != AppUrl.customSelfRegistration) {
              await DeeplinkService().performDeepLinking(context);
            }
          }
        }
      });
    });
  }

  //to trigger platform rating on 4th click setting platform rating to default(zero)
  void setDefaultStorageValues() {
    _storage.write(key: Storage.enableRating, value: '0');
    _storage.write(
        key: Storage.showKarmaPointFirstCourseEnrolPopup, value: 'true');
  }

  _initTabController(int index,
      {bool callSetState = false, bool isFromInitState = false}) {
    _currentIndex = (index > 0) ? index : 0;
    if (isFromInitState && _getProfileDetailsFuture != null) {
      _getProfileDetailsFuture!.then((data) => setTabItems(index,
          callSetState: true, isFromInitState: isFromInitState));
    }
  }

  setTabItems(int index,
      {bool callSetState = false,
      bool isFromInitState = false,
      int tab = 0,
      int pill = 0,
      bool isFromHome = false}) {
    _controller = TabController(
        length: CustomBottomNavigation.itemsWithVegaDisabled(context: context)
            .length,
        vsync: this,
        initialIndex: index > 0 ? index : 0);
    tabIndex = tab;
    pillIndex = pill;
    isFromHomeShowAll = isFromHome;
    if (!isFromInitState) {
      _currentIndex = (index > 0) ? index : 0;
    }
    if (callSetState) {
      setState(() {});
    }
  }

  void _generateInteractTelemetryData(
      {String? contentId, String? subType}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.homePageId,
        contentId: contentId ?? "",
        subType: subType ?? "",
        env: TelemetryEnv.home);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  void _getFaqData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String? isLoggedIn = await _storage.read(key: Storage.hasFetchedFaqData);
      if (isLoggedIn == null) {
        await Provider.of<ChatbotRepository>(context, listen: false)
            .getAlData();
      }
      await Provider.of<ChatbotRepository>(context, listen: false)
          .getFaqData(isLoggedIn: true);
    });
  }

  void _setAppOpenStatus() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final isAppOpened = await _storage.read(
        key: Storage.isAppOpened,
      );
      // checking if the app launch time has stored or not. If it's not stored, need to call setAppOpenedStatus() to store current time
      final lastTriggeredTime = await _storage.read(
        key: Storage.lastTriggeredTime,
      );
      if (isAppOpened != EnglishLang.yes || lastTriggeredTime == null) {
        await Provider.of<InAppReviewRespository>(context, listen: false)
            .setAppOpenedStatus();
      }
    });
  }

  Future<dynamic> _getProfileDetails() async {
    if (!_pageInitialized) {
      try {
        _profileDetails =
            await Provider.of<ProfileRepository>(context, listen: false)
                .getProfileDetailsById('');
        if (_profileDetails!.length > 0) {
          Profile userObj = _profileDetails!.first;
          await SmartechService.checkIsNetcoreActive();
          if (widget.isFromSignIn && userObj.id.toString().isNotEmpty) {
            if (isNetcoreActive) {
              /// SMT user login
              bool _isNetcoreEnabled =
                  await Provider.of<LearnRepository>(context, listen: false)
                      .isSmartechEventEnabled(
                          eventName: SMTTrackEvents.userSignin,
                          reload: true,
                          isFunctionality: true);
              if (_isNetcoreEnabled)
                SmartechService.reportLogin(userObj.id.toString());

              /// SMT track user signed in
              bool _isTrackUserSignInEnabled =
                  await Provider.of<LearnRepository>(context, listen: false)
                      .isSmartechEventEnabled(
                          eventName: SMTTrackEvents.userSignin, reload: false);
              if (_isTrackUserSignInEnabled)
                SmartechService.trackUserSignIn(userObj);
            }
          }

          /// SMT update user Profile
          smtUpdateUserProfile(userObj);
        }
      } catch (e) {
        await Provider.of<LoginRespository>(context, listen: false)
            .doLogout(context);
        return;
      }
      // Store profile image to local Storage
      if (_profileDetails != null && _profileDetails!.isNotEmpty) {
        _storage.write(
            key: Storage.profileImageUrl,
            value: _profileDetails![0].profileImageUrl);
        await _storage.write(
            key: Storage.profileCompletionPercentage,
            value:
                _profileDetails!.first.profileCompletionPercentage.toString());
      }
      return _profileDetails;
    }
  }

  Future<void> smtUpdateUserProfile(Profile userObj) async {
    if (isNetcoreActive) {
      bool _isUpdateUserProfileEnabled =
          await Provider.of<LearnRepository>(context, listen: false)
              .isSmartechEventEnabled(
                  eventName: SMTTrackEvents.userProfilePush, reload: true);
      if (_isUpdateUserProfileEnabled) {
        try {
          SmartechService.updateUserProfile(
            userObj: userObj,
          );
        } catch (e) {
          SmartechService.updateUserProfile(userObj: userObj);
        }
      }
    }
  }

  _getConnectivity() async {
    final InternetConnectionChecker checker =
        InternetConnectionChecker.createInstance();
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) async {
      _isDeviceConnected = await checker.hasConnection;
      if (!_isDeviceConnected && !_enableNetworkConnectivityAlert.value) {
        _showDialogBox();
        _enableNetworkConnectivityAlert.value = true;
      }
    });
  }

  _showDialogBox() => {
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext contxt) => Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    AlertDialog(
                        insetPadding: EdgeInsets.symmetric(horizontal: 16).r,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12).r),
                        actionsPadding: EdgeInsets.zero.r,
                        actions: [
                          Container(
                            padding: EdgeInsets.all(16).r,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12).r,
                                color: AppColors.negativeLight),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: Container(
                                    child: TitleRegularGrey60(
                                      AppLocalizations.of(context)!
                                          .mStaticUnableToConnectInternet,
                                      fontSize: 14.sp,
                                      color: AppColors.appBarBackground,
                                      maxLines: 3,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () async {
                                    Navigator.pop(contxt, EnglishLang.cancel);
                                    _enableNetworkConnectivityAlert.value = false;
                                  },
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(16, 4, 4, 0)
                                            .r,
                                    child: Icon(
                                      Icons.replay_outlined,
                                      color: AppColors.appBarBackground,
                                      size: 24.sp,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ]),
                  ],
                ))
      };

  Future<bool> showCustomProfileFieldsPopUp() async {
    OrgCustomFieldsData? orgCustomFieldsData =
        await CustomProfileFieldRepository.getOrgDetails();
    if (orgCustomFieldsData != null &&
        orgCustomFieldsData.customFieldIds.isNotEmpty) {
      if (!orgCustomFieldsData.isPopUpEnabled) {
        return false;
      }
      List<CustomProfileData> customProfiledata =
          await CustomProfileFieldRepository().getCustomFieldData();
      for (var data in orgCustomFieldsData.customFieldIds) {
        if (!customProfiledata.any((element) {
          return data == element.customFieldId &&
              (element.value == null ||
                  element.value.toString().isEmpty ||
                  element.values == null ||
                  element.values == null ||
                  element.values!.isEmpty);
        })) {
          return true;
        }
      }
    }
    return false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _performDeepLinking();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    SMTDeeplinkService.instance.dispose();
    _connectivitySubscription.cancel();
    _enableNetworkConnectivityAlert.dispose();
    WidgetsBinding.instance.removeObserver(this);
    try {
      final context = navigatorKey.currentContext!;
      Provider.of<TabStateRepository>(context, listen: false)
          .removeListener(_onTabChange);
    } catch (e) {
      debugPrint('Error removing tab state listener: $e');
    }
    super.dispose();
  }

  showSurveyPopup() async {
    bool _showGetStarted =
        await _storage.read(key: Storage.getStarted).then((value) {
      return value != GetStarted.finished;
    });
    bool showGetStartedPopUp =
        await _storage.read(key: Storage.enableSurveyPopUp).then((value) {
      if (value == null) return false;
      return jsonDecode(value);
    });

    if (!_showGetStarted && showGetStartedPopUp) {
      HomeComponentsHelper().getSurveyPopUp(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          FutureBuilder(
              future: _getProfileDetailsFuture,
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                return Scaffold(
                  // Page content
                  body: PageTransitionSwitcher(
                      transitionBuilder: (
                        Widget child,
                        Animation<double> animation,
                        Animation<double> secondaryAnimation,
                      ) {
                        return FadeThroughTransition(
                          animation: animation,
                          secondaryAnimation: secondaryAnimation,
                          child: child,
                        );
                      },
                      duration: Duration(milliseconds: 500),
                      child: setScreen(currentIndex: _currentIndex)),

                  // Bottom navigation bar
                  bottomNavigationBar: BottomAppBar(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppUpgradeStrip(),
                        DefaultTabController(
                          length: CustomBottomNavigation.itemsWithVegaDisabled(
                                  context: context)
                              .length,
                          child: Container(
                              child: TabBar(
                                indicator: BoxDecoration(
                                  color: Color.fromRGBO(0, 0, 0, 0.04),
                                  border: Border(
                                    top: BorderSide(
                                      color: AppColors.darkBlue,
                                      width: 2.0.w,
                                    ),
                                  ),
                                ),
                                indicatorColor: Colors.transparent,
                                labelPadding: EdgeInsets.only(top: 0.0).w,
                                unselectedLabelColor: AppColors.greys60,
                                labelColor: AppColors.darkBlue,
                                labelStyle: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                      fontSize: 10.sp,
                                    ),
                                unselectedLabelStyle: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(
                                      fontSize: 10.sp,
                                    ),
                                onTap: (int index) => setState(() {
                                  _currentIndex = index;
                                  _generateInteractTelemetryData(
                                      contentId: CustomBottomNavigation
                                              .itemsWithVegaDisabled(
                                                  context: context)[index]
                                          .telemetryId,
                                      subType: TelemetrySubType.hubMenu);
                                }),
                                tabs: [
                                  for (final tabItem in (CustomBottomNavigation
                                      .itemsWithVegaDisabled(context: context)))
                                    tabItem.index == _currentIndex
                                        ? Stack(children: <Widget>[
                                            SizedBox(
                                              height: Platform.isIOS
                                                  ? 70.w
                                                  : 60.0.w,
                                              child: Container(
                                                  margin: EdgeInsets.fromLTRB(
                                                          0.0, 0.0, 0.0, 3.0)
                                                      .w,
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                    top: 8,
                                                                    bottom: 4,
                                                                    left: 8,
                                                                    right: 8)
                                                                .w,
                                                        child: SvgPicture.asset(
                                                          tabItem.svgIcon,
                                                          width: 24.0.w,
                                                          height: 24.0.w,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 60.w,
                                                        child: Text(
                                                          tabItem.title,
                                                          textAlign:
                                                              TextAlign.center,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodySmall!
                                                                  .copyWith(
                                                                    fontSize:
                                                                        10.sp,
                                                                  ),
                                                        ),
                                                      )
                                                    ],
                                                  )),
                                            ),
                                            (tabItem.index == 3 &&
                                                    _unSeenNotificationsCount >
                                                        0)
                                                ? Positioned(
                                                    // draw a red marble
                                                    top: 5,
                                                    right: 0,
                                                    child: Container(
                                                      height: 20.w,
                                                      child: CircleAvatar(
                                                          backgroundColor:
                                                              AppColors
                                                                  .negativeLight,
                                                          child: Center(
                                                            child: Text(
                                                              _unSeenNotificationsCount
                                                                  .toString(),
                                                              style: GoogleFonts.lato(
                                                                  fontSize:
                                                                      10.0.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                            ),
                                                          )),
                                                    ),
                                                  )
                                                : Positioned(
                                                    child: Text(''),
                                                  ),
                                          ])
                                        : Stack(children: <Widget>[
                                            SizedBox(
                                              height: Platform.isIOS
                                                  ? 70.w
                                                  : 60.0.w,
                                              child: Container(
                                                  margin: EdgeInsets.fromLTRB(
                                                          0.0, 0.0, 0.0, 3.0)
                                                      .r,
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                    top: 8,
                                                                    bottom: 4,
                                                                    left: 8,
                                                                    right: 8)
                                                                .r,
                                                        child: SvgPicture.asset(
                                                          tabItem
                                                              .unselectedSvgIcon,
                                                          width: 24.0.w,
                                                          height: 24.0.w,
                                                          colorFilter:
                                                              ColorFilter.mode(
                                                                  AppColors
                                                                      .greys60,
                                                                  BlendMode
                                                                      .srcIn),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 60.w,
                                                        child: Text(
                                                          tabItem.title,
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .headlineSmall!
                                                              .copyWith(
                                                                fontSize: 10.sp,
                                                              ),
                                                          textAlign:
                                                              TextAlign.center,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      )
                                                    ],
                                                  )),
                                            ),
                                            (tabItem.index == 3 &&
                                                    _unSeenNotificationsCount >
                                                        0)
                                                ? Positioned(
                                                    // draw a red marble
                                                    top: 5,
                                                    right: 0,
                                                    child: Container(
                                                      height: 20.w,
                                                      child: CircleAvatar(
                                                          backgroundColor:
                                                              AppColors
                                                                  .negativeLight,
                                                          child: Center(
                                                            child: Text(
                                                              _unSeenNotificationsCount
                                                                  .toString(),
                                                              style: GoogleFonts.lato(
                                                                  fontSize:
                                                                      10.0.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                            ),
                                                          )),
                                                    ),
                                                  )
                                                : Positioned(
                                                    child: Text(''),
                                                  ),
                                          ])
                                ],
                                controller: _controller,
                              ),
                              decoration: BoxDecoration(
                                  color: AppColors.appBarBackground,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.grey08,
                                      blurRadius: 6.0.r,
                                      spreadRadius: 0.r,
                                      offset: Offset(
                                        0,
                                        -3,
                                      ),
                                    ),
                                  ])),
                        ),
                      ],
                    ),
                  ),

                  // Drawer
                  key: drawerKey,
                  drawer: CustomDrawer(
                    profileDetails:
                        _profileDetails != null && _profileDetails!.isNotEmpty
                            ? _profileDetails!.first
                            : null,
                  ),
                );
              }),
          Consumer<LandingPageRepository>(builder: (BuildContext context,
              LandingPageRepository landingPageRepository, Widget? child) {
            if (landingPageRepository.showGetStarted) {
              if (_currentIndex > 0) {
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  setState(() {
                    _currentIndex = 0;
                    _controller!.animateTo(0);
                  });
                });
              }
            }
            return Visibility(
              visible: (landingPageRepository.showGetStarted),
              child: Positioned.fill(
                child: IntroGetStart(
                  returnCallback: _getStartReturnCallback,
                ),
              ),
            );
          }),
        ],
      ),
    ).withChatbotButton();
  }

  Future<void> _getStartReturnCallback() async {
    Provider.of<LandingPageRepository>(context, listen: false)
        .updateShowGetStarted(false);
    HomeComponentsHelper().getSurveyPopUp(context);
  }

  Future<void> _getGetStartedStatus() async {
    _showGetStarted =
        await _storage.read(key: Storage.getStarted).then((value) {
      return value != GetStarted.finished;
    });
    if(mounted) {
      Provider.of<LandingPageRepository>(context, listen: false)
          .updateShowGetStarted(_showGetStarted);
    }
  }

  updateProfile() async {
    await _getProfileDetails();
    setState(() {});
  }

  // This function is intializing the required data for the telemetry events which will be calling only once in the app launch
  void _generateTelemetryRequiredData() async {
    await TelemetryRepository().generateTelemetryRequiredData();
  }

  Widget setScreen({required int currentIndex}) {
    switch (currentIndex) {
      case 0:
        return _profileDetails != null && _profileDetails!.isNotEmpty
            ? HomeScreen(
                index: _currentIndex,
                profileInfo: _profileDetails?[0],
                profileParentAction: updateProfile,
                drawerKey: drawerKey)
            : HomeScreen(index: _currentIndex, drawerKey: drawerKey);
      case 1:
        return _profileDetails != null && _profileDetails!.isNotEmpty
            ? HubScreen(
                index: _currentIndex,
                profileInfo: _profileDetails?[0],
                profileParentAction: updateProfile,
                drawerKey: drawerKey)
            : HubScreen(index: _currentIndex, drawerKey: drawerKey);
      case 2:
        return SearchPage(categoryIndex: widget.searchCategoryIndex);
      case 3:
        isFromHomeShowAll = false;
        return MyLearningV2(
            drawerKey: drawerKey,
            profileParentAction: updateProfile,
            tabIndex: tabIndex,
            pillIndex: pillIndex);

      default:
        return Container();
    }
  }
}
