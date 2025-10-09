import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/home_screen_components/models/learn_tab_model.dart';

class FilterDropdown extends StatelessWidget {
  final FilterItems? selectedFilterItem;
  final List<FilterItems> filterItems;
  final Function(FilterItems) onchanged;
  const FilterDropdown(
      {super.key,
      required this.selectedFilterItem,
      required this.filterItems,
      required this.onchanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButton2(
      style: GoogleFonts.lato(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.greys87,
      ),
      underline: SizedBox(),
      buttonStyleData: ButtonStyleData(
        height: 40.w,
        width: 0.6.sw,
        padding: const EdgeInsets.symmetric(horizontal: 10).r,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(60),
          border: Border.all(color: AppColors.grey16),
          color: AppColors.appBarBackground,
        ),
      ),
      iconStyleData: IconStyleData(
        icon: Icon(Icons.arrow_drop_down),
        iconSize: 20.sp,
        iconEnabledColor: AppColors.greys,
      ),
      value: selectedFilterItem,
      selectedItemBuilder: (context) => List.generate(
        filterItems.length,
        (index) => Center(
          child: SizedBox(
            width: 0.48.sw,
            child: Text(
              filterItems[index].filterTitle.getText(context),
              style: GoogleFonts.lato(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.greys87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
      items: List.generate(
        filterItems.length,
        (index) => DropdownMenuItem(
          value: filterItems[index],
          child: Text(
            filterItems[index].filterTitle.getText(context),
            style: selectedFilterItem == filterItems[index]
                ? GoogleFonts.lato(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkBlue,
                  )
                : GoogleFonts.lato(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.greys87,
                  ),
          ),
        ),
      ),
      dropdownStyleData: DropdownStyleData(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8).w,
          color: AppColors.appBarBackground,
        ),
        offset: const Offset(0, -5),
      ),
      onChanged: (value) {
        onchanged(value!);
      },
    );
  }
}
