import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/models/_models/course_model.dart';
import 'package:karmayogi_mobile/services/_services/learn_service.dart';
import 'package:karmayogi_mobile/services/_services/location_service.dart';
import 'package:karmayogi_mobile/ui/widgets/_scanner/mark_attendence.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import '../../../../../../../models/_models/batch_model.dart';

class AttendenceMarker extends StatefulWidget {
  final Course courseDetails;
  final BatchAttribute selectedBatchAttributes;
  final Batch batch;
  final bool isEnrolledCourse;
  final SessionDetailV2 session;
  final Function() onAttendanceMarked;
  const AttendenceMarker(
      {Key? key,
      required this.courseDetails,
      required this.session,
      required this.onAttendanceMarked,
      required this.isEnrolledCourse,
      required this.selectedBatchAttributes,
      required this.batch})
      : super(key: key);

  @override
  State<AttendenceMarker> createState() => _AttendenceMarkerState();
}

class _AttendenceMarkerState extends State<AttendenceMarker> {
  initState() {
    showCompleted = checkCompletionStatus(widget.session);
    getSessionDetails();
    super.initState();
  }

  List<SessionDetailV2> sessionList = [];
  final LearnService learnService = LearnService();
  List<Map<String, dynamic>> sessionIdList = [];
  List? contentProgressList = [];
  bool isPast = false;

  bool? showCompleted;
  @override
  Widget build(BuildContext context) {
    return widget.session.sessionAttendanceStatus
        ? SvgPicture.asset(
            "assets/img/approved.svg",
            height: 36.w,
            width: 36.w,
          )
        : GestureDetector(
            onTap: () async {
              // if (isEnrolledCourse &&
              //     DateTime.parse(widget.session.startDate)
              //         .isBefore(DateTime.now()) &&
              //     DateTime.parse(widget.session.)
              //         .isAfter(DateTime.now())) {

              if (_isSessionLive(widget.session)) {
                final LocationService locationService = LocationService();
                LocationPermission permissionStatus =
                    await locationService.handleLocationPermission();
                if (permissionStatus == LocationPermission.denied) {
                  Helper.showToastMessage(context,
                      message: EnglishLang.disabledLocationToastMsg);
                  return;
                }
                if (permissionStatus == LocationPermission.deniedForever) {
                  Helper.showToastMessage(context,
                      message: EnglishLang.disabledLocationToastToOpenSettings);
                  return;
                }
                if (permissionStatus == LocationPermission.always ||
                    permissionStatus == LocationPermission.whileInUse) {
                  try {
                    Position? position =
                        await locationService.getCurrentPosition();

                    bool isLocationValid = locationService.isValidLocationRange(
                        startLatitude: position!.latitude,
                        startLongitude: position.longitude,
                        endLatitude: double.parse(widget
                            .selectedBatchAttributes.latlong
                            .split(',')
                            .first),
                        endLongitude: double.parse(widget
                            .selectedBatchAttributes.latlong
                            .split(',')
                            .last));

                    if (isLocationValid) {
                      var isAttendanceMarked = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => MarkAttendence(
                            courseId: widget.courseDetails.id,
                            sessionIds: [
                              {
                                'sessionId': widget.session.sessionId,
                                'status': false
                              }
                            ],
                            onAttendanceMarked: widget.onAttendanceMarked,
                            batchId: widget.batch.batchId,
                          ),
                        ),
                      );
                      if (isAttendanceMarked != null) {
                        if (isAttendanceMarked) {
                          await getSessionDetails();
                        }
                      }
                    } else {
                      Helper.showToastMessage(context,
                          title: EnglishLang.invalidBatchLocation,
                          message: EnglishLang.invalidBatchLocationDesc);
                    }
                  } catch (e) {
                    Helper.showToastMessage(context,
                        title: EnglishLang.invalidLocation,
                        message: EnglishLang.invalidLocationDesc);
                  }
                }
              } else {
                if (widget.isEnrolledCourse) {
                  Helper.showToastMessage(context,
                      message: "Session is not live");
                } else {
                  Helper.showToastMessage(context,
                      message:
                          "You are not enrolled in this program, or your enrollment has not been approved.");
                }
              }
            },
            child: SvgPicture.asset(
              "assets/img/qr_scanner2.svg",
              height: 56.w,
              width: 56.w,
            ),
          );
  }

  getSessionDetails() async {
    sessionList = [];
    await _readContentProgress();
    sessionList = widget.batch.batchAttributes!.sessionDetailsV2;
    if (sessionList.isNotEmpty) {
      getLiveSessionIds();
    }
  }

  getLiveSessionIds() {
    sessionIdList = [];
    sessionList.forEach((session) {
      bool sessionStatus = Helper.isSessionLive(session);
      if (sessionStatus) {
        bool status = checkCompletionStatus(session);
        sessionIdList.add({'sessionId': session.sessionId, 'status': status});
      }
    });
  }

  Future<dynamic> _readContentProgress() async {
    var response = await learnService.readContentProgress(
        widget.courseDetails.id, widget.batch.batchId, language: widget.courseDetails.language);
    if (response['result']['contentList'] != null) {
      setState(() {
        contentProgressList = response['result']['contentList'];
      });
    }
  }

  bool checkCompletionStatus(session) {
    if (contentProgressList != null) {
      for (int i = 0; i < contentProgressList!.length; i++) {
        if (contentProgressList![i]['contentId'] == session.sessionId &&
            contentProgressList![i]['progress'] == 100 &&
            contentProgressList![i]['status'] == 2) {
          session.sessionAttendanceStatus = true;
          return true;
        }
      }
    }
    return false;
  }

  bool _isSessionLive(SessionDetailV2 session) {
    try {
      DateTime sessionDate = DateTime.parse(session.startDate);
      TimeOfDay startTime = DateTimeHelper.getTimeIn24HourFormat(session.startTime);
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
      isPast = (DateTime.now().isAfter(sessionStartEndTime));
      return isLive;
    } catch (e) {
      return false;
    }
  }
}