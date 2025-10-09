import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/ui/widgets/_interests/bulletList.dart';

class RolesInfo extends StatelessWidget {
  const RolesInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 0).r,
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "What is Role?",
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  height: 1.5.w,
                  letterSpacing: 0.12.r,
                  fontWeight: FontWeight.w700),
            ),
            SizedBox(
              height: 8.w,
            ),
            Text(
              "Roles describe the overall objective of a group of activities and how they contribute to the position.",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    height: 1.5.w,
                    letterSpacing: 0.25.r,
                  ),
            ),
            SizedBox(
              height: 32.w,
            ),
            Text(
              "Why is it important?",
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.5.w,
                    letterSpacing: 0.12.r,
                  ),
            ),
            SizedBox(
              height: 8.w,
            ),
            Text(
              "Roles help understand the mandate of a position. There could be similar positions across the government, but differentiated by the roles they form. Roles help articulate these distinctions by highlighting why the position exists and how it works towards larger organisational goals and priorities.",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    height: 1.5.w,
                    letterSpacing: 0.25.r,
                  ),
            ),
            SizedBox(
              height: 32.w,
            ),
            Text(
              "Example:",
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.5.w,
                    letterSpacing: 0.12.r,
                  ),
            ),
            SizedBox(
              height: 8.w,
            ),
            BulletList([
              'Ensures inclusion and accuracy of facts in vigilance proposals.',
              'Coordinates and manages relationships with various stakeholders',
              'Manages grievance redressal mechanisms'
            ]),
            SizedBox(
              height: 32.w,
            ),
          ],
        ),
      ),
    );
  }
}
