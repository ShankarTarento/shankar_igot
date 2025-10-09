import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/_assessment/display_question_widget.dart';
import '../../../../constants/index.dart';
import '../../../../feedback/constants.dart';
import '../../../../util/helper.dart';
import '../../../pages/index.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

class QuestionStatusSummaryV2 extends StatefulWidget {
  final Map apiResponse;
  final List assessmentsInfo;
  const QuestionStatusSummaryV2(
      {Key? key, required this.apiResponse, required this.assessmentsInfo})
      : super(key: key);

  @override
  State<QuestionStatusSummaryV2> createState() =>
      _QuestionStatusSummaryV2State();
}

class _QuestionStatusSummaryV2State extends State<QuestionStatusSummaryV2> {
  final List<Map<String, dynamic>> questionStatusList = [
    {'name': AssessmentQuestionStatus.all, 'status': true},
    {'name': AssessmentQuestionStatus.correct, 'status': false},
    {'name': AssessmentQuestionStatus.wrong, 'status': false},
    {'name': AssessmentQuestionStatus.unattempted, 'status': false}
  ];

  List<Map<String, dynamic>> sectionList = [];
  List<Map<String, dynamic>> questionSet = [];
  final ScrollController _horizontalScrollController = ScrollController();
  dynamic selectedItem;
  String status = AssessmentQuestionStatus.all;

