import 'dart:async';
import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/models/_models/transcription_data_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/transcript/model/transcript_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/transcript/repository/transcript_repository.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/util/toc_helper.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/_contentPlayers/course_video_player_widget/custom_video_controller.dart';
import 'package:karmayogi_mobile/util/app_config.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../../../respositories/_respositories/settings_repository.dart';
import '../../../../util/index.dart';
import '../../../pages/_pages/toc/model/navigation_model.dart';
import '../../../pages/_pages/toc/util/toc_constants.dart';
import '../../../pages/_pages/toc/view_model/toc_player_view_model.dart';
import '../../../pages/index.dart';
import './../../../widgets/index.dart';
import './../../../../constants/index.dart';
import './../../../../services/index.dart';

class CourseVideoPlayer extends StatefulWidget {
  CourseVideoPlayer(
      {required this.identifier,
      this.fileUrl,
      this.batchId,
      this.parentAction,
      this.isPlatformWalkThrough = false,
      this.isFeatured = false,
      required this.parentCourseId,
      this.playNextResource,
      this.resourceNavigateItems,
      this.startAt,
      this.isPlayer = false,
      this.isPreRequisite = false,
      required this.language});

  final String? batchId;
  final String? fileUrl;
  final String identifier;
  final bool isFeatured;
  final bool isPlatformWalkThrough;
  final ValueChanged<Map>? parentAction;
  final String parentCourseId;
  final ValueChanged<bool>? playNextResource;
  final NavigationModel? resourceNavigateItems;
  final bool isPlayer;
  final int? startAt;
  final bool? isPreRequisite;
  final String language;

  @override
  _CourseVideoPlayerState createState() => _CourseVideoPlayerState();
}

