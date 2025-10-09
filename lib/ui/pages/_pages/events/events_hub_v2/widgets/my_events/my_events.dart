import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/models/_models/event_model.dart';
import 'package:karmayogi_mobile/models/_models/multilingual_text.dart';
import 'package:karmayogi_mobile/models/_models/my_events_tab_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/events_details/events_details_screenv2.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/widgets/events_card/events_card.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/widgets/my_events/my_events_skeleton.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/widgets/my_events/repository/my_events_repository.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/widgets/my_events/show_all_my_events/show_all_my_events.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/my_learnings/no_data_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/title_widget/title_widget.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:karmayogi_mobile/util/telemetry_repository.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../../../../constants/_constants/color_constants.dart';

class MyEvents extends StatefulWidget {
  final Map<String, dynamic> data;
  const MyEvents({super.key, required this.data});

  @override
  State<MyEvents> createState() => _MyEventsState();
}

class _MyEventsState extends State<MyEvents>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = true;
  bool setTabIndex = true;
  MultiLingualText? title;
  List<MyEventsTabModel> tabItems = [];

  @override
  void initState() {
    getConfigData();
    super.initState();
  }

  void getConfigData() {
    try {
      if (widget.data['mTitle'] != null) {
        title = MultiLingualText.fromJson(widget.data['mTitle']);
      }

      if (widget.data['tabs'] != null && widget.data['tabs'] is List) {
        for (var e in widget.data['tabs']) {
          tabItems.add(MyEventsTabModel.fromJson(e));
        }
      }
    } catch (e) {
      debugPrint("An error occurred while processing data: $e");
    }
    _tabController = TabController(length: tabItems.length, vsync: this);
    getData();
  }

  void getData() async {
    await Provider.of<MyEventsRepository>(context, listen: false)
        .getAllEnrolledEvents();
    isLoading = false;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MyEventsRepository>(builder: (context, myEvents, child) {
      return isLoading
          ? MyEventsSkeleton()
          : myEvents.allEnrolledEvents.isNotEmpty
              ? buildBody(
                  pastEvents: myEvents.pastEvents,
                  upcomingEvents: myEvents.upcomingEvents,
                  todaysEvents: myEvents.todaysEvents)
              : SizedBox();
    });
  }

  Widget buildBody(
      {required List<Event> pastEvents,
      required List<Event> upcomingEvents,
      required List<Event> todaysEvents}) {
    setTabInitialIndex(
        pastEvents: pastEvents,
        upcomingEvents: upcomingEvents,
        todaysEvents: todaysEvents);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0).r,
          child: TitleWidget(
            title: title != null
                ? title!.getText(context)
                : AppLocalizations.of(context)!.mMyEvents,
            showAllCallBack: () {
              Navigator.push(
                  context,
                  FadeRoute(
                      page: ShowAllMyEvents(
                    initialIndex: _tabController.index,
                    pastEvents: pastEvents,
                    todaysEvents: todaysEvents,
                    upcomingEvents: upcomingEvents,
                  )));
            },
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 16, right: 16).r,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(top: 4).r,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(width: 1.w, color: AppColors.grey08),
            ),
          ),
          child: TabBar(
            tabAlignment: TabAlignment.start,
            isScrollable: true,
            indicator: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.darkBlue,
                  width: 2.0.w,
                ),
              ),
            ),
            indicatorColor: AppColors.appBarBackground,
            labelPadding: EdgeInsets.only(top: 0.0).w,
            unselectedLabelColor: AppColors.greys60,
            labelColor: AppColors.greys87,
            labelStyle: GoogleFonts.lato(
              fontSize: 14.0.sp,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: GoogleFonts.lato(
              fontSize: 14.0.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.greys60,
            ),
            tabs: List.generate(
              tabItems.length,
              (index) {
                return Container(
                    padding: EdgeInsets.symmetric(horizontal: 16).r,
                    child: Tab(
                      child: Padding(
                        padding: EdgeInsets.all(5.0).r,
                        child: Text(
                          Helper.capitalize(
                              tabItems[index].mLabel.getText(context)),
                        ),
                      ),
                    ));
              },
            ),
            controller: _tabController,
          ),
        ),
        SizedBox(
          height: 16.w,
        ),
        SizedBox(
            height: 315.w,
            child: TabBarView(
              controller: _tabController,
              children: [
                eventList(todaysEvents),
                eventList(upcomingEvents),
                eventList(pastEvents),
              ],
            ))
      ],
    );
  }

  Widget eventList(List<Event> events) {
    return events.isNotEmpty
        ? ListView.builder(
            itemCount: events.length > 8 ? 8 : events.length,
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(left: 16).r,
                child: InkWell(
                  onTap: () {
                    _generateInteractTelemetryData(
                        clickId: TelemetryIdentifier.cardContent,
                        subType: TelemetrySubType.myEvents,
                        events[index].identifier);
                    Navigator.push(
                        context,
                        FadeRoute(
                            page: EventsDetailsScreenv2(
                          eventId: events[index].identifier,
                        )));
                  },
                  child: EventsCardV2(
                    event: events[index],
                  ),
                ),
              );
            },
          )
        : NoDataWidget(
            message: AppLocalizations.of(context)!.mNoResourcesFound,
          );
  }

  void setTabInitialIndex(
      {required List<Event> todaysEvents,
      required List<Event> upcomingEvents,
      required List<Event> pastEvents}) {
    if (setTabIndex) {
      if (todaysEvents.isNotEmpty) {
        _tabController.index = 0;
      } else if (upcomingEvents.isNotEmpty) {
        _tabController.index = 1;
      } else if (pastEvents.isNotEmpty) {
        _tabController.index = 2;
      }
      setTabIndex = false;
    }
  }

  void _generateInteractTelemetryData(String contentId,
      {String subType = '',
      String? primaryCategory,
      bool isObjectNull = false,
      String clickId = ''}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.eventHomePageId,
        contentId: contentId,
        subType: subType,
        env: TelemetryEnv.events,
        objectType: primaryCategory ?? (isObjectNull ? null : subType),
        clickId: clickId);
    await telemetryRepository.insertEvent(eventData: eventData);
  }
}
