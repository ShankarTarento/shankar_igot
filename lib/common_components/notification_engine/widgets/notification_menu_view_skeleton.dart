import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NotificationMenuViewSkeleton extends StatefulWidget {
  const NotificationMenuViewSkeleton({super.key});

  @override
  State<NotificationMenuViewSkeleton> createState() =>
      _NotificationMenuViewSkeletonState();
}

class _NotificationMenuViewSkeletonState
    extends State<NotificationMenuViewSkeleton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.mNotifications,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.w),
          Row(
            children: [
              ContainerSkeleton(
                height: 40.w,
                width: 100.w,
              ),
              SizedBox(width: 8.w),
              ContainerSkeleton(
                height: 40.w,
                width: 100.w,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ContainerSkeleton(
            height: 65.w,
            width: double.infinity,
          ),
          SizedBox(height: 12.h),
          ContainerSkeleton(
            height: 65.w,
            width: double.infinity,
          ),
          SizedBox(height: 12.h),
          ContainerSkeleton(
            height: 65.w,
            width: double.infinity,
          ),
          SizedBox(height: 12.h),
          ContainerSkeleton(
            height: 65.w,
            width: double.infinity,
          ),
          SizedBox(height: 40.h),
          Center(
            child: ContainerSkeleton(
              height: 40.w,
              width: 100.w,
            ),
          ),
        ],
      ),
    );
  }
}
