import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../constants/index.dart';
import '../../../../models/_arguments/index.dart';
import '../../../../models/index.dart';
import '../../../../util/telemetry_repository.dart';
import '../../../pages/index.dart';
import '../../index.dart';

class TimelinesViewWidget extends StatefulWidget {
  const TimelinesViewWidget(
      {Key? key,
      required this.allCourseList,
      required this.upcomingCourseList,
      required this.completedCourseList,
      required this.overdueCourseList,
      required this.aparCourseList,
      required this.filterParentAction})
      : super(key: key);

  final List<Course> allCourseList;
  final List<Course> completedCourseList;
  final List<Course> upcomingCourseList;
  final List<Course> overdueCourseList;
  final List<Course> aparCourseList;
  final ValueChanged<List<dynamic>> filterParentAction;

  @override
  State<TimelinesViewWidget> createState() => _TimelinesViewWidgetState();
}

class _TimelinesViewWidgetState extends State<TimelinesViewWidget>
    with SingleTickerProviderStateMixin {
  late TabController cbptabController;
  bool isLoad = false;

  @override
  void initState() {
    super.initState();
  }

  void _generateInteractTelemetryData(String contentId,
      {String? subType, String? primaryCategory, String? clickId}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.homePageId,
        contentId: contentId,
        subType: subType ?? "",
        env: TelemetryEnv.home,
        objectType: primaryCategory != null ? primaryCategory : subType,
        clickId: clickId ?? "");
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  List tabNames = [];
  @override
  void didChangeDependencies() {
    tabNames = [
      AppLocalizations.of(context)!.mStaticApar,
      AppLocalizations.of(context)!.mStaticUpcoming,
      AppLocalizations.of(context)!.mStaticOverdue,
      AppLocalizations.of(context)!.mStaticCompleted,
    ];
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoad) {
      if (widget.aparCourseList.length > 0) {
        cbptabController = TabController(
            length: tabNames.length, vsync: this, initialIndex: 0);
      } else if (widget.upcomingCourseList.length > 0 ||
          (widget.upcomingCourseList.length == 0 &&
              widget.overdueCourseList.length == 0)) {
        cbptabController = TabController(
            length: tabNames.length, vsync: this, initialIndex: 1);
      } else {
        cbptabController = TabController(
            length: tabNames.length, vsync: this, initialIndex: 2);
      }
      isLoad = true;
    }
    return Container(
      width: 1.sw,
      height: 500.w,
      margin: const EdgeInsets.only(left: 0, top: 5, bottom: 15).r,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12).r,
          border: Border.all(color: AppColors.darkBlue, width: 1),
          color: AppColors.darkBlueGradient8),
      child: DefaultTabController(
        length: tabNames.length,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 50.w, // Height of the TabBar
              child: TabBar(
                tabAlignment: TabAlignment.start,
                padding: EdgeInsets.only(left: 20).r,
                isScrollable: true,
                controller: cbptabController,
                indicator: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.darkBlue,
                      width: 2.0,
                    ),
                  ),
                ),
                indicatorColor: AppColors.appBarBackground,
                labelPadding: EdgeInsets.only(right: 8.0).r,
                unselectedLabelColor: AppColors.greys60,
                labelColor: AppColors.greys,
                labelStyle: GoogleFonts.lato(
                  fontSize: 14.0.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.greys87,
                ),
                indicatorSize: TabBarIndicatorSize.label,
                unselectedLabelStyle: GoogleFonts.lato(
                  fontSize: 14.0.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.greys60,
                ),
                tabs: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Tab(
                      child: Padding(
                        padding: EdgeInsets.all(5.0).r,
                        child: SizedBox(
                          child: Center(
                              child: Text(widget.aparCourseList.length > 0
                                  ? AppLocalizations.of(context)!
                                          .mStaticApar +
                                      ' (' +
                                      widget.aparCourseList.length
                                          .toString() +
                                      ')'
                                  : AppLocalizations.of(context)!.mStaticApar)),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Tab(
                      child: Padding(
                        padding: EdgeInsets.all(5.0).r,
                        child: SizedBox(
                          child: Center(
                              child: Text(widget.upcomingCourseList.length > 0
                                  ? AppLocalizations.of(context)!
                                          .mStaticUpcoming +
                                      ' (' +
                                      widget.upcomingCourseList.length
                                          .toString() +
                                      ')'
                                  : AppLocalizations.of(context)!
                                      .mStaticUpcoming)),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Tab(
                      child: Padding(
                        padding: EdgeInsets.all(5.0).r,
                        child: SizedBox(
                          child: Center(
                            child: Text(widget.overdueCourseList.length > 0
                                ? AppLocalizations.of(context)!.mStaticOverdue +
                                    ' (' +
                                    widget.overdueCourseList.length.toString() +
                                    ')'
                                : AppLocalizations.of(context)!.mStaticOverdue),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Tab(
                      child: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: SizedBox(
                          child: Center(
                            child: Text(widget.overdueCourseList.length > 0
                                ? AppLocalizations.of(context)!
                                        .mCommoncompleted +
                                    ' (' +
                                    widget.completedCourseList.length
                                        .toString() +
                                    ')'
                                : AppLocalizations.of(context)!
                                    .mCommoncompleted),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 16).r,
                width: 1.sw,
                child: TabBarView(
                  controller: cbptabController,
                  children: [
                    courseCardWidget(widget.aparCourseList,
                        AppLocalizations.of(context)!.mStaticApar),
                    courseCardWidget(widget.upcomingCourseList,
                        AppLocalizations.of(context)!.mStaticUpcoming),
                    courseCardWidget(widget.overdueCourseList,
                        AppLocalizations.of(context)!.mStaticOverdue),
                    courseCardWidget(widget.completedCourseList,
                        AppLocalizations.of(context)!.mCommoncompleted),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget courseCardWidget(List<Course> courseList, String category) {
    String message;
    if (category == AppLocalizations.of(context)!.mStaticUpcoming) {
      message = AppLocalizations.of(context)!.mStaticSeeAllUpcoming;
    } else if (category == AppLocalizations.of(context)!.mCommoncompleted) {
      message = AppLocalizations.of(context)!.mStaticSeeCompletedContent;
    } else {
      message =
          AppLocalizations.of(context)!.mStaticSeeContentForWhichDueDatePassed;
    }
    return courseList.length > 0
        ? Padding(
            padding: const EdgeInsets.only(left: 16, right: 16).r,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount:
                          courseList.length >= CBP_COURSE_ON_TIMELINE_LIST_LIMIT
                              ? CBP_COURSE_ON_TIMELINE_LIST_LIMIT
                              : courseList.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                            onTap: () async {
                              _generateInteractTelemetryData(
                                  courseList[index].id,
                                  primaryCategory:
                                      courseList[index].courseCategory,
                                  clickId: TelemetryIdentifier.cardContent,
                                  subType: TelemetrySubType.myIgot);
                              Navigator.pushNamed(context, AppUrl.courseTocPage,
                                  arguments: CourseTocModel(
                                      courseId: courseList[index].id));
                            },
                            child: CbpCourseCard(course: courseList[index]));
                      }),
                ),
                courseList.length > CBP_COURSE_ON_TIMELINE_LIST_LIMIT
                    ? Consumer<CBPFilter>(
                        builder: (context, filterProvider, _) {
                        var filtersList = List.from(filterProvider.filters);
                        return InkWell(
                          onTap: () {
                            filtersList.forEach((element) {
                              element.filters.forEach((item) {
                                if (item.isSelected) {
                                  item.isSelected = false;
                                }
                              });
                            });
                            filtersList.forEach((element) {
                              ///Apar changes start
                              if (cbptabController.index == 0) {
                                if (element.category == CBPFilterCategory.status ||
                                    element.category == CBPFilterCategory.timeDuration) {
                                  for (int filterIndex = 0; filterIndex < element.filters.length; filterIndex++) {
                                    var item = element.filters[filterIndex];
                                    if (item.name == CBPCourseStatus.inProgress || item.name == CBPCourseStatus.notStarted) {
                                      filterProvider.toggleFilter(element.category, filterIndex);
                                    }
                                  }
                                }
                              }
                              ///Apar changes end
                              if (cbptabController.index == 1) {
                                if (element.category ==
                                    CBPFilterCategory.status ||
                                    element.category ==
                                        CBPFilterCategory.timeDuration) {
                                  for (int filterIndex = 0;
                                  filterIndex < element.filters.length;
                                  filterIndex++) {
                                    var item = element.filters[filterIndex];
                                    if (item.name ==
                                        CBPCourseStatus.notStarted ||
                                        item.name ==
                                            CBPCourseStatus.inProgress ||
                                        item.name ==
                                            CBPCourseStatus.completed ||
                                        item.name ==
                                            CBPFilterTimeDuration.upcoming30days) {
                                      filterProvider.toggleFilter(
                                          element.category, filterIndex);
                                    }
                                  }
                                }
                              }
                              if (cbptabController.index == 2) {
                                if (element.category ==
                                        CBPFilterCategory.status ||
                                    element.category ==
                                        CBPFilterCategory.timeDuration) {
                                  for (int filterIndex = 0;
                                      filterIndex < element.filters.length;
                                      filterIndex++) {
                                    var item = element.filters[filterIndex];
                                    if (item.name ==
                                            CBPCourseStatus.notStarted ||
                                        item.name ==
                                            CBPCourseStatus.inProgress ||
                                        item.name ==
                                            CBPFilterTimeDuration.last3month) {
                                      filterProvider.toggleFilter(
                                          element.category, filterIndex);
                                    }
                                  }
                                }
                              } else {
                                if (element.category ==
                                        CBPFilterCategory.status ||
                                    element.category ==
                                        CBPFilterCategory.timeDuration) {
                                  for (int filterIndex = 0;
                                      filterIndex < element.filters.length;
                                      filterIndex++) {
                                    var item = element.filters[filterIndex];
                                    if (item.name ==
                                        CBPCourseStatus.completed) {
                                      filterProvider.toggleFilter(
                                          element.category, filterIndex);
                                    }
                                  }
                                }
                              }
                            });
                            print(filtersList);
                            widget.filterParentAction(filtersList);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16).r,
                            child: Text(
                              AppLocalizations.of(context)!.mLearnShowAll,
                              style: GoogleFonts.lato(
                                color: AppColors.darkBlue,
                                fontWeight: FontWeight.w400,
                                fontSize: 14.sp,
                                letterSpacing: 0.12,
                              ),
                            ),
                          ),
                        );
                      })
                    : Center()
              ],
            ),
          )
        : NoDataWidget(message: message);
  }
}
