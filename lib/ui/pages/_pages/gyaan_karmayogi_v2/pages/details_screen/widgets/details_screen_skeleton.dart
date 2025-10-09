import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';

class DetailsScreenSkeleton extends StatelessWidget {
  const DetailsScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ContainerSkeleton(
              height: 180.w,
              width: double.infinity,
            ),
            SizedBox(height: 16.w),
            Padding(
              padding: const EdgeInsets.all(12.0).r,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ContainerSkeleton(
                    height: 200.w,
                    width: double.infinity,
                  ),
                  SizedBox(height: 16.w),
                  ContainerSkeleton(
                    height: 24.w,
                    width: 0.9.sw,
                  ),
                  SizedBox(height: 16.w),
                  ContainerSkeleton(
                    height: 24.w,
                    width: 0.7.sw,
                  ),
                  SizedBox(height: 16.w),
                  ContainerSkeleton(
                    height: 24.w,
                    width: 0.5.sw,
                  ),
                  SizedBox(height: 16.w),
                  ContainerSkeleton(
                    height: 24.w,
                    width: 0.8.sw,
                  ),
                  SizedBox(height: 32.w),
                  ContainerSkeleton(
                    height: 24.w,
                    width: 0.3.sw,
                  ),
                  SizedBox(height: 16.w),
                  ContainerSkeleton(
                    height: 80.w,
                    width: 0.7.sw,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
