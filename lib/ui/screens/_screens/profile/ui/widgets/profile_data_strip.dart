import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../../../../constants/index.dart';
import '../../../../../../respositories/_respositories/settings_repository.dart';
import '../../../../../pages/_pages/my_learnings/my_learning_v2.dart/my_learning_v2.dart';
import '../../../../../widgets/index.dart';

class ProfileDataStrip extends StatelessWidget {
  final int karmapoint;
  final int certificateCount;
  final int postCount;

  const ProfileDataStrip(
      {Key? key,
      required this.karmapoint,
      required this.certificateCount,
      required this.postCount})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isTablet =
        Provider.of<SettingsRepository>(context, listen: false).itsTablet;
    return Padding(
        padding: const EdgeInsets.all(8.0).r,
        child: GridView(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8.r,
              childAspectRatio: isTablet ? 3.7 : 1.7,
            ),
            shrinkWrap: true,
            children: [
              InkWell(
                onTap: karmapoint > 0
                    ? () =>
                        Navigator.pushNamed(context, AppUrl.karmapointOverview)
                    : null,
                child: Container(
                    width: 0.3.sw,
                    padding: EdgeInsets.all(8).r,
                    color: AppColors.appBarBackground,
                    child: Column(
                      children: [
                        CaptionWidget(
                            context,
                            AppLocalizations.of(context)!.mProfileMyKarmaPoints,
                            karmapoint),
                        Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SvgPicture.asset(
                              'assets/img/kp_icon.svg',
                              width: 32.w,
                              height: 32.w,
                            ),
                            SizedBox(width: 8.w),
                            Text(karmapoint.toString(),
                                style: Theme.of(context).textTheme.displayLarge)
                          ],
                        )
                      ],
                    )),
              ),
              InkWell(
                onTap: certificateCount > 0
                    ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => MyLearningV2(
                                  drawerKey: drawerKey,
                                  profileParentAction: () {},
                                  tabIndex: 0,
                                  pillIndex: 1)),
                        );
                      }
                    : null,
                child: Container(
                    width: 0.3.sw,
                    padding: EdgeInsets.all(8).r,
                    color: AppColors.appBarBackground,
                    child: Column(
                      children: [
                        CaptionWidget(
                            context,
                            AppLocalizations.of(context)!
                                .mProfileMyCertificates,
                            certificateCount),
                        Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SvgPicture.asset(
                              'assets/img/certificate_icon.svg',
                              width: 32.w,
                              height: 24.w,
                            ),
                            SizedBox(width: 8.w),
                            Text(certificateCount.toString(),
                                style: Theme.of(context).textTheme.displayLarge)
                          ],
                        )
                      ],
                    )),
              ),
              InkWell(
                onTap: postCount > 0
                    ? () => Navigator.pushNamed(context, AppUrl.discussionHub)
                    : null,
                child: Container(
                    width: 0.3.sw,
                    padding: EdgeInsets.all(8).r,
                    color: AppColors.appBarBackground,
                    child: Column(
                      children: [
                        CaptionWidget(
                            context,
                            AppLocalizations.of(context)!.mProfileMyPosts,
                            postCount),
                        Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.forum,
                                size: 24.w, color: AppColors.orangeTourText),
                            SizedBox(width: 8.w),
                            Text(postCount.toString(),
                                style: Theme.of(context).textTheme.displayLarge)
                          ],
                        )
                      ],
                    )),
              )
            ]));
  }

  Row CaptionWidget(BuildContext context, String text, int count) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      SizedBox(
        width: 0.225.sw,
        child: Text(text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .labelSmall!
                .copyWith(fontWeight: FontWeight.w900, color: AppColors.greys)),
      ),
      if (count > 0)
        Icon(Icons.arrow_forward_ios, size: 8.sp, color: AppColors.darkBlue)
    ]);
  }
}
