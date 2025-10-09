import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/models/microsite_competency_item_data_model.dart';
import 'package:igot_ui_components/ui/widgets/microsite_competency_item/microsite_competency_item.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/microsites/model/microsites_competency_data_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/microsites/skeleton/micro_sites_competency_strength_view_skeleton.dart';
import 'package:karmayogi_mobile/util/app_config.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../../../../../../constants/_constants/app_constants.dart';
import '../../../../../../../../../constants/_constants/color_constants.dart';
import '../../../../../../../../../constants/_constants/telemetry_constants.dart';
import '../../../../../../../../../models/_models/browse_competency_card_model.dart';
import '../../../../../../../../../respositories/_respositories/learn_repository.dart';
import '../../../../../../../../../util/faderoute.dart';
import '../../../../../../../../../util/telemetry_repository.dart';
import '../../../../../../learn/courses_in_competency.dart';

class MdoCompetencyStrengthView extends StatefulWidget {
  final String orgId;

  MdoCompetencyStrengthView({
    required this.orgId,
    Key? key,
  }) : super(key: key);

  @override
  _MdoCompetencyStrengthViewState createState() {
    return _MdoCompetencyStrengthViewState();
  }
}

class _MdoCompetencyStrengthViewState extends State<MdoCompetencyStrengthView> {
  @override
  void initState() {
    super.initState();

    competencyData = getCompetencies();
  }

  int selectedCompetencyIndex = 0;
  bool viewMoreCompetency = false;
  bool loadingSubTheme = false;
  CompetencyValue? selectedCompetency;
  late Future<List<MicroSiteAllCompetencies>> competencyData;

  Future<List<MicroSiteAllCompetencies>> getCompetencies() async {
    List<MicroSiteAllCompetencies> mdoCompetency = [];

    try {
      var competencyResponseData =
          await Provider.of<LearnRepository>(context, listen: false)
              .getCompetencySearchInfo();

      MicroSitesCompetencyDataModel allAvailableCompetencies =
          MicroSitesCompetencyDataModel.fromJson(competencyResponseData,
              useCompetencyv6: AppConfiguration().useCompetencyv6);

      CompetencyFacets? orgArea = await getOrgCompetencyData(
          AppConfiguration().useCompetencyv6
              ? CompetencyFacetsCategory.competencyAreaFacetV6
              : CompetencyFacetsCategory.competencyAreaFacetV5);
      CompetencyFacets? orgTheme = await getOrgCompetencyData(
          AppConfiguration().useCompetencyv6
              ? CompetencyFacetsCategory.competencyThemeFacetV6
              : CompetencyFacetsCategory.competencyThemeFacetV5);
      CompetencyFacets? orgSubTheme = await getOrgCompetencyData(
          AppConfiguration().useCompetencyv6
              ? CompetencyFacetsCategory.competencySubthemeFacetV6
              : CompetencyFacetsCategory.competencySubthemeFacetV5);

      if (orgArea != null && orgTheme != null && orgSubTheme != null) {
        for (CompetencyValue area in orgArea.values ?? []) {
          if (area.name == null) {
            print("Error: Area name is null.");
            continue;
          }

          for (MicroSiteCompetencyItemDataModel allArea
              in allAvailableCompetencies.competency ?? []) {
            if (allArea.name == null) {
              print("Error: Competency name is null.");
              continue;
            }

            if (allArea.name == area.name) {
              MicroSiteAllCompetencies currentArea =
                  MicroSiteAllCompetencies(name: area.name, count: area.count);
              List<MicroSiteCompetencyItemDataModel> themes = [];

              for (CompetencyValue theme in orgTheme.values ?? []) {
                if (theme.name == null) {
                  print("Error: Theme name is null.");
                  continue;
                }

                for (MicroSiteCompetencyItemDataModel allTheme
                    in allArea.children ?? []) {
                  if (allTheme.name == null) {
                    print("Error: Child theme name is null.");
                    continue;
                  }

                  if (allTheme.name!.toLowerCase() ==
                      theme.name!.toLowerCase()) {
                    MicroSiteCompetencyItemDataModel currentTheme = allTheme;
                    List<MicroSiteCompetencyItemDataModel> subThemes = [];

                    for (CompetencyValue subTheme in orgSubTheme.values ?? []) {
                      // null-aware operator used
                      if (subTheme.name == null) {
                        print("Error: Subtheme name is null.");
                        continue;
                      }

                      for (MicroSiteCompetencyItemDataModel allSubtheme
                          in allTheme.children ?? []) {
                        if (allSubtheme.name == null) {
                          print("Error: Subtheme child name is null.");
                          continue;
                        }

                        if (subTheme.name!.toLowerCase() ==
                            allSubtheme.name!.toLowerCase()) {
                          subThemes.add(allSubtheme);
                        }
                      }
                    }
                    currentTheme.children = subThemes;

                    themes.add(allTheme);
                  }
                }
              }
              currentArea.competency = themes;

              mdoCompetency.add(currentArea);
            }
          }
        }
        print(mdoCompetency);
      } else {
        print("Error: One or more competency facets are null.");
      }
    } catch (e) {
      print("Error fetching competencies: $e");
    }
    return mdoCompetency;
  }

