import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../../constants/_constants/color_constants.dart';
import '../../../../../../../models/index.dart';

class DescriptionWidget extends StatefulWidget {
  final String title;
  final String details;
  final Course course;
  const DescriptionWidget({
    Key? key,
    required this.title,
    required this.course,
    required this.details,
  }) : super(
          key: key,
        );

  @override
  State<DescriptionWidget> createState() => _DescriptionWidgetState();
}

class _DescriptionWidgetState extends State<DescriptionWidget> {
  bool isExpanded = false;
  int _maxLength = 130;
  bool descriptionTrimText = true;
  String? description;
  @override
  void initState() {
    description = html_parser.parse(widget.course.instructions).body!.text;
    super.initState();
  }

  @override
  void didUpdateWidget(DescriptionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.course.id != widget.course.id) {
      description = html_parser.parse(widget.course.instructions).body!.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: GoogleFonts.lato(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10).r,
            child: HtmlWidget(
              (descriptionTrimText && description!.length > _maxLength)
                  ? description!.substring(0, _maxLength - 1) + '...'
                  : widget.course.instructions,
              textStyle: GoogleFonts.lato(
                fontSize: 16.sp,
                height: 1.5.w,
                fontWeight: FontWeight.w400,
                color: AppColors.greys60,
              ),
            )),
        (widget.course.instructions.length > _maxLength)
            ? Padding(
                padding: const EdgeInsets.only(top: 0).r,
                child: InkWell(
                  onTap: () => _toogleReadMore(),
                  child: Text(
                    !descriptionTrimText
                        ? AppLocalizations.of(context)!.mStaticViewLess
                        : "...${AppLocalizations.of(context)!.mStaticViewMore}",
                    style: GoogleFonts.lato(
                      fontSize: 16.sp,
                      height: 1.0.w,
                      fontWeight: FontWeight.w900,
                      color: AppColors.darkBlue,
                    ),
                  ),
                ),
              )
            : Center()
      ],
    );
  }

  void _toogleReadMore() {
    setState(() {
      descriptionTrimText = !descriptionTrimText;
    });
  }
}
