import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../constants/index.dart';
import '../../../../widgets/index.dart';

class TotalRatingWidget extends StatelessWidget {
  final List<dynamic>? additionalTags;
  final String noOfRating;
  final String rating;
  const TotalRatingWidget(
      {Key? key,
      required this.rating,
      required this.noOfRating,
      this.additionalTags})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: rating != '0.0' && noOfRating != '0.0'
            ? Row(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        color: AppColors.greys60,
                        borderRadius: BorderRadius.circular(63).r),
                    padding: EdgeInsets.all(8).r,
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            right: rating != '0.0' ? 5 : 0,
                          ).r,
                          child: rating != '0.0'
                              ? Icon(
                                  Icons.star,
                                  size: 16.sp,
                                  color: AppColors.primaryOne,
                                )
                              : Center(),
                        ),
                        Text(
                          rating,
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall!
                              .copyWith(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.25,
                              ),
                        ),
                        Container(
                          height: 20.w,
                          width: 2.w,
                          color: AppColors.white016,
                          margin: EdgeInsets.symmetric(horizontal: 7).r,
                        ),
                        Text(
                          noOfRating,
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall!
                              .copyWith(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.25,
                              ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  additionalTags!.isNotEmpty
                      ? Expanded(
                          child: SizedBox(
                            height: 20.w,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: additionalTags!.length,
                                itemBuilder: (BuildContext context, index) {
                                  return Container(
                                      margin: EdgeInsets.only(left: 4).r,
                                      padding: EdgeInsets.symmetric(
                                              vertical: 2, horizontal: 4)
                                          .r,
                                      decoration: BoxDecoration(
                                        color: AppColors.yellowShade,
                                        borderRadius:
                                            BorderRadius.circular(2).r,
                                      ),
                                      child: Center(
                                        child: TitleRegularGrey60(
                                          getTagsText(
                                              context,
                                              additionalTags![index]
                                                  .toString()),
                                          color: AppColors.enrollLabelGrey,
                                          fontSize: 10.sp,
                                        ),
                                      ));
                                }),
                          ),
                        )
                      : Center(),
                ],
              )
            : SizedBox.shrink());
  }

  String getTagsText(BuildContext context, String tag) {
    switch (tag) {
      case 'mostEnrolled':
        return AppLocalizations.of(context)!.mStaticMostEnrolled;

      case 'mostTreanding':
        return AppLocalizations.of(context)!.mHomeLabelMostTrending;

      default:
        return tag;
    }
  }
}
