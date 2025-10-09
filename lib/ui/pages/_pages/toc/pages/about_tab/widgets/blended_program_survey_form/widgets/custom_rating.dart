import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/feedback/constants.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/field_name_widget.dart';

class CustomStarRating extends StatelessWidget {
  final String title;
  final bool isMandatory;
  final ValueChanged<double> onRatingUpdate;

  const CustomStarRating({
    Key? key,
    required this.title,
    required this.isMandatory,
    required this.onRatingUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldNameWidget(isMandatory: isMandatory, fieldName: title),
        SizedBox(
          height: 8.w,
        ),
        RatingBar.builder(
          unratedColor: AppColors.grey16,
          initialRating: 0,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: false,
          itemCount: 5,
          itemSize: 30,
          itemPadding: EdgeInsets.symmetric(horizontal: 0.0).r,
          itemBuilder: (context, _) => Icon(
            Icons.star_rounded,
            color: FeedbackColors.ratedColor,
          ),
          onRatingUpdate: (rate) {
            onRatingUpdate(rate);
          },
        ),
      ],
    );
  }
}
