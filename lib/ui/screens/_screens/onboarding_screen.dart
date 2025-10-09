import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/localization/index.dart';
import 'package:karmayogi_mobile/ui/widgets/_introduction/intro_one_body.dart';
import 'package:karmayogi_mobile/ui/widgets/_introduction/intro_three_body.dart';
import 'package:karmayogi_mobile/ui/widgets/_introduction/intro_two_body.dart';
import 'package:karmayogi_mobile/ui/widgets/chatbotbtn.dart';
import 'package:karmayogi_mobile/ui/widgets/index.dart';
import 'package:karmayogi_mobile/ui/widgets/language_dropdown.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../respositories/index.dart';
import '../../../util/faderoute.dart';
import '../../widgets/_introduction/featured_courses.dart';
import '../../widgets/_signup/contact_us.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _storage = FlutterSecureStorage();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isDeviceConnected = false;
  bool _isSetAlert = false;
  late InternetConnectionChecker checker;

  @override
  void initState() {
    super.initState();
    _getConnectivity();
    _getFaqData();
  }

  void _getFaqData() async {
    String? isLoggedIn = await _storage.read(key: Storage.hasFetchedFaqData);
    if (isLoggedIn == null) {
      await Provider.of<ChatbotRepository>(context, listen: false).getAlData();
    }
    await Provider.of<ChatbotRepository>(context, listen: false)
        .getFaqData(isLoggedIn: false);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _getConnectivity() async {
    checker = await InternetConnectionChecker.createInstance();
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) async {
      _isDeviceConnected = await checker.hasConnection;
      if (!_isDeviceConnected && !_isSetAlert) {
        _showDialogBox();
        setState(() {
          _isSetAlert = true;
        });
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
                  actionsPadding: EdgeInsets.zero,
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
                                    .mStaticNoConnectionDescription,
                                fontSize: 14.sp,
                                color: AppColors.appBarBackground,
                                maxLines: 3,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              Navigator.pop(contxt, EnglishLang.cancel);
                              setState(() {
                                _isSetAlert = false;
                              });
                              _isDeviceConnected = await checker.hasConnection;
                              if (!_isDeviceConnected) {
                                _showDialogBox();
                                setState(() {
                                  _isSetAlert = true;
                                });
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 4, 4, 0).r,
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
          ),
        )
      };

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    PageDecoration getPageDecoration(
            {bool contentMargin = true, titlePadding = true}) =>
        PageDecoration(
          safeArea: 0,
          pageColor: AppColors.appBarBackground,
          titleTextStyle:
              TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w700),
          bodyTextStyle: TextStyle(fontSize: 20.sp),
          contentMargin:
              contentMargin ? EdgeInsets.all(16).r : EdgeInsets.all(0).r,
          titlePadding: titlePadding
              ? EdgeInsets.only(top: 16.0, bottom: 24.0).r
              : EdgeInsets.all(0).r,
        );
    return SafeArea(
        child: Scaffold(
            body: Stack(
              children: [
                IntroductionScreen(
                  controlsPadding: EdgeInsets.all(2.0).r,
                  bodyPadding: EdgeInsets.only(bottom: 20).r,
                  globalBackgroundColor: AppColors.appBarBackground,
                  showNextButton: false,
                  pages: [
                    PageViewModel(
                        titleWidget: Padding(
                          padding: const EdgeInsets.only(top: 24).r,
                          child: Image(
                            image: AssetImage(
                                'assets/img/Karmayogi_bharat_logo_horizontal.png'),
                            height: 0.1.sh,
                            width: 0.5.sw,
                          ),
                        ),
                        bodyWidget: IntroOneBody(),
                        decoration: getPageDecoration(contentMargin: false)),
                    PageViewModel(
                        titleWidget: Center(),
                        bodyWidget: IntroTwoBody(),
                        decoration: getPageDecoration(titlePadding: false)),
                    PageViewModel(
                        titleWidget: Center(),
                        bodyWidget: IntroThreeBody(),
                        decoration: getPageDecoration(titlePadding: false)),
                  ],
                  showBackButton: false,
                  showSkipButton: false,
                  showDoneButton: false,
                  dotsDecorator: DotsDecorator(
                      color: AppColors.grey16,
                      activeColor: AppColors.primaryBlue,
                      activeSize: Size(28.w, 8.w),
                      activeShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4).r)),
                  globalFooter: SafeArea(
                    bottom: false,
                    child: Container(
                      width: double.infinity.w,
                      height: MediaQuery.of(context).orientation ==
                              Orientation.portrait
                          ? 0.07.sh
                          : (MediaQuery.of(context).size.shortestSide * 0.07).w,
                      color: AppColors.primaryBlue,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                              width: 0.44.sw,
                              padding: EdgeInsets.only(left: 16).r,
                              child: TextButton(
                                  onPressed: () async => await Navigator.push(
                                        context,
                                        FadeRoute(page: ContactUs()),
                                      ),
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .mStaticNeedHelp,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.montserrat(
                                        color: AppColors.appBarBackground,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        height: 1.375.w,
                                        letterSpacing: 0.125.w),
                                  ))),
                          Padding(
                            padding: const EdgeInsets.all(16).r,
                            child: Opacity(
                              opacity: 0.75,
                              child: VerticalDivider(
                                color: AppColors.appBarBackground,
                                width: 10.w,
                              ),
                            ),
                          ),
                          Container(
                            width: 0.44.sw,
                            padding: EdgeInsets.only(right: 16).r,
                            child: TextButton(
                              onPressed: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => FeaturedCoursesPage(),
                                  ),
                                );
                              },
                              child: Text(
                                AppLocalizations.of(context)!
                                    .mBtnFeaturedCourses,
                                style: GoogleFonts.montserrat(
                                    color: AppColors.appBarBackground,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    height: 1.375.w,
                                    letterSpacing: 0.125.w),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 16.w,
                  top: 16.h,
                  child: LanguageDropdown(
                    isHomePage: false,
                  ),
                ),
              ],
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Chatbotbtn(
              loggedInStatus: EnglishLang.NotLoggedIn,
            )));
  }
}