class _CourseVideoPlayerState extends State<CourseVideoPlayer>
    with AutomaticKeepAliveClientMixin {
  final LearnService learnService = LearnService();
  String? pageIdentifier;
  String? pageUri;
  bool showLoader = true;
  bool showVideo = false, replayVideo = false, allowFullscreenFlag = true;
  String? telemetryType;
  String? batchId;
  late String courseId;

  ChewieController? _chewieController;

  int? _currentProgress;
  late String _identifier;
  ValueNotifier<bool> _playerStatus = ValueNotifier(false);
  int? _progressStatus;
  int _start = 0;
  late Timer _timer;
  VideoPlayerController? _videoPlayerController1;
  ValueNotifier<bool> isVideoCompleted = ValueNotifier(false);
  ValueNotifier<bool> showResume = ValueNotifier(false);
  NavigationModel? resourceInfo;
  late Future<List<SubtitleUrl>> subtitlesUrlFuture;
  ValueNotifier<List<Subtitle>> subtitles = ValueNotifier([]);

  SubtitleUrl? selectedSubtitle;
  bool isTablet = false;
  TranscriptRepository transcriptRepository = TranscriptRepository();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _videoPlayerController1!.dispose();
    if (_progressStatus != null) {
      _videoUpdateContentProgress(_identifier, _progressStatus!,
          language: widget.language);
    }
    if (_chewieController != null) {
      _chewieController!.pause();
      _chewieController!.dispose();
    }
    _triggerEndTelemetryData(widget.identifier);

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    setUpSubtitles();
    isTablet =
        Provider.of<SettingsRepository>(context, listen: false).itsTablet;

    courseId = TocPlayerViewModel()
        .getEnrolledCourseId(context, widget.parentCourseId);
    batchId = widget.batchId;
    fetchData();
  }

  void setUpSubtitles() async {
    if (AppConfiguration.iGOTAiConfig.transcription) {
      subtitlesUrlFuture = getSubtitles();

      await getVttCaptions();
    } else {
      subtitlesUrlFuture = Future.value([]);
      subtitles.value = [];
      selectedSubtitle = null;
    }
  }

  @override
  void didUpdateWidget(CourseVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.identifier != widget.identifier || widget.startAt != null) {
      updatePlayer(oldWidget);
    }
  }

  SubtitleUrl getDefaultSubtitle(List<SubtitleUrl> subtitles) {
    try {
      return subtitles.firstWhere(
        (subtitle) => subtitle.language.toLowerCase().contains('english'),
      );
    } catch (_) {
      try {
        return subtitles.firstWhere(
          (subtitle) => subtitle.language.toLowerCase().contains('hindi'),
        );
      } catch (_) {
        return subtitles[0];
      }
    }
  }

  Future<List<SubtitleUrl>> getSubtitles() async {
    List<SubtitleUrl> subtitles = [];
    final transcriptionData =
        await TranscriptRepository.getSubtitleAndTranscriptionData(
            resourceId: widget.identifier);
    if (transcriptionData != null) {
      subtitles = transcriptionData.subtitleUrls;
    }
    return subtitles;
  }

  Future<List<VttCaption>> getVttCaptions() async {
    List<VttCaption> vttCaptions = [];
    List<SubtitleUrl> subtitlesUrl = await subtitlesUrlFuture;

    if (subtitlesUrl.isNotEmpty) {
      selectedSubtitle = getDefaultSubtitle(subtitlesUrl);

      vttCaptions =
          await transcriptRepository.fetchAndParseWebVtt(selectedSubtitle!.uri);
    }

    if (vttCaptions.isNotEmpty) {
      subtitles.value = vttCaptions.map((caption) {
        return Subtitle(
          index: caption.index,
          start: caption.start,
          end: caption.end,
          text: caption.text,
        );
      }).toList();
    }

    return vttCaptions;
  }

  Future<void> updateSubtitle(SubtitleUrl? subtitle) async {
    if (subtitle != null) {
      List<VttCaption> vttCaptions =
          await transcriptRepository.fetchAndParseWebVtt(subtitle.uri);
      if (vttCaptions.isNotEmpty) {
        subtitles.value = vttCaptions.map((caption) {
          return Subtitle(
            index: caption.index,
            start: caption.start,
            end: caption.end,
            text: caption.text,
          );
        }).toList();
      }
    } else {
      subtitles.value = [];
    }
    await initializeChewieController();
    setState(() {});
  }

  Future<void> initializeChewieController() async {
    List<SubtitleUrl> subtitleUrl = await subtitlesUrlFuture;

    _chewieController = ChewieController(
        overlay: Platform.isIOS
            ? Container(
                height: 250.sh,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.black.withValues(alpha: 0.2),
                      AppColors.greys.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              )
            : null,
        customControls: CustomVideoController(
          defaultSubtitle: selectedSubtitle,
          onSubtitleSelected: (subtitle) {
            selectedSubtitle = subtitle;
            updateSubtitle(selectedSubtitle);
          },
          subtitles: subtitleUrl,
        ),
        deviceOrientationsOnEnterFullScreen: widget.isPlatformWalkThrough
            ? ([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
            : null,
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown
        ],
        videoPlayerController: _videoPlayerController1!,
        autoPlay: widget.identifier == '' && !showVideo ? false : true,
        looping: false,
        showOptions: false,
        allowedScreenSleep: false,
        showSubtitles: true,
        subtitle: subtitles.value.isNotEmpty
            ? Subtitles(
                subtitles.value,
              )
            : null,
        subtitleBuilder: (context, subtitle) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5).r,
            color: Colors.black54,
            child: Text(
              subtitle,
              style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: _chewieController != null &&
                          _chewieController!.isFullScreen
                      ? 8.sp
                      : 12.sp),
              textAlign: TextAlign.center,
            ),
          );
        },
        allowFullScreen: allowFullscreenFlag);
  }

  Future<void> initializePlayer() async {
    replayVideo = false;
    if (widget.identifier != '' &&
        resourceInfo != null &&
        resourceInfo!.currentProgress.toString() != '0' &&
        resourceInfo!.status != 2) {
      _currentProgress =
          int.parse((resourceInfo!.currentProgress).split('.').first);
    } else {
      _currentProgress = 0;
    }

    _videoPlayerController1 = VideoPlayerController.networkUrl(getUri());
    await Future.wait([
      _videoPlayerController1!.initialize(),
    ]);
    await initializeChewieController();
    _videoPlayerController1!
        .seekTo(Duration(seconds: widget.startAt ?? _currentProgress ?? 0));
    setState(() {
      showLoader = false;
    });

    _videoPlayerController1!.addListener(() {
      final position = _videoPlayerController1!.value.position;
      try {
        transcriptRepository.updatePosition(position);
      } catch (e) {}

      if (position == _videoPlayerController1!.value.duration &&
          widget.identifier == '' &&
          !showVideo) {
        setState(() {
          showVideo = true;
        });
      } else if (position == _videoPlayerController1!.value.duration) {
        if (_progressStatus != null) {
          _videoUpdateContentProgress(_identifier, _progressStatus!,
              language: widget.language);
        }
        if (_chewieController!.isFullScreen) {
          _chewieController!.exitFullScreen();
        }

        if (!_playerStatus.value && !replayVideo) {
          isVideoCompleted.value = true;
          setState(() async {
            allowFullscreenFlag = false;
            await initializeChewieController();
          });
        }
      } else {
        if (_playerStatus.value != _videoPlayerController1!.value.isPlaying) {
          replayVideo = false;
          if (_videoPlayerController1!.value.isPlaying) {
            _generateInteractTelemetryData(widget.identifier,
                subType: TelemetrySubType.playButton);
          } else {
            _generateInteractTelemetryData(widget.identifier,
                subType: TelemetrySubType.pauseButton);
          }
        }
        _playerStatus.value = _videoPlayerController1!.value.isPlaying;
      }
    });
  }

  Future<void> updatePlayer(CourseVideoPlayer oldWidget) async {
    if (_progressStatus != null) {
      await _videoUpdateContentProgress(oldWidget.identifier, _progressStatus!,
          language: oldWidget.language);
    }
    _triggerEndTelemetryData(_identifier);
    await getResourceInfo();
    _identifier = widget.identifier;
    _start = 0;
    _triggerTelemetryData();
    _progressStatus = resourceInfo != null ? resourceInfo!.status : null;
    showLoader = true;
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
    isVideoCompleted.value = false;
    showResume.value = false;
    allowFullscreenFlag = true;
    initializePlayer();
    courseId = TocPlayerViewModel()
        .getEnrolledCourseId(context, widget.parentCourseId);
    batchId = widget.batchId;
  }

  _triggerTelemetryData() {
    if ((_start == 0 && widget.batchId != null)) {
      pageIdentifier = TelemetryPageIdentifier.videoPlayerPageId;
      telemetryType = TelemetryType.player;
      String assetFile = widget.isPlayer
          ? 'video'
          : widget.fileUrl!.contains(EMimeTypes.mp4)
              ? 'video'
              : 'audio';
      var batchId = widget.batchId;
      pageUri =
          'viewer/$assetFile/${widget.identifier}?primaryCategory=Learning%20Resource&collectionId=${widget.parentCourseId}&collectionType=Course&batchId=$batchId';
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
        objectId: widget.identifier,
        objectType: resourceInfo != null ? resourceInfo!.primaryCategory : null,
        env: TelemetryEnv.learn,
        isPublic: widget.isFeatured,
        l1: widget.parentCourseId);
    await telemetryRepository.insertEvent(
        eventData: eventData1, isPublic: widget.isFeatured);

    Map eventData2 = telemetryRepository.getImpressionTelemetryEvent(
        pageIdentifier: pageIdentifier ?? "",
        telemetryType: telemetryType ?? "",
        pageUri: pageUri ?? "",
        objectId: widget.identifier,
        objectType: resourceInfo != null ? resourceInfo!.primaryCategory : null,
        env: TelemetryEnv.learn,
        isPublic: widget.isFeatured);
    await telemetryRepository.insertEvent(
        eventData: eventData2, isPublic: widget.isFeatured);
  }

  void _generateInteractTelemetryData(String contentId,
      {String subType = ''}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: pageIdentifier ?? "",
        contentId: contentId,
        subType: subType,
        objectType: resourceInfo != null ? resourceInfo!.primaryCategory : null,
        env: TelemetryEnv.learn,
        isPublic: widget.isFeatured);
    await telemetryRepository.insertEvent(
        eventData: eventData, isPublic: widget.isFeatured);
  }

  _triggerEndTelemetryData(String identifier) {
    if (widget.parentCourseId != '' && widget.batchId != null) {
      TocPlayerViewModel().endTelemetryEvent(
          identifier: identifier,
          pageIdentifier: pageIdentifier ?? '',
          duration: _start,
          telemetryType: telemetryType ?? '',
          pageUri: pageUri ?? '',
          rollup: {},
          objectType:
              resourceInfo != null ? resourceInfo!.primaryCategory : null,
          isPublic: widget.isFeatured,
          l1: widget.parentCourseId,
          env: TelemetryEnv.learn);

      _timer.cancel();
    }
  }

  Future<void> _videoUpdateContentProgress(
      String contentIdentifier, int progressStatus,
      {required String language}) async {
    if (!widget.isFeatured && resourceInfo!.status != 2) {
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
      duration = duration == 0 ? 1 : duration;
      current.add(currentPosition.toString());
      int status = progressStatus != 2
          ? currentPosition == duration
              ? 2
              : 1
          : 2;
      double completionPercentage = (currentPosition / duration) * 100;
      if (completionPercentage >= ContentCompletionPercentage.video) {
        completionPercentage = 100;
        status = 2;
      }
      Map data = {
        'identifier': contentIdentifier,
        'mimeType': EMimeTypes.mp4,
        'current': currentPosition.toString(),
        'completionPercentage': completionPercentage / 100
      };
      if (widget.parentAction != null &&
          (resourceInfo!.completionPercentage * 100) < completionPercentage) {
        widget.parentAction!(data);
      }
      if (batchId != null &&
          (resourceInfo!.completionPercentage * 100) < completionPercentage) {
        await TocPlayerViewModel().videoUpdateContentProgress(contentIdentifier,
            language: language,
            courseId: courseId,
            isPreRequisite: widget.isPreRequisite ?? false,
            currentPosition: currentPosition,
            maxSize: duration,
            status: status,
            completionPercentage: completionPercentage,
            batchId: batchId!,
            current: current);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return !showLoader
        ? Column(children: <Widget>[
            Expanded(
              child: Center(
                child: _chewieController != null
                    ? Stack(
                        children: [
                          Padding(
                            // Added padding to handle  video player full screen button visibility issue in ipad
                            padding: EdgeInsets.only(
                                    bottom: 16, top: isTablet ? 60 : 16)
                                .r,
                            child: Chewie(
                              controller: _chewieController!,
                            ),
                          ),
                          ValueListenableBuilder(
                              valueListenable: isVideoCompleted,
                              builder: (context, bool value, child) {
                                return value
                                    ? Container(
                                        width: 1.sw,
                                        height: 250.w,
                                        color: AppColors.greys
                                            .withValues(alpha: 0.8),
                                        child: Center(
                                          child: SizedBox(
                                            height: 1.sh,
                                            width: 1.sw,
                                            child: ValueListenableBuilder(
                                                valueListenable: showResume,
                                                builder:
                                                    (context, isResume, child) {
                                                  _chewieController!.pause();
                                                  return isResume
                                                      ? ReplayWidget(
                                                          onPressed: () {
                                                            replayVideo = true;
                                                            isVideoCompleted
                                                                .value = false;
                                                            showResume.value =
                                                                false;
                                                            resumePlayer();
                                                          },
                                                        )
                                                      : AutoplayNextResource(
                                                          clickedPlayNextResource:
                                                              () {
                                                            isVideoCompleted
                                                                .value = false;
                                                            showResume.value =
                                                                false;
                                                            widget.playNextResource!(
                                                                value);
                                                          },
                                                          cancelTimer: () {
                                                            showResume.value =
                                                                true;
                                                          },
                                                        );
                                                }),
                                          ),
                                        ),
                                      )
                                    : Center();
                              }),
                        ],
                      )
                    : PageLoader(),
              ),
            ),
          ])
        : PageLoader();
  }

  Future<void> resumePlayer() async {
    setState(() {
      allowFullscreenFlag = true;
    });
    await initializeChewieController();
    _videoPlayerController1!.seekTo(Duration.zero);
    _videoPlayerController1!.play();
    _chewieController!.play();
  }

  Future<void> fetchData() async {
    _identifier = widget.identifier;
    await getResourceInfo();
    _progressStatus =
        widget.isPlayer && resourceInfo != null ? resourceInfo!.status : null;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      initializePlayer();
    });

    _triggerTelemetryData();
  }

  Future<void> getResourceInfo() async {
    if (widget.isPlayer) {
      resourceInfo = await TocHelper.getResourceInfo(
          context: context,
          resourceId: widget.identifier,
          isFeatured: widget.isFeatured,
          resourceNavigateItems: widget.resourceNavigateItems!);
    }
  }

  Uri getUri() {
    if (widget.isPlayer) {
      String url = resourceInfo != null ? resourceInfo!.artifactUrl ?? '' : '';
      return Uri.parse(Helper.generateCdnUri(url));
    } else {
      return Uri.parse(widget.fileUrl ?? '');
    }
  }
}
