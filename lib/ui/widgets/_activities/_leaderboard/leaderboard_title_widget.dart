import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/utils/profile_constants.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import '../../../../constants/index.dart';
import '../../../screens/_screens/profile/model/profile_dashboard_arg_model.dart';
import '../../index.dart';

class LeaderboardTitleWidget extends StatelessWidget {
  final String? rank;

  const LeaderboardTitleWidget({Key? key, this.rank}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, AppUrl.profileDashboard,
              arguments: ProfileDashboardArgModel(
                  type: ProfileConstants.currentUser, showMyActivity: true));
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppLocalizations.of(context)!.mLeaderboard,
                    style: GoogleFonts.lato(
                      color: AppColors.greys87,
                      fontWeight: FontWeight.w400,
                      fontSize: 12.sp,
                      letterSpacing: 0.12,
                    )),
                SizedBox(width: 8.w),
                TooltipWidget(
                    message: AppLocalizations.of(context)!
                        .mMyActivityLeaderboardTooltipInfo,
                    iconColor: AppColors.darkBlue,
                    icon: Icons.info)
              ],
            ),
            SizedBox(
              height: 8.w,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                getImage('assets/img/leaderboard_icon.svg'),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    '${Helper.numberWithSuffix(int.parse(rank ?? '0'))} ${AppLocalizations.of(context)!.mRank}',
                    style: GoogleFonts.lato(
                      color: AppColors.greys87,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                      letterSpacing: 0.12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget getImage(imagePath) {
    return SvgPicture.asset(
      imagePath,
      width: 24.w,
      height: 26.w,
    );
  }
}
