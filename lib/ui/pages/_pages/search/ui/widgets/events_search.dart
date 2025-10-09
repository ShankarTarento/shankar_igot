import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';

import '../../../../../../constants/index.dart';
import '../../../../../../models/_models/event_model.dart';
import '../../../../../../models/index.dart';
import '../../../../../../respositories/index.dart';
import '../../../../../../util/index.dart';
import '../../../../../widgets/_events/models/event_enrollment_list_model.dart';
import '../../../../../widgets/_home/course_card_banner.dart';
import '../../../../../widgets/index.dart';
import '../../models/composite_search_model.dart';
import '../../models/event_search_model.dart';
import '../../repository/search_repository.dart';
import '../skeleton/event_search_skeleton_widget.dart';
import '../../utils/search_helper.dart';
import 'course_progress_status_widget.dart';

class EventsSearch extends StatefulWidget {
  final String searchText;
  final bool showAll;
  final Map<String, dynamic>? filters;
  final Map<String, dynamic>? sortBy;
  final VoidCallback? changeSelectedCategory;
  final VoidCallback callBackOnEmptyResult;
  final Function(List<Facet>) callBackWithFacet;
  final Function(TelemetryDataModel)? onTelemetryCallBack;
  final EventRepository eventRepository;
  final SearchRepository searchRepository;

  EventsSearch(
      {super.key,
      required this.searchText,
      this.showAll = true,
      this.filters,
      this.sortBy,
      this.changeSelectedCategory,
      required this.callBackOnEmptyResult,
      required this.callBackWithFacet,
      this.onTelemetryCallBack,
      EventRepository? eventRepository,
      SearchRepository? searchRepository})
      : eventRepository = eventRepository ?? EventRepository(),
        searchRepository = searchRepository ?? SearchRepository();
  @override
  State<EventsSearch> createState() => EventsSearchState();
}

