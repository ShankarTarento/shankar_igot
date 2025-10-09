import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:karmayogi_mobile/home_screen_components/home_screen_components.dart';
import 'package:karmayogi_mobile/ui/widgets/index.dart';
import 'package:karmayogi_mobile/models/_models/user_feed_model.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';
import 'package:provider/provider.dart';
import '../../../../constants/index.dart';
import '../../../../models/index.dart';
import '../../../../respositories/index.dart';
import '../../../../util/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  static const route = AppUrl.homePage;
  final int? index;

  HomePage({
    Key? key,
    this.index,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  ScrollController _controller = ScrollController();
  int _start = 0;
  final _storage = FlutterSecureStorage();
  String? feedId, enableRating = '0';
  Map<String, dynamic>? formFields;
  int? _npsFormId;
  List<UserFeed> userFeeds = [];
  int get leaderboardCelebrationPlayDuration => 1100;
  final List<Color> gradientColors = <Color>[];
  late Future<Map<String, dynamic>>? nationalLearningWeek;

  @override
  void initState() {
    super.initState();

    if (widget.index == 0) {
      _getConnectionRequest();
      if (_start == 0) {
        _generateTelemetryData();
      }
      _start++;
    }
    _getFormFeed();
    _showPopupToUpdateProfile();
    getProfileInfo();
  }

  void _modalBottomSheetMenu(show) async {
    await Provider.of<InAppReviewRespository>(context, listen: false)
        .setOtherPopupVisibleStatus(true);
    showModalBottomSheet<Widget>(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return show == 'true'
            ? SingleChildScrollView(child: NPSFeedback(userFeeds: userFeeds))
            : Center();
      },
    ).whenComplete(() async {
      await Provider.of<InAppReviewRespository>(context, listen: false)
          .setOtherPopupVisibleStatus(false);
    });
  }

  void _generateTelemetryData() async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getImpressionTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.homePageId,
        telemetryType: TelemetryType.app,
        pageUri: TelemetryPageIdentifier.homePageUri,
        env: TelemetryEnv.home);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  void _getFormFeed() async {
    String? userId = await _storage.read(key: Storage.userId);
    List<UserFeed> userFeed =
        await Provider.of<NpsRepository>(context, listen: false)
            .getFormFeed(userId);
    if (userFeed.isEmpty) return;
    userFeed.forEach((element) async {
      if (element.category == FeedCategory.nps &&
          element.data['actionData'] != null &&
          element.data['actionData']['formId'] != null) {
        userFeeds.add(element);
      }
      if (element.category == FeedCategory.inAppReview) {
        bool isExpired = DateTime.fromMillisecondsSinceEpoch(
                int.parse(element.expireOn.toString()))
            .isBefore(DateTime.now());
        if (!isExpired) {
          await Provider.of<InAppReviewRespository>(context, listen: false)
              .rateAppOnWeeklyClap(context: context, feedId: element.feedId!);
        }
      }
    });
    if (userFeeds.isNotEmpty) {
      String? lastPlatformRatedDate =
          await _storage.read(key: Storage.platformRatingSubmitDate);
      if (lastPlatformRatedDate == null ||
          DateTimeHelper.isDateXDaysBefore(int.parse(lastPlatformRatedDate))) {
        _npsFormId = userFeeds.last.data['actionData']['formId'];
        feedId = userFeeds.last.feedId;
        await _storage.write(
            key: Storage.showRatingPlatform, value: NPS.enable);
        if (_npsFormId != null) _getFormById(_npsFormId);
      }
    }
  }

  void _getFormById(formId) async {
    String? show = await _storage.read(key: Storage.showRatingPlatform);
    enableRating = await _storage.read(key: Storage.enableRating);
    if (show == NPS.enable && int.parse(enableRating!) >= 4) {
      Future.delayed(Duration.zero, () {
        _modalBottomSheetMenu(show);
      });
    }
    if (mounted) {
      setState(() {});
    }
  }

  /// Get connection request response
  Future _getConnectionRequest() async {
    try {
      await Provider.of<NetworkRespository>(context, listen: false).getCrList();
    } catch (err) {
      return err;
    }
  }

  @override
  void dispose() async {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          return true;
        },
        child: widget.index == 0 ? HomeScreenComponents() : Center());
  }

  Future<void> _showPopupToUpdateProfile() async {
    bool showGetStarted =
        await _storage.read(key: Storage.getStarted).then((value) {
      return value != GetStarted.finished || value == 'null';
    });
    if (showGetStarted) {
      Provider.of<LandingPageRepository>(context, listen: false)
          .updateShowGetStarted(true);
      return;
    }

    String? showNPS = await _storage.read(key: Storage.showRatingPlatform);
    if (showNPS == NPS.enable) return;

    List<Profile>? _profileDetails =
        await Provider.of<ProfileRepository>(context, listen: false)
            .getProfileDetailsById('');
    Profile? profileDetails =
        _profileDetails.isNotEmpty ? _profileDetails.first : null;

    if (profileDetails != null && profileDetails.isApprovedMsgViewed == false) {
      // To get the In review fields which is SENT FOR APPROVAL
      List<dynamic> approvedFields =
          await Provider.of<ProfileRepository>(context, listen: false)
              .getInReviewFields(isApproved: true);
      // To get the rejected fields
      List<dynamic> rejectedFields =
          await Provider.of<ProfileRepository>(context, listen: false)
              .getInReviewFields(isRejected: true);
      Future.delayed(Duration(milliseconds: 500), () async {
        await Provider.of<InAppReviewRespository>(context, listen: false)
            .setOtherPopupVisibleStatus(true);
        await _showDialogToUpdateNumber(
            isUpdateProfile: true,
            buttonText: AppLocalizations.of(context)!.mStaticClickHere,
            popupMessage: rejectedFields.isNotEmpty && approvedFields.isEmpty
                ? AppLocalizations.of(context)!.mHomeMdoRejectedRequestMsg
                : approvedFields.isNotEmpty && rejectedFields.isEmpty
                    ? AppLocalizations.of(context)!.mHomeMdoApprovedRequestMsg
                    : AppLocalizations.of(context)!.mHomeMdoUpdatedDetailsMsg);
      });
    } else if (checkPhoneVerified(profileDetails?.personalDetails)) {
      Future.delayed(Duration(milliseconds: 500), () async {
        await Provider.of<InAppReviewRespository>(context, listen: false)
            .setOtherPopupVisibleStatus(true);
        await _showDialogToUpdateNumber();
      });
    } else if (profileDetails != null &&
        profileDetails.profileStatus != UserProfileStatus.verified) {
      // Nudge for profile details update
      Future.delayed(Duration(milliseconds: 500), () async {
        await Provider.of<InAppReviewRespository>(context, listen: false)
            .setOtherPopupVisibleStatus(true);
        await _showDialogToUpdateNumber(
          isUpdateProfile: true,
        );
      });
    }
  }

  Future<void> _showDialogToUpdateNumber(
      {bool isUpdateProfile = false,
      String? popupMessage,
      String? buttonText}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return UpdatePopupWidget(
          ctx: context,
          buttonText: buttonText,
          isUpdateProfile: isUpdateProfile,
          popupMessage: popupMessage,
        );
      },
    ).whenComplete(() async {
      await Provider.of<InAppReviewRespository>(context, listen: false)
          .setOtherPopupVisibleStatus(false);
    });
  }

  bool checkPhoneVerified(Map<dynamic, dynamic>? personalDetails) {
    return !(personalDetails != null &&
        personalDetails['mobile'] != null &&
        personalDetails['mobile'].toString().isNotEmpty &&
        personalDetails['phoneVerified'].toString() == 'true');
  }

  Future<void> getProfileInfo() async {
    await Provider.of<ProfileRepository>(context, listen: false)
        .getProfileDetailsById('');

    await Provider.of<ProfileRepository>(context, listen: false)
        .getInReviewFields();
    // To get the In review fields which is SENT FOR APPROVAL
    await Provider.of<ProfileRepository>(context, listen: false)
        .getInReviewFields(isApproved: true);
    // To get the rejected fields
    await Provider.of<ProfileRepository>(context, listen: false)
        .getInReviewFields(isRejected: true);
  }
}
