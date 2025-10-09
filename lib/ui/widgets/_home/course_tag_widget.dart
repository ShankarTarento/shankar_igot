import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CourseTagWidget extends StatelessWidget {
  final String tag;
  final Widget? prefix;
  final Color bgColor;
  final Color textColor;
  final Decoration? backgroundDecoration;

  const CourseTagWidget({Key? key, required this.tag, this.prefix, required this.bgColor, required this.textColor, this.backgroundDecoration}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: backgroundDecoration ?? BoxDecoration(),
      padding: EdgeInsets.all((backgroundDecoration != null) ? 8 : 4).r,
      child: Container(
        padding: EdgeInsets.all(4).r,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6).r,
        ),
        child: Row(
          children: [
            if (prefix != null) prefix!,
            SizedBox(
              width: 2.w,
            ),
            Text(
              tag,
              style: Theme.of(context).textTheme.displaySmall!.copyWith(
                fontSize: 12.sp,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
