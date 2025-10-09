import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:karmayogi_mobile/common_components/filter_pill/filter_pills.dart';
import 'package:karmayogi_mobile/common_components/my_learning_card/course_complete_card.dart';
import 'package:karmayogi_mobile/common_components/my_learning_card/course_inprogress_card.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/common_components/common_service/home_telemetry_service.dart';
import 'package:karmayogi_mobile/common_components/constants/widget_constants.dart';
import 'package:karmayogi_mobile/home_screen_components/models/learn_tab_model.dart';
import 'package:karmayogi_mobile/home_screen_components/my_learning_section/my_learning_service.dart';
import 'package:karmayogi_mobile/models/_arguments/course_toc_model.dart';
import 'package:karmayogi_mobile/models/_models/course_model.dart';
import 'package:karmayogi_mobile/models/_models/multilingual_text.dart';
import 'package:karmayogi_mobile/ui/pages/index.dart';
import 'package:karmayogi_mobile/ui/skeleton/pages/course_progress_skeleton_page.dart';
import 'package:karmayogi_mobile/ui/widgets/_common/show_all_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/custom_tabs.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyLearningCourseTab extends StatefulWidget {
  final TabItems tabItem;

  const MyLearningCourseTab({super.key, required this.tabItem});

  @override
  State<MyLearningCourseTab> createState() => _MyLearningCourseTabState();
}

class _MyLearningCourseTabState extends State<MyLearningCourseTab> {
  MultiLingualText? selectedFilter;
  Future<List<Course>>? enrollmentCourses;

  @override
  void initState() {
    selectedFilter = widget.tabItem.continueLearningModel?.filterItems[0];
    enrollmentCourses = getEnrollmentCourses();
    super.initState();
  }

  Future<List<Course>> getEnrollmentCourses() async {
    try {
      List<Course> enrollmentCourses =
          await HomeMyLearningService.getEnrollmentData(
        type: selectedFilter!.id,
        enrollmentApi: widget.tabItem.continueLearningModel!.enrollmentApi!,
      );

      return enrollmentCourses;
    } catch (err) {
      debugPrint('Error in _getContinueLearningCourses: $err');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return selectedFilter != null
        ? Column(
            children: [
              SizedBox(height: 12.w),
              Row(
                children: [
                  SizedBox(
                    width: 0.7.sw,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0).r,
                      child: _buildTabPills(),
                    ),
                  ),
                  Spacer(),
                  InkWell(
                      onTap: () {
                        navigateFunction(selectedFilter!.id);
                        // HomeTelemetryService.generateInteractTelemetryData(
                        //     TelemetryIdentifier.showAll,
                        //     subType: TelemetrySubType.myLearning);
                      },
                      child: ShowAllWidget())
                ],
              ),
              FutureBuilder(
                  future: enrollmentCourses,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                          height: 230.w,
                          child: ListView.separated(
                            itemBuilder: (context, index) =>
                                const CourseProgressSkeletonPage(),
                            separatorBuilder: (context, index) =>
                                SizedBox(width: 8.w),
                            itemCount: 3,
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                          ));
                    }
                    if (snapshot.data != null) {
                      return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 12.w),
                            buildBody(
                                type: selectedFilter!.id,
                                courseList: snapshot.data ?? []),
                          ]);
                    }
                    return SizedBox();
                  }),
            ],
          )
        : SizedBox();
  }

  void navigateFunction(String type) {
    try {
      switch (type) {
        case WidgetConstants.myLearningCompleted:
          CustomTabs.setTabItem(context, 3, true,
              tabIndex: 0, pillIndex: 1, isFromHome: true);
          break;
        case WidgetConstants.inProgress:
          CustomTabs.setTabItem(context, 3, true,
              tabIndex: 0, pillIndex: 0, isFromHome: true);
          break;
        default:
          return;
      }
    } catch (e) {
      debugPrint("$e");
    }
  }

  Widget buildBody({required String type, required List<Course> courseList}) {
    Widget _buildCourseList(
        List<Course> courses, Widget Function(Course) cardBuilder) {
      return SizedBox(
        height: 220.w,
        child: courses.isNotEmpty
            ? AnimationLimiter(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16.0).r,
                            child: InkWell(
                              onTap: () {
                                onTapCard(courses[index]);
                              },
                              child: cardBuilder(courses[index]),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            : NoDataWidget(
                message: AppLocalizations.of(context)!.mNoResourcesFound,
                isCompleted: type == WidgetConstants.myLearningCompleted),
      );
    }

    switch (type) {
      case WidgetConstants.myLearningCompleted:
        return _buildCourseList(
            courseList, (course) => CourseCompleteCard(course: course));

      case WidgetConstants.inProgress:
        return _buildCourseList(
            courseList, (course) => CourseInprogressCard(course: course));

      default:
        return SizedBox();
    }
  }

  Widget _buildTabPills() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
            widget.tabItem.continueLearningModel!.filterItems.length,
            (index) => FilterPills(
                filter:
                    widget.tabItem.continueLearningModel!.filterItems[index],
                isSelected: selectedFilter!.id ==
                    widget.tabItem.continueLearningModel!.filterItems[index].id,
                onClickedPill: (value) {
                  setState(() {
                    selectedFilter = value;
                    enrollmentCourses = getEnrollmentCourses();
                  });
                })),
      ),
    );
  }

  void onTapCard(Course course) {
    HomeTelemetryService.generateInteractTelemetryData(course.raw['courseId'],
        primaryCategory: course.courseCategory,
        subType: TelemetrySubType.myLearning,
        clickId: TelemetryIdentifier.cardContent);
    if (course.raw['content']['status'] == 'Live') {
      Navigator.push(
          context,
          FadeRoute(
              page: CourseTocPage(
                  arguments:
                      CourseTocModel.fromJson({'courseId': course.id}))));
    } else {
      Helper.showSnackBarMessage(
          context: context,
          text:
              "This ${course.raw['content']['primaryCategory']} has been archived and is no longer available.",
          bgColor: AppColors.darkBlue);
    }
  }
}
