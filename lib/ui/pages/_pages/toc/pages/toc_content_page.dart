import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import '../../../../../constants/index.dart';
import '../../../../../models/index.dart';
import '../../../../../util/telemetry_repository.dart';
import '../../../../widgets/index.dart';
import '../../../index.dart';
import '../util/toc_helper.dart';

class TocContentPage extends StatefulWidget {
  const TocContentPage(
      {Key? key,
      required this.courseId,
      required this.course,
      this.enrolledCourse,
      required this.courseHierarchy,
      required this.navigationItems,
      this.lastAccessContentId,
      this.isFeatured = false,
      this.isProgram = false,
      this.isPlayer = false,
      this.startNewResourse,
      this.readCourseProgress,
      required this.enrollmentList})
      : super(key: key);

  final Course course;
  final List navigationItems;
  final Course? enrolledCourse;
  final String courseId;
  final bool isFeatured;
  final bool isProgram, isPlayer;
  final CourseHierarchyModel courseHierarchy;
  final String? lastAccessContentId;
  final ValueChanged<String>? startNewResourse;
  final VoidCallback? readCourseProgress;
  final List<Course> enrollmentList;

  @override
  State<TocContentPage> createState() => _TocContentPageState();
}

class _TocContentPageState extends State<TocContentPage> {
  double progress = 0.0;
  int totalCourseProgress = 0;
  var contentProgress = Map();
  late CourseHierarchyModel? courseHierarchyInfo;
  String? batchId;
  bool isCuratedProgram = false,
      showCertificateIcon = false,
      isContentsAdded = false,
      showProgress = false,
      allowAccess = false;
  List? navigationItems;

  @override
  void initState() {
    super.initState();
    fetchData();

    checkAccess();
    _generateTelemetryData();
  }

  void fetchData() {
    courseHierarchyInfo = widget.courseHierarchy;
    navigationItems = List.from(widget.navigationItems);
    isCuratedProgram = courseHierarchyInfo!.cumulativeTracking;

    getProgressInfo();
    if (widget.isPlayer || widget.enrolledCourse != null) {
      showProgress = true;
    }
  }

  void checkAccess() {
    if (widget.enrolledCourse != null) {
      batchId = widget.enrolledCourse!.batchId;
      DateTime now = DateTime.now();
      DateTime? endDate = widget.enrolledCourse!.batch!.endDate.isNotEmpty
          ? DateTime.parse(widget.enrolledCourse!.batch!.endDate)
          : null;
      if (widget.course.courseCategory == EnglishLang.program ||
          (endDate != null &&
              (DateTime(endDate.year, endDate.month, endDate.day)
                      .isAtSameMomentAs(
                          DateTime(now.year, now.month, now.day)) ||
                  DateTime(endDate.year, endDate.month, endDate.day)
                      .isAfter(DateTime(now.year, now.month, now.day))))) {
        allowAccess = TocHelper().checkInviteOnlyProgramIsActive(
            widget.course, widget.enrolledCourse!);
      } else {
        allowAccess = true;
      }
    }
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(TocContentPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.courseHierarchy.identifier !=
        widget.courseHierarchy.identifier) {
      fetchData();
    }
    navigationItems = List.from(widget.navigationItems);
  }

  void getProgressInfo() {
    if (widget.enrolledCourse != null) {
      if (isCuratedProgram) {
        showCertificateIcon = true;
      }
      showProgress = true;
      totalCourseProgress = widget.enrolledCourse!.completionPercentage ?? 0;
    }
  }

