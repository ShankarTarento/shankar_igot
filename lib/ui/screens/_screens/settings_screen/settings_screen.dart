import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:karmayogi_mobile/common_components/notification_engine/screens/notification_settings_screen/notification_settings_screen.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/settings_screen/screens/profile/visibility_control_settings_screen.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/settings_screen/widgets/font_slider.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/settings_screen/widgets/settings_expansion_tile.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/settings_screen/widgets/settings_tile_item.dart';
import 'package:karmayogi_mobile/ui/widgets/_signup/contact_us.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';
import 'package:karmayogi_mobile/util/logout.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../respositories/_respositories/landing_page_repository.dart';
import '../../../../util/telemetry_repository.dart';
import '../../../../util/faderoute.dart';
import '../../../../constants/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  static const route = AppUrl.settingsPage;

  final bool notMyUser;
  final bool popTillFirst;

  SettingsScreen({Key? key, this.notMyUser = false, this.popTillFirst = false})
      : super(key: key);

  @override
  _SettingsScreenState createState() {
    return new _SettingsScreenState();
  }
}

String get getEnvironmentInfo => APP_ENVIRONMENT == Environment.prod
    ? ''
    : APP_ENVIRONMENT.split('.').last.toUpperCase();

String get getYear =>
    DateTimeHelper.getDateTimeInFormat(DateTime.now().toString(),
        desiredDateFormat: IntentType.dateFormatYearOnly);

String get getNextYear => (int.parse(getYear) + 1).toString();

class _SettingsScreenState extends State<SettingsScreen> {
  String? userId;
  String? userSessionId;
  String? messageIdentifier;
  String? departmentId;
  String? pageIdentifier;
  String? telemetryType;
  String? pageUri;
  List allEventsData = [];
  String? deviceIdentifier;
  var telemetryEventData;

  int tapCount = 0;

