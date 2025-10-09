import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/models/_models/landing_page_info_model.dart';
import 'package:karmayogi_mobile/services/_services/landing_page_service.dart';
import 'package:karmayogi_mobile/ui/widgets/_common/page_loader.dart';
import 'package:karmayogi_mobile/ui/widgets/_landingPage/dashboard_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../constants/_constants/color_constants.dart';

class IntroTwoBody extends StatefulWidget {
  const IntroTwoBody({Key? key}) : super(key: key);

  @override
  State<IntroTwoBody> createState() => _IntroTwoBodyState();
}

class _IntroTwoBodyState extends State<IntroTwoBody> {
  final landingPageService = LandingPageService();
  late LandingPageInfo _landingPageInfo;
  @override
  void initState() {
    super.initState();
  }

  _getInfo() async {
    _landingPageInfo = await landingPageService.getLandingPageInfo();
    return _landingPageInfo;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getInfo(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 50.h,
              ),
              Text(
                AppLocalizations.of(context)!.mLearnAndNetwork,
                style: GoogleFonts.montserrat(
                    color: AppColors.primaryBlue,
                    height: 1.5.w,
                    fontSize: 20.0.sp,
                    // letterSpacing: 0.75,
                    fontWeight: FontWeight.w700),
              ),
              SizedBox(
                height: 32.w,
              ),
              snapshot.hasData
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16).r,
                          child: Text(
                            AppLocalizations.of(context)!.noOfUsersMdo,
                            style: GoogleFonts.montserrat(
                                color: AppColors.secondaryBlack,
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                                height: 1.3125.w),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            DashboardCard(
                              count: '${_landingPageInfo.karmayogiOnboarded}',
                              text: AppLocalizations.of(context)!
                                  .mKarmyogiOnboarded,
                              chart: 'assets/img/learnGraph.png',
                              parentContext: context,
                            ),
                            DashboardCard(
                              count: '${_landingPageInfo.registeredMdo}',
                              text: AppLocalizations.of(context)!
                                  .mStaticIntroTwoDashboard2Text,
                              chart: 'assets/img/learnGraph.png',
                              parentContext: context,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 32.w,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16).r,
                          child: Text(
                            AppLocalizations.of(context)!
                                .mAvailableContent
                                .replaceAll("(hours)", ""),
                            style: GoogleFonts.montserrat(
                                color: AppColors.secondaryBlack,
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                                height: 1.3125.w),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            DashboardCard(
                              count: '${_landingPageInfo.courses}',
                              text: AppLocalizations.of(context)!.mCourses,
                              chart: 'assets/img/coursesGraph.png',
                              parentContext: context,
                            ),
                            DashboardCard(
                              count: '${_landingPageInfo.availableContent}',
                              text: AppLocalizations.of(context)!
                                  .mAvailableContent,
                              chart: 'assets/img/contentGraph.png',
                              parentContext: context,
                            ),
                          ],
                        ),
                      ],
                    )
                  : PageLoader(
                      bottom: 300,
                    ),
            ],
          );
        });
  }
}
