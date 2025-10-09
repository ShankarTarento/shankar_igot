import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/models/_models/user_feed_model.dart';
import 'package:karmayogi_mobile/respositories/_respositories/in_app_review_repository.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../constants/_constants/app_constants.dart';
import '../../constants/_constants/color_constants.dart';
import '../../constants/_constants/storage_constants.dart';
import '../../constants/_constants/telemetry_constants.dart';
import '../../respositories/_respositories/nps_repository.dart';
import '../../util/telemetry_repository.dart';

class NPSFeedback extends StatefulWidget {
  final List<UserFeed>? userFeeds;

  NPSFeedback({this.userFeeds});
  @override
  FeedbackState createState() => FeedbackState();
}

class FeedbackState extends State<NPSFeedback>
    with SingleTickerProviderStateMixin {
  bool showSubmitBtn = false;
  int rating = -1;
  bool submit = false;
  String? response;
  bool showAnimation = true;
  TextEditingController reviewController = TextEditingController();
  String hintText = "Inspire others by sharing your experience";
  final _storage = FlutterSecureStorage();

  String? userId;
  String? userSessionId;
  String? messageIdentifier;
  String? departmentId;
  String? deviceIdentifier;
  var telemetryEventData;
  Map<String, dynamic>? formFields;
  bool isClosePopUpShown = false;
  int _start = 0;

  @override
  void initState() {
    super.initState();
    if (widget.userFeeds != null) {
      _getFormById(widget.userFeeds!.last.data['actionData']['formId']);
      reviewController.text = '';
    }
    _triggerStartTelemetryEvent();
  }

  void _triggerStartTelemetryEvent() async {
    startTimer();
    var telemetryRepository = TelemetryRepository();
    Map eventData1 = telemetryRepository.getImpressionTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.homePageId,
        telemetryType: TelemetryType.page,
        pageUri: TelemetryPageIdentifier.homePageUri,
        env: TelemetryEnv.home,
        subType: TelemetrySubType.platformRating);
    await telemetryRepository.insertEvent(eventData: eventData1);

    Map eventData2 = telemetryRepository.getStartTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.homePageId,
        telemetryType: TelemetryType.page,
        pageUri: TelemetryPageIdentifier.homePageUri,
        env: TelemetryEnv.platformRating);
    await telemetryRepository.insertEvent(eventData: eventData2);
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  Future<void> _triggerEndTelemetryEvent() async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getEndTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.homePageId,
        duration: _start,
        telemetryType: TelemetryType.page,
        pageUri: TelemetryPageIdentifier.homePageUri,
        rollup: {},
        env: TelemetryEnv.platformRating);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  Future<void> _generateInteractTelemetryData(String contentId) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.platformRatingPageId,
        contentId: contentId,
        subType: rating.toString(),
        env: TelemetryEnv.platformRating);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  void _getFormById(formId) async {
    if (formId == null) return;
    formFields = await Provider.of<NpsRepository>(context, listen: false)
        .getFormById(formId);
  }

  Future<void> _submitForm() async {
    await _storage.write(key: Storage.showRatingPlatform, value: NPS.disable);
    await _storage.write(
        key: Storage.platformRatingSubmitDate,
        value: DateTime.now().millisecondsSinceEpoch.toString());
    String? userId = await _storage.read(key: Storage.userId);
    response = await Provider.of<NpsRepository>(context, listen: false)
        .submitForm(formFields, reviewController.text, rating,
            widget.userFeeds!.last.data['actionData']['formId']);
    await Provider.of<NpsRepository>(context, listen: false)
        .deleteNPSFeed(userId, widget.userFeeds!.last.feedId);
    if (widget.userFeeds!.length > 1) {
      widget.userFeeds!.removeLast();
      widget.userFeeds!.forEach((element) async {
        try {
          await Provider.of<NpsRepository>(context, listen: false)
              .deleteNPSFeed(userId, element.feedId);
        } catch (e) {
          debugPrint("$e");
        }
      });
    }
  }

  Widget showSmiley(rating) {
    return Container(
      height: 40.w,
      width: 40.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(width: 1.5, color: AppColors.primaryBlue),
      ),
      child: SvgPicture.asset(
        'assets/img/rating_$rating.svg',
        height: 40.w,
        width: 40.w,
        fit: BoxFit.fill,
      ),
    );
  }

  Widget getAnimatedWidget() {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom).r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Image(
              image: AssetImage('assets/img/karmasahayogi.png'),
              height: 160.w,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.appBarBackground,
              borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15))
                  .r,
              boxShadow: [
                BoxShadow(
                  color: AppColors.grey16,
                  blurRadius: 3.0.r,
                  spreadRadius: 3.r,
                  offset: Offset(-3.0, -3.0),
                ),
                BoxShadow(
                  color: AppColors.primaryBlue,
                  blurRadius: 3.0.r,
                  spreadRadius: 4.r,
                  offset: Offset(-1.0, -1.0),
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 30).r,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 8).r,
                    child: Align(
                        alignment: Alignment.topRight,
                        child: InkWell(
                          onTap: () async {
                            rating = -1;
                            if (!submit) {
                              await _submitForm();
                              await _generateInteractTelemetryData(
                                  TelemetryIdentifier.platformRatingClose);
                              await _triggerEndTelemetryEvent();
                            }
                            isClosePopUpShown = false;
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: 24.w,
                            width: 24.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border:
                                  Border.all(width: 1, color: AppColors.grey16),
                            ),
                            child: Icon(
                              Icons.close,
                              color: AppColors.greys60,
                              size: 16.sp,
                            ),
                          ),
                        )),
                  ),
                  !submit
                      ? Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                !showSubmitBtn
                                    ? Column(
                                        children: [
                                          SizedBox(
                                            width: 1.sw / 1.2,
                                            child: Text(
                                              AppLocalizations.of(context)!
                                                      .mRatingHowLikelyAreYouToRecommed +
                                                  "\n" +
                                                  AppLocalizations.of(context)!
                                                      .mRatingIgotToColleagues,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineSmall!
                                                  .copyWith(
                                                      letterSpacing: 0.12.r,
                                                      color: AppColors.greys),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 3,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Center(),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8)
                                  .r,
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                runSpacing: 2.0,
                                spacing: 8.0,
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: showSubmitBtn
                                          ? const EdgeInsets.only(
                                                  top: 0, bottom: 4, left: 8)
                                              .r
                                          : const EdgeInsets.only(
                                                  top: 10, bottom: 4, left: 8)
                                              .r,
                                      child: Text(
                                          AppLocalizations.of(context)!
                                              .mRatingNotLikely,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge!
                                              .copyWith(
                                                  letterSpacing: 0.09.r,
                                                  fontSize: 12.sp)),
                                    ),
                                  ),
                                  ...List.generate(
                                    RATING_LIMIT,
                                    (index) {
                                      return AnimationConfiguration
                                          .staggeredList(
                                        position: index,
                                        duration:
                                            const Duration(milliseconds: 375),
                                        child: SlideAnimation(
                                          verticalOffset: 50.0,
                                          child: FadeInAnimation(
                                              child: ratingItemWidget(index)),
                                        ),
                                      );
                                    },
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                              top: 4, right: 16)
                                          .r,
                                      child: Container(
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .mRatingExtremelyLikely,
                                          maxLines: 2,
                                          textAlign: TextAlign.end,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge!
                                              .copyWith(
                                                  fontSize: 12.sp,
                                                  letterSpacing: 0.09.r),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            showSubmitBtn ? submitLayout() : Center(),
                          ],
                        )
                      : ConfirmationPopUp(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget submitLayout() {
    return Padding(
      padding: const EdgeInsets.only(top: 16).r,
      child: Column(
        children: <Widget>[
          Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0).r,
              ),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4).r,
                    border: Border.all(width: 1, color: AppColors.grey16)),
                child: Padding(
                  padding: EdgeInsets.all(8.0).r,
                  child: TextField(
                    controller: reviewController,
                    maxLines: 4,
                    maxLength: 500,
                    style: Theme.of(context).textTheme.labelMedium,
                    decoration: InputDecoration.collapsed(
                      hintText: hintText,
                      hintStyle: Theme.of(context)
                          .textTheme
                          .labelLarge!
                          .copyWith(letterSpacing: 0.25.r),
                    ),
                  ),
                ),
              )),
          Padding(
            padding: const EdgeInsets.only(top: 10.0).r,
            child: Container(
              width: 1.sw,
              height: 50.w,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(4).r),
              child: ElevatedButton(
                  onPressed: () async {
                    await _submitForm();
                    await _generateInteractTelemetryData(
                        TelemetryIdentifier.platformRatingSubmit);
                    await _triggerEndTelemetryEvent();

                    setState(() {
                      submit = true;
                      isClosePopUpShown = true;
                      Future.delayed(Duration(milliseconds: 3000), () async {
                        if (isClosePopUpShown) {
                          Navigator.of(context).pop();
                          await Provider.of<InAppReviewRespository>(context,
                                  listen: false)
                              .setOtherPopupVisibleStatus(false);
                        }
                      });
                    });
                  },
                  style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all(AppColors.darkBlue)),
                  child: Text(AppLocalizations.of(context)!.mStaticSubmit,
                      style: GoogleFonts.lato(
                          color: AppColors.scaffoldBackground,
                          fontSize: 14.sp,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w700))),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: Duration(seconds: 1), // Duration for the animation
      curve: Curves.fastOutSlowIn, // Animation curve (e.g., ease-in-out)
      child: getAnimatedWidget(),
    );
  }

  Widget ratingItemWidget(int index) {
    return Container(
      padding: EdgeInsets.only(left: 4, right: 4, top: 8, bottom: 8).r,
      child: InkWell(
        child: (showSubmitBtn && rating == index)
            ? showSmiley(rating)
            : Container(
                height: 40.w,
                width: 40.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(width: 1.w, color: AppColors.primaryBlue),
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    '${index}',
                    style: GoogleFonts.montserrat(
                      color: AppColors.deepBlue,
                      fontSize: 12.sp,
                      letterSpacing: 0.25.w,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )),
        onTap: () {
          setState(() {
            if (rating == index) {
              showSubmitBtn = false;
              rating = -1;
              showAnimation = true;
            } else {
              showSubmitBtn = true;
              rating = index;
              if (rating < 9) {
                hintText =
                    AppLocalizations.of(context)!.mRatingHowCanWeMakeItBetter;
              } else {
                hintText = AppLocalizations.of(context)!.mRatingInspireOthers;
              }
            }
          });
        },
      ),
    );
  }
}

class ConfirmationPopUp extends StatelessWidget {
  const ConfirmationPopUp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(27.0, 0, 27.0, 30).r,
      child: Text(
        AppLocalizations.of(context)!.mRatingThanksForFeedBack,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
              letterSpacing: 0.12.r,
              fontFamily: GoogleFonts.montserrat().fontFamily,
            ),
      ),
    );
  }
}
