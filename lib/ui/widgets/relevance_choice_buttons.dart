import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../constants/index.dart';

class RelevanceChoiceButtons extends StatelessWidget {
  final VoidCallback onReleventBtnPressed;
  final VoidCallback onNonReleventBtnPressed;

  const RelevanceChoiceButtons(
      {super.key,
      required this.onReleventBtnPressed,
      required this.onNonReleventBtnPressed});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: InkWell(
            onTap: () => onReleventBtnPressed(),
            child: Row(children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16).r,
                child: SvgPicture.network(
                  ApiUrl.baseUrl + '/assets/images/sakshamAI/ai-icon.svg',
                  placeholderBuilder: (context) => Container(),
                  height: 20.sp,
                  width: 20.sp,
                ),
              ),
              Flexible(
                child: Text(
                  AppLocalizations.of(context)!.mCommonRelevant,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              )
            ]),
          ),
        ),
        InkWell(
          onTap: () => onNonReleventBtnPressed(),
          child: Row(children: [
            Icon(
              Icons.thumb_down,
              color: AppColors.primaryBlue,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              AppLocalizations.of(context)!.mStaticNo,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall,
            )
          ]),
        )
      ],
    );
  }
}
