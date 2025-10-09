import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/index.dart';
import '../../../localization/index.dart';
import '../../../util/faderoute.dart';
import '../../../util/telemetry_repository.dart';
import '../index.dart';

class KarmaPointWidget extends StatelessWidget {
  final profileParentAction;
  final String karmapoint;

  KarmaPointWidget({this.profileParentAction, required this.karmapoint});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await _generateInteractTelemetryData(
                contentId: EnglishLang.karmaPoints, context: context)
            .then((_) => Navigator.push(
                  context,
                  FadeRoute(
                    page: KarmaPointOverview(),
                  ),
                ));
      },
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(right: 8).r,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppLocalizations.of(context)!.mStaticKarmaPoints,
                      style: GoogleFonts.lato(
                        color: AppColors.greys87,
                        fontWeight: FontWeight.w400,
                        fontSize: 12.sp,
                        letterSpacing: 0.12,
                      )),
                  SizedBox(width: 8.w),
                  TooltipWidget(
                      message: AppLocalizations.of(context)!
                          .mStaticKarmapointAppbarInfo,
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
                  SvgPicture.asset(
                    'assets/img/kp_icon.svg',
                    width: 32.w,
                    height: 32.w,
                  ),
                  SizedBox(width: 8.w),
                  Text(karmapoint,
                      style: GoogleFonts.lato(
                        color: AppColors.greys87,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                        letterSpacing: 0.12,
                      ))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _generateInteractTelemetryData(
      {required String contentId, required BuildContext context}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.karmaPointPageId,
        contentId: contentId,
        subType: TelemetrySubType.karmaPoints,
        env: TelemetryEnv.home,
        objectType: TelemetrySubType.karmaPoints);
    await telemetryRepository.insertEvent(eventData: eventData);
  }
}
