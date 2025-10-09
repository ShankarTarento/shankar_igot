import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/utils/profile_constants.dart';
import 'package:karmayogi_mobile/ui/widgets/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../constants/index.dart';
import '../../../util/telemetry_repository.dart';
import '../../screens/_screens/profile/model/profile_dashboard_arg_model.dart';

class WeeklyclapTitleWidget extends StatelessWidget {
  final Map<String, dynamic> weeklyClaps;
  final bool showInRow;
  final bool enableNavigationForWeeklyClaps;

  const WeeklyclapTitleWidget(
      {Key? key,
      required this.weeklyClaps,
      this.showInRow = false,
      this.enableNavigationForWeeklyClaps = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: showInRow
          ? InkWell(
              onTap: () {
                if (enableNavigationForWeeklyClaps) {
                  Navigator.pushNamed(context, AppUrl.profileDashboard,
                      arguments: ProfileDashboardArgModel(
                          type: ProfileConstants.currentUser,
                          showMyActivity:true));
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext contxt) {
                            return Center(
                              child: AlertDialog(
                                insetPadding:
                                    EdgeInsets.only(left: 17, right: 15).r,
                                titlePadding: EdgeInsets.zero,
                                contentPadding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12.0))
                                            .r),
                                title: Container(
                                    padding:
                                        EdgeInsets.fromLTRB(16, 24, 16, 24).r,
                                    width: 1.sw,
                                    decoration: BoxDecoration(
                                        color: AppColors.seaShell,
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(12),
                                            topRight: Radius.circular(12))),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        getImage('assets/img/clap_icon.svg'),
                                        SizedBox(height: 8.w),
                                        TitleBoldWidget(
                                          AppLocalizations.of(context)!
                                              .mStaticWhatIsWeeklyClaps,
                                          color: AppColors.darkBlue,
                                        ),
                                        SizedBox(height: 8.w),
                                        Text(
                                          AppLocalizations.of(context)!
                                              .mStaticWeeklyClapTitleDescription,
                                          textAlign: TextAlign.center,
                                          maxLines: 3,
                                          style: GoogleFonts.lato(
                                              color: AppColors.greys87,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14.sp,
                                              letterSpacing: 0.25.sp,
                                              height: 1.3.w),
                                        )
                                      ],
                                    )),
                                content: Container(
                                    width: 1.sw,
                                    padding:
                                        EdgeInsets.fromLTRB(16, 32, 16, 32).r,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 1.sw,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              getImage(
                                                  'assets/img/clap_icon.svg'),
                                              SizedBox(width: 12.w),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    TitleBoldWidget(
                                                      AppLocalizations.of(
                                                                  context)
                                                              ?.mStaticMaintainClaps ??
                                                          '',
                                                      maxLines: 2,
                                                    ),
                                                    SizedBox(height: 4.h),
                                                    RichText(
                                                      maxLines: 3,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textWidthBasis:
                                                          TextWidthBasis
                                                              .longestLine,
                                                      text: TextSpan(
                                                          style: GoogleFonts.lato(
                                                              color: AppColors
                                                                  .greys60,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 12.sp,
                                                              letterSpacing:
                                                                  0.25.sp,
                                                              height: 1.3.w),
                                                          children: <TextSpan>[
                                                            TextSpan(
                                                              text: AppLocalizations
                                                                      .of(context)
                                                                  ?.mStaticSpentAtleast,
                                                            ),
                                                            TextSpan(
                                                              text:
                                                                  ' $CLAP_DURATION ${AppLocalizations.of(context)!.mStaticMinutes}',
                                                              style: GoogleFonts.lato(
                                                                  color: AppColors
                                                                      .greys60,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontSize:
                                                                      12.sp,
                                                                  letterSpacing:
                                                                      0.25.sp,
                                                                  height:
                                                                      1.3.w),
                                                              children: <TextSpan>[
                                                                TextSpan(
                                                                  text: AppLocalizations.of(
                                                                          context)
                                                                      ?.mCommonSpendMinimum,
                                                                ),
                                                                TextSpan(
                                                                    text:
                                                                        ' $CLAP_DURATION ${AppLocalizations.of(context)!.mStaticMinutes} ',
                                                                    style:
                                                                        GoogleFonts
                                                                            .lato(
                                                                      color: AppColors
                                                                          .darkBlue,
                                                                    )),
                                                                TextSpan(
                                                                    text: AppLocalizations.of(
                                                                            context)
                                                                        ?.mStaticEngageWithPlatform)
                                                              ],
                                                            ),
                                                          ]),
                                                    )
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 40.w),
                                        Container(
                                          width: 1.sw,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              getImage(
                                                  'assets/img/clap_disable_icon.svg'),
                                              SizedBox(width: 12.w),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    TitleBoldWidget(
                                                      AppLocalizations.of(
                                                                  context)
                                                              ?.mStaticWhyDidLossClaps ??
                                                          '',
                                                      maxLines: 2,
                                                    ),
                                                    SizedBox(height: 4.w),
                                                    RichText(
                                                      maxLines: 3,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textWidthBasis:
                                                          TextWidthBasis
                                                              .longestLine,
                                                      text: TextSpan(
                                                        style: GoogleFonts.lato(
                                                            color: AppColors
                                                                .greys60,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 12.sp,
                                                            letterSpacing:
                                                                0.25.sp,
                                                            height: 1.3.w),
                                                        children: <TextSpan>[
                                                          TextSpan(
                                                            text: AppLocalizations
                                                                    .of(context)
                                                                ?.mStaticFallShort,
                                                          ),
                                                          TextSpan(
                                                              text:
                                                                  ' $CLAP_DURATION ${AppLocalizations.of(context)!.mStaticMinutes} ',
                                                              style: GoogleFonts
                                                                  .lato(
                                                                color: AppColors
                                                                    .darkBlue,
                                                              )),
                                                          TextSpan(
                                                              text: AppLocalizations
                                                                      .of(context)
                                                                  ?.mStaticEngagementRequirement)
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    )),
                              ),
                            );
                          });
                    },
                    child: Row(
                      children: [
                        SizedBox(
                          width: 85.w,
                          child: Text(
                            AppLocalizations.of(context)!.mStaticWeeklyClaps,
                            style: GoogleFonts.lato(
                              color: AppColors.greys87,
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp,
                              letterSpacing: 0.12.w,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(Icons.info, size: 16.sp, color: AppColors.darkBlue)
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      getImage(weeklyClaps.isNotEmpty &&
                              weeklyClaps['total_claps'] != null &&
                              weeklyClaps['total_claps'] != 0
                          ? 'assets/img/clap_icon.svg'
                          : 'assets/img/clap_disable_icon.svg'),
                      SizedBox(width: 8.w),
                      Text(
                          weeklyClaps.isNotEmpty &&
                                  weeklyClaps['total_claps'] != null
                              ? '${weeklyClaps['total_claps']} ${AppLocalizations.of(context)!.mStaticWeeks}'
                              : '0 (${AppLocalizations.of(context)!.mStaticWeeks})',
                          style: GoogleFonts.lato(
                            color: AppColors.greys87,
                            fontWeight: FontWeight.w700,
                            fontSize: 14.sp,
                            letterSpacing: 0.12.w,
                          ))
                    ],
                  )
                ],
              ))
          : InkWell(
              onTap: () {
                if (enableNavigationForWeeklyClaps) {
                  Navigator.pushNamed(context, AppUrl.profileDashboard,
                      arguments: ProfileDashboardArgModel(
                          type: ProfileConstants.currentUser,
                          showMyActivity: true));
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      _generateInteractTelemetryData(null,
                          edataId: TelemetryIdentifier.weeklyClapsInfo,
                          context: context);
                      showDialog(
                          context: context,
                          builder: (BuildContext contxt) {
                            return Center(
                              child: AlertDialog(
                                insetPadding:
                                    EdgeInsets.only(left: 17, right: 15).r,
                                titlePadding: EdgeInsets.zero,
                                contentPadding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(12.0).r)),
                                title: Container(
                                    padding:
                                        EdgeInsets.fromLTRB(16, 24, 16, 24).r,
                                    width: 1.sw,
                                    decoration: BoxDecoration(
                                        color: AppColors.seaShell,
                                        borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(12),
                                                topRight: Radius.circular(12))
                                            .r),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        getImage('assets/img/clap_icon.svg'),
                                        SizedBox(height: 8.w),
                                        TitleBoldWidget(
                                          AppLocalizations.of(context)!
                                              .mStaticWhatIsWeeklyClaps,
                                          color: AppColors.darkBlue,
                                        ),
                                        SizedBox(height: 8.w),
                                        Text(
                                          AppLocalizations.of(context)!
                                              .mStaticWeeklyClapTitleDescription,
                                          textAlign: TextAlign.center,
                                          maxLines: 3,
                                          style: GoogleFonts.lato(
                                              color: AppColors.greys87,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14.sp,
                                              letterSpacing: 0.25.r,
                                              height: 1.3.w),
                                        )
                                      ],
                                    )),
                                content: Container(
                                    width: 1.sw,
                                    padding:
                                        EdgeInsets.fromLTRB(16, 32, 16, 32).r,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 1.sw,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              getImage(
                                                  'assets/img/clap_icon.svg'),
                                              SizedBox(width: 12.w),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    TitleBoldWidget(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .mStaticMaintainClaps,
                                                      maxLines: 2,
                                                    ),
                                                    SizedBox(height: 4.w),
                                                    RichText(
                                                      maxLines: 3,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textWidthBasis:
                                                          TextWidthBasis
                                                              .longestLine,
                                                      text: TextSpan(
                                                        style: GoogleFonts.lato(
                                                            color: AppColors
                                                                .greys60,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 12.sp,
                                                            letterSpacing:
                                                                0.25.w,
                                                            height: 1.3.w),
                                                        children: <TextSpan>[
                                                          TextSpan(
                                                            text: AppLocalizations
                                                                    .of(context)
                                                                ?.mStaticSpentAtleast,
                                                          ),
                                                          TextSpan(
                                                              text:
                                                                  ' $CLAP_DURATION ${AppLocalizations.of(context)!.mStaticMinutes} ',
                                                              style: GoogleFonts
                                                                  .lato(
                                                                color: AppColors
                                                                    .darkBlue,
                                                              )),
                                                          TextSpan(
                                                              text: AppLocalizations
                                                                      .of(context)
                                                                  ?.mStaticEngageWithPlatform)
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 40.w),
                                        Container(
                                          width: 1.sw,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              getImage(
                                                  'assets/img/clap_disable_icon.svg'),
                                              SizedBox(width: 12.w),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    TitleBoldWidget(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .mStaticWhyDidLossClaps,
                                                      maxLines: 2,
                                                    ),
                                                    SizedBox(height: 4.w),
                                                    RichText(
                                                      maxLines: 3,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textWidthBasis:
                                                          TextWidthBasis
                                                              .longestLine,
                                                      text: TextSpan(
                                                        style: GoogleFonts.lato(
                                                            color: AppColors
                                                                .greys60,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 12.sp,
                                                            letterSpacing:
                                                                0.25.w,
                                                            height: 1.3.w),
                                                        children: <TextSpan>[
                                                          TextSpan(
                                                            text: AppLocalizations
                                                                    .of(context)
                                                                ?.mStaticFallShort,
                                                          ),
                                                          TextSpan(
                                                              text:
                                                                  ' $CLAP_DURATION ${AppLocalizations.of(context)!.mStaticMinutes} ',
                                                              style: GoogleFonts
                                                                  .lato(
                                                                color: AppColors
                                                                    .darkBlue,
                                                              )),
                                                          TextSpan(
                                                              text: AppLocalizations
                                                                      .of(context)
                                                                  ?.mStaticEngagementRequirement)
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    )),
                              ),
                            );
                          });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppLocalizations.of(context)!.mStaticWeeklyClaps,
                            style: GoogleFonts.lato(
                              color: AppColors.greys87,
                              fontWeight: FontWeight.w400,
                              fontSize: 12.sp,
                              letterSpacing: 0.12.w,
                            )),
                        SizedBox(width: 8.w),
                        Icon(Icons.info, size: 16.sp, color: AppColors.darkBlue)
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 8.w,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      getImage(weeklyClaps.isNotEmpty &&
                              weeklyClaps['total_claps'] != null &&
                              weeklyClaps['total_claps'] != 0
                          ? 'assets/img/clap_icon.svg'
                          : 'assets/img/clap_disable_icon.svg'),
                      SizedBox(width: 8.w),
                      Text(
                          weeklyClaps.isNotEmpty &&
                                  weeklyClaps['total_claps'] != null
                              ? '${weeklyClaps['total_claps']} ${AppLocalizations.of(context)!.mStaticWeeks}'
                              : '0 ${AppLocalizations.of(context)!.mStaticWeeks}',
                          style: GoogleFonts.lato(
                            color: AppColors.greys87,
                            fontWeight: FontWeight.w700,
                            fontSize: 14.sp,
                            letterSpacing: 0.12.w,
                          ))
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

  void _generateInteractTelemetryData(String? contentId,
      {String subType = '',
      String? edataId,
      required BuildContext context}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.homePageId,
        contentId: contentId ?? "",
        subType: subType,
        env: TelemetryEnv.home,
        clickId: edataId ?? "");
    await telemetryRepository.insertEvent(eventData: eventData);
  }
}
