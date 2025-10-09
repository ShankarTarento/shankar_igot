import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';
import '../../../../../../../../../../constants/_constants/color_constants.dart';

class MdoCertificateOfWeekSkeleton extends StatefulWidget {
  const MdoCertificateOfWeekSkeleton({Key? key}) : super(key: key);
  _MdoCertificateOfWeekSkeletonState createState() =>
      _MdoCertificateOfWeekSkeletonState();
}

class _MdoCertificateOfWeekSkeletonState
    extends State<MdoCertificateOfWeekSkeleton>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  late Animation<Color?> animation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    animation = TweenSequence<Color?>(
      [
        TweenSequenceItem(
          weight: 1.0,
          tween: ColorTween(
            begin: AppColors.grey04,
            end: AppColors.grey08,
          ),
        ),
        TweenSequenceItem(
          weight: 1.0,
          tween: ColorTween(
            begin: AppColors.grey04,
            end: AppColors.grey08,
          ),
        ),
      ],
    ).animate(_controller!)
      ..addListener(() {
        setState(() {});
      });
    _controller?.repeat();
  }

  @override
  dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 300.w,
          width: double.infinity,
          margin: const EdgeInsets.only(
            top: 5,
          ).w,
          child: Stack(
            children: [
              Positioned(
                child: Align(
                  alignment: FractionalOffset.topCenter,
                  child: _certificateView(color: animation.value!),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _certificateView({Color? color}) {
    return Container(
        height: 280.w,
        width: double.maxFinite,
        margin: EdgeInsets.only(left: 16, right: 16).w,
        decoration: BoxDecoration(
            color: AppColors.grey08, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ContainerSkeleton(
              height: 135.w,
              width: 1.sw,
            ),
            SizedBox(height: 8.w),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16).w,
              child: ContainerSkeleton(height: 25.w, width: 150.w),
            ),
            SizedBox(height: 8.w),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16).w,
                child: ContainerSkeleton(
                  height: 25.w,
                  width: 200.w,
                )),
            SizedBox(height: 8.w),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16).w,
                child: Row(children: [
                  ContainerSkeleton(
                    height: 25.w,
                    width: 25.w,
                  ),
                  SizedBox(width: 4.w),
                  ContainerSkeleton(
                    height: 25.w,
                    width: 150.w,
                  )
                ])),
            SizedBox(height: 8.w),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16).w,
                child: ContainerSkeleton(
                  height: 25.w,
                  width: 150.w,
                ))
          ],
        ));
  }
}
