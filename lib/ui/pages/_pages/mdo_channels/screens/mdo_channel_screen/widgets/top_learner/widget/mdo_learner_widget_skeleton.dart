import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:igot_ui_components/constants/color_constants.dart';
import '../../../../../../../../skeleton/widgets/container_skeleton.dart';

class MdoLearnerWidgetSkeleton extends StatelessWidget {
  final double itemWidth;
  final double itemHeight;
  MdoLearnerWidgetSkeleton(
      {required this.itemWidth, required this.itemHeight});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ContainerSkeleton(
          width: 220.w,
          height: 2.w,
          radius: 4.w,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16).w,
          child: ContainerSkeleton(
            width: 180.w,
            height: 32.w,
            radius: 4.w,
          ),
        ),
        ContainerSkeleton(
          width: 220.w,
          height: 2.w,
          radius: 4.w,
        ),
        Container(
          height: itemHeight,
          margin: const EdgeInsets.only(left: 16, top: 16, bottom: 16).w,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            children: [
              _mdoLearnerItem(),
              _mdoLearnerItem(),
              _mdoLearnerItem(),
            ],
          ),
        )
      ],
    );
  }

  Widget _mdoLearnerItem() {
    return Container(
      margin: const EdgeInsets.only(right: 16).w,
      padding:const EdgeInsets.symmetric(vertical: 16, horizontal: 16).w,
      width: itemWidth,
      decoration: BoxDecoration(
        color: ModuleColors.grey04,
        borderRadius: BorderRadius.all(Radius.circular(8.w)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 16).w,
                child: ContainerSkeleton(
                  width: 32.w,
                  height: 32.w,
                  radius: 100.w,
                ),
              ),
              Container(
                  width: 0.52.sw,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8).w,
                        child: Container(
                          margin: const EdgeInsets.only(right: 16).w,
                          child: ContainerSkeleton(
                            width: 0.5.sw,
                            height: 38.w,
                            radius: 4.w,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4).w,
                        child: ContainerSkeleton(
                          width: 0.5.sw,
                          height: 38.w,
                          radius: 4.w,
                        ),
                      ),
                    ],
                  )
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(left: 2, top: 8).w,
                child: ContainerSkeleton(
                  width: 20.w,
                  height: 20.w,
                  radius: 4.w,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 0),
                child: ContainerSkeleton(
                  width: 18.w,
                  height: 18.w,
                  radius: 4.w,
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 4),
                child: ContainerSkeleton(
                  width: 32.w,
                  height: 18.w,
                  radius: 4.w,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
