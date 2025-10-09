import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../constants/index.dart';
import '../../../../services/index.dart';
import '../../../../util/index.dart';
import '../../../pages/_pages/toc/view_model/toc_player_view_model.dart';
import '../../_events/widgets/custom_youtube_player.dart';
import '../../../pages/_pages/toc/model/navigation_model.dart';
import '../../../pages/_pages/toc/util/toc_helper.dart';

class CourseYoutubePlayer extends StatefulWidget {
  final String identifier;
  final String duration;
  final String contentId;
  final String? batchId;
  final bool isFeaturedCourse;
  final NavigationModel? resourceNavigateItems;
  final updateContentProgress;
  final bool? isPreRequisite;
  final String language;

  CourseYoutubePlayer(
      {required this.identifier,
      required this.duration,
      required this.contentId,
      this.batchId,
      this.isFeaturedCourse = false,
      this.resourceNavigateItems,
      this.updateContentProgress,
      this.isPreRequisite = false,
      required this.language});
  @override
  State<CourseYoutubePlayer> createState() => _CourseYoutubePlayerState();
}

class _CourseYoutubePlayerState extends State<CourseYoutubePlayer> {
  Future<NavigationModel>? updatedResourseData;
  TelemetryRepository telemetryRepository = TelemetryRepository();
  LearnService learnService = LearnService();
  int _start = 0;
  late String pageIdentifier;
  late String telemetryType;
  late String pageUri;
  late NavigationModel? resourse;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchData() async {
    updatedResourseData = Future.value(await TocHelper.getResourceInfo(
        context: context,
        resourceId: widget.contentId,
        isFeatured: widget.isFeaturedCourse,
        resourceNavigateItems: widget.resourceNavigateItems!));
    if (mounted) {
      Future.delayed(Duration.zero, () => setState(() {}));
    }
    resourse = await updatedResourseData;
    if (resourse != null) {
      _generateTelemetryData();
    }
  }

  void _generateTelemetryData() async {
    pageIdentifier = TelemetryPageIdentifier.youtubePlayerPageId;
    telemetryType = TelemetryType.player;
    var batchId = widget.batchId ?? '';
    pageUri =
        'viewer/youtube/${widget.identifier}?primaryCategory=Learning%20Resource&collectionId=${widget.identifier}&collectionType=Course&batchId=$batchId';

    Map eventData1 = telemetryRepository.getStartTelemetryEvent(
        pageIdentifier: pageIdentifier,
        telemetryType: telemetryType,
        pageUri: pageUri,
        objectId: widget.contentId,
        objectType: resourse!.primaryCategory,
        env: TelemetryEnv.learn,
        isPublic: widget.isFeaturedCourse,
        l1: widget.identifier);
    await telemetryRepository.insertEvent(
        eventData: eventData1, isPublic: widget.isFeaturedCourse);

    Map eventData2 = telemetryRepository.getImpressionTelemetryEvent(
        pageIdentifier: pageIdentifier,
        telemetryType: telemetryType,
        pageUri: pageUri,
        env: TelemetryEnv.learn,
        objectId: widget.contentId,
        objectType: resourse!.primaryCategory,
        isPublic: widget.isFeaturedCourse);
    await telemetryRepository.insertEvent(
        eventData: eventData2, isPublic: widget.isFeaturedCourse);
  }

  Future<void> _updateContentProgress(Map value) async {
    String courseId =
        TocPlayerViewModel().getEnrolledCourseId(context, widget.identifier);
    if (widget.batchId != null &&
        widget.resourceNavigateItems != null &&
        (widget.resourceNavigateItems!.completionPercentage * 100) <
            value['completionPercentage']) {
      await learnService.updateContentProgress(
          courseId,
          widget.batchId!,
          widget.contentId,
          value['status'],
          value['contentType'],
          value['current'],
          value['maxSize'],
          double.parse(value['completionPercentage'].toString()),
          isPreRequisite: widget.isPreRequisite,
          language: widget.language);

      Map data = {
        'identifier': widget.contentId,
        'mimeType': value['contentType'],
        'current': value['current'].first,
        'completionPercentage': value['completionPercentage'] / 100
      };
      await widget.updateContentProgress(data);
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
        await doPop(context);
      },
      child: FutureBuilder(
          future: updatedResourseData,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              NavigationModel resourseData = snapshot.data;
              return CustomYoutubePlayer(
                  url: resourseData.artifactUrl ?? '',
                  batchId: widget.batchId,
                  status: resourseData.status,
                  updateContentProgress: _updateContentProgress,
                  completionRequiredPercentage: 100,
                  currentProgress: resourseData.currentProgress,
                  currentWatchTime: double.parse(resourseData.currentProgress),
                  completionRequiredTimeInSec: 0,
                  isFeatured: widget.isFeaturedCourse,
                  onNavigateBack: () async {
                    await doPop(context);
                  });
            } else {
              return Center();
            }
          }),
    );
  }

  Future<void> doPop(BuildContext context) async {
    if (resourse != null) {
      Map eventData = telemetryRepository.getEndTelemetryEvent(
          pageIdentifier: pageIdentifier,
          duration: _start,
          telemetryType: telemetryType,
          pageUri: pageUri,
          rollup: {},
          objectId: widget.contentId,
          objectType: resourse!.primaryCategory,
          env: TelemetryEnv.learn,
          isPublic: widget.isFeaturedCourse,
          l1: widget.identifier);
      await telemetryRepository
          .insertEvent(eventData: eventData, isPublic: widget.isFeaturedCourse)
          .then((_) {
        Navigator.of(context).pop();
      });
    } else {
      Navigator.of(context).pop();
    }
  }
}
