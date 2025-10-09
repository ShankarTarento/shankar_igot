import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../constants/index.dart';

class LanguageWidget extends StatelessWidget {
  final String language;

  const LanguageWidget(this.language, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(4).r,
        decoration: BoxDecoration(
          color: AppColors.greys87,
          borderRadius: BorderRadius.circular(6).r,
        ),
        child: Text(
          language,
          style: Theme.of(context).textTheme.displaySmall!.copyWith(
                fontSize: 12.sp,
              ),
        ));
  }
}
