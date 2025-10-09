import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';
import '../../../../../constants/index.dart';
import 'micro_sites_competency_strength_view_skeleton.dart';
import 'microsites_course_strip_view_skeleton.dart';
import 'microsites_infra_detail_view_skeleton.dart';
import 'microsites_learner_reviews_view_skeleton.dart';
import 'microsites_top_section_view_skeleton.dart';
import 'microsites_training_calender_view_skeleton.dart';

class AtiCtiMicroSitesScreenSkeleton extends StatelessWidget {
  final PreferredSizeWidget? appBarWidget;

  AtiCtiMicroSitesScreenSkeleton({this.appBarWidget});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarWidget,
        body: _buildLayout(),
        bottomSheet: _bottomAction());
  }

  Widget _buildLayout() {
    return SafeArea(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          margin: EdgeInsets.only(bottom: 100).w,
          child: Column(children: [
            MicroSitesTopSectionViewSkeleton(),
            SizedBox(
              height: 16.w,
            ),
            MicroSitesTrainingCalenderViewSkeleton(showTitle: true),
            SizedBox(
              height: 16.w,
            ),
            MicroSitesCompetencyStrengthViewSkeleton(showFiler: true),
            SizedBox(
              height: 16.w,
            ),
            MicroSitesInfraDetailViewSkeleton(),
            SizedBox(
              height: 16.w,
            ),
            MicroSitesCourseStripViewSkeleton(),
            SizedBox(
              height: 16.w,
            ),
            MicroSitesCourseStripViewSkeleton(),
            SizedBox(
              height: 16.w,
            ),
            MicroSitesLearnerReviewsViewSkeleton()
          ]),
        ),
      ),
    );
  }

  Widget _bottomAction() {
    return Container(
        height: 87.w,
        width: double.maxFinite,
        padding: EdgeInsets.fromLTRB(16, 16, 16, 32).w,
        decoration: BoxDecoration(color: AppColors.assesmentCardBackground),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [_chipsWidget(), _chipsWidget(), _chipsWidget()],
          ),
        ));
  }

  Widget _chipsWidget() {
    return Container(
        margin: EdgeInsets.only(left: 4, right: 4).w,
        child: ContainerSkeleton(
          width: 120.w,
          height: double.maxFinite,
          radius: 18.w,
        ));
  }
}
