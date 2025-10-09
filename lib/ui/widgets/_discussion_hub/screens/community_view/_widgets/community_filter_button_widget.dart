import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';

class CommunityFilterButtonWidget extends StatelessWidget {

  final double width;
  final double height;
  final BorderRadiusGeometry? borderRadius;
  final Function? onTap;
  final bool? isFiltered;

  const CommunityFilterButtonWidget({super.key, required this.width, required this.height, this.borderRadius, this.onTap, this.isFiltered});

  @override
  Widget build(BuildContext context) {
    return _filterView();
  }

  Widget _filterView() {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: borderRadius ??  BorderRadius.all(Radius.circular(8.w)),
        border: Border.all(color: AppColors.darkBlue),
      ),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              if (onTap != null)
                onTap!();
            },
            child: Icon(
              Icons.filter_alt_outlined,
              size: 24.w,
              color: AppColors.darkBlue,
            ),
          ),
          if (isFiltered??false)
            _filterIndicator()
        ],
      ),
    );
  }

  Widget _filterIndicator() {
    return Positioned(
        top: 0,
        right: 0,
        child: Icon(
          Icons.circle,
          size: 10.sp,
          color: AppColors.negativeLight,
        )
    );
  }

}
