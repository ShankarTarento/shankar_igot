import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/utils/module_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/models/_models/gyaan_karmayogi_category_model.dart';
import 'package:karmayogi_mobile/models/_models/gyaan_karmayogi_sector_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/gyaan_karmayogi_v2/pages/filter_screen/filter_screen.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/gyaan_karmayogi_v2/services/gyaan_karmayogi_services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../../constants/index.dart';

class FilterBottomBarV2 extends StatefulWidget {
  final List<String> selectedSector;
  final List<String> selectedSubSector;
  final String selectedCategory;
  final Function(Map) applyFilter;
  const FilterBottomBarV2({
    required this.selectedCategory,
    required this.selectedSector,
    required this.selectedSubSector,
    required this.applyFilter,
    super.key,
  });

  @override
  State<FilterBottomBarV2> createState() => _FilterBottomBarV2State();
}

class _FilterBottomBarV2State extends State<FilterBottomBarV2> {
  @override
  void initState() {
    getFilterData();
    super.initState();
  }

  getFilterData() {
    sectors =
        Provider.of<GyaanKarmayogiServicesV2>(context, listen: false).sectors;

    subSector = Provider.of<GyaanKarmayogiServicesV2>(context, listen: false)
        .subSectors;
    categories = Provider.of<GyaanKarmayogiServicesV2>(context, listen: false)
        .categories;
    contextSDGs = Provider.of<GyaanKarmayogiServicesV2>(context, listen: false)
        .contextSDGs;
    contextYear = Provider.of<GyaanKarmayogiServicesV2>(context, listen: false)
        .contextYear;
    contextStateOrUTs =
        Provider.of<GyaanKarmayogiServicesV2>(context, listen: false)
            .contextStateOrUTs;

    selectedSectors = widget.selectedSector;
    selectedSubSectors = widget.selectedSubSector;
    selectedCategory = widget.selectedCategory;
    updateFilterData();
  }

  updateFilterData() {
    sectors = sectors.map((e) {
      return FilterModel(
        title: e.title,
        isSelected: selectedSectors.contains(e.title),
      );
    }).toList();
    subSector = subSector.map((e) {
      return FilterModel(
        title: e.title,
        isSelected: selectedSubSectors.contains(e.title),
      );
    }).toList();
    categories = categories.map((e) {
      return FilterModel(
        title: e.title,
        isSelected: selectedSectors.contains(selectedCategory),
      );
    }).toList();
    setState(() {});
  }

  List<FilterModel> sectors = [];
  List<FilterModel> subSector = [];
  List<FilterModel> categories = [];
  List<FilterModel> contextYear = [];
  List<FilterModel> contextSDGs = [];
  List<FilterModel> contextStateOrUTs = [];
  List<String> selectedSectors = [];
  List<String> selectedSubSectors = [];
  List<String> selectedContextStateOrUTs = [];
  List<String> selectedContextYear = [];
  List<String> selectedContextSDGs = [];
  String? selectedCategory;

