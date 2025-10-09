import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../../../constants/index.dart';
import '../../tooltip_widget.dart';

class RewardMessageCards extends StatelessWidget {
  final String textOne;
  final String textTwo;
  final String description;
  const RewardMessageCards({
    Key? key,
    required this.textOne,
    required this.textTwo,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return messageWidget();
  }

  Container messageWidget() {
    return Container(
      padding: EdgeInsets.all(16).r,
      decoration: BoxDecoration(
          color: AppColors.verifiedBadgeIconColor.withValues(alpha: 0.08),
          border: Border.all(
            color: AppColors.verifiedBadgeIconColor,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8).r),
      child: Row(children: [
        SvgPicture.asset(
          'assets/img/kp_icon.svg',
          alignment: Alignment.center,
          height: 32.w,
          width: 32.w,
          fit: BoxFit.contain,
        ),
        SizedBox(
          width: 16.w,
        ),
        Flexible(
          child: RichText(
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                textWidget(textOne, FontWeight.w900),
                textWidget("$textTwo", FontWeight.w400),
              ],
            ),
          ),
        ),
        if (description.isNotEmpty)
          Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: TooltipWidget(
                message: description,
              ))
      ]),
    );
  }

  TextSpan textWidget(String message, FontWeight font,
      {Color color = AppColors.greys87, double fontSize = 12}) {
    return TextSpan(
      text: message,
      style: TextStyle(
          color: color,
          fontSize: fontSize.sp,
          fontWeight: font,
          letterSpacing: 0.25),
    );
  }
}
