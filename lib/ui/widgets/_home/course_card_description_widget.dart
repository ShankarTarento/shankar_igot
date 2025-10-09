import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/index.dart';
import '../../../models/index.dart';

class CourseCardDescriptionWidget extends StatelessWidget {
  const CourseCardDescriptionWidget({
    super.key,
    required this.course,
    required this.isFeatured,
  });

  final Course course;
  final bool isFeatured;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        //Course name
        Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.fromLTRB(16, 8, 16, 12).r,
          child: Text(
            course.name.isNotEmpty ? course.name : course.raw['courseName'],
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.displayLarge,
          ),
        ),
        //Source
        Row(
          children: [
            Container(
              margin: EdgeInsets.only(left: 16, top: 0).r,
              decoration: BoxDecoration(
                  color: AppColors.appBarBackground,
                  border: Border.all(color: AppColors.grey16, width: 1),
                  borderRadius: BorderRadius.all(const Radius.circular(4.0)).r),
              child: Image.network(
                course.creatorLogo,
                height: 16.w,
                width: 16.w,
                fit: BoxFit.cover,
                cacheWidth: 16,
                cacheHeight: 16,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/img/igot_creator_icon.png',
                  height: 16.w,
                  width: 16.w,
                ),
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.only(left: 4, right: 4).r,
                child: Text(
                  course.source != '' ? 'By ' + course.source : '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium!
                      .copyWith(color: AppColors.greys60),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
