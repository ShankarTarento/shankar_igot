import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/models/_models/events_filter_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/view_all_event_with_filter/events_filter_screen/widgets/events_filter_checkbox.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/view_all_event_with_filter/events_filter_screen/widgets/events_filter_dates.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/view_all_event_with_filter/events_filter_screen/widgets/events_filter_radio_button.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// ignore: must_be_immutable
class EventDateFilters extends StatefulWidget {
  String? eventStartDateFilter;
  String? eventEndDateFilter;
  final List<EventFilterModel> eventStatusFilter;
  List<String> selectedEventStatus;
  final List<EventFilterModel> eventDateTimeFilter;
  List<String> selectedEventDateTimeFilter;

  final Function(Map<String, dynamic> filter) onFilterApplied;

  EventDateFilters({
    super.key,
    required this.eventStartDateFilter,
    required this.eventEndDateFilter,
    required this.eventStatusFilter,
    required this.onFilterApplied,
    required this.selectedEventStatus,
    required this.eventDateTimeFilter,
    required this.selectedEventDateTimeFilter,
  });

  @override
  State<EventDateFilters> createState() => _EventDateFiltersState();
}

class _EventDateFiltersState extends State<EventDateFilters> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Event Status Filter
        EventsFilterRadioButton(
          checkListItems: widget.eventStatusFilter,
          onChanged: (value) {
            setState(() {
              widget.selectedEventDateTimeFilter.clear();
              widget.eventDateTimeFilter.forEach((e) => e.isSelected = false);

              widget.selectedEventStatus = [value];
              widget.eventStartDateFilter = "";
              widget.eventEndDateFilter = "";
            });
            widget.onFilterApplied({
              'status': [value]
            });
          },
          selectedItem: widget.selectedEventStatus.isNotEmpty
              ? widget.selectedEventStatus[0]
              : null,
          title: Helper.capitalizeEachWordFirstCharacter(
              AppLocalizations.of(context)!.mEventStatus),
        ),

        // Event Date & Time Filter
        EventsFilterCheckbox(
          checkListItems: widget.eventDateTimeFilter,
          onChanged: (value) {
            setState(() {
              widget.selectedEventStatus.clear();
              widget.eventStatusFilter.forEach((e) => e.isSelected = false);

              widget.selectedEventDateTimeFilter = value;
              widget.eventStartDateFilter = "";
              widget.eventEndDateFilter = "";
            });
            widget.onFilterApplied({
              "eventDateTime": value,
            });
          },
          selectedItems: widget.selectedEventDateTimeFilter,
          title: Helper.capitalizeEachWordFirstCharacter(
              AppLocalizations.of(context)!.mEventDateTime),
          showSelectAll: false,
          showSearchBar: false,
        ),

        SizedBox(
          height: 16.w,
        ),

        // Date Range Filter
        EventsFilterDates(
          title: Helper.capitalizeEachWordFirstCharacter(
              AppLocalizations.of(context)!.mChooseDateRange),
          startDate: widget.eventStartDateFilter,
          endDate: widget.eventEndDateFilter,
          onChanged: (value) {
            setState(() {
              widget.selectedEventStatus.clear();
              widget.eventStatusFilter.forEach((e) => e.isSelected = false);
              widget.selectedEventDateTimeFilter.clear();
              widget.eventDateTimeFilter.forEach((e) => e.isSelected = false);
            });
            widget.eventStartDateFilter = value['startDate'];
            widget.eventEndDateFilter = value['endDate'];
            widget.onFilterApplied({
              "startDate":
                  value['startDate'] != null && value['startDate'] != ""
                      ? DateTimeHelper.convertDateFormat(value['startDate']!,
                          inputFormat: IntentType.dateFormat,
                          desiredFormat: IntentType.dateFormat4)
                      : "",
              "endDate": value['endDate'] != null && value['endDate'] != ""
                  ? DateTimeHelper.convertDateFormat(value['endDate']!,
                      inputFormat: IntentType.dateFormat,
                      desiredFormat: IntentType.dateFormat4)
                  : "",
            });
          },
        ),
      ],
    );
  }
}
