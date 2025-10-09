import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/learn_compatibility_constants.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/glance_item_3.dart';
import 'package:karmayogi_mobile/util/telemetry_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../constants/_constants/app_constants.dart';
import '../../../constants/_constants/app_routes.dart';
import '../../../constants/_constants/color_constants.dart';
import '../../../constants/_constants/telemetry_constants.dart';
import '../../../models/_arguments/toc_player_model.dart';
import '../../../models/index.dart';
import '../../../respositories/_respositories/in_app_review_repository.dart';
import '../../pages/_pages/toc/model/navigation_model.dart';
import '../../pages/_pages/toc/util/toc_helper.dart';
import '../../pages/_pages/toc/widgets/course_at_glance_widget.dart';
import '../../pages/_pages/toc/widgets/linear_progress_indicator.dart';
import '../../pages/_pages/toc/widgets/rate_now_pop_up.dart';
import '../../pages/_pages/toc/widgets/toc_download_certificate.dart';

class ModuleItem extends StatefulWidget {
  final navigationItems;
  final Course course;
  final int moduleIndex;
  final String moduleName;
  final List glanceListItems;
  final navigation;
  final bool initiallyExpanded;
  final String? batchId;
  final String? lastAccessContentId;
  final bool isCourse;
  final bool isFeatured, isPlayer;
  final dynamic duration;
  final String parentCourseId;
  final bool showProgress;
  final CourseHierarchyModel courseHierarchyInfo;
  final int itemCount;
  final ValueChanged<String>? startNewResourse;
  final Course? enrolledCourse;
  final VoidCallback? readCourseProgress;
  final bool allowAccess;
  final List<Course> enrollmentList;

  const ModuleItem(
      {Key? key,
      required this.course,
      required this.moduleIndex,
      required this.moduleName,
      required this.glanceListItems,
      this.navigation,
      this.initiallyExpanded = false,
      this.batchId,
      this.isCourse = false,
      this.isFeatured = false,
      this.duration,
      required this.parentCourseId,
      this.showProgress = false,
      required this.courseHierarchyInfo,
      this.itemCount = 0,
      this.lastAccessContentId,
      this.startNewResourse,
      this.isPlayer = false,
      this.navigationItems,
      this.enrolledCourse,
      this.readCourseProgress,
      this.allowAccess = false,
      required this.enrollmentList})
      : super(key: key);

  @override
  _ModuleItemState createState() => _ModuleItemState();
}

class _ModuleItemState extends State<ModuleItem> {
  double _moduleProgress = 0;
  List _glanceListItems = [];
  bool isCuratedProgram = false, isExpanded = false;
  late String? _lastAccessContentId;
  List _navigationItems = [];

  @override
  void initState() {
    super.initState();
    _lastAccessContentId = widget.lastAccessContentId;
    isCuratedProgram = widget.course.cumulativeTracking;
    _glanceListItems = List.from(widget.glanceListItems);
    _navigationItems = widget.navigationItems.map((e) {
      if (e is List<NavigationModel>) {
        return e.map((item) => item.copy()).toList();
      } else if (e is NavigationModel) {
        return e.copy();
      } else {
        return e;
      }
    }).toList();
    if (widget.course.courseCategory == PrimaryCategory.blendedProgram) {
      removeOfflineContentFromNavigation(_navigationItems);
    }
    if (widget.isPlayer) {
      isLastAccessedContentExist();
    }
  }

  @override
  void didUpdateWidget(covariant ModuleItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    isCuratedProgram = widget.course.cumulativeTracking;
    _glanceListItems = List.from(widget.glanceListItems);
    if (_lastAccessContentId != widget.lastAccessContentId) {
      _lastAccessContentId = widget.lastAccessContentId;
      setState(() {
        if (widget.isPlayer) isExpanded = false;
      });
      isLastAccessedContentExist();
    }
  }

  void _calculateModuleProgress() {
    double sum = 0.0;
    for (var item in _glanceListItems) {
      if (item.status == 2) {
        sum += 1;
      } else if (item.completionPercentage != '0' &&
          item.completionPercentage != null) {
        sum += double.tryParse(item.completionPercentage.toString()) ?? 0;
      }
    }
    _moduleProgress =
        _glanceListItems.isNotEmpty ? sum / _glanceListItems.length : 0;
  }

