import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/services/_services/feed_service.dart';
import 'package:karmayogi_mobile/ui/widgets/_buttons/animated_container.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../util/telemetry_repository.dart';

class InAppReviewPopupOnWeeklyClap extends StatefulWidget {
  final BuildContext parentContext;
  final String feedId;
  const InAppReviewPopupOnWeeklyClap(
      {Key? key, required this.parentContext, required this.feedId})
      : super(key: key);

  @override
  State<InAppReviewPopupOnWeeklyClap> createState() =>
      _InAppReviewPopupOnWeeklyClapState();
}

class _InAppReviewPopupOnWeeklyClapState
    extends State<InAppReviewPopupOnWeeklyClap> {
  final FeedService feedService = FeedService();
  late String userId;
  late String userSessionId;
  late String messageIdentifier;
  late String departmentId;
  late String deviceIdentifier;
  var telemetryEventData;

  @override
  void initState() {
    super.initState();
    _loadTelemetryData();
  }

  _loadTelemetryData() async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getImpressionTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.homePageId,
        telemetryType: TelemetryType.page,
        pageUri: TelemetryPageIdentifier.homePageUri,
        env: TelemetryEnv.home,
        subType: TelemetrySubType.weeklyClapsRateNow);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  void _generateInteractTelemetryData(String contentId) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.homePageId,
        contentId: contentId,
        subType: TelemetrySubType.weeklyClaps,
        env: TelemetryEnv.home);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0).r),
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
              color: AppColors.seaShell,
              borderRadius: BorderRadius.circular(16).r),
          child: Column(
            children: [
              Stack(
                children: [
                  Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                          splashRadius: 4.r,
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(Icons.highlight_remove))),
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 30, 20, 24).r,
                    child: Column(
                      children: [
                        SvgPicture.asset(
                          'assets/img/clap_icon.svg',
                          width: 50.w,
                          height: 50.w,
                        ),
                        SizedBox(
                          height: 16.w,
                        ),
                        Text(
                          AppLocalizations.of(widget.parentContext)!
                              .mRateOnWeeklyClapCongratsText,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                fontWeight: FontWeight.w500,
                                fontFamily: GoogleFonts.montserrat().fontFamily,
                              ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                width: double.infinity.w,
                decoration: BoxDecoration(
                    color: AppColors.appBarBackground,
                    borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16))
                        .r),
                padding: EdgeInsets.fromLTRB(20, 24, 20, 10).r,
                child: Column(
                  children: [
                    Text(
                      AppLocalizations.of(widget.parentContext)!
                          .mRateOnWeeklyClapCongratsDescription,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.w500,
                            fontFamily: GoogleFonts.montserrat().fontFamily,
                          ),
                    ),
                    SizedBox(
                      height: 12.sp,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ButtonClickEffect(
                        child: Text(AppLocalizations.of(widget.parentContext)!
                            .mRateOnWeeklyClapRateText),
                        onTap: () {
                          _generateInteractTelemetryData(
                              TelemetryIdentifier.rateNow);
                          feedService.deleteInAppReviewFeed(
                              feedId: widget.feedId);
                          final InAppReview inAppReview = InAppReview.instance;
                          inAppReview.openStoreListing(
                              appStoreId: APP_STORE_ID);
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    SizedBox(
                      height: 2.w,
                    ),
                    TextButton(
                        onPressed: () {
                          _generateInteractTelemetryData(
                              TelemetryIdentifier.mayBeLater);
                          feedService.deleteInAppReviewFeed(
                              feedId: widget.feedId);
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          AppLocalizations.of(widget.parentContext)!
                              .mRateOnWeeklyClapLaterText,
                          style:
                              Theme.of(context).textTheme.titleSmall!.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                        ))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
