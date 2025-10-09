import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:simple_moment/simple_moment.dart';
import './../../../constants/index.dart';
import './../../../util/helper.dart';
// import 'dart:developer' as developer;

class Review extends StatefulWidget {
  final String name;
  final double rating;
  final String description;
  final int? updatedOn;
  final String courseId;
  final String primaryCategory;
  final String userId;
  final String comment;
  final String review;

  Review(
      {required this.name,
      required this.rating,
      required this.description,
      this.updatedOn,
      required this.courseId,
      required this.primaryCategory,
      required this.comment,
      required this.review,
      required this.userId});

  @override
  State<Review> createState() => _ReviewState();
}

class _ReviewState extends State<Review> {
  final dateNow = Moment.now();
  bool _isShowReply = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.appBarBackground,
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 5.0, top: 4).r,
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 25).r,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 16, left: 10).r,
                  child: Container(
                    height: 48.w,
                    width: 48.w,
                    decoration: BoxDecoration(
                      color: AppColors.positiveLight,
                      borderRadius:
                          BorderRadius.all(const Radius.circular(4.0)).r,
                    ),
                    child: Center(
                      child: Text(Helper.getInitials(widget.name),
                          style: GoogleFonts.lato(
                              color: AppColors.appBarBackground)),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10.0).r,
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(right: 5).r,
                                child: Text(
                                  widget.rating.toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                          color: AppColors.orangeBackground),
                                ),
                              ),
                              RatingBar.builder(
                                initialRating: widget.rating,
                                minRating: 1,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                itemSize: 20,
                                itemPadding:
                                    EdgeInsets.symmetric(horizontal: 0.0).r,
                                itemBuilder: (context, _) => Icon(
                                  Icons.star,
                                  color: AppColors.primaryOne,
                                ),
                                onRatingUpdate: (rating) {
                                  // print(rating);
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10).r,
                                child: Text(
                                  widget.updatedOn != null
                                      ? dateNow
                                          .from(DateTime
                                              .fromMillisecondsSinceEpoch(
                                                  widget.updatedOn!))
                                          .toString()
                                      : 'Invalid date',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall!
                                      .copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 0.7.sw,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10).r,
                            child: Text(
                              widget.description,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                        Visibility(
                          visible: widget.comment.isNotEmpty,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 16).r,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _isShowReply = !_isShowReply;
                                    });
                                  },
                                  child: Text(
                                    !_isShowReply ? 'View reply' : 'Hide reply',
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ),
                              Visibility(
                                  visible: _isShowReply,
                                  child: Container(
                                    width: 1.sw - 100.w,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 16).r,
                                      child: Text(_isShowReply
                                          ? widget.comment
                                          : widget.review),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
