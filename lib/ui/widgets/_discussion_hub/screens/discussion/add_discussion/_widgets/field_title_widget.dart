import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';

class FieldTitleWidget extends StatelessWidget {
  final bool isMandatory;
  final String fieldName;
  const FieldTitleWidget(
      {Key? key, this.isMandatory = false, required this.fieldName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8).r,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          !isMandatory
              ? Text(
                  fieldName,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: AppColors.greys87,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                      ),
                )
              : RichText(
                  text: TextSpan(
                      text: fieldName,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: AppColors.greys87,
                            fontWeight: FontWeight.w700,
                            fontSize: 14.sp,
                          ),
                      children: [
                        TextSpan(
                            text: ' *',
                            style: TextStyle(
                                color: AppColors.mandatoryRed,
                                fontWeight: FontWeight.w600,
                                fontSize: 16.sp))
                      ]),
                ),
        ],
      ),
    );
  }
}
