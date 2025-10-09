import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/index.dart';

class DropDownSelectionKeyValue extends StatelessWidget {
  final text;
  final List options;
  final dynamic selectedValue;
  final Function(dynamic) onChanged;
  final IconData icon;
  final Color iconColor;
  final double borderRadius;
  DropDownSelectionKeyValue({
    Key? key,
    this.text,
    required this.options,
    this.selectedValue,
    required this.onChanged,
    this.icon = Icons.keyboard_arrow_down_sharp,
    this.iconColor = AppColors.grey40,
    this.borderRadius = 4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8).r,
      padding: EdgeInsets.only(left: 16, right: 8).r,
      decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey16),
          borderRadius: BorderRadius.circular(borderRadius).r),
      child: DropdownButton(
        underline: SizedBox(),
        hint: Text(
          text,
          style: GoogleFonts.lato(fontSize: 14.sp),
        ),
        icon: Icon(
          icon,
          color: iconColor,
        ),
        isExpanded: true,
        menuMaxHeight: 350.w,
        value: selectedValue != null ? selectedValue : null,
        items: options.map((menuItem) {
          return DropdownMenuItem(
              value: menuItem,
              child: Text(menuItem.name.toString(),
                  style: GoogleFonts.lato(
                      fontSize: 14.sp,
                      color: selectedValue == menuItem
                          ? AppColors.darkBlue
                          : AppColors.greys)));
        }).toList(),
        selectedItemBuilder: (BuildContext context) {
          return options.map((menuItem) {
            return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    menuItem.name.toString(),
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
