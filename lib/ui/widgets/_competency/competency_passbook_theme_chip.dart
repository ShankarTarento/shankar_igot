import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';

class CompetencyPassbookThemeChipsWidget extends StatelessWidget {
  final String chipText;
  const CompetencyPassbookThemeChipsWidget({Key? key, required this.chipText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8).r,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20).r,
          border: Border.all(width: 2, color: AppColors.darkBlue)),
      child: Text(
        chipText,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 12.sp),
      ),
    );
  }
}
