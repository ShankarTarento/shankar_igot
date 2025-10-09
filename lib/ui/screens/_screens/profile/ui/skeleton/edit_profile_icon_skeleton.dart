import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditProfileIconSkeleton extends StatelessWidget {
  final double? height;
  final double? width;
  final double? radius;
  final Color? color;

  const EditProfileIconSkeleton(
      {Key? key, this.height, this.width, this.radius, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(100.w)),
      child: Container(
        width: width ?? 0.2.sw,
        height: height ?? 0.2.sw,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
