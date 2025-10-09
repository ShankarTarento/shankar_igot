import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/models/_models/course_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/microsites/model/ati_cti_microsite_data_model.dart';
import 'package:karmayogi_mobile/ui/skeleton/pages/course_card_skeleton_page.dart';
import 'package:provider/provider.dart';
import '../../../../../../../../../../constants/_constants/color_constants.dart';
import '../../../../../../../../../../respositories/_respositories/learn_repository.dart';
import '../../../../../../../../../../util/faderoute.dart';
import '../../../../../../../../../../util/telemetry_repository.dart';
import '../../../../../../../../../widgets/title_semibold_size16.dart';
import '../../../../../../../my_learnings/no_data_widget.dart';
import '../../../../../../model/course_pills_data_model.dart';
import '../../../../../../model/mdo_course_strip_data_model.dart';
import '../../../../../contents_screen/mdo_all_content_screen.dart';
import 'mdo_course_strip_view_skeleton.dart';
import 'mdo_course_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MdoCourseStripView extends StatefulWidget {
  final String contentsType;
  final String title;
  final String? orgId;
  final String? type;
  final String? telemetryIdentifier;
  final ColumnData columnData;

  MdoCourseStripView({
    required this.contentsType,
    required this.title,
    this.orgId,
    this.type,
    Key? key,
    this.telemetryIdentifier,
    required this.columnData,
  }) : super(key: key);

  @override
  _MdoCourseStripView createState() {
    return _MdoCourseStripView();
  }
}

class _MdoCourseStripView extends State<MdoCourseStripView> {
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
    mdoStripsDataModel = MdoStripsDataModel.fromJson(widget.columnData.data);
    if ((mdoStripsDataModel?.strips ?? []).isNotEmpty) {
      _courseTab = mdoStripsDataModel!.strips![0].tabs ?? [];
      loadingCourses = true;
      if ((_courseTab).isNotEmpty) {
        selectedCoursePillsData = _courseTab[0];
        getMdoCoursesData(selectedCoursePillsData!.value!);
      }
    }
  }

  Future<void> getMdoCoursesData(String selectedCoursePills) async {
    var responseData =
        await Provider.of<LearnRepository>(context, listen: false)
            .getMdoCoursesData(
                widget.orgId ?? '', widget.type ?? '', selectedCoursePills);
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
      child: _microSiteCourseStrip(_courseList, widget.title, true),
    );
  }

  Widget _microSiteCourseStrip(
      dynamic courseList, String title, bool showShowAll) {
    return (_courseTab.isNotEmpty)
        ? Container(
            margin: EdgeInsets.only(bottom: 8).w,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 15).w,
                  child: Row(
                    children: [
                      Container(
                          child: TitleSemiboldSize16(
                        title,
                        maxLines: 2,
                        fontSize: 16,
                      )),
                      Spacer(),
                      Visibility(
                        visible: showShowAll,
                        child: Container(
                          width: 60.w,
                          child: InkWell(
                              onTap: () {
                                _generateInteractTelemetryData(
                                    TelemetryIdentifier.showAll,
                                    subType: TelemetrySubType.mdoChannel,
                                    isObjectNull: true);
                                Navigator.push(
                                  context,
                                  FadeRoute(
                                      page: MdoAllContentScreen(
                                    title: widget.title,
                                    orgId: widget.orgId,
                                    type: widget.type,
                                    selectedCoursePill:
                                        selectedCoursePillsData!.value,
                                  )),
                                );
                              },
                              child: Text(
                                AppLocalizations.of(context)!.mStaticShowAll,
                                textAlign: TextAlign.right,
                                style: GoogleFonts.lato(
                                  color: AppColors.darkBlue,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14.sp,
                                  letterSpacing: 0.12.w,
                                ),
                              )),
                        ),
                      )
                    ],
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
                            return MdoCourseStripViewSkeleton(
                              showHeader: false,
                            );
                          }
                        },
                      )
                    : MdoCourseStripViewSkeleton(
                        showHeader: false,
                      )
              ],
            ))
        : SizedBox.shrink();
  }

  Widget _microSiteCourseList(
      {dynamic courseList, required String title, bool? showShowAll}) {
    return courseList == null
        ? const CourseCardSkeletonPage()
        : courseList.runtimeType == String
            ? Center()
            : courseList.isEmpty
                ? Center()
                : MdoCourseWidget(
                    trendingList: courseList,
                    showHeader: false,
                    title: title,
                    orgId: widget.orgId,
                    type: widget.type,
                    showShowAll: showShowAll ?? true,
                    titleFontSize: 16.sp,
                    viewAllFontSize: 14.sp,
                    telemetrySubType: TelemetrySubType.mdoChannel);
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
                      getMdoCoursesData(tabList[index].value ?? '');
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
      String clickId = ''}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.homePageId,
        contentId: contentId,
        subType: subType ?? '',
        env: TelemetryEnv.home,
        objectType: primaryCategory != null
            ? primaryCategory
            : (isObjectNull ? null : subType),
        clickId: clickId);
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
      default:
        return AppLocalizations.of(context)!.mCommonNoCourseFound;
    }
  }
}