  Future<CompetencyFacets?> getOrgCompetencyData(String facets) async {
    CompetencyFacets? data;
    MicroSiteCompetenciesModel responseData = await getCompetenciesByOrg();
    for (var competency in responseData.facets!) {
      if (competency.name == facets) {
        data = competency;
      }
    }
    return data;
  }

  Future<MicroSiteCompetenciesModel> getCompetenciesByOrg() async {
    var responseData =
        await Provider.of<LearnRepository>(context, listen: false)
            .getCompetenciesByOrg(widget.orgId);

    return MicroSiteCompetenciesModel.fromJson(responseData);
  }

  @override
  Widget build(BuildContext context) {
    return _buildLayout();
  }

  Widget _buildLayout() {
    return FutureBuilder(
      future: competencyData,
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          List<MicroSiteAllCompetencies> competencyList = snapshot.data ?? [];

          return competencyList.isNotEmpty
              ? Container(
                  margin: EdgeInsets.only(bottom: 32).w,
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 16).w,
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _coreAreaDescription(),
                      _competencyStrengthFilterView(competency: competencyList),
                      _microSiteCompetencyStrengthList(
                          competencyList[selectedCompetencyIndex].competency ??
                              []),
                    ],
                  ))
              : SizedBox(
                  height: 0.5.sw,
                );
        } else {
          return MicroSitesCompetencyStrengthViewSkeleton(
              showTitle: false, showFiler: true);
        }
      },
    );
  }

  Widget _coreAreaDescription() {
    return Container(
      margin: EdgeInsets.only(top: 8, bottom: 8).w,
      child: Text(
        AppLocalizations.of(context)!.mMdoChannelCompetenciesDescription,
        style: GoogleFonts.lato(
          color: AppColors.deepBlue,
          fontWeight: FontWeight.w500,
          fontSize: 14.sp,
          height: 1.5.w,
        ),
      ),
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
            selectedCompetencyIndex = index;
            setState(() {});
          },
          child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(right: 12).w,
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 16).w,
              decoration: BoxDecoration(
                border: Border.all(
                  color: selectedCompetencyIndex == index
                      ? AppColors.darkBlue
                      : AppColors.grey40,
                  width: 1.w,
                ),
                borderRadius: BorderRadius.circular(18.w),
                color: selectedCompetencyIndex == index
                    ? AppColors.darkBlue
                    : null,
              ),
              child: Text(
                '${competency[index].name?[0].toUpperCase()}${competency[index].name?.substring(1).toLowerCase()}(${competency[index].competency?.length})',
                style: GoogleFonts.lato(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: selectedCompetencyIndex == index
                      ? AppColors.appBarBackground
                      : AppColors.grey40,
                ),
              )),
        ),
      ),
    );
  }

  Widget _microSiteCompetencyStrengthList(
      List<MicroSiteCompetencyItemDataModel> _selectedCompetencyThemeList) {
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
                        competencyName: selectedCompetency?.name ?? '',
                        totalContentPostFix:
                            '${_selectedCompetencyThemeList[index].count} ${AppLocalizations.of(context)!.mStaticContents}',
                        viewMoreText: AppLocalizations.of(context)!
                            .mCompetencyViewMoreTxt,
                        viewLessText: AppLocalizations.of(context)!
                            .mCompetencyViewLessTxt,
                        competencyItem: _selectedCompetencyThemeList[index],
                        callBack: () {
                          BrowseCompetencyCardModel browseCompetencyCardModel =
                              BrowseCompetencyCardModel(
                            id: _selectedCompetencyThemeList[index]
                                .id
                                .toString(),
                            name:
                                _selectedCompetencyThemeList[index].name ?? '',
                            description:
                                _selectedCompetencyThemeList[index].description,
                            type: _selectedCompetencyThemeList[index].type,
                            competencyType:
                                _selectedCompetencyThemeList[index].type ?? '',
                            status: _selectedCompetencyThemeList[index].status,
                            competencyArea: selectedCompetency?.name ?? '',
                          );
                          Navigator.push(
                            context,
                            FadeRoute(
                                page: CoursesInCompetency(
                                    browseCompetencyCardModel)),
                          );
                        },
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
                            ? TelemetryIdentifier.coreExpertiseLoadMore
                            : TelemetryIdentifier.coreExpertiseLoadLess,
                        subType: TelemetrySubType.mdoChannel);
                    setState(() {
                      viewMoreCompetency = !viewMoreCompetency;
                    });
                  },
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      viewMoreCompetency
                          ? AppLocalizations.of(context)!.mStaticShowLess
                          : AppLocalizations.of(context)!.mStaticShowAll,
                      style: GoogleFonts.lato(
                          height: 1.5.w,
                          color: AppColors.darkBlue,
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
      return SizedBox();
    }
  }

  void _generateInteractTelemetryData(
      {String contentId = '',
      required String subType,
      required String clickId}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.browseByProviderAllCbpPageId,
        contentId: contentId,
        subType: subType,
        clickId: clickId,
        env: TelemetryEnv.learn);
    await telemetryRepository.insertEvent(eventData: eventData);
  }
}
