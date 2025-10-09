import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internet_file/internet_file.dart';
import 'package:karmayogi_mobile/ui/skeleton/pages/pdf_player_skeleton.dart';
import 'package:pdfx/pdfx.dart';
import '../../../../util/index.dart';
import '../../../pages/_pages/toc/model/navigation_model.dart';
import '../../../pages/_pages/toc/util/toc_helper.dart';
import '../../../pages/_pages/toc/view_model/toc_player_view_model.dart';
import './../../../../services/index.dart';
import './../../../../constants/index.dart';
import './../../../widgets/index.dart';

class CoursePdfPlayer extends StatefulWidget {
  final String identifier;
  final String? batchId;
  final bool isFeaturedCourse;
  final updateProgress;
  final String? primaryCategory;
  final String parentCourseId;
  final ValueChanged<bool>? playNextResource;
  final resourceNavigateItems;
  final int? startAt;
  final bool? isPreRequisite;final String language;

  CoursePdfPlayer(
      {required this.identifier,
      required this.parentCourseId,
      this.batchId,
      required this.isFeaturedCourse,
      this.updateProgress,
      this.primaryCategory,
      this.playNextResource,
      this.startAt,
      this.resourceNavigateItems,
      this.isPreRequisite = false,required this.language});

  @override
  _CoursePdfPlayerState createState() => _CoursePdfPlayerState();
}

class _CoursePdfPlayerState extends State<CoursePdfPlayer> {
  final LearnService learnService = LearnService();
  bool _isLoading = true;
  PdfController? _pdfController;
  int? _currentProgress;
  List<String> current = [];
  String? _identifier;
  ValueNotifier<int> _currentPage = ValueNotifier(1);
  int _totalPages = 0;
  NavigationModel? resourceInfo;

  int _start = 0;
  String? pageIdentifier;
  String? telemetryType;
  late String courseId;
  String? pageUri;
  ValueNotifier<bool> isCompleted = ValueNotifier(false);
  bool _fullScreen = false;

  @override
  void initState() {
    super.initState();
    fetchData();
    _identifier = widget.identifier;
    courseId = TocPlayerViewModel()
        .getEnrolledCourseId(context, widget.parentCourseId);
    _triggerTelemetryData();
  }

