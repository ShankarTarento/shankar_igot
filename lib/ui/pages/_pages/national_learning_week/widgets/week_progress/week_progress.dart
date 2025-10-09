import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/national_learning_week/services/national_learning_week_view_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/content_info.dart';
import 'package:karmayogi_mobile/ui/widgets/title_regular_grey60.dart';
import 'package:karmayogi_mobile/util/index.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:karmayogi_mobile/models/_models/week_progress_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WeekProgress extends StatefulWidget {
  final String title;
  final String? infoText;
  const WeekProgress({super.key, required this.title, this.infoText});
  static final _controller = PageController();

  @override
  State<WeekProgress> createState() => _WeekProgressState();
}

class _WeekProgressState extends State<WeekProgress> {
  @override
  void initState() {
    weekProgress = NationalLearningWeekViewModel().getUserWeekProgress();
    getUserInsightFuture =
        Provider.of<ProfileRepository>(context, listen: false)
            .getInsights(context);
    super.initState();
  }

  bool _isExpanded = false;

  Future<dynamic>? getUserInsightFuture;

  late Future<WeekProgressModel?> weekProgress;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.blue209,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8).r,
      child: ExpansionTile(
        textColor: AppColors.greys,
        iconColor: AppColors.greys,
        trailing:
            Icon(_isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down),
        title: _buildTitle(),
        onExpansionChanged: (bool expanding) => setState(() {
          _isExpanded = expanding;
        }),
        children: [
          FutureBuilder<WeekProgressModel?>(
              future: weekProgress,
              builder: (context, snapshot) {
                return Stack(
                  children: [
                    _buildProgressCard(snapshot.data),
                    _buildProfileAvatar(snapshot.data),
                  ],
                );
              }),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        Text(
          widget.title,
          style: GoogleFonts.lato(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        widget.infoText != null
            ? ContentInfo(
                infoMessage: widget.infoText!,
              )
            : SizedBox(),
      ],
    );
  }

  Widget _buildProgressCard(WeekProgressModel? weekProgres) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12).r,
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ).r,
                child: Image.asset(
                  'assets/img/nlw_profile.jpeg',
                  fit: BoxFit.cover,
                  width: 1.sw,
                  height: 70.w,
                ),
              ),
              weekProgres?.rank != null
                  ? IntrinsicWidth(
                      child: Container(
                        margin: EdgeInsets.only(top: 25, left: 90).w,
                        padding: EdgeInsets.only(
                                left: 16, right: 16, top: 6, bottom: 6)
                            .r,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: AppColors.appBarBackground),
                        child: Center(
                          child: Text(
                            '#${weekProgres?.rank} Rank',
                            style: GoogleFonts.lato(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkBlue),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    )
                  : SizedBox()
            ],
          ),
          Container(
            width: 1.sw,
            decoration: BoxDecoration(
              color: AppColors.keyHighlightBackground,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ).r,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 90.0, top: 10).r,
                  child: Text(
                    weekProgres?.fullname ?? '',
                    style: GoogleFonts.lato(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 10.w),
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0).r,
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      runSpacing: 10.w,
                      spacing: 10.w,
                      children: [
                        _insightsWidget(
                            image: Container(
                              height: 28.w,
                              width: 28.w,
                              padding: EdgeInsets.all(6).r,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28).r,
                                gradient: LinearGradient(colors: [
                                  AppColors.yellow1.withValues(alpha: 0.15),
                                  AppColors.pink1.withValues(alpha: 0.15),
                                ]),
                              ),
                              child: SvgPicture.asset(
                                'assets/img/course_icon.svg',
                                height: 16.w,
                                width: 16.w,
                                colorFilter: ColorFilter.mode(
                                    AppColors.primaryOne, BlendMode.srcIn),
                              ),
                            ),
                            subTitle: AppLocalizations.of(context)!
                                .mCommonLearningHours,
                            title: weekProgres?.totalLearningHours ?? '-'),
                        _insightsWidget(
                            image: Container(
                              height: 28.w,
                              width: 28.w,
                              padding: EdgeInsets.all(6).r,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(28).r,
                                  gradient: LinearGradient(colors: [
                                    AppColors.yellow2.withValues(alpha: 0.24),
                                    AppColors.yellow3.withValues(alpha: 0.24),
                                  ])),
                              child: Image.asset(
                                'assets/img/certificate.png',
                                height: 16.w,
                                width: 16.w,
                              ),
                            ),
                            subTitle: AppLocalizations.of(context)!
                                .mCommonCertificates,
                            title: weekProgres?.count ?? '-'),
                        _insightsWidget(
                            image: Container(
                              height: 28.w,
                              width: 28.w,
                              padding: EdgeInsets.all(6).r,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(28).r,
                                  color: AppColors.lightBackground),
                              child: SvgPicture.asset(
                                'assets/img/kp_icon.svg',
                                height: 16.w,
                                width: 16.w,
                              ),
                            ),
                            subTitle: AppLocalizations.of(context)!
                                .mStaticKarmaPoints,
                            title: weekProgres?.totalPoints ?? '-')
                      ],
                    ),
                  ),
                ),
                Column(
                  children: [
                    FutureBuilder<dynamic>(
                        future: getUserInsightFuture,
                        builder: (context, snapshot) {
                          if (snapshot.data != null) {
                            var userInsights = snapshot.data;

                            return Container(
                              height: 84.w,
                              width: 1.sw,
                              margin: EdgeInsets.all(8).r,
                              padding: EdgeInsets.all(12).r,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4).r,
                                color: AppColors.yellow4,
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: PageView.builder(
                                        controller: WeekProgress._controller,
                                        itemCount:
                                            userInsights['nudges'].length,
                                        itemBuilder: (context, pageIndex) {
                                          return Container(
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: userInsights['nudges'][
                                                                      pageIndex]
                                                                  ['growth'] ==
                                                              'negative' ||
                                                          userInsights['nudges']
                                                                      [
                                                                      pageIndex]
                                                                  ['progress'] <
                                                              1
                                                      ? 1.sw - 100.w
                                                      : 1.sw - 175.w,
                                                  child: Text(
                                                    trimQuotes(
                                                        userInsights['nudges']
                                                                [pageIndex]
                                                            ['label']),
                                                    style: GoogleFonts.lato(
                                                        fontSize: 14.sp),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Spacer(),
                                                userInsights['nudges']
                                                                [pageIndex]
                                                            ['growth'] !=
                                                        'negative'
                                                    ? userInsights['nudges']
                                                                    [pageIndex]
                                                                ['progress'] >=
                                                            1
                                                        ? Row(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .arrow_upward,
                                                                size: 18.sp,
                                                                color: AppColors
                                                                    .positiveLight,
                                                              ),
                                                              TitleRegularGrey60(
                                                                  '+${userInsights['nudges'][pageIndex]['progress']}%',
                                                                  color: AppColors
                                                                      .positiveLight)
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
                                    controller: WeekProgress._controller,
                                    count: userInsights['nudges'].length,
                                    effect: const ExpandingDotsEffect(
                                      activeDotColor: Colors.orange,
                                      dotColor: Colors.grey,
                                      dotHeight: 4,
                                      dotWidth: 4,
                                      spacing: 4,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return SizedBox();
                        }),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar(WeekProgressModel? weekProgres) {
    return Positioned(
      top: 40.w,
      left: 16.w,
      child: CircleAvatar(
        radius: 32.r,
        backgroundColor: AppColors.appBarBackground,
        child: weekProgres?.profileImage == null
            ? CircleAvatar(
                radius: 30.r,
                backgroundColor: AppColors.greys,
                child: Text(
                  weekProgres?.fullname != null
                      ? Helper.getInitialsNew(weekProgres?.fullname ?? "")
                      : "",
                  style: GoogleFonts.lato(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.appBarBackground,
                  ),
                ),
              )
            : CircleAvatar(
                radius: 30.r,
                backgroundImage: NetworkImage(weekProgres!.profileImage!),
              ),
      ),
    );
  }

  Widget _insightsWidget({
    required Widget image,
    required String title,
    required String subTitle,
  }) {
    return Container(
      height: 65.w,
      width: 170.w,
      padding: EdgeInsets.all(10).r,
      decoration: BoxDecoration(
        color: AppColors.appBarBackground,
        border: Border.all(color: Colors.grey.shade400, width: 1.5),
        borderRadius: BorderRadius.circular(8).r,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          image,
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.greys,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.w),
              Text(
                subTitle,
                style: GoogleFonts.montserrat(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String trimQuotes(String input) {
    if (input.startsWith('"') && input.endsWith('"')) {
      return input.substring(1, input.length - 1);
    }
    return input;
  }
}