  void _generateTelemetryData() async {
    var telemetryRepository = TelemetryRepository();
    String pageUri = (!widget.isFeatured
            ? TelemetryPageIdentifier.courseDetailsPageUri
            : TelemetryPageIdentifier.publicCourseDetailsPageUri)
        .replaceAll(':do_ID', widget.course.id);
    if (batchId != null) {
      pageUri = pageUri + "?batchId=$batchId";
    }
    Map eventData = telemetryRepository.getImpressionTelemetryEvent(
        pageIdentifier: (!widget.isFeatured
            ? TelemetryPageIdentifier.courseDetailsPageId
            : TelemetryPageIdentifier.publicCourseDetailsPageId),
        telemetryType:
            !widget.isFeatured ? TelemetryType.public : TelemetryType.page,
        pageUri: pageUri,
        env: TelemetryEnv.learn,
        objectId: widget.course.id,
        objectType: widget.course.courseCategory,
        isPublic: widget.isFeatured);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  @override
  Widget build(BuildContext context) {
    if (courseHierarchyInfo != null) {
      if (courseHierarchyInfo.runtimeType == String) {
        return NoDataWidget(message: 'No course');
      } else {
        if (!isContentsAdded) {
          isContentsAdded = true;
        }
        return navigationItems != null && navigationItems!.length != 0
            ? Container(
                height: 1.sh,
                width: 1.sw,
                color: AppColors.scaffoldBackground,
                child: SingleChildScrollView(
                    child: Container(
                        padding: EdgeInsets.only(bottom: 120).r,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (int i = 0; i < navigationItems!.length; i++)
                              if (navigationItems![i] is! List ||
                                  navigationItems![i].length > 0) ...[
                                if (navigationItems![i] is! List ||
                                    navigationItems![i][0] == null)
                                  TocContentObjectWidget(
                                      content: navigationItems![i],
                                      course: widget.course,
                                      showProgress: showProgress,
                                      lastAccessContentId:
                                          widget.lastAccessContentId,
                                      startNewResourse: widget.startNewResourse,
                                      isPlayer: widget.isPlayer,
                                      enrolledCourse: widget.enrolledCourse,
                                      navigationItems: widget.navigationItems,
                                      courseId: widget.courseId,
                                      batchId: batchId,
                                      isCuratedProgram: isCuratedProgram,
                                      readCourseProgress: () =>
                                          widget.readCourseProgress!(),
                                      allowAccess: allowAccess,
                                      isFeatured: widget.isFeatured,
                                      enrollmentList: widget.enrollmentList,
                                      parentCompatibility:
                                          widget.course.compatibilityLevel,
                                      contextLockingType:
                                          widget.course.contextLockingType,
                                      isMandatory:
                                          navigationItems![i].isMandatory)
                                //Added below condition to handle course item
                                else if (hasModuleInChildren(
                                    navigationItems![i])) ...[
                                  CourseLevelModuleItem(
                                      index: i,
                                      content: navigationItems,
                                      isCuratedProgram: isCuratedProgram,
                                      course: widget.course,
                                      courseHierarchyInfo: courseHierarchyInfo!,
                                      batchId: batchId,
                                      showCertificateIcon: showCertificateIcon,
                                      showCertificate: [],
                                      showProgress: showProgress,
                                      lastAccessContentId:
                                          widget.lastAccessContentId,
                                      startNewResourse: widget.startNewResourse,
                                      isPlayer: widget.isPlayer,
                                      enrolledCourse: widget.enrolledCourse,
                                      readCourseProgress: () =>
                                          widget.readCourseProgress!(),
                                      allowAccess: allowAccess,
                                      isFeatured: widget.isFeatured,
                                      enrollmentList: widget.enrollmentList)
                                ] else
                                  Container(
                                    padding: EdgeInsets.only(top: 16).r,
                                    child: Column(
                                      children: [
                                        navigationItems![i].length > 0
                                            ? ModuleItem(
                                                course: widget.course,
                                                moduleIndex: i,
                                                moduleName: navigationItems![i][0].moduleName != null
                                                    ? navigationItems![i][0]
                                                        .moduleName
                                                    : navigationItems![i][0]
                                                        .courseName,
                                                glanceListItems:
                                                    navigationItems![i],
                                                navigation: navigationItems,
                                                batchId: batchId,
                                                isCourse: navigationItems![i][0].moduleName != null
                                                    ? false
                                                    : true,
                                                isFeatured: widget.isFeatured,
                                                duration: navigationItems![i][0]
                                                            .moduleDuration !=
                                                        null
                                                    ? navigationItems![i][0]
                                                        .moduleDuration
                                                    : navigationItems![i][0]
                                                        .courseDuration,
                                                parentCourseId:
                                                    navigationItems![i][0]
                                                        .parentCourseId,
                                                showProgress: showProgress,
                                                courseHierarchyInfo:
                                                    courseHierarchyInfo!,
                                                lastAccessContentId:
                                                    widget.lastAccessContentId,
                                                startNewResourse: widget.startNewResourse,
                                                isPlayer: widget.isPlayer,
                                                navigationItems: navigationItems,
                                                enrolledCourse: widget.enrolledCourse,
                                                readCourseProgress: () => widget.readCourseProgress != null ? widget.readCourseProgress!() : null,
                                                allowAccess: allowAccess,
                                                enrollmentList: widget.enrollmentList,
                                                itemCount: navigationItems![i].length)
                                            : Center(),
                                      ],
                                    ),
                                  ),
                              ],
                            SizedBox(height: 100)
                          ],
                        ))),
              )
            : Center(
                child: Text(
                    AppLocalizations.of(context)!.mLearnNoContentForCourse,
                    style: Theme.of(context).textTheme.headlineSmall),
              );
      }
    } else {
      return Center();
    }
  }

  bool hasModuleInChildren(navigationItem) {
    for (var item in navigationItem) {
      if (item is List) {
        return true;
      }
    }
    return false;
  }
}
