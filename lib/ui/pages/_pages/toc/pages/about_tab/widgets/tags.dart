import 'package:extended_wrap/extended_wrap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:google_fonts/google_fonts.dart';

import '../../../../../../../constants/_constants/color_constants.dart';

class Tags extends StatefulWidget {
  final List<dynamic> keywords;
  final String title;
  const Tags({Key? key, required this.keywords, required this.title})
      : super(key: key);

  @override
  State<Tags> createState() => _TagsState();
}

class _TagsState extends State<Tags> {
  bool isExpanded = false;
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
          height: 15.w,
        ),
        widget.keywords.isNotEmpty
            ? ExtendedWrap(
                minLines: 1,
                maxLines: isExpanded ? 10 : 1,
                overflowWidget: GestureDetector(
                  onTap: () {
                    isExpanded = isExpanded ? false : true;
                    setState(() {});
                  },
                  child: Text(
                    isExpanded
                        ? AppLocalizations.of(context)!.mStaticViewLess
                        : AppLocalizations.of(context)!.mStaticViewMore,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontSize: 12.sp,
                          height: 1.3.w,
                          decoration: TextDecoration.underline,
                          decorationThickness: 1.0.w,
                        ),
                  ),
                ),
                runSpacing: 8,
                spacing: 0,
                alignment: WrapAlignment.start,
                children: widget.keywords
                    .map(
                      (e) => Container(
                        padding: EdgeInsets.all(1).r,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              e,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(7.0).r,
                              child: widget.keywords.indexOf(e) !=
                                      widget.keywords.length - 1
                                  ? CircleAvatar(
                                      backgroundColor: AppColors.grey40,
                                      radius: 1.r,
                                    )
                                  : SizedBox(),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              )
            : Text(
                AppLocalizations.of(context)!.mProfileNoTags,
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.w400,
                      height: 1.5.w,
                    ),
              )
      ],
    );
  }
}
