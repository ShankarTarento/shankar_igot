import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/common_components/constants/widget_constants.dart';
import 'package:karmayogi_mobile/core/repositories/enrollment_repository.dart';
import 'package:karmayogi_mobile/home_screen_components/custom_tab_bar/custom_tab_bar.dart';
import 'package:karmayogi_mobile/home_screen_components/models/my_space_model.dart';
import 'package:karmayogi_mobile/home_screen_components/my_space_tab/my_space_repository.dart';
import 'package:karmayogi_mobile/home_screen_components/my_space_tab/widgets/cbp_course_strip/cbp_course_strip.dart';
import 'package:karmayogi_mobile/models/_models/cbplan_model.dart';
import 'package:karmayogi_mobile/models/_models/course_model.dart';
import 'package:karmayogi_mobile/models/_models/multilingual_text.dart';
import 'package:karmayogi_mobile/models/_models/recommended_learning_model.dart';
import 'package:karmayogi_mobile/respositories/index.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/cbp/mycbp_plan_page.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/home_page/my_space/igot_ai.dart';
import 'package:karmayogi_mobile/ui/skeleton/pages/course_card_skeleton_page.dart';
import 'package:karmayogi_mobile/ui/skeleton/pages/title_skeleton.dart';
import 'package:karmayogi_mobile/ui/widgets/_home/recommended_learning_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/title_widget/title_widget.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:karmayogi_mobile/util/helper.dart';

import '../../constants/index.dart';

class MySpaceTab extends StatefulWidget {
  final MySpaceModel tabData;
  const MySpaceTab({super.key, required this.tabData});

  @override
  State<MySpaceTab> createState() => _MySpaceTabState();
}

