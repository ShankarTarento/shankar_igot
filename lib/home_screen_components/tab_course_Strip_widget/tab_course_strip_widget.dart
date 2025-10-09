import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/common_components/content_strips/course_strip_widget/widgets/course_strip.dart';
import 'package:karmayogi_mobile/common_components/content_strips/service/course_strip_service.dart';
import 'package:karmayogi_mobile/common_components/models/content_strip_model.dart';
import 'package:karmayogi_mobile/common_components/view_all_courses/view_all_courses.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/common_components/constants/widget_constants.dart';
import 'package:karmayogi_mobile/home_screen_components/custom_tab_bar/custom_tab_bar.dart';
import 'package:karmayogi_mobile/home_screen_components/models/learn_tab_model.dart';
import 'package:karmayogi_mobile/home_screen_components/my_learning_section/widgets/my_learning_course_tab.dart';
import 'package:karmayogi_mobile/home_screen_components/my_learning_section/widgets/my_learning_event_tab.dart';
import 'package:karmayogi_mobile/home_screen_components/providers_external_courses/providers_external_courses.dart';
import 'package:karmayogi_mobile/home_screen_components/tab_course_Strip_widget/filter_dropdown.dart';
import 'package:karmayogi_mobile/home_screen_components/training_institutes/training_institutes.dart';
import 'package:karmayogi_mobile/models/_models/course_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/my_learnings/no_data_widget.dart';
import 'package:karmayogi_mobile/ui/skeleton/pages/course_card_skeleton_page.dart';
import 'package:karmayogi_mobile/ui/widgets/title_widget/title_widget.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TabCourseStripWidget extends StatefulWidget {
  final LearnTabModel tabData;
  const TabCourseStripWidget({super.key, required this.tabData});

  @override
  State<TabCourseStripWidget> createState() => _TabCourseStripWidgetState();
}

