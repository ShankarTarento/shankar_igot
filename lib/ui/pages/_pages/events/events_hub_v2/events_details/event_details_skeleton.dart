import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';

class EventDetailsSkeleton extends StatelessWidget {
  const EventDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.appBarBackground,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_sharp, size: 24.sp, color: AppColors.greys60),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 8.0).r,
                child: Icon(
                  Icons.share,
                  color: AppColors.darkBlue,
                )
              )
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.only(left: 8, right: 8, bottom: 20, top: 8).r,
          child: ContainerSkeleton(
            radius: 40.r,
            height: 60.w,
            width: double.infinity,
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: 1.sw,
                height: 1.sh,
                padding: EdgeInsets.all(10).r,
                decoration: BoxDecoration(
                  color: AppColors.scaffoldBackground,
                  borderRadius: BorderRadius.circular(8).r,
                ),
                child: Container(
                    padding: EdgeInsets.all(10).r,
                    decoration: BoxDecoration(
                      color: AppColors.appBarBackground,
                      borderRadius: BorderRadius.circular(8).r,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ContainerSkeleton(
                          height: 300.w,
                          width: double.infinity,
                        ),
                        SizedBox(
                          height: 16.w,
                        ),
                        ContainerSkeleton(
                          height: 55.w,
                          width: 0.95.sw,
                        ),
                        SizedBox(
                          height: 16.w,
                        ),
                        ContainerSkeleton(
                          height: 55.w,
                          width: 0.7.sw,
                        ),
                        SizedBox(
                          height: 16.w,
                        ),
                        ContainerSkeleton(
                          height: 55.w,
                          width: 0.8.sw,
                        ),
                        SizedBox(
                          height: 16.w,
                        ),
                        ContainerSkeleton(
                          height: 55.w,
                          width: 0.5.sw,
                        ),
                        SizedBox(
                          height: 40.w,
                        ),
                        ContainerSkeleton(
                          height: 55.w,
                          width: double.infinity,
                        ),
                        SizedBox(
                          height: 20.w,
                        ),
                        ContainerSkeleton(
                          height: 55.w,
                          width: double.infinity,
                        ),
                      ],
                    )),
              )
            ],
          ),
        ));
  }
}
