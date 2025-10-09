import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/models/_models/event_model.dart';
import 'package:intl/intl.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/events_details/events_details_screenv2.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:karmayogi_mobile/util/telemetry_repository.dart';

class ExploreEventsCard extends StatelessWidget {
  final Event event;
  const ExploreEventsCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _generateInteractTelemetryData(event.identifier,
            subType: TelemetrySubType.mdoExploreEvents,
            clickId: TelemetryIdentifier.cardContent,
            primaryCategory: PrimaryCategory.event);
        Navigator.push(
          context,
          FadeRoute(
              page: EventsDetailsScreenv2(
            eventId: event.identifier,
          )),
        );
      },
      child: Container(
        height: 170.w,
        width: 1.sw,
        padding: EdgeInsets.all(16).r,
        decoration: BoxDecoration(
            color: AppColors.appBarBackground,
            border: Border.all(color: AppColors.grey08),
            borderRadius: BorderRadius.circular(8).r),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ).r,
              child: event.eventIcon != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: CachedNetworkImage(
                        fit: BoxFit.fill,
                        imageUrl: Helper.convertImageUrl(
                          event.eventIcon,
                        ),
                        height: 100.w,
                        width: 120.w,
                        placeholder: (context, url) {
                          return ContainerSkeleton(
                            height: 100.w,
                            width: 120.w,
                          );
                        },
                        errorWidget: (context, url, error) => Image.asset(
                          'assets/img/image_placeholder.jpg',
                          height: 100.w,
                          width: 120.w,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    )
                  : Image.asset(
                      'assets/img/image_placeholder.jpg',
                      height: 100.w,
                      width: 120.w,
                      fit: BoxFit.fitWidth,
                    ),
            ),
            SizedBox(
              width: 16.w,
            ),
            SizedBox(
              width: 0.44.sw,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8)
                            .r,
                    decoration: BoxDecoration(
                        color: AppColors.orangeFaded,
                        borderRadius: BorderRadius.circular(36).r,
                        border: Border.all(
                            color: AppColors.orangeTourText, width: 1)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          event.category ?? '',
                          style:
                              Theme.of(context).textTheme.labelMedium!.copyWith(
                                    fontSize: 14.sp,
                                    color: AppColors.greys,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    event.source != null ? event.source! : 'iGOT',
                    style: GoogleFonts.lato(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.greys60,
                    ),
                    maxLines: 2,
                  ),
                  Text(
                    event.name ?? "",
                    style: GoogleFonts.lato(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.greys87,
                    ),
                    maxLines: 2,
                  ),
                  Text(
                    formateDate(event.startDate) +
                        ' ' +
                        formateTime(event.startTime),
                    style: GoogleFonts.lato(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.darkBlue,
                    ),
                    maxLines: 2,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  formateDate(date) {
    return DateFormat("MMMM d, y").format(DateTime.parse(date));
  }

  formateTime(time) {
    return time.substring(0, 5);
  }

  void _generateInteractTelemetryData(String contentId,
      {String subType = '',
      String? primaryCategory,
      bool isObjectNull = false,
      String clickId = ''}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.mdoChannelUri,
        contentId: contentId,
        subType: subType,
        env: TelemetryEnv.nationalLearningWeek,
        objectType: primaryCategory ?? (isObjectNull ? null : subType),
        clickId: clickId);
    await telemetryRepository.insertEvent(eventData: eventData);
  }
}
