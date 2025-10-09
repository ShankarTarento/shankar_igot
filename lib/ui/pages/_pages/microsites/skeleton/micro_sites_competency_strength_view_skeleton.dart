import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';
import 'package:igot_ui_components/ui/widgets/microsite_competency_item/microsite_competency_item_skeleton.dart';

class MicroSitesCompetencyStrengthViewSkeleton extends StatelessWidget {
  final bool showTitle;
  final bool showFiler;

  MicroSitesCompetencyStrengthViewSkeleton(
      {this.showTitle = true, this.showFiler = true});

  @override
  Widget build(BuildContext context) {
    return _buildLayout();
  }

  Widget _buildLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle)
          Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 8,
            ).w,
            child: ContainerSkeleton(
              height: 18.w,
              width: 0.5.sw,
              radius: 12.w,
            ),
          ),
        if (showFiler) _competencyStrengthFilterView(),
        MicroSiteCompetencyItemSkeleton(),
      ],
    );
  }

  Widget _competencyStrengthFilterView() {
    return Container(
      height: 32.w,
      alignment: Alignment.center,
      margin: EdgeInsets.only(top: 16).w,
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: 3,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) => Container(
                margin: EdgeInsets.symmetric(horizontal: 4),
                child: ContainerSkeleton(
                  height: 32.w,
                  width: 120.w,
                  radius: 12.w,
                ),
              )),
    );
  }
}
