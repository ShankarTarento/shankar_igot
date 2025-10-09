import 'dart:async';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../../../constants/index.dart';
import '../../../../services/_services/learn_service.dart';
import '../../../../util/index.dart';
import '../../../pages/_pages/learn/course_video_assessment.dart';
import '../../../pages/_pages/toc/model/navigation_model.dart';
import '../../../pages/_pages/toc/pages/services/toc_services.dart';
import '../../../pages/_pages/toc/util/toc_constants.dart';
import '../../../pages/_pages/toc/util/toc_helper.dart';
import '../../../pages/_pages/toc/view_model/toc_player_view_model.dart';
import './../../../widgets/index.dart';

class CourseAudioPlayer extends StatefulWidget {
  final String identifier;
  final String? batchId;
  final bool updateProgress;
  final ValueChanged<Map> parentAction;
  final bool isFeaturedCourse;
  final String parentCourseId;
  final ValueChanged<bool>? playNextResource;
  final NavigationModel resourceNavigateItems;
  final bool updatePlayerProgress;
  final bool? isPreRequisite;
  final String language;
  CourseAudioPlayer(
      {required this.identifier,
      required this.updateProgress,
      required this.parentAction,
      required this.parentCourseId,
      required this.resourceNavigateItems,
      this.batchId,
      this.isFeaturedCourse = false,
      this.playNextResource,
      required this.updatePlayerProgress,
      this.isPreRequisite = false,
      required this.language});
  @override
  _CourseAudioPlayerState createState() => _CourseAudioPlayerState();
}

class _CourseAudioPlayerState extends State<CourseAudioPlayer> {
  VideoPlayerController? _videoPlayerController1;
  final LearnService learnService = LearnService();
  ChewieController? _chewieController;
  int? _progressStatus;

  bool showVideo = false;

  Timer? _timer;
  int _start = 0;
  String? pageIdentifier;
  String? telemetryType;
  String? pageUri;
  String? batchId;
  late String courseId;
  bool _playerStatus = false, replayVideo = false;
  int? _currentProgress;
  NavigationModel? resourceInfo;

  @override
  void initState() {
    super.initState();
    courseId = TocPlayerViewModel()
        .getEnrolledCourseId(context, widget.parentCourseId);
    batchId = widget.batchId;
    fetchData();
  }

  _triggerTelemetryEvent() {
    if ((_start == 0 && widget.batchId != null)) {
      pageIdentifier = TelemetryPageIdentifier.audioPlayerPageId;
      telemetryType = TelemetryType.player;
      String assetFile = 'audio';
      pageUri =
          'viewer/$assetFile/${widget.parentCourseId}?primaryCategory=Learning%20Resource&collectionId=${widget.parentCourseId}&collectionType=Course&batchId=${widget.batchId}';
      _generateTelemetryData();
    }
    _startTimer();
  }

