import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/gyaan_karmayogi_v2/pages/view_all_page/view_all_pages.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/gyaan_karmayogi_v2/services/gyaan_karmayogi_services.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/gyaan_karmayogi_v2/widget/agk_form.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/gyaan_karmayogi_v2/widget/gyaan_karmayogi_carousel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/gyaan_karmayogi_v2/widget/top_section.dart';
import 'package:karmayogi_mobile/ui/widgets/base_scaffold.dart';
import 'package:karmayogi_mobile/ui/widgets/hubs_custom_app_bar.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:karmayogi_mobile/util/telemetry_repository.dart';
import 'package:provider/provider.dart';

class GyaanKarmayogiV2 extends StatefulWidget {
  final String? title;
  const GyaanKarmayogiV2({super.key, this.title});

  @override
  State<GyaanKarmayogiV2> createState() => _GyaanKarmayogiV2State();
}

class _GyaanKarmayogiV2State extends State<GyaanKarmayogiV2>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    _controller = TabController(length: 2, vsync: this, initialIndex: 0);
    _generateImpressionTelemetryData();

    getData();
  }

  @override
  void didChangeDependencies() {
    tabs = [
      AppLocalizations.of(context)!.mAGKCaseStudies,
      AppLocalizations.of(context)!.mOtherResources
    ];
    super.didChangeDependencies();
  }

  getData() async {
    await Provider.of<GyaanKarmayogiServicesV2>(context, listen: false)
        .getAllFilterData();
    await Provider.of<GyaanKarmayogiServicesV2>(context, listen: false)
        .fetchFilters();
    await Provider.of<GyaanKarmayogiServicesV2>(context, listen: false)
        .getCreatedForData();
    await Provider.of<GyaanKarmayogiServicesV2>(context, listen: false)
        .getAmritGyaanConfig();
  }

  void _generateImpressionTelemetryData() async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getImpressionTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.amritGyaanKoshPageId,
        telemetryType: TelemetryType.app,
        pageUri: TelemetryPageIdentifier.amritGyaanKoshPageId,
        env: TelemetryEnv.amritGyaanKosh);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  TabController? _controller;

  bool showAll = false;
  String? sectorFilter;
  String? subSectorFilter;
  String? searchQuery;
  String? resourceCategory;
  List<String> tabs = [];
  int selectedTabIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.whiteGradientOne,
        appBar: HubsCustomAppBar(
          title: widget.title ?? AppLocalizations.of(context)!.mAmritGyaanKosh,
          titlePrefixIcon: Icon(Icons.menu_book, size: 24.sp, color: AppColors.darkBlue),
        ),
        body: DefaultTabController(
          length: 2,
          child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      TopSection(
                        filterData: (value) {
                          if (sectorFilter != value['sector'] ||
                              subSectorFilter != value['subSector'] ||
                              resourceCategory != value['category'] ||
                              searchQuery != value['query']) {
                            Provider.of<GyaanKarmayogiServicesV2>(context,
                                    listen: false)
                                .getAllFilterData(
                              createdFor: selectedTabIndex == 0
                                  ? null
                                  : Provider.of<GyaanKarmayogiServicesV2>(
                                          context,
                                          listen: false)
                                      .createdFor,
                              searchQuery: value['query'],
                              sectorsFilter: value['sector'] != null
                                  ? [value['sector']]
                                  : [],
                              subSectorFilter: value['subSector'] != null
                                  ? [value['subSector']]
                                  : [],
                              resourceCategoryFilter: value['category'] != null
                                  ? [value['category']]
                                  : [],
                            );
                            sectorFilter = value['sector'];
                            subSectorFilter = value['subSector'];
                            searchQuery = value['query'];
                            resourceCategory = value['category'];
                            setState(() {});
                          }
                        },
                        navigateToViewAll: () {
                          Navigator.push(
                              context,
                              FadeRoute(
                                  page: ViewAllScreenV2(
                                index: selectedTabIndex,
                                sector: sectorFilter,
                                subSector: subSectorFilter,
                              )));
                        },
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 16, right: 16).r,
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.only(top: 4).w,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom:
                                BorderSide(width: 1.w, color: AppColors.grey08),
                          ),
                        ),
                        child: TabBar(
                          controller: _controller,
                          tabAlignment: TabAlignment.start,
                          isScrollable: true,
                          indicator: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: AppColors.darkBlue,
                                width: 2.0.w,
                              ),
                            ),
                          ),
                          indicatorColor: AppColors.appBarBackground,
                          labelPadding: EdgeInsets.only(top: 0.0).w,
                          unselectedLabelColor: AppColors.greys60,
                          labelColor: AppColors.greys87,
                          labelStyle: GoogleFonts.lato(
                            fontSize: 14.0.sp,
                            fontWeight: FontWeight.w700,
                          ),
                          unselectedLabelStyle: GoogleFonts.lato(
                            fontSize: 14.0.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.greys60,
                          ),
                          onTap: (index) {
                            selectedTabIndex = index;
                            Provider.of<GyaanKarmayogiServicesV2>(context,
                                    listen: false)
                                .getAllFilterData(
                                    createdFor: selectedTabIndex == 0
                                        ? null
                                        : Provider.of<GyaanKarmayogiServicesV2>(
                                                context,
                                                listen: false)
                                            .createdFor,
                                    searchQuery: searchQuery,
                                    sectorsFilter: sectorFilter != null
                                        ? [sectorFilter!]
                                        : [],
                                    subSectorFilter: subSectorFilter != null
                                        ? [subSectorFilter!]
                                        : [],
                                    resourceCategoryFilter:
                                        resourceCategory != null
                                            ? [resourceCategory!]
                                            : []);
                          },
                          tabs: List.generate(
                            tabs.length,
                            (index) {
                              return Container(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 16).r,
                                  child: Tab(
                                    child: Padding(
                                      padding: EdgeInsets.all(5.0).r,
                                      child: Text(
                                        tabs[index],
                                      ),
                                    ),
                                  ));
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ];
            },
            body: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                controller: _controller,
                children: List.generate(
                  2,
                  (index) => Consumer<GyaanKarmayogiServicesV2>(
                    builder: (context, provider, child) {
                      List<String> resourceCategories =
                          provider.resourceCategoriesFilters;
                      return resourceCategories.isNotEmpty
                          ? SingleChildScrollView(
                              child: Column(
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.all(16.0).r,
                                      child: Text(
                                        index == 0
                                            ? AppLocalizations.of(context)!
                                                .mAgkCaseStudyDescription
                                            : AppLocalizations.of(context)!
                                                .mOtherResourcesDescription,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      )),
                                  Column(
                                    children: List.generate(
                                      resourceCategories.length > 3 && !showAll
                                          ? 3
                                          : resourceCategories.length,
                                      (index) => GyaanKarmayogiCarouselV2(
                                        createdFor: selectedTabIndex == 0
                                            ? null
                                            : Provider.of<
                                                        GyaanKarmayogiServicesV2>(
                                                    context,
                                                    listen: false)
                                                .createdFor,
                                        searchQuery: searchQuery,
                                        sectorFilter: sectorFilter,
                                        subSectorFilter: subSectorFilter,
                                        title: resourceCategories[index],
                                      ),
                                    ),
                                  ),
                                  resourceCategories.length > 4
                                      ? ElevatedButton(
                                          onPressed: () {
                                            showAll = showAll ? false : true;
                                            setState(() {});
                                          },
                                          style: ElevatedButton.styleFrom(
                                            elevation: 0,
                                            backgroundColor:
                                                AppColors.appBarBackground,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30).r,
                                              side: BorderSide(
                                                  color: AppColors.darkBlue),
                                            ),
                                          ),
                                          child: Text(
                                            showAll
                                                ? Helper.capitalizeFirstLetter(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .mStaticViewLess)
                                                : AppLocalizations.of(context)!
                                                    .mViewAllCategories,
                                            style: GoogleFonts.lato(
                                              color: AppColors.darkBlue,
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        )
                                      : SizedBox(),
                                  index == 0 ? AgkForm() : SizedBox(),
                                  SizedBox(
                                    height: 100.w,
                                  ),
                                ],
                              ),
                            )
                          : Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 100).r,
                                child: Text(AppLocalizations.of(context)!
                                    .mNoResourcesFound),
                              ),
                            );
                    },
                  ),
                )),
          ),
        )).withChatbotButton();
  }
}
