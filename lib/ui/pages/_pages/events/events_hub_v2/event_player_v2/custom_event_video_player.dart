import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/services/_services/events_service.dart';
import 'package:chewie/chewie.dart';
import 'package:karmayogi_mobile/util/telemetry_repository.dart';
import 'package:video_player/video_player.dart';

class CustomEventVideoPlayer extends StatefulWidget {
  final String identifier;
  final String? batchId;
  final String url;
  final currentProgress;
  final currentWatchTime;
  final double? progressPercentage;
  final double? contentDuration;
  final int? status;
  final bool? isLive;
  final int completionRequiredPercentage;
  final double completionRequiredTimeInSec;
  final String primaryCategory;
  final String telemetryEnv;
  final Widget? contentChildWidget;
  final ValueChanged<Map> updateContentProgress;
  final Future<void> Function({bool isFromDisposeFunction})? setAllOrientation;
  final Future<void> Function()? setLandscape;
  final String? title;

  CustomEventVideoPlayer({
    required this.identifier,
    this.batchId,
    required this.url,
    this.currentProgress,
    this.currentWatchTime,
    this.progressPercentage,
    this.contentDuration,
    this.status,
    this.isLive = false,
    this.completionRequiredPercentage = 100,
    this.completionRequiredTimeInSec = 180,
    required this.primaryCategory,
    required this.telemetryEnv,
    this.contentChildWidget,
    required this.updateContentProgress,
    this.setAllOrientation,
    this.setLandscape,
    this.title,
  });

  @override
  _CustomEventVideoPlayerState createState() => _CustomEventVideoPlayerState();
}

class _CustomEventVideoPlayerState extends State<CustomEventVideoPlayer> {
  late ChewieController _chewieController;
  late VideoPlayerController _videoPlayerController;

  final EventService eventService = EventService();
  TelemetryRepository telemetryRepository = TelemetryRepository();
  late String identifier;
  double _currentProgressInSeconds = 0;
  double _currentProgressPercentage = 0;

  Timer? _timer;
  Timer? _updateProgressTimer;
  Timer? _updateProgressPostCertTimer;
  int _start = 0;
  late String pageIdentifier;
  late String telemetryType;
  late String pageUri;
  Orientation? screenOrientation;

  double _totalWatchedTime = 0; // Track total watched time
  double _previousProgressTime = 0;
  int _contentStatus = 0;

  @override
  void initState() {
    super.initState();

    List urlSegments = widget.url.split('/');
    if (urlSegments.last.contains('?')) {
      identifier = urlSegments.last.split('?')[0];
    } else {
      identifier = urlSegments.last;
    }
    if (_start == 0) {
      pageIdentifier = TelemetryPageIdentifier.youtubePlayerPageId;
      telemetryType = TelemetryType.player;
      pageUri =
          'viewer/video/${widget.identifier}?primaryCategory=Learning%20Resource&collectionId=${widget.identifier}&collectionType=Course&batchId=${widget.batchId}';

      _generateTelemetryData();
    }
    _contentStatus = widget.status ?? 0;

    // Initialize video player
    _videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(widget.url))
          ..initialize().then((_) {
            // setState(() {
            //   _isPlayerReady = true;
            // });
          });

