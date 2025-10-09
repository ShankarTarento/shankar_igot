import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_models/event_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/mdo_channels/screens/mdo_channel_screen/widgets/state_learning_week/slw_repository/slw_repository.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/national_learning_week/services/national_learning_week_view_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/national_learning_week/widgets/explore_events/widgets/explore_events_card.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/national_learning_week/widgets/explore_events/widgets/explore_events_skeleton.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/events_hub.dart';
import 'package:karmayogi_mobile/ui/widgets/title_widget/title_widget.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';

class SlwExploreEventsStrip extends StatefulWidget {
  final String startDate;
  final String endDate;
  final Map<String, dynamic> exploreEventsData;
  const SlwExploreEventsStrip({
    required this.endDate,
    required this.startDate,
    required this.exploreEventsData,
    super.key,
  });

  @override
  State<SlwExploreEventsStrip> createState() => _SlwExploreEventsStripState();
}

class _SlwExploreEventsStripState extends State<SlwExploreEventsStrip> {
  String? dropdownValue;
  List<String> dropdownItems = [];
  late Future<List<Event>> eventsList;

  void initState() {
    super.initState();
    dropdownItems = getDatesBetween(
        endDate: DateTime.parse(widget.endDate),
        startDate: DateTime.parse(widget.startDate));
    String currentDate =
        DateFormat(IntentType.dateFormat2).format(DateTime.now());
    if (dropdownItems.contains(currentDate)) {
      dropdownValue = currentDate;
    } else {
      dropdownValue = dropdownItems[0];
    }

    eventsList = SlwRepository().getAllEvents(
      request: widget.exploreEventsData['column']?[0]?['request'] ?? null,
      startDate: format.format(DateTime.now()),
    );
  }

  DateFormat format = DateFormat(IntentType.dateFormat4);

  List<String> getDatesBetween(
      {required DateTime startDate, required DateTime endDate}) {
    List<String> dateList = [];

    if (startDate.isAfter(endDate)) {
      return dateList;
    }

    DateTime currentDate = startDate;

    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      dateList.add(DateFormat(IntentType.dateFormat2).format(currentDate));
      currentDate = currentDate.add(Duration(days: 1));
    }
    return dateList;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16).r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 12.w,
          ),
          TitleWidget(
            title: widget.exploreEventsData['title'] ?? 'Explore Events',
            showAllCallBack: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => EventsHub()));
            },
          ),
          SizedBox(
            height: 20.w,
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton2<String>(
              selectedItemBuilder: (context) {
                return dropdownItems.map((item) {
                  return _buildDropdownItem(item, selected: false);
                }).toList();
              },
              isExpanded: true,
              items: dropdownItems.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  alignment: AlignmentDirectional.center,
                  child:
                      _buildDropdownItem(item, selected: dropdownValue == item),
                );
              }).toList(),
              value: dropdownValue,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    dropdownValue = value;
                    eventsList = NationalLearningWeekViewModel().getAllEvents(
                        startDate: DateTimeHelper.convertDateFormat(value,
                            inputFormat: IntentType.dateFormat2,
                            desiredFormat: IntentType.dateFormat4));
                  });
                }
              },
              buttonStyleData: ButtonStyleData(
                height: 32.w,
                width: 135.w,
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50).r,
                  border: Border.all(color: AppColors.grey16),
                  color: AppColors.appBarBackground,
                  boxShadow: [BoxShadow(color: Colors.transparent)],
                ),
                elevation: 2,
              ),
              iconStyleData: IconStyleData(
                icon: Icon(Icons.arrow_drop_down),
                iconSize: 14.w,
                iconEnabledColor: AppColors.greys,
                iconDisabledColor: AppColors.greys,
              ),
              dropdownStyleData: DropdownStyleData(
                width: 150.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4).r,
                  color: AppColors.appBarBackground,
                ),
                offset: Offset(0, -5),
                scrollbarTheme: ScrollbarThemeData(
                  radius: Radius.circular(40).r,
                  thickness: WidgetStateProperty.all(6),
                  thumbVisibility: WidgetStateProperty.all(true),
                ),
              ),
              menuItemStyleData: MenuItemStyleData(),
            ),
          ),
          SizedBox(
            height: 20.w,
          ),
          FutureBuilder<List<Event>>(
              future: eventsList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView.separated(
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 4,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return ExploreEventsSkeleton();
                    },
                    separatorBuilder: (context, index) {
                      return SizedBox(
                        height: 16.w,
                      );
                    },
                  );
                }

                if (snapshot.data != null) {
                  if (snapshot.data!.isNotEmpty) {
                    return ListView.separated(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount:
                          snapshot.data!.length > EVENT_EXPLORE_LIST_LIMIT
                              ? EVENT_EXPLORE_LIST_LIMIT
                              : snapshot.data!.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return ExploreEventsCard(
                          event: snapshot.data![index],
                        );
                      },
                      separatorBuilder: (context, index) {
                        return SizedBox(
                          height: 16.w,
                        );
                      },
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(top: 100.0, bottom: 150).r,
                      child: Center(
                          child: Text(
                              AppLocalizations.of(context)!.mNoResourcesFound)),
                    );
                  }
                }
                if (snapshot.data == null) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 100.0, bottom: 150).r,
                    child: Center(
                        child: Text(
                            AppLocalizations.of(context)!.mNoResourcesFound)),
                  );
                }
                return SizedBox();
              }),
          SizedBox(
            height: 20.w,
          )
        ],
      ),
    );
  }

  Widget _buildDropdownItem(String item, {required bool selected}) {
    return Center(
      child: Text(
        item,
        style: GoogleFonts.lato(
          fontSize: 14.sp,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          color: selected ? AppColors.darkBlue : AppColors.greys,
        ),
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        maxLines: 1,
      ),
    );
  }
}
