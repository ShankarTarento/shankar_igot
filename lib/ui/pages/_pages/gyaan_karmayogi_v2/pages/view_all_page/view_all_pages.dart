import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/ui/widgets/resource_card/resource_card.dart';
import 'package:igot_ui_components/ui/widgets/skeleton_loading/card_skeleton_loading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/constants/_constants/app_routes.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_arguments/course_toc_model.dart';
import 'package:karmayogi_mobile/models/_models/gyaan_karmayogi_resource_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/gyaan_karmayogi_v2/pages/details_screen/details_screen.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/gyaan_karmayogi_v2/pages/view_all_page/widgets/filter_bottom_bar.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/gyaan_karmayogi_v2/services/gyaan_karma_yogi_helper.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/gyaan_karmayogi_v2/services/gyaan_karmayogi_services.dart';
import 'package:karmayogi_mobile/ui/widgets/silverappbar_delegate.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:karmayogi_mobile/util/index.dart';
import 'package:provider/provider.dart';

class ViewAllScreenV2 extends StatefulWidget {
  final String? sector;
  final String? subSector;
  final String? category;
  final int index;

  const ViewAllScreenV2({
    this.category,
    this.sector,
    this.subSector,
    required this.index,
    super.key,
  });

  @override
  State<ViewAllScreenV2> createState() => _ViewAllScreenState();
}

