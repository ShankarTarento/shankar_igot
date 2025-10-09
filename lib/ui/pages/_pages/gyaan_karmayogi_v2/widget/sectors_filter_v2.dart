import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/gyaan_karmayogi_v2/services/gyaan_karmayogi_services.dart';
import '../../../../../constants/_constants/color_constants.dart';
import '../../../../../util/helper.dart';

// ignore: must_be_immutable
class SectorFilterV2 extends StatefulWidget {
  String? selectedSector;
  String? selectedSubSector;
  String? selectedCategory;
  final Function(Map) filterValues;
  final Function() navigateToViewAll;
  SectorFilterV2(
      {Key? key,
      required this.filterValues,
      this.selectedCategory,
      this.selectedSector,
      required this.navigateToViewAll,
      this.selectedSubSector})
      : super(key: key);

  @override
  _SectorFilterV2State createState() => _SectorFilterV2State();
}

class _SectorFilterV2State extends State<SectorFilterV2> {
  List<String> sectors = [];
  List<String> subSectors = [];
  List<String> resourceCategories = [];
  String? selectedSector;
  String? selectedSubSector;

  @override
  void didChangeDependencies() {
    _fetchSectors();
    super.didChangeDependencies();
  }

  Future<void> _fetchSectors() async {
    sectors = [
      'All Sectors',
      ...await GyaanKarmayogiServicesV2().getAvailableSectors()
    ];

    await _updateResourceCategoriesAndSubSectors();
  }

  Future<void> _updateResourceCategoriesAndSubSectors() async {
    subSectors = [
      'All Sub-Sectors',
      ...await GyaanKarmayogiServicesV2().getSubsector(
        returnSubsector: true,
        sectorFilter: selectedSector,
      )
    ];

    resourceCategories = [
      'All Categories',
      ...await GyaanKarmayogiServicesV2().getSubsector(
        returnSubsector: false,
        subsectorFilter: selectedSubSector,
        sectorFilter: selectedSector,
      )
    ];
    setState(() {});
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required String hint,
  }) {
    return SizedBox(
      height: 40.w,
      child: DropdownButtonFormField2<String>(
        isExpanded: true,
        decoration: InputDecoration(
          fillColor: AppColors.appBarBackground,
          contentPadding: const EdgeInsets.only(bottom: 6).r,
          border: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.grey16),
              borderRadius: BorderRadius.circular(5).r),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.grey16),
              borderRadius: BorderRadius.circular(5).r),
          filled: true,
        ),
        selectedItemBuilder: (context) => items
            .map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    Helper.capitalize(item),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(fontSize: 14.sp),
                    overflow: TextOverflow.ellipsis,
                  ),
                ))
            .toList(),
        value: value,
        items: items.isNotEmpty
            ? items
                .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(Helper.capitalize(item),
                        style: GoogleFonts.lato(
                            color: value == item
                                ? AppColors.darkBlue
                                : AppColors.greys,
                            fontSize: 14.sp,
                            fontWeight: value == item
                                ? FontWeight.w600
                                : FontWeight.w400))))
                .toList()
            : [],
        onChanged: onChanged,
        style: GoogleFonts.lato(
            color: AppColors.greys,
            fontSize: 14.sp,
            fontWeight: FontWeight.w400),
        buttonStyleData: ButtonStyleData(
            height: 40.w, padding: EdgeInsets.symmetric(horizontal: 10).r),
        iconStyleData: const IconStyleData(
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.black45),
            iconSize: 20),
        dropdownStyleData: DropdownStyleData(
            padding: const EdgeInsets.symmetric(horizontal: 10).r,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5).r,
                border: Border.all(color: AppColors.grey16))),
        menuItemStyleData: const MenuItemStyleData(padding: EdgeInsets.all(0)),
        hint: Row(children: [
          Text(hint,
              style: GoogleFonts.lato(
                  fontSize: 14.sp, fontWeight: FontWeight.w400))
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0).r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(AppLocalizations.of(context)!.mStaticSector),
          _buildDropdown(
            value: widget.selectedSector,
            items: sectors,
            hint: AppLocalizations.of(context)!.mAllSectors,
            onChanged: (value) {
              widget.selectedCategory = null;
              widget.selectedSubSector = null;
              widget.selectedSector = value == 'All Sectors' ? null : value;
              selectedSubSector = null;
              selectedSector = value == 'All Sectors' ? null : value;

              _updateResourceCategoriesAndSubSectors();
            },
          ),
          SizedBox(height: 16.w),
          _buildLabel(AppLocalizations.of(context)!.mStaticSubSector),
          _buildDropdown(
            value: widget.selectedSubSector,
            items: widget.selectedSector != null ? subSectors : [],
            hint: AppLocalizations.of(context)!.mAllSubSectors,
            onChanged: (value) {
              widget.selectedSubSector =
                  value == 'All Sub-Sectors' ? null : value;
              widget.selectedCategory = null;
              selectedSubSector = value == 'All Sub-Sectors' ? null : value;

              _updateResourceCategoriesAndSubSectors();
            },
          ),
          SizedBox(height: 16.w),
          _buildLabel(AppLocalizations.of(context)!.mStaticCategory),
          _buildDropdown(
            value: widget.selectedCategory,
            items: resourceCategories,
            hint: AppLocalizations.of(context)!.mAllCategories,
            onChanged: (value) {
              widget.selectedCategory =
                  value == 'All Categories' ? null : value;
              setState(() {});
            },
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  widget.filterValues({
                    'sector': widget.selectedSector,
                    'subSector': widget.selectedSubSector,
                    'category': widget.selectedCategory,
                  });
                },
                child: Text(
                  AppLocalizations.of(context)!
                      .mCompetenciesContentTypeApplyFilters,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: AppColors.appBarBackground, fontSize: 14.sp),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              SizedBox(
                width: 16,
              ),
              ElevatedButton(
                onPressed: () {
                  widget.navigateToViewAll();
                },
                child: Text(
                  AppLocalizations.of(context)!.mMoreFilters,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: AppColors.darkBlue, fontSize: 14.sp),
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: AppColors.appBarBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: BorderSide(
                      color: AppColors.darkBlue,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text,
            style:
                GoogleFonts.lato(fontWeight: FontWeight.w700, fontSize: 14.sp)),
        const SizedBox(height: 10),
      ],
    );
  }
}
