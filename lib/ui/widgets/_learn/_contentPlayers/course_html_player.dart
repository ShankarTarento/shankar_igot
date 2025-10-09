import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import '../../../../models/index.dart';
import '../../../../util/telemetry_repository.dart';
import '../../../pages/_pages/toc/model/navigation_model.dart';
import '../../../pages/_pages/toc/util/toc_constants.dart';
import '../../../pages/_pages/toc/util/toc_helper.dart';
import '../../../pages/_pages/toc/view_model/toc_player_view_model.dart';
import './../../../../constants/index.dart';
import './../../../../services/index.dart';

class CourseHtmlPlayer extends StatefulWidget {
  final CourseHierarchyModel course;
  final String identifier;
  final String? batchId;
  final ValueChanged<bool> parentAction1;
  final parentAction3;
  final bool isLearningResource;
  final bool isFeaturedCourse;
  final String parentCourseId;
  final NavigationModel resourceNavigateItems;
  final bool? isPreRequisite;final String language;

  CourseHtmlPlayer(
      this.course, this.identifier, this.batchId, this.parentAction1,
      {this.isLearningResource = false,
      this.parentAction3,
      this.isFeaturedCourse = false,
      required this.parentCourseId,
      required this.resourceNavigateItems,
      this.isPreRequisite = false,required this.language});

  _CourseHtmlPlayerState createState() => _CourseHtmlPlayerState();
}

class _CourseHtmlPlayerState extends State<CourseHtmlPlayer> {
  final LearnService learnService = LearnService();
  WebViewController? _controller;
  late int startTime;
  late String _identifier;

  late String userId;
  late String userSessionId;
  late String messageIdentifier;
  late String departmentId;
  late String courseId;
  late Timer _timer;
  int _start = 0;
  late String pageIdentifier;
  late String telemetryType;
  late String pageUri;
  List allEventsData = [];
  late String deviceIdentifier;
  var telemetryEventData;
  int spentTime = 0;
  bool _fullScreen = false;
  NavigationModel? resourceNavigateItem;

  void initState() {
    super.initState();
    _identifier = widget.identifier;
    courseId = TocPlayerViewModel()
        .getEnrolledCourseId(context, widget.parentCourseId);
    fetchData();
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
        pageIdentifier: pageIdentifier,
        telemetryType: telemetryType,
        pageUri: pageUri,
        objectId: widget.identifier,
        objectType: resourceNavigateItem!.primaryCategory,
        env: TelemetryEnv.learn,
        isPublic: widget.isFeaturedCourse,
        l1: widget.parentCourseId);
    await telemetryRepository.insertEvent(
        eventData: eventData1, isPublic: widget.isFeaturedCourse);

