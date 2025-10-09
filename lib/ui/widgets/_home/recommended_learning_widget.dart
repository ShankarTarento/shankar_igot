import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../constants/index.dart';
import '../../../models/_arguments/index.dart';
import '../../../models/index.dart';
import '../../../util/index.dart';
import 'course_card_widget.dart';

class RecommendedLearningWidget extends StatefulWidget {
  final List<Course> availableCourses;
  final List<Course> inprogressCourses;
  final List<Course> completedCourses;
  final BuildContext parentContext;
  final bool showAll;

  const RecommendedLearningWidget(
      {super.key,
      required this.availableCourses,
      required this.inprogressCourses,
      required this.completedCourses,
      required this.parentContext,
      this.showAll = false});

  @override
  State<RecommendedLearningWidget> createState() =>
      RecommendedLearningWidgetState();
}

class RecommendedLearningWidgetState extends State<RecommendedLearningWidget>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  List<Widget> tabViewItems = [];
  List<Widget> tabNames = [];

  @override
  void initState() {
    super.initState();
    int length = getTabItemCount();
    tabController = TabController(initialIndex: 0, length: length, vsync: this);
    setTabs();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _generateInteractTelemetryData(String contentId,
      {required String subType,
      String? primaryCategory,
      String? objectType}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.appHomePagePageId,
        contentId: contentId,
        subType: subType,
        env: TelemetryEnv.home,
        objectType: primaryCategory != null ? primaryCategory : objectType,
        clickId: TelemetryClickId.cardContent);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16, bottom: 16).r,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: tabNames.map((element) => element).toList()),
            ),
          ),
          Expanded(
            child: SizedBox(
              height: widget.showAll ? 0.8.sh : 341.w,
              child: TabBarView(
                controller: tabController,
                children: tabViewItems
                    .map((element) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8).r,
                        child: element))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int getCount(int index) {
    if (index == 0) {
      return widget.availableCourses.length;
    } else if (index == 1) {
      return widget.inprogressCourses.length;
    } else {
      return widget.completedCourses.length;
    }
  }

  Future<void> doActionOnCard(TelemetryDataModel value,
      {required String subType}) async {
    await _generateInteractTelemetryData(value.id,
        primaryCategory: value.contentType, subType: subType);
    Navigator.pushNamed(
      context,
      AppUrl.courseTocPage,
      arguments: CourseTocModel(courseId: value.id),
    );
  }

  int getTabItemCount() {
    int count = 0;
    if (widget.availableCourses.isNotEmpty) {
      count++;
      tabViewItems.add(CourseCardWidget(
          courseList: widget.availableCourses,
          category: RECOMMENDEDCOURSEPILLS(context: widget.parentContext)[0],
          onCallback: (value) => doActionOnCard(value,
              subType: TelemetrySubType.recommentedLearningAvailable),
          showAll: widget.showAll));
    }
    if (widget.inprogressCourses.isNotEmpty) {
      count++;
      tabViewItems.add(CourseCardWidget(
          courseList: widget.inprogressCourses,
          category: RECOMMENDEDCOURSEPILLS(context: widget.parentContext)[1],
          onCallback: (value) => doActionOnCard(value,
              subType: TelemetrySubType.recommentedLearningInprogress),
          showAll: widget.showAll));
    }
    if (widget.completedCourses.isNotEmpty) {
      count++;
      tabViewItems.add(CourseCardWidget(
          courseList: widget.completedCourses,
          category: RECOMMENDEDCOURSEPILLS(context: widget.parentContext)[2],
          onCallback: (value) => doActionOnCard(value,
              subType: TelemetrySubType.recommentedLearningCompleted),
          showAll: widget.showAll));
    }
    return count;
  }

  Widget tabPill({required int index, required String text}) {
    return InkWell(
      onTap: () {
        tabController.index = index;
        tabNames.clear();
        setTabs();
        setState(() {});
      },
      child: Container(
        margin: EdgeInsets.only(right: 16).r,
        padding: EdgeInsets.only(left: 12, right: 12, top: 6, bottom: 6).r,
        decoration: BoxDecoration(
            color: index == tabController.index
                ? AppColors.darkBlue
                : Colors.transparent,
            borderRadius: BorderRadius.circular(40).r,
            border: Border.all(
                color: index == tabController.index
                    ? AppColors.darkBlue
                    : AppColors.grey24)),
        child: Text(
          text,
          style: GoogleFonts.lato(
              fontSize: 13.w,
              fontWeight: FontWeight.w400,
              color: index == tabController.index
                  ? AppColors.appBarBackground
                  : AppColors.greys60),
        ),
      ),
    );
  }

  void setTabs() {
    int index = 0;
    if (widget.availableCourses.isNotEmpty) {
      tabNames.add(tabPill(
          text: RECOMMENDEDCOURSEPILLS(context: widget.parentContext)[0] +
              ' (${getCount(0)})',
          index: index));
      index++;
    }
    if (widget.inprogressCourses.isNotEmpty) {
      tabNames.add(tabPill(
          text: RECOMMENDEDCOURSEPILLS(context: widget.parentContext)[1] +
              (' (${getCount(1)})'),
          index: index));
      index++;
    }
    if (widget.completedCourses.isNotEmpty) {
      tabNames.add(tabPill(
          text: RECOMMENDEDCOURSEPILLS(context: widget.parentContext)[2] +
              (' (${getCount(2)})'),
          index: index));
      index++;
    }
  }
}
