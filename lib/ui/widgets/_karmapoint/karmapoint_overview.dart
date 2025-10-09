import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../constants/index.dart';
import '../../../respositories/_respositories/profile_repository.dart';
import '../../../util/telemetry_repository.dart';
import '../index.dart';

class KarmaPointOverview extends StatefulWidget {
  final Map<dynamic, dynamic>? karmaPointList;

  const KarmaPointOverview({Key? key, this.karmaPointList}) : super(key: key);
  KarmaPointOverviewState createState() => KarmaPointOverviewState();
}

class KarmaPointOverviewState extends State<KarmaPointOverview> {
  List karmaPointList = [];
  int count = 0;
  late Future<Map<dynamic, dynamic>> karmaPointsFuture;
  ScrollController _scrollController = ScrollController();
  late String userId;
  late String userSessionId;
  late String messageIdentifier;
  late String departmentId;
  late String pageIdentifier;
  late String telemetryType;
  late String pageUri;
  List allEventsData = [];
  late String deviceIdentifier;
  var telemetryEventData;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    if (widget.karmaPointList == null) {
      getKarmaPointsHistory(
          limit: KARMAPOINT_READ_LIMIT,
          offset: DateTime.now().millisecondsSinceEpoch);
    } else {
      karmaPointList = widget.karmaPointList!['kpList'];
      count = widget.karmaPointList!['count'];
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      getKarmaPointsHistory(
          limit: count > KARMAPOINT_READ_LIMIT ? KARMAPOINT_READ_LIMIT : count,
          offset: DateTime.now().millisecondsSinceEpoch);
    }
  }

  Future<void> getKarmaPointsHistory({limit, offset}) async {
    _generateTelemetryData();
    var response = await Provider.of<ProfileRepository>(context, listen: false)
        .getKarmaPointHistory(limit: limit, offset: offset);
    setState(() {
      count = response['count'];
      response['kpList'].forEach((newitem) {
        bool isPontInList = false;
        karmaPointList.forEach((kpItem) {
          if ((newitem['operation_type'] == kpItem['operation_type'] &&
                  newitem['context_id'] == kpItem['context_id']) ||
              (newitem['operation_type'] == kpItem['operation_type'] &&
                  kpItem['operation_type'] == OperationTypes.firstLogin)) {
            isPontInList = true;
          }
        });
        if (!isPontInList) {
          karmaPointList.add(newitem);
        }
      });
    });
    print(karmaPointList);
  }

  void _generateTelemetryData() async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getImpressionTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.karmaPointOverviewPageId,
        telemetryType: TelemetryType.page,
        pageUri: TelemetryPageIdentifier.karmaPointOverviewPageUri,
        env: TelemetryEnv.profile,
        subType: TelemetrySubType.scroll);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        toolbarHeight: kToolbarHeight.w,
        leading: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Icon(Icons.arrow_back, size: 24.sp)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.mStaticKarmaPoints,
              style: GoogleFonts.lato(
                color: AppColors.greys87,
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
                letterSpacing: 0.12,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16).r,
              child: TooltipWidget(
                  message: AppLocalizations.of(context)!.mStaticKarmaPointInfo,
                  iconSize: 20,
                  triggerMode: TooltipTriggerMode.tap),
            )
          ],
        ),
      ),
      body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll
                .disallowIndicator(); //previous code overscroll.disallowGlow();
            return true;
          },
          child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent) {
                  if (count > karmaPointList.length) {
                    int listLengthDiff = count - karmaPointList.length;
                    getKarmaPointsHistory(
                        limit: listLengthDiff > KARMAPOINT_READ_LIMIT
                            ? KARMAPOINT_READ_LIMIT
                            : listLengthDiff,
                        offset: karmaPointList[karmaPointList.length - 1]
                            ['credit_date']);
                  }
                }
                return true;
              },
              child: SingleChildScrollView(
                child: Container(
                  color: AppColors.scaffoldBackground,
                  child: Column(
                    children: [
                      ListView.builder(
                        controller: _scrollController,
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: karmaPointList.length,
                        itemBuilder: (BuildContext context, int index) {
                          Map kpItem = karmaPointList[index];
                          return count > karmaPointList.length &&
                                  index == karmaPointList.length
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    KarmapointCard(kpItem: kpItem),
                                    SizedBox(
                                        height: 50.w,
                                        width: 50.w,
                                        child: PageLoader())
                                  ],
                                )
                              : KarmapointCard(kpItem: kpItem);
                        },
                      ),
                      SizedBox(
                        height: 48.w,
                      )
                    ],
                  ),
                ),
              ))),
    );
  }
}
