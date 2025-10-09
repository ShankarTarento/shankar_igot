import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/ui/pages/index.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/_assessment/html_webview_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/index.dart';
import 'package:provider/provider.dart';
import '../../../../models/_models/assessment_info_model.dart';
import '../../../../models/_models/assessment_save_point_model.dart';
import '../../../../services/_services/assessment_service.dart';
import '../../../../util/helper.dart';
import '../../../pages/_pages/toc/model/navigation_model.dart';
import '../../_common/alert_dialog.dart';
import './../../../../constants/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'assessment_v2_section_selection_widget.dart';

class NewAssessmentV2Questions extends StatefulWidget {
  final course;
  final String identifier;
  final microSurvey;
  final ValueChanged<double> parentAction;
  final String batchId;
  final duration;
  final sectionalDuration;
  final bool isNewAssessment;
  final String primaryCategory;
  final String? objectType;
  final AssessmentChild assessmentInfo;
  final int sectionIndex;
  final getAnsweredQuestions;
  final answeredQuestions;
  final bool isLastSection;
  final navigateToNextSection;
  final currentRunningTime;
  final isFullAnswered;
  final submitSurvey;
  final List assessmentSection;
  final int? selectedSection;
  final generateInteractTelemetryData;
  final assessmentDetails;
  final String parentCourseId;
  final int compatibilityLevel;
  final SavePointModel? savePointInfo;
  final String assessmentType;
  final bool showMarks;
  final NavigationModel resourceInfo;
  final bool isFeatured;
  NewAssessmentV2Questions(this.course, this.identifier, this.microSurvey,
      this.parentAction, this.batchId, this.duration, this.sectionalDuration,
      {Key? key,
      this.isNewAssessment = false,
      required this.primaryCategory,
      this.objectType,
      required this.assessmentInfo,
      required this.sectionIndex,
      this.getAnsweredQuestions,
      this.answeredQuestions,
      this.isLastSection = false,
      this.navigateToNextSection,
      this.currentRunningTime,
      this.isFullAnswered,
      this.submitSurvey,
      required this.assessmentSection,
      this.selectedSection,
      this.generateInteractTelemetryData,
      this.assessmentDetails,
      required this.parentCourseId,
      required this.compatibilityLevel,
      this.savePointInfo,
      this.assessmentType = '',
      this.showMarks = false,
      required this.resourceInfo,
      this.isFeatured = false})
      : super(key: key);

  @override
  _NewAssessmentV2QuestionsState createState() =>
      _NewAssessmentV2QuestionsState();
}