  void _generateInteractTelemetryData(String contentId, String subtype) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.homePageId,
        contentId: contentId,
        subType: subtype,
        env: TelemetryEnv.home,
        objectType: subtype);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  ValueNotifier<bool> _displayFcmToken = ValueNotifier(false);
  String? _fcmToken;
  final _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _getFcmToken();
  }

  _getFcmToken() async {
    _fcmToken = await _storage.read(key: Storage.fcmToken);
  }

  Future _onBackPressed(contextMain) {
    return showModalBottomSheet(
        isScrollControlled: true,
        // useSafeArea: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8), topRight: Radius.circular(8).r),
          side: BorderSide(
            color: AppColors.grey08,
          ),
        ),
        context: context,
        builder: (context) => Logout(
              contextMain: contextMain,
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(241, 244, 244, 1),
      appBar: _appBar(),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.w),
              /// profile settings
              _profileSetting(),
              /// General settings
              _generalSetting(),
              /// Other settings
              _otherSetting(),
              /// Release version
              _releaseVersionView(),
              /// Copyright text
              Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20).r,
                alignment: Alignment.center,
                child: Text(
                  AppLocalizations.of(context)!.mStaticCopyRightText +
                      getYear +
                      '-' +
                      getNextYear,
                  style: GoogleFonts.lato(fontSize: 14.sp),
                ),
              ),
              /// Fcm token
              _fcmTokenView(),
              SizedBox(height: 24.w)
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileSetting() {
    return SettingsExpansionTile(
      title: AppLocalizations.of(context)!.mStaticProfile,
      children: [
        SettingsTileItem(
          onTap: () => Navigator.push(
            context,
            FadeRoute(page: VisibilityControlSettingsScreen()),
          ),
          title: AppLocalizations.of(context)!.mProfileVisibilityControl,
          leadingIcon: Icon(
            Icons.visibility_rounded,
            size: 25.w,
            color: AppColors.primaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _generalSetting() {
    return SettingsExpansionTile(
      title: AppLocalizations.of(context)!.mSettingGeneralSettings,
      children: [
        SettingsTileItem(
          onTap: () => Navigator.push(
            context,
            FadeRoute(page: NotificationSettingsScreen()),
          ),
          title: AppLocalizations.of(context)!.mStaticNotificationSettings,
          leadingIcon: Icon(
            Icons.notifications,
            color: AppColors.primaryBlue,
            size: 25.sp,
          ),
        ),
        SettingsTileItem(
          onTap: () => showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(content: FontSlider()),
          ),
          title: AppLocalizations.of(context)!.mFontSettings,
          leadingIcon: Icon(
            Icons.font_download_outlined,
            color: AppColors.primaryBlue,
            size: 25.sp,
          ),
        ),
      ],
    );
  }

  Widget _otherSetting() {
    return SettingsExpansionTile(
      title: AppLocalizations.of(context)!.mStaticOthers,
      children: [
        /// Share Application
        SettingsTileItem(
          onTap: () async {
            await SharePlus.instance.share(
              ShareParams(
                text: Platform.isAndroid ? ApiUrl.androidUrl : ApiUrl.iOSUrl,
              ),
            );
          },
          title: AppLocalizations.of(context)!.mSettingShareApplication,
          leadingIcon: SvgPicture.asset(
            'assets/img/share.svg',
            width: 25.0.w,
            height: 25.0.w,
            colorFilter: ColorFilter.mode(AppColors.primaryBlue, BlendMode.srcIn),
          ),
        ),

        /// Help
        SettingsTileItem(
          onTap: () => Navigator.push(
            context,
            FadeRoute(page: ContactUs()),
          ),
          title: AppLocalizations.of(context)!.mStaticContactUs,
          leadingIcon: SvgPicture.asset(
            'assets/img/help.svg',
            width: 25.0.w,
            height: 25.0.w,
            colorFilter: ColorFilter.mode(AppColors.primaryBlue, BlendMode.srcIn),
          ),
        ),

        /// Get Started (conditionally shown)
        if (!widget.notMyUser)
          SettingsTileItem(
            onTap: () async {
              final _storage = FlutterSecureStorage();
              await _storage.write(
                key: Storage.getStarted,
                value: GetStarted.reset,
              );
              _generateInteractTelemetryData(
                TelemetryIdentifier.getStartedTab,
                TelemetryIdentifier.getStartedTab,
              );
              if (widget.popTillFirst) {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              } else {
                Navigator.of(context).pop();
              }
              Provider.of<LandingPageRepository>(context, listen: false)
                  .updateShowGetStarted(true);
            },
            title: AppLocalizations.of(context)!.mStaticKarmayogiTour,
            leadingIcon: SvgPicture.asset(
              'assets/img/videoplay.svg',
              width: 25.0.w,
              height: 25.0.w,
              colorFilter: ColorFilter.mode(AppColors.primaryBlue, BlendMode.srcIn),
            ),
          ),

        /// Sign Out
        SettingsTileItem(
          onTap: () => _onBackPressed(context),
          title: AppLocalizations.of(context)!.mSettingSignOut,
          leadingIcon: SvgPicture.asset(
            'assets/img/logout.svg',
            width: 25.0.w,
            height: 25.0.w,
            colorFilter: ColorFilter.mode(AppColors.primaryBlue, BlendMode.srcIn),
          ),
          showArrow: false, // No arrow for logout
        ),
      ],
    );
  }

  Widget _releaseVersionView() {
    return InkWell(
      onTap: () {
        tapCount++;
        if (tapCount == 4) {
          _displayFcmToken.value = true;
          tapCount = -1;
        } else {
          _displayFcmToken.value = false;
        }
      },
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 8).r,
        child: Text(
          getEnvironmentInfo + ' Release ' + APP_VERSION,
          style: GoogleFonts.montserrat(
              color: AppColors.greys60,
              fontSize: 12.0.sp,
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _fcmTokenView() {
    return ValueListenableBuilder(
        valueListenable: _displayFcmToken,
        builder:
            (BuildContext context, bool displayToken, Widget? child) {
          return Visibility(
            visible: displayToken,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20).r,
              child: Wrap(
                runSpacing: 2,
                children: [
                  Text(
                    'Device token:  ',
                    style: GoogleFonts.montserrat(
                      color: AppColors.greys87,
                      fontSize: 12.0.sp,
                    ),
                  ),
                  SelectableText(
                    '$_fcmToken',
                    showCursor: true,
                    // ignore: deprecated_member_use
                    toolbarOptions: ToolbarOptions(
                        copy: true,
                        selectAll: true,
                        cut: false,
                        paste: false),
                    style: GoogleFonts.montserrat(
                      color: AppColors.greys60,
                      fontSize: 12.0.sp,
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      titleSpacing: 0,
      toolbarHeight: kToolbarHeight.w,
      leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Icon(Icons.arrow_back_ios_sharp, size: 20.sp)),
      title: Text(
        AppLocalizations.of(context)!.mStaticSettings,
        style: GoogleFonts.montserrat(
          color: AppColors.greys87,
          fontSize: 16.0.sp,
          fontWeight: FontWeight.w600,
        ),
      )
    );
  }
}
