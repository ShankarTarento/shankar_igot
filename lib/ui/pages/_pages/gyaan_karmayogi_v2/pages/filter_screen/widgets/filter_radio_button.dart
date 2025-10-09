import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/utils/helper.dart';
import 'package:igot_ui_components/utils/module_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_models/gyaan_karmayogi_category_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FilterRadioButtonV2 extends StatefulWidget {
  final String title;
  final List<FilterModel> checkListItems;
  final ValueChanged<String> onChanged;
  final String searchHint;
  final String? selectedItem;

  const FilterRadioButtonV2({
    super.key,
    required this.title,
    this.selectedItem,
    required this.searchHint,
    required this.checkListItems,
    required this.onChanged,
  });

  @override
  State<FilterRadioButtonV2> createState() => _FilterRadioButtonV2State();
}

class _FilterRadioButtonV2State extends State<FilterRadioButtonV2> {
  List<FilterModel> filteredItems = [];
  String? selectedItem;
  bool showAll = false;
  @override
  void initState() {
    super.initState();
    filteredItems = widget.checkListItems;
    selectedItem = widget.selectedItem;
  }

  void _filterList(String query) {
    setState(() {
      filteredItems = widget.checkListItems
          .where(
              (item) => item.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 16.w,
        ),
        Text(
          widget.title,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(
          height: 12.w,
        ),
        SizedBox(
          height: 45.w,
          width: 1.sw,
          child: TextField(
            onChanged: _filterList,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.appBarBackground,
              border: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: ModuleColors.grey08, width: 1),
                borderRadius: BorderRadius.circular(40.0).r,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: ModuleColors.grey08, width: 1),
                borderRadius: BorderRadius.circular(40.0).r,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: ModuleColors.grey08, width: 1),
                borderRadius: BorderRadius.circular(40.0).r,
              ),
              contentPadding: const EdgeInsets.only(left: 12, right: 12).r,
              hintText: widget.searchHint,
              prefixIcon: Icon(
                Icons.search,
                color: ModuleColors.greys87,
                size: 24.sp,
              ),
              hintStyle: GoogleFonts.lato(
                fontSize: 12.sp,
                color: ModuleColors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 16.w,
        ),
        Column(
          children: List.generate(
            filteredItems.length > 5 && !showAll ? 5 : filteredItems.length,
            (index) => InkWell(
              onTap: () {
                setState(() {
                  selectedItem = filteredItems[index].title;
                });
                widget.onChanged(selectedItem!);
              },
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.only(bottom: 25).r,
                height: 20.w,
                child: Row(
                  children: [
                    Radio(
                      value: filteredItems[index].title,
                      groupValue: selectedItem,
                      onChanged: (String? value) {
                        setState(() {
                          selectedItem = value!;
                        });
                        widget.onChanged(value!);
                      },
                      fillColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.selected)) {
                            return ModuleColors.darkBlue;
                          }
                          return ModuleColors.black40;
                        },
                      ),
                      //  ),                      //activeColor: ModuleColors.darkBlue,
                    ),
                    Text(
                      ModuleHelper.capitalize(filteredItems[index].title),
                      style: GoogleFonts.lato(
                        fontSize: 14.0.sp,
                        fontWeight: FontWeight.w700,
                        color: ModuleColors.greys60,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        filteredItems.length > 5
            ? TextButton(
                onPressed: () {
                  showAll = showAll ? false : true;
                  setState(() {});
                },
                style: TextButton.styleFrom(
                  splashFactory: NoSplash.splashFactory,
                ),
                child: Text(
                  showAll
                      ? AppLocalizations.of(context)!.mCompetencyViewLessTxt
                      : AppLocalizations.of(context)!.mStaticViewAll,
                  style: GoogleFonts.lato(
                      color: AppColors.darkBlue,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600),
                ))
            : SizedBox(),
        SizedBox(
          height: 16.w,
        )
      ],
    );
  }
}