class _NewAssessmentV2QuestionsState extends State<NewAssessmentV2Questions> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AssessmentService assessmentService = AssessmentService();

  List _microSurvey = [];
  List _questionAnswers = [];
  int _questionIndex = 0;
  DateTime? questionStartTime, sectionStartTime;
  int timeSpent = 0;

  int? _start;
  int? _startSectionalTimer;
  Timer? _timer;
  int? timeLimit;
  int? _sectionIndex;
  List _flaggedQuestions = [];
  List _savedQuestions = [];
  List _notAnsweredQuestions = [];
  int _answeredQuestion = 0;
  ValueNotifier<int> sectionNo = ValueNotifier(1);
  final ScrollController _horizontalScrollController = ScrollController();
  int totalQuestionCount = 0;

  @override
  void initState() {
    super.initState();
    if (widget.sectionalDuration != null) {
      timeLimit = double.parse('${widget.sectionalDuration}').round() -
          int.parse(widget
              .assessmentDetails[widget.sectionIndex].sectionalTimeTaken
              .toString());
      _startSectionalTimer =
          double.parse('${widget.sectionalDuration}').round() -
              int.parse(widget
                  .assessmentDetails[widget.sectionIndex].sectionalTimeTaken
                  .toString());
      startSectionalTimer();
    } else {
      timeLimit = widget.currentRunningTime != null
          ? widget.currentRunningTime
          : (widget.duration);
    }
    _sectionIndex = widget.sectionIndex;

    if (widget.microSurvey.runtimeType != String) {
      _loadInitialData();
    }
    questionStartTime = DateTime.now();
    sectionStartTime = DateTime.now();
    widget.assessmentSection.forEach((set) {
      totalQuestionCount += int.parse(set.length.toString());
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(NewAssessmentV2Questions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sectionIndex != widget.sectionIndex) {
      sectionStartTime = DateTime.now();
    }
  }

  void startSectionalTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_startSectionalTimer == 0) {
          setState(() {
            timer.cancel();
            if (widget.isLastSection) {
              updateTimeToAssessmentDetails();
              updateSectionWiseTimeToAssessmentDetails();
              widget.assessmentDetails[widget.sectionIndex].submitted = true;
              widget.submitSurvey();
              if (widget.assessmentSection.length > 1) {
                int visitedAssessmentCount = 0;
                widget.assessmentDetails.forEach((item) {
                  if (item.childStatus != null) {
                    visitedAssessmentCount++;
                  }
                });
                for (int i = 1; i < visitedAssessmentCount; i++) {
                  Navigator.pop(context);
                }
              }
            } else {
              if (widget.assessmentDetails[widget.sectionIndex + 1].submitted ==
                      null ||
                  !widget
                      .assessmentDetails[widget.sectionIndex + 1].submitted) {
                setState(() {
                  Provider.of<TocServices>(context, listen: false)
                      .destroyWebView();
                  updateTimeToAssessmentDetails();
                  updateSectionWiseTimeToAssessmentDetails();
                  widget.getAnsweredQuestions(
                      widget.sectionIndex, _questionAnswers,
                      status: AssessmentQuestionStatus.notAnswered,
                      id: _microSurvey[_questionIndex]['identifier']);

                  widget.navigateToNextSection(widget.sectionIndex + 1,
                      sectionalTimeTaken: widget
                          .assessmentDetails[widget.sectionIndex]
                          .sectionalTimeTaken,
                      prevSectionIndex: widget.sectionIndex,
                      isSubmitted: true);
                  widget.assessmentDetails[widget.sectionIndex].submitted =
                      true;
                });
              }
            }
          });
        } else {
          setState(() {
            if (_startSectionalTimer != null) {
              _startSectionalTimer = _startSectionalTimer! - 1;
            }
          });
        }
      },
    );
  }

  _loadInitialData() {
    if (widget.answeredQuestions != null &&
        widget.answeredQuestions.length > 0) {
      _questionAnswers = widget.answeredQuestions;
      _flaggedQuestions.clear();
      _savedQuestions.clear();
      _notAnsweredQuestions.clear();
      widget.answeredQuestions.forEach((element) {
        int qstnIndex = widget.microSurvey
            .indexWhere((item) => item['identifier'] == element['index']);
        switch (element['status']) {
          case AssessmentQuestionStatus.MarkForReviewAndNext:
            _flaggedQuestions.add(qstnIndex);
            break;
          case AssessmentQuestionStatus.saveAndNext:
            _savedQuestions.add(qstnIndex);
            break;
          default:
            break;
        }
      });
    }

    _start = timeLimit;
    _microSurvey = widget.microSurvey;
    if (!_notAnsweredQuestions.contains(_questionIndex)) {
      _notAnsweredQuestions.add(_questionIndex);
    }
    widget.getAnsweredQuestions(widget.sectionIndex, _questionAnswers,
        status: AssessmentQuestionStatus.notAnswered,
        id: _microSurvey[_questionIndex]['identifier']);
  }

  @override
  void dispose() async {
    _timer?.cancel();
    if (_questionAnswers.length > 0 && widget.getAnsweredQuestions != null) {
      widget.getAnsweredQuestions(widget.sectionIndex, _questionAnswers);
    }
    super.dispose();
  }

  String formatHHMMSS(int seconds) {
    int hours = (seconds / 3600).truncate();
    seconds = (seconds % 3600).truncate();
    int minutes = (seconds / 60).truncate();

    String hoursStr = (hours).toString().padLeft(2, '0');
    String minutesStr = (minutes).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    if (hours == 0) {
      return '$minutesStr:$secondsStr';
    }

    return '$hoursStr:$minutesStr:$secondsStr';
  }

  bool _answerGiven(questionId) {
    bool answerGiven = false;
    for (int i = 0; i < _questionAnswers.length; i++) {
      if (_questionAnswers[i]['index'] == questionId) {
        if (_questionAnswers[i]['value'] != null) {
          if (_questionAnswers[i]['value'].length > 0) {
            answerGiven = true;
          }
        } else {
          answerGiven = false;
        }
      }
    }
    return answerGiven;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sectionIndex != _sectionIndex) {
      _loadInitialData();
    }
    return widget.microSurvey.runtimeType == String
        ? SafeArea(
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: AppColors.darkBlue,
                automaticallyImplyLeading: false,
                shadowColor: Colors.transparent,
                toolbarHeight: 70.w,
                leading: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: AppColors.appBarBackground,
                    size: 24.w,
                  ),
                ),
              ),
              body: NoDataWidget(
                message:
                    AppLocalizations.of(context)!.mAssessmentQuestionsNotFound,
                paddingTop: 150.w,
              ),
            ),
          )
        //  ? ErrorScreen()
        : SafeArea(
            child: PopScope(
              canPop: false,
              child: Scaffold(
                  key: _scaffoldKey,
                  backgroundColor: AppColors.appBarBackground,
                  resizeToAvoidBottomInset: false,
                  appBar: AssessmentAppBar(
                      title: widget.resourceInfo.name ?? '',
                      duration: widget.duration,
                      totalQuestionCount: totalQuestionCount,
                      primaryCategory: widget.primaryCategory),
                  body: (_start == 0 && timeLimit != null && timeLimit! > 0)
                      ? Center(
                          child: Text(
                              AppLocalizations.of(context)!.mTimeLimitExceeded))
                      : SingleChildScrollView(
                          child: Container(
                              width: 1.0.sw,
                              child: Column(children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: widget.assessmentType !=
                                          AssessmentType.optionalWeightage
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            widget.assessmentSection.length > 1
                                                ? SizedBox(
                                                    width: 0.5.sw,
                                                    child:
                                                        SectionSelectionWidgetV2(
                                                            assessmentDetails:
                                                                widget
                                                                    .assessmentDetails,
                                                            sectionIndex: widget
                                                                .sectionIndex,
                                                            changeSection:
                                                                (value) {
                                                              Provider.of<TocServices>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .destroyWebView();
                                                              updateQuestionStatusNotAnswered();
                                                              updateSectionWiseTimeToAssessmentDetails();
                                                              widget.navigateToNextSection(
                                                                  value,
                                                                  sectionalTimeTaken: widget
                                                                      .assessmentDetails[
                                                                          widget
                                                                              .sectionIndex]
                                                                      .sectionalTimeTaken,
                                                                  prevSectionIndex:
                                                                      widget
                                                                          .sectionIndex);
                                                            }),
                                                  )
                                                : Center(),
                                            submitButtonWidget(context)
                                          ],
                                        )
                                      : Container(
                                          width: 1.0.sw,
                                          child: submitButtonWidget(context)),
                                ),
                                _buildLayout()
                              ])),
                        ),
                  bottomSheet: (_questionIndex < _microSurvey.length)
                      ? AssessmentV2ActionButton(
                          isLastSection: widget.isLastSection,
                          assessmentType: widget.assessmentType,
                          questionIndex: _questionIndex,
                          isLastQuestion:
                              (_microSurvey.length - 1) == _questionIndex,
                          onButtonPressed: (value) async {
                            await updateQuestionStatus(value, context);
                          },
                        )
                      : PageLoader()),
            ),
          );
  }

  ElevatedButton submitButtonWidget(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (widget.assessmentType != AssessmentType.optionalWeightage) {
          updateQuestionStatusNotAnswered();
          submitAssessment(context, submitAssessment: true);
        } else {
          if (_questionIndex == _microSurvey.length - 1 &&
              _answerGiven(_microSurvey[_questionIndex]['identifier'])) {
            updateQuestionStatus(AssessmentQuestionStatus.saveAndNext, context);
            widget.submitSurvey();
          }
        }
      },
      style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 16).r,
          backgroundColor: widget.assessmentType != '' &&
                  widget.assessmentType == AssessmentType.optionalWeightage &&
                  (_questionIndex != _microSurvey.length - 1 ||
                      (!_answerGiven(
                              _microSurvey[_questionIndex]['identifier']) &&
                          _questionIndex == _microSurvey.length - 1))
              ? AppColors.grey40
              : AppColors.darkBlue,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(63)).r)),
      child: Text(
        AppLocalizations.of(context)!.mAssessmentSubmitTheTest,
        style: GoogleFonts.roboto(
          color: AppColors.appBarBackground,
          fontSize: 14.0.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.25,
        ),
      ),
    );
  }

  void updateQuestionStatusNotAnswered() {
    if (!_flaggedQuestions.contains(_questionIndex) &&
        !_savedQuestions.contains(_questionIndex)) {
      setState(() {
        widget.getAnsweredQuestions(widget.sectionIndex, _questionAnswers,
            status: AssessmentQuestionStatus.notAnswered,
            id: _microSurvey[_questionIndex]['identifier']);
        if (!_notAnsweredQuestions.contains(_questionIndex)) {
          _notAnsweredQuestions.add(_questionIndex);
        }
      });
    }
    updateTimeToAssessmentDetails();
  }

  Widget _buildLayout() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16).r,
        margin: EdgeInsets.only(top: 16, bottom: 16).r,
        color: AppColors.grey08,
        child: Row(
          children: [
            Text(
              '${AppLocalizations.of(context)!.mStaticQuestionNo} ${_questionIndex + 1}',
              style: GoogleFonts.lato(
                fontWeight: FontWeight.w700,
                fontSize: 16.0.sp,
              ),
            ),
            Spacer(),
            widget.showMarks &&
                    widget.microSurvey[_questionIndex]['questionLevel'] !=
                        null &&
                    widget.microSurvey[_questionIndex]['questionLevel'] != '' &&
                    widget.assessmentInfo.sectionLevelDefinition != null &&
                    widget.assessmentInfo.sectionLevelDefinition![
                            widget.microSurvey[_questionIndex]
                                ['questionLevel']]['marksForQuestion'] !=
                        0
                ? Row(
                    children: [
                      Text(
                        Helper.handleNumber(
                                widget.assessmentInfo.sectionLevelDefinition![
                                    widget.microSurvey[_questionIndex]
                                        ['questionLevel']]['marksForQuestion'])
                            .toString(),
                        style: GoogleFonts.lato(
                          fontWeight: FontWeight.w700,
                          fontSize: 16.0.sp,
                        ),
                      ),
                      Text(
                        Helper.handleNumber(widget.assessmentInfo
                                    .sectionLevelDefinition![widget
                                        .microSurvey[_questionIndex]
                                    ['questionLevel']]['marksForQuestion']) >
                                1
                            ? ' ${AppLocalizations.of(context)!.mStaticMarks}'
                            : ' ${AppLocalizations.of(context)!.mStaticMark}',
                        style: GoogleFonts.openSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 16.0.sp,
                        ),
                      ),
                    ],
                  )
                : Center()
          ],
        ),
      ),
      (widget.assessmentType != '' &&
              widget.assessmentType != AssessmentType.optionalWeightage)
          ? QuestionCountSummaryWidget(
              microSurvey: _microSurvey,
              start: widget.sectionalDuration == null
                  ? widget.currentRunningTime
                  : _start,
              assessmentSectionLength: widget.assessmentSection.length,
              selectedSection: widget.selectedSection,
              answeredQuestions: _answeredQuestion,
              submitSurvey: widget.submitSurvey,
              primaryCategory: widget.primaryCategory,
              generateInteractTelemetryData:
                  widget.generateInteractTelemetryData,
              questionIndex: _questionIndex,
              flaggedQuestions: _flaggedQuestions,
              savedQuestions: _savedQuestions,
              notAnsweredQuestions: _notAnsweredQuestions,
              sectionInstruction: widget.assessmentInfo.additionalInstructions,
              changeQuestion: changeQuestionIndex,
              sectionalDuration: widget.sectionalDuration ?? widget.duration)
          : Center(),
      Container(
        margin: EdgeInsets.fromLTRB(16, 8, 16, 120).r,
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(color: AppColors.grey16),
                left: BorderSide(color: AppColors.grey16),
                right: BorderSide(color: AppColors.grey16))),
        child: Column(
          children: [
            _assessmentProgress(),
            widget.assessmentInfo.sectionType == AssessmentSectionType.paragraph
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            AppLocalizations.of(context)!
                                .mAssessmentParagraphQustionDescription,
                            style: GoogleFonts.lato(
                                color: AppColors.greys87,
                                fontWeight: FontWeight.w700,
                                fontSize: 16.sp)),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: HtmlWebviewWidget(
                            htmlText:
                                widget.assessmentInfo.questionParagraph ?? '',
                            textStyle: GoogleFonts.lato(
                                color: AppColors.black87,
                                fontWeight: FontWeight.w400,
                                fontSize: 14.0.sp,
                                height: 1.5),
                          ),
                        ),
                      ],
                    ))
                : Center(),
            Consumer<TocServices>(builder: (context, tocServices, child) {
              return AssessmentWidget(
                  answeredQuestion: _answeredQuestion,
                  getAnsweredQuestions: widget.getAnsweredQuestions,
                  microSurvey: _microSurvey,
                  primaryCategory: widget.primaryCategory,
                  questionAnswers: _questionAnswers,
                  questionIndex: _questionIndex,
                  sectionIndex: widget.sectionIndex);
            }),
          ],
        ),
      )
    ]);
  }

  Widget _assessmentProgress() {
    return LinearProgressIndicator(
      value: ((_questionIndex + 1) / _microSurvey.length),
      backgroundColor: AppColors.greys.withValues(alpha: 0.16),
      minHeight: 9.w,
      valueColor: AlwaysStoppedAnimation<Color>(AppColors.darkBlue),
    );
  }

  Future<void> updateQuestionStatus(String value, BuildContext contxt) async {
    if (value == AssessmentQuestionStatus.previous) {
      changeQuestionIndex(_questionIndex - 1);
    } else if (_answerGiven(_microSurvey[_questionIndex]['identifier']) ||
        value != AssessmentQuestionStatus.saveAndNext) {
      switch (value) {
        case AssessmentQuestionStatus.MarkForReviewAndNext:
          _flaggedQuestions =
              await updateCategorizedList(value, _flaggedQuestions);
          break;
        case AssessmentQuestionStatus.clearResponse:
          _questionAnswers.removeWhere((item) =>
              item['index'] == _microSurvey[_questionIndex]['identifier']);
          if (_flaggedQuestions.contains(_questionIndex)) {
            _flaggedQuestions.remove(_questionIndex);
          } else if (_savedQuestions.contains(_questionIndex)) {
            _savedQuestions.remove(_questionIndex);
          }
          updateQuestionStatusNotAnswered();
          setState(() {});
          break;
        case AssessmentQuestionStatus.saveAndNext:
          _savedQuestions = await updateCategorizedList(value, _savedQuestions);
          break;
        case AssessmentQuestionStatus.nextSection:
          updateQuestionStatusNotAnswered();
          submitAssessment(context);
          break;
        default:
          break;
      }
    } else {
      updateTimeToAssessmentDetails();
      if (!_notAnsweredQuestions.contains(_questionIndex)) {
        _notAnsweredQuestions.add(_questionIndex);
      }
      widget.getAnsweredQuestions(widget.sectionIndex, _questionAnswers,
          status: AssessmentQuestionStatus.notAnswered,
          id: _microSurvey[_questionIndex]['identifier']);
      if (widget.assessmentType != '' &&
          widget.assessmentType == AssessmentType.optionalWeightage) {
        showDialog(
            context: contxt,
            barrierDismissible: false,
            builder: (BuildContext cxt) {
              return AlertDialogWidget(
                subtitle: AppLocalizations.of(context)!
                    .mAssessmentPleaseAttemptAndMoveNext,
                primaryButtonText: AppLocalizations.of(context)!.mStaticBack,
                onPrimaryButtonPressed: () => Navigator.of(cxt).pop(),
              );
            });
      } else {
        if (_questionIndex == _microSurvey.length - 1) {
          _onSubmitAssessment(context);
        } else {
          _questionIndex++;
          if (!_notAnsweredQuestions.contains(_questionIndex)) {
            _notAnsweredQuestions.add(_questionIndex);
          }
        }
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<List> updateCategorizedList(String value, List list) async {
    _notAnsweredQuestions.remove(_questionIndex);
    _savedQuestions.remove(_questionIndex);
    _flaggedQuestions.remove(_questionIndex);
    setState(() {
      list.add(_questionIndex);
    });
    updateTimeToAssessmentDetails();
    // if (widget.compatibilityLevel >= AppCompatibility.assessmentLevel) {
    //   await saveQuestionAnswer();
    // }
    widget.getAnsweredQuestions(widget.sectionIndex, _questionAnswers,
        status: value, id: _microSurvey[_questionIndex]['identifier']);
    if (_questionIndex == _microSurvey.length - 1 &&
        widget.assessmentType != AssessmentType.optionalWeightage) {
      _onSubmitAssessment(context);
    } else if (_questionIndex != _microSurvey.length - 1) {
      _questionIndex++;
      if (!_notAnsweredQuestions.contains(_questionIndex)) {
        _notAnsweredQuestions.add(_questionIndex);
      }
      updateQuestionStartTimer(_questionIndex);
    }
    return list;
  }

  void changeQuestionIndex(value) {
    setState(() {
      if (_answerGiven(_microSurvey[_questionIndex]['identifier']) ||
          _flaggedQuestions.contains(_questionIndex)) {
        if (!_flaggedQuestions.contains(_questionIndex) &&
            !_savedQuestions.contains(_questionIndex)) {
          _questionAnswers.removeWhere((item) =>
              item['index'] == _microSurvey[_questionIndex]['identifier']);
          if (!_notAnsweredQuestions.contains(_questionIndex)) {
            _notAnsweredQuestions.add(_questionIndex);
          }
        } else if (_savedQuestions.contains(_questionIndex)) {
          int index = _questionAnswers.indexWhere((element) =>
              element['index'] == _microSurvey[_questionIndex]['identifier']);
          _questionAnswers[index]['value'] = _questionAnswers[index]['value'];
          _questionAnswers[index]['isCorrect'] =
              _questionAnswers[index]['status'];
        }
      } else {
        if (!_notAnsweredQuestions.contains(_questionIndex)) {
          _notAnsweredQuestions.add(_questionIndex);
        }
      }
      updateTimeToAssessmentDetails();

      _questionIndex = value;
      if (!_notAnsweredQuestions.contains(_questionIndex)) {
        _notAnsweredQuestions.add(_questionIndex);
      }
      updateQuestionStatusNotAnswered();
      updateQuestionStartTimer(_questionIndex);
    });
  }

  Future<void> _onSubmitAssessment(BuildContext cxt,
      {bool submitAssessment = false}) async {
    sectionNo.value = widget.sectionIndex + 1;
    List<Map<String, dynamic>> sectionSummaryList = [];
    widget.generateInteractTelemetryData(
        widget.identifier, TelemetrySubType.submit);
    return showDialog<void>(
      context: cxt,
      barrierDismissible: false,
      builder: (cxt) => Center(
        child: AlertDialog(
          contentPadding: EdgeInsets.symmetric(vertical: 16).r,
          insetPadding: EdgeInsets.all(16).r,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0).r,
          ),
          content: SizedBox(
            width: 1.sw,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16).r,
                  child: Text(
                    widget.resourceInfo.name ?? '',
                    style: GoogleFonts.robotoSlab(
                      color: AppColors.blackLegend,
                      fontSize: 20.0.sp,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.25,
                    ),
                  ),
                ),
                SizedBox(height: 8.w),
                Scrollbar(
                  thumbVisibility: true,
                  controller: _horizontalScrollController,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: _horizontalScrollController,
                    child: ValueListenableBuilder(
                        valueListenable: sectionNo,
                        builder: (cxt, int value, child) {
                          if (submitAssessment) {
                            for (int index = 0;
                                index < widget.assessmentDetails.length;
                                index++) {
                              sectionSummaryList
                                  .add(updateSectionSummaryList(index));
                            }
                          } else {
                            Provider.of<TocServices>(context, listen: false)
                                .destroyWebView();
                            sectionSummaryList.add(
                                updateSectionSummaryList(sectionNo.value - 1));
                          }
                          return Container(
                            margin: EdgeInsets.only(bottom: 16).r,
                            padding: EdgeInsets.symmetric(horizontal: 16.r),
                            child: Table(
                              columnWidths: {
                                0: FixedColumnWidth(
                                    widget.assessmentSection.length > 1
                                        ? 186.w
                                        : 0.w),
                                1: FixedColumnWidth(186.w),
                                2: FixedColumnWidth(186.w),
                                3: FixedColumnWidth(186.w),
                                4: FixedColumnWidth(186.w),
                                5: FixedColumnWidth(186.w)
                              },
                              children: [
                                TableRow(
                                  decoration:
                                      BoxDecoration(color: AppColors.darkBlue),
                                  children: [
                                    widget.assessmentSection.length > 1
                                        ? getTableHeader(
                                            AppLocalizations.of(context)!
                                                .mAssessmentSection)
                                        : Center(),
                                    getTableHeader(AppLocalizations.of(context)!
                                        .mAssessmentNoOfQuestions),
                                    getTableHeader(AppLocalizations.of(context)!
                                        .mStaticAnswered),
                                    getTableHeader(AppLocalizations.of(context)!
                                        .mStaticNotAnswered),
                                    getTableHeader(AppLocalizations.of(context)!
                                        .mAssessmentMarkedForReview),
                                    getTableHeader(AppLocalizations.of(context)!
                                        .mStaticNotVisited),
                                  ],
                                ),
                                for (var summary in sectionSummaryList)
                                  TableRow(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom:
                                            BorderSide(color: AppColors.grey16),
                                      ),
                                    ),
                                    children: [
                                      widget.assessmentSection.length > 1
                                          ? getTableData(summary['title'])
                                          : Center(),
                                      getTableData(summary['totalCount']),
                                      getTableData(summary['answeredCount']),
                                      getTableData(summary['notAnswered']),
                                      getTableData(summary['markForReview']),
                                      getTableData(summary['notVisited']),
                                    ],
                                  ),
                              ],
                            ),
                          );
                        }),
                  ),
                ),
                submitAssessment
                    ? Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 20)
                                .r,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning,
                                  color: AppColors.greys60,
                                  size: 24.sp,
                                ),
                                SizedBox(width: 6.w),
                                SizedBox(
                                  width: 0.77.sw,
                                  child: Wrap(
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!
                                            .mAssessmentSubmitWarning,
                                        style: GoogleFonts.lato(
                                            color: AppColors.greys,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 16.sp),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16).r,
                            child: Divider(
                              height: 2.w,
                              color: AppColors.grey16,
                            ),
                          ),
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    _timer?.cancel();
                                    widget.submitSurvey();
                                    if (widget.assessmentSection.length > 1) {
                                      Navigator.pop(cxt);
                                      int visitedAssessmentCount = 0;
                                      widget.assessmentDetails.forEach((item) {
                                        if (item.childStatus != null) {
                                          visitedAssessmentCount++;
                                        }
                                      });
                                      for (int i = 1;
                                          i < visitedAssessmentCount;
                                          i++) {
                                        Navigator.pop(context);
                                      }
                                    } else {
                                      Navigator.pop(cxt);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          AppColors.appBarBackground,
                                      padding: EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 5)
                                          .r,
                                      side:
                                          BorderSide(color: AppColors.darkBlue),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                                  Radius.circular(5))
                                              .r)),
                                  child: Text(
                                    AppLocalizations.of(context)!.mStaticYes,
                                    style: GoogleFonts.roboto(
                                      color: AppColors.darkBlue,
                                      fontSize: 16.0.sp,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 0.25,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(cxt).pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.darkBlue,
                                      padding: EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 5)
                                          .r,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                                  Radius.circular(5))
                                              .r)),
                                  child: Text(
                                    AppLocalizations.of(context)!.mStaticNo,
                                    style: GoogleFonts.roboto(
                                      color: AppColors.appBarBackground,
                                      fontSize: 16.0.sp,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 0.25,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      )
                    : Container(
                        padding: EdgeInsets.only(top: 16).r,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: AppColors.grey16),
                          ),
                        ),
                        child: Center(
                          child: ValueListenableBuilder(
                              valueListenable: sectionNo,
                              builder: (cxt, int value, child) {
                                return Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      widget.assessmentSection.length > 1 &&
                                              value <
                                                  widget
                                                      .assessmentSection.length
                                          ? ElevatedButton(
                                              onPressed: () {
                                                Provider.of<TocServices>(
                                                        context,
                                                        listen: false)
                                                    .destroyWebView();
                                                Navigator.of(cxt).pop();
                                                _timer?.cancel();
                                                widget.navigateToNextSection(
                                                    widget.sectionIndex + 1,
                                                    isSubmitted: true);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  padding: EdgeInsets.symmetric(
                                                          horizontal: 20,
                                                          vertical: 5)
                                                      .r,
                                                  backgroundColor:
                                                      AppColors.lightBlueShade,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius
                                                              .all(Radius
                                                                  .circular(5))
                                                          .r)),
                                              child: Text(
                                                AppLocalizations.of(context)!
                                                    .mNewAssessmentNextSection,
                                                style: GoogleFonts.roboto(
                                                  color:
                                                      AppColors.darkBrownShade,
                                                  fontSize: 16.0.sp,
                                                  fontWeight: FontWeight.w400,
                                                  letterSpacing: 0.25,
                                                ),
                                              ),
                                            )
                                          : Center(),
                                      Padding(
                                        padding: widget.isLastSection
                                            ? EdgeInsets.only(right: 6).r
                                            : EdgeInsets.only(left: 6).r,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(cxt).pop();
                                          },
                                          style: ElevatedButton.styleFrom(
                                              padding: EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 5)
                                                  .r,
                                              backgroundColor: AppColors
                                                  .blackBgShade,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                              Radius.circular(
                                                                  5))
                                                          .r)),
                                          child: Text(
                                            AppLocalizations.of(context)!
                                                .mStaticBack,
                                            style: GoogleFonts.roboto(
                                              color: AppColors.appBarBackground,
                                              fontSize: 16.0.sp,
                                              fontWeight: FontWeight.w400,
                                              letterSpacing: 0.25,
                                            ),
                                          ),
                                        ),
                                      ),
                                      value == widget.assessmentSection.length
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.only(left: 6)
                                                      .r,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  updateTimeToAssessmentDetails();
                                                  updateSectionWiseTimeToAssessmentDetails();
                                                  Navigator.of(cxt).pop();
                                                  _onSubmitAssessment(context,
                                                      submitAssessment: true);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                                horizontal: 20,
                                                                vertical: 5)
                                                            .r,
                                                    backgroundColor: AppColors
                                                        .lightBlueShade,
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                    Radius
                                                                        .circular(
                                                                            5))
                                                                .r)),
                                                child: Text(
                                                  AppLocalizations.of(context)!
                                                      .mAssessmentSubmitTest,
                                                  style: GoogleFonts.roboto(
                                                    color: AppColors
                                                        .darkBrownShade,
                                                    fontSize: 16.0.sp,
                                                    fontWeight: FontWeight.w400,
                                                    letterSpacing: 0.25,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Center()
                                    ]);
                              }),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> updateSectionSummaryList(int sectionNo) {
    int markForReview = 0;
    int answeredCount = 0;
    int notAnswered = 0;
    int notVisited = 0;
    int totalCount = widget.assessmentDetails[sectionNo].childNodes.length;
    if (widget.assessmentDetails[sectionNo] != null &&
        widget.assessmentDetails[sectionNo].childStatus != null) {
      widget.assessmentDetails[sectionNo].childStatus.forEach((element) {
        switch (element['status']) {
          case AssessmentQuestionStatus.MarkForReviewAndNext:
            markForReview++;
            break;
          case AssessmentQuestionStatus.saveAndNext:
            answeredCount++;
            break;
          case AssessmentQuestionStatus.notAnswered:
            notAnswered++;
            break;
          default:
            break;
        }
      });
    }
    notVisited = totalCount - (answeredCount + markForReview + notAnswered);
    return {
      'title': widget.assessmentDetails[sectionNo].name,
      'totalCount': totalCount.toString(),
      'markForReview': markForReview.toString(),
      'answeredCount': answeredCount.toString(),
      'notAnswered': notAnswered.toString(),
      'notVisited': notVisited.toString()
    };
  }

  TableCell getTableHeader(String text) {
    return TableCell(
      child: Padding(
        padding: EdgeInsets.all(16.0).r,
        child: Text(
          text,
          style: GoogleFonts.lato(
            color: AppColors.appBarBackground,
            fontSize: 14.0.sp,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.25,
          ),
        ),
      ),
    );
  }

  TableCell getTableData(String text) {
    return TableCell(
      child: Padding(
        padding: EdgeInsets.all(16.0).r,
        child: Text(
          text,
          style: GoogleFonts.lato(
            color: AppColors.greys60,
            fontSize: 14.0.sp,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.25,
          ),
        ),
      ),
    );
  }

  void updateQuestionStartTimer(int questionIndex) {
    bool isVisitedBefore = false;
    for (var map in widget.assessmentDetails[widget.sectionIndex].timeSpent) {
      if (map['questionId'] == _microSurvey[_questionIndex]['identifier']) {
        timeSpent = map['timeSpent'];
        isVisitedBefore = true;
      }
    }
    if (!isVisitedBefore) {
      timeSpent = 0;
    }
    questionStartTime = DateTime.now();
  }

  void updateTimeToAssessmentDetails() {
    int spentTime =
        (DateTime.now().difference(questionStartTime!)).inMilliseconds;
    bool isTimeUpdated = false;
    for (var map in widget.assessmentDetails[widget.sectionIndex].timeSpent) {
      if (map['questionId'] == _microSurvey[_questionIndex]['identifier']) {
        map['timeSpent'] = spentTime;
        isTimeUpdated = true;
      }
    }
    if (!isTimeUpdated) {
      widget.assessmentDetails[widget.sectionIndex].timeSpent.add({
        'questionId': _microSurvey[_questionIndex]['identifier'],
        'timeSpent': spentTime
      });
    }
  }

  void updateSectionWiseTimeToAssessmentDetails() {
    int spentTime = (((DateTime.now().millisecondsSinceEpoch -
                    sectionStartTime!.millisecondsSinceEpoch) /
                1000) +
            widget.assessmentDetails[widget.sectionIndex].sectionalTimeTaken)
        .toInt();
    widget.assessmentDetails[widget.sectionIndex].sectionalTimeTaken =
        spentTime;
    _timer?.cancel();
  }

  Future<void> saveQuestionAnswer() async {
    List options = [];
    if (_microSurvey[_questionIndex]['editorState'] != null ||
        _microSurvey[_questionIndex]['choices'] != null) {
      for (int index = 0;
          index <
              (widget.primaryCategory == PrimaryCategory.practiceAssessment
                  ? _microSurvey[_questionIndex]['editorState']['options']
                      .length
                  : _microSurvey[_questionIndex]['choices']['options'].length);
          index++) {
        var option =
            widget.primaryCategory == PrimaryCategory.practiceAssessment
                ? _microSurvey[_questionIndex]['editorState']['options']
                : _microSurvey[_questionIndex]['choices']['options'];
        if (AssessmentQuestionType.matchCase.toUpperCase() ==
                _microSurvey[_questionIndex]['qType']
                    .toString()
                    .toUpperCase() ||
            AssessmentQuestionType.ftb.toUpperCase() ==
                _microSurvey[_questionIndex]['qType']
                    .toString()
                    .toUpperCase()) {
          _questionAnswers.forEach((element) {
            if (element['index'] ==
                _microSurvey[_questionIndex]['identifier']) {
              for (int optIndex = 0;
                  optIndex < element['value'].length;
                  optIndex++) {
                if (!options.any((item) =>
                    (item['selectedAnswer'] == element['value'][optIndex]))) {
                  options.add({
                    'selectedOptionIndex': optIndex.toString(),
                    'selectedAnswer': element['value'][optIndex]
                  });
                }
              }
            }
          });
        } else if (AssessmentQuestionType.checkBoxType.toUpperCase() ==
            _microSurvey[_questionIndex]['qType'].toString().toUpperCase()) {
          _questionAnswers.forEach((element) {
            if (element['index'] ==
                    _microSurvey[_questionIndex]['identifier'] &&
                element['value']
                    .any((item) => item == option[index]['value']['value'])) {
              options.add({
                'selectedOptionIndex': index.toString(),
                'selectedAnswer': true
              });
            }
          });
        } else {
          if (_questionAnswers.any((element) =>
              element['index'] == _microSurvey[_questionIndex]['identifier'] &&
              element['value'] == option[index]['value']['body'])) {
            options.add({
              'selectedOptionIndex': index.toString(),
              'selectedAnswer': true
            });
          }
        }
      }
    } else {
      if (AssessmentQuestionType.ftb.toUpperCase() ==
          _microSurvey[_questionIndex]['qType'].toString().toUpperCase()) {
        _questionAnswers.forEach((element) {
          if (element['index'] == _microSurvey[_questionIndex]['identifier']) {
            for (int optIndex = 0;
                optIndex < element['value'].length;
                optIndex++) {
              if (!options.any((item) =>
                  (item['selectedAnswer'] == element['value'][optIndex]))) {
                options.add({
                  'selectedOptionIndex': optIndex.toString(),
                  'selectedAnswer': element['value'][optIndex]
                });
              }
            }
          }
        });
      }
    }
    Map<String, dynamic> questionTimeSpentData = widget
        .assessmentDetails[widget.sectionIndex].timeSpent
        .firstWhere((element) =>
            element['questionId'] ==
            _microSurvey[_questionIndex]['identifier']);

    List<Map<String, dynamic>> submittedAnswer = [
      {
        'identifier': _microSurvey[_questionIndex]['identifier'],
        'editorState': {'options': options},
        'timeSpent': questionTimeSpentData['timeSpent']
      }
    ];

    Map surveyData;
    surveyData = {
      'identifier': widget.identifier,
      'primaryCategory': widget.primaryCategory,
      'courseId': widget.parentCourseId,
      'result': [
        {
          'sectionId': widget.assessmentInfo.identifier,
          'timeSpentOnSection': DateTime.now().millisecondsSinceEpoch -
              sectionStartTime!.millisecondsSinceEpoch +
              widget.assessmentDetails[widget.sectionIndex].sectionalTimeTaken,
          'children': submittedAnswer,
        }
      ]
    };

    await assessmentService.saveAssessmentQuestion(surveyData);
  }

  void submitAssessment(BuildContext context, {bool submitAssessment = false}) {
    updateTimeToAssessmentDetails();
    if (!_answerGiven(_microSurvey[_questionIndex]['identifier'])) {
      widget.getAnsweredQuestions(widget.sectionIndex, _questionAnswers,
          status: AssessmentQuestionStatus.notAnswered,
          id: _microSurvey[_questionIndex]['identifier']);
      setState(() {
        if (!_notAnsweredQuestions.contains(_questionIndex)) {
          _notAnsweredQuestions.add(_questionIndex);
        }
      });
    }
    _onSubmitAssessment(context, submitAssessment: submitAssessment);
  }
}
