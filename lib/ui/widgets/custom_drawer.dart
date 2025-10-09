import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/model/profile_model.dart';
import 'package:karmayogi_mobile/respositories/index.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/profile_picture.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/utils/profile_constants.dart';
import 'package:karmayogi_mobile/ui/widgets/_tips_for_learning/repository/tips_repository.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:karmayogi_mobile/util/load_webview_page.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../util/telemetry_repository.dart';
import '../screens/_screens/profile/model/profile_dashboard_arg_model.dart';
import '_tips_for_learning/pages/view_all_tips.dart';

class CustomDrawer extends StatefulWidget {
  final String? title;
  final Profile? profileDetails;

  CustomDrawer({Key? key, this.title, this.profileDetails}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  void initState() {
    super.initState();
    _generateImpressionTelemetryData();
  }

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[
      SizedBox(height: 40.w),
      _userProfileWidget(),
      MenuDivider(applyIndent: false),
      InkWell(
        onTap: () async {
          _generateInteractTelemetryData(TelemetryConstants.shareApplication);
          await SharePlus.instance.share(ShareParams(
              text: Platform.isAndroid ? ApiUrl.androidUrl : ApiUrl.iOSUrl));
        },
        child: _getMenu(
            text: AppLocalizations.of(context)!.mSettingShareApplication,
            icon: Icons.share),
      ),
      MenuDivider(),
      InkWell(
        onTap: () async {
          _generateInteractTelemetryData(
            TelemetryIdentifier.getStarted,
          );
          Navigator.of(context).pop();
          Provider.of<LandingPageRepository>(context, listen: false)
              .updateShowGetStarted(true);
        },
        child: _getMenu(
            text: AppLocalizations.of(context)!.mStaticKarmayogiTour,
            icon: Icons.play_circle),
      ),
      MenuDivider(),
      InkWell(
        onTap: () async {
          Navigator.push(
              context,
              FadeRoute(
                page: ViewAllTips(
                  tips: TipsRepository.getTips(),
                ),
              ));
        },
        child: _getMenu(
            text: AppLocalizations.of(context)!.mTipsForLearners,
            icon: Icons.menu_book),
      ),
      MenuDivider(),
      InkWell(
        onTap: () {
          _generateInteractTelemetryData(TelemetryIdentifier.rateNow);
          final InAppReview inAppReview = InAppReview.instance;
          inAppReview.openStoreListing(appStoreId: APP_STORE_ID);
          Navigator.of(context).pop();
        },
        child: _getMenu(
            text: AppLocalizations.of(context)!.mCustomDrawerRateUs,
            icon: Icons.star),
      ),
      // if (isNetcoreActive)
      //    MenuDivider(applyIndent: true,),
      // if (isNetcoreActive)
      //   InkWell(
      //     onTap: () async {
      //       Navigator.push(
      //           context,
      //           FadeRoute(
      //             page: SMTAppInboxScreen(),
      //           ));
      //     },
      //     child:
      //         _getMenu(text: 'App inbox', icon: Icons.notification_important),
      //   ),
      //Privacy Policy
      MenuDivider(),
      InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LoadWebViewPage(
              title: AppLocalizations.of(context)!.mStaticPrivacyPolicy,
              url: ApiUrl.baseUrl + ApiUrl.privacyPolicy,
            ),
          ),
        ),
        child: _getMenu(
            text: AppLocalizations.of(context)!.mStaticPrivacyPolicy,
            icon: Icons.privacy_tip_outlined),
      ),
      MenuDivider(),
      InkWell(
        onTap: () async {
          Navigator.pushNamed(context,
              AppUrl.settingsPage
          );
        },
        child: _getMenu(
          text: AppLocalizations.of(context)!.mStaticSettings,
          icon: Icons.settings,
        ),
      ),
      MenuDivider(),
      InkWell(
        onTap: () {
          _generateInteractTelemetryData(TelemetryConstants.signout);
          _onSignOutPressed(context);
        },
        child: _getMenu(
          text: AppLocalizations.of(context)!.mSettingSignOut,
          svgPath: 'assets/img/logout.svg',
        ),
      ),
      MenuDivider(),
    ];
    return Stack(children: [
      Drawer(
        width: 0.7.sw,
        child: ListView(padding: EdgeInsets.zero, children: children),
      ),
      Positioned(
        bottom: 20,
        left: 30,
        child: Text(
          'v' + APP_VERSION,
          style: GoogleFonts.lato(
              color: AppColors.greys60,
              fontWeight: FontWeight.w400,
              fontSize: 12.sp,
              letterSpacing: 0.25),
        ),
      )
    ]);
  }

  Widget _userProfileWidget() {
    return Consumer<ProfileRepository>(builder: (BuildContext context,
        ProfileRepository profileRepository, Widget? child) {
      if ((profileRepository.profileDetails == null) &&
          (profileRepository.isLoading)) return const SizedBox.shrink();
      return (profileRepository.profileDetails != null)
          ? InkWell(
              onTap: () {
                _generateInteractTelemetryData(TelemetryConstants.viewProfile);
                Navigator.pushNamed(context, AppUrl.profileDashboard,
                    arguments: ProfileDashboardArgModel(
                        type: ProfileConstants.currentUser));
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16).r,
                child: Row(
                  children: [
                    ProfilePicture(isFromDrawer: true),
                    SizedBox(width: 16.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 0.4.sw,
                          child: Text(
                              profileRepository.profileDetails != null
                                  ? Helper.capitalizeFirstLetter(
                                      (profileRepository
                                              .profileDetails!.firstName) +
                                          ' ' +
                                          (profileRepository
                                              .profileDetails!.surname))
                                  : Helper.capitalizeFirstLetter(
                                      (widget.profileDetails?.firstName ?? '') +
                                          ' ' +
                                          (widget.profileDetails?.surname ??
                                              '')),
                              style: GoogleFonts.lato(
                                  color: AppColors.greys87,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16.0.sp)),
                        ),
                        SizedBox(height: 4.w),
                        Text(
                            AppLocalizations.of(context)!
                                .mCustomDrawerViewprofile,
                            style: GoogleFonts.lato(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w700,
                                fontSize: 12.0.sp))
                      ],
                    )
                  ],
                ),
              ),
            )
          : _profileDataErrorWidget();
    });
  }

  Widget _profileDataErrorWidget() {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(100.w)),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8).r,
        margin: EdgeInsets.symmetric(horizontal: 16).r,
        child: Center(
          child: Text(
            AppLocalizations.of(context)!.mStaticUserDataError,
            style: GoogleFonts.lato(
                color: AppColors.negativeLight,
                fontWeight: FontWeight.w700,
                fontSize: 12.sp),
            textAlign: TextAlign.center,
          ),
        ));
  }

  void _generateImpressionTelemetryData() async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getImpressionTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.homePageId,
        telemetryType: TelemetryType.viewer,
        pageUri: TelemetryPageIdentifier.homePageUri,
        env: TelemetryEnv.home);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  void _generateInteractTelemetryData(String contentId) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.homePageId,
        contentId: contentId,
        subType: TelemetrySubType.profile.toLowerCase(),
        env: TelemetryEnv.home);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  Future<void> doLogout(context) async {
    await Provider.of<LoginRespository>(context, listen: false)
        .doLogout(context);
  }

  Widget roundedButton(String buttonLabel, Color bgColor, Color textColor) {
    var loginBtn = Container(
      width: 1.sw - 40.w,
      padding: EdgeInsets.all(10).r,
      alignment: FractionalOffset.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.all(const Radius.circular(4.0)).r,
        border: bgColor == AppColors.appBarBackground
            ? Border.all(color: AppColors.grey40)
            : Border.all(color: bgColor),
      ),
      child: Text(
        buttonLabel,
        style: GoogleFonts.montserrat(
            decoration: TextDecoration.none,
            color: textColor,
            fontSize: 14.sp,
            fontWeight: FontWeight.w700),
      ),
    );
    return loginBtn;
  }

  Future _onSignOutPressed(contextMain) {
    return showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8), topRight: Radius.circular(8))
              .r,
          side: BorderSide(
            color: AppColors.grey08,
          ),
        ),
        context: context,
        builder: (context) {
          final bottomPadding = MediaQuery.of(context).viewInsets.bottom +
              MediaQuery.of(context).padding.bottom;
          return Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 20).w,
                width: double.infinity.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 20).r,
                        height: 6.w,
                        width: 0.25.sw,
                        decoration: BoxDecoration(
                          color: AppColors.grey16,
                          borderRadius: BorderRadius.all(Radius.circular(16)).r,
                        ),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 15).r,
                        child: Text(
                          AppLocalizations.of(context)!
                              .mSettingDoYouWantToLogout,
                          style: GoogleFonts.montserrat(
                              decoration: TextDecoration.none,
                              color: AppColors.greys87,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500),
                        )),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop(true);
                        doLogout(contextMain);
                      },
                      child: roundedButton(
                          AppLocalizations.of(context)!.mSettingYeslogout,
                          AppColors.appBarBackground,
                          AppColors.darkBlue),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12).r,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(true),
                        child: roundedButton(
                            AppLocalizations.of(context)!.mCommonNoTakeMeBack,
                            AppColors.darkBlue,
                            AppColors.appBarBackground),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  _getMenu({required String text, IconData? icon, String? svgPath}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 1.0, 22.0, 1.0).r,
      child: ListTile(
        leading: SizedBox(
          height: 25.w,
          width: 45.w,
          child: svgPath != null
              ? SvgPicture.asset(
                  svgPath,
                  width: 24.0.w,
                  height: 24.0.w,
                  colorFilter:
                      ColorFilter.mode(AppColors.primaryBlue, BlendMode.srcIn),
                )
              : Icon(
                  icon,
                  color: AppColors.primaryBlue,
                  size: 24.sp,
                ),
        ),
        title: Text(
          text,
          style: GoogleFonts.lato(
              color: AppColors.greys87,
              fontWeight: FontWeight.w700,
              fontSize: 16.0.sp),
        ),
      ),
    );
  }
}

class MenuDivider extends StatelessWidget {
  final bool applyIndent;
  const MenuDivider({
    super.key,
    this.applyIndent = true,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 8.w,
      color: AppColors.grey16,
      indent: applyIndent ? 16.w : 0.w,
      endIndent: applyIndent ? 16.w : 0.w,
    );
  }
}