    // Initialize Chewie player
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: false,
      looping: false,
      showControls: true,
      allowFullScreen: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: AppColors.darkBlue,
        handleColor: AppColors.darkBlue,
      ),
    );

    _previousProgressTime = (widget.currentWatchTime != null
        ? double.parse(widget.currentWatchTime.toString())
        : 0);
    _totalWatchedTime = (widget.currentWatchTime != null
        ? double.parse(widget.currentWatchTime.toString())
        : 0);
    _startTimer();
  }

  void _startTimer() {
    const oneSec = const Duration(seconds: 1);

    _timer = Timer.periodic(
      oneSec,
      (Timer timer) async {
        _start++;
        if (_videoPlayerController.value.isPlaying) {
          double currentTime =
              _videoPlayerController.value.position.inSeconds.toDouble();
          double playerDuration =
              _videoPlayerController.value.duration.inSeconds.toDouble();
          double duration = (widget.contentDuration != null)
              ? widget.contentDuration!
              : playerDuration;

          if (currentTime > _previousProgressTime) {
            _totalWatchedTime += 1;
          }

          // Update progress
          _currentProgressInSeconds = currentTime;
          _currentProgressPercentage =
              (_totalWatchedTime / (duration > 0 ? duration : 1) * 100)
                  .clamp(0, 100);

          _previousProgressTime = currentTime;

          if (_totalWatchedTime == widget.completionRequiredTimeInSec) {
            await _updateContentProgress();
          }
        }
      },
    );
  }

  void _generateTelemetryData() async {
    Map eventData1 = telemetryRepository.getStartTelemetryEvent(
        pageIdentifier: pageIdentifier,
        telemetryType: telemetryType,
        pageUri: pageUri,
        objectId: widget.identifier,
        objectType: widget.primaryCategory,
        env: widget.telemetryEnv,
        isPublic: false,
        l1: widget.identifier);
    await telemetryRepository.insertEvent(
        eventData: eventData1, isPublic: false);
  }

  @override
  void deactivate() {
    _videoPlayerController.pause();
    super.deactivate();
  }

  @override
  void dispose() async {
    super.dispose();
    try {
      if (_contentStatus < 2) {
        await _updateContentProgress();
      }
      _videoPlayerController.dispose();
      _chewieController.dispose();
      _timer?.cancel();
      _updateProgressTimer?.cancel();
      _updateProgressPostCertTimer?.cancel();
      Map eventData = telemetryRepository.getEndTelemetryEvent(
          pageIdentifier: pageIdentifier,
          duration: _start,
          telemetryType: telemetryType,
          pageUri: pageUri,
          rollup: {},
          objectId: widget.identifier,
          objectType: widget.primaryCategory,
          env: widget.telemetryEnv,
          isPublic: false,
          l1: widget.identifier);
      await telemetryRepository.insertEvent(
          eventData: eventData, isPublic: false);
    } catch (e) {
      print(e);
    }
  }

  Future<void> _updateContentProgress() async {
    List<double> current = [];
    var playerDuration =
        _videoPlayerController.value.duration.inSeconds.toDouble();
    double maxSize = (widget.contentDuration != null)
        ? widget.contentDuration!
        : playerDuration;
    double currentTime =
        _videoPlayerController.value.position.inSeconds.toDouble();
    if (widget.batchId != null) {
      _currentProgressPercentage >= 100
          ? current.add(maxSize)
          : current.add((_currentProgressInSeconds));
      int status = widget.status != 2
          ? _totalWatchedTime >= widget.completionRequiredTimeInSec
              ? 2
              : 1
          : 2;
      String contentType = EMimeTypes.mp4;

      double completionPercentage =
          (_totalWatchedTime >= widget.completionRequiredTimeInSec)
              ? 100
              : _currentProgressPercentage;
      double totalWatchedTime =
          (_totalWatchedTime >= widget.completionRequiredTimeInSec)
              ? maxSize
              : _totalWatchedTime;

      _contentStatus = status;

      Map data = {
        'status': status,
        'contentType': contentType,
        'current': current,
        'maxSize': maxSize,
        'completionPercentage': completionPercentage,
        'totalWatchedTime': totalWatchedTime,
        'currentTime': currentTime
      };
      widget.updateContentProgress(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        if (screenOrientation == Orientation.landscape) {
          // _controller.exitFullScreen();
        } else {
          Navigator.pop(context);
        }
      },
      canPop: false,
      child: OrientationBuilder(
          builder: (BuildContext context, Orientation orientation) {
        screenOrientation = orientation;
        return SafeArea(
          child: Scaffold(
              backgroundColor: AppColors.appBarBackground,
              appBar: orientation == Orientation.landscape
                  ? null
                  : AppBar(
                      title: SizedBox(
                        width: 0.55.sw,
                        child: Text(
                          widget.title ?? '',
                          style: GoogleFonts.lato(
                            fontSize: 16.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      elevation: 0,
                      backgroundColor: AppColors.appBarBackground,
                      automaticallyImplyLeading: false,
                      leading: InkWell(
                        onTap: () async {
                          if (orientation == Orientation.landscape) {
                            // _controller.exitFullScreen();
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16).r,
                          child: Icon(
                            Icons.arrow_back,
                            size: 24.sp,
                            color: AppColors.greys,
                          ),
                        ),
                      )),
              body: Container(
                child: Column(
                  mainAxisAlignment: (widget.contentChildWidget != null)
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
                  children: [
                    playerWidget(orientation: orientation),
                    if (orientation != Orientation.landscape) contentView()
                  ],
                ),
              )),
        );
      }),
    );
  }

  Widget playerWidget({required Orientation orientation}) {
    return Container(
      width: double.infinity.w,
      height: (orientation != Orientation.landscape) ? 260.w : 0.9.sh,
      child: Chewie(
        controller: _chewieController,
      ),
    );
  }

  Widget contentView() {
    return (widget.contentChildWidget != null)
        ? widget.contentChildWidget!
        : Container();
  }
}
