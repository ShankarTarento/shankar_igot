import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../constants/index.dart';
import '../../../../../models/index.dart';
import '../../../../widgets/buttons/button_with_border.dart';

class PostEnrollLanguageChangeWidget extends StatelessWidget {
  final Course course;
  final VoidCallback changeSelectionCallback;
  final String title;
  final String description1;
  final String description2;
  final String button1;
  final String button2;
  const PostEnrollLanguageChangeWidget(
      {super.key,
      required this.course,
      required this.changeSelectionCallback,
      required this.title,
      this.description1 = '',
      this.description2 = '',
      required this.button1,
      required this.button2});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 48).r,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.translate,
            size: 40.sp,
            color: AppColors.darkBlue,
          ),
          SizedBox(height: 16.w),
          const Divider(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(color: AppColors.deepBlue),
              ),
              description1.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8.0).r,
                      child: Text(
                        description1,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(color: AppColors.greys60),
                      ),
                    )
                  : Center(),
              description2.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8.0).r,
                      child: Text(
                        description2,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(color: AppColors.greys60),
                      ),
                    )
                  : Center()
            ],
          ),
          SizedBox(height: 24.w),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ButtonWithBorder(
                  onPressCallback: () {
                    Navigator.of(context).pop();
                  },
                  text: button1,
                  borderRadius: 4,
                  padding: EdgeInsets.symmetric(horizontal: 16).r),
              SizedBox(width: 8.w),
              ButtonWithBorder(
                  onPressCallback: () {
                    changeSelectionCallback();
                    Navigator.of(context).pop();
                  },
                  text: button2,
                  bgColor: AppColors.darkBlue,
                  padding: EdgeInsets.symmetric(horizontal: 16).r,
                  textStyle: Theme.of(context).textTheme.displaySmall,
                  borderRadius: 4),
            ],
          ),
        ],
      ),
    );
  }
}
