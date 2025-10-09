import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:karmayogi_mobile/common_components/common_service/home_telemetry_service.dart';
import 'package:karmayogi_mobile/common_components/constants/widget_constants.dart';
import 'package:karmayogi_mobile/common_components/filter_pill/filter_pills.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/models/_models/multilingual_text.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/events_details/events_details_screenv2.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/my_learnings/my_learning_v2.dart/services/my_learning_service.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/my_learnings/my_learning_v2.dart/widgets/my_learning_events/widgets/my_events_completed_card.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/my_learnings/no_data_widget.dart';
import 'package:karmayogi_mobile/ui/skeleton/pages/course_progress_skeleton_page.dart';
import 'package:karmayogi_mobile/ui/widgets/_events/models/event_enrollment_list_model.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:karmayogi_mobile/util/helper.dart';

import 'widgets/my_events_inprogres_card.dart';

class MyLearningEvents extends StatefulWidget {
  final int? index;
  const MyLearningEvents({super.key, this.index});

  @override
  State<MyLearningEvents> createState() => _MyLearningEventsState();
}

class _MyLearningEventsState extends State<MyLearningEvents> {
  List<MultiLingualText> tabItems = [];
  int selectedIndex = 0;
  late Future<List<EventEnrollmentListModel>> enrolledEvents;

  @override
  void initState() {
    selectedIndex = widget.index ?? 0;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    tabItems = [
      MultiLingualText(
          id: WidgetConstants.inProgress,
          enText: AppLocalizations.of(context)!.mStaticInprogress,
          hiText: AppLocalizations.of(context)!.mStaticInprogress),
      MultiLingualText(
          id: WidgetConstants.myLearningCompleted,
          enText: AppLocalizations.of(context)!.mStaticCompleted,
          hiText: AppLocalizations.of(context)!.mStaticCompleted),
    ];
    enrolledEvents =
        MyLearningService.getEventEnrollList(type: tabItems[selectedIndex].id);
    super.didChangeDependencies();
  }

  void _onTabChanged(int index) {
    setState(() {
      selectedIndex = index;
      enrolledEvents = MyLearningService.getEventEnrollList(
          type: tabItems[selectedIndex].id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0).r,
          child: _buildTabPills(),
        ),
        Expanded(
          child: ListView(children: [
            FutureBuilder<List<EventEnrollmentListModel>>(
              future: enrolledEvents,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState();
                }

                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return _buildEventList(snapshot.data!);
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 80.0).r,
                  child: NoDataWidget(
                    isEvent: true,
                    isCompleted: selectedIndex == 1,
                  ),
                );
              },
            ),
          ]),
        ),
      ],
    );
  }

  Widget _buildTabPills() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          tabItems.length,
          (index) => FilterPills(
            fontSize: 14,
            isSelected: selectedIndex == index,
            filterText: Helper.capitalizeFirstLetter(tabItems[index].enText),
            onClickedFilterText: (_) => _onTabChanged(index),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.separated(
      itemBuilder: (context, index) => const CourseProgressSkeletonPage(),
      separatorBuilder: (context, index) => SizedBox(height: 4.w),
      itemCount: 5,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
    );
  }

  Widget _buildEventList(List<EventEnrollmentListModel> enrolledEvents) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16).r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12.w),
          AnimationLimiter(
            child: ListView.separated(
              physics: NeverScrollableScrollPhysics(),
              itemCount: enrolledEvents.length,
              shrinkWrap: true,
              separatorBuilder: (context, index) => SizedBox(height: 16.w),
              itemBuilder: (context, index) {
                return _buildEventCard(enrolledEvents[index], index);
              },
            ),
          ),
          SizedBox(height: 80.w),
        ],
      ),
    );
  }

  Widget _buildEventCard(EventEnrollmentListModel enrolledEvent, int index) {
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: InkWell(
            onTap: () {
              if (enrolledEvent.event.status == WidgetConstants.live) {
                Navigator.push(
                  context,
                  FadeRoute(
                      page: EventsDetailsScreenv2(
                          eventId: enrolledEvent.event.identifier)),
                );
                HomeTelemetryService.generateInteractTelemetryData(
                  enrolledEvent.event.identifier,
                  primaryCategory: "event",
                  subType: TelemetrySubType.myLearning,
                  clickId: TelemetryIdentifier.cardContent,
                );
              } else {
                Helper.showSnackBarMessage(
                    context: context,
                    text: AppLocalizations.of(context)!.meventArchivedMessage,
                    bgColor: AppColors.darkBlue);
              }
            },
            child: selectedIndex == 0
                ? MyEventsInprogresCard(
                    isVertical: true,
                    event: enrolledEvent,
                  )
                : MyEventsCompletedCard(
                    event: enrolledEvent,
                  ),
          ),
        ),
      ),
    );
  }
}
