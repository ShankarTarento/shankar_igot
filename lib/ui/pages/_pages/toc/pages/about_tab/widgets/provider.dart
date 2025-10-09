import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../../../../constants/index.dart';
import '../../../../../../../models/index.dart';
import '../../../../../../../util/faderoute.dart';
import '../../../../../../../util/telemetry_repository.dart';
import '../../../../microsites/screen/microsite_screen/ati_cti_microsites_screen.dart';

class CourseProvider extends StatelessWidget {
  final Course courseDetails;
  CourseProvider({
    Key? key,
    required this.courseDetails,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return courseDetails.source != ''
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.mStaticProviders,
                style: GoogleFonts.lato(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(
                height: 16.w,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      height: 48.w,
                      width: 48.w,
                      margin: EdgeInsets.only(right: 16).r,
                      padding: EdgeInsets.all(9).r,
                      decoration: BoxDecoration(
                          color: AppColors.appBarBackground,
                          border:
                              Border.all(color: AppColors.grey16, width: 1.w),
                          borderRadius:
                              BorderRadius.all(const Radius.circular(4.0).r)),
                      child: Image.network(
                        courseDetails.creatorLogo,
                        height: 48.w,
                        width: 48.w,
                        fit: BoxFit.cover,
                        cacheWidth: 24,
                        cacheHeight: 24,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset(
                          'assets/img/igot_creator_icon.png',
                          height: 48.w,
                          width: 48.w,
                        ),
                      )),
                  Expanded(
                      child: GestureDetector(
                    onTap: () {
                      _generateInteractTelemetryData(
                          contentId: TelemetryIdentifier.cardContent,
                          clickId:
                              courseDetails.getBatches()[0].createdFor[0] ?? '',
                          objectType: courseDetails.source);
                      Navigator.push(
                        context,
                        FadeRoute(
                            page: AtiCtiMicroSitesScreen(
                          providerName: courseDetails.source,
                          orgId:
                              courseDetails.getBatches()[0].createdFor[0] ?? '',
                        )),
                      );
                    },
                    child: Text(
                      'By ' + courseDetails.source,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          Theme.of(context).textTheme.headlineSmall!.copyWith(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                    ),
                  )),
                ],
              ),
            ],
          )
        : SizedBox();
  }

  void _generateInteractTelemetryData(
      {String? contentId,
      String? subType,
      String? clickId,
      String? objectType}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.learnPageId,
        contentId: contentId ?? "",
        subType: subType ?? "",
        clickId: clickId ?? "",
        objectType: objectType,
        env: TelemetryEnv.learn);
    await telemetryRepository.insertEvent(eventData: eventData);
  }
}
