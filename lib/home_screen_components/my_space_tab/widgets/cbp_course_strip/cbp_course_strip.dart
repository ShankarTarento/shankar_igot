import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/common_components/filter_pill/filter_pills.dart';
import 'package:karmayogi_mobile/constants/_constants/app_routes.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/common_components/common_service/home_telemetry_service.dart';
import 'package:karmayogi_mobile/common_components/constants/widget_constants.dart';
import 'package:karmayogi_mobile/home_screen_components/models/my_space_model.dart';
import 'package:karmayogi_mobile/models/_arguments/course_toc_model.dart';
import 'package:karmayogi_mobile/models/_models/course_model.dart';
import 'package:karmayogi_mobile/models/_models/multilingual_text.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/my_learnings/no_data_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/_home/course_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CbpCourseStrip extends StatefulWidget {
  final MySpaceTabItem tabItem;
  final List<Course> upcomingCourses;
  final List<Course> overdueCourses;
  final List<Course> completedCourses;
  final List<Course> allCourses;
  final List<Course> aparCourses;

  const CbpCourseStrip(
      {super.key,
      required this.tabItem,
      required this.upcomingCourses,
      required this.overdueCourses,
      required this.completedCourses,
      required this.allCourses,
      required this.aparCourses});

  @override
  State<CbpCourseStrip> createState() => _CbpCourseStripState();
}

class _CbpCourseStripState extends State<CbpCourseStrip>
    with SingleTickerProviderStateMixin {
  MultiLingualText? selectedFilter;

  @override
  void initState() {
    tabController = TabController(
      length: widget.tabItem.filterItems.length,
      vsync: this,
    );
    setTabIndex();
    super.initState();
  }

  late TabController tabController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 16).r,
                child: _buildTabPills(),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 330.w,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16).r,
            child: TabBarView(
              controller: tabController,
              children: List.generate(
                widget.tabItem.filterItems.length,
                (index) => courseCardWidget(
                    courseList: getCourseList(
                        type:
                            widget.tabItem.filterItems[index].id.toLowerCase()),
                    category: widget.tabItem.filterItems[index].id),
              ),
            ),
          ),
        )
      ],
    );
  }

  List<Course> getCourseList({required String type}) {
    switch (type) {
      case WidgetConstants.completed:
        return widget.completedCourses;
      case WidgetConstants.overdue:
        return widget.overdueCourses;
      case WidgetConstants.all:
        return widget.allCourses;
      case WidgetConstants.upcoming:
        return widget.upcomingCourses;
      case WidgetConstants.apar:
        return widget.aparCourses;
      default:
        return [];
    }
  }

  Widget _buildTabPills() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
            widget.tabItem.filterItems.length,
            (index) => FilterPills(
                  filter: widget.tabItem.filterItems[index],
                  isSelected: selectedFilter!.id ==
                      widget.tabItem.filterItems[index].id,
                  onClickedPill: (value) {
                    setState(() {
                      selectedFilter = value;
                      tabController.index = index;
                    });
                  },
                  count: getCount(type: widget.tabItem.filterItems[index].id),
                )),
      ),
    );
  }

  String getCount({required String type}) {
    switch (type) {
      case WidgetConstants.completed:
        return widget.completedCourses.length.toString();
      case WidgetConstants.overdue:
        return widget.overdueCourses.length.toString();
      case WidgetConstants.all:
        return widget.allCourses.length.toString();
      case WidgetConstants.upcoming:
        return widget.upcomingCourses.length.toString();
      case WidgetConstants.apar:
        return widget.aparCourses.length.toString();
      default:
        return "";
    }
  }

  Widget courseCardWidget(
      {required List<Course> courseList, required String category}) {
    String message;
    if (category == WidgetConstants.upcoming) {
      message = AppLocalizations.of(context)!.mStaticSeeAllUpcoming;
    } else if (category == WidgetConstants.completed) {
      message = AppLocalizations.of(context)!.mStaticSeeCompletedContent;
    } else {
      message =
          AppLocalizations.of(context)!.mStaticSeeContentForWhichDueDatePassed;
    }
    return courseList.length > 0
        ? ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: courseList.length,
            itemBuilder: (context, index) {
              return Row(children: [
                InkWell(
                  onTap: () async {
                    String telemetryId = selectedFilter!.id ==
                            WidgetConstants.upcoming
                        ? TelemetryIdentifier.upcoming
                        : selectedFilter!.id == WidgetConstants.overdue
                            ? TelemetryIdentifier.overdue
                            : selectedFilter!.id == WidgetConstants.completed
                                ? TelemetryIdentifier.completed
                                : "";
                    HomeTelemetryService.generateInteractTelemetryData(
                        courseList[index].id,
                        primaryCategory: courseList[index].courseCategory,
                        subType: "${TelemetrySubType.myIgot}-$telemetryId",
                        clickId: TelemetryIdentifier.cardContent);
                    Navigator.pushNamed(
                      context,
                      AppUrl.courseTocPage,
                      arguments: CourseTocModel.fromJson(
                        {'courseId': courseList[index].id},
                      ),
                    );
                  },
                  child: CourseCard(
                    course: courseList[index],
                  ),
                ),
              ]);
            })
        : NoDataWidget(message: message);
  }

  void setTabIndex() {
    if (widget.aparCourses.isNotEmpty) {
      int index = 0;

      for (int i = 0; i < widget.tabItem.filterItems.length; i++) {
        if (widget.tabItem.filterItems[i].id == WidgetConstants.apar) {
          index = i;
          break;
        }
      }

      tabController.index = index;
    } else if (widget.upcomingCourses.isNotEmpty) {
      int index = 0;

      for (int i = 0; i < widget.tabItem.filterItems.length; i++) {
        if (widget.tabItem.filterItems[i].id == WidgetConstants.upcoming) {
          index = i;
          break;
        }
      }

      tabController.index = index;
    } else if (widget.upcomingCourses.isEmpty &&
        widget.overdueCourses.isNotEmpty) {
      int index = 0;

      for (int i = 0; i < widget.tabItem.filterItems.length; i++) {
        if (widget.tabItem.filterItems[i].id == WidgetConstants.overdue) {
          index = i;
          break;
        }
      }

      tabController.index = index;
    } else if (widget.overdueCourses.isEmpty &&
        widget.completedCourses.isNotEmpty) {
      int index = 0;

      for (int i = 0; i < widget.tabItem.filterItems.length; i++) {
        if (widget.tabItem.filterItems[i].id == WidgetConstants.completed) {
          index = i;
          break;
        }
      }

      tabController.index = index;
    } else if (widget.completedCourses.isEmpty &&
        widget.overdueCourses.isEmpty) {
      int index = 0;

      for (int i = 0; i < widget.tabItem.filterItems.length; i++) {
        if (widget.tabItem.filterItems[i].id == WidgetConstants.all) {
          index = i;
          break;
        }
      }

      tabController.index = index;
    } else {
      tabController.index = 0;
    }
    selectedFilter = widget.tabItem.filterItems[tabController.index];
  }
}
