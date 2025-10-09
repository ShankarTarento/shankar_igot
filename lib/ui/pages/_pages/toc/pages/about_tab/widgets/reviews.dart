import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/models/_models/review_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/view_all_reviews.dart/view_all_reviews.dart';
import 'package:karmayogi_mobile/util/helper.dart';

import '../../../../../../../constants/index.dart';
import '../../../../../../../models/index.dart';

class Reviews extends StatelessWidget {
  final OverallRating reviewAndRating;
  final Course course;
  const Reviews({Key? key, required this.reviewAndRating, required this.course})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 10).r,
          child: Row(
            children: [
              Text(
                AppLocalizations.of(context)!.mStaticTopReviews,
                style: GoogleFonts.lato(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: ((context) => ViewAllReviews(
                            course: course,
                          )),
                    ),
                  );
                },
                child: Text(
                  AppLocalizations.of(context)!.mStaticShowAll,
                  style: GoogleFonts.lato(
                    fontSize: 14.sp,
                    color: AppColors.darkBlue,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              )
            ],
          ),
        ),
        // SizedBox(
        //   height: 16,
        // ),
        reviewAndRating.reviews!.isNotEmpty
            ? SizedBox(
                height: 112.w,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: reviewAndRating.reviews!.length,
                    itemBuilder: (context, index) => reviewCard(
                        index: index,
                        review: reviewAndRating.reviews![index],
                        context: context)),
              )
            : Container(
                padding: EdgeInsets.all(16).r,
                margin: EdgeInsets.only(top: 16, left: 16, right: 16).r,
                width: 1.sw,
                decoration: BoxDecoration(
                  color: AppColors.appBarBackground,
                  borderRadius: BorderRadius.circular(8).r,
                ),
                child: Text(
                  AppLocalizations.of(context)!.mStaticNoReviewsFound,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
        SizedBox(
          height: 16.w,
        ),
      ],
    );
    // : Column(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       Text(
    //         "Top reviews",
    //         style: GoogleFonts.lato(
    //           fontSize: 16,
    //           fontWeight: FontWeight.w700,
    //         ),
    //       ),

    //     ],
    //   );
  }

  Widget reviewCard(
      {required Review review,
      required BuildContext context,
      required int index}) {
    return Container(
      height: 112.w,
      width: 1.sw / 1.2,
      padding: EdgeInsets.all(16).r,
      margin: EdgeInsets.only(right: 16, left: index == 0 ? 16 : 0).r,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8).r,
        color: AppColors.appBarBackground,
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12.r,
                backgroundColor: AppColors.greenOne,
                child: Text(
                  Helper.getInitials(review.firstName!),
                  style: GoogleFonts.lato(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.appBarBackground,
                  ),
                ),
              ),
              SizedBox(
                width: 8.w,
              ),
              Flexible(
                child: Text(
                  review.firstName!,
                  style: GoogleFonts.lato(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.greys.withValues(alpha: 0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8).r,
                child: CircleAvatar(
                  radius: 1.r,
                  backgroundColor: AppColors.greys.withValues(alpha: 0.6),
                ),
              ),
              Text(
                getReviewTime(review.date.toString(), context),
                style: GoogleFonts.lato(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.greys.withValues(alpha: 0.6),
                ),
              ),
              Spacer(),
              Icon(
                Icons.star,
                color: AppColors.verifiedBadgeIconColor,
                size: 16.sp,
              ),
              SizedBox(
                width: 2.w,
              ),
              Text(
                review.rating.toString(),
                style: GoogleFonts.lato(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.greys.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 8.w,
          ),
          Flexible(
            child: Text(
              review.review ?? '',
              style: GoogleFonts.lato(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.greys,
                  height: 1.5.w),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          )
        ],
      ),
    );
  }

  String getReviewTime(String time, BuildContext context) {
    DateTime now = DateTime.now();
    DateTime reviewTime = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    Duration difference = now.difference(reviewTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${AppLocalizations.of(context)!.mStaticMinutesAgo}';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${AppLocalizations.of(context)!.mStaticHoursAgo}';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} ${AppLocalizations.of(context)!.mStaticDaysAgo}';
    } else {
      int months =
          (now.year - reviewTime.year) * 12 + now.month - reviewTime.month;
      return '$months ${AppLocalizations.of(context)!.mHomeDiscussionMonthsAgo}';
    }
  }
}
