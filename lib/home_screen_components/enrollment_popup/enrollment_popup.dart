import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';
import 'package:karmayogi_mobile/core/repositories/enrollment_repository.dart';
import 'package:karmayogi_mobile/models/_models/course_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_home/course_enrol_popup_widget.dart';

class EnrollmentPopup extends StatefulWidget {
  const EnrollmentPopup({super.key});

  @override
  State<EnrollmentPopup> createState() => _EnrollmentPopupState();
}

class _EnrollmentPopupState extends State<EnrollmentPopup> {
  bool enableEnrolPopupOnLaunch = false;
  final _storage = FlutterSecureStorage();
  late Future<List<Course>> enrollmentListFuture;

  @override
  void initState() {
    super.initState();
    userEnrolledToAnyCourse();
  }

  Future<void> userEnrolledToAnyCourse() async {
    String? status =
        await _storage.read(key: Storage.showKarmaPointFirstCourseEnrolPopup);
    if (status?.toLowerCase() == 'false') {
      enableEnrolPopupOnLaunch = false;
    } else {
      enrollmentListFuture = EnrollmentRepository.getEnrolledCourses(limit: 50);

      enableEnrolPopupOnLaunch = true;
    }
    setState(() {});
  }

  bool courseEnrolmentStatus(List<Course> enrolList) {
    return enrolList.any((course) =>
        course.courseCategory.toString().toLowerCase() ==
        PrimaryCategory.course);
  }

  @override
  Widget build(BuildContext context) {
    return enableEnrolPopupOnLaunch
        ? FutureBuilder<List<Course>>(
            future: enrollmentListFuture,
            builder: (BuildContext context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox.shrink();
              } else if (snapshot.hasData && snapshot.data != null) {
                List<Course> enrolmentList = snapshot.data!;
                return courseEnrolmentStatus(enrolmentList)
                    ? SizedBox.shrink()
                    : CourseEnrolPopupWidget(
                        closeButtonPressed: () {
                          setState(() {
                            _storage.write(
                                key:
                                    Storage.showKarmaPointFirstCourseEnrolPopup,
                                value: 'false');
                            enableEnrolPopupOnLaunch = false;
                          });
                        },
                      );
              } else {
                return SizedBox.shrink();
              }
            },
          )
        : SizedBox.shrink();
  }
}
