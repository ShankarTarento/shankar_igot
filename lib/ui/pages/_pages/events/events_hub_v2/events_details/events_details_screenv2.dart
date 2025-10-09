import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/ui/components/microsite_image_view.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/respositories/_respositories/learn_repository.dart';
import 'package:karmayogi_mobile/services/_services/events_service.dart';
import 'package:karmayogi_mobile/services/_services/learn_service.dart';
import 'package:karmayogi_mobile/services/_services/smartech_service.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/event_overview/event_overview_v2.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/events_details/event_details_skeleton.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/events_details/widgets/competency_overview/competency_overview.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/events_details/widgets/event_details_appbar.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/events_details/widgets/event_enrollment_button.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/events_details/widgets/events_documents/events_documents.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/events_details/widgets/events_speakers.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/widgets/my_events/repository/my_events_repository.dart';
import 'package:karmayogi_mobile/ui/widgets/_events/models/event_enroll_model.dart';
import 'package:karmayogi_mobile/models/_models/event_detailv2_model.dart';
import 'package:karmayogi_mobile/respositories/_respositories/event_repository.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:karmayogi_mobile/util/telemetry_repository.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EventsDetailsScreenv2 extends StatefulWidget {
  final String eventId;
  EventsDetailsScreenv2({
    Key? key,
    required this.eventId,
  }) : super(key: key);

  @override
  State<EventsDetailsScreenv2> createState() => _EventsDetailsScreenv2State();
}

class _EventsDetailsScreenv2State extends State<EventsDetailsScreenv2> {
  EventDetailV2? eventDetails;
  late Future<EventDetailV2?> _eventDetailsFuture;
  final EventService eventService = EventService();
  EventEnrollModel? _eventEnrollData;
  List<String> _enrollFlowItems = [];
  bool isViewed = false;

  @override
  void initState() {
    super.initState();
    _eventDetailsFuture = _getEventDetails();
    _generateTelemetryData();
  }