class _ViewAllScreenState extends State<ViewAllScreenV2>
    with TickerProviderStateMixin {
  late Future<List<GyaanKarmayogiResource>> _resourcesFuture;
  late TabController _tabController;

  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  List<String> tabs = [];
  List<String> selectedSectors = [];
  List<String> selectedSubSectors = [];
  List<String> selectedStateOrUTs = [];
  List<String> selectedYears = [];
  List<String> selectedSDGs = [];

  String? selectedCategory;
  int selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();

    _tabController =
        TabController(length: 2, vsync: this, initialIndex: widget.index);
    selectedTabIndex = widget.index;
    selectedCategory = widget.category;

    _fetchResources();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    tabs = [
      AppLocalizations.of(context)!.mAGKCaseStudies,
      AppLocalizations.of(context)!.mOtherResources,
    ];
  }

  void _fetchResources() {
    _resourcesFuture = GyaanKarmayogiServicesV2.getGyaanKarmaYogiResources(
      resourceCategoryFilter:
          selectedCategory != null ? [selectedCategory!] : [],
      sectorsFilter: widget.sector != null ? [widget.sector!] : [],
      subSectorFilter: widget.subSector != null ? [widget.subSector!] : [],
      createdFor: selectedTabIndex == 0
          ? null
          : Provider.of<GyaanKarmayogiServicesV2>(context, listen: false)
              .createdFor,
    );
  }

  void _applyFilters({
    required List<String> sector,
    required List<String> subSector,
    required List<String> category,
    required List<String> contextYear,
    required List<String> contextSdgs,
    required List<String> contextStateOrUTs,
  }) {
    setState(() {
      selectedSectors = sector;
      selectedSubSectors = subSector;
      selectedCategory = category.isNotEmpty ? category.first : null;
      selectedYears = contextYear;
      selectedSDGs = contextSdgs;
      selectedStateOrUTs = contextStateOrUTs;

      _resourcesFuture = GyaanKarmayogiServicesV2.getGyaanKarmaYogiResources(
        contextSDGs: contextSdgs,
        contextStateOrUTs: contextStateOrUTs,
        contextYear: selectedTabIndex == 0 ? contextYear : [],
        resourceCategoryFilter: category,
        sectorsFilter: sector,
        subSectorFilter: subSector,
        createdFor: selectedTabIndex == 0
            ? null
            : Provider.of<GyaanKarmayogiServicesV2>(context, listen: false)
                .createdFor,
      );
      isLoading.value = false;
    });
  }

  Widget _buildResourceList() {
    return FutureBuilder<List<GyaanKarmayogiResource>>(
      future: _resourcesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoading();
        }

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return Column(
            children: snapshot.data!
                .map((resource) => Padding(
                      padding: const EdgeInsets.only(bottom: 16).r,
                      child: ResourceCard(
                          creatorLogo: Image.asset(
                            "assets/img/igot_creator_icon.png",
                            package: "igot_ui_components",
                            fit: BoxFit.fill,
                          ),
                          creator: resource.source,
                          mimeType: GyaanKarmaYogiHelper().checkContentType(
                            mimeType: resource.mimeType,
                          ),
                          mimeTypeIcon:
                              GyaanKarmaYogiHelper().checkContentTypeIcon(
                            mimeType: resource.mimeType,
                          ),
                          posterImage: resource.posterImage,
                          resourceDescription: resource.description,
                          resourceName: resource.name,
                          onTapCallBack: () {
                            final contentType = GyaanKarmaYogiHelper()
                                .checkContentType(mimeType: resource.mimeType);
                            if (contentType == "Collection") {
                              Navigator.pushNamed(
                                context,
                                AppUrl.courseTocPage,
                                arguments: CourseTocModel.fromJson({
                                  'courseId': resource.identifier,
                                }),
                              );
                            } else {
                              Navigator.push(
                                context,
                                FadeRoute(
                                  page: ResourceDetailsScreenV2(
                                      resourceId: resource.identifier),
                                ),
                              );
                            }
                          },
                          tags: getSectorNames(resource)),
                    ))
                .toList(),
          );
        }

        return Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 150.0).r,
            child: Text(
              AppLocalizations.of(context)!.mNoResourcesFound,
              style: GoogleFonts.lato(fontSize: 14.sp),
            ),
          ),
        );
      },
    );
  }

  List<String> getSectorNames(GyaanKarmayogiResource sectorDetails) {
    if (sectorDetails.sector == null) return [];

    final Set<String> uniqueSectorNames = {};

    for (var item in sectorDetails.sector!) {
      if (item.sectorName.isNotEmpty) {
        uniqueSectorNames.add(item.sectorName);
      }
    }

    return uniqueSectorNames.toList();
  }

  Widget _buildLoading() {
    return Column(
      children: List.generate(3, (_) => const CardSkeletonLoading()),
    );
  }

  TabBar _buildTabBar() {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      indicator: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.darkBlue, width: 2.0.w),
        ),
      ),
      labelPadding: EdgeInsets.only(top: 10.0).r,
      unselectedLabelColor: AppColors.greys60,
      labelColor: AppColors.darkBlue,
      labelStyle:
          GoogleFonts.lato(fontSize: 10.sp, fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.lato(fontSize: 10.sp),
      onTap: (index) {
        selectedTabIndex = index;
        isLoading.value = true;
        _applyFilters(
          contextSdgs: selectedSDGs,
          contextStateOrUTs: selectedStateOrUTs,
          contextYear: selectedYears,
          sector: selectedSectors,
          subSector: selectedSubSectors,
          category: selectedCategory != null ? [selectedCategory!] : [],
        );
      },
      tabs: tabs
          .map((tabTitle) => Container(
                width: 0.5.sw,
                padding: const EdgeInsets.symmetric(horizontal: 16).r,
                child: Tab(
                  child: Text(
                    tabTitle,
                    style: GoogleFonts.lato(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.greys87,
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        bottomNavigationBar: FilterBottomBarV2(
          applyFilter: (filter) {
            _applyFilters(
              contextSdgs: filter['selectedContextSDGs'],
              contextStateOrUTs: filter['selectedContextStateOrUTs'],
              contextYear: filter['selectedContextYear'],
              category: filter['category'] != null ? [filter['category']] : [],
              sector: filter['sectors'] ?? [],
              subSector: filter['subSectors'] ?? [],
            );
          },
          selectedCategory: selectedCategory ?? '',
          selectedSector: widget.sector != null ? [widget.sector!] : [],
          selectedSubSector:
              widget.subSector != null ? [widget.subSector!] : [],
        ),
        body: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (_, __) => [
              SliverAppBar(
                title: Text(
                  AppLocalizations.of(context)!.mAmritGyaanKosh,
                  style: GoogleFonts.lato(fontSize: 16.sp),
                ),
              ),
              SliverPersistentHeader(
                delegate: SilverAppBarDelegate(_buildTabBar()),
                pinned: true,
              )
            ],
            body: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(
                2,
                (_) => ValueListenableBuilder<bool>(
                  valueListenable: isLoading,
                  builder: (context, loading, _) => loading
                      ? _buildLoading()
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(12).r,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (selectedCategory != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                          left: 12, bottom: 16)
                                      .r,
                                  child: Text(
                                    Helper.capitalizeFirstLetter(
                                        selectedCategory!),
                                    style: GoogleFonts.lato(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              _buildResourceList(),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
