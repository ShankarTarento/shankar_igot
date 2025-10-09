import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:google_fonts/google_fonts.dart';

class SummaryWidget extends StatefulWidget {
  final String title;
  final String details;

  const SummaryWidget({
    Key? key,
    required this.title,
    required this.details,
  }) : super(key: key);

  @override
  State<SummaryWidget> createState() => _SummaryWidgetState();
}

class _SummaryWidgetState extends State<SummaryWidget> {
  bool isExpanded = false;
  int _maxLength = 150;

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
        SizedBox(
          height: 8.w,
        ),
        Text(
          widget.details,
          maxLines: isExpanded ? null : 3,
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.w400,
                fontSize: 16.sp,
                height: 1.5.w,
              ),
        ),
        widget.details.length > _maxLength
            ? GestureDetector(
                onTap: () {
                  isExpanded = isExpanded ? false : true;
                  setState(() {});
                },
                child: Text(
                  isExpanded
                      ? AppLocalizations.of(context)!.mStaticViewLess
                      : "...${AppLocalizations.of(context)!.mStaticViewMore}",
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        height: 1.5.w,
                      ),
                ),
              )
            : SizedBox(),
      ],
    );
  }
}