  void _startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        _start++;
      },
    );
  }

  void _generateTelemetryData() async {
    var telemetryRepository = TelemetryRepository();
    Map eventData1 = telemetryRepository.getStartTelemetryEvent(
        pageIdentifier: pageIdentifier ?? "",
        telemetryType: telemetryType ?? "",
        pageUri: pageUri ?? "",
        objectId: widget.parentCourseId,
        objectType: resourceInfo!.primaryCategory,
        env: TelemetryEnv.learn,
        isPublic: widget.isFeaturedCourse,
        l1: widget.parentCourseId);
    await telemetryRepository.insertEvent(
        eventData: eventData1, isPublic: widget.isFeaturedCourse);

    Map eventData2 = telemetryRepository.getImpressionTelemetryEvent(
        pageIdentifier: pageIdentifier ?? "",
        telemetryType: telemetryType ?? "",
        pageUri: pageUri ?? "",
        env: TelemetryEnv.learn,
        objectId: widget.parentCourseId,
        objectType: resourceInfo!.primaryCategory,
        isPublic: widget.isFeaturedCourse);
    await telemetryRepository.insertEvent(
        eventData: eventData2, isPublic: widget.isFeaturedCourse);
  }

  void _generateInteractTelemetryData(String contentId,
      {String subType = ''}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: pageIdentifier ?? "",
        contentId: contentId,
        subType: subType,
        env: TelemetryEnv.learn,
        objectType: resourceInfo!.primaryCategory,
        isPublic: widget.isFeaturedCourse);
    await telemetryRepository.insertEvent(
        eventData: eventData, isPublic: widget.isFeaturedCourse);
  }

  _triggerEndTelemetryEvent(String identifier) {
    if (widget.parentCourseId != '' && widget.batchId != null) {
      TocPlayerViewModel().endTelemetryEvent(
          identifier: identifier,
          duration: _start,
          isPublic: widget.isFeaturedCourse,
          objectType: resourceInfo != null ? resourceInfo!.primaryCategory : null,
          env: TelemetryEnv.learn,
          l1: widget.parentCourseId,
          pageIdentifier: pageIdentifier ?? "",
          telemetryType: telemetryType ?? "",
          pageUri: pageUri ?? "",
          rollup: {},
          );
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    if (widget.updateProgress &&
        !widget.isFeaturedCourse &&
        _progressStatus != null) {
      _updateContentProgress(
          progressStatus: _progressStatus!,
          contentId: widget.identifier,
          language: widget.language);
    }
    _videoPlayerController1?.dispose();
    _chewieController?.dispose();
    _triggerEndTelemetryEvent(widget.parentCourseId);

    super.dispose();
  }

  @override
  void didUpdateWidget(CourseAudioPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    doUpdateAudio(oldWidget);
  }

  Future<void> doUpdateAudio(CourseAudioPlayer oldWidget) async {
    if (widget.updatePlayerProgress && !widget.isFeaturedCourse) {
      await _updateContentProgress(
          progressStatus: _progressStatus!,
          contentId: widget.identifier,
          language: widget.language);
    } else {
      if (oldWidget.identifier != widget.identifier) {
        _triggerEndTelemetryEvent(oldWidget.identifier);
        await _updateContentProgress(
            progressStatus: _progressStatus!,
            contentId: oldWidget.identifier,
            language: oldWidget.language);
        _start = 0;
        if (_chewieController != null) {
          _chewieController!.pause();
          _chewieController!.dispose();
          _chewieController = null; // Reset chewie controller
        }
        if (_videoPlayerController1 != null) {
          _videoPlayerController1!.pause();
          _videoPlayerController1!.dispose();
          _videoPlayerController1 = null; // Reset video player controller
        }
        courseId = TocPlayerViewModel()
            .getEnrolledCourseId(context, widget.parentCourseId);
        batchId = widget.batchId;
        fetchData();
      }
    }
  }

  Future<void> initializePlayer() async {
    replayVideo = false;
    if (widget.identifier != '' &&
        resourceInfo!.currentProgress.toString() != '0') {
      _currentProgress =
          int.parse((resourceInfo!.currentProgress).split('.').first);
    } else {
      _currentProgress = 0;
    }
    _videoPlayerController1 = VideoPlayerController.networkUrl(
        Uri.parse(Helper.generateCdnUri(resourceInfo!.artifactUrl)));
    await Future.wait([
      _videoPlayerController1!.initialize(),
    ]);
    _videoPlayerController1!.seekTo(Duration(seconds: _currentProgress!));

    _videoPlayerController1!.addListener(() {
      if (_videoPlayerController1!.value.position ==
              _videoPlayerController1!.value.duration &&
          widget.parentCourseId == '' &&
          !showVideo) {
        setState(() {
          showVideo = true;
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CourseVideoAssessment()),
        );
      } else {
        if (_playerStatus != _videoPlayerController1!.value.isPlaying) {
          if (_videoPlayerController1!.value.isPlaying) {
            _generateInteractTelemetryData(widget.parentCourseId,
                subType: TelemetrySubType.playButton);
          } else {
            _generateInteractTelemetryData(widget.parentCourseId,
                subType: TelemetrySubType.pauseButton);
          }
        }
        _playerStatus = _videoPlayerController1!.value.isPlaying;
      }
    });

    _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController1!,
        autoPlay: true,
        looping: false,
        showOptions: false,
        allowFullScreen: false);
    setState(() {});
  }

  Future<void> _updateContentProgress(
      {progressStatus,
      required String contentId,
      required String language}) async {
    if (!widget.isFeaturedCourse &&
        (widget.resourceNavigateItems.status != 2)) {
      List<String> current = [];
      double currentPosition = 0.0;
      double duration = 0.0;
      List position =
          _videoPlayerController1!.value.position.toString().split(':');
      List totalTime =
          _videoPlayerController1!.value.duration.toString().split(':');
      currentPosition = double.parse(position[0]) * 60 * 60 +
          double.parse(position[1]) * 60 +
          double.parse(position[2]);
      duration = double.parse(totalTime[0]) * 60 * 60 +
          double.parse(totalTime[1]) * 60 +
          double.parse(totalTime[2]);
      current.add(currentPosition.toString());
      int status = progressStatus != 2
          ? currentPosition == duration
              ? 2
              : 1
          : 2;
      if (duration != 0) {
        double completionPercentage = (currentPosition / duration) * 100;
        if (completionPercentage >= ContentCompletionPercentage.audio) {
          completionPercentage = 100;
          status = 2;
        }

        Map data = {
          'identifier': contentId,
          'mimeType': EMimeTypes.mp3,
          'current': currentPosition.toString(),
          'completionPercentage': completionPercentage / 100
        };
        if ((resourceInfo!.completionPercentage * 100) < completionPercentage) {
          widget.parentAction(data);
          await TocPlayerViewModel().audioUpdateContentProgress(
              contentId: contentId,
              language: language,
              maxSize: duration,
              courseId: courseId,
              isPreRequisite: widget.isPreRequisite ?? false,
              status: status,
              completionPercentage: completionPercentage,
              current: current,
              batchId: batchId);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TocServices>(builder: (context, tocServices, _) {
      return Column(children: <Widget>[
        Expanded(
          child: Center(
            child: _chewieController != null
                ? Chewie(
                    controller: _chewieController!,
                  )
                : PageLoader(),
          ),
        ),
      ]);
    });
  }

  Future<void> fetchData() async {
    await getResourceInfo();
    if (resourceInfo != null) {
      _progressStatus = resourceInfo!.status;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        initializePlayer();
      });
      _triggerTelemetryEvent();
    }
  }

  Future<void> getResourceInfo() async {
    resourceInfo = await TocHelper.getResourceInfo(
        context: context,
        resourceId: widget.identifier,
        isFeatured: widget.isFeaturedCourse,
        resourceNavigateItems: widget.resourceNavigateItems);
  }
}
