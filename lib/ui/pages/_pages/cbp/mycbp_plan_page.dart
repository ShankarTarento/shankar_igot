import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../constants/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../models/index.dart';
import '../../../../util/faderoute.dart';
import '../../../widgets/_signup/contact_us.dart';
import '../../../widgets/index.dart';
import '../../index.dart';

class MyCbpPlanPage extends StatefulWidget {
  final List<Course> allCourseList;
  final List<Course> upcomingCourseList;
  final List<Course> overdueCourseList;
  final List<Course> completedCourseList;
  final List<Course> aparCoursesList;
  MyCbpPlanPage(
      {Key? key,
      required this.allCourseList,
      required this.completedCourseList,
      required this.upcomingCourseList,
      required this.overdueCourseList,
      required this.aparCoursesList})
      : super(key: key);

  @override
  _MyCbpPlanPageState createState() => _MyCbpPlanPageState();
}

class _MyCbpPlanPageState extends State<MyCbpPlanPage> {
  ScrollController _scrollController = ScrollController();
  List<Course> allCourseList = [],
      upcomingCourseList = [],
      completedCourseList = [],
      overdueCourseList = [],
      aparCoursesList = [];

  ValueNotifier<int> allCourseCount = ValueNotifier<int>(0),
      upcomingCourseCount = ValueNotifier<int>(0),
      overdueCourseCount = ValueNotifier<int>(0),
      completedCourseCount = ValueNotifier<int>(0),
      aparCourseCount = ValueNotifier<int>(0);
  @override
  void initState() {
    super.initState();
    allCourseList = widget.allCourseList;
    upcomingCourseList = widget.upcomingCourseList;
    overdueCourseList = widget.overdueCourseList;
    completedCourseList = widget.completedCourseList;
    aparCoursesList = widget.aparCoursesList;
    allCourseCount.value = allCourseList.length;
    upcomingCourseCount.value = upcomingCourseList.length;
    overdueCourseCount.value = overdueCourseList.length;
    completedCourseCount.value = completedCourseList.length;
    aparCourseCount.value = aparCoursesList.length;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: buildLayout(),
      ),
    );
  }

  Widget buildLayout() {
    return Scaffold(
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll
              .disallowIndicator(); //previous code overscroll.disallowGlow();
          return true;
        },
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 50.0.w,
                floating: false,
                pinned: true,
                titleSpacing: 0,
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.mStaticAcbpBannerTitle,
                      style: GoogleFonts.lato(
                          color: AppColors.greys87,
                          fontSize: 16.0.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.12),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          FadeRoute(page: ContactUs()),
                        );
                      },
                      child: SvgPicture.asset(
                        'assets/img/help_icon.svg',
                        width: 56.0.w,
                        height: 56.0.w,
                      ),
                    ),
                  ],
                ),
              ),
            ];
          },
          body: Container(
            color: AppColors.whiteGradientOne,
            height: double.infinity.w,
            padding: EdgeInsets.all(16).r,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  planStatsWidget(),
                  SizedBox(height: 24.w),
                  CBPSearchPage(
                      completedCourseList: completedCourseList,
                      allCourseList: allCourseList,
                      upcomingCourseList: upcomingCourseList,
                      overdueCourseList: overdueCourseList,
                      aparCourseList: aparCoursesList),
                  SizedBox(
                    height: 120.w,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      bottomSheet: BottomBar(),
    );
  }

  Widget planStatsWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12).r,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12).r,
          border: Border.all(
            color: AppColors.grey04,
            width: 1.w,
          ),
          color: AppColors.appBarBackground),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16).r,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TitleBoldWidget(
                    AppLocalizations.of(context)!.mStaticAcbpBannerTitle)
              ],
            ),
          ),
          Divider(
            color: AppColors.grey08,
            thickness: 1.w,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8).r,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ValueListenableBuilder<int>(
                    valueListenable: allCourseCount,
                    builder: (context, value, _) {
                      return statsWidget(
                          title: AppLocalizations.of(context)!.mCommonAll,
                          count: allCourseCount.value.toString());
                    }),
                ValueListenableBuilder<int>(
                    valueListenable: aparCourseCount,
                    builder: (context, value, _) {
                      return statsWidget(
                          title: AppLocalizations.of(context)!.mStaticApar,
                          count: aparCourseCount.value.toString());
                    }),
                ValueListenableBuilder<int>(
                    valueListenable: upcomingCourseCount,
                    builder: (context, value, _) {
                      return statsWidget(
                          title: AppLocalizations.of(context)!.mStaticUpcoming,
                          count: upcomingCourseCount.value.toString());
                    }),
                ValueListenableBuilder<int>(
                    valueListenable: overdueCourseCount,
                    builder: (context, value, _) {
                      return statsWidget(
                          title: AppLocalizations.of(context)!.mStaticOverdue,
                          count: overdueCourseCount.value.toString());
                    }),
                ValueListenableBuilder<int>(
                    valueListenable: overdueCourseCount,
                    builder: (context, value, _) {
                      return statsWidget(
                          title: AppLocalizations.of(context)!.mCommoncompleted,
                          count: completedCourseCount.value.toString());
                    })
              ],
            ),
          )
        ],
      ),
    );
  }

  Column statsWidget({required String title, required String count}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleRegularGrey60(title),
        SizedBox(height: 4.w),
        TitleBoldWidget(
          count,
          color: AppColors.darkBlue,
          fontSize: 14.sp,
        )
      ],
    );
  }

  int getTimeDiff(String date1, String date2) {
    return DateTime.parse(
            DateFormat('yyyy-MM-dd').format(DateTime.parse(date1)))
        .difference(DateTime.parse(
            DateFormat('yyyy-MM-dd').format(DateTime.parse(date2))))
        .inDays;
  }
}