class EventsSearchState extends State<EventsSearch> {
  Future<List<Event>>? futureEventsList;
  bool isLoading = true;
  int pageNo = 0;
  int eventCount = 0;
  List<Facet> initialFacet = [];
  EventSearchModel? eventData;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void didUpdateWidget(covariant EventsSearch oldWidget) {
    if (SearchHelper.hasFilterChanged(
            oldFilter: oldWidget.filters, newFilter: widget.filters) ||
        widget.searchText != oldWidget.searchText ||
        SearchHelper.hasSortByChanged(
            oldSortBy: oldWidget.sortBy, newSortBy: widget.sortBy)) {
      futureEventsList = null;
      pageNo = 0;
      eventCount = 0;
      setState(() {
        isLoading = true;
      });
      fetchData();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: futureEventsList,
        builder: (context, snapshot) {
          if (snapshot.hasData || !isLoading) {
            if (snapshot.data != null && snapshot.data!.isNotEmpty) {
              List<Event> eventList = snapshot.data!;
              return !widget.showAll
                  ? Container(
                      height: 0.68.sh,
                      padding: EdgeInsets.zero,
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification scrollInfo) {
                          if (scrollInfo.metrics.pixels ==
                              scrollInfo.metrics.maxScrollExtent) {
                            if (!isLoading && !widget.showAll) {
                              setState(() {
                                isLoading = true;
                              });
                              loadMore();
                            }
                          }
                          return true;
                        },
                        child: SingleChildScrollView(
                          physics: widget.showAll
                              ? NeverScrollableScrollPhysics()
                              : ClampingScrollPhysics(),
                          child: Padding(
                            padding: EdgeInsets.only(
                                    bottom: widget.showAll ? 0 : 100)
                                .r,
                            child: ContentWidget(context, eventList),
                          ),
                        ),
                      ),
                    )
                  : ContentWidget(context, eventList);
            } else {
              return SizedBox();
            }
          }
          return EventSearchSkeleton();
        });
  }

  Column ContentWidget(BuildContext context, List<Event> eventList) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16).r,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  eventCount != 0
                      ? '${AppLocalizations.of(context)!.mCommonEvents} (${eventCount})'
                      : AppLocalizations.of(context)!.mCommonEvents,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: AppColors.blackLegend)),
              eventList.length > SHOW3 && widget.showAll
                  ? InkWell(
                      onTap: () => widget.changeSelectedCategory!(),
                      child: Row(
                        children: [
                          Text(
                              AppLocalizations.of(context)!
                                  .mSearchShowAllResults,
                              style:
                                  Theme.of(context).textTheme.headlineMedium),
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.arrow_forward_ios_outlined,
                            color: AppColors.darkBlue,
                            size: 10.sp,
                          )
                        ],
                      ),
                    )
                  : Center()
            ],
          ),
        ),
        SizedBox(height: 8.w),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: eventList.length > SHOW3 && widget.showAll
              ? SHOW3
              : eventList.length,
          itemBuilder: (context, index) {
            Event event = eventList[index];
            return InkWell(
              onTap: () {
                widget.onTelemetryCallBack!(TelemetryDataModel(
                    id: event.identifier,
                    clickId: '${TelemetryClickId.searchCard}-${index + 1}',
                    subType: TelemetrySubType.learnSearch,
                    pageId: TelemetryPageIdentifier.globalSearchCardPageId,
                    objectType: TelemetryObjectType.events));
                Navigator.pushNamed(context, AppUrl.eventDetails,
                    arguments: event.identifier);
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 16, left: 16, right: 16).r,
                padding: EdgeInsets.all(16).r,
                decoration: BoxDecoration(
                  color: AppColors.appBarBackground,
                  borderRadius: BorderRadius.circular(16).r,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Column(
                          children: [
                            SizedBox(
                                width: 0.3.sw,
                                height: 75.w,
                                child: CourseCardBanner(
                                    appIcon: Helper.convertImageUrl(
                                        event.eventIcon ?? ''),
                                    creatorIcon: '',
                                    bottomRadius: 12,
                                    createdOn: event.createdOn,
                                    duration: event.duration,
                                    isEvent: true)),
                            if (event.completionPercentage > 0)
                              CourseProgressStatusWidget(
                                  completionPercentage:
                                      event.completionPercentage,
                                  issuedCertificates: event.issuedCertificates,
                                  name: event.name ?? '')
                          ],
                        ),
                        event.startDate != null &&
                                event.startTime != null &&
                                event.endDate != null &&
                                event.endTime != null &&
                                isLive(
                                    startDate: DateTime.parse(event.startDate),
                                    endDate: DateTime.parse(event.endDate),
                                    startTime: event.startTime,
                                    endTime: event.endTime)
                            ? ClipRRect(
                                borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12),
                                        bottomLeft: Radius.circular(12),
                                        bottomRight: Radius.circular(12))
                                    .r,
                                child: Container(
                                  width: 0.3.sw,
                                  height: 75.w,
                                  color: AppColors.greys.withValues(alpha: 0.5),
                                  child: Center(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2)
                                          .r,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(20).r,
                                        color: AppColors.negativeLight,
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .mSearchLive,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge!
                                            .copyWith(
                                                color:
                                                    AppColors.appBarBackground),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox()
                      ],
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 4, left: 16, right: 16).r,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              padding: EdgeInsets.symmetric(
                                      vertical: 2, horizontal: 4)
                                  .r,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [
                                  AppColors.fourthLinearOne,
                                  AppColors.fourthLinearTwo
                                ]),
                                borderRadius: BorderRadius.circular(4).r,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.whatshot,
                                    color: AppColors.appBarBackground,
                                    size: 16.sp,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(event.eventType ?? '',
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall)
                                ],
                              )),
                          SizedBox(height: 8.0.w),
                          SizedBox(
                            width: 0.42.sw,
                            child: Text(
                              event.name ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(color: AppColors.greys),
                            ),
                          ),
                          SizedBox(height: 8.0.w),
                          Text(event.source ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(color: AppColors.greys60)),
                          SizedBox(height: 8.0.w),
                          Row(
                            children: [
                              Icon(
                                Icons.date_range,
                                size: 16.sp,
                                color: AppColors.greys60,
                              ),
                              SizedBox(width: 4.0.w),
                              Text(
                                  '${DateTimeHelper.getDateTimeInFormat(event.startDate, desiredDateFormat: IntentType.dateFormat6)} ${(DateTimeHelper.convertTo12HourFormat(event.startTime)).toLowerCase()}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium!
                                      .copyWith(color: AppColors.disabledGrey)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 16, top: 4).r,
                          decoration: BoxDecoration(
                              color: AppColors.appBarBackground,
                              border:
                                  Border.all(color: AppColors.grey16, width: 1),
                              borderRadius:
                                  BorderRadius.all(const Radius.circular(4.0))
                                      .r),
                        )
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        ),
        isLoading && !widget.showAll
            ? Container(
                height: 40,
                width: 80,
                margin: EdgeInsets.symmetric(vertical: 16).r,
                child: PageLoader())
            : SizedBox()
      ],
    );
  }

  Future<void> fetchData({int offset = 0}) async {
    // Get events based on search keyword
    List<Event> events = await getEvents(offset);
    futureEventsList = Future.value(events);
    if (mounted) {
      setState(() {
        isLoading = false;
        checkIsEmpty(events);
      });
    }
  }

  Future<List<Event>> getEvents(int offset) async {
    List<Event> events = (await futureEventsList) ?? [];
    List<Event> newEvents = [];
    Map<String, dynamic>? filters = jsonDecode(jsonEncode(widget.filters));
    if (widget.filters != null) {
      Map<String, dynamic> newFilters = {};

      widget.filters!.forEach((key, newValues) {
        if (key == SearchFilterFacet.eventTypes) {
          newValues.forEach((value) {
            if (value == SearchConstants.upcoming) {
              newFilters[SearchFilterFacet.startDateTime] = <String, dynamic>{};
              newFilters[SearchFilterFacet.startDateTime]['>='] =
                  DateTime.now().millisecondsSinceEpoch;
            } else if (value == SearchConstants.pastEvents) {
              newFilters[SearchFilterFacet.endDateTime] = <String, dynamic>{};
              newFilters[SearchFilterFacet.endDateTime]['<='] =
                  DateTime.now().millisecondsSinceEpoch;
            } else if (value == SearchConstants.liveEvents) {
              newFilters[SearchFilterFacet.startDateTime] = <String, dynamic>{};
              newFilters[SearchFilterFacet.startDateTime]['<='] =
                  DateTime.now().millisecondsSinceEpoch;
              newFilters[SearchFilterFacet.endDateTime] = <String, dynamic>{};
              newFilters[SearchFilterFacet.endDateTime]['>='] =
                  DateTime.now().millisecondsSinceEpoch;
            }
          });
        } else {
          // For new keys (except avgRating which was handled above)
          newFilters[key] = newValues;
        }
      });
      filters!.remove(SearchFilterFacet.eventTypes);
      Map<String, dynamic> merged = {
        ...filters,
        ...newFilters,
      };
      filters = merged;
      filters['contentType'] = 'Event';
      filters['status'] = ['Live'];
    }
    eventData = await fetchCompositeEventSearch(offset, filters);
    if (eventData != null && eventData!.events.isNotEmpty) {
      newEvents = eventData!.events;
      eventCount = eventData!.count;
      List<EventEnrollmentListModel> enrollmentList =
          await getEnrollmentList(eventData!.events);
      enrollmentList.forEach((enrolledEvent) {
        int index = eventData!.events
            .indexWhere((event) => event.identifier == enrolledEvent.contentId);
        if (index >= 0) {
          eventData!.events[index].completionPercentage =
              enrolledEvent.completionPercentage;
          eventData!.events[index].issuedCertificates =
              enrolledEvent.issuedCertificates;
        }
      });
    }
    if (eventData != null && eventData!.facets.isNotEmpty) {
      if (eventData!.events.isNotEmpty) {
        eventData!.facets = await updateEventFacet(eventData!.facets);

        if (widget.filters != null) {
          if (widget.filters!.containsKey(SearchFilterFacet.eventTypes)) {
            String typeName =
                widget.filters![SearchFilterFacet.eventTypes].first;
            Facet? facet = eventData!.facets.cast<Facet?>().firstWhere(
                (element) =>
                    element != null &&
                    element.name == SearchFilterFacet.eventTypes,
                orElse: () => null);
            if (facet != null) {
              Value? value = facet.values.cast<Value?>().firstWhere(
                  (element) => element != null && element.name == typeName,
                  orElse: () => null);
              if (value != null) {
                value.isChecked = true;
              }
            }
          }
        }
      }
      if (events.isNotEmpty || eventData!.events.isNotEmpty) {
        Future.delayed(
            Duration.zero, () => widget.callBackWithFacet(eventData!.facets));
      }
    }
    if (events.isNotEmpty) {
      if (newEvents.isNotEmpty) {
        events.addAll(newEvents);
      }
    } else {
      events = newEvents;
    }
    return events;
  }

  Future<EventSearchModel?> fetchCompositeEventSearch(
      int offset, Map<String, dynamic>? filters) async {
    EventSearchModel? eventData =
        await widget.eventRepository.compositeEventsSearch(
            searchText: widget.searchText,
            limit: 100,
            offset: offset,
            facets: [
              SearchFilterFacet.resourceType,
              SearchFilterFacet.provider,
              SearchFilterFacet.competencyAreaName,
              SearchFilterFacet.competencyThemeName,
              SearchFilterFacet.competencySubThemeName
            ],
            filters: filters,
            sortBy: widget.sortBy ?? {});
    return eventData;
  }

  void checkIsEmpty(List<Event> event) {
    if (event.isEmpty) {
      Future.delayed(Duration.zero, () {
        widget.callBackOnEmptyResult();
      });
    }
  }

  Future<void> loadMore() async {
    List<Event>? eventData = await futureEventsList;
    if (eventData != null) {
      if (eventData.length < eventCount) {
        pageNo = pageNo + 1;
        await fetchData(offset: pageNo);
      } else {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  bool isLive(
      {required DateTime startDate,
      required DateTime endDate,
      required String startTime,
      required String endTime}) {
    DateTime now = DateTime.now();
    DateTime convertedStartDateTime = DateTime.parse(
        SearchHelper.mergeDateAndTime(date: startDate, time: startTime)
            .toString());
    DateTime convertedEndDateTime = DateTime.parse(
        SearchHelper.mergeDateAndTime(date: endDate, time: endTime).toString());
    bool isStartNow = convertedStartDateTime.isBefore(now) ||
        convertedStartDateTime.isAtSameMomentAs(now);

    // Check if endDate is before current time
    bool isEndAfterNow = convertedEndDateTime.isAfter(now);

    return isStartNow && isEndAfterNow;
  }

  Future<List<EventEnrollmentListModel>> getEnrollmentList(
      List<Event> events) async {
    if (events.isEmpty) return [];
    List<EventEnrollmentListModel> responseList =
        await widget.searchRepository.getEventEnrollList(type: 'Completed');
    return responseList;
  }

  void removeCompetencyFacet(EventSearchModel data) {
    data.facets.removeWhere((facet) => facet.values.isEmpty);
  }

  Future<List<Facet>> updateEventFacet(List<Facet> facets) async {
    facets.removeWhere((element) =>
        element.name == SearchFilterFacet.eventTypes || element.values.isEmpty);
    if (!(widget.filters != null &&
        widget.filters!.containsKey(SearchFilterFacet.eventTypes) &&
        (widget.filters![SearchFilterFacet.eventTypes]
                .contains(SearchConstants.pastEvents) ||
            widget.filters![SearchFilterFacet.eventTypes]
                .contains(SearchConstants.liveEvents)))) {
      // Fetch Upcomimng events
      facets = await fetchUpcomingFacet(facets);
    }
    if (!(widget.filters != null &&
        widget.filters!.containsKey(SearchFilterFacet.eventTypes) &&
        (widget.filters![SearchFilterFacet.eventTypes]
                .contains(SearchConstants.upcoming) ||
            widget.filters![SearchFilterFacet.eventTypes]
                .contains(SearchConstants.liveEvents)))) {
      // Fetch Past events
      facets = await fetchPastFacet(facets);
    }
    if (!(widget.filters != null &&
        widget.filters!.containsKey(SearchFilterFacet.eventTypes) &&
        (widget.filters![SearchFilterFacet.eventTypes]
                .contains(SearchConstants.upcoming) ||
            widget.filters![SearchFilterFacet.eventTypes]
                .contains(SearchConstants.pastEvents)))) {
      // Fetch Live events
      facets = await fetchLiveFacet(facets);
    }
    return facets;
  }

  List<Facet> updateEventTypeFacetValues(
      List<Facet> facets, String valueName, int count) {
    Facet? existingFacet;

    for (Facet facet in facets) {
      if (facet.name == SearchFilterFacet.eventTypes) {
        existingFacet = facet;
        break;
      }
    }
    if (existingFacet == null) {
      facets.add(Facet(values: [
        Value(
            name: valueName,
            count: count,
            isChecked: false,
            isExpanded: false,
            showMore: false)
      ], name: SearchFilterFacet.eventTypes, count: 0, useSingleChoice: true));
    } else {
      existingFacet.values.add(Value(
          name: valueName,
          count: count,
          isChecked: false,
          isExpanded: false,
          showMore: false));
    }
    return facets;
  }

  Future<List<Facet>> fetchUpcomingFacet(List<Facet> facets) async {
    Map<String, dynamic> filter = {};
    filter = {
      SearchFilterFacet.startDateTime: {
        '>=': DateTime.now().millisecondsSinceEpoch
      },
      'contentType': 'Event',
      'status': ['Live']
    };
    filter = updateFilterForTypes(filter);
    EventSearchModel? eventData = await fetchCompositeEventSearch(0, filter);
    if (eventData != null && eventData.count != 0) {
      facets = updateEventTypeFacetValues(
          facets, SearchConstants.upcoming, eventData.count);
    }
    return facets;
  }

  Map<String, dynamic> updateFilterForTypes(Map<String, dynamic> filters) {
    if (widget.filters != null) {
      Map<String, dynamic> initialFilter = widget.filters!;
      Map<String, dynamic> merged = {
        ...filters,
        ...initialFilter,
      };
      filters = merged;
    }
    if (filters.containsKey(SearchFilterFacet.eventTypes)) {
      filters.remove(SearchFilterFacet.eventTypes);
    }
    filters.removeWhere((key, value) {
      return value == null ||
          value == '' ||
          (value is List && value.isEmpty) ||
          (value is Map && value.isEmpty);
    });
    return filters;
  }

  Future<List<Facet>> fetchPastFacet(List<Facet> facets) async {
    Map<String, dynamic> filters = {
      SearchFilterFacet.endDateTime: {
        '<=': DateTime.now().millisecondsSinceEpoch
      },
      'contentType': 'Event',
      'status': ['Live']
    };
    filters = updateFilterForTypes(filters);
    EventSearchModel? eventData = await fetchCompositeEventSearch(0, filters);
    if (eventData != null && eventData.count != 0) {
      facets = updateEventTypeFacetValues(
          facets, SearchConstants.pastEvents, eventData.count);
    }
    return facets;
  }

  Future<List<Facet>> fetchLiveFacet(List<Facet> facets) async {
    Map<String, dynamic> filters = {
      SearchFilterFacet.startDateTime: {
        '<=': DateTime.now().millisecondsSinceEpoch
      },
      SearchFilterFacet.endDateTime: {
        '>=': DateTime.now().millisecondsSinceEpoch
      },
      'contentType': 'Event',
      'status': ['Live']
    };
    filters = updateFilterForTypes(filters);
    EventSearchModel? eventData = await fetchCompositeEventSearch(0, filters);
    if (eventData != null && eventData.count != 0) {
      facets = updateEventTypeFacetValues(
          facets, SearchConstants.liveEvents, eventData.count);
    }
    return facets;
  }
}
