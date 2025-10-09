import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_models/multilingual_text.dart';

class FilterPills extends StatefulWidget {
  final MultiLingualText? filter;
  final String? filterText;
  final bool isSelected;
  final String? count;
  final double? fontSize;
  final Function(MultiLingualText filter)? onClickedPill;
  final Function(String filterText)? onClickedFilterText;

  const FilterPills({
    super.key,
    this.filter,
    this.fontSize,
    this.filterText,
    required this.isSelected,
    this.onClickedPill,
    this.onClickedFilterText,
    this.count,
  }) : assert(
            (filter != null && onClickedPill != null) ||
                (filterText != null && onClickedFilterText != null),
            'Either filter and onClickedPill, or filterText and onClickedFilterText must be provided.');

  @override
  _FilterPillsState createState() => _FilterPillsState();
}

class _FilterPillsState extends State<FilterPills> {
  @override
  Widget build(BuildContext context) {
    return _buildTabPill();
  }

  Widget _buildTabPill() {
    String pillText = widget.filter?.getText(context) ?? widget.filterText!;

    return InkWell(
      onTap: () {
        if (widget.filter != null) {
          widget.onClickedPill!(widget.filter!);
        } else if (widget.filterText != null) {
          widget.onClickedFilterText!(widget.filterText!);
        }
      },
      child: Container(
        margin: EdgeInsets.only(right: 16).r,
        padding: EdgeInsets.only(left: 14, right: 14, top: 6, bottom: 6).r,
        decoration: BoxDecoration(
          color: widget.isSelected ? AppColors.darkBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(40).r,
          border: Border.all(
            color: widget.isSelected ? AppColors.darkBlue : AppColors.grey24,
          ),
        ),
        child: Text(
          "$pillText" + (widget.count != null ? " (${widget.count})" : ""),
          style: GoogleFonts.lato(
            fontSize: widget.fontSize ?? 13.sp,
            fontWeight: FontWeight.w400,
            color: widget.isSelected
                ? AppColors.appBarBackground
                : AppColors.greys60,
          ),
        ),
      ),
    );
  }
}
