import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/ui/widgets/_interests/bulletList.dart';

class CompetenciesInfo extends StatelessWidget {
  const CompetenciesInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 0).r,
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "What are competencies?",
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
              '''Competencies are a combination of attitudes, skills, and knowledge that enable an individual to perform a task or activity successfully in a given job and roles are the starting point for arriving at them.     
There are three types of competencies: Behavioral, Functional and Domain''',
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
              "Competencies help with:",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    height: 1.5.w,
                    letterSpacing: 0.25.r,
                  ),
            ),
            BulletList([
              'Providing information on individual requirements from a role',
              'Identifying learning and development needs for government officials',
              'Streamlining the recruitment process'
            ]),
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
              '''Competency Label: Noting and Drafting
Competency Type: Functional
Description: Drafts and analyses a note, in order, in order to move a proposal for
decision making on the availability of evidence and existing rules and precedents.''',
              '''Competency Label: Communication Skills
Competency Type: Behavioral
Description: Articulates information to others in a language that is clear, concise, and easy to understand. It also includes the ability to listen and understand the unspoken feelings and concerns of others.''',
              '''Competency Label: Regulatory and Legal Advisory
Competency Type: Domain
Description: Provides advice to business and management stakeholders on regulatory compliance and legal matters related to support business decision making'''
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
