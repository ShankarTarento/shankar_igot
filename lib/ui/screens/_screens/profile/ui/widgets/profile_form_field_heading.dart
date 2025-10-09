import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileFormFieldHeading extends StatelessWidget {
  final String text;
  const ProfileFormFieldHeading({Key? key, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8).r,
      child: Text(
        text,
        style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
            ),
      ),
    );
  }
}
