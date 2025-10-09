import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/ui/widgets/_home/duration_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/custom_image_widget.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';

import '../../../../../../../../constants/index.dart';

class EventCardImage extends StatelessWidget {
  final String imageUrl;
  final bool isLive;
  final int? duration;
  const EventCardImage(
      {super.key, this.isLive = false, required this.imageUrl, this.duration});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8).r, topRight: Radius.circular(8).r),
          child: ImageWidget(
            imageUrl: imageUrl,
          ),
        ),
        isLive
            ? Positioned(
                child: Container(
                color: AppColors.appBarBackground.withValues(alpha: 0.4),
                child: Center(
                  child: Container(
                    height: 32.w,
                    width: 75.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20).r,
                      color: AppColors.mandatoryRed,
                    ),
                    child: Center(
                      child: Text(
                        "Live",
                        style: TextStyle(
                            color: AppColors.appBarBackground,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ))
            : duration != null
                ? Positioned(
                    right: 3,
                    bottom: 3,
                    child: DurationWidget(
                      DateTimeHelper.getTimeFormatInHrs(duration!),
                    ))
                : SizedBox()
      ],
    );
  }
}
