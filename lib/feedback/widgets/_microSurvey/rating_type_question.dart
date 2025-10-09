import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import './../../constants.dart';

class RatingTypeQuestion extends StatefulWidget {
  final question;
  final int currentIndex;
  final answerGiven;
  final ValueChanged<Map> parentAction;

  RatingTypeQuestion(
      this.question, this.currentIndex, this.answerGiven, this.parentAction);
  @override
  _RatingTypeQuestionState createState() => _RatingTypeQuestionState();
}

class _RatingTypeQuestionState extends State<RatingTypeQuestion> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(32).r,
        width: 1.sw,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 15).r,
              child: Text(
                widget.question.question,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            RatingBar.builder(
              unratedColor: FeedbackColors.unRatedColor,
              initialRating: widget.question.answer != null
                  ? widget.question.answer
                  : (widget.answerGiven != null ? widget.answerGiven : 0),
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemSize: 50,
              itemPadding: EdgeInsets.symmetric(horizontal: 0.0).r,
              itemBuilder: (context, _) => Icon(
                Icons.star_rounded,
                color: FeedbackColors.ratedColor,
              ),
              onRatingUpdate: (rating) {
                Future.delayed(const Duration(milliseconds: 250), () {
                  widget.parentAction({
                    'index': widget.question.id - 1,
                    'question': widget.question.question,
                    'value': rating
                  });
                });
              },
            ),
          ],
        ));
  }
}
