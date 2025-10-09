import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../respositories/_respositories/learn_repository.dart';

class CourseRatingSubmitted extends StatefulWidget {
  final String? title, courseId, primaryCategory;

  CourseRatingSubmitted({this.title, this.courseId, this.primaryCategory});
  @override
  _CourseRatingSubmittedState createState() => _CourseRatingSubmittedState();
}

class _CourseRatingSubmittedState extends State<CourseRatingSubmitted> {
  int count = 0;
  @override
  void initState() {
    super.initState();
    if (widget.courseId != null && widget.primaryCategory != null) {
      updateRating();
    }
  }

  @override
  Widget build(BuildContext context) {
    // super.build(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.clear, color: AppColors.greys60),
          onPressed: () {
            // Navigator.of(context).pop()
            Navigator.popUntil(context, (route) {
              return count++ == 2;
            });
          },
        ),
        title: Text(
          widget.title!,
          style: GoogleFonts.montserrat(
            color: AppColors.greys87,
            fontSize: 16.0.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        // centerTitle: true,
      ),
      // Tab controller

      body: SingleChildScrollView(
          child: Container(
        width: double.infinity.w,
        height: 1.sh,
        padding: const EdgeInsets.all(20).r,
        color: AppColors.lightBackground,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.only(top: 30).r,
                child: SvgPicture.asset(
                  'assets/img/rating.svg',
                  fit: BoxFit.cover,
                )),
            Padding(
              padding: const EdgeInsets.only(top: 50).r,
              child: Text(
                AppLocalizations.of(context)!.mCommonthankYouForFeedback,
                style: GoogleFonts.lato(
                  color: AppColors.greys87,
                  fontSize: 16.0.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15).r,
              child: Text(
                AppLocalizations.of(context)!.mCourseYouCanUpdateRating,
                style: GoogleFonts.lato(
                  color: AppColors.greys60,
                  fontSize: 16.0.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      )),
      bottomSheet: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        child: Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10).r,
            decoration:
                BoxDecoration(color: AppColors.appBarBackground, boxShadow: [
              BoxShadow(
                color: AppColors.grey08,
                blurRadius: 6.0.r,
                spreadRadius: 0.r,
                offset: Offset(
                  0,
                  -3,
                ),
              ),
            ]),
            child: ScaffoldMessenger(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) {
                        return count++ == 2;
                      });
                    },
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.fromLTRB(40, 15, 40, 15).r,
                        backgroundColor: AppColors.darkBlue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4).r,
                            side: BorderSide(color: AppColors.grey16))),
                    child: Text(
                      AppLocalizations.of(context)!.mStaticDone,
                      style: GoogleFonts.lato(
                        color: AppColors.appBarBackground,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }

  Future<void> updateRating() async {
    await getYourRatingAndReview();
    await getReviews();
  }

  Future<void> getYourRatingAndReview() async {
    await Provider.of<LearnRepository>(context, listen: false).getYourReview(
        id: widget.courseId!,
        primaryCategory: widget.primaryCategory!,
        forceUpdate: true);
  }

  Future<void> getReviews() async {
    await Provider.of<LearnRepository>(context, listen: false)
        .getCourseReviewSummery(
            courseId: widget.courseId!,
            primaryCategory: widget.primaryCategory!,
            forceUpdate: true);
  }
}
