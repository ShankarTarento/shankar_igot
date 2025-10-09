import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/models/_models/gyaan_karmayogi_category_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/gyaan_karmayogi_v2/pages/filter_screen/widgets/filter_check_box.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/gyaan_karmayogi_v2/pages/filter_screen/widgets/filter_radio_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/gyaan_karmayogi_v2/pages/filter_screen/widgets/filter_year_slider.dart';

class FilterScreenV2 extends StatefulWidget {
  final bool sectorVisibility;
  final bool subSectorVisobility;
  final bool categotiesVisibility;
  final bool sdgsVisibility;
  final bool stateAndUtVisibility;
  final List<FilterModel> sectorFilter;
  final List<FilterModel> subSectorFilter;
  final List<FilterModel> categories;
  final List<FilterModel> contextYear;
  final List<FilterModel> contextSDGs;
  final List<FilterModel> contextStateOrUTs;
  final Function(Map) appliedFilters;
  final List<String> selectedSectors;
  final List<String> selectedSubSector;
  final String? selectedCategory;
  final List<String> selectedContextStateOrUTs;
  final List<String> selectedContextYear;
  final List<String> selectedContextSDGs;

  const FilterScreenV2(
      {super.key,
      required this.contextSDGs,
      required this.contextStateOrUTs,
      required this.contextYear,
      required this.sectorVisibility,
      required this.categotiesVisibility,
      required this.subSectorVisobility,
      required this.categories,
      required this.sectorFilter,
      required this.subSectorFilter,
      required this.appliedFilters,
      required this.selectedSectors,
      required this.selectedSubSector,
      this.selectedCategory,
      required this.sdgsVisibility,
      required this.stateAndUtVisibility,
      required this.selectedContextStateOrUTs,
      required this.selectedContextYear,
      required this.selectedContextSDGs});

  @override
  State<FilterScreenV2> createState() => _FilterScreenV2State();
}

class _FilterScreenV2State extends State<FilterScreenV2> {
  @override
  initState() {
    sectors = widget.sectorFilter;
    subSector = widget.subSectorFilter;
    categories = widget.categories;
    selectedCategory = widget.selectedCategory;
    selectedSectors = widget.selectedSectors;
    selectedSubSectors = widget.selectedSubSector;
    contextStateOrUTs = widget.contextStateOrUTs;
    contextSDGs = widget.contextSDGs;
    contextYearontextYear = widget.contextYear;
    selectedContextSDGs = widget.selectedContextSDGs;
    selectedContextStateOrUTs = widget.selectedContextStateOrUTs;
    selectedContextYear = widget.selectedContextYear;
    selectedContextYear.sort();
    contextYearontextYear.sort((a, b) => a.title.compareTo(b.title));

    super.initState();
  }

