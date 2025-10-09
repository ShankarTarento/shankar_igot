import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/microsites/skeleton/microsites_course_strip_view_skeleton.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/microsites/widgets/course_strip/widgets/microsite_course_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/title_widget/title_widget.dart';
import 'package:provider/provider.dart';
import '../../../../../../constants/_constants/color_constants.dart';
import '../../../../../../models/_models/course_model.dart';
import '../../../../../../respositories/_respositories/learn_repository.dart';
import '../../../../../../util/faderoute.dart';
import '../../../../../../util/telemetry_repository.dart';
import '../../../mdo_channels/model/course_pills_data_model.dart';
import '../../../mdo_channels/model/mdo_course_strip_data_model.dart';
import '../../../my_learnings/no_data_widget.dart';
import '../../model/ati_cti_microsite_data_model.dart';
import 'widgets/microsite_show_all_courses.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MicroSitesCourseStripView extends StatefulWidget {
  final GlobalKey? containerKey;
  final String? contentsType;
  final String? contentsTitle;
  final String? orgId;
  final String? telemetryIdentifier;
  final ColumnData? columnData;
  final bool showNavigationButtons;

  MicroSitesCourseStripView({
    this.containerKey,
    this.contentsType,
    this.showNavigationButtons = true,
    this.contentsTitle,
    this.orgId,
    Key? key,
    this.telemetryIdentifier,
    this.columnData,
  }) : super(key: key);

  @override
  _MicroSitesCourseStripViewState createState() {
    return _MicroSitesCourseStripViewState();
  }
}

class _MicroSitesCourseStripViewState extends State<MicroSitesCourseStripView> {
  dynamic _courseList = [];
  List<CoursePillsDataModel> _courseTab = [];
  Future<List<Course>>? courseDataFuture;
  MdoStripsDataModel? mdoStripsDataModel;

  int selectedCoursePillsIndex = 0;
  CoursePillsDataModel? selectedCoursePillsData;
  bool loadingCourses = false;

  @override
  void initState() {
    super.initState();
    getCoursePillsData();
  }

  void getCoursePillsData() {
    mdoStripsDataModel = widget.columnData?.data != null
        ? MdoStripsDataModel.fromJson(widget.columnData!.data)
        : null;
    if ((mdoStripsDataModel?.strips ?? []).isNotEmpty) {
      _courseTab = mdoStripsDataModel!.strips![0].tabs ?? [];
      loadingCourses = true;
      if (_courseTab.isNotEmpty) {
        selectedCoursePillsData = _courseTab[0];
        getCourseData(selectedCoursePillsData?.mobValue ?? '');
      }
    }
  }

  void getCourseData(String selectedCoursePills) {
    if (widget.contentsType.toString() == 'topContents') {
      getMicroSiteTopCourses(selectedCoursePills);
    } else {
      getMicroSiteFeaturedCourses(selectedCoursePills);
    }
  }

