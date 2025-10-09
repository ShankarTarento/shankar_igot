import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/ui/widgets/_interests/bulletList.dart';

class ActivitiesInfo extends StatelessWidget {
  const ActivitiesInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 0).r,
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "What is an activity?",
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
              "Activities are a set of actions taken to contribute towards the various roles one performs within a position",
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
              "Activities speak directly to the execution capacity of an individual public official by providing details on the mandate of their position, and how it is distinguished from other positions in the government.",
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
              'Role: Ensures inclusion and accuracy of facts in vigilance related proposals',
              'Activities:',
            ]),
            Padding(
              padding: const EdgeInsets.only(left: 16).r,
              child: BulletList(
                [
                  'Checks the facts with regards to proposal keeping in mind existing rules, provisions, and legal precedents',
                  'Supplies missing facts to a proposal if any information is missing',
                  'Supports drafting of proposals',
                  'Quotes previous precedents by referring to existing rules'
                ],
                hasSubBullets: true,
              ),
            ),
            SizedBox(
              height: 32.w,
            ),
          ],
        ),
      ),
    );
  }
}
