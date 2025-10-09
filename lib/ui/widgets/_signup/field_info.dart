import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/ui/widgets/_signup/contact_us.dart';

class FieldInfo extends StatelessWidget {
  const FieldInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        // insetPadding: EdgeInsets.symmetric(horizontal: 0),
        contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 24).r,
        content: SingleChildScrollView(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.25.r,
                      height: 1.5.w),
                  text:
                      'If you do not find your department or organization in the list here, please ',
                ),
                TextSpan(
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                      letterSpacing: 0.25.r,
                      height: 1.5.w),
                  text: 'contact us',
                  recognizer: TapGestureRecognizer()
                    ..onTap = (() => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ContactUs()),
                        )),
                ),
                TextSpan(
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp,
                      letterSpacing: 0.25.r,
                      height: 1.5.w),
                  text: ' to get it added.',
                ),
              ],
            ),
          ),
        ));
  }
}