  Future<void> removeOfflineContentFromNavigation(List navItems) async {
    navItems.removeWhere((child) {
      if (child is! List &&
          child.primaryCategory == PrimaryCategory.offlineSession) {
        return true;
      } else if (child is List) {
        child.removeWhere((e) =>
            e is! List && e.primaryCategory == PrimaryCategory.offlineSession);
      }
      return false;
    });
    navItems.removeWhere((element) => element is List && element.isEmpty);
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  void _generateInteractTelemetryData(
      String contentId, String primaryType) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
      pageIdentifier: TelemetryPageIdentifier.courseDetailsPageId,
      contentId: contentId,
      subType: TelemetrySubType.contentCard,
      env: TelemetryEnv.learn,
      objectType: primaryType,
      isPublic: widget.isFeatured,
    );
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  void isLastAccessedContentExist() {
    isExpanded = false;
    for (var content in _glanceListItems) {
      if (content.contentId == widget.lastAccessContentId) {
        setState(() {
          isExpanded = true;
        });
        break;
      }
    }
  }

  bool canNavigateToTocPlayer() {
    final category = widget.course.courseCategory;
    return (((category == PrimaryCategory.moderatedProgram ||
                category == PrimaryCategory.blendedProgram) &&
            TocHelper().isProgramLive(widget.enrolledCourse)) ||
        (category != PrimaryCategory.moderatedProgram &&
            category != PrimaryCategory.blendedProgram));
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isFeatured) {
      _calculateModuleProgress();
    }
    return Container(
      decoration: BoxDecoration(
        border: isExpanded && !widget.isCourse
            ? null
            : Border.all(
                color: isExpanded && widget.isCourse
                    ? AppColors.darkBlue
                    : AppColors.appBarBackground,
              ),
        color: isExpanded
            ? widget.isCourse
                ? AppColors.darkBlue
                : AppColors.whiteGradientOne
            : AppColors.appBarBackground,
      ),
      child: ExpansionTile(
        key: UniqueKey(),
        onExpansionChanged: (value) => setState(() => isExpanded = !isExpanded),
        tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4).r,
        childrenPadding: EdgeInsets.zero.r,
        initiallyExpanded: isExpanded,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(left: 6).r,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (!widget.isCourse &&
                        widget.enrolledCourse != null &&
                        widget.showProgress)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, right: 6).r,
                        child: _moduleProgress == 1 ||
                                widget.enrolledCourse!.completionPercentage ==
                                    COURSE_COMPLETION_PERCENTAGE
                            ? Icon(Icons.check_circle,
                                size: 22.sp, color: AppColors.darkBlue)
                            : Container(
                                height: 20.w,
                                width: 20.w,
                                child: CircularProgressIndicator(
                                  backgroundColor: AppColors.grey16,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _moduleProgress > 0 && _moduleProgress < 1
                                        ? AppColors.primaryOne
                                        : AppColors.appBarBackground,
                                  ),
                                  strokeWidth: 3.w,
                                  value: _moduleProgress,
                                ),
                              ),
                      ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 0.7.sw,
                              child: Text(
                                '${widget.moduleIndex + 1}.  ${widget.moduleName}',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: GoogleFonts.montserrat(
                                  height: 1.5.w,
                                  decoration: TextDecoration.none,
                                  color: isExpanded
                                      ? widget.isCourse
                                          ? AppColors.appBarBackground
                                          : AppColors.darkBlue
                                      : AppColors.greys87,
                                  fontSize: 16.sp,
                                  fontWeight: isExpanded
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  letterSpacing: 0.12.r,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.w),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CourseAtGlanceWidget(
                              courseInfo: widget.navigation[widget.moduleIndex]
                                  [0],
                              courseHierarchyInfo: widget.courseHierarchyInfo,
                              isExpanded: isExpanded,
                              isCourse: widget.isCourse,
                              duration: widget.duration,
                              itemCount: widget.itemCount,
                            ),
                          ],
                        ),
                        SizedBox(height: 8.w),
                        if (widget.enrolledCourse != null &&
                            widget.showProgress)
                          if ((_moduleProgress >= 1 ||
                                  widget.enrolledCourse?.completionPercentage ==
                                      COURSE_COMPLETION_PERCENTAGE) &&
                              widget.isCourse)
                            TocDownloadCertificateWidget(
                              courseId: widget.parentCourseId,
                              isPlayer: widget.isPlayer,
                              isExpanded: isExpanded,
                              enrolledCourse: widget.enrolledCourse,
                            )
                          else if (_moduleProgress > 0 && widget.isCourse)
                            LinearProgressIndicatorWidget(
                              value: _moduleProgress,
                              isExpnaded: isExpanded,
                              isCourse: widget.isCourse,
                            ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        trailing: isExpanded
            ? Icon(
                widget.isCourse ? Icons.arrow_drop_up : Icons.minimize,
                color: widget.isCourse
                    ? AppColors.appBarBackground
                    : AppColors.darkBlue,
              )
            : Icon(
                widget.isCourse ? Icons.arrow_drop_down : Icons.add,
                color: AppColors.darkBlue,
                size: 24.sp,
              ),
        children: [
          for (int i = 0; i < _glanceListItems.length; i++)
            if ((_glanceListItems[i] is! List || _glanceListItems[i][0] == null) &&
                _glanceListItems[i].primaryCategory !=
                    PrimaryCategory.offlineSession)
              Container(
                  width: 1.sw,
                  color: isExpanded
                      ? AppColors.whiteGradientOne
                      : AppColors.appBarBackground,
                  child: InkWell(
                      onTap: () async {
                        if (!widget.isFeatured) {
                          _generateInteractTelemetryData(
                            _glanceListItems[i].identifier,
                            _glanceListItems[i].primaryCategory,
                          );
                        }
                        if (widget.isPlayer) {
                          if (!_glanceListItems[i].isLocked) {
                            widget.startNewResourse
                                ?.call(_glanceListItems[i].contentId);
                          }
                        } else if (widget.allowAccess) {
                          var result;
                          if (canNavigateToTocPlayer()) {
                            result = await Navigator.pushNamed(
                              context,
                              AppUrl.tocPlayer,
                              arguments: TocPlayerModel(
                                enrolledCourse: widget.enrolledCourse,
                                navigationItems: widget.navigationItems,
                                isCuratedProgram: isCuratedProgram,
                                batchId: widget.batchId,
                                courseId: widget.course.id,
                                isFeatured: widget.isFeatured,
                                lastAccessContentId:
                                    _glanceListItems[i].contentId,
                                enrollmentList: widget.enrollmentList,
                              ),
                            );
                          }
                          if (result != null && result is Map<String, bool>) {
                            Map<String, dynamic> response = result;
                            if (response['isFinished']) {
                              showModalBottomSheet(
                                isScrollControlled: true,
                                context: context,
                                backgroundColor: AppColors.greys60,
                                builder: (ctx) =>
                                    RateNowPopUp(courseDetails: widget.course),
                              ).whenComplete(() => InAppReviewRespository()
                                  .triggerInAppReviewPopup(context));
                            }
                          }
                          widget.readCourseProgress?.call();
                        }
                      },
                      child: _glanceListItems[i].contentId != null
                          ? _glanceListItems[i].contentId == EMimeTypes.offline
                              ? SizedBox.shrink()
                              : GlanceItem3(
                                  icon: TocHelper.getMimeTypeIcon(
                                      _glanceListItems[i].mimeType),
                                  text: _glanceListItems[i].name,
                                  status: widget.enrolledCourse != null && widget.enrolledCourse!.completionPercentage == COURSE_COMPLETION_PERCENTAGE
                                      ? 2
                                      : _glanceListItems[i].status,
                                  duration: _glanceListItems[i].duration,
                                  isFeaturedCourse: widget.isFeatured,
                                  currentProgress: widget.enrolledCourse != null && widget.enrolledCourse!.completionPercentage == COURSE_COMPLETION_PERCENTAGE
                                      ? 1
                                      : _glanceListItems[i]
                                          .completionPercentage,
                                  showProgress: widget.showProgress,
                                  isExpanded: isExpanded,
                                  isLastAccessed: widget.lastAccessContentId ==
                                      _glanceListItems[i].contentId,
                                  isEnrolled: widget.isPlayer
                                      ? true
                                      : widget.enrolledCourse != null,
                                  maxQuestions: (_glanceListItems[i].maxQuestions ?? '')
                                      .toString(),
                                  mimeType: (_glanceListItems[i].mimeType ?? '')
                                      .toString(),
                                  isLocked: _glanceListItems[i].isLocked,
                                  isL2Assessment: _glanceListItems[i].parentCourseId == widget.course.id &&
                                      widget.courseHierarchyInfo.compatibilityLevel >= ResourceCategoryVersion.contentCompatibility.version &&
                                      _glanceListItems[i].mimeType == EMimeTypes.newAssessment &&
                                      isCuratedProgram)
                          : Container(padding: EdgeInsets.all(8).r, child: Text(AppLocalizations.of(context)!.mCourseNoContentsAvailable)))),
          // Add a thin divider if needed
          if (!widget.isCourse)
            Container(
              height: 2.w,
              width: double.infinity.w,
              color: AppColors.grey,
            ),
        ],
      ),
    );
  }
}
