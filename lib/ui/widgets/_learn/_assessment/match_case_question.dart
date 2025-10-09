import 'package:clippy_flutter/clippy_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/_assessment/html_webview_widget.dart';
import 'package:reorderables/reorderables.dart';
import '../../../../util/helper.dart';
import '../../_common/page_loader.dart';
import './../../../../constants/_constants/color_constants.dart';
import './../../../../feedback/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MatchCaseQuestion extends StatefulWidget {
  final question;
  final String? questionText;
  final List options;
  final int currentIndex;
  final answerGiven;
  final bool showAnswer;
  final ValueChanged<Map> parentAction;
  final bool isNewAssessment;
  final String? id;
  MatchCaseQuestion(this.question, this.questionText, this.options,
      this.currentIndex, this.answerGiven, this.showAnswer, this.parentAction,
      {this.isNewAssessment = false, this.id});
  @override
  _MatchCaseQuestionQuestionState createState() =>
      _MatchCaseQuestionQuestionState();
}

class _MatchCaseQuestionQuestionState extends State<MatchCaseQuestion> {
  List _options = [];
  double _minHeight = 72;
  List<double> _heights = [];
  String? _qId;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _qId = widget.isNewAssessment ? widget.id : widget.question['questionId'];
    updateRawHeight(widget.options);
    updateOptions();
  }

  void updateRawHeight(List options) {
    for (int i = 0; i < options.length; i++) {
      double height = calculateTextHeight(
        text: options[i],
        maxWidth:
            (1.sw / 2) - 120.w, // available width of your container/column
        style: const TextStyle(fontSize: 16),
      );
      _heights.add(height < _minHeight ? _minHeight : height);
    }
    for (int i = 0; i < widget.question['options'].length; i++) {
      double height = calculateTextHeight(
        text: widget.question['options'][i]['value']['body'],
        maxWidth: (1.sw / 2) - 60.w, // available width of your container/column
        style: const TextStyle(fontSize: 16),
      );
      if (_heights[i] < height) {
        _heights[i] = height < _minHeight ? _minHeight : height;
      }
    }
  }

  double calculateTextHeight({
    required String text,
    required double maxWidth,
    required TextStyle style,
  }) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: null, // allow wrapping
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);

    return textPainter.size.height;
  }

  @override
  void didUpdateWidget(MatchCaseQuestion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_qId !=
        (widget.isNewAssessment ? widget.id : widget.question['questionId'])) {
      _heights = [];
      updateRawHeight(widget.options);
      _qId = widget.isNewAssessment ? widget.id : widget.question['questionId'];
      updateOptions();
    }
  }

  double _getHeight() {
    double height = 0;
    for (var i = 0; i < _heights.length; i++) {
      height = height + _heights[i];
    }
    return height;
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (!widget.showAnswer) {
      final temp = _options[oldIndex];
      _options[oldIndex] = _options[newIndex];
      _options[newIndex] = temp;
      _heights = [];
      updateRawHeight(_options);
      if (mounted) {
        setState(() {});
      }
      widget
          .parentAction({'index': _qId, 'isCorrect': true, 'value': _options});
    }
  }

  _getRows(ctx) {
    return List<Widget>.generate(
        widget.options.length,
        (int index) => InkWell(
              onTap: () {
                Helper.showSnackBarMessage(
                    context: context,
                    text: AppLocalizations.of(context)!
                        .mMatchCaseHoldANdDragItems,
                    bgColor: AppColors.darkBlue);
              },
              onLongPress: widget.showAnswer
                  ? () {
                      setState(() {
                        _selectedIndex = index;
                      });
                      Future.delayed(
                          Duration(
                            seconds: 2,
                          ), () {
                        if (mounted) {
                          setState(() {
                            _selectedIndex = null;
                          });
                        }
                      });
                    }
                  : null,
              child: Container(
                width: (double.infinity - 30).w,
                height: _heights[index],
                margin: EdgeInsets.only(bottom: 8).r,
                child: Row(
                  children: [
                    Label(
                      triangleHeight: 10.0.w,
                      edge: Edge.LEFT,
                      child: Container(
                          alignment: Alignment.centerLeft,
                          width: 1.sw / 2 - 62.w,
                          height: _heights[index],
                          decoration: BoxDecoration(
                            color: widget.showAnswer &&
                                    (widget.isNewAssessment
                                            ? widget.question['options'][index]
                                                ['answer']
                                            : widget.question['options'][index]
                                                ['match']) !=
                                        _options[index]
                                ? FeedbackColors.negativeLightBg
                                : widget.showAnswer &&
                                        (widget.isNewAssessment
                                                ? widget.question['options']
                                                    [index]['answer']
                                                : widget.question['options']
                                                    [index]['match']) ==
                                            _options[index]
                                    ? FeedbackColors.positiveLightBg
                                    : FeedbackColors.background,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.grey08,
                                blurRadius: 6.0.r,
                                spreadRadius: 0.r,
                                offset: Offset(
                                  3,
                                  3,
                                ),
                              ),
                            ],
                            border: Border.all(
                                color: widget.showAnswer &&
                                        (widget.isNewAssessment
                                                ? widget.question['options']
                                                    [index]['answer']
                                                : widget.question['options']
                                                    [index]['match']) !=
                                            _options[index]
                                    ? FeedbackColors.negativeLight
                                    : widget.showAnswer &&
                                            (widget.isNewAssessment
                                                    ? widget.question['options']
                                                        [index]['answer']
                                                    : widget.question['options']
                                                        [index]['match']) ==
                                                _options[index]
                                        ? FeedbackColors.positiveLight
                                        : AppColors.grey08),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          padding: EdgeInsets.all(10).r,
                          // height: 0,
                          child: Padding(
                              padding: const EdgeInsets.only(left: 8).r,
                              child: HtmlWebviewWidget(
                                  htmlText: _selectedIndex != null &&
                                          _selectedIndex == index
                                      ? ((widget.isNewAssessment
                                          ? widget.question['options'][index]
                                              ['answer']
                                          : widget.question['options'][index]
                                              ['match']))
                                      : _options[index],
                                  textStyle: getTextStyle(
                                      _selectedIndex != null && _selectedIndex == index
                                          ? ((widget.isNewAssessment
                                              ? widget.question['options']
                                                  [index]['answer']
                                              : widget.question['options']
                                                  [index]['match']))
                                          : _options[index],
                                      color: _selectedIndex == index
                                          ? FeedbackColors.positiveLight
                                          : FeedbackColors.black87)))),
                    ),
                    Container(
                      width: 40.w,
                      height: _heights[index],
                      decoration: BoxDecoration(
                          color: AppColors.appBarBackground,
                          border: Border(
                              right: BorderSide(
                                color: AppColors.grey08,
                              ),
                              left: BorderSide(
                                  color: AppColors.grey08, width: 0.5),
                              top: BorderSide(
                                color: AppColors.grey08,
                              ),
                              bottom: BorderSide(
                                color: AppColors.grey08,
                              ))
                          // borderRadius: BorderRadius.circular(4),
                          ),
                      child: Center(
                          child: Icon(
                        Icons.reorder,
                        color: AppColors.greys60,
                      )),
                    )
                  ],
                ),
              ),
            ));
  }

  // Make sure there is a scroll controller attached to the scroll view that contains ReorderableSliverList.
  // Otherwise an error will be thrown.

  @override
  Widget build(BuildContext context) {
    ScrollController _scrollController = ScrollController();
    return SingleChildScrollView(
      child: widget.question['options'].length > 0
          ? Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 100).r,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(bottom: 15).r,
                    child: HtmlWebviewWidget(
                      htmlText: widget.questionText != null
                          ? widget.questionText
                          : widget.question['question'],
                      textStyle: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(height: 1.5.w),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(bottom: 15).r,
                    child: Text(
                      AppLocalizations.of(context)!.mMatchCaseHoldANdDragItems,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontSize: 14.sp,
                            fontFamily: GoogleFonts.montserrat().fontFamily,
                          ),
                    ),
                  ),
                  Container(
                      margin: const EdgeInsets.only(bottom: 10).r,
                      child: Divider(
                        color: AppColors.greys,
                      )),
                  Container(
                      width: 1.sw,
                      child: Stack(
                        children: [
                          Container(
                              width: (1.sw / 2) - 26.w,
                              child: ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: _options.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin:
                                        EdgeInsets.only(bottom: 8, right: 4).r,
                                    child: Point(
                                        triangleHeight: 10.0,
                                        edge: Edge.RIGHT,
                                        child: Container(
                                            height: _heights[index],
                                            padding: EdgeInsets.all(10).r,
                                            decoration: BoxDecoration(
                                                color: AppColors.grey
                                                    .withValues(alpha: 0.1),
                                                border: Border(
                                                    left: BorderSide(
                                                      color: AppColors.grey08,
                                                    ),
                                                    right: BorderSide(
                                                        color:
                                                            AppColors.avatarRed,
                                                        width: 0.5),
                                                    top: BorderSide(
                                                      color: AppColors.grey08,
                                                    ),
                                                    bottom: BorderSide(
                                                      color: AppColors.grey08,
                                                    ))),
                                            child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: HtmlWebviewWidget(
                                                  htmlText: widget
                                                          .isNewAssessment
                                                      ? widget.question[
                                                              'options'][index]
                                                          ['value']['body']
                                                      : widget.question[
                                                              'options'][index]
                                                          ['text'],
                                                  textStyle: getTextStyle(widget
                                                          .isNewAssessment
                                                      ? widget.question[
                                                              'options'][index]
                                                          ['value']['body']
                                                      : widget.question[
                                                              'options'][index]
                                                          ['text']),
                                                )))),
                                  );

                                  // ]);
                                },
                              )),
                          Positioned(
                              right: 0,
                              child: Container(
                                height: _getHeight().w + 1.0.sw,
                                width: 1.sw / 2 - 22.w,
                                child: CustomScrollView(
                                  physics: NeverScrollableScrollPhysics(),
                                  // A ScrollController must be included in CustomScrollView, otherwise
                                  // ReorderableSliverList wouldn't work
                                  controller: _scrollController,
                                  slivers: <Widget>[
                                    ReorderableSliverList(
                                      enabled: widget.showAnswer ? false : true,
                                      delegate:
                                          ReorderableSliverChildListDelegate(
                                              _getRows(context)),
                                      onReorder: _onReorder,
                                    )
                                  ],
                                ),
                              )),
                        ],
                      )),
                  widget.showAnswer
                      ? Padding(
                          padding: const EdgeInsets.only(top: 16).r,
                          child: Text(AppLocalizations.of(context)!
                              .mMatchCaseLongPressOnItems),
                        )
                      : Center(),
                  SizedBox(
                    height: 100.w,
                  )
                ],
              ))
          : PageLoader(),
    );
  }

  TextStyle? getTextStyle(String htmlText,
      {Color color = FeedbackColors.black87}) {
    return htmlText.contains('<strong>')
        ? null
        : GoogleFonts.lato(
            color: color,
            fontWeight: FontWeight.w400,
            fontSize: 14.sp,
          );
  }

  void updateOptions() {
    if (widget.answerGiven.isEmpty) {
      _options = List.from(widget.options);
    } else {
      _options = List.from(widget.answerGiven);
    }
  }
}
