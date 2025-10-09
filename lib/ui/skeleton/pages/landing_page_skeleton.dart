import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/hub_categories.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/home_page/scheduled_assesment/widgets/scheduled_assesment_skeleton.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/learn/karma_programs/widgets/karma_program_strip_skeleton.dart';
import 'package:karmayogi_mobile/ui/skeleton/pages/course_card_skeleton_page.dart';
import 'package:karmayogi_mobile/ui/skeleton/pages/course_progress_skeleton_page.dart';
import 'package:karmayogi_mobile/ui/skeleton/widgets/myacticities_card_skeleton.dart';
import 'package:karmayogi_mobile/ui/widgets/_events/widgets/todays_event_skeleton.dart';


class LandingPageSkeletonPage extends StatefulWidget {
  const LandingPageSkeletonPage({Key? key}) : super(key: key);

  @override
  State<LandingPageSkeletonPage> createState() =>
      _LandingPageSkeletonPageState();
}

class _LandingPageSkeletonPageState extends State<LandingPageSkeletonPage> with TickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _appBarSkeleton(),
              _hubStripSkeleton(),
              _myActivitySkeleton(),
              _todayEventSkeleton(),
              Padding(
                padding: EdgeInsets.only(bottom: 8).r,
                child: KarmaProgramStripWidgetSkeleton(),
              ),
              Container(
                margin: EdgeInsets.only(top: 16, bottom: 16).r,
                child: CourseCardSkeletonPage(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: AppColors.appBarBackground,
        padding: EdgeInsets.only(left: 8, right: 8).r,
        height: 90.w,
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (_) {
            return Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ContainerSkeleton(
                    width: 40.w,
                    height: 40.w,
                    radius: 50.r,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4).r,
                    child: ContainerSkeleton(
                      width: 40.w,
                      height: 12.w,
                      radius: 8.r,
                    ),
                  ),
                ],
              ),
            );
          }),
        )
      ),
    );
  }

  Widget _appBarSkeleton() {
    return Container(
      color: AppColors.appBarBackground,
      height: (kToolbarHeight + 8).w,
      padding: EdgeInsets.symmetric(horizontal: 16).r,
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8).w,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(children: [
              ContainerSkeleton(
                width: 52.w,
                height: 52.w,
                radius: 50.r,
              ),
              SizedBox(width: 8.w)
            ]),
            Spacer(),
            ContainerSkeleton(
              width: 32.w,
              height: 32.w,
              radius: 50.r,
            ),
            SizedBox(width: 8.w),
            ContainerSkeleton(
              width: 32.w,
              height: 32.w,
              radius: 50.r,
            ),
          ],
        ),
      ),
      // pinned: true,
    );
  }

  Widget _hubStripSkeleton() {
    return Container(
      color: AppColors.appBarBackground,
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.only(top: 8, bottom: 8).w,
        height: 90.w,
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          children: HUBS(context: context).map((hub) => Container(
              margin: const EdgeInsets.only(left: 10, right: 10).w,
              child: Column(
                children: <Widget>[
                  ContainerSkeleton(
                    width: 52.w,
                    height: 40.w,
                    radius: 50.r,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4).r,
                    child: ContainerSkeleton(
                      width: 52.w,
                      height: 12.w,
                      radius: 8.r,
                    ),
                  )
                ],
              ),
          ))
              .toList(),
        ),
      ),
    );
  }

  Widget _myActivitySkeleton() {
    return Column(
      children: [
        Container(
            margin: EdgeInsets.all(16),
            child: MyacticitiesCardSkeleton()),
        Padding(
          padding: const EdgeInsets.all(16.0).r,
          child: ScheduledAssesmentSkeleton(),
        ),
        Container(
          height: 300.w,
          child: ListView.separated(
            itemBuilder: (context, index) =>
            const CourseProgressSkeletonPage(),
            separatorBuilder: (context, index) =>
                SizedBox(width: 8.w),
            itemCount: 3,
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
          ),
        )
      ],
    );
  }

  Widget _todayEventSkeleton() {
    return Container(
      margin: EdgeInsets.only(top: 16).r,
      height: 160.w,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: 3,
          itemBuilder: (context, index) => TodaysEventSkeleton()),
    );
  }
}