  Map<String, dynamic>? searchFilter;
  List<GyaanKarmayogiSector>? availableSectors;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.w,
      width: 1.sw,
      color: AppColors.appBarBackground,
      padding: const EdgeInsets.only(left: 12, bottom: 18).r,
      child: Row(children: [
        IconButton(
            onPressed: () {
              showModalBottomSheet(
                  isScrollControlled: true,
                  useSafeArea: true,
                  isDismissible: true,
                  enableDrag: true,
                  context: context,
                  builder: (BuildContext contextx) {
                    return FilterScreenV2(
                      selectedContextSDGs: List.from(selectedContextSDGs),
                      selectedContextStateOrUTs:
                          List.from(selectedContextStateOrUTs),
                      selectedContextYear: List.from(selectedContextYear),
                      contextSDGs: contextSDGs,
                      contextStateOrUTs: contextStateOrUTs,
                      contextYear: contextYear,
                      selectedSectors: List.from(selectedSectors),
                      selectedSubSector: List.from(selectedSubSectors),
                      selectedCategory: selectedCategory,
                      appliedFilters: (value) {
                        print('appliedFilters=========$value');
                        widget.applyFilter(value);
                        selectedSectors = value['sectors'];
                        selectedCategory = value['category'];
                        selectedSubSectors = value['subSectors'];
                        selectedContextSDGs = value['selectedContextSDGs'];
                        selectedContextStateOrUTs =
                            value['selectedContextStateOrUTs'];
                        selectedContextYear = value['selectedContextYear'];
                        updateFilterData();
                        setState(() {});
                      },
                      sectorVisibility: true,
                      subSectorVisobility: true,
                      categotiesVisibility: true,
                      sdgsVisibility: true,
                      stateAndUtVisibility: true,
                      categories: categories,
                      sectorFilter: List.from(sectors),
                      subSectorFilter: List.from(subSector),
                    );
                  });
            },
            icon: const Icon(Icons.filter_list_outlined)),
        SizedBox(
          width: MediaQuery.of(context).size.width / 1.2,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                filterButton(
                  displayTitle: AppLocalizations.of(context)!.mStaticSectors,
                  title: "Sectors",
                  count: selectedSectors.isNotEmpty
                      ? selectedSectors.length.toString()
                      : sectors.length.toString(),
                ),
                SizedBox(
                  width: 12.w,
                ),
                filterButton(
                    displayTitle: AppLocalizations.of(context)!.mAllSubSectors,
                    title: "Sub-sectors",
                    count: selectedSubSectors.isNotEmpty
                        ? selectedSubSectors.length.toString()
                        : subSector.length.toString()),
                SizedBox(
                  width: 12.w,
                ),
                filterButton(
                    displayTitle:
                        AppLocalizations.of(context)!.mStaticCategories,
                    title: "Categories",
                    count: selectedCategory != null && selectedCategory != ''
                        ? '1'
                        : '0'),
                SizedBox(
                  width: 12.w,
                ),
                filterButton(
                    displayTitle: AppLocalizations.of(context)!.mStatesAndUts,
                    title: "StatesAndUts",
                    count: selectedContextStateOrUTs.isNotEmpty
                        ? selectedContextStateOrUTs.length.toString()
                        : contextStateOrUTs.length.toString()),
                SizedBox(
                  width: 12.w,
                ),
                filterButton(
                    displayTitle: AppLocalizations.of(context)!
                        .mSustainableDevelopmentGoals,
                    title: "SDGs",
                    count: selectedContextSDGs.isNotEmpty
                        ? selectedContextSDGs.length.toString()
                        : contextSDGs.length.toString()),
              ],
            ),
          ),
        )
      ]),
    );
  }

  Widget filterButton(
      {required String title,
      required String count,
      required String displayTitle}) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
            isScrollControlled: true,
            useSafeArea: true,
            isDismissible: true,
            enableDrag: true,
            context: context,
            builder: (BuildContext context) {
              return FilterScreenV2(
                selectedContextSDGs: List.from(selectedContextSDGs),
                selectedContextStateOrUTs: List.from(selectedContextStateOrUTs),
                selectedContextYear: List.from(selectedContextYear),
                contextSDGs: contextSDGs,
                contextStateOrUTs: contextStateOrUTs,
                contextYear: contextYear,
                selectedSectors: List.from(selectedSectors),
                selectedSubSector: List.from(selectedSubSectors),
                selectedCategory: selectedCategory,
                appliedFilters: (value) {
                  print('appliedFilters=========$value');
                  widget.applyFilter(value);
                  selectedSectors = value['sectors'];
                  selectedCategory = value['category'];
                  selectedSubSectors = value['subSectors'];
                  selectedContextSDGs = value['selectedContextSDGs'];
                  selectedContextStateOrUTs =
                      value['selectedContextStateOrUTs'];
                  selectedContextYear = value['selectedContextYear'];
                  updateFilterData();
                  setState(() {});
                },
                sectorVisibility: title == 'Sectors',
                subSectorVisobility: title == 'Sub-sectors',
                categotiesVisibility: title == 'Categories',
                sdgsVisibility: title == 'SDGs',
                stateAndUtVisibility: title == 'StatesAndUts',
                categories: categories,
                sectorFilter: List.from(sectors),
                subSectorFilter: List.from(subSector),
              );
            });
      },
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 9, left: 8).r,
            height: 32.w,
            padding: const EdgeInsets.only(left: 10, right: 10).r,
            decoration: BoxDecoration(
              color: ModuleColors.grey08,
              borderRadius: BorderRadius.circular(30).r,
              border: Border.all(color: ModuleColors.black16),
            ),
            child: Center(
              child: Row(
                children: [
                  Text(
                    displayTitle,
                    style: GoogleFonts.lato(
                        fontSize: 14.sp, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  const Icon(Icons.arrow_drop_down)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
