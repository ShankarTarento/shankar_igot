import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_models/mdo_leaderboard.dart';

class MdoLeaderboardCard extends StatelessWidget {
  final MDOLeaderboardData leaderboardData;
  final Color backgroundColor;
  final Color textColor;
  const MdoLeaderboardCard({
    super.key,
    required this.leaderboardData,
    this.backgroundColor = AppColors.appBarBackground,
    this.textColor = AppColors.greys,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(16).r,
          margin: EdgeInsets.only(left: 16, right: 16, top: 16).r,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12).r,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 32.w,
                width: 32.w,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: leaderboardData.rowNum != 1 &&
                              leaderboardData.rowNum != 2 &&
                              leaderboardData.rowNum != 3
                          ? AppColors.grey40
                          : Colors.transparent),
                  borderRadius: BorderRadius.circular(30.r),
                  color: leaderboardData.rowNum == 1
                      ? AppColors.yellow3
                      : leaderboardData.rowNum == 2
                          ? AppColors.darkBlue
                          : leaderboardData.rowNum == 3
                              ? AppColors.primaryOne
                              : AppColors.appBarBackground,
                ),
                child: Center(
                  child: Text(
                    '${leaderboardData.rowNum}',
                    style: GoogleFonts.lato(
                        color: AppColors.greys, fontSize: 14.sp),
                  ),
                ),
              ),
              SizedBox(
                width: 10.w,
              ),
              SizedBox(
                width: leaderboardData.rowNum != 1 &&
                        leaderboardData.rowNum != 2 &&
                        leaderboardData.rowNum != 3
                    ? 0.57.sw
                    : 0.5.sw,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      leaderboardData.orgName ?? "",
                      style: GoogleFonts.montserrat(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(
                      height: 8.w,
                    ),
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/img/kp_icon.svg',
                          width: 32.w,
                          height: 32.w,
                        ),
                        SizedBox(
                          width: 8.w,
                        ),
                        Text(
                          '${leaderboardData.totalPoints ?? 0} points',
                          style: GoogleFonts.montserrat(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: textColor,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Spacer(),
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        colorFilter: ColorFilter.mode(
                            leaderboardData.rowNum == 1
                                ?AppColors.yellow3
                                : leaderboardData.rowNum == 2
                                    ? AppColors.darkBlue
                                    : leaderboardData.rowNum == 3
                                        ? AppColors.primaryOne
                                        : AppColors.appBarBackground,
                            BlendMode.srcIn),
                        image: AssetImage('assets/img/Medal.png'))),
                child: Image.asset('assets/img/crown.png',
                    width: 9.w, height: 6.w, color: AppColors.appBarBackground),
              ),
            ],
          ),
        ),
        leaderboardData.rowNum == 1
            ? SvgPicture.asset(
                'assets/img/Crown.svg',
                width: 38.w,
                height: 38.w,
              )
            : SizedBox(),
      ],
    );
  }
}
