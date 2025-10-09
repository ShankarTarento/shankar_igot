import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../constants/index.dart';

class ProfileEditHeader extends StatelessWidget {
  final String title;
  final VoidCallback callback;

  const ProfileEditHeader(
      {super.key, required this.title, required this.callback});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        InkWell(
            onTap: () => callback(),
            child: Padding(
                padding: EdgeInsets.only(left: 20).r,
                child: Icon(Icons.close,
                    size: 24.sp, color: AppColors.disabledTextGrey)))
      ],
    );
  }
}
