import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../constants/_constants/color_constants.dart';
import '../../../../feedback/constants.dart';
import '../../../../models/_models/leaderboard_model.dart';
import '../../../../util/helper.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';

class LeaderboardRankHolderWidget extends StatelessWidget {
  final List<LeaderboardModel> leaderboardDataList;
  LeaderboardRankHolderWidget({Key? key, required this.leaderboardDataList})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Flexible(
          child: Stack(
        alignment: Alignment.center,
        fit: StackFit.passthrough,
        children: [
          // Rank 2
          if (leaderboardDataList.length > 1)
            Positioned(
                left: 4.w,
                top: 44.w,
                child: leaderboardRankHolderWidget(
                    context,
                    leaderboardDataList[1],
                    false,
                    "2",
                    _isCurrentUser(leaderboardDataList[1].userId ?? ""))),
          // Rank 1
          if (leaderboardDataList.length > 0)
            Positioned(
                top: 28.w,
                child: leaderboardRankHolderWidget(
                    context,
                    leaderboardDataList[0],
                    true,
                    "1",
                    _isCurrentUser(leaderboardDataList[0].userId ?? ""))),
          // Rank 3
          if (leaderboardDataList.length > 2)
            Positioned(
                right: 4.w,
                top: 44.w,
                child: leaderboardRankHolderWidget(
                    context,
                    leaderboardDataList[2],
                    false,
                    "3",
                    _isCurrentUser(leaderboardDataList[2].userId ?? ""))),
        ],
      )),
    );
  }

  Widget leaderboardRankHolderWidget(
      BuildContext context,
      LeaderboardModel leaderboardData,
      bool showCrown,
      String rank,
      Future<bool> isCurrentUser) {
    return Column(
      children: [
        FutureBuilder<bool>(
          future: isCurrentUser,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              bool _isCurrentUser = snapshot.data as bool;
              return Container(
                  margin: EdgeInsets.only(bottom: 2).w,
                  decoration: BoxDecoration(
                    color: AppColors.appBarBackground,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Container(
                      padding: EdgeInsets.fromLTRB(2, 2, 2, 2).w,
                      decoration: BoxDecoration(
                        color: _isCurrentUser
                            ? AppColors.orangeShadow.withValues(alpha: 0.4)
                            : AppColors.appBarBackground,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: SizedBox(
                        height: 0.34.sw,
                        width: 0.3.sw - 20.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Stack(
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(0, 16, 0, 0).w,
                                  child: ((leaderboardData.profileImage ??
                                              '') !=
                                          '')
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(63).w,
                                          child: Image(
                                            height: 32.w,
                                            width: 32.w,
                                            fit: BoxFit.fitWidth,
                                            image: NetworkImage(
                                                leaderboardData.profileImage ??
                                                    ''),
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    SizedBox.shrink(),
                                          ),
                                        )
                                      : Container(
                                          height: 32.w,
                                          width: 32.w,
                                          decoration: BoxDecoration(
                                            color: AppColors.networkBg[Random()
                                                .nextInt(AppColors
                                                    .networkBg.length)],
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              Helper.getInitialsNew(
                                                  leaderboardData.fullname ??
                                                      ""),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displaySmall!
                                                  .copyWith(
                                                    fontSize: 12.sp,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ),
                                        ),
                                ),
                                if (showCrown)
                                  Positioned(
                                      top: 0.w,
                                      child: SizedBox(
                                        width: 32.w,
                                        height: 32.w,
                                        child: Image.asset(
                                          WallOfFameAssets.crown,
                                          fit: BoxFit.cover,
                                        ),
                                      )),
                              ],
                            ),
                            SizedBox(height: 4.w),
                            Wrap(
                              children: [
                                Text(
                                  leaderboardData.fullname ?? "",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium!
                                      .copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            SizedBox(height: 4.w),
                            Container(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 0.3.sw - 60.w,
                                    child: Wrap(
                                      alignment: WrapAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(1),
                                          child: SvgPicture.asset(
                                            'assets/img/kp_icon.svg',
                                            width: 18.w,
                                            height: 18.w,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(1),
                                          child: Text(
                                            '${(leaderboardData.totalPoints ?? 0).toString()}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge!
                                                .copyWith(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            if ((leaderboardData.rank !=
                                    leaderboardData.previousRank) &&
                                _isCurrentUser)
                              Container(
                                margin: EdgeInsets.only(top: 4.w),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    (leaderboardData.rank <
                                            leaderboardData.previousRank)
                                        ? Icon(
                                            Icons.arrow_drop_up,
                                            size: 16.sp,
                                            color: AppColors.positiveLight,
                                          )
                                        : Icon(
                                            Icons.arrow_drop_down,
                                            size: 16.sp,
                                            color: AppColors.negativeLight,
                                          ),
                                    (leaderboardData.rank <
                                            leaderboardData.previousRank)
                                        ? Text(
                                            '${leaderboardData.previousRank - leaderboardData.rank}',
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.lato(
                                                color: AppColors.positiveLight,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 10.sp,
                                                letterSpacing: 0.25.r,
                                                height: 1.3.w))
                                        : Text(
                                            '${leaderboardData.rank - leaderboardData.previousRank}',
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.lato(
                                                color: AppColors.negativeLight,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 10.sp,
                                                letterSpacing: 0.25,
                                                height: 1.3.w))
                                  ],
                                ),
                              ),
                          ],
                        ),
                      )));
            } else {
              return Container();
            }
          },
        ),
      ],
    );
  }

  Future<bool> _isCurrentUser(String userId) async {
    final _storage = FlutterSecureStorage();
    var _userId = await _storage.read(key: Storage.wid);
    if (userId.toString() == _userId.toString()) {
      return true;
    }
    return false;
  }
}