class _MySpaceTabState extends State<MySpaceTab>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  List<MySpaceTabItem> availableTabItems = [];
  MySpaceTabItem? selectedTabItem;
  List<Course> recommendedCourseAvailable = [];
  List<Course> recommendedCourseInprogress = [];
  List<Course> recommendedCourseCompleted = [];
  List<Course> allCourses = [];
  List<Course> overdueCourses = [];
  List<Course> upcomingCourses = [];
  List<Course> completedCourses = [];
  List<Course> aparCourses = [];
  List<Widget> tabBody = [];
  List<MultiLingualText> tabHeader = [];
  bool isLoading = true;

  @override
  void initState() {
    getAllData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Padding(
            padding: const EdgeInsets.only(left: 16.0).r,
            child: Column(
              children: [
                TitleSkeleton(),
                CourseCardSkeletonPage(),
              ],
            ),
          )
        : tabHeader.isNotEmpty && selectedTabItem != null
            ? Column(
                children: [
                  SizedBox(
                    height: 8.w,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 8).r,
                    child: TitleWidget(
                        title: widget.tabData.title.getText(context),
                        showAllCallBack:
                            selectedTabItem!.type == WidgetConstants.igotAi
                                ? null
                                : () {
                                    handleShowAll();
                                  }),
                  ),
                  Column(
                    children: [
                      CustomTabBar(
                        onTabChange: (value) {
                          onChangeTab(value);
                        },
                        tabController: tabController,
                        tabTitles: tabHeader,
                      ),
                      SizedBox(
                        height: 380.w,
                        child: TabBarView(
                          controller: tabController,
                          children: tabBody,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : SizedBox();
  }

  void buildTabWidget() {
    tabBody = [];
    tabHeader = [];
    try {
      for (var tabItem in widget.tabData.tabItems) {
        if (tabItem.isEnabled) {
          switch (tabItem.type) {
            case WidgetConstants.cbpCourses:
              if (allCourses.isNotEmpty) {
                tabBody.add(CbpCourseStrip(
                  tabItem: tabItem,
                  allCourses: allCourses,
                  completedCourses: completedCourses,
                  overdueCourses: overdueCourses,
                  upcomingCourses: upcomingCourses,
                  aparCourses: aparCourses,
                ));
                tabHeader.add(tabItem.title);
              }
            case WidgetConstants.recommendedLearning:
              if (recommendedCourseAvailable.isNotEmpty ||
                  recommendedCourseInprogress.isNotEmpty ||
                  recommendedCourseCompleted.isNotEmpty) {
                tabBody.add(RecommendedLearningWidget(
                    availableCourses: recommendedCourseAvailable,
                    inprogressCourses: recommendedCourseInprogress,
                    completedCourses: recommendedCourseCompleted,
                    parentContext: context));
                tabHeader.add(tabItem.title);
              }
            case WidgetConstants.igotAi:
              tabBody.add(
                  IgotAI(shareFeedbackCardVisibility: ValueNotifier(true)));
              tabHeader.add(tabItem.title);

            default:
              debugPrint("invalid case");
          }
        }
      }
      if (tabHeader.isNotEmpty) {
        tabController = TabController(
          length: tabHeader.length,
          vsync: this,
          initialIndex: 0,
        );
        for (MultiLingualText header in tabHeader) {
          for (MySpaceTabItem item in widget.tabData.tabItems) {
            if (item.title == header) {
              availableTabItems.add(item);
              break;
            }
          }
        }

        selectedTabItem = availableTabItems[0];
      }
    } catch (e) {
      selectedTabItem = null;
      debugPrint("----------$e");
    }
    isLoading = false;
    if (mounted) {
      setState(() {});
    }
  }

  void getAllData() async {
    try {
      CbPlanModel? cbpPlan =
          await MySpaceRepository.getCbplan(apiUrl: widget.tabData.cbpApiUrl);
      List<Content>? cbpCourseList = cbpPlan != null
          ? cbpPlan.content != null
              ? cbpPlan.content
              : []
          : [];
      if (cbpPlan != null) {
        List<Course> enrolmentList = await MySpaceRepository.getEnrollmentData(
            context: context,
            cbpPlanData: cbpPlan,
            enrollmentApi: widget.tabData.enrollmentApi);

        // get all cbp course
        getAllCbpCourse(
            cbpCourseList: cbpCourseList!, enrolmentList: enrolmentList);
      } else {
        getFilteredRecommendedCourseIds(allCbpCourseList: []);
      }
    } catch (e) {
      debugPrint("get data error ===  ${e.toString()}");
    }
  }

  void onChangeTab(int index) {
    if (index >= availableTabItems.length) return;
    selectedTabItem = availableTabItems[index];
    setState(() {});
  }

  void getAllCbpCourse(
      {required List<Content> cbpCourseList,
      required List<Course> enrolmentList}) {
    allCourses = [];
    overdueCourses = [];
    upcomingCourses = [];
    completedCourses = [];
    aparCourses = [];
    cbpCourseList.forEach((contents) {
      bool _isApar = contents.isApar ?? false;
      contents.contentList!.forEach((content) {
        content.isApar = _isApar;
        if (Helper.checkUniqueCourse(content, allCourses) &&
            content.raw['status'] != 'Retired') {
          allCourses.add(content);
        }
        if (content.isApar) {
          aparCourses.add(content);
        }
      });
    });

    allCourses.sort((a, b) {
      int dateComparison =
          DateTime.parse(a.endDate!).compareTo(DateTime.parse(b.endDate!));
      if (dateComparison == 0) {
        return a.name.compareTo(b.name);
      } else {
        return dateComparison;
      }
    });

    allCourses.forEach((content) {
      int dateDiff =
          Helper.getTimeDiff(content.endDate!, DateTime.now().toString());
      bool isCompleted = false;

      enrolmentList.forEach((course) {
        if (course.raw['courseId'] == content.id &&
            course.raw['completionPercentage'] ==
                COURSE_COMPLETION_PERCENTAGE) {
          content.completionPercentage = COURSE_COMPLETION_PERCENTAGE;
          completedCourses.add(content);
          isCompleted = true;
        }
      });

      if (!isCompleted) {
        if (dateDiff >= 0) {
          upcomingCourses.add(content);
        } else {
          overdueCourses.add(content);
        }
      }
    });

    // Get recommended course
    getFilteredRecommendedCourseIds(allCbpCourseList: allCourses);
  }

  Future<void> getFilteredRecommendedCourseIds(
      {required List<Course>? allCbpCourseList}) async {
    // Get recommended course id's
    List<dynamic> courseIdList =
        await ProfileRepository().getRecommendedCourse();
    // Delete course comes under cbp plan
    if (allCbpCourseList != null && allCbpCourseList.isNotEmpty) {
      allCbpCourseList.forEach((course) {
        courseIdList.removeWhere((identifier) => identifier == course.id);
      });
    }

    List<Course> enrolmentList = [];
    if (courseIdList.isNotEmpty) {
      enrolmentList = await EnrollmentRepository.getEnrolledCoursesByIds(
          courseIds: courseIdList);
    }
    await getRecommendedCourseList(
        courseIdList: courseIdList, enrolmentList: enrolmentList);
  }

  Future<void> getRecommendedCourseList(
      {required List courseIdList, required List<Course> enrolmentList}) async {
    if (courseIdList.isNotEmpty) {
      List<Course> recommendedCourse =
          await LearnRepository().getRecommendationWithDoId(courseIdList);
      if (recommendedCourse.isNotEmpty) {
        recommendedCourse.forEach((recommended) {
          Course? course = enrolmentList.cast<Course?>().firstWhere(
              (item) => item!.id == recommended.id,
              orElse: () => null);
          if (course == null) {
            recommendedCourseAvailable.add(recommended);
          } else if (course.completionPercentage ==
              COURSE_COMPLETION_PERCENTAGE) {
            recommendedCourseCompleted.add(recommended);
          } else {
            recommendedCourseInprogress.add(recommended);
          }
        });
      }
    }
    buildTabWidget();
  }

  void handleShowAll() {
    if (selectedTabItem!.type == WidgetConstants.cbpCourses) {
      Navigator.push(
        context,
        FadeRoute(
            page: MyCbpPlanPage(
          completedCourseList: completedCourses,
          allCourseList: allCourses,
          upcomingCourseList: upcomingCourses,
          overdueCourseList: overdueCourses,
          aparCoursesList: aparCourses,
        )),
      );
    } else if (selectedTabItem!.type == WidgetConstants.recommendedLearning) {
      Navigator.pushNamed(context, AppUrl.recommendedLearning,
          arguments: RecommendedLearningModel(
              availableCourses: recommendedCourseAvailable,
              inprogressCourses: recommendedCourseInprogress,
              completedCourses: recommendedCourseCompleted,
              showAll: true));
    }
    // HomeTelemetryService.generateInteractTelemetryData(
    //     TelemetryIdentifier.showAll,
    //     subType: TelemetrySubType.myIgot);
  }
}
