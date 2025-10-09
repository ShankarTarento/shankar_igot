import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/microsites/widgets/training_calendar/microsites_training_calendar_item_view.dart';
import 'package:provider/provider.dart';
import '../../../../../../constants/_constants/color_constants.dart';
import '../../../../../../respositories/_respositories/learn_repository.dart';
import '../../../../../../util/helper.dart';
import '../../model/microsites_training_calender_data_model.dart';
import '../../skeleton/microsites_training_calender_view_skeleton.dart';
import 'microsites_select_month_bottom_sheet.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MicroSitesTrainingCalendarScreen extends StatefulWidget {
  final String? orgId;
  final int? currentMonthNumber;
  final int? currentYear;

  MicroSitesTrainingCalendarScreen({
    this.orgId,
    this.currentMonthNumber,
    this.currentYear,
    Key? key,
  }) : super(key: key);

  @override
  _MicroSitesTrainingCalendarScreenState createState() {
    return _MicroSitesTrainingCalendarScreenState();
  }
}

class _MicroSitesTrainingCalendarScreenState
    extends State<MicroSitesTrainingCalendarScreen> {
  Future<MicroSitesTrainingCalenderDataModel>?
      microSitesTrainingCalenderDataModelFuture;
  List<MicroSitesTrainingCalenderMonthData> monthList = [];
  MicroSitesTrainingCalenderMonthData? selectedMonth;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getMicroSiteCalenderMonthData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getMicroSiteCalenderMonthData() async {
    monthList = generateMonthDataForYear(widget.currentYear!);
    selectedMonth = monthList[widget.currentMonthNumber!];
    if (selectedMonth != null) {
      getMicroSiteCalenderData();
    }
  }

  Future<void> getMicroSiteCalenderData() async {
    var learnerReviewResponseData = await Provider.of<LearnRepository>(context,
            listen: false)
        .getMicroSiteCalenderData(
            widget.orgId!, selectedMonth!.startDate!, selectedMonth!.endDate!);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        isLoading = false;
        if (learnerReviewResponseData != null)
          microSitesTrainingCalenderDataModelFuture = Future.value(
              MicroSitesTrainingCalenderDataModel.fromJson(
                  learnerReviewResponseData));
        else
          microSitesTrainingCalenderDataModelFuture =
              Future.value(MicroSitesTrainingCalenderDataModel());
      });
    });
  }

  Future<void> applyMonth(
      MicroSitesTrainingCalenderMonthData
          microSitesTrainingCalenderMonth) async {
    selectedMonth = microSitesTrainingCalenderMonth;
    getMicroSiteCalenderData();
    setState(() {
      isLoading = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _appBar(), body: _buildLayout());
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_sharp,
              size: 20.w, color: AppColors.greys60),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(right: 0).w,
              child: Text(
                '${AppLocalizations.of(context)!.mMicroSiteTrainingCalendar}: ${Helper.capitalizeFirstLetter(selectedMonth!.monthName!)} ${selectedMonth!.yearOfMonth}',
                style: GoogleFonts.lato(
                    color: AppColors.greys87,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    letterSpacing: 0.12.w,
                    height: 1.5.w),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        side: BorderSide(
                          color: AppColors.grey08,
                        ),
                      ),
                      builder: (BuildContext context) {
                        return MicroSitesSelectMonthBottomSheet(
                          monthList: monthList,
                          month: selectedMonth,
                          applyMonth: applyMonth,
                        );
                      });
                },
                child: Icon(Icons.keyboard_arrow_down))
          ],
        ));
  }

  Widget _buildLayout() {
    return SafeArea(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          margin: EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 16).w,
          child: isLoading
              ? MicroSitesTrainingCalenderViewSkeleton(
                  showTitle: false,
                )
              : FutureBuilder(
                  future: microSitesTrainingCalenderDataModelFuture,
                  builder: (context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      List<EventDataModel> _eventList =
                          snapshot.data.Event ?? [];
                      return Container(
                        margin: EdgeInsets.only(top: 8).w,
                        padding: EdgeInsets.symmetric(horizontal: 8).w,
                        child: _calendarListView(_eventList),
                      );
                    } else {
                      return MicroSitesTrainingCalenderViewSkeleton(
                        showTitle: false,
                      );
                    }
                  }),
        ),
      ),
    );
  }

  Widget _calendarListView(List<EventDataModel> eventList) {
    return MicroSitesTrainingCalendarItemView(
      isShowAllEvents: true,
      eventDataModelList: eventList,
      monthName: selectedMonth!.monthName!.toLowerCase(),
      year: int.parse(selectedMonth!.yearOfMonth!),
      startDate: 1,
    );
  }

  List<MicroSitesTrainingCalenderMonthData> generateMonthDataForYear(int year) {
    List<String> monthNames = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];

    List<MicroSitesTrainingCalenderMonthData> monthList = [];

    for (int i = 0; i < 12; i++) {
      String monthName = monthNames[i];
      DateTime startDate = DateTime(year, i + 1, 1);
      DateTime endDate = DateTime(year, i + 1, daysInMonth(year, i + 1));

      monthList.add(MicroSitesTrainingCalenderMonthData(
        monthName: monthName,
        yearOfMonth: year.toString(),
        startDate: formatDate(startDate),
        endDate: formatDate(endDate),
      ));
    }

    return monthList;
  }

  String formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  int daysInMonth(int year, int month) {
    DateTime firstDayNextMonth;
    if (month == 12) {
      firstDayNextMonth = DateTime(year + 1, 1, 1);
    } else {
      firstDayNextMonth = DateTime(year, month + 1, 1);
    }
    DateTime lastDayThisMonth = firstDayNextMonth.subtract(Duration(days: 1));
    return lastDayThisMonth.day;
  }
}
