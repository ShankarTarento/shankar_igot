import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/skeleton/widgets/container_skeleton.dart';

class NetworkCardWidgetSkeleton extends StatelessWidget {
  final Color color;

  const NetworkCardWidgetSkeleton({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return _communityListItemView();
  }

  Widget _communityListItemView() {
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        Container(
            margin: EdgeInsets.only(left: 8, right: 8, bottom: 8, top: 32).r,
            width: 0.4.sw,
            height: 196.w,
            decoration: BoxDecoration(
              color: AppColors.appBarBackground,
              boxShadow: [
                BoxShadow(
                  color: AppColors.grey08,
                  blurRadius: 6.0.r,
                  spreadRadius: 0.r,
                  offset: Offset(
                    3,
                    3,
                  ),
                ),
              ],
              border: Border.all(color: AppColors.grey08),
              borderRadius: BorderRadius.circular(8).r,
            ),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                      padding: EdgeInsets.fromLTRB(20, 50, 20, 0).r,
                      child: ContainerSkeleton(
                        height: 18.w,
                        width: 120.w,
                        color: color,
                      )),
                  Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0).r,
                      child: ContainerSkeleton(
                        height: 18.w,
                        width: 120.w,
                        color: color,
                      )),
                  Padding(
                    padding: const EdgeInsets.only(
                            top: 2, bottom: 2, left: 10, right: 10)
                        .r,
                    child: ContainerSkeleton(
                      // height: 18.w,
                      width: double.infinity.w,
                      color: color,
                    ),
                  )
                ])),
        Positioned(
            top: 10,
            child: Center(
              child: CircleAvatar(
                radius: 32.r,
                backgroundColor: color,
              ),
            )),
      ],
    );
  }
}
