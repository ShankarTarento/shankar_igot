import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:karmayogi_mobile/services/_services/report_service.dart';
import 'package:karmayogi_mobile/ui/network_hub/network_hub.dart';
import 'package:karmayogi_mobile/ui/widgets/_network/see_all_connection_requests.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../../../constants/index.dart';
import '../../../../../../models/index.dart';
import '../../../../../../respositories/index.dart';
import '../../../../../skeleton/index.dart';
import '../../../../../widgets/_activities/_leaderboard/leaderboard_frame_widget.dart';
import '../../../../../widgets/index.dart';
import '../../../../../pages/_pages/network/network_request_page.dart';

class YourActivities extends StatefulWidget {
  const YourActivities({Key? key}) : super(key: key);

  @override
  _YourActivitiesState createState() => _YourActivitiesState();
}

class _YourActivitiesState extends State<YourActivities> {
  // List _data = [];
  int pageNo = 1;
  // List _flaggedDiscussions = [];
  var telemetryEventData;

  Future<UserEnrollmentInfo>? getEnrollmentInfoFuture;
  Future<dynamic>? getUserInsightFuture;
  Future<dynamic>? getLatestDiscussionFuture;
  Future<dynamic>? getConnectionRequestFuture;
  LearnRepository learnRepository = LearnRepository();

  final _controller = PageController();

  final ReportService reportService = ReportService();
  @override
  void initState() {
    super.initState();
    _getFutureData();
    getConnectionRequestFuture = _getConnectionRequest(context);
  }

  Future<void> _getFutureData() async {
    await getUserInsights();
    await getEnrolledCourse();
    await getLatestDiscussion();
  }

  Future<void> getUserInsights() async {
    getUserInsightFuture = Future.value(
        await Provider.of<ProfileRepository>(context, listen: false)
            .getInsights(context));
  }

  Future<void> getLatestDiscussion() async {
    getLatestDiscussionFuture = Future.value(await _getLatestDiscussion());
    if (mounted) {
      setState(() {});
    }
  }

  // Latest Discussion
  Future<dynamic> _getLatestDiscussion() async {
    List<dynamic> response = [];
    var res = await Provider.of<DiscussRepository>(context, listen: false)
        .getMyDiscussions();
    if (res == null || res['latestPosts'] == null) {
      return 'No Data found';
    } else if (res['latestPosts'].isEmpty) {
      return 'No Data found';
    }
    response = [for (final item in res['latestPosts']) Discuss.fromJson(item)];
    response.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
    return response.first;
  }

  /// Get connection request response
  Future<dynamic> _getConnectionRequest(context) async {
    try {
      return await Provider.of<NetworkRespository>(context, listen: false)
          .getCrList();
    } catch (err) {
      return err;
    }
  }

