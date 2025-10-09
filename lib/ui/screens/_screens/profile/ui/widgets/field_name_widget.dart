import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../../constants/index.dart';

class FieldNameWidget extends StatelessWidget {
  final bool isMandatory;
  final String fieldName;
  final bool isApproved;
  final bool isInReview;
  final bool isNeedsApproval;
  final bool isApprovalField;
  final TextStyle? fieldTheme;
  const FieldNameWidget(
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
      padding: const EdgeInsets.only(top: 16).r,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          !isMandatory
              ? SizedBox(
                  width: isApprovalField ? 0.7.sw : 0.8.sw,
                  child: Text(
                    fieldName,
                    style: fieldTheme != null
                        ? fieldTheme
                        : Theme.of(context).textTheme.displayLarge,
                  ),
                )
              : SizedBox(
                  width: isApprovalField ? 0.7.sw : 0.8.sw,
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
          isApprovalField
              ? SvgPicture.asset(
                  isApproved && !isInReview
                      ? 'assets/img/approved.svg'
                      : isInReview
                          ? 'assets/img/sent_for_approval.svg'
                          : 'assets/img/needs_approval.svg',
                  width: 22.w,
                  height: 22.w,
                )
              : SizedBox()
        ],
      ),
    );
  }
}
