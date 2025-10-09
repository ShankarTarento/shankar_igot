import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../../../constants/_constants/color_constants.dart';
import '../../../../../../constants/_constants/telemetry_constants.dart';
import '../../../../../../respositories/_respositories/learn_repository.dart';
import '../../../../../../util/faderoute.dart';
import '../../../../../../util/telemetry_repository.dart';
import '../../model/ati_cti_microsite_data_model.dart';
import '../../model/microsites_training_calender_data_model.dart';
import '../../skeleton/microsites_training_calender_view_skeleton.dart';
import 'microsites_training_calendar_item_view.dart';
import 'microsites_training_calendar_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MicroSitesTrainingCalendarView extends StatefulWidget {
  final GlobalKey? containerKey;
  final String? orgId;
  final ColumnData? columnData;

  MicroSitesTrainingCalendarView({
    this.containerKey,
    this.orgId,
    this.columnData,
    Key? key,
  }) : super(key: key);

  @override
  _MicroSitesTrainingCalendarViewState createState() {
    return _MicroSitesTrainingCalendarViewState();
  }
}

class _MicroSitesTrainingCalendarViewState
    extends State<MicroSitesTrainingCalendarView> {
  Future<MicroSitesTrainingCalenderDataModel>?
      microSitesTrainingCalenderDataModelFuture;

  @override
  void initState() {
    super.initState();
    getMicroSiteCalenderData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildLayout();
  }

  Future<void> getMicroSiteCalenderData() async {
    var learnerReviewResponseData =
        await Provider.of<LearnRepository>(context, listen: false)
            .getMicroSiteCalenderData(
                widget.orgId ?? "", getCurrentDate(), getNextDate());
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
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

  Widget _buildLayout() {
    return Container(
      key: widget.containerKey,
      child: FutureBuilder(
          future: microSitesTrainingCalenderDataModelFuture,
          builder: (context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              List<EventDataModel> _eventList = snapshot.data.Event ?? [];
              return Container(
                margin: EdgeInsets.only(bottom: 8).w,
                child: Column(
                  children: [
                    _calendarTopView(),
                    Container(
                      color: AppColors.appBarBackground,
                      margin: EdgeInsets.only(top: 8).w,
                      padding: EdgeInsets.symmetric(horizontal: 8).w,
                      child: Column(
                        children: [
                          _calendarListView(_eventList),
                          Container(
                            alignment: Alignment.center,
                            margin:
                                EdgeInsets.only(left: 4, right: 4, bottom: 8).w,
                            child: _actionButtonView(
                              title: AppLocalizations.of(context)!
                                  .mStaticViewFullCalender,
                              backgroundColor: AppColors.appBarBackground,
                              action: () async {
                                _generateInteractTelemetryData(
                                    clickId:
                                        TelemetryIdentifier.viewFullCalendar,
                                    subType: TelemetrySubType.atiCti);
                                return Navigator.push(
                                  context,
                                  FadeRoute(
                                      page: MicroSitesTrainingCalendarScreen(
                                    orgId: widget.orgId,
                                    currentMonthNumber:
                                        getCurrentMonthNumber() - 1,
                                    currentYear: int.parse(getCurrentYear()),
                                  )),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return MicroSitesTrainingCalenderViewSkeleton(
                showTitle: true,
              );
            }
          }),
    );
  }

  Widget _calendarTopView() {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16).w,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(right: 4).w,
              child: Text(
                '${widget.columnData!.title}: ${getCurrentMonthYear()}',
                style: GoogleFonts.lato(
                    color: AppColors.greys87,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    letterSpacing: 0.12.w,
                    height: 1.5.w),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ));
  }

  Widget _calendarListView(List<EventDataModel> eventList) {
    return MicroSitesTrainingCalendarItemView(
      isShowAllEvents: false,
      eventDataModelList: eventList,
      monthName: getCurrentMonth().toLowerCase(),
      year: int.parse(getCurrentYear()),
      startDate: int.parse(getCurrentDayDate()),
    );
  }

  Widget _actionButtonView(
      {String? title, Color? backgroundColor, dynamic action}) {
    return TextButton(
        onPressed: action,
        style: TextButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.w),
              side: BorderSide(color: AppColors.darkBlue))
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8).w,
          child: Text(
            title!,
            style: GoogleFonts.lato(
              color: AppColors.darkBlue,
              fontWeight: FontWeight.w700,
              fontSize: 14.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ));
  }

  String getCurrentMonthYear() {
    return DateFormat('MMMM yyyy').format(DateTime.now());
  }

  String getCurrentMonth() {
    return DateFormat('MMMM').format(DateTime.now());
  }

  String getCurrentDayDate() {
    return DateFormat('dd').format(DateTime.now());
  }

  String getCurrentYear() {
    return DateFormat('yyyy').format(DateTime.now());
  }

  int getCurrentMonthNumber() {
    return DateTime.now().month;
  }

  String getCurrentDate() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  String getNextDate() {
    return DateFormat('yyyy-MM-dd')
        .format(DateTime.now().add(Duration(days: 1)));
  }

  void _generateInteractTelemetryData(
      {String? contentId, String? subType, String? clickId}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.browseByProviderAllCbpPageId,
        contentId: contentId ?? "",
        subType: subType ?? "",
        clickId: clickId ?? "",
        env: TelemetryEnv.learn);
    await telemetryRepository.insertEvent(eventData: eventData);
  }
}
