import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:karmayogi_mobile/ui/widgets/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../constants/index.dart';
import '../../../models/index.dart';
import '../../../util/faderoute.dart';
import '../../widgets/_signup/contact_us.dart';

class RecommendedLearningShowallScreen extends StatelessWidget {
  final RecommendedLearningModel arguments;

  const RecommendedLearningShowallScreen({super.key, required this.arguments});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteGradientOne,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(70.w),
          child: AppBar(
            titleSpacing: 0,
            toolbarHeight: 70.w,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.arrow_back_ios,
                        size: 24, color: AppColors.greys87)),
                Padding(
                  padding: const EdgeInsets.only(left: 16).r,
                  child: Text(
                      AppLocalizations.of(context)!
                          .mMySpacePeerLearning,
                      style: Theme.of(context).textTheme.displayLarge),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      FadeRoute(page: ContactUs()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 0, 8).r,
                    child: SvgPicture.asset(
                      'assets/img/help_icon.svg',
                      width: 56.0.w,
                      height: 56.0.w,
                    ),
                  ),
                ),
              ],
            ),
          )),
      body: RecommendedLearningWidget(
          availableCourses: arguments.availableCourses,
          inprogressCourses: arguments.inprogressCourses,
          completedCourses: arguments.completedCourses,
          showAll: arguments.showAll,
          parentContext: context),
    );
  }
}
