import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'dart:async';
import '../../../../services/_services/learn_service.dart';
import '../../../../ui/pages/_pages/toc/view_model/toc_player_view_model.dart';
import '../../../services/micro_survey_service.dart';
import './../../../constants.dart';
import './../../../models/micro_survey_model.dart';
import './../../../widgets/index.dart';
import './../../../../constants/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SurveyPage extends StatefulWidget {
  final Map? microSurvey;
  final String surveyName;
  final CourseHierarchyModel course;
  final String identifier;
  final String? batchId;
  final updateContentProgress;
  final String parentCourseId;
  final ValueChanged<bool> playNextResource;
  final bool? isPreRequisite;
  final String language;

  SurveyPage(this.microSurvey, this.surveyName, this.course, this.identifier,
      this.batchId,
      {this.updateContentProgress,
      required this.parentCourseId,
      required this.playNextResource,
      this.isPreRequisite = false,
      required this.language});

  @override
  _SurveyPageState createState() {
    return _SurveyPageState();
  }
}

class _SurveyPageState extends State<SurveyPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final MicroSurveyService microSurveyService = MicroSurveyService();
  final LearnService learnService = LearnService();
  List<MicroSurvey> _microSurvey = [];
  List _questionAnswers = [];
  int _questionIndex = 0;
  int count = 0;

  @override
  void initState() {
    super.initState();
    _microSurvey = widget.microSurvey?['questions'];
  }

  @override
  void dispose() {
    super.dispose();
  }

  void updateQuestionIndex(int value) {
    setState(() {
      _questionIndex = value;
    });
  }

  void setUserAnswer(Map answer) {
    bool matchDetected = false;
    for (int i = 0; i < _questionAnswers.length; i++) {
      if (_questionAnswers[i]['index'] == answer['index']) {
        setState(() {
          _questionAnswers[i]['value'] = answer['value'];
          matchDetected = true;
        });
      }
    }
    if (!matchDetected) {
      setState(() {
        _questionAnswers.add(answer);
      });
    }
  }

  bool _answerGiven(_questionIndex) {
    bool answerGiven = false;
    for (int i = 0; i < _questionAnswers.length; i++) {
      if (_questionAnswers[i]['index'] == _questionIndex) {
        if (_questionAnswers[i]['value'] != null) {
          if (_microSurvey[_questionIndex].fieldType != QuestionType.rating) {
            if (_questionAnswers[i]['value'].length > 0) {
              answerGiven = true;
            }
          } else if (_questionAnswers[i]['value'] != '') {
            if (_questionAnswers[i]['value'] > 0) {
              answerGiven = true;
            } else {
              answerGiven = false;
            }
          }
        } else {
          answerGiven = false;
        }
      }
    }
    return answerGiven;
  }

  Future<bool> _submitSurvey(context) async {
    Map dataObject = {};
    bool isSubmitted = false;
    for (int i = 0; i < _questionAnswers.length; i++) {
      if (_questionAnswers[i]['question'] != null) {
        dataObject[_questionAnswers[i]['question']] =
            _questionAnswers[i]['value'];
      }
    }
    dataObject['Course ID and Name'] =
        '${widget.course.identifier}, ${widget.course.name}';
    Map surveyData = {
      'formId': widget.microSurvey!['id'],
      'version': widget.microSurvey!['version'],
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'dataObject': dataObject
    };

    var response = await microSurveyService.saveMicroSurvey(surveyData,
        isContentFeedback: true);
    if (response.toString() == 'true') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context)!.mSurveyThanksForSubmitting),
          backgroundColor: AppColors.positiveLight,
        ),
      );
      Future.delayed(Duration(microseconds: 150), () async {
        await _updateContentProgress();
        Navigator.of(context).pop(true);
      });
      isSubmitted = true;
      return isSubmitted;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.mStaticSomethingWrong),
          backgroundColor: AppColors.negativeLight,
        ),
      );
      return isSubmitted;
    }
  }

  Future<void> _updateContentProgress() async {
    List<String> current = [];
    if (widget.batchId != null) {
      current.add(_microSurvey.length.toString());
      String courseId =
        TocPlayerViewModel().getEnrolledCourseId(context, widget.parentCourseId);
      String batchId = widget.batchId!;
      String contentId = widget.identifier;
      int status = 2;
      String contentType = EMimeTypes.survey;
      var maxSize = widget.course.duration;

    double completionPercentage = 100.0;
    await learnService.updateContentProgress(courseId, batchId, contentId,
        status, contentType, current, maxSize, completionPercentage,
        isAssessment: true, isPreRequisite: widget.isPreRequisite, language: widget.language);

      Map data = {
        'identifier': contentId,
        'mimeType': EMimeTypes.survey,
        'current': 100,
        'completionPercentage': completionPercentage / 100
      };
      await widget.updateContentProgress(data);
      widget.playNextResource(true);
    }
  }

  PreferredSizeWidget _getAppbar() {
    return AppBar(
      titleSpacing: 0,
      elevation: 5,
      leading: IconButton(
        icon: Icon(Icons.clear, color: FeedbackColors.black60),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(children: [
        Icon(Icons.book, color: FeedbackColors.black60),
        Container(
          width: 0.6825.sw,
          child: Padding(
            padding: const EdgeInsets.only(left: 10).r,
            child: Text(
              widget.surveyName,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontFamily: GoogleFonts.montserrat().fontFamily,
                  ),
            ),
          ),
        ),
        Spacer(),
        Padding(
          padding: const EdgeInsets.only(right: 10).r,
          child: Icon(
            Icons.info,
            color: AppColors.grey40,
          ),
        )
      ]),
    );
  }

  _getQuestionAnswer(_questionIndex, {bool isRadio = false}) {
    var givenAnswer;
    for (int i = 0; i < _questionAnswers.length; i++) {
      if (_questionAnswers[i]['index'] == _questionIndex) {
        givenAnswer = isRadio
            ? _questionAnswers[i]['value'].toString()
            : _questionAnswers[i]['value'];
      }
    }
    return givenAnswer;
  }

  Widget _generatePagination() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.fromLTRB(15, 30, 15, 0).r,
        child: Text(
          'Question ${_questionIndex + 1} of ${_microSurvey.length}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      Container(
        margin: const EdgeInsets.only(left: 5, top: 20).r,
        height: 45.w,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _microSurvey.length,
          itemBuilder: (BuildContext context, int index) => InkWell(
              onTap: () {
                setState(() {
                  _questionIndex = index;
                });
              },
              child: Container(
                height: 40.w,
                width: 60.w,
                margin: const EdgeInsets.only(left: 10).r,
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.lato(
                      color: _questionIndex == index
                          ? FeedbackColors.black87
                          : FeedbackColors.black60,
                      fontWeight: _questionIndex == index
                          ? FontWeight.w700
                          : FontWeight.w400,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                  color: _answerGiven(index)
                      ? FeedbackColors.black04
                      : AppColors.appBarBackground,
                  borderRadius: BorderRadius.all(const Radius.circular(22.0).r),
                  border: Border.all(
                      color: _questionIndex == index
                          ? AppColors.darkBlue
                          : _answerGiven(index)
                              ? FeedbackColors.lightGrey
                              : FeedbackColors.black16),
                ),
              )),
        ),
      )
    ]);
  }

  Future<bool?> _onSubmitPressed(contextMain) {
    return showDialog(
        context: context,
        builder: (context) => Stack(
              children: [
                Positioned(
                    child: Align(
                        alignment: FractionalOffset.bottomCenter,
                        child: Container(
                          padding: EdgeInsets.all(20).r,
                          width: double.infinity.w,
                          height: 190.0.w,
                          color: AppColors.appBarBackground,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 5, bottom: 15).r,
                                child: Text(
                                  'Do you want to come back to your feedback?',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(
                                        fontFamily:
                                            GoogleFonts.montserrat().fontFamily,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  final response =
                                      await _submitSurvey(contextMain);
                                  if (response) {
                                    Future.delayed(Duration.zero, () {
                                      Navigator.of(context).pop(true);
                                    });
                                  }
                                },
                                child: roundedButton(
                                    AppLocalizations.of(contextMain)!
                                        .mStaticNoSubmit,
                                    AppColors.appBarBackground,
                                    AppColors.darkBlue),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 12).r,
                                child: GestureDetector(
                                  onTap: () => Navigator.of(context).pop(true),
                                  child: roundedButton(
                                      AppLocalizations.of(contextMain)!
                                          .mStaticYesTakeMeBack,
                                      AppColors.darkBlue,
                                      AppColors.appBarBackground),
                                ),
                              )
                            ],
                          ),
                        )))
              ],
            ));
  }

  Widget roundedButton(String buttonLabel, Color bgColor, Color textColor) {
    var optionButton = Container(
      width: 1.sw - 40.w,
      padding: EdgeInsets.all(10).r,
      alignment: FractionalOffset.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.all(const Radius.circular(4.0).r),
        border: bgColor == AppColors.appBarBackground
            ? Border.all(color: FeedbackColors.black40)
            : Border.all(color: bgColor),
      ),
      child: Text(
        buttonLabel,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontFamily: GoogleFonts.montserrat().fontFamily,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
    return optionButton;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.appBarBackground,
        key: _scaffoldKey,
        appBar: _getAppbar(),
        body: SingleChildScrollView(
            child: Container(
                height: 1.sh,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16, left: 16).r,
                        child: Text(
                          Helper.capitalize(
                              widget.microSurvey!['title'].toString()),
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(
                                fontSize: 18.sp,
                              ),
                        ),
                      ),
                      _questionIndex < _microSurvey.length
                          ? Container(
                              color: AppColors.appBarBackground,
                              child: _generatePagination())
                          : Center(),
                      Padding(
                        padding: const EdgeInsets.only(top: 12).r,
                        child: Divider(
                          thickness: 1.w,
                          color: AppColors.grey16,
                        ),
                      ),
                      _microSurvey[_questionIndex].fieldType ==
                              QuestionType.radio
                          ? Container(
                              color: AppColors.appBarBackground,
                              child: RadioTypeQuestion(
                                  question: _microSurvey[_questionIndex],
                                  currentIndex: _questionIndex + 1,
                                  answerGiven: _getQuestionAnswer(
                                      _questionIndex,
                                      isRadio: true),
                                  showAnswer: false,
                                  parentAction: setUserAnswer),
                            )
                          : _microSurvey[_questionIndex].fieldType ==
                                  QuestionType.boolean
                              ? Container(
                                  color: AppColors.appBarBackground,
                                  child: BooleanTypeQuestion(
                                      _microSurvey[_questionIndex],
                                      _questionIndex + 1,
                                      _getQuestionAnswer(_questionIndex),
                                      false,
                                      setUserAnswer),
                                )
                              : _microSurvey[_questionIndex].fieldType ==
                                      QuestionType.checkbox
                                  ? Container(
                                      color: AppColors.appBarBackground,
                                      child: CheckboxTypeQuestion(
                                          question:
                                              _microSurvey[_questionIndex],
                                          currentIndex: _questionIndex + 1,
                                          answerGiven: _getQuestionAnswer(
                                              _questionIndex),
                                          showAnswer: false,
                                          parentAction: setUserAnswer),
                                    )
                                  : _microSurvey[_questionIndex].fieldType ==
                                          QuestionType.rating
                                      ? Container(
                                          color: AppColors.appBarBackground,
                                          child: RatingTypeQuestion(
                                              _microSurvey[_questionIndex],
                                              _questionIndex + 1,
                                              _getQuestionAnswer(
                                                  _questionIndex),
                                              setUserAnswer),
                                        )
                                      : _microSurvey[_questionIndex]
                                                      .fieldType ==
                                                  QuestionType.textarea ||
                                              _microSurvey[_questionIndex]
                                                      .fieldType ==
                                                  QuestionType.text ||
                                              _microSurvey[_questionIndex]
                                                      .fieldType ==
                                                  QuestionType.numeric ||
                                              _microSurvey[_questionIndex]
                                                      .fieldType ==
                                                  QuestionType.email
                                          ? Container(
                                              color: AppColors.appBarBackground,
                                              child: new TextFieldTypeQuestion(
                                                  _microSurvey[_questionIndex],
                                                  _questionIndex + 1,
                                                  _getQuestionAnswer(
                                                      _questionIndex),
                                                  setUserAnswer),
                                            )
                                          : Center()
                    ]))),
        bottomSheet: Container(
          height: _questionIndex >= _microSurvey.length ? 0 : 80,
          padding: const EdgeInsets.all(16).r,
          decoration:
              BoxDecoration(color: AppColors.appBarBackground, boxShadow: [
            BoxShadow(
              color: FeedbackColors.black08,
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
              _questionIndex > 0
                  ? Container(
                      height: 58.w,
                      width: 1.sw / 2 - 70.w,
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _questionIndex--;
                          });
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.appBarBackground,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4).r,
                              side: BorderSide(color: FeedbackColors.black16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8).r,
                              child: Icon(
                                Icons.arrow_back,
                                color: AppColors.greys60,
                              ),
                            ),
                            Text(
                              AppLocalizations.of(context)!.mTourPrevious,
                              style: Theme.of(context).textTheme.displayLarge,
                            )
                          ],
                        ),
                      ),
                    )
                  : Center(),
              Spacer(),
              Container(
                height: 58.w,
                width: _questionIndex == 0 ? 1.sw - 40.w : 1.sw / 2 + 20.w,
                child: TextButton(
                  onPressed: () async {
                    if (_questionIndex == _microSurvey.length - 1 &&
                        _questionAnswers.length < _microSurvey.length) {
                      await _onSubmitPressed(context);
                    } else if (_questionIndex == _microSurvey.length - 1) {
                      await _submitSurvey(context);
                    } else {
                      setState(() {
                        _questionIndex++;
                      });
                    }
                    // }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.darkBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4).r,
                        side: BorderSide(color: FeedbackColors.black16)),
                  ),
                  child: Text(
                    _questionIndex < _microSurvey.length - 1
                        ? AppLocalizations.of(context)!.mTourNext
                        : AppLocalizations.of(context)!.mStaticSubmit,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
