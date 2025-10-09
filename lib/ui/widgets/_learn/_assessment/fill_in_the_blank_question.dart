import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import './../../../../constants/index.dart';
import './../../../../feedback/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

class FillInTheBlankQuestion extends StatefulWidget {
  final question;
  final String questionText;
  final int currentIndex;
  final answerGiven;
  final bool showAnswer;
  final ValueChanged<Map> parentAction;
  final String id;
  FillInTheBlankQuestion(this.question, this.questionText, this.currentIndex,
      this.answerGiven, this.showAnswer, this.parentAction,
      {required this.id});
  @override
  _FillInTheBlankQuestionState createState() => _FillInTheBlankQuestionState();
}

class _FillInTheBlankQuestionState extends State<FillInTheBlankQuestion> {
  String? _qId;
  List<String> _alphabets =
      List.generate(10, (index) => String.fromCharCode(index + 65));
  late String _questionWithBlank;
  List<dynamic> _answer = [];
  late int _blankCount;
  dynamic _question;
  final List<TextEditingController> _optionController = [];
  List<FocusNode> optionFocusNode = [];
  List<Widget>? contentWidgets;

  @override
  void initState() {
    super.initState();
    _qId = widget.id;
    getData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Helper.isHtml(_questionWithBlank)) {
      contentWidgets =
          renderHtmlContent(Helper.decodeHtmlEntities(_questionWithBlank));
      if (widget.answerGiven.isEmpty) {
        _answer = [];
      }
      for (var i = 0; i < _answer.length; i++) {
        _optionController[i].text = _answer[i];
      }
    }
  }

  getData() async {
    await _setText();
    if (Helper.isHtml(_questionWithBlank)) {
      contentWidgets =
          renderHtmlContent(Helper.decodeHtmlEntities(_questionWithBlank));
      for (var i = 0; i < _answer.length; i++) {
        _optionController[i].text = _answer[i];
      }
    }
  }

  @override
  void didUpdateWidget(FillInTheBlankQuestion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id == widget.id) {
      if (oldWidget.answerGiven.isNotEmpty && widget.answerGiven.isEmpty) {
        _answer = [];
        getData();
      }
      // setState(() {
      //   if (widget.answerGiven.isEmpty) {
      //     _answer = [];
      //     getData();
      //   }
      // });
    } else {
      setState(() {
        if (widget.answerGiven.isEmpty) {
          _answer = [];
        }
        _qId = widget.id;
        getData();
      });
    }
  }

  Future<void> _setText() async {
    _optionController.clear();
    String substring = "_______________";
    RegExp regExp = RegExp(substring);
    _blankCount = regExp.allMatches(widget.questionText).length;
    _questionWithBlank = widget.questionText;
    _question = widget.question;
    if (widget.answerGiven != '') {
      _answer = List.from(widget.answerGiven.sublist(0));
    }
    if (!Helper.isHtml(_questionWithBlank)) {
      for (var i = 0;
          i <
              ((_question != null && _question['options'] != null)
                  ? _question['options'].length
                  : _blankCount);
          i++) {
        _optionController.add(TextEditingController());
        optionFocusNode.add(FocusNode());
        _questionWithBlank = _questionWithBlank.replaceFirst(
            "_______________", " ___(${_alphabets[i].toLowerCase()})___");
      }
      for (var i = 0; i < _answer.length; i++) {
        _optionController[i].text = _answer[i];
      }
    }
  }

  @override
  void dispose() {
    _optionController.clear();
    optionFocusNode.forEach((element) {
      element.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        // height: 1.sh - 30.w,
        padding: const EdgeInsets.all(32).r,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 15).r,
              child: Text(
                AppLocalizations.of(context)!.mStaticFillInTheBlanks,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Container(
                margin: const EdgeInsets.only(bottom: 10).r,
                child: Divider(
                  color: AppColors.greys60,
                )),
            Container(
              padding: const EdgeInsets.only(bottom: 15).r,
              child: Helper.isHtml(_questionWithBlank)
                  ? Wrap(
                      children: contentWidgets!,
                    )
                  : HtmlWidget(
                      Helper.decodeHtmlEntities(_questionWithBlank),
                      textStyle: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(height: 1.5.w),
                    ),
            ),
            SizedBox(
              height: 16.w,
            ),
            !Helper.isHtml(_questionWithBlank)
                ? Column(
                    children: [
                      for (var i = 0;
                          i <
                              ((_question != null &&
                                      _question['options'] != null)
                                  ? _question['options'].length
                                  : _blankCount);
                          i++)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                                width: 1.sw,
                                decoration: BoxDecoration(
                                  color: AppColors.appBarBackground,
                                  borderRadius: BorderRadius.circular(4).r,
                                ),
                                child: TextField(
                                  controller: _optionController[i],
                                  focusNode: optionFocusNode[i],
                                  onEditingComplete: () {
                                    widget.parentAction({
                                      'index': _qId,
                                      'isCorrect': (_question != null &&
                                              _question['options'] != null)
                                          ? _question['options'][i]['answer']
                                          : true,
                                      'value': _answer.sublist(0),
                                    });
                                  },
                                  onChanged: (value) {
                                    if (_answer.length > i) {
                                      _answer.insert(i, value);
                                      _answer.removeAt(i + 1);
                                    } else if (_answer.length < i) {
                                      for (var j = 0; j < i; j++) {
                                        _answer.add('');
                                      }
                                      _answer.insert(i, value);
                                    } else {
                                      _answer.insert(i, value);
                                    }
                                    if (_answer.length > 0) {
                                      widget.parentAction({
                                        'index': _qId,
                                        'isCorrect': (_question != null &&
                                                _question['options'] != null)
                                            ? _question['options'][i]['answer']
                                            : true,
                                        'value': _answer,
                                      });
                                    }
                                  },
                                  onSubmitted: (value) {
                                    optionFocusNode[i].unfocus();
                                    widget.parentAction({
                                      'index': _qId,
                                      'isCorrect': (_question != null &&
                                              _question['options'] != null)
                                          ? _question['options'][i]['answer']
                                          : true,
                                      'value': _answer,
                                    });
                                  },
                                  enabled: widget.showAnswer ? false : true,
                                  textInputAction: TextInputAction.done,
                                  style: GoogleFonts.lato(fontSize: 14.0),
                                  keyboardType: TextInputType.name,
                                  decoration: InputDecoration(
                                      filled: true,
                                      fillColor: !widget.showAnswer
                                          ? AppColors.appBarBackground
                                          : (_answer.length > i &&
                                                  _answer[i] != null)
                                              ? (_question['options'][i]
                                                              ['value']['body']
                                                          .toString() ==
                                                      _answer[i].toString()
                                                  ? FeedbackColors
                                                      .positiveLightBg
                                                  : FeedbackColors
                                                      .negativeLightBg)
                                              : FeedbackColors.negativeLightBg,
                                      contentPadding: EdgeInsets.fromLTRB(
                                              10.0, 0.0, 10.0, 0.0)
                                          .r,
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppColors.grey16)),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: AppColors.grey16),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColors.darkBlue),
                                      ),
                                      disabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: widget.showAnswer
                                                ? (_answer.length > i &&
                                                        _answer[i] != null)
                                                    ? (_question['options'][i][
                                                                        'value']
                                                                    ['body']
                                                                .toString() ==
                                                            _answer[i]
                                                                .toString()
                                                        ? FeedbackColors
                                                            .positiveLight
                                                        : FeedbackColors
                                                            .negativeLight)
                                                    : FeedbackColors
                                                        .negativeLight
                                                : AppColors.grey16),
                                      ),
                                      helperText: '',
                                      hintStyle: GoogleFonts.lato(
                                          color: AppColors.grey40,
                                          fontSize: 14.0.sp,
                                          fontWeight: FontWeight.w400),
                                      icon: Text(_alphabets[i].toLowerCase())),
                                )),
                            (widget.showAnswer &&
                                    _question['options'][i]['value']['body']
                                            .toString() !=
                                        (_answer.length > i ? _answer[i] : ''))
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 20, left: 24),
                                    child: Row(
                                      // mainAxisAlignment: MainAxisAlignment.s,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!
                                              .mStaticCorrectAnswer,
                                          style: GoogleFonts.lato(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.greys87),
                                        ),
                                        Text(
                                          _question['options'][i]['value']
                                                  ['body']
                                              .toString(),
                                          style: GoogleFonts.lato(
                                              color: AppColors.positiveLight),
                                        ),
                                      ],
                                    ),
                                  )
                                : Center()
                          ],
                        ),
                    ],
                  )
                : Center(),
          ],
        ));
  }

  List<Widget> renderHtmlContent(String html) {
    final document = html_parser.parse(html);
    final widgets = <Widget>[];
    _optionController.clear();
    optionFocusNode.clear();

    addTextInputField() {
      final controller = TextEditingController();
      _optionController.add(controller);
      int currentIndex = _optionController.length - 1;
      final inputFocusNode = FocusNode();
      optionFocusNode.add(inputFocusNode);

      widgets.add(addTextField(controller, currentIndex, inputFocusNode));
    }

    void processNode(dom.Node node, {TextStyle? parentStyle}) {
      if (node is dom.Element) {
        final currentStyle = parentStyle ?? DefaultTextStyle.of(context).style;
        if (node.localName == 'em') {
          final emStyle =
              currentStyle.merge(TextStyle(fontStyle: FontStyle.italic));
          node.nodes.forEach((childNode) {
            processNode(childNode, parentStyle: emStyle);
          });
        } else if (node.localName == 'strong') {
          final strongStyle =
              currentStyle.merge(TextStyle(fontWeight: FontWeight.bold));
          node.nodes.forEach((childNode) {
            processNode(childNode, parentStyle: strongStyle);
          });
        } else if (node.localName == 'input') {
          addTextInputField();
        } else if (node.localName == 'ol' || node.localName == 'ul') {
          // Handle ol tag manually
          node.nodes.forEach((childNode) {
            if (childNode is dom.Element && childNode.localName == 'li') {
              // Handle li tag manually
              childNode.nodes.forEach((grandChildNode) {
                if (grandChildNode is dom.Element &&
                    grandChildNode.localName == 'input') {
                  addTextInputField();
                } else {
                  processNode(grandChildNode, parentStyle: currentStyle);
                }
              });
            }
          });
        } else if (node.nodes.isEmpty || node.nodes.length == 1) {
          widgets.add(HtmlWidget(node.outerHtml));
        } else {
          node.nodes.forEach((childNode) {
            processNode(childNode, parentStyle: currentStyle);
          });
        }
      } else if (node is dom.Text) {
        widgets.add(Text(
          node.text.trim(),
          style: parentStyle,
        ));
      }
    }

    document.body!.nodes.forEach(processNode);
    return widgets;
  }

  TextField addTextField(
      TextEditingController controller, int currentIndex, FocusNode focusNode) {
    return TextField(
      controller: controller,
      // focusNode: optionFocusNode[currentIndex],
      onEditingComplete: () {
        widget.parentAction({
          'index': _qId,
          'isCorrect': (_question != null && _question['options'] != null)
              ? _question['options'][currentIndex]['answer']
              : true,
          'value': _answer.sublist(0),
        });
        true;
      },
      onChanged: (value) {
        if (_answer.length > currentIndex) {
          _answer.insert(currentIndex, value);
          _answer.removeAt(currentIndex + 1);
        } else if (_answer.length < currentIndex) {
          for (var j = 0; j < currentIndex; j++) {
            if (_answer.length < currentIndex || _answer[j] == null) {
              _answer.add(null);
            }
          }
          _answer.insert(currentIndex, value);
        } else {
          _answer.insert(currentIndex, value);
        }
        if (_answer.length > 0) {
          widget.parentAction({
            'index': _qId,
            'isCorrect': (_question != null && _question['options'] != null)
                ? _question['options'][currentIndex]['answer']
                : true,
            'value': _answer,
          });
        }
      },
      onSubmitted: (value) {
        optionFocusNode[currentIndex].unfocus();
        widget.parentAction({
          'index': _qId,
          'isCorrect': (_question != null && _question['options'] != null)
              ? _question['options'][currentIndex]['answer']
              : true,
          'value': _answer,
        });
      },
      enabled: widget.showAnswer ? false : true,
      textInputAction: TextInputAction.done,
      style: GoogleFonts.lato(fontSize: 14.0.sp),
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        filled: true,
        fillColor: !widget.showAnswer
            ? AppColors.appBarBackground
            : (_answer.length > currentIndex && _answer[currentIndex] != null)
                ? (_question['options'][currentIndex]['value']['body']
                            .toString() ==
                        _answer[currentIndex].toString()
                    ? FeedbackColors.positiveLightBg
                    : FeedbackColors.negativeLightBg)
                : FeedbackColors.negativeLightBg,
        contentPadding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
        border:
            OutlineInputBorder(borderSide: BorderSide(color: AppColors.grey16)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.grey16),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.darkBlue),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: widget.showAnswer
                  ? (_answer.length > currentIndex &&
                          _answer[currentIndex] != null)
                      ? (_question['options'][currentIndex]['value']['body']
                                  .toString() ==
                              _answer[currentIndex].toString()
                          ? FeedbackColors.positiveLight
                          : FeedbackColors.negativeLight)
                      : FeedbackColors.negativeLight
                  : AppColors.grey16),
        ),
        helperText: '',
        hintStyle: GoogleFonts.lato(
            color: AppColors.grey40,
            fontSize: 14.0.sp,
            fontWeight: FontWeight.w400),
      ),
    );
  }
}