  Future<void> getMicroSiteTopCourses(String selectedCoursePills) async {
    var responseData =
        await Provider.of<LearnRepository>(context, listen: false)
            .getMicroSiteTopCourses(
                widget.orgId ?? '', [], selectedCoursePills, 12);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        courseDataFuture = Future<List<Course>>.value(
          responseData.map<Course>((data) => Course.fromJson(data)).toList(),
        );
        loadingCourses = false;
      });
    });
  }

  Future<void> getMicroSiteFeaturedCourses(String selectedCoursePills) async {
    var responseData =
        await Provider.of<LearnRepository>(context, listen: false)
            .getMicroSiteFeaturedCourses(
                widget.orgId ?? '', [], selectedCoursePills);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        courseDataFuture = Future<List<Course>>.value(
          responseData.map<Course>((data) => Course.fromJson(data)).toList(),
        );
        loadingCourses = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildLayout();
  }

  Widget _buildLayout() {
    return Container(
      key: widget.containerKey,
      child: _microSiteCourseStrip(_courseList, widget.contentsTitle!, true),
    );
  }

  Widget _microSiteCourseStrip(
      dynamic courseList, String title, bool showShowAll) {
    return (_courseTab.isNotEmpty)
        ? Container(
            margin: EdgeInsets.only(bottom: 16).w,
            padding: EdgeInsets.fromLTRB(0, 0, 0, 8).w,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TitleWidget(
                    title: title,
                    showAllCallBack: showShowAll
                        ? () {
                            _generateInteractTelemetryData(
                                TelemetryIdentifier.showAll,
                                subType: TelemetrySubType.atiCti,
                                isObjectNull: true);
                            Navigator.push(
                              context,
                              FadeRoute(
                                  page: MicroSiteShowAllCourses(
                                title: title,
                                orgId: widget.orgId,
                                type: widget.contentsType,
                                selectedCoursePill:
                                    selectedCoursePillsData!.mobValue,
                              )),
                            );
                          }
                        : null,
                  ),
                ),
                _courseFilterPills(tabList: _courseTab),
                (!loadingCourses)
                    ? FutureBuilder(
                        future: courseDataFuture,
                        builder: (context, AsyncSnapshot<dynamic> snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            List<Course> courseList = snapshot.data ?? [];
                            return courseList.isNotEmpty
                                ? _microSiteCourseList(
                                    courseList: courseList,
                                    title: title,
                                    showShowAll: showShowAll)
                                : NoDataWidget(
                                    message: getNoDataMessage(
                                        selectedCoursePillsData?.nodataMsg ??
                                            ''));
                          } else {
                            return MicroSitesCourseStripViewSkeleton(
                                showHeader: false);
                          }
                        },
                      )
                    : MicroSitesCourseStripViewSkeleton(showHeader: false)
              ],
            ))
        : SizedBox.shrink();
  }

  Widget _microSiteCourseList(
      {required List<Course> courseList,
      required String title,
      bool? showShowAll}) {
    return courseList.runtimeType == String
        ? Center()
        : courseList.isEmpty
            ? Center()
            : courseList.isEmpty
                ? Center()
                : MicroSiteCourseWidget(
                    trendingList: courseList,
                    showHeader: false,
                    title: title,
                    orgId: widget.orgId ?? "",
                    type: widget.contentsType ?? "",
                    showShowAll: showShowAll ?? true,
                    showNavigationButtons: widget.showNavigationButtons,
                    showItemIndicator: false,
                    titleFontSize: 16.sp,
                    viewAllFontSize: 14.sp,
                    telemetrySubType: TelemetrySubType.mdoChannel,
                    telemetryIdentifier: widget.telemetryIdentifier ?? '',
                    showAllCallback: () {
                      Navigator.push(
                        context,
                        FadeRoute(
                            page: MicroSiteShowAllCourses(
                          title: title,
                          orgId: widget.orgId ?? '',
                          type: widget.contentsType ?? '',
                        )),
                      );
                    },
                  );
  }

  Widget _courseFilterPills({required List<CoursePillsDataModel> tabList}) {
    if ((tabList.isNotEmpty)) {
      return Container(
        height: 32.w,
        margin: EdgeInsets.symmetric(vertical: 8).w,
        alignment: Alignment.centerLeft,
        child: ListView.builder(
            physics: BouncingScrollPhysics(),
            shrinkWrap: true,
            itemCount: tabList.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) => GestureDetector(
                  onTap: () {
                    if (index != selectedCoursePillsIndex) {
                      setState(() {
                        selectedCoursePillsIndex = index;
                        selectedCoursePillsData = tabList[index];
                        loadingCourses = true;
                      });
                      getCourseData(tabList[index].mobValue ?? '');
                    }
                  },
                  child: Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(
                              right: 16, left: (index == 0) ? 16 : 0)
                          .w,
                      padding:
                          EdgeInsets.symmetric(vertical: 6, horizontal: 16).w,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedCoursePillsIndex == index
                              ? AppColors.darkBlue
                              : AppColors.grey24,
                          width: 1.w,
                        ),
                        borderRadius: BorderRadius.circular(18.w),
                        color: selectedCoursePillsIndex == index
                            ? AppColors.darkBlue
                            : null,
                      ),
                      child: Text(
                        '${tabList[index].label}',
                        style: GoogleFonts.lato(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: selectedCoursePillsIndex == index
                              ? AppColors.appBarBackground
                              : AppColors.greys60,
                        ),
                      )),
                )),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  void _generateInteractTelemetryData(String contentId,
      {String? subType,
      String? primaryCategory,
      bool isObjectNull = false,
      String? clickId}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.homePageId,
        contentId: contentId,
        subType: subType ?? '',
        env: TelemetryEnv.home,
        objectType: primaryCategory != null
            ? primaryCategory
            : (isObjectNull ? null : subType),
        clickId: clickId ?? '');
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  String getNoDataMessage(String message) {
    switch (message) {
      case 'nocontent':
        return AppLocalizations.of(context)!.mStaticNoContent;
      case 'atinofuturecourses':
        return AppLocalizations.of(context)!.mStaticAtiNoFutureCourses;
      case 'atinofutureprograms':
        return AppLocalizations.of(context)!.mStaticAtiNoFuturePrograms;
      case 'atinofutureassessments':
        return AppLocalizations.of(context)!.mStaticAtiNoFutureAssessments;
      case 'atinotopcourses':
        return AppLocalizations.of(context)!.mStaticNoTopCourses;
      case 'atinotopprograms':
        return AppLocalizations.of(context)!.mStaticNoTopPrograms;
      case 'atinotopassessments':
        return AppLocalizations.of(context)!.mStaticNoTopAssessments;
      default:
        return AppLocalizations.of(context)!.mCommonNoCourseFound;
    }
  }
}
