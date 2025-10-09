import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_models/event_model.dart';
import 'package:karmayogi_mobile/models/_models/events_filter_model.dart';
import 'package:karmayogi_mobile/respositories/_respositories/event_repository.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/event_constants.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/view_all_event_with_filter/events_filter_screen/events_filter_screen.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/view_all_event_with_filter/services/view_all_events_service.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/view_all_event_with_filter/widgets/events_search_bar.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/widgets/events_card/show_all_screen_card.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/widgets/events_card/widgets/view_all_event_card_skeleton.dart';
import 'package:karmayogi_mobile/ui/pages/index.dart';
import 'package:provider/provider.dart';

class ViewAllEvent extends StatefulWidget {
  final String? query;
  final List<String>? selectedEventType;
  const ViewAllEvent({super.key, this.selectedEventType, this.query});

  @override
  State<ViewAllEvent> createState() => _ViewAllEventState();
}

class _ViewAllEventState extends State<ViewAllEvent> {
  ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int offset = 0;
  List<Event> allEvents = [];
  late Future<List<Event>> eventsFuture;
  List<EventFilterModel> eventTypeFilter = [];
  List<EventFilterModel> eventStatusFilter = [];
  List<EventFilterModel> eventDateTimeFilter = [];
  List<EventFilterModel> eventDurationFilter = [];
  List<String> selectedEventTypeFilter = [];
  List<String> selectedEventStatusFilter = [];
  List<String> selectedEventDurationFilter = [];
  List<String> selectedEventDateTimeFilter = [];
  String startDate = "";
  String endDate = "";
  String? searchQuery;
  Map? sortBy;

  void initState() {
    super.initState();
    getEventTypeFilter();
    selectedEventTypeFilter = widget.selectedEventType ?? [];
    searchQuery = widget.query;
    _scrollController.addListener(loadMoreData);
    eventsFuture = getEvents();
  }

  void didChangeDependencies() {
    eventTypeFilter = getEventTypeFilter();
    eventStatusFilter = EventFilter.getEventStatusFilter(context);
    eventDateTimeFilter = EventFilter.getEventDateTimeFilter(context);
    //  eventDurationFilter = EventFilter.getEventDurationFilter(context);
    super.didChangeDependencies();
  }

