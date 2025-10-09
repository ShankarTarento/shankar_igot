import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../../constants/index.dart';

class FieldNameV2Widget extends StatelessWidget {
  final bool isMandatory;
  final String fieldName;
  final bool isApproved;
  final bool isInReview;
  final bool isNeedsApproval;
  final bool isApprovalField;
  final TextStyle? fieldTheme;
  const FieldNameV2Widget(
      {Key? key,
      this.isMandatory = false,
      required this.fieldName,
      this.isApproved = false,
      this.isInReview = false,
      this.isNeedsApproval = false,
      this.isApprovalField = false,
      this.fieldTheme})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4).r,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: !isMandatory
                ? SizedBox(
                    child: Text(
                      fieldName,
                      style: fieldTheme != null
                          ? fieldTheme
                          : Theme.of(context).textTheme.displayLarge,
                    ),
                  )
                : SizedBox(
                    child: RichText(
                      text: TextSpan(
                          text: fieldName,
                          style: fieldTheme != null
                              ? fieldTheme
                              : Theme.of(context).textTheme.displayLarge,
                          children: [
                            TextSpan(
                                text: ' *',
                                style: TextStyle(
                                    color: AppColors.mandatoryRed,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16.sp))
                          ]),
                    ),
                  ),
          ),
          if (isApprovalField)
            Padding(
              padding: EdgeInsets.only(left: 4, right: 4),
              child: SvgPicture.asset(
                isApproved && !isInReview
                    ? 'assets/img/approved.svg'
                    : isInReview
                        ? 'assets/img/sent_for_approval.svg'
                        : 'assets/img/needs_approval.svg',
                width: 16.w,
                height: 16.w,
              ),
            )
        ],
      ),
    );
  }
}
