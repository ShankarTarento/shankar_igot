import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../../../../../constants/_constants/color_constants.dart';
import '../../../../skeleton/widgets/container_skeleton.dart';

class CommentViewSkeleton extends StatefulWidget {
  final int itemCount;
  CommentViewSkeleton({Key? key, this.itemCount = 1}) : super(key: key);

  _CommentViewSkeletonState createState() => _CommentViewSkeletonState();

}

class _CommentViewSkeletonState extends State<CommentViewSkeleton>
    with TickerProviderStateMixin {
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
    _controller!.repeat();
  }

  @override
  dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildLayout();
  }

  Widget _buildLayout() {
    return Container(
      child: AnimationLimiter(
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          itemCount: widget.itemCount,
          itemBuilder: (context, index) {
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                    child: _commentListItemWidgetSkeleton()
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _commentListItemWidgetSkeleton() {
    return Container(
        width: 1.sw,
        padding: EdgeInsets.only(top: 16, bottom: 8, left: 16, right: 16).w,
        margin: EdgeInsets.symmetric(vertical: 4).r,
        decoration: BoxDecoration(
          color: AppColors.appBarBackground,
          border: Border.all(color: AppColors.grey16),
          borderRadius: BorderRadius.all(Radius.circular(12.w)),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    ContainerSkeleton(
                      height: 32.w,
                      width: 32.w,
                      radius: 100.w,
                      color: animation.value!,
                    ),
                    Container(
                        padding: EdgeInsets.only(left: 8.0,).w,
                        child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: <Widget>[
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                    maxWidth: 200.w),
                                child: ContainerSkeleton(
                                  height: 20.w,
                                  width: 160.w,
                                  radius: 8.w,
                                  color: animation.value!,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 4).w,
                                child: ContainerSkeleton(
                                  height: 16.w,
                                  width: 80.w,
                                  radius: 8.w,
                                  color: animation.value!,
                                ),
                              ),

                            ]))
                  ]),
              Padding(
                padding: EdgeInsets.only(top: 12.0,).w,
                child: ContainerSkeleton(
                  height: 20.w,
                  width: 0.6.sw,
                  radius: 8.w,
                  color: animation.value!,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 12, top: 16.0).w,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 4).w,
                        child: ContainerSkeleton(
                          height: 24.w,
                          width: 46.w,
                          radius: 8.w,
                          color: animation.value!,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 4).w,
                        child: ContainerSkeleton(
                          height: 24.w,
                          width: 46.w,
                          radius: 8.w,
                          color: animation.value!,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 4).w,
                        child: ContainerSkeleton(
                          height: 24.w,
                          width: 86.w,
                          radius: 8.w,
                          color: animation.value!,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ]));
  }
}
