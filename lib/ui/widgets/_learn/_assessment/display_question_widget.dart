import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/_assessment/audio_video_webView.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import '../../../../util/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DisplayQuestionWidget extends StatefulWidget {
  final String htmlText;
  final TextStyle? textStyle;

  const DisplayQuestionWidget(
      {super.key, required this.htmlText, this.textStyle});
  @override
  State<DisplayQuestionWidget> createState() => _DisplayQuestionWidgetState();
}

class _DisplayQuestionWidgetState extends State<DisplayQuestionWidget> {
  bool isAudio = false, isVideo = false;

  @override
  void initState() {
    super.initState();
    if (Helper.isHtml(widget.htmlText)) {
      iSAudioOrVideoContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return (isAudio || isVideo)
        ? InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    child: AudioVideoWebView(
                      htmlText: widget.htmlText,
                      isAudio: isAudio,
                      isVideo: isVideo,
                    ),
                  );
                },
              );
            },
            child: Container(
              child: Text(
                isVideo
                    ? AppLocalizations.of(context)!.mStaticClickToSeeVideo
                    : AppLocalizations.of(context)!.mStaticClickToSeeAudio,
                style: TextStyle(
                  color: AppColors.darkBlue,
                  decoration: TextDecoration.underline,
                  fontSize: 14.sp,
                ),
              ),
            ),
          )
        : HtmlWidget(
            Helper.decodeHtmlEntities(widget.htmlText),
            textStyle: widget.textStyle ??
                GoogleFonts.lato(
                    color: AppColors.black87,
                    fontWeight: FontWeight.w400,
                    fontSize: 14.0.sp,
                    height: 1.5),
            customStylesBuilder: (element) {
              if (element.localName == 'strong') {
                return {'font-weight': 'bold'};
              }
              return null;
            },
          );
  }

  bool iSAudioOrVideoContent() {
    final document = html_parser.parse(widget.htmlText);
    bool isAudioOrVideo = false;

    void processNode(dom.Node node) {
      if (node is dom.Element) {
        print(node.localName);
        if (node.localName == 'video') {
          isVideo = true;
          isAudioOrVideo = true;
        } else if (node.localName == 'audio') {
          isAudio = true;
          isAudioOrVideo = true;
        } else {
          for (int i = 0; i < node.nodes.length; i++) {
            if (node.nodes[i] is dom.Element) {
              dom.Element element = node.nodes[i] as dom.Element;
              if (element.localName == 'video') {
                isVideo = true;
                isAudioOrVideo = true;
                break;
              } else if (element.localName == 'audio') {
                isAudio = true;
                isAudioOrVideo = true;
                break;
              } else {
                for (int index = 0; index < element.nodes.length; index++) {
                  processNode(element.nodes[index]);
                }
              }
            }
          }
        }
      }
    }

    document.body!.nodes.forEach(processNode);
    return isAudioOrVideo;
  }
}
