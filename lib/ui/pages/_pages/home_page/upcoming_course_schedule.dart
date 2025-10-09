import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/core/repositories/enrollment_repository.dart';
import 'package:karmayogi_mobile/ui/widgets/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../constants/index.dart';
import '../../../../models/index.dart';
import '../../../../services/index.dart';
import '../../../../util/index.dart';
import '../../../widgets/_home/session_schedule_widget.dart';

class UpcomingCourseSchedule extends StatefulWidget {
  final VoidCallback? callBack;
  UpcomingCourseSchedule({Key? key, this.callBack}) : super(key: key);
  @override
  UpcomingCourseScheduleState createState() => UpcomingCourseScheduleState();
}

class UpcomingCourseScheduleState extends State<UpcomingCourseSchedule> {
  final _controller = PageController();
  List<Map<String, BatchAttribute>> batchAttributes = [];
  Future<List<Map<String, dynamic>>>? upcomingFuture;
  List<Map<String, dynamic>> orderedSessions = [];
  String courseId = '';
  String batchId = '';

  @override
  void initState() {
    super.initState();
    upcomingFuture = getUpcoming();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
        future: upcomingFuture,
        builder: (context, snapshot) {
          if (snapshot.data != null && snapshot.data!.isNotEmpty) {
            return Visibility(
              visible: batchAttributes.isNotEmpty,
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 16).r,
                      child: TitleSemiboldSize16(AppLocalizations.of(context)!
                          .mStaticMarkYourAttendance),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 10, bottom: 16).r,
                      height: 136.w,
                      child: Column(
                        children: [
                          Expanded(
                            child: PageView.builder(
                                controller: _controller,
                                itemCount: orderedSessions.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  var batchData;
                                  batchAttributes.forEach(
                                      (batch) => batch.forEach((id, batchAttr) {
                                            batchAttr.sessionDetailsV2
                                                .forEach((session) {
                                              if (session.sessionId ==
                                                  orderedSessions[index]
                                                      ['sessionId']) {
                                                batchData = batch;
                                              }
                                            });
                                          }));
                                  return batchData == null
                                      ? Center()
                                      : SessionScheduleWidget(
                                          batch: batchData,
                                          sessionId: orderedSessions[index]
                                              ['sessionId'],
                                          callBack: widget.callBack);
                                }),
                          ),
                          SizedBox(height: 8.w),
                          SmoothPageIndicator(
                            controller: _controller,
                            count: orderedSessions.length,
                            effect: ExpandingDotsEffect(
                                activeDotColor: AppColors.orangeTourText,
                                dotColor: AppColors.profilebgGrey20,
                                dotHeight: 4.w,
                                dotWidth: 4.w,
                                spacing: 4),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Center();
          }
        });
  }

  Future<List<Map<String, dynamic>>> _getUpcomingSchedules(List courses) async {
    orderedSessions = [];
    courses.forEach((course) {
      if (course['batch']['batchAttributes'] != null) {
        if (course['batch']['batchAttributes']["sessionDetails_v2"] != null) {
          Map<String, BatchAttribute> batchAttr = {
            course['batch']['identifier'].toString():
                BatchAttribute.fromJson(course['batch']['batchAttributes'])
          };
          courseId = course['courseId'];
          List sessionList =
              course['batch']['batchAttributes']["sessionDetails_v2"];
          List tempSessionList = sessionList;
          tempSessionList.forEach((tempSession) {
            bool isUpcoming =
                Helper.isSessionLive(SessionDetailV2.fromJson(tempSession));
            if (!isUpcoming) {
              batchAttr.values.forEach((batch) {
                batch.sessionDetailsV2.removeWhere(
                    (session) => session.sessionId == tempSession['sessionId']);
              });
            }
          });

          batchAttr.forEach((id, batchAttribute) {
            if (batchAttribute.sessionDetailsV2.isNotEmpty) {
              // Adding sorted sessions to orderedSessions to display in ascending order
              batchAttribute.sessionDetailsV2.forEach((session) {
                DateTime sessionDate = DateTime.parse(session.startDate);
                TimeOfDay startTime =
                DateTimeHelper.getTimeIn24HourFormat(session.startTime);
                DateTime sessionStartDateTime = DateTime(
                    sessionDate.year,
                    sessionDate.month,
                    sessionDate.day,
                    startTime.hour,
                    startTime.minute);
                orderedSessions.add({
                  'sessionId': session.sessionId,
                  'startDateTime': sessionStartDateTime
                });
              });
              batchAttributes.add(batchAttr);
            }
          });

          batchAttributes
              .forEach((batch) => batch.forEach((id, batchAttr) async {
                    batchId = id;
                    if (course['batchId'] == id) {
                      batchAttr.courseId = course['courseId'];
                    }
                    batchAttr.sessionDetailsV2.forEach((sessionMap) async {
                      await _readContentProgress(id, courseId,
                          language: course['language']);
                    });
                  }));
        }
      }
    });
    if (orderedSessions.isNotEmpty) {
      orderedSessions
          .sort((a, b) => a['startDateTime'].compareTo(b['startDateTime']));
    }
    return orderedSessions;
//    setState(() {});
  }

  Future<void> _readContentProgress(batchId, courseId,
      {required String language}) async {
    var response = await LearnService()
        .readContentProgress(courseId, batchId, language: language);
    if (response['result']['contentList'] != null) {
      var contentProgressList = response['result']['contentList'];
      if (contentProgressList != null) {
        for (int i = 0; i < contentProgressList.length; i++) {
          if (contentProgressList[i]['progress'] == COURSE_COMPLETION_PERCENTAGE &&
              contentProgressList[i]['status'] == 2) {
            batchAttributes
                .forEach((batch) => batch.forEach((id, batchAttr) async {
                      batchAttr.sessionDetailsV2.forEach((sessionMap) async {
                        if (sessionMap.sessionId ==
                            contentProgressList[i]['contentId']) {
                          setState(() {
                            sessionMap.sessionAttendanceStatus = true;
                          });
                        }
                      });
                    }));
          }
        }
      }
    }
  }

  Future<List<Map<String, dynamic>>> getUpcoming() async {
    List<Map> enrollmentList =
        await EnrollmentRepository.getEnrolledCoursesAsMap();
    if (enrollmentList.isNotEmpty) {
      return _getUpcomingSchedules(enrollmentList);
    } else {
      return [];
    }
  }
}
