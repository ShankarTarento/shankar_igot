import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/models/_models/course_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/microsites/model/ati_cti_microsite_data_model.dart';
import 'package:karmayogi_mobile/ui/skeleton/pages/course_card_skeleton_page.dart';
import 'package:provider/provider.dart';

import '../../../../../../../../../../respositories/_respositories/learn_repository.dart';
import 'mdo_certificate_of_week.dart';
import 'mdo_certificate_strip_view_skeleton.dart';

class MdoCertificateStripView extends StatefulWidget {
  final String contentsType;
  final String title;
  final String? orgId;
  final ColumnData columnData;

  MdoCertificateStripView({
    required this.contentsType,
    required this.title,
    this.orgId,
    Key? key,
    required this.columnData,
  }) : super(key: key);

  @override
  _MdoCertificateStripViewState createState() {
    return _MdoCertificateStripViewState();
  }
}

class _MdoCertificateStripViewState extends State<MdoCertificateStripView> {
  Future<List<Course>>? certificateDataFuture;

  @override
  void initState() {
    super.initState();
    getCertificateData();
  }

  Future<void> getCertificateData() async {
    var responseData =
        await Provider.of<LearnRepository>(context, listen: false)
            .getMdoCertificateOfWeek(widget.orgId ?? '');
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        certificateDataFuture = Future<List<Course>>.value(
          responseData.map<Course>((data) => Course.fromJson(data)).toList(),
        );
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildLayout();
  }

  Widget _buildLayout() {
    return Container(
      child: _certificateStrip(widget.columnData.title, false),
    );
  }

  Widget _certificateStrip(String title, bool showShowAll) {
    return Container(
      margin: EdgeInsets.only(bottom: 16).w,
      padding: EdgeInsets.fromLTRB(0, 0, 0, 8).w,
      child: FutureBuilder(
        future: certificateDataFuture,
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            List<Course> courseList = getCertificateList( snapshot.data ?? []);
            return courseList.isNotEmpty
                ? _microSiteCourseList(
                    courseList: courseList,
                    title: title,
                    showShowAll: showShowAll)
                : SizedBox.shrink();
          } else {
            return MdoCertificateStripViewSkeleton();
          }
        },
      ),
    );
  }

  Widget _microSiteCourseList(
      {List<Course>? courseList,required String title, bool? showShowAll}) {
    return courseList == null
        ? const CourseCardSkeletonPage()
        : courseList.runtimeType == String
            ? Center()
            : courseList.isEmpty
                ? Center()
                : MdoCertificateOfWeek(
                    title: widget.title,
                    orgId: widget.orgId,
                    certificateOfWeekList: courseList,
                    showShowAll: false,
                  );
  }

  List<Course> getCertificateList(List<Course> courseList) {
    List<Course> certificates = [];
    courseList.forEach((element) {
      if ((element.createdFor??[]).contains(widget.orgId.toString())) {
        certificates.add(element);
      }
    });
    return certificates;
  }
}
