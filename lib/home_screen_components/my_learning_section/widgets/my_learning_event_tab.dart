import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:karmayogi_mobile/common_components/filter_pill/filter_pills.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/common_components/common_service/home_telemetry_service.dart';
import 'package:karmayogi_mobile/common_components/constants/widget_constants.dart';
import 'package:karmayogi_mobile/home_screen_components/models/learn_tab_model.dart';
import 'package:karmayogi_mobile/home_screen_components/my_learning_section/my_learning_service.dart';
import 'package:karmayogi_mobile/models/_models/multilingual_text.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/events_details/events_details_screenv2.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/my_learnings/my_learning_v2.dart/widgets/my_learning_events/widgets/my_events_completed_card.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/my_learnings/my_learning_v2.dart/widgets/my_learning_events/widgets/my_events_inprogres_card.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/my_learnings/no_data_widget.dart';
import 'package:karmayogi_mobile/ui/skeleton/pages/course_progress_skeleton_page.dart';
import 'package:karmayogi_mobile/ui/widgets/_common/show_all_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/_events/models/event_enrollment_list_model.dart';
import 'package:karmayogi_mobile/ui/widgets/custom_tabs.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';

class MyLearningEventTab extends StatefulWidget {
  final TabItems tabItem;

  const MyLearningEventTab({super.key, required this.tabItem});

  @override
  State<MyLearningEventTab> createState() => _MyLearningEventTabState();
}

class _MyLearningEventTabState extends State<MyLearningEventTab> {
  late Future<List<EventEnrollmentListModel>> eventsFuture;
  late MultiLingualText selectedFilter;
  void initState() {
    selectedFilter = widget.tabItem.continueLearningModel!.filterItems[0];
    eventsFuture = getEnrollmentEvents();
    super.initState();
  }

  Future<List<EventEnrollmentListModel>> getEnrollmentEvents() async {
    return await HomeMyLearningService.getEventEnrollList(
        eventsEnrollmentApi:
            widget.tabItem.continueLearningModel!.enrollmentApi!,
        type: selectedFilter.id);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 0.75.sw,
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 16.0, top: 12, bottom: 12).r,
                child: _buildTabPills(),
              ),
            ),
            Spacer(),
            InkWell(
                onTap: () {
                  navigateFunction(selectedFilter.id);
                  // HomeTelemetryService.generateInteractTelemetryData(
                  //     TelemetryIdentifier.showAll,
                  //     subType: TelemetrySubType.myLearning);
                },
                child: ShowAllWidget())
          ],
        ),
        FutureBuilder(
            future: eventsFuture,
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
                    eventProgress(
                        enrolledEvents: snapshot.data!,
                        isCompleted:
                            selectedFilter.id == WidgetConstants.completed),
                  ],
                );
              }
              return SizedBox();
            }),
      ],
    );
  }

  void navigateFunction(String type) {
    try {
      switch (type) {
        case WidgetConstants.myLearningCompleted:
          CustomTabs.setTabItem(context, 3, true,
              tabIndex: 1, pillIndex: 1, isFromHome: true);
          break;
        case WidgetConstants.inProgress:
          CustomTabs.setTabItem(context, 3, true,
              tabIndex: 1, pillIndex: 0, isFromHome: true);
          break;
        default:
      }
    } catch (e) {
      debugPrint("$e");
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
                  isSelected: selectedFilter.id ==
                      widget
                          .tabItem.continueLearningModel!.filterItems[index].id,
                  onClickedPill: (value) {
                    setState(() {
                      selectedFilter = value;
                      eventsFuture = getEnrollmentEvents();
                    });
                  },
                )),
      ),
    );
  }

  Widget eventProgress(
      {required List<EventEnrollmentListModel> enrolledEvents,
      required bool isCompleted}) {
    return enrolledEvents.length > 0
        ? SizedBox(
            height: 210.w,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0).r,
              child: AnimationLimiter(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: enrolledEvents.length,
                  itemBuilder: (context, index) {
                    EventEnrollmentListModel enrolledEvent =
                        enrolledEvents[index];
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                            child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                FadeRoute(
                                    page: EventsDetailsScreenv2(
                                  eventId: enrolledEvent.event.identifier,
                                )));
                            HomeTelemetryService.generateInteractTelemetryData(
                                enrolledEvent.event.identifier,
                                primaryCategory: "event",
                                subType: TelemetrySubType.myLearning,
                                clickId: TelemetryIdentifier.cardContent);
                          },
                          child: selectedFilter.id == WidgetConstants.inProgress
                              ? MyEventsInprogresCard(
                                  event: enrolledEvent,
                                )
                              : MyEventsCompletedCard(
                                  event: enrolledEvent,
                                  isVerticalList: false,
                                ),
                        )),
                      ),
                    );
                  },
                ),
              ),
            ),
          )
        : NoDataWidget(
            isEvent: true,
            isCompleted: isCompleted,
          );
  }
}
