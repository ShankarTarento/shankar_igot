import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:igot_ui_components/ui/widgets/elevated_chip/elevated_chip.dart';
import 'package:karmayogi_mobile/respositories/_respositories/learn_repository.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/microsites/widgets/course_strip/microsites_course_strip_view.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/microsites/skeleton/ati_cti_microsites_screen_skeleton.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/microsites/widgets/top_section/microsites_top_section_view.dart';
import 'package:provider/provider.dart';
import '../../../../../../constants/_constants/color_constants.dart';
import '../../../../../../constants/_constants/telemetry_constants.dart';
import '../../../../../../util/faderoute_slide.dart';
import '../../../../../../util/telemetry_repository.dart';
import '../../model/ati_cti_microsite_data_model.dart';
import '../../widgets/competency_strength/microsites_competency_strength_view.dart';
import '../../widgets/contributors/microsites_contributors_view.dart';
import '../../widgets/infra_detail/microsites_infra_detail_view.dart';
import '../../widgets/learner_reviews/microsites_learner_reviews_view.dart';
import '../../widgets/training_calendar/microsites_training_calendar_view.dart';
import '../contents/microsites_all_contents.dart';

class AtiCtiMicroSitesScreen extends StatefulWidget {
  final String? providerName;
  final String? orgId;

  AtiCtiMicroSitesScreen({this.providerName, this.orgId});

  @override
  _AtiCtiMicroSitesScreenState createState() {
    return _AtiCtiMicroSitesScreenState();
  }
}

class _AtiCtiMicroSitesScreenState extends State<AtiCtiMicroSitesScreen> {
  late ScrollController _MicroSitesScrollController;
  Future<AtiCtiMicroSitesFormDataModel>? microSiteFuture;
  List<SectionListModel> microSiteSortedData = [];
  List<Widget> microSiteWidgets = [];

