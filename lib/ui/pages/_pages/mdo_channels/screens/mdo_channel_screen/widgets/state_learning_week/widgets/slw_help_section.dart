import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';

class SlwHelpSection extends StatefulWidget {
  const SlwHelpSection({super.key});

  @override
  State<SlwHelpSection> createState() => _SlwHelpSectionState();
}

class _SlwHelpSectionState extends State<SlwHelpSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16).r,
          color: AppColors.darkBlue,
        )
      ],
    );
  }
}