  @override
  void didUpdateWidget(CoursePdfPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.identifier != widget.identifier) {
      _triggerEndTelemetryData(_identifier ?? "");
      _start = 0;
      _identifier = widget.identifier;
      _triggerTelemetryData();
      setState(() => _isLoading = true);
      loadDocument();
      courseId = TocPlayerViewModel()
          .getEnrolledCourseId(context, widget.parentCourseId);
    }
  }

  _triggerTelemetryData() {
    if (_start == 0) {
      pageIdentifier = TelemetryPageIdentifier.pdfPlayerPageId;
      telemetryType = TelemetryType.player;
      var batchId = widget.batchId ?? '';
      pageUri =
          'viewer/pdf/${widget.identifier}?primaryCategory=Learning%20Resource&collectionId=${widget.parentCourseId}&collectionType=Course&batchId=$batchId';
      _generateTelemetryData();
      _startTimer();
    }
  }

  void _startTimer() {
    const Duration(seconds: 1);
    new Timer.periodic(
      const Duration(seconds: 1),
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
        objectType: widget.primaryCategory,
        env: TelemetryEnv.learn,
        isPublic: widget.isFeaturedCourse,
        l1: widget.parentCourseId);
    await telemetryRepository.insertEvent(
        eventData: eventData1, isPublic: widget.isFeaturedCourse);

    Map eventData2 = telemetryRepository.getImpressionTelemetryEvent(
        pageIdentifier: pageIdentifier ?? "",
        telemetryType: telemetryType ?? "",
        pageUri: pageUri ?? "",
        objectId: widget.identifier,
        objectType: widget.primaryCategory,
        env: TelemetryEnv.learn,
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
        objectType: widget.primaryCategory,
        isPublic: widget.isFeaturedCourse);
    await telemetryRepository.insertEvent(
        eventData: eventData, isPublic: widget.isFeaturedCourse);
  }

  Future<void> loadDocument() async {
    try {
      String resUri = resourceInfo?.artifactUrl ?? '';
      if (resUri == '') return;
      if (resUri.contains('http://')) {
        resUri = Helper.upgradeToHttps(resUri, replaceFirst: true);
      }
      if (resUri.contains('https://storage.googleapis.com/igotprod')) {
        resUri = Helper.upgradeGoogleAPI(resUri);
      }

      var pdfData = await InternetFile.get(resUri);
      final Future<PdfDocument> document = PdfDocument.openData(pdfData);
      _pdfController = PdfController(
          document: document,
          initialPage: widget.startAt ?? await getInitialPage(document));
    } catch (e) {
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateContentProgress(
    int currentPage,
    int totalPages,
  ) async {
    if (!widget.isFeaturedCourse &&
        (int.parse(resourceInfo!.currentProgress.toString()) < currentPage ||
            currentPage == 0) &&
        resourceInfo!.status != 2 &&
        widget.batchId != null) {
      if (currentPage == 0) {
        currentPage = 1;
      }
      currentPage = currentPage <= totalPages ? currentPage : totalPages;
      current.add((currentPage).toString());
      int status = resourceInfo!.status != 2
          ? currentPage == totalPages
              ? 2
              : 1
          : 2;
      int maxSize = totalPages;
      double completionPercentage = currentPage / totalPages * 100;
      await learnService.updateContentProgress(
        courseId,
        widget.batchId!,
        widget.identifier,
        status,
        EMimeTypes.pdf,
        current,
        maxSize,
        completionPercentage,
        isPreRequisite: widget.isPreRequisite, language: widget.language
      );

      widget.updateProgress({
        'identifier': widget.identifier,
        'mimeType': EMimeTypes.pdf,
        'current': (currentPage).toString(),
        'completionPercentage': completionPercentage / 100
      });
    }
  }

  _triggerEndTelemetryData(String identifier) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getEndTelemetryEvent(
        pageIdentifier: pageIdentifier ?? "",
        duration: _start,
        telemetryType: telemetryType ?? "",
        pageUri: pageUri ?? "",
        rollup: {},
        objectId: identifier,
        objectType: widget.primaryCategory,
        env: TelemetryEnv.learn,
        isPublic: widget.isFeaturedCourse,
        l1: widget.parentCourseId);
    await telemetryRepository.insertEvent(
        eventData: eventData, isPublic: widget.isFeaturedCourse);
  }

  @override
  void dispose() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      if (_currentPage.value >= 0) {
        if (!widget.isFeaturedCourse) {
          await _updateContentProgress(_currentPage.value, _totalPages);
        }
      }
      // _document?.close();
      _pdfController?.dispose();
    });
    _triggerEndTelemetryData(widget.identifier);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _isLoading
          ? PdfPlayerSkeletonPage()
          : _pdfController != null
              ? Stack(
                  alignment: Alignment.topCenter,
                  fit: StackFit.passthrough,
                  children: [
                    PdfView(
                      controller: _pdfController!,
                      scrollDirection: Axis.vertical,
                      onDocumentError: (error) => ErrorPage(),
                      onDocumentLoaded: (document) {
                        setState(() => _isLoading = true);
                        _currentPage.value = _pdfController!.initialPage;
                        isCompleted.value = (_currentProgress == _totalPages) ||
                            resourceInfo!.status == 2;
                        setState(() => _isLoading = false);
                      },
                      builders: const PdfViewBuilders<DefaultBuilderOptions>(
                          options: DefaultBuilderOptions(
                              loaderSwitchDuration:
                                  const Duration(milliseconds: 500))),
                      onPageChanged: (value) async {
                        _currentPage.value = value;
                        if (_currentPage.value == _totalPages) {
                          isCompleted.value = true;
                          await _updateContentProgress(
                              _currentPage.value, _totalPages);
                        }
                      },
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        color: AppColors.appBarBackground,
                        height: _fullScreen ? 25.w : 60.w,
                        padding: EdgeInsets.only(left: 16, right: 16).w,
                        child: Flex(
                          direction: Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            ValueListenableBuilder(
                                valueListenable: _currentPage,
                                builder: (BuildContext context, int currentPage,
                                    Widget? child) {
                                  return Expanded(
                                      flex: 1,
                                      child: _currentPage.value != 1
                                          ? InkWell(
                                              onTap: () {
                                                // jumpToPage(page: page - 2);
                                                _pdfController!.jumpToPage(
                                                    _currentPage.value - 1);
                                                _generateInteractTelemetryData(
                                                    widget.identifier,
                                                    subType: TelemetrySubType
                                                        .previousPageButton);
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4)
                                                    .w,
                                                child: Text(
                                                  AppLocalizations.of(context)!
                                                      .mPdfPlayerPrevious,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall!
                                                      .copyWith(
                                                        letterSpacing: 0.25.r,
                                                      ),
                                                ),
                                              ))
                                          : SizedBox());
                                }),
                            Expanded(
                              flex: 2,
                              child: ValueListenableBuilder<bool>(
                                  valueListenable: isCompleted,
                                  builder: (context, completionValue, child) {
                                    return completionValue
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.done,
                                                size: 24.sp,
                                                color: AppColors.darkBlue,
                                              ),
                                              Text(
                                                AppLocalizations.of(context)!
                                                    .mCommoncompleted,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall!
                                                    .copyWith(
                                                      letterSpacing: 0.25.w,
                                                    ),
                                              ),
                                            ],
                                          )
                                        : Center(
                                            child: InkWell(
                                                onTap: () async {
                                                  _generateInteractTelemetryData(
                                                      widget.identifier,
                                                      subType: TelemetrySubType
                                                          .markAsCompletePageButton);
                                                  if (!widget
                                                      .isFeaturedCourse) {
                                                    await _updateContentProgress(
                                                        _totalPages,
                                                        _totalPages);
                                                    widget.playNextResource!(
                                                        true);
                                                    Navigator.of(context).pop();
                                                  }
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 4)
                                                      .w,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                                  63)
                                                              .w,
                                                      border: Border.all(
                                                          color: AppColors
                                                              .darkBlue)),
                                                  child: Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .mPdfPlayerMarkAsComplete,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleSmall!
                                                        .copyWith(
                                                          letterSpacing: 0.25.w,
                                                        ),
                                                  ),
                                                )),
                                          );
                                  }),
                            ),
                            ValueListenableBuilder(
                                valueListenable: _currentPage,
                                builder: (BuildContext context, int currentPage,
                                    Widget? child) {
                                  return Expanded(
                                      flex: 1,
                                      child: _currentPage.value != _totalPages
                                          ? Align(
                                              alignment: Alignment.centerRight,
                                              child: InkWell(
                                                  onTap: () async {
                                                    _pdfController!.jumpToPage(
                                                        _currentPage.value + 1);
                                                    _generateInteractTelemetryData(
                                                        widget.identifier,
                                                        subType: TelemetrySubType
                                                            .nextPageButton);
                                                    if (!widget
                                                        .isFeaturedCourse) {
                                                      await _updateContentProgress(
                                                          _currentPage.value,
                                                          _totalPages);
                                                    }
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                                horizontal: 8,
                                                                vertical: 4)
                                                            .w,
                                                    child: Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .mPdfPlayerNext,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleSmall!
                                                          .copyWith(
                                                            letterSpacing:
                                                                0.25.r,
                                                          ),
                                                    ),
                                                  )),
                                            )
                                          : Center());
                                }),
                          ],
                        ),
                      ),
                    ),
                    ValueListenableBuilder(
                        valueListenable: _currentPage,
                        builder: (context, value, child) {
                          return Visibility(
                            visible: _totalPages != 0,
                            child: Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                margin: EdgeInsets.all(16).r,
                                padding: EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 4)
                                    .r,
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4)).r,
                                    color: AppColors.greys60),
                                child: Text(
                                  '${_currentPage.value} of $_totalPages',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall!
                                      .copyWith(
                                        letterSpacing: 0.25.r,
                                        fontSize: 12.sp,
                                      ),
                                ),
                              ),
                            ),
                          );
                        }),
                    Positioned(
                        bottom: _fullScreen ? 100.r : 60.r,
                        right: 16.r,
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
              : PdfPlayerSkeletonPage(),
    );
  }

  Future<void> fetchData() async {
    resourceInfo = await TocHelper.getResourceInfo(
        context: context,
        resourceId: widget.identifier,
        isFeatured: widget.isFeaturedCourse,
        resourceNavigateItems: widget.resourceNavigateItems);
    if (resourceInfo != null) {
      await loadDocument();
    }
  }

  Future<int> getInitialPage(Future<PdfDocument> document) async {
    PdfDocument doc = await document;
    _totalPages = doc.pagesCount;
    _currentProgress = int.parse(resourceInfo!.currentProgress.toString());
    return (_currentProgress == 0 ||
            (_currentProgress == _totalPages) ||
            resourceInfo!.status == 2)
        ? 1
        : _currentProgress!;
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
  }
}
