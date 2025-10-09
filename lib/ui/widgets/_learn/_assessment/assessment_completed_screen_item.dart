import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/_assessment/html_webview_widget.dart';
import '../../../../util/helper.dart';
import './../../../../feedback/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

class AssessmentCompletedScreenItem extends StatefulWidget {
  const AssessmentCompletedScreenItem({
    Key? key,
    required this.itemIndex,
    required this.apiResponse,
    required this.color,
    required this.type,
    required this.title,
  }) : super(key: key);

  final int itemIndex;
  final Map apiResponse;
  final Color color;
  final String type;
  final String title;

  @override
  State<AssessmentCompletedScreenItem> createState() =>
      _AssessmentCompletedScreenItemState();
}

class _AssessmentCompletedScreenItemState
    extends State<AssessmentCompletedScreenItem> {
  bool expanded = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.zero.r,
      decoration: BoxDecoration(
          color: expanded
              ? widget.color.withValues(alpha: 0.05)
              : AppColors.appBarBackground,
          border: Border(
            top: BorderSide(color: AppColors.grey04),
            bottom: BorderSide(color: AppColors.grey04),
            left: expanded
                ? BorderSide(color: widget.color, width: 4)
                : BorderSide(color: AppColors.appBarBackground, width: 0),
          )),
      child: ExpansionTile(
        title: Row(
          children: [
            if (widget.type.toString() == 'correct')
              Icon(Icons.done, size: 20.sp, color: AppColors.primaryBlue),
            if (widget.type.toString() == 'incorrect')
              SvgPicture.asset(
                'assets/img/close_black.svg',
                colorFilter:
                    ColorFilter.mode(AppColors.primaryBlue, BlendMode.srcIn),
              ),
            if (widget.type.toString() == 'blank')
              SvgPicture.asset(
                'assets/img/unanswered.svg',
                colorFilter:
                    ColorFilter.mode(AppColors.primaryBlue, BlendMode.srcIn),
              ),
            Padding(
              padding: const EdgeInsets.only(left: 8).r,
              child: Text(widget.title,
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
          ],
        ),
        onExpansionChanged: (value) {
          setState(() {
            expanded = value;
          });
        },
        trailing: Icon(
          expanded ? Icons.remove : Icons.add,
          color: AppColors.darkBlue,
          size: 20.sp,
        ),
        children: [
          for (var k = 0;
              k <
                  (widget.apiResponse['children'][widget.itemIndex]
                              ['children'] !=
                          null
                      ? widget
                          .apiResponse['children'][widget.itemIndex]['children']
                          .length
                      : 0);
              k++)
            widget.apiResponse['children'][widget.itemIndex]['children'][k]
                        ['result'] ==
                    widget.type
                ? QuestionItem(
                    question: widget.apiResponse['children'][widget.itemIndex]
                        ['children'][k]['question'],
                    questionIndex: k + 1,
                  )
                : Container()
        ],
      ),
    );
  }
}

class QuestionItem extends StatefulWidget {
  const QuestionItem({
    Key? key,
    required this.question,
    required this.questionIndex,
  }) : super(key: key);

  final int questionIndex;
  final String question;

  @override
  State<QuestionItem> createState() => _QuestionItemState();
}

class _QuestionItemState extends State<QuestionItem> {
  bool expanded = true;
  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity.w,
        margin: const EdgeInsets.only(left: 4, right: 4, bottom: 2).r,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExpansionTile(
              expandedAlignment: Alignment.centerLeft,
              onExpansionChanged: (value) {
                setState(() {
                  expanded = !value;
                });
              },
              trailing: Icon(
                expanded ? Icons.add : Icons.remove,
                color: AppColors.darkBlue,
                size: 20.sp,
              ),
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: RegExpressions.inputTagRegExp
                          .hasMatch(Helper.decodeHtmlEntities(widget.question))
                      ? Wrap(
                          children: renderHtmlContent(
                              Helper.decodeHtmlEntities(widget.question)),
                        )
                      : HtmlWebviewWidget(
                          htmlText: widget.question,
                          textStyle: GoogleFonts.lato(
                              color: FeedbackColors.black87,
                              fontWeight: FontWeight.w400,
                              fontSize: 14.0.sp,
                              height: 1.5)),
                )
              ],
              title: Text(
                '${AppLocalizations.of(context)!.mStaticQuestion} ${widget.questionIndex}',
                style: GoogleFonts.lato(
                    decoration: TextDecoration.none,
                    color: AppColors.greys87,
                    fontSize: 12,
                    fontWeight: FontWeight.w400),
              ),
            ),
          ],
        ));
  }

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
