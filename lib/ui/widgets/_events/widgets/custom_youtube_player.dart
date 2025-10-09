import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/services/_services/events_service.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../../../constants/_constants/color_constants.dart';
import '../../../pages/_pages/toc/util/toc_constants.dart';

class CustomYoutubePlayer extends StatefulWidget {
  final String? batchId;
  final String url;
  final currentProgress;
  final currentWatchTime;
  final double? progressPercentage;
  final double? contentDuration;
  final int? status;
  final bool? isLive;
  final bool isFeatured;
  final int completionRequiredPercentage;
  final double completionRequiredTimeInSec;
  final Widget? contentChildWidget;
  final ValueChanged<Map> updateContentProgress;
  final Future<void> Function({bool isFromDisposeFunction})? setAllOrientation;
  final Future<void> Function()? setLandscape;
  final VoidCallback? onNavigateBack;
  final String? title;
  final Color? appbar;
  final Color? leadingIconColor;

  CustomYoutubePlayer(
      {this.batchId,
      required this.url,
      this.currentProgress,
      this.currentWatchTime,
      this.progressPercentage,
      this.contentDuration,
      this.status,
      this.isLive = false,
      this.isFeatured = false,
      this.completionRequiredPercentage = ContentCompletionPercentage.youtube,
      this.completionRequiredTimeInSec = 180,
      this.contentChildWidget,
      required this.updateContentProgress,
      this.setAllOrientation,
      this.setLandscape,
      this.onNavigateBack,
      this.title,
      this.leadingIconColor,
      this.appbar});

  @override
  _CustomYoutubePlayerState createState() => _CustomYoutubePlayerState();
}