  @override
  void initState() {
    super.initState();
    _getSectionList();
    _updateQuestionSet(status: status);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16).r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionList.isNotEmpty
              ? Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5).r,
                  decoration: BoxDecoration(
                      color: AppColors.appBarBackground,
                      border: Border.all(color: AppColors.darkBlue),
                      borderRadius: BorderRadius.circular(6).r),
                  child: DropdownButton<String>(
                    isDense: true,
                    value: selectedItem['identifier'],
                    underline: Center(),
                    dropdownColor: AppColors.appBarBackground,
                    iconEnabledColor: AppColors.darkBlue,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedItem = sectionList.firstWhere(
                            (element) => element['identifier'] == newValue);
                        getSectionWiseQuestionSet(newValue!);
                        _updateQuestionSet(
                            status: status,
                            identifier: newValue == AssessmentQuestionStatus.all
                                ? null
                                : newValue);
                      });
                    },
                    items: sectionList.map<DropdownMenuItem<String>>((value) {
                      return DropdownMenuItem<String>(
                        value: value['identifier'],
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 0.77.sw),
                          child: Text(
                            value['category'],
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.lato(
                              color: AppColors.darkBlue,
                              fontSize: 14.0.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.25,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                )
              : Center(),
          Wrap(
              alignment: WrapAlignment.start,
              children: questionStatusList.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, dynamic> item = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: ElevatedButton(
                    onPressed: () {
                      _updateStatus(index);
                      status = item['name'];
                      _updateQuestionSet(
                          status: item['name'],
                          identifier: selectedItem != null &&
                                  selectedItem['identifier'] !=
                                      AssessmentQuestionStatus.all
                              ? selectedItem['identifier']
                              : null);
                    },
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                      backgroundColor: item['status']
                          ? AppColors.darkBlue
                          : AppColors.appBarBackground,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: AppColors.darkBlue),
                        borderRadius: BorderRadius.all(Radius.circular(5)).r,
                      ),
                    ),
                    child: Text(
                      getText(item['name']),
                      style: GoogleFonts.roboto(
                        color: item['status']
                            ? AppColors.appBarBackground
                            : AppColors.darkBlue,
                        fontSize: 16.0.sp,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.25,
                      ),
                    ),
                  ),
                );
              }).toList()),
          SizedBox(height: 8.w),
          questionSet.isNotEmpty
              ? Container(
                  padding: EdgeInsets.symmetric(vertical: 16).r,
                  child: Scrollbar(
                    thumbVisibility: true,
                    controller: _horizontalScrollController,
                    child:
                        NotificationListener<OverscrollIndicatorNotification>(
                      onNotification:
                          (OverscrollIndicatorNotification overscroll) {
                        overscroll.disallowIndicator();
                        return true;
                      },
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        controller: _horizontalScrollController,
                        child: Container(
                          margin: EdgeInsets.only(bottom: 16).r,
                          child: Table(
                            columnWidths: const {
                              0: FixedColumnWidth(200.0),
                              1: FixedColumnWidth(120.0),
                              2: FixedColumnWidth(190.0),
                              3: FixedColumnWidth(150.0),
                            },
                            children: [
                              TableRow(
                                children: [
                                  TableCell(
                                    child: Container(
                                      padding: EdgeInsets.all(16).r,
                                      color: AppColors.grey04,
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .mStaticQuestions,
                                        style: GoogleFonts.lato(
                                            color: AppColors.greys60,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Container(
                                      color: AppColors.grey04,
                                      padding: EdgeInsets.all(16.0).r,
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .mAssessmentStatus,
                                        style: GoogleFonts.lato(
                                            color: AppColors.greys60,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Container(
                                      color: AppColors.grey04,
                                      padding: EdgeInsets.all(16.0).r,
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .mAssessmentQuestionTagging,
                                        style: GoogleFonts.lato(
                                            color: AppColors.greys60,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Container(
                                      color: AppColors.grey04,
                                      padding: EdgeInsets.all(16.0).r,
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .mAssessmentTimeTaken,
                                        style: GoogleFonts.lato(
                                            color: AppColors.greys60,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              for (var row in questionSet)
                                TableRow(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom:
                                          BorderSide(color: AppColors.grey16),
                                    ),
                                  ),
                                  children: [
                                    TableCell(
                                      child: Container(
                                        padding: EdgeInsets.all(16.0),
                                        child: RegExpressions.inputTagRegExp
                                                .hasMatch(
                                                    Helper.decodeHtmlEntities(
                                                        row['question']))
                                            ? Wrap(
                                                children: renderHtmlContent(
                                                    Helper.decodeHtmlEntities(
                                                        row['question'])),
                                              )
                                            : DisplayQuestionWidget(
                                                htmlText: row['question'],
                                                textStyle: GoogleFonts.lato(
                                                    color:
                                                        FeedbackColors.black87,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 14.0.sp,
                                                    height: 1.5),
                                              ),
                                      ),
                                    ),
                                    TableCell(
                                      child: Container(
                                        padding: EdgeInsets.all(16.0),
                                        child: Text(
                                            row['status'] != null
                                                ? row['status']
                                                            .toString()
                                                            .toLowerCase() ==
                                                        AssessmentQuestionStatus
                                                            .correct
                                                            .toLowerCase()
                                                    ? Helper.capitalizeFirstLetter(
                                                        row['status'])
                                                    : row['status']
                                                                    .toString()
                                                                    .toLowerCase() ==
                                                                AssessmentQuestionStatus
                                                                    .wrong
                                                                    .toLowerCase() ||
                                                            row['status']
                                                                    .toString()
                                                                    .toLowerCase() ==
                                                                AssessmentQuestionStatus
                                                                    .incorrect
                                                                    .toLowerCase()
                                                        ? Helper.capitalizeFirstLetter(
                                                            AssessmentQuestionStatus
                                                                .wrong)
                                                        : Helper.capitalizeFirstLetter(
                                                            AssessmentQuestionStatus
                                                                .unattempted)
                                                : '',
                                            style: GoogleFonts.lato(
                                                color: row['status'] != null
                                                    ? row['status'].toString().toLowerCase() == AssessmentQuestionStatus.correct.toLowerCase()
                                                        ? AppColors.positiveLight
                                                        : row['status'].toString().toLowerCase() == AssessmentQuestionStatus.wrong.toLowerCase() || row['status'].toString().toLowerCase() == AssessmentQuestionStatus.incorrect.toLowerCase()
                                                            ? AppColors.negativeLight
                                                            : AppColors.blackLegend
                                                    : AppColors.blackLegend,
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w400)),
                                      ),
                                    ),
                                    TableCell(
                                      child: Container(
                                        padding: EdgeInsets.all(16.0),
                                        child: Text(
                                            row['tagging'] != null &&
                                                    row['tagging'] != ''
                                                ? Helper()
                                                    .capitalizeFirstCharacter(
                                                        row['tagging'])
                                                : 'N/A',
                                            style: GoogleFonts.lato(
                                                color: AppColors.blackLegend,
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w400)),
                                      ),
                                    ),
                                    TableCell(
                                      child: Container(
                                        padding: EdgeInsets.all(16.0),
                                        child: Text(
                                            row['time'] != null
                                                ? row['time'].toString()
                                                : '00:00:00',
                                            style: GoogleFonts.lato(
                                                color: AppColors.blackLegend,
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w400)),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 40).r,
                    child: NoDataWidget(
                      isCompleted: true,
                      message: AppLocalizations.of(context)!.mDiscussNodata,
                    ),
                  ),
                )
        ],
      ),
    );
  }

  void _updateStatus(int index) {
    setState(() {
      for (int i = 0; i < questionStatusList.length; i++) {
        questionStatusList[i]['status'] = (i == index);
      }
    });
  }

  String getText(item) {
    if (item.toString().compareTo(AssessmentQuestionStatus.all) == 0) {
      return AppLocalizations.of(context)!.mCommonAll;
    } else if (item.toString().compareTo(AssessmentQuestionStatus.correct) ==
        0) {
      return AppLocalizations.of(context)!.mAssessmentCorrect;
    } else if (item.toString().compareTo(AssessmentQuestionStatus.wrong) == 0) {
      return AppLocalizations.of(context)!.mAssessmentWrong;
    } else if (item
            .toString()
            .compareTo(AssessmentQuestionStatus.unattempted) ==
        0) {
      return AppLocalizations.of(context)!.mAssessmentUnattempted;
    } else {
      return '';
    }
  }

  void _updateQuestionSet({required String status, String? identifier}) {
    if (questionSet.isNotEmpty) {
      _horizontalScrollController.jumpTo(0);
    }
    if (status == AssessmentQuestionStatus.all) {
      questionSet.clear();
      widget.apiResponse['children'].forEach((section) {
        if (identifier == section['identifier'] ||
            identifier == null && section['children'] != null) {
          section['children'].forEach((item) {
            questionSet.add({
              'question': item['question'],
              'status': item['result'],
              'tagging':
                  item['questionLevel'] != null ? item['questionLevel'] : '',
              'time': item['timeSpent'] != null
                  ? DateFormat('HH:mm:ss').format(
                      DateTime.fromMillisecondsSinceEpoch(item['timeSpent'],
                          isUtc: true))
                  : '00:00:00'
            });
          });
        }
      });
    } else if (status == AssessmentQuestionStatus.correct) {
      questionSet.clear();
      widget.apiResponse['children'].forEach((section) {
        if (identifier == section['identifier'] ||
            identifier == null && section['children'] != null) {
          section['children'].forEach((item) {
            if (item['result'].toString().toLowerCase() == 'correct') {
              questionSet.add({
                'question': item['question'],
                'status': item['result'],
                'tagging':
                    item['questionLevel'] != null ? item['questionLevel'] : '',
                'time': item['timeSpent'] == null
                    ? '00:00:00'
                    : DateFormat('HH:mm:ss').format(
                        DateTime.fromMillisecondsSinceEpoch(item['timeSpent'],
                            isUtc: true))
              });
            }
          });
        }
      });
    } else if (status == AssessmentQuestionStatus.wrong) {
      questionSet.clear();
      widget.apiResponse['children'].forEach((section) {
        if (identifier == section['identifier'] ||
            identifier == null && section['children'] != null) {
          section['children'].forEach((item) {
            if (item['result'].toString().toLowerCase() == 'incorrect') {
              questionSet.add({
                'question': item['question'],
                'status': item['result'],
                'tagging':
                    item['questionLevel'] != null ? item['questionLevel'] : '',
                'time': item['timeSpent'] == null
                    ? '00:00:00'
                    : DateFormat('HH:mm:ss').format(
                        DateTime.fromMillisecondsSinceEpoch(item['timeSpent'],
                            isUtc: true))
              });
            }
          });
        }
      });
    } else if (status == AssessmentQuestionStatus.unattempted) {
      questionSet.clear();
      widget.apiResponse['children'].forEach((section) {
        if (identifier == section['identifier'] ||
            identifier == null && section['children'] != null) {
          section['children'].forEach((item) {
            if (item['result'].toString().toLowerCase() == 'blank') {
              questionSet.add({
                'question': item['question'],
                'status': getStatus(item['result']),
                'tagging':
                    item['questionLevel'] != null ? item['questionLevel'] : '',
                'time': item['timeSpent'] == null
                    ? '00:00:00'
                    : DateFormat('HH:mm:ss').format(
                        DateTime.fromMillisecondsSinceEpoch(item['timeSpent'],
                            isUtc: true))
              });
            }
          });
        }
      });
    }
  }

  getStatus(result) {
    if (result.toString().toLowerCase() == 'correct') {
      return AssessmentQuestionStatus.correct;
    } else if (result.toString().toLowerCase() == 'blank') {
      return AssessmentQuestionStatus.unattempted;
    } else {
      return AssessmentQuestionStatus.wrong;
    }
  }

  void _getSectionList() {
    if (widget.assessmentsInfo.length > 1) {
      sectionList.add({
        'category': AssessmentQuestionStatus.all,
        'identifier': AssessmentQuestionStatus.all
      });
      selectedItem = sectionList.first;
      widget.assessmentsInfo.forEach((element) {
        sectionList
            .add({'category': element.name, 'identifier': element.identifier});
      });
    }
  }

  void getSectionWiseQuestionSet(String newValue) {}

  List<Widget> renderHtmlContent(String html) {
    final document = html_parser.parse(html);
    final widgets = <Widget>[];

    void processNode(dom.Node node, {TextStyle? currentStyle}) {
      if (node is dom.Element) {
        var newStyle = currentStyle ?? DefaultTextStyle.of(context).style;
        if (node.localName == 'em') {
          newStyle = newStyle.copyWith(fontStyle: FontStyle.italic);
        }
        if (node.localName == 'strong') {
          newStyle = newStyle.copyWith(fontWeight: FontWeight.bold);
        }
        if (node.localName == 'input') {
          widgets.add(Text(' ____________ ', style: newStyle));
        } else if (node.nodes.isEmpty || node.nodes.length == 1) {
          widgets.add(HtmlWidget(node.outerHtml));
        } else {
          node.nodes.forEach((childNode) {
            processNode(childNode, currentStyle: newStyle);
          });
        }
      } else if (node is dom.Text) {
        widgets.add(Text(node.text.trim(), style: currentStyle));
      }
    }

    document.body?.nodes.forEach(processNode);
    return widgets;
  }
}
