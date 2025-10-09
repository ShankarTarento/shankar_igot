import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import './../../../../constants/index.dart';
import './../../../../ui/widgets/index.dart';

class CourseVideoAssessment extends StatefulWidget {
  @override
  _CourseVideoAssessmentState createState() {
    return _CourseVideoAssessmentState();
  }
}

class _CourseVideoAssessmentState extends State<CourseVideoAssessment> {
  int questionIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          leading: IconButton(
            icon: Icon(Icons.clear, color: AppColors.greys60),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text('Agile methodology',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontFamily: GoogleFonts.montserrat().fontFamily,
                  )),
        ),
        body: questionIndex > 2
            ? HomepageAssessmentCompleted()
            : ASSESSMENT_QUESTIONS[questionIndex].questionType ==
                    QuestionTypes.singleAnswer
                ? SingleAnswerQuestion(ASSESSMENT_QUESTIONS[questionIndex])
                : Center(),
        bottomSheet: Container(
          height: questionIndex > 2 ? 0.w : 58.w,
          padding: const EdgeInsets.fromLTRB(20, 5, 20, 5).r,
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                width: 1.sw / 2 - 20.w,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      questionIndex++;
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.customBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4).r,
                        side: BorderSide(color: AppColors.grey16)),
                  ),
                  child: Text(
                    questionIndex < 2 ? 'Next' : 'Finish',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