class _CustomYoutubePlayerState extends State<CustomYoutubePlayer> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;
  bool _hasSought = false;

  final EventService eventService = EventService();
  late String identifier;
  double _currentProgressInSeconds = 0;
  double _currentProgressPercentage = 0;

  Timer? _timer;
  Timer? _updateProgressTimer;
  Timer? _updateProgressPostCertTimer;

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

    _contentStatus = widget.status ?? 0;

    _controller = YoutubePlayerController(
      initialVideoId: ((YoutubePlayer.convertUrlToId(widget.url) ?? '') != '')
          ? (YoutubePlayer.convertUrlToId(widget.url) ?? '')
          : identifier,
      flags: YoutubePlayerFlags(
        mute: false,
        autoPlay: false,
        disableDragSeek: false,
        loop: false,
        isLive: widget.isLive ?? false,
        forceHD: false,
        enableCaption: true,
      ),
    )..addListener(listener);

    _previousProgressTime = (widget.currentWatchTime != null
        ? double.parse(widget.currentWatchTime.toString())
        : 0);
    _totalWatchedTime = (widget.currentWatchTime != null
        ? double.parse(widget.currentWatchTime.toString())
        : 0);
    _startTimer();
  }

  void listener() async {
    try {
      double playerDuration =
          _controller.value.metaData.duration.inSeconds.toDouble();
      double duration = (widget.contentDuration != null)
          ? widget.contentDuration!
          : double.parse(playerDuration.toString());
      int targetPosition = (widget.currentProgress != null)
          ? double.parse(widget.currentProgress.toString()).toInt()
          : 0;
      if (duration.toInt() > targetPosition && targetPosition != 0) {
        if (_controller.value.isReady && !_hasSought) {
          if (_controller.value.position.inSeconds != targetPosition) {
            _controller.seekTo(Duration(seconds: targetPosition));
          }
          _hasSought = true;
        }
      }
    } catch (_) {
      print(_);
    }
    if (_isPlayerReady && mounted && _controller.value.isFullScreen) {
      if (widget.setLandscape != null) {
        await widget.setLandscape!();
      } else {
        if (!_controller.value.isFullScreen) {
          await _setLandscape();
        }
      }
    }
  }

  _setLandscape() async {
    await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    setState(() {});
  }

  _setAllOrientation({bool isFromDisposeFunction = false}) async {
    await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    if (!isFromDisposeFunction) {
      setState(() {});
    }
  }

  void _startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) async {
        PlayerState playerState = await _controller.value.playerState;
        if (playerState == PlayerState.playing) {
          double currentTime = _controller.value.position.inSeconds.toDouble();
          double playerDuration =
              _controller.value.metaData.duration.inSeconds.toDouble();
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

          if (((_currentProgressPercentage >=
                      widget.completionRequiredPercentage) ||
                  currentTime >= duration) &&
              _contentStatus != 2) {
            await _updateContentProgress();
          }

          if (widget.completionRequiredTimeInSec != 0 &&
              _totalWatchedTime == widget.completionRequiredTimeInSec) {
            await _updateContentProgress();
          }
        }
      },
    );
    // _updateProgressTimer = Timer.periodic(oneMin, (Timer timer) async {
    //   if (_contentStatus < 2)
    //     await _updateContentProgress();
    // });
    //
    // _updateProgressPostCertTimer = Timer.periodic(fiveMin, (Timer timer) async {
    //   if (_contentStatus == 2)
    //     await _updateContentProgress();
    // });
  }

  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();

    _controller.dispose();
    _timer?.cancel();
    _updateProgressTimer?.cancel();
    _updateProgressPostCertTimer?.cancel();
  }

  Future<void> _updateContentProgress() async {
    if (!widget.isFeatured) {
      List<double> current = [];
      var playerDuration =
          _controller.value.metaData.duration.inSeconds.toDouble();
      ;
      double maxSize = (widget.contentDuration != null)
          ? widget.contentDuration!
          : playerDuration;
      double currentTime = _controller.value.position.inSeconds.toDouble();
      ;
      if (widget.batchId != null) {
        if (widget.contentDuration == null &&
            widget.completionRequiredTimeInSec == 0) {
          _currentProgressPercentage =
              (_currentProgressInSeconds / playerDuration) * 100;
        }
        _currentProgressPercentage >= 100
            ? current.add(maxSize)
            : current.add((_currentProgressInSeconds));
        String contentType = EMimeTypes.youtube;

        double completionPercentage =
            (widget.completionRequiredTimeInSec != 0 &&
                    _totalWatchedTime >= widget.completionRequiredTimeInSec)
                ? 100.0
                : _currentProgressPercentage;

        int status = widget.status != 2
            ? widget.completionRequiredTimeInSec != 0 &&
                    _totalWatchedTime >= widget.completionRequiredTimeInSec
                ? 2
                : completionPercentage >= ContentCompletionPercentage.youtube
                    ? 2
                    : 1
            : 2;
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
          'completionPercentage':
              completionPercentage >= ContentCompletionPercentage.youtube
                  ? 100.0
                  : completionPercentage,
          'totalWatchedTime': totalWatchedTime,
          'currentTime': currentTime
        };
        widget.updateContentProgress(data);
      }
    }
  }

  void doPop(BuildContext context) {
    if (widget.onNavigateBack != null) {
      widget.onNavigateBack!();
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
      return Scaffold(
        backgroundColor: AppColors.greys,
        appBar: orientation != Orientation.landscape
            ? _buildAppBar(orientation)
            : null,
        body: Column(
          mainAxisAlignment: widget.contentChildWidget != null
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          children: [
            playerWidget(orientation: orientation),
            if (orientation != Orientation.landscape)
              widget.contentChildWidget ?? const SizedBox.shrink(),
          ],
        ),
      );
    });
  }

  PreferredSizeWidget _buildAppBar(Orientation orientation) {
    return AppBar(
        backgroundColor: widget.appbar ?? Colors.transparent,
        automaticallyImplyLeading: false,
        title: widget.title != null
            ? SizedBox(
                width: 0.6.sw,
                child: Text(
                  widget.title ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.lato(
                      fontWeight: FontWeight.w700,
                      color: AppColors.greys,
                      fontSize: 16.sp),
                ),
              )
            : null,
        leading: InkWell(
          onTap: () async {
            if (orientation == Orientation.landscape) {
              // _controller.exitFullScreen();
            } else {
              await _setAllOrientation(isFromDisposeFunction: true);
              try {
                if (_contentStatus < 2) {
                  await _updateContentProgress().then((_) {
                    doPop(context);
                  });
                } else {
                  doPop(context);
                }
              } catch (e) {
                doPop(context);
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16).r,
            child: Icon(
              Icons.arrow_back,
              size: 24.sp,
              color: widget.leadingIconColor ?? AppColors.white70,
            ),
          ),
        ));
  }

  Widget playerWidget({required Orientation orientation}) {
    return Container(
      width: double.infinity.w,
      height: (orientation != Orientation.landscape) ? 260.w : 0.9.sw,
      child: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.blueAccent,
        topActions: <Widget>[
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              _controller.metadata.title,
              style: const TextStyle(
                color: AppColors.appBarBackground,
                fontSize: 18.0,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
        onReady: () {
          _isPlayerReady = true;
        },
      ),
    );
  }

  Widget contentView() {
    return (widget.contentChildWidget != null)
        ? widget.contentChildWidget!
        : Container();
  }
}