  List<FilterModel> sectors = [];
  List<FilterModel> subSector = [];
  List<FilterModel> categories = [];
  List<FilterModel> contextStateOrUTs = [];
  List<FilterModel> contextYearontextYear = [];
  List<FilterModel> contextSDGs = [];
  List<String> selectedSectors = [];
  List<String> selectedSubSectors = [];
  List<String> selectedContextStateOrUTs = [];
  List<String> selectedContextYear = [];
  List<String> selectedContextSDGs = [];

  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: Container(
          padding: EdgeInsets.only(top: 10.r, bottom: 15.r),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(width: 2.0, color: AppColors.grey08),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width / 2.8,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appBarBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50).r,
                    ),
                    side: const BorderSide(color: AppColors.darkBlue, width: 1),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.mStaticCancel,
                    style: GoogleFonts.lato(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkBlue,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 2.8,
                child: ElevatedButton(
                  onPressed: () {
                    widget.appliedFilters({
                      'sectors': selectedSectors,
                      'subSectors': selectedSubSectors,
                      'category':
                          selectedCategory == '' ? null : selectedCategory,
                      'selectedContextSDGs': selectedContextSDGs,
                      'selectedContextStateOrUTs': selectedContextStateOrUTs,
                      'selectedContextYear': selectedContextYear
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50).r,
                    ),
                    side: const BorderSide(color: AppColors.darkBlue, width: 1),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!
                        .mCompetenciesContentTypeApplyFilters,
                    style: GoogleFonts.lato(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.appBarBackground,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.all(16).r,
                  height: 8,
                  width: 80,
                  decoration: BoxDecoration(
                    color: AppColors.greys60,
                    borderRadius: BorderRadius.circular(16).r,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16).r,
                child: Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.mStaticFilterResults,
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(16.0).r,
                  child: Column(children: [
                    const Divider(
                      color: AppColors.grey08,
                      thickness: 2,
                    ),
                    Visibility(
                      visible: widget.sectorVisibility,
                      child: Column(
                        children: [
                          FilterCheckboxV2(
                            title: AppLocalizations.of(context)!.mStaticSectors,
                            selectedItems: selectedSectors,
                            checkListItems: sectors,
                            onChanged: (value) {
                              selectedSectors = value;
                              // widget.selectedSectors = value;
                            },
                            searchHint:
                                AppLocalizations.of(context)!.mSearchSector,
                          ),
                          const Divider(
                            color: AppColors.grey08,
                            thickness: 2,
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: widget.subSectorVisobility,
                      child: Column(
                        children: [
                          FilterCheckboxV2(
                            selectedItems: selectedSubSectors,
                            title:
                                AppLocalizations.of(context)!.mStaticSubSectors,
                            checkListItems: subSector,
                            onChanged: (value) {
                              selectedSubSectors = value;
                              // widget.selectedSubsectors = value;
                            },
                            searchHint:
                                AppLocalizations.of(context)!.mSearchSubSector,
                          ),
                          const Divider(
                            color: AppColors.grey08,
                            thickness: 2,
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: widget.categotiesVisibility,
                      child: Column(
                        children: [
                          FilterRadioButtonV2(
                            title:
                                AppLocalizations.of(context)!.mStaticCategories,
                            selectedItem: selectedCategory,
                            checkListItems: widget.categories,
                            onChanged: (value) {
                              selectedCategory = value;
                            },
                            searchHint:
                                AppLocalizations.of(context)!.mSearchCategory,
                          ),
                          const Divider(
                            color: AppColors.grey08,
                            thickness: 2,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    widget.sectorVisibility &&
                            widget.subSectorVisobility &&
                            widget.categotiesVisibility &&
                            contextYearontextYear.isNotEmpty
                        ? YearSliderFilter(
                            title: AppLocalizations.of(context)!.mYear,
                            startYear: contextYearontextYear.first.title,
                            endYear: contextYearontextYear.last.title,
                            startValue: selectedContextYear.isNotEmpty
                                ? selectedContextYear.first
                                : contextYearontextYear.first.title,
                            endValue: selectedContextYear.isNotEmpty
                                ? selectedContextYear.last
                                : contextYearontextYear.last.title,
                            values: (values) {
                              selectedContextYear = values['years'];
                              print(selectedContextYear);
                            },
                          )
                        : SizedBox(),
                    widget.stateAndUtVisibility
                        ? Column(
                            children: [
                              FilterCheckboxV2(
                                selectedItems: selectedContextStateOrUTs,
                                title:
                                    AppLocalizations.of(context)!.mStatesAndUts,
                                checkListItems: contextStateOrUTs,
                                onChanged: (value) {
                                  selectedContextStateOrUTs = value;
                                  // widget.selectedSubsectors = value;
                                },
                                searchHint:
                                    AppLocalizations.of(context)!.mSearchStates,
                              ),
                              const Divider(
                                color: AppColors.grey08,
                                thickness: 2,
                              ),
                            ],
                          )
                        : SizedBox(),
                    widget.sdgsVisibility
                        ? Column(
                            children: [
                              FilterCheckboxV2(
                                selectedItems: selectedContextSDGs,
                                title: AppLocalizations.of(context)!
                                    .mSustainableDevelopmentGoals,
                                checkListItems: contextSDGs,
                                onChanged: (value) {
                                  selectedContextSDGs = value;
                                  // widget.selectedSubsectors = value;
                                },
                                searchHint:
                                    AppLocalizations.of(context)!.mSearchSdgs,
                              ),
                              const Divider(
                                color: AppColors.grey08,
                                thickness: 2,
                              ),
                            ],
                          )
                        : SizedBox(),
                  ])),
            ],
          ),
        ),
      ),
    );
  }
}