  void loadMoreData() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore &&
        _hasMoreData) {
      _isLoadingMore = true;

      getEvents();
    }
  }

  List<EventFilterModel> getEventTypeFilter() {
    Map eventConfigData =
        Provider.of<EventRepository>(context, listen: false).evenConfigData;
    List<EventFilterModel> eventTypeFilter = [];
    try {
      List data = eventConfigData['version2']?['filterFacetsData']
              ?['resourceType']?['values'] ??
          [];

      for (var e in data) {
        eventTypeFilter
            .add(EventFilterModel(title: MultiLingualFilterModel.fromJson(e)));
      }
    } catch (e) {
      print(e);
    }
    return eventTypeFilter;
  }

  Future<List<Event>> getEvents() async {
    List<Event> newEvents = await ViewAllEventsService().filterEvents(
        searchText: searchQuery,
        offset: offset,
        resourceType: selectedEventTypeFilter,
        endDateFilter: endDate,
        startDateFilter: startDate,
        eventDateTimeFilter: selectedEventDateTimeFilter,
        sortBy: sortBy,
        eventStatusFilter: selectedEventStatusFilter);
    if (mounted) {
      setState(() {
        if (newEvents.isEmpty) {
          _hasMoreData = false;
        } else {
          allEvents.addAll(newEvents);
          offset += 20;
        }
        _isLoadingMore = false;
      });
    }
    return newEvents;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteGradientOne,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: SizedBox(
              height: 40,
              width: 40,
              child: Column(
                children: [
                  checkFilterApplied()
                      ? Row(
                          children: [
                            Spacer(),
                            CircleAvatar(
                              radius: 3,
                              backgroundColor: AppColors.avatarRed,
                            ),
                          ],
                        )
                      : SizedBox(),
                  Icon(Icons.filter_list_outlined),
                ],
              ),
            ),
            onPressed: () {
              showModalBottomSheet(
                  isScrollControlled: true,
                  useSafeArea: true,
                  isDismissible: true,
                  enableDrag: true,
                  context: context,
                  builder: (BuildContext bottomSheetContext) {
                    return EventsFilterScreen(
                      sortBy: sortBy,
                      eventDateTimeFilter: eventDateTimeFilter,
                      selectedEventDateTimeFilter:
                          List.from(selectedEventDateTimeFilter),
                      eventStartDateFilter: startDate,
                      eventEndDateFilter: endDate,
                      eventDurationFilter: eventDurationFilter,
                      eventStatusFilter: eventStatusFilter,
                      eventTypeFilter: eventTypeFilter,
                      selectedEventStatusFilter:
                          List.from(selectedEventStatusFilter),
                      selectedEventTypeFilter:
                          List.from(selectedEventTypeFilter),
                      onFilterApplied: (filter) {
                        debugPrint("---------$filter");
                        selectedEventDurationFilter =
                            filter['eventDuration'] ?? [];
                        selectedEventStatusFilter = filter['eventStatus'] ?? [];
                        selectedEventTypeFilter = filter['eventType'] ?? [];
                        selectedEventDateTimeFilter =
                            filter['eventDateTime'] ?? [];
                        startDate = filter['eventStartDate'] ?? "";
                        endDate = filter['eventEndDate'] ?? "";
                        sortBy = filter['sortBy'];

                        allEvents = [];
                        offset = 0;
                        _hasMoreData = true;

                        eventsFuture = getEvents();

                        setState(() {});
                        Navigator.pop(context);
                      },
                    );
                  });
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16).r,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              SizedBox(
                height: 16.w,
              ),
              EventsSearchBar(
                searchQuery: searchQuery,
                showButton: true,
                onFieldSubmitted: (value) {
                  selectedEventTypeFilter = [];
                  selectedEventStatusFilter = [];
                  selectedEventDurationFilter = [];
                  selectedEventDateTimeFilter = [];
                  allEvents = [];
                  offset = 0;
                  _hasMoreData = true;
                  searchQuery = value;
                  eventsFuture = getEvents();
                  setState(() {});
                },
              ),
              SizedBox(
                height: 10.w,
              ),
              _buildEventsList(),
              allEvents.length > 20
                  ? Center(
                      child: TextButton(
                          onPressed: () {
                            _scrollController.animateTo(
                              0,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Column(
                            children: [
                              Icon(
                                Icons.arrow_upward,
                                color: AppColors.darkBlue,
                                size: 20,
                              ),
                              Text(
                                AppLocalizations.of(context)!.mScrollToTop,
                                style: GoogleFonts.lato(
                                    fontSize: 14.sp,
                                    color: AppColors.darkBlue,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          )),
                    )
                  : SizedBox(),
              SizedBox(
                height: 100.w,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventsList() {
    return FutureBuilder(
        future: eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              itemCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) => ViewAllEventCardSkeleton(),
            );
          }

          if (snapshot.data != null && snapshot.data!.isNotEmpty) {
            return AnimationLimiter(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: allEvents.length,
                itemBuilder: (context, index) {
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: ShowAllScreenCard(event: allEvents[index]),
                      ),
                    ),
                  );
                },
              ),
            );
          }
          return NoDataWidget(
            message: AppLocalizations.of(context)!.mNoResourcesFound,
          );
        });
  }

  bool checkFilterApplied() {
    if (selectedEventDurationFilter.isNotEmpty ||
        selectedEventStatusFilter.isNotEmpty ||
        selectedEventTypeFilter.isNotEmpty ||
        selectedEventDateTimeFilter.isNotEmpty ||
        startDate.isNotEmpty ||
        endDate.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }
}
