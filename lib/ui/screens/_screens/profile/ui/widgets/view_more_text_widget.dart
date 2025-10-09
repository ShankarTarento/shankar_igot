import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:igot_ui_components/ui/components/view_more_text.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../constants/index.dart';
import '../../../../../../util/index.dart';

class ViewMoreTextWidget extends StatelessWidget {
  final String text;
  final int maxline;

  const ViewMoreTextWidget({super.key, required this.text, this.maxline = 3});
  @override
  Widget build(BuildContext context) {
    final textSpan = TextSpan(
      text: text,
      style: Theme.of(context)
          .textTheme
          .labelLarge!
          .copyWith(color: AppColors.greys60),
    );
    final tp = TextPainter(
      text: textSpan,
      maxLines: maxline,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 1.sw);

    final exceedsMaxLines = tp.didExceedMaxLines;

    return exceedsMaxLines
        ? ViewMoreText(
            text: text,
            viewLessText: Helper.capitalizeFirstLetter(
                AppLocalizations.of(context)!.mStaticViewLess),
            viewMoreText: Helper.capitalizeFirstLetter(
                AppLocalizations.of(context)!.mStaticViewMore),
            maxLines: maxline,
            style: Theme.of(context)
                .textTheme
                .labelLarge!
                .copyWith(color: AppColors.greys60),
            moreLessStyle: Theme.of(context).textTheme.bodySmall!,
          )
        : Text(
            text,
            style: Theme.of(context)
                .textTheme
                .labelLarge!
                .copyWith(color: AppColors.greys60),
          );
  }
}
