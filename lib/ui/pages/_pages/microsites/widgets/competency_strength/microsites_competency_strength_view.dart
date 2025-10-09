import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/models/microsite_competency_item_data_model.dart';
import 'package:igot_ui_components/ui/widgets/microsite_competency_item/microsite_competency_item.dart';
import 'package:igot_ui_components/ui/widgets/microsite_spane_text/microsites_span_text.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/microsites/skeleton/micro_sites_competency_strength_view_skeleton.dart';
import 'package:karmayogi_mobile/util/app_config.dart';
import 'package:provider/provider.dart';
import '../../../../../../constants/_constants/app_constants.dart';
import '../../../../../../constants/_constants/color_constants.dart';
import '../../../../../../constants/_constants/telemetry_constants.dart';
import '../../../../../../models/_models/browse_competency_card_model.dart';
import '../../../../../../respositories/_respositories/learn_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../../../util/faderoute.dart';
import '../../../../../../util/hexcolor.dart';
import '../../../../../../util/telemetry_repository.dart';
import '../../../learn/courses_in_competency.dart';
import '../../model/ati_cti_microsite_data_model.dart';
import '../../model/microsites_competency_data_model.dart';

class MicroSitesCompetencyStrengthView extends StatefulWidget {
  final GlobalKey? containerKey;
  final String? orgId;
  final ColumnData columnData;

  MicroSitesCompetencyStrengthView({
    this.containerKey,
    this.orgId,
    required this.columnData,
    Key? key,
  }) : super(key: key);

  @override
  _MicroSitesCompetencyStrengthViewState createState() =>
      _MicroSitesCompetencyStrengthViewState();
}

