import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';

import '../../../../../constants/_constants/color_constants.dart';

class MicroSitesTrainingCalenderViewSkeleton extends StatelessWidget {
  final bool showTitle;
  MicroSitesTrainingCalenderViewSkeleton({
    this.showTitle = true,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildLayout();
  }

  Widget _buildLayout() {
    return Container(
      margin: EdgeInsets.only(bottom: 16).w,
      child: Column(
        children: [
          if (showTitle) _calendarTopView(),
          Container(
            color: AppColors.appBarBackground,
            margin: EdgeInsets.only(top: 8).w,
            padding: EdgeInsets.symmetric(horizontal: 8).w,
            child: Column(
              children: [
                _calendarListView(),
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(left: 4, right: 4, bottom: 8).w,
                  child: _actionButtonView(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _calendarTopView() {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16).w,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(right: 4).w,
              child: ContainerSkeleton(
                height: 32.w,
                width: 0.5.sw,
                radius: 8.w,
              ),
            ),
          ],
        ));
  }

  Widget _calendarListView() {
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: 3,
        itemBuilder: (context, index) {
          return _calendarItemView();
        });
  }

  Widget _actionButtonView() {
    return ContainerSkeleton(
      height: 36.w,
      width: 120.w,
      radius: 50.w,
    );
  }

  Widget _calendarItemView() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4).w,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              width: 60.w,
              padding: EdgeInsets.all(4).w,
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: ContainerSkeleton(
                      height: 18.w,
                      width: 36.w,
                      radius: 8.w,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: ContainerSkeleton(
                      height: 18.w,
                      width: 24.w,
                      radius: 8.w,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: ContainerSkeleton(
                      height: 18.w,
                      width: 36.w,
                      radius: 8.w,
                    ),
                  )
                ],
              )),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...List.generate(
                2,
                (index) => Container(
                    margin: EdgeInsets.symmetric(vertical: 4).w,
                    padding: EdgeInsets.all(8).w,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10.w)),
                        border: Border.all(color: AppColors.grey04),
                        color: AppColors.grey04),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ContainerSkeleton(
                          height: 18.w,
                          width: double.maxFinite,
                          radius: 8.w,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 8).w,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(right: 8),
                                child: ContainerSkeleton(
                                  height: 18.w,
                                  width: 18.w,
                                  radius: 8.w,
                                ),
                              ),
                              ContainerSkeleton(
                                height: 18.w,
                                width: 160.w,
                                radius: 8.w,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 8).w,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(right: 8),
                                child: ContainerSkeleton(
                                  height: 18.w,
                                  width: 18.w,
                                  radius: 8.w,
                                ),
                              ),
                              ContainerSkeleton(
                                height: 18.w,
                                width: 160.w,
                                radius: 8.w,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 8).w,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(right: 8),
                                child: ContainerSkeleton(
                                  height: 18.w,
                                  width: 18.w,
                                  radius: 8.w,
                                ),
                              ),
                              ContainerSkeleton(
                                height: 18.w,
                                width: 160.w,
                                radius: 8.w,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
              )
            ],
          )),
        ],
      ),
    );
  }
}
