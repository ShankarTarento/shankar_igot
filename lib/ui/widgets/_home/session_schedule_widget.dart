import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:karmayogi_mobile/models/_models/batch_model.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';
import '../../../constants/index.dart';
import '../../../services/_services/location_service.dart';
import '../_scanner/mark_attendence.dart';
import '../index.dart';

class SessionScheduleWidget extends StatelessWidget {
  final Map<String, BatchAttribute>? batch;
  final VoidCallback? callBack;
  final String? sessionId;
  SessionScheduleWidget({Key? key, this.batch, this.sessionId, this.callBack})
      : super(key: key);

  final subTitleStyle = TextStyle(
      color: AppColors.avatarText.withValues(alpha: 0.7),
      fontWeight: FontWeight.w400,
      fontSize: 14.sp);

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    batch?.forEach((id, batchAttr) {
      String selectedBatchId = id;
      batchAttr.sessionDetailsV2.forEach((session) {
        final bool isLive = _isSessionLive(session);
        var widget = session.sessionId == sessionId
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10).r,
                child: Container(
                    height: 105.w,
                    decoration: BoxDecoration(
                        color: AppColors.orange32,
                        border: Border.all(
                            color: AppColors.verifiedBadgeIconColor, width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(12).r)),
                    margin: EdgeInsets.fromLTRB(5, 10, 10, 0).r,
                    padding: const EdgeInsets.fromLTRB(15, 10, 15, 10).r,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Visibility(
                          visible: isLive,
                          child: Text(
                            AppLocalizations.of(context)!.mStaticLive,
                            style: TextStyle(
                                color: AppColors.lightGreen,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.sp),
                          ),
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 0.6.sw,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TitleBoldWidget(
                                    '${session.title} - ${session.sessionType}',
                                    maxLines: 2,
                                  ),
                                  Visibility(
                                      visible: !isLive,
                                      child: SizedBox(
                                        height: 5.w,
                                      )),
                                  Visibility(
                                    visible: !isLive,
                                    child: TitleRegularGrey60(
                                      DateTimeHelper.convertTo12HourFormat(
                                              session.startTime) +
                                          ' to ' +
                                          DateTimeHelper.convertTo12HourFormat(
                                              session.endTime) +
                                          ', ' +
                                          DateFormat('dd/MM/yy').format(
                                              DateTime.parse(
                                                  session.startDate)),
                                      color: AppColors.greys87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            session.sessionAttendanceStatus
                                ? Container(
                                    padding:
                                        EdgeInsets.fromLTRB(10, 5, 10, 5).r,
                                    decoration: BoxDecoration(
                                        color: AppColors.ghostWhite
                                            .withValues(alpha: 0.5),
                                        borderRadius:
                                            BorderRadius.circular(5).r),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(4.0).r,
                                          child: SvgPicture.asset(
                                            'assets/img/approved.svg',
                                            width: 20.w,
                                            height: 20.w,
                                          ),
                                        ),
                                        Text(
                                          AppLocalizations.of(context)!
                                              .mStaticMarkedAttendence,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                height: 1.5.w,
                                              ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Align(
                                    alignment: Alignment.center,
                                    child: ElevatedButton(
                                      child: Center(
                                        child: SvgPicture.asset(
                                          'assets/img/qr_scanner.svg',
                                          width: 56.0.w,
                                          height: 56.0.w,
                                        ),
                                      ),
                                      style: TextButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          elevation: 0),
                                      onPressed: isLive &&
                                              session.sessionType ==
                                                  'Offline' &&
                                              batchAttr.enableQR != null &&
                                              batchAttr.enableQR!
                                          ? () async {
                                              final LocationService
                                                  locationService =
                                                  LocationService();
                                              LocationPermission
                                                  permissionStatus =
                                                  await locationService
                                                      .handleLocationPermission();
                                              if (permissionStatus ==
                                                  LocationPermission.denied) {
                                                showToastMessage(context,
                                                    message: AppLocalizations
                                                            .of(context)!
                                                        .mStaticDisabledLocationToastMsg);
                                                return;
                                              }
                                              if (permissionStatus ==
                                                  LocationPermission
                                                      .deniedForever) {
                                                showToastMessage(context,
                                                    message: AppLocalizations
                                                            .of(context)!
                                                        .mStaticDisabledLocationToastToOpenSettings);
                                                return;
                                              }
                                              if (permissionStatus ==
                                                      LocationPermission
                                                          .always ||
                                                  permissionStatus ==
                                                      LocationPermission
                                                          .whileInUse) {
                                                try {
                                                  Position? position =
                                                      await locationService
                                                          .getCurrentPosition();
                                                  bool isLocationValid = locationService
                                                      .isValidLocationRange(
                                                          startLatitude:
                                                              position!
                                                                  .latitude,
                                                          startLongitude:
                                                              position
                                                                  .longitude,
                                                          endLatitude: double
                                                              .parse(batchAttr
                                                                  .latlong
                                                                  .split(',')
                                                                  .first),
                                                          endLongitude: double
                                                              .parse(batchAttr
                                                                  .latlong
                                                                  .split(',')
                                                                  .last));

                                                  if (isLocationValid) {
                                                    var isAttendanceMarked =
                                                        await Navigator.of(
                                                                context)
                                                            .push(
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            MarkAttendence(
                                                          id: id,
                                                          onAttendanceMarked:
                                                              () {},
                                                          courseId: batchAttr
                                                              .courseId,
                                                          sessionIds: [
                                                            {
                                                              'sessionId':
                                                                  session
                                                                      .sessionId,
                                                              'status': false
                                                            }
                                                          ],
                                                          batchId:
                                                              selectedBatchId,
                                                        ),
                                                      ),
                                                    );
                                                    if (isAttendanceMarked !=
                                                        null) {
                                                      if (isAttendanceMarked) {
                                                        session.sessionAttendanceStatus =
                                                            isAttendanceMarked;
                                                        callBack!();
                                                      }
                                                    }
                                                  } else {
                                                    showToastMessage(context,
                                                        title: AppLocalizations
                                                                .of(context)!
                                                            .mStaticInvalidLocation,
                                                        message: AppLocalizations
                                                                .of(context)!
                                                            .mStaticInvalidLocationDesc);
                                                  }
                                                } catch (e) {
                                                  showToastMessage(context,
                                                      title: AppLocalizations
                                                              .of(context)!
                                                          .mStaticInvalidLocation,
                                                      message: AppLocalizations
                                                              .of(context)!
                                                          .mStaticInvalidLocationDesc);
                                                }
                                              }
                                            }
                                          : session.sessionType != 'Offline' &&
                                                  batchAttr.enableQR != null &&
                                                  !batchAttr.enableQR!
                                              ? () {
                                                  showToastMessage(context,
                                                      message: AppLocalizations
                                                              .of(context)!
                                                          .mStaticContactProgramCordinator);
                                                }
                                              : () => showToastMessage(context,
                                                  message: AppLocalizations.of(
                                                          context)!
                                                      .mStaticWaitTillSessionStart),
                                    ),
                                  ),
                          ],
                        ),
                      ],
                    )),
              )
            : Center();
        widgets.add(widget);
      });
    });
    return Row(children: widgets);
  }

  void showToastMessage(BuildContext context,
      {String? title, String? message}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Column(
      children: [
        Text(title ?? ''),
        Text(
          message ?? '',
          textAlign: TextAlign.center,
        ),
      ],
    )));
  }

  bool _isSessionLive(SessionDetailV2 session) {
    try {
      DateTime sessionDate = DateTime.parse(session.startDate);
      TimeOfDay startTime =
          DateTimeHelper.getTimeIn24HourFormat(session.startTime);
      // TimeOfDay endTime = _getTimeIn24HourFormat(session.endTime);
      DateTime sessionStartDateTime = DateTime(sessionDate.year,
          sessionDate.month, sessionDate.day, startTime.hour, startTime.minute);
      DateTime sessionStartEndTime = DateTime(
          sessionDate.year,
          sessionDate.month,
          sessionDate.day,
          startTime.hour +
              (int.parse((session.sessionDuration).split('hr')[0])) +
              AttendenceMarking.bufferHour,
          startTime.minute);
      final bool isLive = (DateTime.now().isAfter(sessionStartDateTime) &&
          DateTime.now().isBefore(sessionStartEndTime));
      return isLive;
    } catch (e) {
      return false;
    }
  }
}
