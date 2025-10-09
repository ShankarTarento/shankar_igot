import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../constants/index.dart';
import '../../../../util/helper.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

import '../../index.dart';

class FTBDropdown extends StatefulWidget {
  final question;
  final String questionText;
  final int currentIndex;
  final answerGiven;
  final bool showAnswer;
  final ValueChanged<Map> parentAction;
  final String id;
  FTBDropdown(
      {required this.question,
      required this.questionText,
      required this.currentIndex,
      required this.answerGiven,
      required this.showAnswer,
      required this.parentAction,
      required this.id});
  @override
  State<FTBDropdown> createState() => _FTBDropdownState();
}

class _FTBDropdownState extends State<FTBDropdown> {
  List<String> _alphabets =
      List.generate(10, (index) => String.fromCharCode(index + 65));
  late String _questionWithBlank;
  List<dynamic> _answer = [];
  late int _blankCount;
  dynamic _question;
  List<Widget>? contentWidgets;
  int dropdownCount = -1;
  List selectedDropdownValue = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Helper.isHtml(_questionWithBlank)) {
      contentWidgets =
          renderHtmlContent(Helper.decodeHtmlEntities(_questionWithBlank));
    }
  }

  getData() async {
    dropdownCount = -1;
    await _setText();
    if (Helper.isHtml(widget.questionText)) {
      contentWidgets =
          renderHtmlContent(Helper.decodeHtmlEntities(widget.questionText));
    }
  }

  @override
  void didUpdateWidget(FTBDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id == widget.id) {
      if (oldWidget.answerGiven.isNotEmpty && widget.answerGiven.isEmpty) {
        _answer = [];
        getData();
      }
    } else {
      setState(() {
        if (widget.answerGiven.isEmpty) {
          _answer = [];
        }
        getData();
      });
    }
  }

  Future<void> _setText() async {
    String substring = "_______________";
    RegExp regExp = RegExp(substring);
    _blankCount = regExp.allMatches(widget.questionText).length;
    _questionWithBlank = widget.questionText;
    _question = widget.question;
    if (widget.answerGiven != '') {
      _answer = List.from(widget.answerGiven.sublist(0));
    }
    if (!Helper.isHtml(_questionWithBlank)) {
      selectedDropdownValue.clear();
      for (var i = 0;
          i <
              ((_question != null && _question['options'] != null)
                  ? _question['options'].length
                  : _blankCount);
          i++) {
        selectedDropdownValue.add(null);
        _questionWithBlank = _questionWithBlank.replaceFirst(
            "_______________", " ___(${_alphabets[i].toLowerCase()})___");
      }
      for (var i = 0; i < _answer.length; i++) {
        selectedDropdownValue[i] = _answer[i];
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(32).r,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 15).r,
              child: Helper.isHtml(_questionWithBlank)
                  ? Wrap(
                      runSpacing: 16,
                      spacing: 4.0,
                      crossAxisAlignment: WrapCrossAlignment.center,
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
                                child: DropDownListWidget(
                                    key: ValueKey(
                                        '${_questionWithBlank}_$i${Random().nextInt(10000)}'),
                                    options: widget.question['options'],
                                    selectedValue: selectedDropdownValue[i],
                                    changeOption: (value) {
                                      selectedDropdownValue[i] = value;
                                      updateAnswer(value, i);
                                    })),
                            (widget.showAnswer &&
                                    _question['options'][i]['value']['body']
                                            .toString() !=
                                        (_answer.length > i ? _answer[i] : ''))
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 20, left: 24),
                                    child: Row(
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
    selectedDropdownValue.clear();

    void addDropDownToWidget() {
      int currentIndex = initializeDropdown();
      widgets.add(DropDownListWidget(
        key: ValueKey(
            '${html.hashCode}_$currentIndex${Random().nextInt(10000)}'),
        options: widget.question['options'],
        selectedValue: selectedDropdownValue[currentIndex],
        changeOption: (value) {
          selectedDropdownValue[currentIndex] = value;
          updateAnswer(value, currentIndex);
        },
      ));
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
          addDropDownToWidget();
        } else if (node.localName == 'ol' || node.localName == 'ul') {
          node.nodes.forEach((childNode) {
            if (childNode is dom.Element && childNode.localName == 'li') {
              childNode.nodes.forEach((grandChildNode) {
                if (grandChildNode is dom.Element &&
                    grandChildNode.localName == 'input') {
                  addDropDownToWidget();
                } else {
                  processNode(grandChildNode, parentStyle: currentStyle);
                }
              });
            }
          });
        } else if (node.nodes.isEmpty ||
            node.nodes.isEmpty ||
            node.nodes.length == 1) {
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

    document.body!.nodes.forEach((node) {
      processNode(node);
    });

    return widgets;
  }

  updateAnswer(value, currentIndex) {
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
        'index': widget.id,
        'isCorrect': widget.question['options'][currentIndex]['answer'],
        'value': _answer,
      });
    }
  }

  IntrinsicWidth addWidget(Widget widget) {
    return IntrinsicWidth(
        child: Container(
            height: 60.w,
            child: Align(
                alignment: Alignment.centerLeft,
                child: Center(child: widget))));
  }

  int initializeDropdown() {
    dropdownCount++;
    selectedDropdownValue.add(null);
    int currentIndex = selectedDropdownValue.length - 1;
    if (widget.answerGiven != '' && widget.answerGiven.isNotEmpty) {
      _answer = List.from(widget.answerGiven.sublist(0));
      if (_answer.length > currentIndex) {
        selectedDropdownValue[currentIndex] = _answer[currentIndex];
      }
    }
    return currentIndex;
  }
}
