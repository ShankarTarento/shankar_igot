import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/models/_models/event_detailv2_model.dart';
import 'package:karmayogi_mobile/respositories/_respositories/event_repository.dart';
import 'package:karmayogi_mobile/services/_services/events_service.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/event_player_v2/custom_event_video_player.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/event_player_v2/event_player_v2_skeleton.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/events_comments_v2/events_comments_v2.dart';
import 'package:karmayogi_mobile/ui/widgets/_events/models/event_state_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_events/widgets/custom_youtube_player.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:provider/provider.dart';

import '../../../../../../constants/index.dart';

class EventPlayerV2Screen extends StatefulWidget {
  final EventDetailV2 eventDetail;
  final String mediaLink;
  final bool isEnrolled;

  const EventPlayerV2Screen(
      {super.key,
      required this.eventDetail,
      required this.mediaLink,
      required this.isEnrolled,
      req});

  @override
  State<EventPlayerV2Screen> createState() => _EventPlayerV2ScreenState();
}

class _EventPlayerV2ScreenState extends State<EventPlayerV2Screen> with TickerProviderStateMixin {
  late Future<EventStateModel?> _eventStateFuture;
  final EventService eventService = EventService();

  @override
  void initState() {
    super.initState();
    _eventStateFuture = _getEventStateDetails();
  }

  Future<EventStateModel?> _getEventStateDetails() async {
    var response = await Provider.of<EventRepository>(context, listen: false)
        .getEventStateDetails(
            widget.eventDetail.identifier,
            ((widget.eventDetail.batches ?? []).isNotEmpty)
                ? widget.eventDetail.batches![0].batchId ?? ''
                : '');
    return response;
  }

  formateTime(time) {
    return time.substring(0, 5);
  }

  bool isEvenStarted() {
    int timestampNow = DateTime.now().millisecondsSinceEpoch;
    String start = widget.eventDetail.startDate +
        ' ' +
        formateTime(widget.eventDetail.startTime);
    DateTime startDate = DateTime.parse(start);
    int timestampStartEvent = startDate.microsecondsSinceEpoch;
    double eventStartTime = timestampStartEvent / 1000;
    if (timestampNow >= eventStartTime) {
      return true;
    }
    return false;
  }

