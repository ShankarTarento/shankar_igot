import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/utils/profile_constants.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:provider/provider.dart';
import '../../../constants/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../models/index.dart';
import '../../../respositories/index.dart';
import '../../../util/telemetry_repository.dart';
import '../../screens/_screens/profile/model/profile_dashboard_arg_model.dart';
import '../_activities/_leaderboard/leaderboard_title_widget.dart';
import '../index.dart';

class MyactivityCard extends StatelessWidget {
  final Profile? profileDetails;
  final UserEnrollmentInfo? enrollmentInfo;
  final weeklyClaps;
  final String? leaderboardRank;

  MyactivityCard(
      {Key? key,
      this.profileDetails,
      this.enrollmentInfo,
      this.weeklyClaps,
      this.leaderboardRank})
      : super(key: key);

  final _profileCardkey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Selector<ProfileRepository, double>(
        selector: (context, profileRepo) => profileRepo.profileCompletionPercentage,
        builder: (context, profilePercentage, child) {
          bool isProfileCardExpanded =
              Provider.of<LandingPageRepository>(context, listen: false)
                  .isProfileCardExpanded;
          if (isProfileCardExpanded) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Future.delayed(Duration(seconds: 3), () {
                final context = _profileCardkey.currentContext;
                if (context != null) {
                  final size = context.size;
                  if (size != null) {
                    Provider.of<LandingPageRepository>(context, listen: false)
                        .setProfileCardSize(size);
                  }
                }
              });
            });
          }

          return Container(
            margin: EdgeInsets.all(16).r,
            decoration: BoxDecoration(
              color: AppColors.grey08,
              borderRadius: BorderRadius.circular(12.0).r,
            ),
            child: Column(
              key: _profileCardkey,
              children: [
                Container(
                  width: 1.sw,
                  decoration: BoxDecoration(
                    color: AppColors.appBarBackground,
                    borderRadius: BorderRadius.circular(12.0).w,
                  ),
                  child: Consumer<LandingPageRepository>(
                      builder: (context, landingPageRepository, _) {
                    return ExpansionTile(
                      onExpansionChanged: (value) async {
                        Provider.of<LandingPageRepository>(context,
                                listen: false)
                            .changeExpansionProfileCard(value);
                      },
                      title: InkWell(
                        onTap: () {
                          _generateInteractTelemetryData(null,
                              edataId:
                                  TelemetryIdentifier.profileUpdateProgress,
                              context: context);
                          Navigator.pushNamed(context, AppUrl.profileDashboard);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                profileDetails?.firstName != null
                                    ? '${AppLocalizations.of(context)!.mCommonHey} ' +
                                        Helper.capitalizeFirstLetter(
                                            profileDetails!.firstName) +
                                        '!'
                                    : '${AppLocalizations.of(context)!.mCommonHey}, ',
                                style: GoogleFonts.lato(
                                  color: AppColors.greys87,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16.sp,
                                  letterSpacing: 0.12.sp,
                                )),
                            SizedBox(height: 8.w),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 69.w,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5).w,
                                    child: LinearProgressIndicator(
                                      minHeight: 4.w,
                                      backgroundColor: AppColors.grey16,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.lightGreen,
                                      ),
                                      value: profilePercentage / 100,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                TitleRegularGrey60(
                                  AppLocalizations.of(context)!
                                      .mCommonProfileIsComplete(
                                          profilePercentage),
                                  maxLines: 2,
                                ),
                                SizedBox(width: 8.w),
                                Icon(
                                  Icons.keyboard_arrow_right,
                                  size: 12.sp,
                                  color: AppColors.deepBlue,
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      iconColor: AppColors.darkBlue,
                      collapsedIconColor: AppColors.darkBlue,
                      initiallyExpanded:
                          landingPageRepository.isProfileCardExpanded,
                      childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 0).w,
                      children: [
                        Divider(
                          color: AppColors.grey08,
                          thickness: 1,
                        ),
                        SizedBox(height: 15.5.w),
                        YourStats(
                            getInprogressCount(),
                            getCertificateIssuedCount(),
                            getTime(), myLearningInProgressCallback: () {
                          CustomTabs.setTabItem(context, 3, true,
                              tabIndex: 0, pillIndex: 0, isFromHome: true);
                        }, myLearningCompletedCallback: () {
                          CustomTabs.setTabItem(context, 3, true,
                              tabIndex: 0, pillIndex: 1, isFromHome: true);
                        }),
                        SizedBox(height: 15.5.w),
                        Divider(
                          color: AppColors.grey08,
                          thickness: 1,
                        ),
                        /** Leaderboard changes start**/
                        IntrinsicHeight(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (enrollmentInfo != null &&
                                  enrollmentInfo!.userCourseEnrolmentInfo
                                          .karmaPoints !=
                                      0)
                                Expanded(
                                  child: KarmaPointWidget(
                                      karmapoint: enrollmentInfo!
                                          .userCourseEnrolmentInfo.karmaPoints
                                          .toString()),
                                ),
                              if (enrollmentInfo != null &&
                                  enrollmentInfo!.userCourseEnrolmentInfo
                                          .karmaPoints !=
                                      0)
                                VerticalDivider(
                                  color: AppColors.grey08,
                                  thickness: 1,
                                ),
                              if (leaderboardRank != '')
                                Expanded(
                                  child: LeaderboardTitleWidget(
                                      rank: leaderboardRank),
                                ),
                              if (leaderboardRank != '')
                                VerticalDivider(
                                  color: AppColors.grey08,
                                  thickness: 1,
                                ),
                              Expanded(
                                child: WeeklyclapTitleWidget(
                                    weeklyClaps: weeklyClaps.isNotEmpty
                                        ? weeklyClaps
                                        : {},
                                    showInRow: (leaderboardRank != '' ||
                                            (enrollmentInfo != null &&
                                                enrollmentInfo!
                                                        .userCourseEnrolmentInfo
                                                        .karmaPoints !=
                                                    0))
                                        ? false
                                        : true,
                                    enableNavigationForWeeklyClaps: true),
                              ),
                            ],
                          ),
                        ),
                        /** Leaderboard changes end**/
                        SizedBox(height: 8.w),
                      ],
                    );
                  }),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 8).w,
                  decoration: BoxDecoration(
                      // color: AppColors.grey08,
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(12)).r),
                  child: InkWell(
                    onTap: () => Navigator.pushNamed(
                        context, AppUrl.profileDashboard,
                        arguments: ProfileDashboardArgModel(
                            type: ProfileConstants.currentUser)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/img/activity_icon.svg',
                              width: 24.w,
                              height: 24.w,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                                AppLocalizations.of(context)!
                                    .mStaticShowMyActivities,
                                style: GoogleFonts.lato(
                                  color: AppColors.darkBlue,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14.sp,
                                  letterSpacing: 0.12.sp,
                                )),
                          ],
                        ),
                        SvgPicture.asset(
                          'assets/img/arrow_forward_blue.svg',
                          width: 24.w,
                          height: 24.w,
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }

  int getTime() {
    int time = 0;
    if (enrollmentInfo != null) {
      time =
          enrollmentInfo!.userCourseEnrolmentInfo.timeSpentOnCompletedCourses +
              enrollmentInfo!
                  .userExternalCourseEnrolmentInfo.timeSpentOnCompletedCourses;
    }
    return time;
  }

  int getCertificateIssuedCount() {
    int count = 0;
    if (enrollmentInfo != null) {
      count = enrollmentInfo!.userCourseEnrolmentInfo.certificatesIssued +
          enrollmentInfo!.userExternalCourseEnrolmentInfo.certificatesIssued;
    }
    return count;
  }

  int getInprogressCount() {
    int count = 0;
    if (enrollmentInfo != null) {
      count = enrollmentInfo!.userCourseEnrolmentInfo.coursesInProgress +
          enrollmentInfo!.userExternalCourseEnrolmentInfo.coursesInProgress;
    }
    return count;
  }

  void _generateInteractTelemetryData(String? contentId,
      {String subType = '',
      String? edataId,
      required BuildContext context}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.homePageId,
        contentId: contentId ?? "",
        subType: subType,
        env: TelemetryEnv.home,
        clickId: edataId ?? "");
    await telemetryRepository.insertEvent(eventData: eventData);
  }
}
