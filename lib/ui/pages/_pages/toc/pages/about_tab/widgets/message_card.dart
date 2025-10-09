import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/services/toc_services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../../constants/index.dart';
import '../../../../../../../models/index.dart';
import '../../../../../../../respositories/_respositories/learn_repository.dart';
import '../../../../../../../respositories/_respositories/profile_repository.dart';
import '../../../../../../widgets/index.dart';

class MessageCards extends StatefulWidget {
  final Course course;
  final ValueChanged<bool> showKarmaPointClaimButton;
  final bool showCourseCongratsMessage;
  final bool isEnrolled;
  const MessageCards(
      {Key? key,
      required this.course,
      required this.showKarmaPointClaimButton,
      required this.showCourseCongratsMessage,
      this.isEnrolled = false})
      : super(key: key);

  @override
  State<MessageCards> createState() => _MessageCardsState();
}

class _MessageCardsState extends State<MessageCards> {
  bool isAcbp = false;
  int rewardPoint = 0;
  Map? cbpList;
  String? cbpEndDate;
  ValueNotifier<bool> showCongratsMessage = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76.w,
      child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Selector<TocServices, double?>(
              selector: (context, tocServices) => tocServices.courseProgress,
              builder: (context, courseProgress, _) {
                return Row(children: <Widget>[
                  !widget.isEnrolled
                      ? messageWidget(context, isEnroll: true)
                      : courseProgress != 0
                          ? Selector<LearnRepository, dynamic>(
                              selector: (context, learnRepository) =>
                                  learnRepository.courseRatingAndReview,
                              builder: (context, courseRatingAndReview, _) {
                                rewardPoint = COURSE_RATING_POINT;
                                if (courseRatingAndReview == null) {
                                  return messageWidget(context,
                                      isRating: true, isPointRewarded: false);
                                } else {
                                  return messageWidget(context,
                                      isRating: true, isPointRewarded: true);
                                }
                              })
                          : Center(),
                  (widget.course.courseCategory.toString().toLowerCase() ==
                          PrimaryCategory.course.toLowerCase())
                      ? Selector<LearnRepository, dynamic>(
                          selector: (context, learnRepository) =>
                              learnRepository.cbplanData,
                          builder: (context, cbplanData, _) {
                            if (cbplanData != null) {
                              isAcbp =
                                  checkIsAcbp(widget.course.id, cbplanData);
                              if (!isAcbp && !widget.isEnrolled) {
                                return Center();
                              }
                            }
                            if (isAcbp && cbplanData != null) {
                              getCBPEnddate(cbplanData);
                              rewardPoint = ACBP_COURSE_COMPLETION_POINT;
                              if (courseProgress == 1 &&
                                  widget.showCourseCongratsMessage) {
                                showCongratsMessage.value = true;
                                checkIsKarmaPointRewarded(widget.course.id);
                              } else if (getTimeDiff(cbpEndDate!) < 0) {
                                isAcbp = false;
                                rewardPoint = COURSE_COMPLETION_POINT;
                              }
                            } else {
                              rewardPoint = COURSE_COMPLETION_POINT;
                            }

                            return ValueListenableBuilder(
                                valueListenable: showCongratsMessage,
                                builder: (BuildContext context, bool value,
                                    Widget? child) {
                                  return value
                                      ? messageWidget(context,
                                          isRating: false,
                                          isPointRewarded: courseProgress == 1)
                                      : Center();
                                });
                          })
                      : Center()
                ]);
              })),
    );
  }

  Container messageWidget(BuildContext context,
      {isRating = false, isPointRewarded = false, isEnroll = false}) {
    return Container(
      height: 76.w,
      width: 0.85.sw,
      margin: EdgeInsets.only(right: 16).r,
      padding: EdgeInsets.all(16).r,
      decoration: BoxDecoration(
          color: AppColors.verifiedBadgeIconColor.withValues(alpha: 0.08),
          border: Border.all(
            color: AppColors.verifiedBadgeIconColor,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8).r),
      child: Row(children: [
        SvgPicture.asset(
          'assets/img/kp_icon.svg',
          alignment: Alignment.center,
          height: 32.w,
          width: 32.w,
          // color: AppColors.darkBlue,
          fit: BoxFit.contain,
        ),
        SizedBox(
          width: 16.w,
        ),
        isEnroll
            ? enrollMessageCard(context)
            : isPointRewarded
                ? congratsMessageWidget(context, isRating)
                : taskRewardMessageWidget(context, isRating)
      ]),
    );
  }

  Widget enrollMessageCard(context) {
    return Container(
      width: 0.6.sw,
      child: Row(
        children: [
          Flexible(
              child: RichText(
            text: TextSpan(
              children: [
                textWidget(AppLocalizations.of(context)!.mStaticEarn + ' ',
                    FontWeight.w400),
                textWidget(
                    '$FIRST_ENROLMENT_POINT ' +
                        AppLocalizations.of(context)!.mStaticKarmaPoints +
                        ' ',
                    FontWeight.w900),
                textWidget(
                    ' ' +
                        AppLocalizations.of(context)!
                            .mStaticFirstCourseEnrolment,
                    FontWeight.w400)
              ],
            ),
          )),
          Padding(
            padding: const EdgeInsets.only(left: 10.0).r,
            child: TooltipWidget(
                message:
                    AppLocalizations.of(context)!.mKarmapointEnrollTooltipMsg),
          )
        ],
      ),
    );
  }

  Widget congratsMessageWidget(context, isRating) {
    return Container(
      width: 0.6.sw,
      child: Row(
        children: [
          Flexible(
            child: RichText(
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  textWidget(
                      isRating
                          ? AppLocalizations.of(context)!
                              .mStaticcourseRatedMessage(widget
                                  .course.courseCategory
                                  .toString()
                                  .toLowerCase())
                          : AppLocalizations.of(context)!.mStaticEarn + ' ',
                      FontWeight.w400),
                  textWidget(
                      ' $rewardPoint ' +
                          AppLocalizations.of(context)!.mStaticKarmaPoints +
                          '. ',
                      FontWeight.w900),
                  if (!isRating)
                    textWidget(
                        AppLocalizations.of(context)!.mCourseCompletedMessage,
                        FontWeight.w400)
                ],
              ),
            ),
          ),
          isRating
              ? SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(left: 10.0).r,
                  child: TooltipWidget(
                      message: isAcbp
                          ? AppLocalizations.of(context)!
                              .mStaticCourseCompletedInfo
                          : AppLocalizations.of(context)!
                              .mStaticCourseCompletedInfo),
                )
        ],
      ),
    );
  }

  Widget taskRewardMessageWidget(context, isRating) {
    return Container(
      width: 0.6.sw,
      child: Row(
        children: [
          Flexible(
            child: RichText(
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  textWidget(AppLocalizations.of(context)!.mStaticEarn,
                      FontWeight.w400),
                  textWidget(
                      ' $rewardPoint ' +
                          (isRating
                              ? AppLocalizations.of(context)!.mMsgMore + ' '
                              : '') +
                          AppLocalizations.of(context)!
                              .mStaticKarmaPoints
                              .toLowerCase() +
                          ' ',
                      FontWeight.w900),
                  textWidget(
                      isRating
                          ? AppLocalizations.of(context)!.mratingCourseMessage
                          : AppLocalizations.of(context)!
                              .completingCourseMessage(widget
                                  .course.courseCategory
                                  .toString()
                                  .toLowerCase()),
                      FontWeight.w400),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: TooltipWidget(
                message: isRating
                    ? AppLocalizations.of(context)!.mCourseRatingInfo(
                        widget.course.courseCategory.toString().toLowerCase(),
                        "")
                    : isAcbp
                        ? AppLocalizations.of(context)!
                            .mStaticAcbpCourseCompletionInfo
                        : AppLocalizations.of(context)!
                            .mStaticCourseCompletionInfo),
          )
        ],
      ),
    );
  }

  TextSpan textWidget(String message, FontWeight font,
      {Color color = AppColors.greys87, double fontSize = 12}) {
    return TextSpan(
      text: message,
      style: TextStyle(
          color: color,
          fontSize: fontSize.sp,
          fontWeight: font,
          letterSpacing: 0.25),
    );
  }

  bool checkIsAcbp(String courseId, cbpData) {
    bool isCourseFound = false;
    if (cbpData.length != null) {
      if (cbpData.length == 0) {
        return isCourseFound;
      }
      cbpData['content'].forEach((cbp) {
        var data = cbp['contentList'].firstWhere(
            (element) => element['identifier'] == courseId,
            orElse: () => {});
        if (data.isNotEmpty) {
          isCourseFound = true;
        }
      });
    }
    return isCourseFound;
  }

  void checkIsKarmaPointRewarded(String courseId) async {
    var response = await ProfileRepository().getKarmaPointCourseRead(courseId);
    if (response != null && response.isNotEmpty) {
      bool isPointRewarded = false;
      if (response['addinfo'] != null) {
        if (response['addinfo'].runtimeType == String &&
            response['addinfo'] != "") {
          var addinfo = jsonDecode(response['addinfo']);
          if (addinfo['ACBP'] != null) {
            isPointRewarded = addinfo['ACBP'];
          }
        } else if (response['addinfo'] != null &&
            response['addinfo'].runtimeType != String) {
          if (response['addinfo']['ACBP'] != null) {
            isPointRewarded = response['addinfo']['ACBP'];
          }
        }
      }
      if (!isPointRewarded) {
        widget.showKarmaPointClaimButton(true);
        showCongratsMessage.value = false;
      }
    }
  }

  int getTimeDiff(String date1) {
    return DateTime.parse(
            DateFormat('yyyy-MM-dd').format(DateTime.parse(date1)))
        .difference(
            DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now())))
        .inDays;
  }

  void getCBPEnddate(cbpList) {
    if (cbpEndDate == null && cbpList.runtimeType != String) {
      var cbpCourse = cbpList['content'] ?? [];

      for (int index = 0; index < cbpCourse.length; index++) {
        var element = cbpCourse[index]['contentList'];
        for (int elementindex = 0;
            elementindex < element.length;
            elementindex++) {
          if (element[elementindex]['identifier'] == widget.course.id) {
            cbpEndDate = cbpCourse[index]['endDate'];
            break;
          }
        }
      }
    }
  }
}