    Map eventData2 = telemetryRepository.getImpressionTelemetryEvent(
        pageIdentifier: pageIdentifier,
        telemetryType: telemetryType,
        pageUri: pageUri,
        env: TelemetryEnv.learn,
        objectId: widget.identifier,
        objectType: resourceNavigateItem!.primaryCategory,
        isPublic: widget.isFeaturedCourse);
    await telemetryRepository.insertEvent(
        eventData: eventData2, isPublic: widget.isFeaturedCourse);
  }

  void _triggerEndTelemetryEvent(
      {required String id,
      required String primaryCategory,
      required String parentCourseId,
      required bool isFeatured}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getEndTelemetryEvent(
        pageIdentifier: pageIdentifier,
        duration: _start,
        telemetryType: telemetryType,
        pageUri: pageUri,
        rollup: {},
        objectId: widget.identifier,
        objectType: primaryCategory,
        env: TelemetryEnv.learn,
        isPublic: widget.isFeaturedCourse,
        l1: widget.parentCourseId);
    await telemetryRepository.insertEvent(
        eventData: eventData, isPublic: widget.isFeaturedCourse);
  }

  @override
  void dispose() async {
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    if (!widget.isFeaturedCourse) {
      await _updateContentProgress();
    }
    if (resourceNavigateItem != null) {
      _triggerEndTelemetryEvent(
          id: widget.identifier,
          isFeatured: widget.isFeaturedCourse,
          parentCourseId: widget.parentCourseId,
          primaryCategory: resourceNavigateItem!.primaryCategory);
    }
    _timer.cancel();
  }

  double getCompletionPercentage(NavigationModel courseinfo) {
    String values = courseinfo.duration != null
        ? courseinfo.duration!.substring(
            courseinfo.duration!.indexOf('-') + 1, courseinfo.duration!.length)
        : '0';
    int hour = 0;
    int min = 0;
    double percentage;
    if (values.contains('h')) {
      hour = int.parse(values.substring(0, values.indexOf('h'))) * 60;
      values = values.substring(values.indexOf('h') + 1, values.length);
    }
    if (values.contains('m')) {
      min = int.parse(values.substring(0, values.indexOf('m')));
    }
    int courseDuration = RegExp(r'[hm]').hasMatch(values)
        ? (hour + min) * 60
        : int.parse(values);
    DateTime time = DateTime.fromMillisecondsSinceEpoch(startTime);
    var diff = (DateTime.fromMillisecondsSinceEpoch(
                DateTime.now().millisecondsSinceEpoch)
            .difference(time))
        .inSeconds;
    spentTime = courseinfo.spentTime + diff;
    percentage = (diff / courseDuration) * 100;
    double totalPercentage =
        double.parse(courseinfo.completionPercentage.toString()) * 100 +
            percentage;
    //mark scorm progress as completed if course completion is more then 40%
    if (totalPercentage >= 40) {
      return 100.0;
    }
    //mark scorm completion using current progress plus previous progress
    else if (totalPercentage < 40) {
      return totalPercentage;
    }

    return double.parse(courseinfo.completionPercentage.toString()) * 100;
  }

  Future<void> _updateContentProgress() async {
    List<String> current = [];
    if (widget.batchId != null) {
      current.add(10.toString());
      String batchId = widget.batchId!;
      String contentId = widget.identifier;
      String contentType = EMimeTypes.externalLink;
      int status = 0;
      var maxSize = widget.course.duration;
      double completionPercentage = 0;
      completionPercentage = getCompletionPercentage(resourceNavigateItem!);
      if (completionPercentage >= ContentCompletionPercentage.scorm) {
        status = 2;
      } else if (completionPercentage > 0) {
        status = 1;
      }
      await learnService.updateContentProgress(courseId, batchId, contentId,
          status, contentType, current, maxSize, completionPercentage,
          spentTime: spentTime, isPreRequisite: widget.isPreRequisite, language: widget.language);
      Map data = {
        'identifier': contentId,
        'mimeType': contentType,
        'current': completionPercentage,
        'completionPercentage': completionPercentage / 100
      };
      await widget.parentAction3(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.identifier != '' && _controller != null
        ? Stack(
            children: [
              SizedBox(
                  width: 0.99.sw,
                  height: 1.0.sh,
                  child: WebViewWidget(
                    controller: _controller!,
                  )),
              Positioned(
                  bottom: 5,
                  right: 5,
                  child: Container(
                      child: Row(
                    children: [
                      _fullScreen
                          ? IconButton(
                              icon: Icon(
                                Icons.fullscreen_exit,
                                size: 30,
                              ),
                              onPressed: () async {
                                _fullScreen = false;
                                await changeOrientation();
                              },
                            )
                          : IconButton(
                              icon: Icon(
                                Icons.fullscreen,
                                size: 30,
                              ),
                              onPressed: () async {
                                _fullScreen = true;
                                await changeOrientation();
                              },
                            ),
                    ],
                  )))
            ],
          )
        : Center();
  }

  Future<void> changeOrientation() async {
    if (_fullScreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
    widget.parentAction1(_fullScreen);
  }

  Future<void> fetchData() async {
    resourceNavigateItem = await TocHelper.getResourceInfo(
        context: context,
        resourceId: _identifier,
        isFeatured: widget.isFeaturedCourse,
        resourceNavigateItems: widget.resourceNavigateItems);
    if (resourceNavigateItem != null) {
      if (_start == 0) {
        pageIdentifier = TelemetryPageIdentifier.htmlPlayerPageId;
        telemetryType = TelemetryType.player;
        var batchId = widget.batchId ?? '';
        pageUri =
            'viewer/html/${widget.identifier}?primaryCategory=Learning%20Resource&collectionId=${widget.parentCourseId}&collectionType=Course&batchId=$batchId';
        _generateTelemetryData();
      }
      _startTimer();
      // #docregion platform_features
      late final PlatformWebViewControllerCreationParams params;
      if (WebViewPlatform.instance is WebKitWebViewPlatform) {
        params = WebKitWebViewControllerCreationParams(
          allowsInlineMediaPlayback: true,
          mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
        );
      } else {
        params = const PlatformWebViewControllerCreationParams();
      }

      final WebViewController controller =
          WebViewController.fromPlatformCreationParams(params);

      controller
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.transparent)
        ..setNavigationDelegate(NavigationDelegate(
            onNavigationRequest: (NavigationRequest request) {
          return NavigationDecision.navigate;
        }, onPageStarted: (String url) async {
          startTime = DateTime.now().millisecondsSinceEpoch;
        }, onPageFinished: (String url) async {
          // Inject JavaScript to make background transparent and ensure responsiveness
          await controller.runJavaScript('''
        document.body.style.backgroundColor = 'transparent'; 
        var meta = document.createElement('meta');
        meta.name = 'viewport';
        meta.content = 'width=device-width, initial-scale=1.0';
        document.getElementsByTagName('head')[0].appendChild(meta);
      ''');
        }))
        ..loadRequest(Uri.parse(
            '${ApiUrl.baseUrl}/viewer/mobile/html/${widget.identifier}?primaryCategory=Learning Resource&collectionId=${widget.parentCourseId}&collectionType=Course&batchId=${widget.batchId}&courseName=${widget.course.name}&embed=true${'&preview=true'}'));

      if (kIsWeb || !Platform.isMacOS) {
        controller.setBackgroundColor(AppColors.greys60);
      }

      setState(() {
        _controller = controller;
      });

      // #enddocregion platform_features
    }
  }
}