  void _generateTelemetryData() async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getImpressionTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.eventDetailsPageId,
        telemetryType: TelemetryPageIdentifier.eventDetailsPageUri
            .replaceAll(':eventId', widget.eventId),
        pageUri: TelemetryPageIdentifier.eventDetailsPageUri
            .replaceAll(':eventId', widget.eventId),
        env: TelemetryEnv.events,
        objectId: widget.eventId,
        objectType: 'Event');
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  void smtTrackEventView() async {
    try {
      bool _isEventViewEnabled =
          await Provider.of<LearnRepository>(context, listen: false)
              .isSmartechEventEnabled(eventName: SMTTrackEvents.eventView);
      if (_isEventViewEnabled) {
        SmartechService.trackEventView(
          eventCategory: eventDetails?.resourceType ?? '',
          eventName: eventDetails?.name ?? '',
          eventId: widget.eventId,
          eventImage: eventDetails?.eventIcon ?? '',
          eventUrl: getEventUrl(),
          eventDuration: ((eventDetails?.duration ?? 0.0) * 60).toInt(),
          eventProviderName: eventDetails?.source ?? '',
        );
      }
    } catch (e) {
      debugPrint("e");
    }
  }

  void smtTrackEventEnrolled() async {
    try {
      bool _isEventEnrolmentEnabled =
          await Provider.of<LearnRepository>(context, listen: false)
              .isSmartechEventEnabled(eventName: SMTTrackEvents.eventEnrolment);
      if (_isEventEnrolmentEnabled) {
        SmartechService.trackEventEnroll(
          eventCategory: eventDetails?.resourceType ?? '',
          eventName: eventDetails?.name ?? '',
          eventId: widget.eventId,
          eventImage: eventDetails?.eventIcon ?? '',
          eventUrl: getEventUrl(),
          eventDuration: ((eventDetails?.duration ?? 0.0) * 60).toInt(),
          eventProviderName: eventDetails?.source ?? '',
        );
      }
    } catch (e) {
      print(e);
    }
  }

  String getEventUrl() {
    return ((eventDetails?.batches ?? []).isNotEmpty)
        ? "${ApiUrl.baseUrl}/app/event-hub/home/${widget.eventId}?batchId=${eventDetails?.batches![0].batchId ?? ''}"
        : "${ApiUrl.baseUrl}/app/event-hub/home/${widget.eventId}";
  }

  Future<List<String>> getEnrollFlowItems() async {
    try {
      dynamic data = await LearnService().getEventConfig();
      return List<String>.from(data['enrollFlowItems'] ?? []);
    } catch (_) {
      return [];
    }
  }

  Future<EventDetailV2?> _getEventDetails() async {
    _enrollFlowItems = await getEnrollFlowItems();
    eventDetails = await Provider.of<EventRepository>(context, listen: false)
        .getEventDetailsV2(widget.eventId);

    try {
      if (eventDetails != null &&
          _enrollFlowItems.contains(eventDetails?.resourceType ?? '')) {
        _eventEnrollData = await _getEventEnrollDetails();
      }
    } catch (e) {
      debugPrint('error');
    }
    return Future.value(eventDetails);
  }

  Future<EventEnrollModel?> _getEventEnrollDetails() async {
    var response = await Provider.of<EventRepository>(context, listen: false)
        .getEventEnrollDetails(
            widget.eventId,
            ((eventDetails?.batches ?? []).isNotEmpty)
                ? eventDetails?.batches![0].batchId ?? ''
                : '');
    return response;
  }

  Future<void> _enrollEvent() async {
    _generateInteractTelemetryData(
      widget.eventId,
      subType: TelemetrySubType.enrollNowEvents,
    );

    try {
      final batchId = (eventDetails?.batches?.isNotEmpty ?? false)
          ? eventDetails!.batches![0].batchId
          : '';

      final message = await eventService.enrollToEvent(
        eventDetails?.identifier ?? '',
        batchId ?? '',
      );

      if (message == 'SUCCESS') {
        final data = await _getEventDetails();

        setState(() {
          _eventDetailsFuture = Future.value(data);
        });

        Helper.showSnackBarMessage(
          context: context,
          text: AppLocalizations.of(context)!.mStaticEnrolledSuccessfully,
          bgColor: AppColors.positiveLight,
        );
        smtTrackEventEnrolled();
        if (eventDetails != null) {
          await Helper()
              .addEventToCalendar(event: eventDetails!, context: context);
        }
      } else {
        Helper.showSnackBarMessage(
          context: context,
          text: message,
          bgColor: AppColors.negativeLight,
        );
      }
    } catch (error) {
      debugPrint("$error");
    } finally {
      await Provider.of<MyEventsRepository>(context, listen: false)
          .getAllEnrolledEvents();
    }
  }

  Future<void> _reloadEventData() async {
    setState(() {
      _eventDetailsFuture = _getEventDetails();
    });
  }

  bool hasBatchId() {
    try {
      return eventDetails?.batches?.isNotEmpty == true
          ? eventDetails?.batches?.first.batchId != null
          : false;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _eventDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return EventDetailsSkeleton();
          }
          if (snapshot.data != null) {
            if (!isViewed) {
              smtTrackEventView();
              isViewed = true;
            }
            return Scaffold(
              backgroundColor: AppColors.whiteGradientOne,
              appBar: EventDetailsAppbar(
                eventId: widget.eventId,
              ),
              bottomNavigationBar: SafeArea(
                child: Container(
                    color: AppColors.appBarBackground,
                    padding:
                        EdgeInsets.only(bottom: 20, top: 12, right: 8, left: 8)
                            .r,
                    child: EventEnrollmentButton(
                      eventDetail: snapshot.data!,
                      enableEventEnroll: (_enrollFlowItems
                              .contains(snapshot.data?.resourceType ?? '') &&
                          hasBatchId()),
                      isEnrolled: ((_eventEnrollData != null)
                          ? (_eventEnrollData?.events ?? []).isNotEmpty
                          : false),
                      reloadCallback: _reloadEventData,
                      enrollCallback: _enrollEvent,
                    )),
              ),
              body: buildLayout(),
            );
          } else {
            return SafeArea(
              child: Scaffold(
                  backgroundColor: AppColors.whiteGradientOne,
                  appBar: EventDetailsAppbar(
                    eventId: widget.eventId,
                  ),
                  body: Center(
                    child: Text(AppLocalizations.of(context)!.mMsgNoDataFound,
                        style: GoogleFonts.lato(
                          fontSize: 16.sp,
                        )),
                  )),
            );
          }
        });
  }

  Widget buildLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10).r,
            decoration: BoxDecoration(
              color: AppColors.whiteGradientOne,
              borderRadius: BorderRadius.circular(8).r,
            ),
            child: Container(
              padding: EdgeInsets.all(10).r,
              decoration: BoxDecoration(
                color: AppColors.appBarBackground,
                borderRadius: BorderRadius.circular(8).r,
              ),
              child: Column(
                children: [
                  eventBannerWidget(),
                  EventOverviewV2(
                    eventDetail: eventDetails,
                    eventEnrollData:
                        (((_eventEnrollData?.events ?? []).isNotEmpty)
                            ? (_eventEnrollData?.events ?? [])[0]
                            : null),
                    enableEventEnroll: (_enrollFlowItems
                            .contains(eventDetails?.resourceType ?? '') &&
                        hasBatchId()),
                    isEnrolled: ((_eventEnrollData != null)
                        ? (_eventEnrollData?.events ?? []).isNotEmpty
                        : false),
                  ),
                  if (eventDetails?.competencyV6 != null &&
                      eventDetails!.competencyV6!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CompetencyOverview(
                          competencies: eventDetails!.competencyV6!,
                        ),
                        Divider(
                          color: AppColors.greys60,
                          height: 8.w,
                        ),
                      ],
                    ),
                  if (eventDetails?.eventHandouts != null &&
                      eventDetails!.eventHandouts!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EventsDocuments(
                          eventHandouts: eventDetails!.eventHandouts!,
                        ),
                        Divider(
                          height: 8.w,
                          color: AppColors.greys60,
                        ),
                      ],
                    ),
                  if (eventDetails!.speakers != null &&
                      eventDetails!.speakers!.isNotEmpty)
                    EventsSpeakers(
                      speakersList: eventDetails!.speakers!,
                    ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 50.w,
          )
        ],
      ),
    );
  }

  Widget eventBannerWidget() {
    return Container(
        width: double.infinity,
        height: 240.w,
        child:
            (eventDetails?.eventIcon != null && eventDetails?.eventIcon != '')
                ? MicroSiteImageView(
                    imgUrl: Helper.convertImageUrl(eventDetails!.eventIcon!),
                    height: 240.w,
                    width: double.maxFinite,
                    fit: BoxFit.fill,
                  )
                : Image.asset(
                    'assets/img/image_placeholder.jpg',
                    fit: BoxFit.cover,
                  ));
  }

  void _generateInteractTelemetryData(String contentId,
      {String subType = '',
      String? primaryCategory,
      bool isObjectNull = false,
      String clickId = ''}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.eventDetailsPageUri
            .replaceAll(':eventId', widget.eventId),
        contentId: contentId,
        subType: subType,
        env: TelemetryEnv.events,
        objectType: primaryCategory ?? (isObjectNull ? null : subType),
        clickId: clickId);
    await telemetryRepository.insertEvent(eventData: eventData);
  }
}
