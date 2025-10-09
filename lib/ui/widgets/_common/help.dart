import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../constants/index.dart';
import '../../../util/faderoute.dart';
import '../_signup/contact_us.dart';

class HelpWidget extends StatelessWidget {
  const HelpWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          FadeRoute(page: ContactUs()),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 8).w,
        child: SvgPicture.asset(
          'assets/img/help_icon.svg',
          fit: BoxFit.fill,
          colorFilter: ColorFilter.mode(
              AppColors.deepBlue, BlendMode.srcIn),
          width: 50.0.w,
          height: 50.0.w,
        ),
      ),
    );
  }
}