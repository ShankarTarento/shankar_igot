import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../../constants/_constants/color_constants.dart';

class MicroSitesCourseFilters extends StatefulWidget {
  final String? filterName;
  final List? items;
  final List? selectedItems;
  final ValueChanged<Map>? updateFiltersCallback;
  final ValueChanged<String>? applyFilters;
  final ValueChanged<String>? setDefaultCallback;

  MicroSitesCourseFilters(
      {Key? key,
      this.filterName,
      this.items,
      this.selectedItems,
      this.updateFiltersCallback,
      this.applyFilters,
      this.setDefaultCallback})
      : super(key: key);
  @override
  _MicroSitesCourseFiltersState createState() =>
      _MicroSitesCourseFiltersState();
}

class _MicroSitesCourseFiltersState extends State<MicroSitesCourseFilters> {
  Map? data;

  @override
  void initState() {
    super.initState();
  }

  void _updateFilter(i) {
    data = {'filter': widget.filterName, 'item': widget.items![i]};
    widget.updateFiltersCallback!(data!);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.appBarBackground,
        body: _buildLayout(),
        bottomNavigationBar: _bottomNavigationView(),
      ),
    );
  }

  Widget _buildLayout() {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.all(16).w,
              height: 8.w,
              width: 80.w,
              decoration: BoxDecoration(
                color: AppColors.greys60,
                borderRadius: BorderRadius.circular(36.w),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16).w,
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
                InkWell(
                  onTap: () {
                    widget.setDefaultCallback!(widget.filterName!);
                    Navigator.of(context).pop(false);
                  },
                  child: Text(
                    AppLocalizations.of(context)!.mStaticClearAll,
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      color: (widget.selectedItems!.length > 0)
                          ? AppColors.primaryBlue
                          : AppColors.greys60,
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              children: [
                const Divider(
                  color: AppColors.grey08,
                  thickness: 2,
                ),
              ],
            ),
          ),
          _filterItems(),
        ],
      ),
    );
  }

  Widget _filterItems() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16).w,
            child: Text(
              widget.filterName!,
              style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                  color: AppColors.greys87),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 32).w,
            child: Column(
              children: List.generate(
                  widget.items!.length,
                  (index) => Container(
                        alignment: FractionalOffset.centerLeft,
                        child: InkWell(
                          onTap: () {
                            _updateFilter(index);
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Checkbox(
                                side: const BorderSide(
                                    color: AppColors.black40, width: 1),
                                activeColor: AppColors.darkBlue,
                                value: (widget.selectedItems!.contains(
                                        (widget.items![index] ?? '')
                                            .toString()
                                            .toLowerCase())
                                    ? true
                                    : false),
                                onChanged: (value) {
                                  _updateFilter(index);
                                },
                              ),
                              Text(
                                Helper.capitalize(widget.items![index]
                                    .toString()
                                    .toLowerCase()),
                                style: GoogleFonts.lato(
                                  fontSize: 14.0.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.greys60,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomNavigationView() {
    return Container(
      padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16).w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            width: 0.34.sw,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.appBarBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.w),
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
            width: 0.34.sw,
            child: ElevatedButton(
              onPressed: () {
                widget.applyFilters!(widget.filterName!);
                Navigator.of(context).pop(false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                side: const BorderSide(color: AppColors.darkBlue, width: 1),
              ),
              child: Text(
                AppLocalizations.of(context)!
                    .mCompetenciesContentTypeApplyFilters,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.appBarBackground,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
