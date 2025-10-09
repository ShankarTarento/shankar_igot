import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../model/mdo_main_section_data_model.dart';
import 'certificate/mdo_certificate_strip_view.dart';
import 'course/mdo_course_strip_view.dart';

class MdoContentView extends StatefulWidget {
  final String orgId;
  final List<ContentTabData> contentTab;

  MdoContentView({
    required this.orgId,
    required this.contentTab,
    Key? key,
  }) : super(key: key);

  @override
  _MdoContentView createState() {
    return _MdoContentView();
  }
}

class _MdoContentView extends State<MdoContentView> {
  Future<List<ContentTabData>>? contentDataFuture;
  List<ContentTabData> contentTabSortedData = [];
  List<Widget> contentWidgets = [];

  @override
  void initState() {
    super.initState();
    getContentData();
  }

  void getContentData() {
    contentTabSortedData =
        widget.contentTab.where((item) => item.enabled).toList();
    contentTabSortedData.sort((a, b) => a.order!.compareTo(b.order!));
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
    sortLayouts(contentTabSortedData);
    return Container(
      margin: EdgeInsets.only(bottom: 16).w,
      child: Column(children: contentWidgets),
    );
  }

  void sortLayouts(List<ContentTabData> _microSiteSortedData) {
    contentWidgets = [];
    _microSiteSortedData.forEach((element) {
      switch (element.key) {
        case 'sectionCertificationsOfWeeks':
          if (element.column.isNotEmpty)
            return contentWidgets.add(MdoCertificateStripView(
                contentsType: 'sectionCertificationsOfWeeks',
                title: element.title ?? '',
                orgId: widget.orgId,
                columnData: element.column[0]));
          break;
        case 'sectionRecommendedProgram':
          if (element.column.isNotEmpty)
            return contentWidgets.add(MdoCourseStripView(
                contentsType: 'sectionRecommendedPrograms',
                title: element.title ?? '',
                orgId: widget.orgId,
                type: 'MDO_RECOMMENDED_PROGRAMS',
                columnData: element.column[0]));
          break;
        case 'sectionRecommendedCourses':
          if (element.column.isNotEmpty)
            return contentWidgets.add(MdoCourseStripView(
                contentsType: 'sectionRecommendedCourses',
                title: element.title ?? '',
                orgId: widget.orgId,
                type: 'MDO_RECOMMENDED_COURSES',
                columnData: element.column[0]));
          break;
        case 'sectionFeatureCourses':
          if (element.column.isNotEmpty)
            return contentWidgets.add(MdoCourseStripView(
                contentsType: 'sectionFeatureCourses',
                title: element.title ?? '',
                orgId: widget.orgId,
                type: 'MDO_FEATURED_COURSES',
                columnData: element.column[0]));
          break;
        default:
          return contentWidgets.add(SizedBox.shrink());
      }
    });
  }
}