  double getStateMetadataAsDouble(dynamic progressDetails) {
    try {
      if (progressDetails is String) {
        Map<String, dynamic> jsonMap = json.decode(progressDetails);
        if (jsonMap.containsKey('stateMetaData')) {
          return (jsonMap['stateMetaData']).toDouble(); // Convert to double
        }
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  double getEventCurrentWatchTimeAsDouble(dynamic progressDetails) {
    try {
      if (progressDetails is String) {
        Map<String, dynamic> jsonMap = json.decode(progressDetails);
        if (jsonMap.containsKey('duration')) {
          return (jsonMap['duration']).toDouble(); // Convert to double
        }
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  Future<void> updateContentProgress(Map data) async {
    if (isEvenStarted() && (widget.isEnrolled)) {
      await eventService.updateEventProgress(
          widget.eventDetail.identifier,
          ((widget.eventDetail.batches ?? []).isNotEmpty)
              ? widget.eventDetail.batches![0].batchId ?? ''
              : '',
          data['status'],
          data['contentType'],
          data['current'],
          data['maxSize'],
          data['completionPercentage'],
          data['totalWatchedTime'],
          data['currentTime']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        Navigator.pop(context);
      },
      child: FutureBuilder(
        future: _eventStateFuture,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            EventStateModel eventStateModel = snapshot.data;
            return isYouTubeUrl(widget.mediaLink)
                ? CustomYoutubePlayer(
                    title: widget.eventDetail.name,
                    appbar: AppColors.appBarBackground,
                    leadingIconColor: AppColors.greys,
                    batchId: ((widget.eventDetail.batches ?? []).isNotEmpty)
                        ? widget.eventDetail.batches![0].batchId ?? ''
                        : '',
                    url: widget.mediaLink,
                    currentProgress: getStateMetadataAsDouble(
                        ((eventStateModel.events ?? []).isNotEmpty)
                            ? (eventStateModel.events![0].progressDetails ?? '')
                            : ''),
                    currentWatchTime: getEventCurrentWatchTimeAsDouble(
                        ((eventStateModel.events ?? []).isNotEmpty)
                            ? (eventStateModel.events![0].progressDetails ?? '')
                            : ''),
                    progressPercentage:
                        ((eventStateModel.events ?? []).isNotEmpty)
                            ? ((eventStateModel.events![0].completionPercentage ??
                                    0) /
                                100)
                            : 0.0,
                    status: ((eventStateModel.events ?? []).isNotEmpty)
                        ? (eventStateModel.events![0].status ?? 0)
                        : 0,
                    isLive: Helper.isEventLive(
                        endDate: widget.eventDetail.endDate.toString(),
                        endTime: widget.eventDetail.endTime.toString(),
                        startDate: widget.eventDetail.startDate.toString(),
                        startTime: widget.eventDetail.startTime.toString()),
                    contentDuration: (widget.eventDetail.duration != null)
                        ? (widget.eventDetail.duration! * 60)
                        : null, //duration is coming in mins
                    completionRequiredPercentage: EVENT_COMPLETION_PERCENTAGE,
                    completionRequiredTimeInSec:
                        Provider.of<EventRepository>(context, listen: false)
                            .eventCompletionDurationInSeconds,
                    // primaryCategory: TelemetrySubType.eventsTab,
                    // telemetryEnv: TelemetryEnv.learn,
                    contentChildWidget: eventCommentsSection(eventStateModel),
                    updateContentProgress: updateContentProgress,
                  )
                : CustomEventVideoPlayer(
                    title: widget.eventDetail.name,
                    identifier: widget.eventDetail.identifier,
                    batchId: ((widget.eventDetail.batches ?? []).isNotEmpty)
                        ? widget.eventDetail.batches![0].batchId ?? ''
                        : '',
                    url: widget.mediaLink,
                    currentProgress: getStateMetadataAsDouble(
                        ((eventStateModel.events ?? []).isNotEmpty)
                            ? (eventStateModel.events![0].progressDetails ?? '')
                            : ''),
                    currentWatchTime: getEventCurrentWatchTimeAsDouble(
                        ((eventStateModel.events ?? []).isNotEmpty)
                            ? (eventStateModel.events![0].progressDetails ?? '')
                            : ''),
                    progressPercentage:
                        ((eventStateModel.events ?? []).isNotEmpty)
                            ? ((eventStateModel.events![0].completionPercentage ??
                                    0) /
                                100)
                            : 0.0,
                    status: ((eventStateModel.events ?? []).isNotEmpty)
                        ? (eventStateModel.events![0].status ?? 0)
                        : 0,
                    isLive: Helper.isEventLive(
                        endDate: widget.eventDetail.endDate.toString(),
                        endTime: widget.eventDetail.endTime.toString(),
                        startDate: widget.eventDetail.startDate.toString(),
                        startTime: widget.eventDetail.startTime.toString()),
                    contentDuration: (widget.eventDetail.duration != null)
                        ? (widget.eventDetail.duration! * 60)
                        : null,
                    completionRequiredPercentage: EVENT_COMPLETION_PERCENTAGE,
                    completionRequiredTimeInSec:
                        Provider.of<EventRepository>(context, listen: false)
                            .eventCompletionDurationInSeconds,
                    primaryCategory: TelemetrySubType.eventsTab,
                    telemetryEnv: TelemetryEnv.learn,
                    contentChildWidget: eventCommentsSection(eventStateModel),
                    updateContentProgress: updateContentProgress,
                  );
          } else {
            return EventPlayerV2Skeleton();
          }
        },
      ),
    );
  }

  Widget eventCommentsSection(EventStateModel? eventStateModel) {
    return Expanded(
        child: Container(
            width: 1.sw,
            alignment: Alignment.topLeft,
            decoration: BoxDecoration(
              color: AppColors.appBarBackground,
              borderRadius: BorderRadius.all(const Radius.circular(12.0)).r,
            ),
            child: EventCommentsV2(
              courseId: widget.eventDetail.identifier,
              isEnrolled: true,
            )));
  }

  bool isYouTubeUrl(String url) {
    return url.contains('youtube');
  }
}