class _MicroSitesCompetencyStrengthViewState
    extends State<MicroSitesCompetencyStrengthView> {
  MicroSitesCompetencyDataModel? allCompetencies;
  MicroSiteCompetenciesModel? microSiteCompetenciesModel;
  int selectedCompetencyIndex = 0;
  CompetencyValue? selectedCompetency;
  bool viewMoreCompetency = false;
  bool loadingSubTheme = false;
  List<MicroSiteAllCompetencies> microSiteAllCompetenciesList = [];
  Future<List<MicroSiteAllCompetencies>>? microSiteAllCompetenciesFuture;
  Future<List<MicroSiteCompetencyItemDataModel>>?
      microSiteCompetenciesThemeFuture;

  @override
  void initState() {
    super.initState();
    getAllCompetencyData();
  }

  Future<void> getAllCompetencyData() async {
    try {
      var competencyResponseData =
          await Provider.of<LearnRepository>(context, listen: false)
              .getCompetencySearchInfo();
      if (mounted) {
        setState(() {
          allCompetencies = MicroSitesCompetencyDataModel.fromJson(
              competencyResponseData,
              useCompetencyv6: AppConfiguration().useCompetencyv6);
        });
        getMicroSiteCompetencies();
      }
    } catch (e) {
      debugPrint("Error fetching competency data: $e");
    }
  }

  Future<void> getMicroSiteCompetencies() async {
    var responseData =
        await Provider.of<LearnRepository>(context, listen: false)
            .getMicroSiteCompetencies(
                orgId: widget.orgId ?? "",
                competencyArea: '',
                facets: AppConfiguration().useCompetencyv6
                    ? [CompetencyFacetsCategory.competencyAreaFacetV6]
                    : [CompetencyFacetsCategory.competencyAreaFacetV5]);
    try {
      microSiteCompetenciesModel =
          MicroSiteCompetenciesModel.fromJson(responseData);
      if ((microSiteCompetenciesModel?.facets ?? []).isNotEmpty) {
        List<CompetencyValue> competencyList =
            await microSiteCompetenciesModel?.facets?[0].values ?? [];
        if (competencyList.isNotEmpty && selectedCompetency == null) {
          loadingSubTheme = true;
          getMicroSiteCompetenciesAllTheme(competencyList);
        }
      }
    } catch (e) {
      debugPrint('^^^^^^^^^^^^^^^^^^^^^^^^${e}');
    }
  }

  Future<void> getMicroSiteCompetenciesAllTheme(
      List<CompetencyValue> competencyList) async {
    for (var competencyListElement in competencyList) {
      MicroSiteCompetenciesModel responseData =
          await getMicroSiteCompetenciesTheme(
              competencyListElement.name ?? '',
              AppConfiguration().useCompetencyv6
                  ? [CompetencyFacetsCategory.competencyThemeFacetV6]
                  : [CompetencyFacetsCategory.competencyThemeFacetV5]);
      List<MicroSiteCompetencyItemDataModel> _microSiteCompetenciesThemeList =
          [];
      if ((responseData.facets ?? []).isNotEmpty) {
        _microSiteCompetenciesThemeList =
            await getMicroSiteCompetenciesThemeList(
                responseData.facets![0].values ?? [],
                competencyListElement.name ?? '');
      }
      microSiteAllCompetenciesList.add(MicroSiteAllCompetencies(
        name: competencyListElement.name,
        count: _microSiteCompetenciesThemeList.length,
        competency: _microSiteCompetenciesThemeList,
      ));
    }
    setState(() {
      microSiteAllCompetenciesFuture =
          Future.value(microSiteAllCompetenciesList);
      loadingSubTheme = false;
    });
  }

  List<MicroSiteCompetencyItemDataModel> getMicroSiteCompetenciesThemeList(
      List<CompetencyValue> competencyValueList, String currentCompetency) {
    List<MicroSiteCompetencyItemDataModel> competency = [];

    if (allCompetencies?.competency != null) {
      for (var allCompetencyItem in allCompetencies!.competency!) {
        if (allCompetencyItem.name?.toLowerCase() ==
            currentCompetency.toLowerCase()) {
          for (var microSiteThemeElement in competencyValueList) {
            for (var themeElement in allCompetencyItem.children!) {
              if (themeElement.name!.toLowerCase() ==
                  microSiteThemeElement.name!.toLowerCase()) {
                competency.add(themeElement);
              }
            }
          }
        }
      }
    }
    return competency;
  }

  String getTotalCompetencyCount(
      List<MicroSiteAllCompetencies> microSiteAllCompetenciesList) {
    int count = 0;
    microSiteAllCompetenciesList.forEach((element) {
      count += element.count!;
    });
    return count.toString();
  }

  Future<MicroSiteCompetenciesModel> getMicroSiteCompetenciesTheme(
      String competencyArea, List<String> facets) async {
    var responseData =
        await Provider.of<LearnRepository>(context, listen: false)
            .getMicroSiteCompetencies(
                orgId: widget.orgId ?? "",
                competencyArea: competencyArea,
                facets: facets);
    return MicroSiteCompetenciesModel.fromJson(responseData);
  }

  Future<void> getSelectedMicroSiteCompetenciesTheme(
      List<MicroSiteAllCompetencies> microSiteAllCompetencies,
      competencyArea) async {
    List<MicroSiteCompetencyItemDataModel> subThemeFilteredList =
        await filterMicroSiteThemeSubTheme(
            microSiteAllCompetencies[selectedCompetencyIndex].competency ?? [],
            competencyArea);
    if (mounted) {
      setState(() {
        loadingSubTheme = false;
        microSiteCompetenciesThemeFuture = Future.value(subThemeFilteredList);
      });
    }
  }

  Future<List<MicroSiteCompetencyItemDataModel>> filterMicroSiteThemeSubTheme(
      List<MicroSiteCompetencyItemDataModel> microSiteAllCompetencies,
      String competencyArea) async {
    List<MicroSiteCompetencyItemDataModel>? competencyTheme = [];

    MicroSiteCompetenciesModel responseData =
        await getMicroSiteCompetenciesTheme(
            competencyArea,
            AppConfiguration().useCompetencyv6
                ? [CompetencyFacetsCategory.competencySubthemeFacetV6]
                : [CompetencyFacetsCategory.competencySubthemeFacetV5]);
    if ((responseData.facets ?? []).isNotEmpty) {
      for (var competencyListElement in microSiteAllCompetencies) {
        MicroSiteCompetencyItemDataModel competencyItem =
            await MicroSiteCompetencyItemDataModel(
          id: competencyListElement.id,
          type: competencyListElement.type,
          name: competencyListElement.name,
          displayName: competencyListElement.displayName,
          description: competencyListElement.description,
          status: competencyListElement.status,
          count: competencyListElement.count,
          children: getFilteredCompetenciesThemeChildren(
              competencyListElement.children ?? [],
              responseData.facets![0].values ?? []),
        );
        competencyTheme.add(competencyItem);
      }
    }
    return competencyTheme;
  }

  List<MicroSiteCompetencyItemDataModel> getFilteredCompetenciesThemeChildren(
      List<MicroSiteCompetencyItemDataModel> competencyItemList,
      List<CompetencyValue> competencyValuesList) {
    List<MicroSiteCompetencyItemDataModel> competency = [];

    if (competencyItemList.isNotEmpty) {
      for (var competencyItemItem in competencyItemList) {
        for (var competencyValuesItem in competencyValuesList) {
          if ((competencyItemItem.name ?? '').toLowerCase().trim() ==
              (competencyValuesItem.name ?? '').toLowerCase().trim()) {
            competency.add(competencyItemItem);
          }
        }
      }
    }
    return competency;
  }

  void updateSelectedCompetency(
      int index, List<MicroSiteAllCompetencies> competencyList) {
    setState(() {
      selectedCompetency = CompetencyValue(
          name: competencyList[index].name, count: competencyList[index].count);
      selectedCompetencyIndex = index;
      loadingSubTheme = true;
    });
    if (competencyList.isNotEmpty) {
      getSelectedMicroSiteCompetenciesTheme(
          competencyList, competencyList[index].name ?? "");
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildLayout();
  }

  Widget _buildLayout() {
    return Container(
      key: widget.containerKey,
      child: _buildCompetencyLayout(),
    );
  }

  Widget _buildCompetencyLayout() {
    return FutureBuilder(
      future: microSiteAllCompetenciesFuture,
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          List<MicroSiteAllCompetencies> competencyList = snapshot.data ?? [];
          if (competencyList.isNotEmpty && selectedCompetency == null) {
            selectedCompetency = CompetencyValue(
                name: competencyList[0].name, count: competencyList[0].count);
            loadingSubTheme = true;
            getSelectedMicroSiteCompetenciesTheme(
                competencyList, competencyList[0].name);
          }
          return competencyList.isNotEmpty
              ? Container(
                  color: (widget.columnData.background != null &&
                          widget.columnData.background != '')
                      ? HexColor(widget.columnData.background!)
                      : AppColors.deepBlue,
                  margin: EdgeInsets.only(bottom: 32).w,
                  padding: EdgeInsets.fromLTRB(16, 32, 16, 16).w,
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 8).w,
                        child: MicroSiteSpanText(
                          textOne: widget.columnData.title,
                          textTwo:
                              '(${getTotalCompetencyCount(competencyList)})',
                          textOneColor: AppColors.appBarBackground,
                          textTwoColor: AppColors.primaryOne,
                        ),
                      ),
                      _competencyStrengthFilterView(competency: competencyList),
                      _microSiteCompetencyStrengthList(),
                    ],
                  ),
                )
              : SizedBox.shrink();
        } else {
          return MicroSitesCompetencyStrengthViewSkeleton(showFiler: true);
        }
      },
    );
  }

  Widget _competencyStrengthFilterView(
      {required List<MicroSiteAllCompetencies> competency}) {
    return Container(
      height: 32.w,
      alignment: Alignment.center,
      margin: EdgeInsets.only(top: 16).w,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: competency.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) => GestureDetector(
          onTap: () {
            _generateInteractTelemetryData(
                clickId: TelemetryIdentifier.competencyTypeCoreExpertise
                    .replaceAll(':name', competency[index].name ?? ""),
                subType: TelemetrySubType.atiCti);
            updateSelectedCompetency(index, competency);
          },
          child: Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(right: 12).w,
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 16).w,
            decoration: BoxDecoration(
              border: Border.all(
                color: selectedCompetencyIndex == index
                    ? AppColors.darkBlue
                    : AppColors.appBarBackground,
                width: 1.w,
              ),
              borderRadius: BorderRadius.circular(18.w),
              color:
                  selectedCompetencyIndex == index ? AppColors.darkBlue : null,
            ),
            child: Text(
              '${competency[index].name?[0].toUpperCase()}${competency[index].name?.substring(1).toLowerCase()}(${competency[index].count})',
              style: GoogleFonts.lato(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.appBarBackground,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _microSiteCompetencyStrengthList() {
    return (!loadingSubTheme)
        ? FutureBuilder(
            future: microSiteCompetenciesThemeFuture,
            builder: (context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                List<MicroSiteCompetencyItemDataModel>
                    _selectedCompetencyThemeList = snapshot.data ?? [];
                if (_selectedCompetencyThemeList.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8).w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _selectedCompetencyThemeList.length >
                                    COMPETENCY_ITEM_DISPLAY_LIMIT
                                ? viewMoreCompetency
                                    ? _selectedCompetencyThemeList.length
                                    : COMPETENCY_ITEM_DISPLAY_LIMIT
                                : _selectedCompetencyThemeList.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                  padding: const EdgeInsets.only(top: 8.0).w,
                                  child: MicroSiteCompetencyItem(
                                    competencyName:
                                        selectedCompetency?.name ?? '',
                                    totalContentPostFix: "0",
                                    // '${_selectedCompetencyThemeList[index].count ?? "0"} ${((int.parse(_selectedCompetencyThemeList[index].count ?? "0")) > 1) ? AppLocalizations.of(context)!.mStaticContents : AppLocalizations.of(context)!.mStaticContent}',
                                    viewMoreText: AppLocalizations.of(context)!
                                        .mCompetencyViewMoreTxt,
                                    viewLessText: AppLocalizations.of(context)!
                                        .mCompetencyViewLessTxt,
                                    competencyItem:
                                        _selectedCompetencyThemeList[index],
                                    callBack: () {
                                      BrowseCompetencyCardModel
                                          browseCompetencyCardModel =
                                          BrowseCompetencyCardModel.fromJson({
                                        'id':
                                            _selectedCompetencyThemeList[index]
                                                .id
                                                .toString(),
                                        'name':
                                            _selectedCompetencyThemeList[index]
                                                .name,
                                        'description':
                                            _selectedCompetencyThemeList[index]
                                                .description,
                                        'type':
                                            _selectedCompetencyThemeList[index]
                                                .type,
                                        'competencyType':
                                            _selectedCompetencyThemeList[index]
                                                .type,
                                        'status':
                                            _selectedCompetencyThemeList[index]
                                                .status,
                                        'competencyArea':
                                            selectedCompetency!.name,
                                      });
                                      Navigator.push(
                                        context,
                                        FadeRoute(
                                            page: CoursesInCompetency(
                                                browseCompetencyCardModel)),
                                      );
                                    },
                                    showContentCount: false,
                                  ));
                            }),
                        if (_selectedCompetencyThemeList.length >
                            COMPETENCY_ITEM_DISPLAY_LIMIT)
                          Padding(
                            padding: EdgeInsets.only(top: 16).w,
                            child: InkWell(
                              onTap: () {
                                _generateInteractTelemetryData(
                                    clickId: viewMoreCompetency
                                        ? TelemetryIdentifier
                                            .coreExpertiseLoadMore
                                        : TelemetryIdentifier
                                            .coreExpertiseLoadLess,
                                    subType: TelemetrySubType.atiCti);
                                setState(() {
                                  viewMoreCompetency = !viewMoreCompetency;
                                });
                              },
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  viewMoreCompetency
                                      ? AppLocalizations.of(context)!
                                          .mStaticShowLess
                                      : AppLocalizations.of(context)!
                                          .mStaticShowAll,
                                  style: GoogleFonts.lato(
                                      height: 1.5.w,
                                      color: AppColors.appBarBackground,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          )
                      ],
                    ),
                  );
                } else {
                  return SizedBox.shrink();
                }
              } else {
                return MicroSitesCompetencyStrengthViewSkeleton(
                    showTitle: false, showFiler: false);
              }
            },
          )
        : MicroSitesCompetencyStrengthViewSkeleton(
            showTitle: false, showFiler: false);
  }

  String getAllCompetencyCount(List<CompetencyValue> competency) {
    int count = 0;
    competency.forEach((element) {
      count += element.count!;
    });
    return count.toString();
  }

  void _generateInteractTelemetryData(
      {String? contentId, String? subType, String? clickId}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
      pageIdentifier: TelemetryPageIdentifier.browseByProviderAllCbpPageId,
      contentId: contentId ?? "",
      subType: subType ?? "",
      clickId: clickId ?? "",
      env: TelemetryEnv.learn,
    );
    await telemetryRepository.insertEvent(eventData: eventData);
  }
}