  Future<void> getEnrolledCourse() async {
    getEnrollmentInfoFuture =
        Future.value(await learnRepository.getEnrollmentSummary());
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24).r,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder(
                future: getUserInsightFuture,
                builder: (context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData) {
                    var userInsights = snapshot.data;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Your stats
                        FutureBuilder<UserEnrollmentInfo>(
                            future: getEnrollmentInfoFuture,
                            builder:
                                (context, AsyncSnapshot<dynamic> snapshot) {
                              if (snapshot.hasData && snapshot.data != null) {
                                UserEnrollmentInfo data = snapshot.data;
                                return Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: TitleSemiboldSize16(
                                          AppLocalizations.of(context)!
                                              .mStaticYourStats),
                                    ),
                                    Container(
                                        margin: EdgeInsets.only(top: 16).r,
                                        padding:
                                            EdgeInsets.fromLTRB(16, 20, 16, 20)
                                                .r,
                                        decoration: BoxDecoration(
                                          color: AppColors.appBarBackground,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(16).r),
                                        ),
                                        child: Column(
                                          children: [
                                            YourStats(
                                              getInprogressCount(data),
                                              getCertificateIssuedCount(data),
                                              getTime(data),
                                            ),
                                            userInsights != null &&
                                                    userInsights.runtimeType !=
                                                        String
                                                ? userInsights['nudges']
                                                        .isNotEmpty
                                                    ? Container(
                                                        margin: EdgeInsets.only(
                                                                top: 16)
                                                            .r,
                                                        padding:
                                                            EdgeInsets.only(
                                                                    bottom: 16)
                                                                .r,
                                                        width: 1.sw,
                                                        decoration: BoxDecoration(
                                                            color: AppColors
                                                                .orangeShadow,
                                                            borderRadius:
                                                                BorderRadius.all(
                                                                    Radius.circular(
                                                                            12)
                                                                        .r)),
                                                        child: Column(
                                                          children: [
                                                            SizedBox(
                                                              height: 70.w,
                                                              child: PageView
                                                                  .builder(
                                                                      controller:
                                                                          _controller,
                                                                      itemCount:
                                                                          userInsights['nudges']
                                                                              .length,
                                                                      itemBuilder:
                                                                          (context,
                                                                              pageIndex) {
                                                                        return Container(
                                                                          margin:
                                                                              EdgeInsets.all(8).r,
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              SizedBox(
                                                                                width: userInsights['nudges'][pageIndex]['growth'] == 'negative' || userInsights['nudges'][pageIndex]['progress'] < 1 ? 1.sw - 100.w : 1.sw - 175.w,
                                                                                child: TitleRegularGrey60(
                                                                                  trimQuotes(userInsights['nudges'][pageIndex]['label']),
                                                                                  color: AppColors.greys87,
                                                                                  maxLines: 2,
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                width: 4.w,
                                                                              ),
                                                                              userInsights['nudges'][pageIndex]['growth'] != 'negative'
                                                                                  ? userInsights['nudges'][pageIndex]['progress'] >= 1
                                                                                      ? Row(
                                                                                          children: [
                                                                                            Icon(
                                                                                              Icons.arrow_upward,
                                                                                              size: 18.sp,
                                                                                              color: AppColors.positiveLight,
                                                                                            ),
                                                                                            TitleRegularGrey60('+${userInsights['nudges'][pageIndex]['progress']}%', color: AppColors.positiveLight)
                                                                                          ],
                                                                                        )
                                                                                      : Center()
                                                                                  : Center()
                                                                            ],
                                                                          ),
                                                                        );
                                                                      }),
                                                            ),
                                                            SmoothPageIndicator(
                                                              controller:
                                                                  _controller,
                                                              count: userInsights[
                                                                      'nudges']
                                                                  .length,
                                                              effect: ExpandingDotsEffect(
                                                                  activeDotColor:
                                                                      AppColors
                                                                          .orangeTourText,
                                                                  dotColor:
                                                                      AppColors
                                                                          .profilebgGrey20,
                                                                  dotHeight: 4,
                                                                  dotWidth: 4,
                                                                  spacing: 4),
                                                            )
                                                          ],
                                                        ),
                                                      )
                                                    : Center()
                                                : Center(),
                                          ],
                                        )),
                                  ],
                                );
                              } else {
                                return StatsSkeleton();
                              }
                            }),

                        /** Leader board started**/
                        LeaderboardFameWidget(),
                        /** Leader board end**/

                        // Weekl claps
                        userInsights != null
                            ? Container(
                                margin: EdgeInsets.only(top: 16).r,
                                padding: EdgeInsets.fromLTRB(16, 16, 16, 20).r,
                                decoration: BoxDecoration(
                                  color: AppColors.appBarBackground,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16).r),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    WeeklyclapTitleWidget(
                                      weeklyClaps:
                                          userInsights.runtimeType != String
                                              ? userInsights['weekly-claps']
                                              : {},
                                      showInRow: true,
                                      enableNavigationForWeeklyClaps: false,
                                    ),
                                    SizedBox(height: 4.w),
                                    userInsights.runtimeType != String
                                        ? TitleRegularGrey60(getFormattedDate(
                                            userInsights['weekly-claps']
                                                ['startDate'],
                                            userInsights['weekly-claps']
                                                ['endDate']))
                                        : Center(),
                                    SizedBox(height: 20.w),
                                    userInsights.runtimeType != String
                                        ? Row(
                                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              weekwiseClapWidget(
                                                  userInsights['weekly-claps'],
                                                  'w1'),
                                              SizedBox(width: 24.w),
                                              weekwiseClapWidget(
                                                  userInsights['weekly-claps'],
                                                  'w2'),
                                              SizedBox(width: 24.w),
                                              weekwiseClapWidget(
                                                  userInsights['weekly-claps'],
                                                  'w3'),
                                              SizedBox(width: 24.w),
                                              weekwiseClapWidget(
                                                  userInsights['weekly-claps'],
                                                  'w4')
                                            ],
                                          )
                                        : Row(
                                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              weekwiseClapWidget({}, 'w1'),
                                              SizedBox(width: 24.w),
                                              weekwiseClapWidget({}, 'w2'),
                                              SizedBox(width: 24.w),
                                              weekwiseClapWidget({}, 'w3'),
                                              SizedBox(width: 24.w),
                                              weekwiseClapWidget({}, 'w4')
                                            ],
                                          )
                                  ],
                                ))
                            : Center(),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        StatsSkeleton(),
                        WeeklyclapSkeleton(),
                        DiscussSkeleton()
                      ],
                    );
                  }
                }),
            NetworkRequestPage(parentAction: () {
              setState(() {
                getConnectionRequestFuture = _getConnectionRequest(context);
              });
            }),
            SizedBox(
              height: 18.w,
            ),
            FutureBuilder(
                future: getConnectionRequestFuture,
                builder: (context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data != null &&
                        snapshot.data.runtimeType != String) {
                      return Wrap(
                        children: [
                          SeeAllConnectionRequests(snapshot.data,
                              parentAction: () {
                            Navigator.push(
                              context,
                              FadeRoute(page: NetworkHubV2()),
                            );
                          }),
                        ],
                      );
                    } else
                      return Container(height: 30.w, child: SizedBox.shrink());
                  } else {
                    return Container(height: 30.w, child: SizedBox.shrink());
                  }
                }),
            SizedBox(
              height: 100.w,
            )
          ],
        ),
      ),
    );
  }

  Widget weekwiseClapWidget(Map<String, dynamic> weeklyClaps, String week) {
    return Row(
      children: [
        TitleRegularGrey60(
          week.toUpperCase(),
          color: week == 'w4' ? AppColors.darkBlue : AppColors.greys60,
        ),
        SizedBox(width: 4.w),
        weeklyClaps.isEmpty
            ? appNotUsed()
            : weeklyClaps[week] == null
                ? appNotUsed()
                : weeklyClaps[week].isEmpty
                    ? appNotUsed()
                    : weeklyClaps[week]['timespent'] >= CLAP_DURATION
                        ? clapRecieved()
                        : week == 'w4'
                            ? Container(
                                width: 24.w,
                                height: 24.w,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.verifiedBadgeIconColor
                                        .withValues(alpha: 0.5),
                                    border: Border.all(
                                        color:
                                            AppColors.verifiedBadgeIconColor)),
                              )
                            : appNotUsed()
      ],
    );
  }

  String trimQuotes(String input) {
    if (input.startsWith('"') && input.endsWith('"')) {
      return input.substring(1, input.length - 1);
    }
    return input;
  }

  String getFormattedDate(String startDate, String endDate) {
    try {
      return '${DateFormat('EEE, d MMM').format(DateTime.parse(startDate))} - ${DateFormat('EEE, d MMM').format(DateTime.parse(endDate))}';
    } catch (e) {
      return '';
    }
  }

  Widget appNotUsed() {
    return Icon(Icons.cancel, color: AppColors.grey40, size: 30.w);
  }

  Widget clapRecieved() {
    return Icon(
      Icons.check_circle,
      size: 24.w,
      color: AppColors.orangeTourText,
    );
  }

  int getInprogressCount(UserEnrollmentInfo enrollmentInfo) {
    int count = enrollmentInfo.userCourseEnrolmentInfo.coursesInProgress +
        enrollmentInfo.userExternalCourseEnrolmentInfo.coursesInProgress;
    return count;
  }

  int getCertificateIssuedCount(UserEnrollmentInfo enrollmentInfo) {
    int count = enrollmentInfo.userCourseEnrolmentInfo.certificatesIssued +
        enrollmentInfo.userExternalCourseEnrolmentInfo.certificatesIssued;
    return count;
  }

  int getTime(UserEnrollmentInfo enrollmentInfo) {
    return enrollmentInfo.userCourseEnrolmentInfo.timeSpentOnCompletedCourses +
        enrollmentInfo
            .userExternalCourseEnrolmentInfo.timeSpentOnCompletedCourses;
  }
}
