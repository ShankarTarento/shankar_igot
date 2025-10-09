import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DropDownSelection extends StatelessWidget {
  final List options;
  final dynamic selectedValue;
  final Function(dynamic) onChanged;
  final IconData icon;
  final Color iconColor;
  final InputBorder? border;
  final EdgeInsetsGeometry? padding;
  DropDownSelection(
      {Key? key,
      required this.options,
      this.selectedValue,
      required this.onChanged,
      this.icon = Icons.keyboard_arrow_down_sharp,
      this.iconColor = AppColors.grey40,
      this.border,
      this.padding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.only(top: 8.0, bottom: 8).r,
      child: DropdownButtonFormField(
        //  underline: SizedBox(),
        decoration: InputDecoration(
          contentPadding:
              EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          border: border ??
              OutlineInputBorder(
                borderRadius: BorderRadius.circular(4).r,
                borderSide: BorderSide(
                  color: AppColors.grey24,
                  width: 1,
                ),
              ),
          enabledBorder: border ??
              OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.r),
                borderSide: BorderSide(
                  color: AppColors.grey24,
                  width: 1,
                ),
              ),
          focusedBorder: border ??
              OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.r),
                borderSide: BorderSide(
                  color: AppColors.darkBlue,
                  width: 2,
                ),
              ),
        ),
        hint: Text(
          AppLocalizations.of(context)!.mStaticSelectFromDropdown,
          style: GoogleFonts.lato(fontSize: 14.sp),
        ),
        icon: Icon(
          icon,
          color: iconColor,
        ),
        isExpanded: true,
        menuMaxHeight: 350.w,
        value: selectedValue != null && selectedValue.isNotEmpty
            ? selectedValue.toString().toUpperCase()
            : null,
        items: options.map((menuItem) {
          return DropdownMenuItem(
              value: menuItem.toString().toUpperCase(),
              child: Text(menuItem.toString(),
                  style: GoogleFonts.lato(
                      fontSize: 14.sp,
                      color: menuItem == selectedValue
                          ? AppColors.darkBlue
                          : AppColors.greys)));
        }).toList(),
        selectedItemBuilder: (BuildContext context) {
          return options.map((menuItem) {
            return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    menuItem.toString(),
                    style: GoogleFonts.lato(
                      fontSize: 14.sp,
                      color: AppColors.greys,
                    ),
                  ),
                ]);
          }).toList();
        },
        onChanged: onChanged,
      ),
    );
  }
}
