import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/ui/widgets/alert_dialog/alert_dialog.dart';
import 'package:karmayogi_mobile/constants/_constants/learn_compatibility_constants.dart';
import 'package:karmayogi_mobile/feedback/constants.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:karmayogi_mobile/services/_services/learn_service.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/_assessment/_models/guest_data_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/_assessment/assessment_verification_screen.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/_assessment/new_assessment_v2_questions.dart';
import 'package:karmayogi_mobile/ui/widgets/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../constants/index.dart';
import '../../../../models/_models/assessment_save_point_model.dart';
import '../../../../services/_services/assessment_service.dart';
import '../../../../util/faderoute.dart';
import '../../../../util/telemetry_repository.dart';
import '../../../pages/_pages/toc/model/navigation_model.dart';
import '../../../pages/_pages/toc/view_model/toc_player_view_model.dart';

class AssessmentV2Section extends StatefulWidget {
  final CourseHierarchyModel course;
  final String identifier;
  final questionSets;
  final ValueChanged<double> parentAction;
  final String batchId;
  final duration;
  final bool isNewAssessment;
  final String primaryCategory;
  final String? objectType;
  final assessmentsInfo;
  final updateContentProgress;
  final String? fileUrl;
  final String parentCourseId;
  final int compatibilityLevel;
  final SavePointModel? savePointInfo;
  final String assessmentType;
  final bool showMark;
  final NavigationModel resourceInfo;
  final bool isFeatured;
  final String courseCategory;
  final GuestDataModel? guestUserData;
  final bool isPreRequisite;
  final String? preEnrolmentAssessmentId;
  final String? preRequisiteMimeType;

  const AssessmentV2Section(this.course, this.identifier, this.questionSets,
      this.parentAction, this.batchId, this.duration,
      {Key? key,
      this.isNewAssessment = false,
      required this.primaryCategory,
      this.objectType,
      this.assessmentsInfo,
      this.updateContentProgress,
      this.fileUrl,
      required this.parentCourseId,
      this.compatibilityLevel = 5,
      this.savePointInfo,
      required this.assessmentType,
      this.showMark = false,
      required this.resourceInfo,
      this.isFeatured = false,
      required this.courseCategory,
      this.guestUserData,
      this.isPreRequisite = false,
      this.preEnrolmentAssessmentId,
      this.preRequisiteMimeType
      })
      : super(key: key);

  @override
  State<AssessmentV2Section> createState() => _AssessmentV2SectionState();
}

class _AssessmentV2SectionState extends State<AssessmentV2Section> {
  final LearnService learnService = LearnService();
  final AssessmentService assessmentService = AssessmentService();

  // String _timeFormat;
  int? _start;
  Timer? _timer;
  List _selected = [];
  int? _selectedSection;

  String? userId;
  String? userSessionId;
  String? messageIdentifier;
  String? departmentId;
  String? pageIdentifier;
  String? telemetryType;
  String? pageUri;
  List allEventsData = [];
  String? deviceIdentifier;
  late String courseId;
  var telemetryEventData;

  @override
  void initState() {
    super.initState();
    _start = widget.duration;
    courseId = TocPlayerViewModel()
        .getEnrolledCourseId(context, widget.parentCourseId);
    if (_start == widget.duration) {
      telemetryType = TelemetryType.player;
      pageIdentifier = TelemetryPageIdentifier.assessmentPlayerPageId;
      pageUri =
          "viewer/quiz/${widget.identifier}?primaryCategory=Learning%20Resource&collectionId=${widget.parentCourseId}&collectionType=Course&batchId=${widget.course.batches != null ? widget.course.batches!.last.batchId : widget.batchId}";
      _generateTelemetryData();
    }

    widget.assessmentsInfo[0].childStatus = [];
    widget.assessmentsInfo[0].timeSpent = [];
    widget.assessmentsInfo[0].sectionalTimeTaken = 0;
  }

  void _generateTelemetryData() async {
    var telemetryRepository = TelemetryRepository();
    Map eventData1 = telemetryRepository.getStartTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.assessmentPlayerPageId,
        telemetryType: telemetryType!,
        pageUri: pageUri!,
        objectId: widget.identifier,
        objectType: widget.primaryCategory,
        env: TelemetryEnv.learn,
        l1: widget.parentCourseId);
    await telemetryRepository.insertEvent(eventData: eventData1);

