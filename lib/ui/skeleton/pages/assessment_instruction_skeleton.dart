import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/index.dart';
import '../../../feedback/constants.dart';

class AssessmentInstructionSkeleton extends StatefulWidget {
  final String primaryCategory;
  const AssessmentInstructionSkeleton({Key? key, required this.primaryCategory})
      : super(key: key);
  AssessmentInstructionSkeletonState createState() =>
      AssessmentInstructionSkeletonState();
}

class AssessmentInstructionSkeletonState
    extends State<AssessmentInstructionSkeleton>
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
    _controller!.repeat();
  }

  @override
  dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.w),
        child: Container(
          decoration: BoxDecoration(
            color: animation.value,
            border: Border(
              bottom: BorderSide(
                color: AppColors.grey16,
                width: 2.0,
              ),
            ),
          ),
          child: AppBar(
            backgroundColor: AppColors.scaffoldBackground,
            automaticallyImplyLeading: false,
            shadowColor: Colors.transparent,
            toolbarHeight: 70.w,
            leading: InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Icon(
                Icons.arrow_back_ios,
                color: AppColors.greys87,
                size: 24.w,
              ),
            ),
            title: Padding(
                padding: EdgeInsets.symmetric(vertical: 20).r,
                child: Row(
                  children: [
                    Expanded(child: _cardHeadingItems()),
                    SizedBox(
                        width: 1.sw / 2,
                        child: Container(
                            height: 70.w,
                            padding: EdgeInsets.fromLTRB(16, 16, 0, 16).r,
                            child: Container(
                                height: 58.w,
                                width: 1.sw - 35.w,
                                decoration:
                                    BoxDecoration(color: animation.value))))
                  ],
                )),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20).r,
            child: SingleChildScrollView(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    height: 58.w,
                    width: 0.7.sw,
                    decoration: BoxDecoration(color: animation.value)),
                SizedBox(
                  height: 32.w,
                ),
                Container(
                    height: 100.w,
                    width: 1.sw,
                    padding: EdgeInsets.all(16).r,
                    decoration: BoxDecoration(color: animation.value)),
                SizedBox(
                  height: 32.w,
                ),
                Row(
                  children: [
                    Container(
                      width: 20.w,
                      height: 20.w,
                      decoration: BoxDecoration(
                          border: Border.all(color: AppColors.grey40)),
                    ),
                    SizedBox(width: 12.w),
                    SizedBox(
                      width: 0.8.sw,
                      child: Container(
                          height: 100.w,
                          width: 1.sw,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(color: animation.value)),
                    ),
                  ],
                ),
              ],
            )),
          ),
        ],
      ),
    );
  }

  Widget _cardHeadingItems() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: (widget.primaryCategory == PrimaryCategory.practiceAssessment
              ? practiceScenario4summary(context)
              : scenario4summary(context))
          .map(
            (informationCard) =>
                _headingItem(informationCard.icon, AppColors.black40),
          )
          .toList(),
    );
  }

  Widget _headingItem(IconData icon, Color iconColor) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8).r,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20.sp, color: iconColor),
            Padding(
              padding: const EdgeInsets.only(top: 4).r,
              child: Container(
                width: 0.7.sw,
                color: animation.value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
