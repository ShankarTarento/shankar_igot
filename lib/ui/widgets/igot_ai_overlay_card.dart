import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';

import '../../constants/index.dart';

class IgotAIOverlayCard extends StatelessWidget {
  final bool isVisible;
  final VoidCallback updateVisiblity;

  const IgotAIOverlayCard(
      {super.key, required this.isVisible, required this.updateVisiblity});
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: Container(
        color: AppColors.greys87.withValues(alpha: 0.8),
        margin: EdgeInsets.only(top: 16, bottom: 32).r,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.network(
                ApiUrl.baseUrl + '/assets/images/sakshamAI/lady-greet.svg',
                height: 110.w,
                placeholderBuilder: (context) => SizedBox.shrink()),
            SizedBox(height: 16.w),
            Text(
              AppLocalizations.of(context)!.mIgotAIExploreMessage,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(color: AppColors.appBarBackground),
            ),
            SizedBox(height: 16.w),
            TextButton(
                onPressed: () {
                  updateVisiblity();
                },
                style: ButtonStyle(
                  backgroundColor:
                      WidgetStatePropertyAll(AppColors.appBarBackground),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                ),
                child: Container(
                  child: Text(
                    AppLocalizations.of(context)!.mStaticOk,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge!,
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