    Map eventData2 = telemetryRepository.getImpressionTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.assessmentPlayerPageId,
        telemetryType: telemetryType!,
        pageUri: pageUri!,
        env: TelemetryEnv.learn,
        objectId: widget.identifier,
        objectType: widget.primaryCategory);
    await telemetryRepository.insertEvent(eventData: eventData2);
  }

  void _generateInteractTelemetryData(String contentId, String subtype) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.assessmentPlayerPageId,
        contentId: contentId,
        subType: subtype,
        env: TelemetryEnv.learn,
        objectType: widget.primaryCategory);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  String formatHHMMSS(int seconds, {bool insertPadding = true}) {
    int hours = (seconds / 3600).truncate();
    seconds = (seconds % 3600).truncate();
    int minutes = (seconds / 60).truncate();

    if (insertPadding) {
      String hoursStr = (hours).toString().padLeft(2, '0');
      String minutesStr = (minutes).toString().padLeft(2, '0');
      String secondsStr = (seconds % 60).toString().padLeft(2, '0');

      if (hours == 0) {
        return '$minutesStr:$secondsStr';
      }
      return '$hoursStr:$minutesStr:$secondsStr';
    } else {
      return '${hours.toString()}:${minutes.toString()}:${seconds.toString()}';
    }
  }

  _getAnsweredStatus(int index, List<dynamic> selectedAnswers,
      {String? status, String? id}) {
    var selected = _selected.sublist(0);
    if (selected.length > 0) {
      for (var i = 0; i < selected.length; i++) {
        if (!selected.any((element) =>
            element['index'] == index &&
            element['selectedAnswers'] == selectedAnswers)) {
          if (selected[i]['index'] == index && selected.length > i) {
            _selected[i] = {'index': index, 'selectedAnswers': selectedAnswers};
            if (selected.length > i + 1) {
              _selected.remove(selected[i + 1]);
            }
          } else {
            _selected.add({'index': index, 'selectedAnswers': selectedAnswers});
          }
        } else if (selected[i]['index'] == index &&
            selected[i]['selectedAnswers'] == selectedAnswers &&
            status != null &&
            id != null) {
          var updateItem = selected[i]['selectedAnswers'].firstWhere(
              (element) => element['index'] == id,
              orElse: () => null);
          if (updateItem != null) {
            updateItem['status'] = status;
          }
        }
      }
    } else {
      _selected.add({'index': index, 'selectedAnswers': selectedAnswers});
    }
    if (id != null && status != null) {
      if (widget.assessmentsInfo[index].childStatus == null ||
          widget.assessmentsInfo[index].childStatus.isEmpty) {
        widget.assessmentsInfo[index].childStatus = [
          {'questionId': id, 'status': status}
        ];
      } else {
        Map<String, dynamic>? data = widget.assessmentsInfo[index].childStatus
            .cast<Map<String, dynamic>?>()
            .firstWhere((element) => element['questionId'] == id,
                orElse: () => null);
        if (data == null) {
          widget.assessmentsInfo[index].childStatus
              .add({'questionId': id, 'status': status});
        } else {
          data['status'] = status;
        }
      }
    }

    _selected.sort((a, b) => a['index'].compareTo(b['index']));
  }

  Future<void> _submitSurvey() async {
    _generateInteractTelemetryData(widget.identifier, TelemetrySubType.submit);
    var questionAnswers = [];
    var courseAssessmentData = [];

    for (var q = 0; q < widget.questionSets.length; q++) {
      _selected.forEach((selectedItem) {
        if (selectedItem['index'] == q) {
          questionAnswers = selectedItem['selectedAnswers'];
        }
      });
      List assessmentQuestions = List.from(widget.questionSets[q].sublist(0));
      for (int index = 0; index < widget.assessmentsInfo.length; index++) {
        for (int qstnIndex = 0;
            qstnIndex < assessmentQuestions.length;
            qstnIndex++) {
          Map<String, dynamic> timeSpentData =
              widget.assessmentsInfo[index].timeSpent == null ||
                      widget.assessmentsInfo[index].timeSpent.isEmpty
                  ? {}
                  : (widget.assessmentsInfo[index].timeSpent as List)
                      .cast<Map<String, dynamic>>()
                      .firstWhere(
                          (item) =>
                              item['questionId'] ==
                              assessmentQuestions[qstnIndex]['identifier'],
                          orElse: () => {});
          if (timeSpentData['questionId'] ==
              assessmentQuestions[qstnIndex]['identifier']) {
            assessmentQuestions[qstnIndex]['timeSpent'] =
                timeSpentData.isNotEmpty ? timeSpentData['timeSpent'] : 0;
          }
        }
      }

      for (int i = 0; i < widget.questionSets[q].length; i++) {
        var userSelected;
        widget.questionSets[q][i]['editorState'] =
            widget.questionSets[q][i]['editorState'] != null
                ? widget.questionSets[q][i]['editorState']
                : widget.questionSets[q][i]['choices'];
        assessmentQuestions[i]['editorState'] =
            assessmentQuestions[i]['editorState'] != null
                ? assessmentQuestions[i]['editorState']
                : assessmentQuestions[i]['choices'];
        for (int j = 0; j < questionAnswers.length; j++) {
          if (questionAnswers[j]['index'] ==
              widget.questionSets[q][i]['identifier']) {
            if (questionAnswers[j]['value'] != null)
              userSelected = questionAnswers[j];
          }
        }
        if (assessmentQuestions[i]['qType'] ==
            AssessmentQuestionType.matchCase.toUpperCase()) {
          for (int k = 0;
              k < widget.questionSets[q][i]['editorState']['options'].length;
              k++) {
            if (userSelected != null) {
              for (var m = 0; m < userSelected['value'].length; m++) {
                if (m ==
                    widget.questionSets[q][i]['editorState']['options'][k]
                        ['value']['value']) {
                  assessmentQuestions[i]['editorState']['options'][k]['index'] =
                      widget.questionSets[q][i]['editorState']['options'][k]
                              ['value']['value']
                          .toString();
                  assessmentQuestions[i]['editorState']['options'][k]
                      ['selectedAnswer'] = userSelected['value'][m];
                }
              }
            }
          }
        } else if (assessmentQuestions[i]['qType'] ==
            AssessmentQuestionType.radioType.toUpperCase()) {
          for (int k = 0;
              k < widget.questionSets[q][i]['editorState']['options'].length;
              k++) {
            if (userSelected != null) {
              if (widget.questionSets[q][i]['editorState']['options'][k]
                          ['value']['body']
                      .toString() ==
                  userSelected['value'].toString()) {
                assessmentQuestions[i]['editorState']['options'][k]['index'] =
                    widget.questionSets[q][i]['editorState']['options'][k]
                            ['value']['value']
                        .toString();
                assessmentQuestions[i]['editorState']['options'][k]
                    ['selectedAnswer'] = true;
              }
            }
          }
        } else if (assessmentQuestions[i]['qType'] ==
                AssessmentQuestionType.checkBoxWeightageType.toUpperCase() ||
            assessmentQuestions[i]['qType'] ==
                AssessmentQuestionType.radioWeightageType.toUpperCase()) {
          if (userSelected != null) {
            int selectedIndex = userSelected['optionIndex'];
            if (widget.questionSets[q][i]['editorState']['options']
                        [selectedIndex]['value']['body']
                    .toString() ==
                userSelected['value'].toString()) {
              assessmentQuestions[i]['editorState']['options'][selectedIndex]
                  ['index'] = widget.questionSets[q][i]['editorState']
                      ['options'][selectedIndex]['value']['value']
                  .toString();
              assessmentQuestions[i]['editorState']['options'][selectedIndex]
                  ['selectedAnswer'] = true;
            }
          }
        } else if (assessmentQuestions[i]['qType'] ==
            AssessmentQuestionType.checkBoxType.toUpperCase()) {
          for (int k = 0;
              k < widget.questionSets[q][i]['editorState']['options'].length;
              k++) {
            if (userSelected != null) {
              userSelected['value'].forEach((element) {
                if ((element) ==
                    widget.questionSets[q][i]['editorState']['options'][k]
                        ['value']['value']) {
                  assessmentQuestions[i]['editorState']['options'][k]['index'] =
                      widget.questionSets[q][i]['editorState']['options'][k]
                              ['value']['value']
                          .toString();
                  assessmentQuestions[i]['editorState']['options'][k]
                      ['selectedAnswer'] = true;
                }
              });
            }
          }
        } else if (userSelected != null &&
            assessmentQuestions[i]['qType'] ==
                AssessmentQuestionType.ftb.toUpperCase()) {
          if (widget.questionSets[q][i]['editorState'] != null) {
            for (int k = 0;
                k < widget.questionSets[q][i]['editorState']['options'].length;
                k++) {
              if (userSelected != null) {
                for (var m = 0; m < userSelected['value'].length; m++) {
                  if (m ==
                      widget.questionSets[q][i]['editorState']['options'][k]
                          ['value']['value']) {
                    assessmentQuestions[i]['editorState']['options'][k]
                        ['index'] = widget.questionSets[q][i]['editorState']
                            ['options'][k]['value']['value']
                        .toString();
                    assessmentQuestions[i]['editorState']['options'][k]
                        ['selectedAnswer'] = userSelected['value'][m];
                  }
                }
              }
            }
          } else {
            assessmentQuestions[i]['editorState'] = {'options': []};

            for (var m = 0; m < userSelected['value'].length; m++) {
              assessmentQuestions[i]['editorState']['options'].add(
                  {'index': '$m', 'selectedAnswer': userSelected['value'][m]});
            }
          }
        }
      }

      var submittedAnswers = [];

      // Iterate through assessmentQuestions and process each element
      assessmentQuestions.map((element) {
        // Convert the element to JSON and back to Map to create a deep copy
        Map<String, dynamic> _optionInfo = jsonDecode(jsonEncode(element));

        // Perform modifications on _optionInfo
        if (_optionInfo['editorState'] != null &&
            _optionInfo['editorState']['question'] != null) {
          _optionInfo['editorState'].remove('question');
        }
        if (_optionInfo['editorState'] != null) {
          _optionInfo['editorState']['options'].forEach((option) {
            if (option['selectedAnswer'] != null) {
              option.remove('answer');
              option.remove('value');
            }
          });
        }
        if (_optionInfo['editorState'] == null) {
          _optionInfo['editorState'] = {'options': []};
        }
        List<Map<String, dynamic>> editorStateOptions =
            List.from(_optionInfo['editorState']['options'].sublist(0));
        _optionInfo['editorState']['options'] = editorStateOptions
            .where((_optionInfo) => _optionInfo['value'] == null)
            .toList();

        // Prepare data for submittedAnswers without modifying original data
        submittedAnswers.add({
          "identifier": _optionInfo['identifier'],
          "mimeType": _optionInfo['mimeType'],
          "objectType": _optionInfo['objectType'],
          "questionLevel": _optionInfo['questionLevel'],
          "primaryCategory": _optionInfo['qType'] ==
                      AssessmentQuestionType.radioType.toUpperCase() ||
                  _optionInfo['qType'] ==
                      AssessmentQuestionType.radioWeightageType.toUpperCase() ||
                  _optionInfo['qType'] ==
                      AssessmentQuestionType.checkBoxWeightageType.toUpperCase()
              ? 'Single Choice Question'
              : _optionInfo['primaryCategory'],
          "qType": _optionInfo['qType'],
          "editorState": _optionInfo['editorState'],
          "question": _optionInfo['body'],
          "timeSpent": _optionInfo['timeSpent']
        });
      }).toList(); // Convert map result to list if necessary

      Map assessmentData = {
        "identifier": widget.assessmentsInfo[q].identifier,
        "name": widget.assessmentsInfo[q].name,
        "objectType": widget.assessmentsInfo[q].objectType,
        "primaryCategory": widget.assessmentsInfo[q].primaryCategory,
        "scoreCutoffType": widget.assessmentsInfo[q].scoreCutoffType,
        "children": submittedAnswers
      };

      courseAssessmentData.add(assessmentData);
    }
    Map surveyData;
    if (widget.isFeatured) {
      String courseId = TocPlayerViewModel()
          .getEnrolledCourseId(context, widget.parentCourseId);
      surveyData = {
        'batchId': widget.batchId,
        'identifier': widget.identifier,
        'primaryCategory': widget.primaryCategory,
        'courseId': courseId,
        "isAssessment": true,
        'objectType': widget.objectType,
        'timeLimit': widget.duration,
        'children': courseAssessmentData,
        'name': widget.guestUserData?.name ?? '',
        'email': widget.guestUserData?.email ?? '',
        'contextId': courseId,
        'language': widget.resourceInfo.language.toLowerCase()
      };
    } else {
      surveyData = {
        'batchId': widget.batchId,
        'identifier': widget.identifier,
        'primaryCategory': widget.primaryCategory,
        'courseId': courseId,
        "isAssessment": true,
        'objectType': widget.objectType,
        'timeLimit': widget.duration,
        'children': courseAssessmentData,
        'language': widget.resourceInfo.language.toLowerCase()
      };
    }

    var response;
    if (widget.compatibilityLevel >=
        AssessmentCompatibility.dropdownCompatibility.version) {
      response = response = widget.isFeatured
          ? await assessmentService.submitPublicAssessment(surveyData,
              isAdvanceAssessment: true)
          : await assessmentService.submitStandaloneAssessment(surveyData,
              isFTBDropdown: true);
    } else if (widget.compatibilityLevel >=
        AssessmentCompatibility.multimediaCompatibility.version) {
      response = widget.isFeatured
          ? await assessmentService.submitPublicAssessment(surveyData,
              isAdvanceAssessment: true)
          : await assessmentService.submitStandaloneAssessment(surveyData);
    } else {
      response = await assessmentService.submitAssessmentNew(surveyData);
    }

    var contents = jsonDecode(response.body);
    bool submittedSuccessfully =
        (response.statusCode == 200 || response.statusCode == 201);
    if (widget.assessmentType != '' &&
        widget.assessmentType == AssessmentType.optionalWeightage) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext cxt) {
            return AlertDialogWidget(
              dialogRadius: 8,
              icon: Image.asset(
                'assets/img/examlist.png',
                width: 56.0.w,
                height: 56.0.w,
                fit: BoxFit.fill,
              ),
              title: AppLocalizations.of(context)!.mAssessmentThankYouMessage,
              subtitle: AppLocalizations.of(context)!
                  .mAssessmentDetailedAnalysisWillShare,
              primaryButtonText:
                  AppLocalizations.of(context)!.mAssessmentReattemptTest,
              onPrimaryButtonPressed: () async {
                _generateInteractTelemetryData(
                    widget.identifier, AssessmentType.optionalWeightage);
                Navigator.of(cxt).pop();
                await Navigator.pushReplacement(
                    context,
                    FadeRoute(
                        page: CourseAssessmentPlayer(
                            widget.course,
                            widget.identifier,
                            widget.updateContentProgress,
                            widget.batchId,
                            parentCourseId: widget.course.identifier,
                            compatibilityLevel: widget.compatibilityLevel,
                            resourceNavigateItems: widget.resourceInfo,
                            isFeatured: widget.isFeatured,
                            courseCategory: widget.courseCategory,
                            isPreRequisite: widget.isPreRequisite)));
              },
              primaryButtonIcon: SvgPicture.asset(
                'assets/img/assessment_vector.svg',
                width: 24.0.w,
                height: 24.0.w,
              ),
              primaryButtonTextStyle: GoogleFonts.lato(
                color: AppColors.darkBlue,
                fontWeight: FontWeight.w400,
                fontSize: 14.0.sp,
                height: 1.5.w,
              ),
              secondaryButtonText:
                  AppLocalizations.of(context)!.mAssessmentGoBackToToc,
              onSecondaryButtonPressed: () async {
                Navigator.of(cxt).pop();
                Navigator.of(context).pop();
              },
              secondaryButtonIcon: SvgPicture.asset(
                'assets/img/link.svg',
                width: 24.0.w,
                height: 24.0.w,
                colorFilter: ColorFilter.mode(
                    AppColors.appBarBackground, BlendMode.srcIn),
              ),
              secondaryButtonTextStyle: GoogleFonts.lato(
                color: AppColors.appBarBackground,
                fontWeight: FontWeight.w400,
                fontSize: 14.0.sp,
                height: 1.5.w,
              ),
              secondaryButtonBgColor: AppColors.darkBlue,
              alignButtonVertical: true,
            );
          });
    } else if (submittedSuccessfully) {
      Map request = {
        'assessmentId': widget.identifier,
        'batchId': widget.batchId,
        'courseId': widget.parentCourseId,
      };
      Map requestBody = {
        'request': request,
      };

      Navigator.of(context).pop();
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return Container(
              child: AssessmentVerificationScreen(
                  formatHHMMSS(widget.duration - _start, insertPadding: false),
                  requestBody,
                  assessmentsInfo: widget.assessmentsInfo,
                  primaryCategory: widget.primaryCategory,
                  course: widget.course,
                  identifier: widget.identifier,
                  updateContentProgress: widget.updateContentProgress,
                  batchId: widget.batchId,
                  fromSectionalCutoff: widget.questionSets.length > 1,
                  compatibilityLevel: widget.compatibilityLevel,
                  assessmentType: widget.assessmentType,
                  submitResponse: contents['result'],
                  resourceInfo: widget.resourceInfo,
                  isFeatured: widget.isFeatured,
                  courseCategory: widget.courseCategory,
                  isPreRequisite: widget.isPreRequisite));
        },
      );
    } else {
      widget.parentAction(0.0);
      await Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => Scaffold(body: ErrorPage())));
    }
    if (((widget.course.batches != null || widget.batchId != '') ||
            widget.isPreRequisite) &&
        submittedSuccessfully) {
      _updateContentProgress();
      widget.parentAction(100.0);
    }
  }

  Future<void> _updateContentProgress() async {
    List<String> current = [];
    current.add(widget.questionSets.last.length.toString());
    String batchId = widget.batchId;
    String contentId = (widget.isPreRequisite)
        ? (widget.preEnrolmentAssessmentId ?? '')
        : widget.identifier;
    int status = 2;
    String contentType = (widget.isPreRequisite) ? (widget.preRequisiteMimeType??'') : EMimeTypes.newAssessment;
    var maxSize = widget.course.duration;
    // double completionPercentage =
    //     status == 2 ? 100.0 : (_start / maxSize) * 100;
    double completionPercentage = 100.0;
    await learnService.updateContentProgress(courseId, batchId, contentId,
        status, contentType, current, maxSize, completionPercentage,
        isAssessment: true,
        isPreRequisite: widget.isPreRequisite,
        language: widget.resourceInfo.language);
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
        style: GoogleFonts.montserrat(
            decoration: TextDecoration.none,
            color: textColor,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500),
      ),
    );
    return optionButton;
  }

  _navigateToNextSection(int index,
      {bool isSubmitted = false,
      int sectionalTimeTaken = 0,
      int? prevSectionIndex}) {
    // Initialize childStatus with empty list for handling sectional cut-off assessment
    widget.assessmentsInfo[index].childStatus = [];
    widget.assessmentsInfo[index].timeSpent = [];
    if (prevSectionIndex != null)
      widget.assessmentsInfo[prevSectionIndex].sectionalTimeTaken =
          sectionalTimeTaken;
    if (widget.assessmentsInfo[index].sectionalTimeTaken == null)
      widget.assessmentsInfo[index].sectionalTimeTaken = 0;
    if (isSubmitted) {
      widget.assessmentsInfo[index - 1].submitted = true;
    }

    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => NewAssessmentV2Questions(
            widget.course,
            widget.identifier,
            widget.questionSets[index],
            widget.parentAction,
            widget.batchId,
            widget.duration,
            widget.assessmentsInfo[index].expectedDuration,
            key: UniqueKey(),
            isNewAssessment: true,
            primaryCategory: widget.primaryCategory,
            objectType: widget.objectType,
            assessmentInfo: widget.assessmentsInfo[index],
            sectionIndex: index,
            getAnsweredQuestions: _getAnsweredStatus,
            answeredQuestions:
                _selected.indexWhere((element) => element['index'] == index) ==
                        -1
                    ? []
                    : _selected[_selected
                            .indexWhere((element) => element['index'] == index)]
                        ['selectedAnswers'],
            isLastSection: index == widget.assessmentsInfo.length - 1,
            navigateToNextSection: _navigateToNextSection,
            currentRunningTime: _start,
            isFullAnswered: _isFullAnswered,
            submitSurvey: _submitSurvey,
            assessmentSection: widget.questionSets,
            selectedSection: _selectedSection,
            generateInteractTelemetryData: _generateInteractTelemetryData,
            assessmentDetails: widget.assessmentsInfo,
            parentCourseId: widget.parentCourseId,
            compatibilityLevel: widget.compatibilityLevel,
            savePointInfo: widget.savePointInfo,
            assessmentType: widget.assessmentType,
            showMarks: widget.showMark,
            resourceInfo: widget.resourceInfo,
            isFeatured: widget.isFeatured)));
  }

  bool _isFullAnswered() {
    int answered = 0;
    int total = 0;
    widget.questionSets.forEach((element) {
      total = total + int.parse(element.length.toString());
    });

    _selected.forEach((element) {
      answered =
          answered + int.parse(element['selectedAnswers'].length.toString());
    });
    // print("Total: $total, Answered: $answered");

    return total == answered;
  }

  void _triggerEndTelemetryEvent() async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getEndTelemetryEvent(
        pageIdentifier: pageIdentifier!,
        duration: _start!,
        telemetryType: telemetryType!,
        pageUri: pageUri!,
        rollup: {},
        objectId: widget.identifier,
        objectType: widget.primaryCategory,
        env: TelemetryEnv.learn,
        l1: widget.parentCourseId);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  @override
  void dispose() async {
    _triggerEndTelemetryEvent();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.questionSets.length > 1
        ? NewAssessmentV2Questions(
            widget.course,
            widget.identifier,
            widget.questionSets.first,
            widget.parentAction,
            widget.batchId,
            widget.duration,
            widget.assessmentsInfo.first.expectedDuration,
            key: UniqueKey(),
            isNewAssessment: true,
            primaryCategory: widget.primaryCategory,
            objectType: widget.objectType,
            assessmentInfo: widget.assessmentsInfo.first,
            sectionIndex: 0,
            getAnsweredQuestions: _getAnsweredStatus,
            answeredQuestions:
                _selected.length > 0 ? _selected[0]['selectedAnswers'] : [],
            isLastSection: false,
            navigateToNextSection: _navigateToNextSection,
            currentRunningTime: _start,
            isFullAnswered: _isFullAnswered,
            submitSurvey: _submitSurvey,
            assessmentSection: widget.questionSets,
            selectedSection: _selectedSection,
            generateInteractTelemetryData: _generateInteractTelemetryData,
            assessmentDetails: widget.assessmentsInfo,
            parentCourseId: widget.parentCourseId,
            compatibilityLevel: widget.compatibilityLevel,
            savePointInfo: widget.savePointInfo,
            assessmentType: widget.assessmentType,
            showMarks: widget.showMark,
            resourceInfo: widget.resourceInfo,
            isFeatured: widget.isFeatured)
        : widget.questionSets.first.length > 0
            ? NewAssessmentV2Questions(
                widget.course,
                widget.identifier,
                widget.questionSets.first,
                widget.parentAction,
                widget.batchId,
                widget.duration,
                widget.assessmentsInfo.first.expectedDuration,
                key: UniqueKey(),
                isNewAssessment: true,
                primaryCategory: widget.primaryCategory,
                objectType: widget.objectType,
                assessmentInfo: widget.assessmentsInfo.first,
                isLastSection: true,
                submitSurvey: _submitSurvey,
                isFullAnswered: _isFullAnswered,
                sectionIndex: 0,
                getAnsweredQuestions: _getAnsweredStatus,
                answeredQuestions:
                    _selected.length > 0 ? _selected[0]['selectedAnswers'] : [],
                assessmentSection: widget.questionSets,
                generateInteractTelemetryData: _generateInteractTelemetryData,
                assessmentDetails: widget.assessmentsInfo,
                parentCourseId: widget.parentCourseId,
                compatibilityLevel: widget.compatibilityLevel,
                savePointInfo: widget.savePointInfo,
                assessmentType: widget.assessmentType,
                showMarks: widget.showMark,
                resourceInfo: widget.resourceInfo,
                isFeatured: widget.isFeatured)
            : ErrorPage();
  }
}
