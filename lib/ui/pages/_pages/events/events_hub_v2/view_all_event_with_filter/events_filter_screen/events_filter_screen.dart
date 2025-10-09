import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_models/events_filter_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/view_all_event_with_filter/events_filter_screen/widgets/event_date_filters.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/view_all_event_with_filter/events_filter_screen/widgets/events_filter_checkbox.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/view_all_event_with_filter/events_filter_screen/widgets/events_sort_by.dart';
import 'package:karmayogi_mobile/util/helper.dart';

class EventsFilterScreen extends StatefulWidget {
  final List<EventFilterModel> eventTypeFilter;
  final List<EventFilterModel> eventStatusFilter;
  final List<EventFilterModel> eventDurationFilter;
  final List<String> selectedEventTypeFilter;
  final List<String> selectedEventStatusFilter;
  final List<EventFilterModel> eventDateTimeFilter;
  final List<String> selectedEventDateTimeFilter;
  final String? eventStartDateFilter;
  final String? eventEndDateFilter;
  final Map? sortBy;
  final Function(Map<String, dynamic> filter) onFilterApplied;

  const EventsFilterScreen(
      {super.key,
      required this.eventTypeFilter,
      required this.eventStatusFilter,
      required this.eventDurationFilter,
      required this.selectedEventTypeFilter,
      required this.selectedEventStatusFilter,
      required this.onFilterApplied,
      required this.eventDateTimeFilter,
      required this.selectedEventDateTimeFilter,
      this.eventStartDateFilter,
      this.sortBy,
      this.eventEndDateFilter});

  @override
  State<EventsFilterScreen> createState() => _EventsFilterScreenState();
}

class _EventsFilterScreenState extends State<EventsFilterScreen> {
  List<String> selectedEventType = [];
  List<String> selectedEventStatus = [];
  List<String> selectedEventDuration = [];
  List<String> selectedEventDateTime = [];
  List<EventFilterModel> eventDateTimeFilter = [];
  List<EventFilterModel> eventTypeFilter = [];
  List<EventFilterModel> eventStatusFilter = [];
  List<EventFilterModel> eventDurationFilter = [];
  String startDate = "";
  String endDate = "";
  Map? sortByFilter;

  void initState() {
    selectedEventType = widget.selectedEventTypeFilter;
    selectedEventStatus = widget.selectedEventStatusFilter;
    eventTypeFilter = widget.eventTypeFilter;
    eventStatusFilter = widget.eventStatusFilter;
    eventDurationFilter = widget.eventDurationFilter;
    eventDateTimeFilter = widget.eventDateTimeFilter;
    selectedEventDateTime = widget.selectedEventDateTimeFilter;
    startDate = widget.eventStartDateFilter ?? "";
    endDate = widget.eventEndDateFilter ?? "";
    sortByFilter = widget.sortBy;

    super.initState();
  }

  void clearAllFilters() {
    setState(() {
      selectedEventType = [];
      selectedEventStatus = [];
      selectedEventDuration = [];
      selectedEventDateTime = [];

      eventTypeFilter.forEach((e) {
        e.isSelected = false;
      });
      eventStatusFilter.forEach((e) {
        e.isSelected = false;
      });
      eventDurationFilter.forEach((e) {
        e.isSelected = false;
      });
      eventDateTimeFilter.forEach((e) {
        e.isSelected = false;
      });
      startDate = "";
      endDate = "";
      sortByFilter = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBarBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        shadowColor: Colors.transparent,
        title: TextButton(
          onPressed: () {
            clearAllFilters();
          },
          child: Text(
            AppLocalizations.of(context)!.mStaticClearAll,
            style: GoogleFonts.lato(
                color: AppColors.darkBlue,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600),
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.close))
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 20).r,
          height: 80.w,
          width: 1.sw,
          decoration: BoxDecoration(
            color: AppColors.appBarBackground,
            boxShadow: [
              BoxShadow(
                color: AppColors.greys.withValues(alpha: 0.2),
                offset: Offset(0, -4),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              widget.onFilterApplied({
                "eventType": selectedEventType,
                "eventStatus": selectedEventStatus,
                "eventDuration": selectedEventDuration,
                "eventStartDate": startDate,
                "eventEndDate": endDate,
                "eventDateTime": selectedEventDateTime,
                "sortBy": sortByFilter
              });
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: AppColors.appBarBackground,
              side: BorderSide(color: AppColors.darkBlue, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40).r,
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!
                  .mCompetenciesContentTypeApplyFilters,
              style: GoogleFonts.lato(
                  color: AppColors.darkBlue,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          Divider(
            color: AppColors.grey40,
            height: 0,
          ),
          Padding(
            padding: EdgeInsets.all(16).r,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EventsSortBy(
                  sortBy: sortByFilter,
                  onChanged: (value) {
                    sortByFilter = value;
                  },
                ),
                Divider(
                  color: AppColors.greys60,
                  height: 24.w,
                ),
                EventsFilterCheckbox(
                  checkListItems: eventTypeFilter,
                  onChanged: (value) {
                    selectedEventType = value;
                  },
                  selectedItems: selectedEventType,
                  title: Helper.capitalizeEachWordFirstCharacter(
                      AppLocalizations.of(context)!.mEventsType),
                  showSelectAll: false,
                ),
                Divider(
                  color: AppColors.greys60,
                  height: 24.w,
                ),
                EventDateFilters(
                  eventDateTimeFilter: eventDateTimeFilter,
                  selectedEventDateTimeFilter: selectedEventDateTime,
                  selectedEventStatus: selectedEventStatus,
                  eventEndDateFilter: endDate,
                  eventStartDateFilter: startDate,
                  eventStatusFilter: eventStatusFilter,
                  onFilterApplied: (filter) {
                    startDate = filter['startDate'] ?? "";
                    endDate = filter['endDate'] ?? "";
                    selectedEventStatus = filter['status'] ?? [];
                    selectedEventDateTime = filter['eventDateTime'] ?? [];
                    debugPrint("************************$filter");
                  },
                ),
                SizedBox(
                  height: 16.w,
                ),
                Divider(
                  color: AppColors.greys60,
                  height: 24.w,
                ),
                // EventsFilterCheckbox(
                //   checkListItems: eventDurationFilter,
                //   onChanged: (value) {
                //     selectedEventDuration = value;
                //   },
                //   showSearchBar: false,
                //   selectedItems: selectedEventDuration,
                //   title: "Event Duration",
                //   showSelectAll: false,
                // ),
                SizedBox(
                  height: 40.w,
                ),
              ],
            ),
          )
        ]),
      ),
    );
  }
}
