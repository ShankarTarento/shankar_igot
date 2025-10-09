import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/models/_models/learning_week_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/national_learning_week/national_learning_week.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:intl/intl.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:karmayogi_mobile/util/deeplinks/smt_deeplink_service.dart';
import 'package:karmayogi_mobile/util/telemetry_repository.dart';
import 'package:lottie/lottie.dart';

class HomeLearningWeekCard extends StatefulWidget {
  final LearningWeekModel learningWeekData;
  const HomeLearningWeekCard({Key? key, required this.learningWeekData})
      : super(key: key);

  @override
  _HomeLearningWeekCardState createState() => _HomeLearningWeekCardState();
}

class _HomeLearningWeekCardState extends State<HomeLearningWeekCard> {
  List<bool> dates = [];
  DateFormat format = DateFormat(IntentType.dateFormat4);

  void getDates() {
    DateTime startDate =
        format.parse(convertDateFormat(widget.learningWeekData.startDate));
    DateTime endDate =
        format.parse(convertDateFormat(widget.learningWeekData.endDate));

    DateTime now = DateTime.now().subtract(Duration(days: 1));
    Duration difference = endDate.difference(startDate);

    for (int i = 0; i <= difference.inDays; i++) {
      DateTime currentDate = startDate.add(Duration(days: i));
      dates.add(currentDate.isBefore(now));
    }
  }

  String convertDateFormat(String dateString) {
    DateFormat inputFormat = DateFormat(IntentType.dateFormat);
    DateFormat outputFormat = DateFormat(IntentType.dateFormat4);

    DateTime dateTime = inputFormat.parse(dateString);

    return outputFormat.format(dateTime);
  }

  void _generateInteractTelemetryData(String contentId,
      {required String subType,
      String? primaryCategory,
      bool isObjectNull = false,
      String clickId = ''}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.homePageId,
        contentId: contentId,
        subType: subType,
        env: TelemetryEnv.home,
        objectType: primaryCategory != null
            ? primaryCategory
            : (isObjectNull ? null : subType),
        clickId: clickId);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  bool checkLearningWeekStarted() {
    DateFormat format = DateFormat(IntentType.dateFormat4);

    DateTime now = DateTime.now().toLocal();
    now = DateTime(now.year, now.month, now.day);

    if (widget.learningWeekData.enabled != true) return false;

    try {
      DateTime startDate =
          format.parse(convertDateFormat(widget.learningWeekData.startDate));
      DateTime endDate =
          format.parse(convertDateFormat(widget.learningWeekData.endDate));

      startDate = DateTime(startDate.year, startDate.month, startDate.day);
      endDate = DateTime(endDate.year, endDate.month, endDate.day);

      return now.isAfter(startDate.subtract(Duration(days: 1))) &&
          now.isBefore(endDate.add(Duration(days: 1)));
    } catch (e) {
      debugPrint('Error parsing dates: $e');
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    getDates();
  }

  @override
  Widget build(BuildContext context) {
    return checkLearningWeekStarted()
        ? InkWell(
            onTap: () {
              OnClickNavigation(context);
            },
            child: Container(
              margin: EdgeInsets.all(16.0.w),
              padding: EdgeInsets.all(16.0.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0.w),
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage(
                    'assets/img/learning_week_background.png',
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      widget.learningWeekData.title != null
                          ? SizedBox(
                              width: 0.6.sw,
                              child: Text(
                                  widget.learningWeekData.title!
                                      .getText(context),
                                  style: GoogleFonts.montserrat(
                                    color: AppColors.appBarBackground,
                                    fontSize: 20.0.sp,
                                    fontWeight: FontWeight.w600,
                                  )))
                          : SizedBox.shrink(),
                      Spacer(),
                      Lottie.asset(
                        'assets/animations/nlw.json',
                        width: 65.w,
                        height: 65.w,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0.w),
                  widget.learningWeekData.description != null
                      ? Text(
                          widget.learningWeekData.description!.getText(context),
                          style: GoogleFonts.montserrat(
                            color: AppColors.appBarBackground,
                            fontSize: 14.0.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : SizedBox.shrink(),
                  SizedBox(height: 24.0.w),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(dates.length, (index) {
                        return Row(
                          children: [
                            CircleAvatar(
                              radius: 6,
                              backgroundColor: dates[index]
                                  ? AppColors.primaryOne
                                  : AppColors.appBarBackground,
                            ),
                            if (index < dates.length - 1)
                              Container(
                                width: 40.w,
                                height: 3.w,
                                color: dates[index]
                                    ? AppColors.primaryOne
                                    : AppColors.appBarBackground,
                              ),
                          ],
                        );
                      }),
                    ),
                  ),
                  SizedBox(height: 8.0.w),
                  widget.learningWeekData.buttonText != null
                      ? Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40.0.w),
                              ),
                              backgroundColor: AppColors.primaryOne,
                            ),
                            onPressed: () {
                              OnClickNavigation(context);
                            },
                            child: Text(widget.learningWeekData.buttonText!
                                .getText(context)),
                          ),
                        )
                      : SizedBox.shrink(),
                ],
              ),
            ),
          )
        : SizedBox();
  }

  Future<void> OnClickNavigation(BuildContext context) async {
    if (widget.learningWeekData.orgId != null &&
        widget.learningWeekData.orgName != null) {
      /// un-comment below code for direct navigation without deeplink
      // Navigator.push(
      //   context,
      //   FadeRoute(
      //       page: MdoChannelScreen(
      //     channelName: widget.learningWeekData.orgName!,
      //     orgId: widget.learningWeekData.orgId!,
      //   )),
      // );
      String url = ApiUrl.baseUrl +
          "/app/learn/mdo-channels/${widget.learningWeekData.orgName}/${widget.learningWeekData.orgId}/micro-sites";
      try {
        Platform.isIOS
            ? await SMTDeeplinkService.instance.initSMTAppLink(
                smtDeeplinkSource: BroadCastEvent.InAppMessage,
                deeplink: url,
              )
            : Helper.doLaunchUrl(
                url: url,
              );
      } catch (e) {
        debugPrint("error in navigation of state learning week$e");
      }
      _generateInteractTelemetryData(TelemetryIdentifier.slwViewMore,
          subType: TelemetryIdentifier.stateLearningWeek);
    } else {
      Navigator.push(
        context,
        FadeRoute(
            page: NationalLearningWeek(
          startDate: convertDateFormat(widget.learningWeekData.startDate),
          endDate: convertDateFormat(widget.learningWeekData.endDate),
        )),
      );
      _generateInteractTelemetryData(TelemetryIdentifier.nationalLearningWeek,
          subType: TelemetryIdentifier.nationalLearningWeek);
    }
  }
}