  var _topBannerKey = GlobalKey();
  var _trainingCalendarKey = GlobalKey();
  var _competencyStrengthKey = GlobalKey();
  var _featuredContentsKey = GlobalKey();
  var _topContentsKey = GlobalKey();
  var _contributorKey = GlobalKey();
  var _infraDetailKey = GlobalKey();
  var _learnersReviewsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _MicroSitesScrollController = ScrollController();
    getMicroSiteFormData();
    _generateInteractTelemetryData();
    _generateInteractTelemetryData(subType: TelemetrySubType.atiCti);
  }

  Future<void> getMicroSiteFormData() async {
    var responseData =
        await Provider.of<LearnRepository>(context, listen: false)
            .getMicroSiteFormData(orgId: widget.orgId ?? "", type: 'ATI-CTI');

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        microSiteFuture =
            Future.value(AtiCtiMicroSitesFormDataModel.fromJson(responseData));
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _MicroSitesScrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: microSiteFuture,
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          if (snapshot.data.rootOrgId.toString() != widget.orgId.toString()) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              Navigator.of(context).pushReplacement(
                FadeRouteSlide(
                    page: MicroSiteAllContents(
                        providerName: widget.providerName ?? '')),
              );
            });
          }
          List<SectionListModel> microSiteDataList =
              snapshot.data.data.sectionList ?? [];
          microSiteSortedData =
              microSiteDataList.where((item) => item.enabled!).toList();
          microSiteSortedData.sort((a, b) => a.order!.compareTo(b.order!));
          sortLayouts(microSiteSortedData);
          return Scaffold(
            appBar: _appBar(),
            body: (microSiteWidgets.isNotEmpty) ? _buildLayout() : Container(),
            bottomSheet: (microSiteSortedData.isNotEmpty)
                ? _bottomAction()
                : Container(),
          );
        } else {
          return AtiCtiMicroSitesScreenSkeleton(appBarWidget: _appBar());
        }
      },
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      elevation: 0,
      titleSpacing: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, size: 24.sp, color: AppColors.greys60),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget _buildLayout() {
    return SafeArea(
      child: SingleChildScrollView(
        controller: _MicroSitesScrollController,
        physics: BouncingScrollPhysics(),
        child: Container(
          margin: EdgeInsets.only(bottom: 100).w,
          child: Column(children: microSiteWidgets),
        ),
      ),
    );
  }

  Widget _bottomAction() {
    List<SectionListModel> _navOrderedList =
        microSiteSortedData.where((item) => item.navigation!).toList();
    _navOrderedList =
        microSiteSortedData.where((item) => item.navOrder != 0).toList();
    _navOrderedList.sort((a, b) => a.navOrder!.compareTo(b.navOrder!));
    return Container(
        height: 87.w,
        width: double.maxFinite,
        padding: EdgeInsets.fromLTRB(0, 16, 0, 32).w,
        decoration: BoxDecoration(color: AppColors.assesmentCardBackground),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              InkWell(
                onTap: _scrollToTop,
                child: Container(
                  margin: EdgeInsets.only(right: 4, left: 16).w,
                  child: Icon(
                    Icons.arrow_upward,
                    size: 24.w,
                    color: AppColors.grey40,
                  ),
                ),
              ),
              ...List.generate(
                  _navOrderedList.length,
                  (index) => Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                                    left: 4,
                                    right:
                                        (index == (_navOrderedList.length - 1))
                                            ? 16
                                            : 4)
                                .w,
                            child: ElevatedChip(
                              onTap: () {
                                switch (_navOrderedList[index].key) {
                                  case 'sectionTopBanner':
                                    return _scrollToContainer(
                                        containerKey: _topBannerKey);
                                  case 'sectionTrainingCalendar':
                                    _generateInteractTelemetryData(
                                        clickId: TelemetryIdentifier
                                            .trainingCalendarNavigation,
                                        subType: TelemetrySubType.atiCti);
                                    return _scrollToContainer(
                                        containerKey: _trainingCalendarKey);
                                  case 'sectionContributors':
                                    _generateInteractTelemetryData(
                                        clickId: TelemetryIdentifier
                                            .contributorNavigation,
                                        subType: TelemetrySubType.atiCti);
                                    return _scrollToContainer(
                                        containerKey: _contributorKey);
                                  case 'sectionInfrastructure':
                                    _generateInteractTelemetryData(
                                        clickId: TelemetryIdentifier
                                            .infrastructureDetailNavigation,
                                        subType: TelemetrySubType.atiCti);
                                    return _scrollToContainer(
                                        containerKey: _infraDetailKey);
                                  case 'sectionFeatureCourses':
                                    _generateInteractTelemetryData(
                                        clickId: TelemetryIdentifier
                                            .featuredContentsNavigation,
                                        subType: TelemetrySubType.atiCti);
                                    return _scrollToContainer(
                                        containerKey: _featuredContentsKey);
                                  case 'sectionPopularCourses':
                                    _generateInteractTelemetryData(
                                        clickId: TelemetryIdentifier
                                            .topContentsNavigation,
                                        subType: TelemetrySubType.atiCti);
                                    return _scrollToContainer(
                                        containerKey: _topContentsKey);
                                  case 'sectionCompetency':
                                    _generateInteractTelemetryData(
                                        clickId: TelemetryIdentifier
                                            .competencyStrengthNavigation,
                                        subType: TelemetrySubType.atiCti);
                                    return _scrollToContainer(
                                        containerKey: _competencyStrengthKey);
                                  case 'sectionLearnerReview':
                                    _generateInteractTelemetryData(
                                        clickId: TelemetryIdentifier
                                            .learnersReviewsNavigation,
                                        subType: TelemetrySubType.atiCti);
                                    return _scrollToContainer(
                                        containerKey: _learnersReviewsKey);
                                  default:
                                    return _scrollToTop();
                                }
                              },
                              borderColor: AppColors.disabledTextGrey,
                              borderWidth: 1.w,
                              text: '${_navOrderedList[index].title}',
                              textColor: AppColors.greys87,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ))
            ],
          ),
        ));
  }

  void _scrollToTop() {
    _MicroSitesScrollController.animateTo(0,
        duration: Duration(seconds: 1), curve: Curves.linear);
  }

  void _scrollToContainer({GlobalKey? containerKey}) {
    Scrollable.ensureVisible(
      containerKey!.currentContext!,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void sortLayouts(List<SectionListModel> _microSiteSortedData) {
    microSiteWidgets = [];
    _microSiteSortedData.forEach((element) {
      switch (element.key) {
        case 'sectionTopBanner':
          if (element.column.isNotEmpty)
            return microSiteWidgets.add(MicroSitesTopSectionView(
                containerKey: _topBannerKey,
                providerName: widget.providerName!,
                orgId: widget.orgId!,
                columnData: element.column[0]));
          break;
        case 'sectionTrainingCalendar':
          if (element.column.isNotEmpty)
            return microSiteWidgets.add(MicroSitesTrainingCalendarView(
                containerKey: _trainingCalendarKey,
                orgId: widget.orgId,
                columnData: element.column[0]));
          break;
        case 'sectionFeatureCourses':
          if (element.column.isNotEmpty)
            return microSiteWidgets.add(MicroSitesCourseStripView(
                containerKey: _featuredContentsKey,
                contentsType: 'featuredContents',
                contentsTitle: element.title ?? '',
                orgId: widget.orgId!,
                columnData: element.column[0]));
          break;
        case 'sectionPopularCourses':
          if (element.column.isNotEmpty)
            return microSiteWidgets.add(MicroSitesCourseStripView(
                containerKey: _topContentsKey,
                contentsType: 'topContents',
                contentsTitle: element.title ?? '',
                orgId: widget.orgId!,
                columnData: element.column[0]));
          break;
        case 'sectionCompetency':
          if (element.column.isNotEmpty)
            return microSiteWidgets.add(MicroSitesCompetencyStrengthView(
                containerKey: _competencyStrengthKey,
                orgId: widget.orgId!,
                columnData: element.column[0]));
          break;
        case 'sectionContributors':
          if (element.column.isNotEmpty)
            return microSiteWidgets.add(MicroSitesContributorsView(
                containerKey: _contributorKey,
                orgId: widget.orgId!,
                columnData: element.column[0]));
          break;
        case 'sectionInfrastructure':
          if (element.column.isNotEmpty)
            return microSiteWidgets.add(MicroSitesInfraDetailView(
              containerKey: _infraDetailKey,
              columnData: element.column[0],
            ));
          break;
        case 'sectionLearnerReview':
          if (element.column.isNotEmpty)
            return microSiteWidgets.add(MicroSitesLearnerReviewsView(
                containerKey: _learnersReviewsKey,
                orgId: widget.orgId!,
                columnData: element.column[0]));
          break;
        default:
          return microSiteWidgets.add(SizedBox.shrink());
      }
    });
  }

  void _generateInteractTelemetryData(
      {String? contentId, String? subType, String? clickId}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.browseByProviderAllCbpPageId,
        contentId: contentId ?? "",
        subType: subType ?? "",
        clickId: clickId ?? "",
        env: TelemetryEnv.learn);
    await telemetryRepository.insertEvent(eventData: eventData);
  }
}
