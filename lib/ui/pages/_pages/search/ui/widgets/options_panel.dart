import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../constants/index.dart';

class OptionsPanel extends StatelessWidget {
  final bool hasActiveFilters;
  final VoidCallback filterCallback;
  final VoidCallback sortCallback;

  const OptionsPanel(
      {super.key,
      required this.hasActiveFilters,
      required this.filterCallback,
      required this.sortCallback});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        InkWell(
          onTap: () {
            sortCallback();
          },
          child: Container(
            width: 0.5.sw - 1.w,
            padding: EdgeInsets.symmetric(vertical: 16.r),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.sort, color: AppColors.greys60, size: 20.sp),
              Text(AppLocalizations.of(context)!.mSearchSort,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium!
                      .copyWith(color: AppColors.disabledGrey)),
            ]),
          ),
        ),
        Container(
          width: 2.w,
          height: 30.w,
          color: AppColors.grey08,
        ),
        InkWell(
          onTap: () {
            filterCallback();
          },
          child: Container(
            width: 0.5.sw - 1.w,
            padding: EdgeInsets.symmetric(vertical: 16.r),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.filter_list,
                  color:
                      hasActiveFilters ? AppColors.darkBlue : AppColors.greys60,
                  size: 20.sp),
              Text(AppLocalizations.of(context)!.mSearchFilter,
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: hasActiveFilters
                          ? AppColors.darkBlue
                          : AppColors.disabledGrey)),
              hasActiveFilters
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 12).r,
                      child: Icon(
                        Icons.circle,
                        size: 10.sp,
                        color: AppColors.negativeLight,
                      ),
                    )
                  : SizedBox()
            ]),
          ),
        ),
      ],
    );
  }
}
