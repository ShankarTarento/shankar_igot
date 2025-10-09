import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../constants/index.dart';

class FeedbackOverlayCard extends StatelessWidget {
  final bool isVisible;
  final Function(String) submitPressed;
  final VoidCallback cancelPressed;
  final double padding;
  final Color color;
  final Color titleColor;
  final Color borderColor;
  final Color submitBtnColor;
  final Color submitTextColor;
  final Color cancelBtnColor;
  final Color textFieldFillColor;
  final String? title;
  final String? submitText;
  final String? cancelText;
  final String? textFieldHint;
  final double? margin;
  final TextAlign? textAlign;

  const FeedbackOverlayCard({
    super.key,
    required this.isVisible,
    required this.submitPressed,
    required this.cancelPressed,
    this.padding = 0,
    this.color = AppColors.appBarBackground,
    this.titleColor = AppColors.appBarBackground,
    this.borderColor = AppColors.appBarBackground,
    this.submitTextColor = AppColors.greys87,
    this.submitBtnColor = AppColors.appBarBackground,
    this.cancelBtnColor = AppColors.appBarBackground,
    this.textFieldFillColor = AppColors.appBarBackground,
    this.title,
    this.submitText,
    this.cancelText,
    this.textFieldHint,
    this.margin,
    this.textAlign,
  });
  @override
  Widget build(BuildContext context) {
    TextEditingController feedbackController = TextEditingController();
    return Visibility(
      visible: isVisible,
      child: Container(
        color: color,
        margin: EdgeInsets.symmetric(vertical: 16).r,
        padding: EdgeInsets.all(padding).r,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title ?? AppLocalizations.of(context)!.mIgotAIFeedbackIsImportant,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              textAlign: textAlign ?? TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(color: titleColor),
            ),
            SizedBox(height: 16.w),
            Container(
              margin: EdgeInsets.symmetric(horizontal: margin ?? 16).r,
              decoration: BoxDecoration(
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(8).r,
                  color: textFieldFillColor),
              child: TextFormField(
                  controller: feedbackController,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.done,
                  maxLength: 200,
                  maxLines: 5,
                  decoration: InputDecoration(
                      hintText: textFieldHint ??
                          AppLocalizations.of(context)!.mIgotAIEnterFeedback,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0)
                              .r,
                      counter: Offstage(),
                      border: InputBorder.none)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: () {
                      submitPressed(feedbackController.text);
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(submitBtnColor),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16).r,
                      child: Text(
                        submitText ??
                            AppLocalizations.of(context)!.mCommonsubmit,
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .displayLarge!
                            .copyWith(color: submitTextColor),
                      ),
                    )),
                SizedBox(width: 16.w),
                TextButton(
                    onPressed: () {
                      cancelPressed();
                    },
                    style: ButtonStyle(
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                            side: BorderSide(color: cancelBtnColor)),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16).r,
                      child: Text(
                        cancelText ??
                            AppLocalizations.of(context)!.mStaticCancel,
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall!
                            .copyWith(color: cancelBtnColor),
                      ),
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }
}