class _TabCourseStripWidgetState extends State<TabCourseStripWidget>
    with SingleTickerProviderStateMixin {
  late LearnTabModel tabData;
  late TabItems selectedTabItem;
  FilterItems? selectedFilterItem;
  ContentStripModel? courseStripData;
  late TabController tabController;
  late Future<List<Course>> coursesFuture;

  @override
  void initState() {
    super.initState();

    getData();
  }

  void getData() {
    tabData = widget.tabData;
    tabController = TabController(
      length: tabData.tabItems
          .where((e) => e.isEnabled)
          .map((e) => e.title)
          .toList()
          .length,
      vsync: this,
      initialIndex: 0,
    );
    if (tabData.tabItems.isNotEmpty) {
      selectedTabItem = tabData.tabItems[0];
      if (selectedTabItem.filterItems != null &&
          selectedTabItem.filterItems!.isNotEmpty) {
        selectedFilterItem = selectedTabItem.filterItems![0];
        courseStripData = selectedFilterItem!.courseStrip;

        getCourseData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.w),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 8).r,
          child: TitleWidget(
            title: widget.tabData.title.getText(context),
          ),
        ),
        CustomTabBar(
          onTabChange: (value) {
            onChangeTab(value);
          },
          tabController: tabController,
          tabTitles: tabData.tabItems
              .where((e) => e.isEnabled)
              .map((e) => e.title)
              .toList(),
        ),
        getFilterType(),
        getTabBody(),
        SizedBox(height: 8.w),
      ],
    );
  }

  Widget getFilterType() {
    switch (selectedTabItem.type) {
      case WidgetConstants.pills:
        return Padding(
          padding: const EdgeInsets.only(top: 16.0, left: 16).r,
          child: _buildTabPills(),
        );
      case WidgetConstants.dropdown:
        return Padding(
          padding: const EdgeInsets.only(top: 16.0, left: 16).r,
          child: Row(
            children: [
              FilterDropdown(
                filterItems: selectedTabItem.filterItems!,
                onchanged: (value) {
                  selectedFilterItem = value;
                  courseStripData = selectedFilterItem!.courseStrip;
                  // HomeTelemetryService.generateInteractTelemetryData(
                  //     primaryCategory: selectedFilterItem!
                  //         .courseStrip.telemetryPrimaryCategory,
                  //     selectedFilterItem!.courseStrip.telemetryIdentifier,
                  //     subType:
                  //         selectedFilterItem!.courseStrip.telemetrySubType);
                  getCourseData();
                  setState(() {});
                },
                selectedFilterItem: selectedFilterItem,
              ),
              Spacer(),
              courseStripData != null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 8).r,
                      child: TextButton(
                        onPressed: () {
                          // HomeTelemetryService.generateInteractTelemetryData(
                          //     TelemetryIdentifier.showAll,
                          //     subType: selectedFilterItem!
                          //         .courseStrip.telemetrySubType,
                          //     primaryCategory: selectedFilterItem!
                          //         .courseStrip.telemetryPrimaryCategory);

                          Navigator.push(
                              context,
                              FadeRoute(
                                  page: ViewAllCourses(
                                courseStripData: courseStripData!,
                              )));
                        },
                        child: Row(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.mCommonShowAll,
                              style: GoogleFonts.lato(
                                color: AppColors.darkBlue,
                                fontWeight: FontWeight.w400,
                                fontSize: 14.sp,
                                letterSpacing: 0.12,
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: AppColors.darkBlue,
                              size: 20.sp,
                            )
                          ],
                        ),
                      ),
                    )
                  : SizedBox(),
            ],
          ),
        );
      default:
        return SizedBox();
    }
  }

  Widget getTabBody() {
    switch (selectedTabItem.type) {
      case WidgetConstants.myLearningCourses:
        return MyLearningCourseTab(tabItem: selectedTabItem);
      case WidgetConstants.myLearningEvents:
        return MyLearningEventTab(tabItem: selectedTabItem);
      case WidgetConstants.providers:
        return ProvidersExternalCourses(tabItemData: selectedTabItem);
      case WidgetConstants.trainingInstitutes:
        return TrainingInstitutes(tabItemData: selectedTabItem);
      case WidgetConstants.pills:
        return getCourseStrip();
      case WidgetConstants.dropdown:
        return getCourseStrip();
      case WidgetConstants.courseStrip:
        return getCourseStrip();
      default:
        return SizedBox();
    }
  }

  Widget getCourseStrip() {
    return FutureBuilder(
        future: coursesFuture,
        builder: (BuildContext context, AsyncSnapshot<List<Course>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Padding(
              padding: const EdgeInsets.all(16.0).r,
              child: CourseCardSkeletonPage(),
            );
          }
          if (snapshot.data != null) {
            List<Course> courses = snapshot.data!;

            return (courses.isNotEmpty)
                ? Column(
                    children: [
                      SizedBox(
                        height: 8.w,
                      ),
                      CourseStrip(
                        courses: courses,
                        courseStripData: courseStripData,
                      )
                    ],
                  )
                : SizedBox(
                    height: 300.w,
                    child: Center(
                      child: AnimationConfiguration.staggeredList(
                        position: 0,
                        duration: const Duration(milliseconds: 800),
                        child: FadeInAnimation(
                          child: Padding(
                            padding: const EdgeInsets.all(16).r,
                            child: NoDataWidget(
                              message: AppLocalizations.of(context)!
                                  .mNoResourcesFound,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
          } else {
            return SizedBox();
          }
        });
  }

  Widget _buildTabPills() {
    return Row(
      children: List.generate(
        selectedTabItem.filterItems!.length,
        (index) => _buildTabPill(filter: selectedTabItem.filterItems![index]),
      ),
    );
  }

  Widget _buildTabPill({required FilterItems filter}) {
    bool isSelected = selectedFilterItem!.filterTitle == filter.filterTitle;
    return InkWell(
      onTap: () {
        setState(() {
          // HomeTelemetryService.generateInteractTelemetryData(
          //     selectedFilterItem!.courseStrip.telemetryIdentifier,
          //     subType: selectedFilterItem!.courseStrip.telemetrySubType);
          selectedFilterItem = filter;
          courseStripData = selectedFilterItem!.courseStrip;

          getCourseData();
        });
      },
      child: Container(
        margin: EdgeInsets.only(right: 16).r,
        padding: EdgeInsets.all(6).r,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(40).r,
          border: Border.all(
            color: isSelected ? AppColors.darkBlue : AppColors.grey24,
          ),
        ),
        child: Text(
          filter.filterTitle.getText(context),
          style: GoogleFonts.lato(
            fontSize: 12.w,
            fontWeight: FontWeight.w400,
            color: isSelected ? AppColors.appBarBackground : AppColors.greys60,
          ),
        ),
      ),
    );
  }

  void onChangeTab(int index) {
    setState(() {
      selectedTabItem = tabData.tabItems[index];

      if (selectedTabItem.filterItems != null &&
          selectedTabItem.filterItems!.isNotEmpty) {
        selectedFilterItem = selectedTabItem.filterItems![0];
        courseStripData = selectedFilterItem!.courseStrip;
      } else if (selectedTabItem.type == WidgetConstants.courseStrip &&
          selectedTabItem.courseStripData != null) {
        courseStripData = selectedTabItem.courseStripData;
      }
      // HomeTelemetryService.generateInteractTelemetryData(
      //     tabData.tabItems[index].telemetryIdentifier,
      //     subType: tabData.tabItems[index].telemetrySubType);
      getCourseData();
    });
  }

  void getCourseData() {
    if (courseStripData != null) {
      coursesFuture =
          ContentStripService.getCourseData(stripData: courseStripData!);
    }
  }
}
