import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';

import '../../../../../../constants/index.dart';

class EventPlayerV2Skeleton extends StatelessWidget {
  const EventPlayerV2Skeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            size: 24.sp,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16).r,
              child: ContainerSkeleton(
                width: double.infinity,
                height: 260.w,
                radius: 4.w,
              ),
            ),
            Expanded(
                child: Container(
                    width: 1.sw,
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.all(16).r,
                    margin: EdgeInsets.fromLTRB(16, 8, 16, 32).r,
                    decoration: BoxDecoration(
                      color: AppColors.appBarBackground,
                      borderRadius:
                          BorderRadius.all(const Radius.circular(12.0)).r,
                    ),
                    child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(
                            children: List.generate(
                          2,
                          (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 40.0).r,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding:
                                          EdgeInsets.only(bottom: 4, right: 8)
                                              .r,
                                      child: ContainerSkeleton(
                                        width: 32.w,
                                        height: 40.w,
                                        radius: 12.w,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 8).r,
                                      child: ContainerSkeleton(
                                        width: 0.5.sw,
                                        height: 40.w,
                                        radius: 12.w,
                                      ),
                                    ),
                                    Spacer(),
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 8).r,
                                      child: ContainerSkeleton(
                                        width: 55.w,
                                        height: 40.w,
                                        radius: 12.w,
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.only(bottom: 8).r,
                                  child: ContainerSkeleton(
                                    width: 1.sw,
                                    height: 80.w,
                                    radius: 12.w,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Padding(
                                      padding:
                                          EdgeInsets.only(bottom: 8, right: 16)
                                              .r,
                                      child: ContainerSkeleton(
                                        width: 0.3.sw,
                                        height: 40.w,
                                        radius: 12.w,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 8).r,
                                      child: ContainerSkeleton(
                                        width: 0.4.sw,
                                        height: 40.w,
                                        radius: 12.w,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )))))
          ],
        ),
      ),
    );
  }
}
