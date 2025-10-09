import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../constants/index.dart';

class DurationWidget extends StatelessWidget {
  final String duration;

  const DurationWidget(this.duration, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4).r,
      decoration: BoxDecoration(
        color: AppColors.greys87,
        borderRadius: BorderRadius.circular(6).r,
      ),
      child: Row(
        children: [
          Icon(
            Icons.access_time_sharp,
            color: AppColors.darkBlue,
            size: 20.sp,
          ),
          SizedBox(
            width: 2.w,
          ),
          Text(
            duration,
            style: Theme.of(context).textTheme.displaySmall!.copyWith(
                  fontSize: 12.sp,
                ),
          ),
        ],
      ),
    );
  }
}
