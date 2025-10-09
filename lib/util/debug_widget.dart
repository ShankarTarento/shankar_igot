import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/_constants/app_constants.dart';
import '../constants/_constants/color_constants.dart';

class DebugWidget extends StatelessWidget {
  final Widget widget;
  const DebugWidget({Key? key, required this.widget}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget,
        Positioned(
          top: 20.w,
          right: 0,
          child: Container(
            height: 20.w,
            padding: EdgeInsets.all(4).r,
            color: AppColors.darkBlue,
            child: Text(
              getEnv(text: APP_ENVIRONMENT),
              style: TextStyle(
                color: AppColors.appBarBackground,
                fontSize: 12.sp,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String getEnv({required String text}) {
    List<String> parts = text.split(".");

    String result = parts.last;

    return "${result.toUpperCase()} $APP_VERSION";
  }
}
