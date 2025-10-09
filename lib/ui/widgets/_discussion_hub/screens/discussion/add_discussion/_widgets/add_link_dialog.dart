import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';

class AddLinkDialog extends StatefulWidget {
  final String title;
  final String hintText;
  final String errorMessage;
  final String primaryButtonText;
  final Function(String) onPrimaryButtonPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryButtonPressed;

  AddLinkDialog({
    required this.title,
    required this.hintText,
    required this.errorMessage,
    required this.primaryButtonText,
    required this.onPrimaryButtonPressed,
    this.secondaryButtonText,
    this.onSecondaryButtonPressed,
  });

  @override
  State<AddLinkDialog> createState() => AddLinkDialogState();
}

class AddLinkDialogState extends State<AddLinkDialog> {
  final TextEditingController linkController = TextEditingController();
  ValueNotifier<String> _errorMessage = ValueNotifier('');

  bool isValidUrl(String url) {
    final Uri? uri = Uri.tryParse(url);
    return uri != null &&
        (uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https'));
  }

  @override
  void dispose() {
    super.dispose();
    linkController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8).r,
            child: Text(
              widget.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                color: AppColors.greys60,
                fontSize: 16.0.sp,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.25,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          TextFormField(
            textCapitalization: TextCapitalization.none,
            textInputAction: TextInputAction.next,
            controller: linkController,
            style: GoogleFonts.lato(fontSize: 14.0.sp),
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0).r,
              border: OutlineInputBorder(),
              hintText: widget.hintText,
              hintStyle: Theme.of(context).textTheme.labelLarge,
              focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: AppColors.primaryThree, width: 1.0),
              ),
            ),
          ),
          ValueListenableBuilder(
              valueListenable: _errorMessage,
              builder:
                  (BuildContext context, String errorMessage, Widget? child) {
                return errorMessage.isNotEmpty
                    ? Container(
                        width: double.maxFinite,
                        padding: EdgeInsets.only(top: 8.0, bottom: 8.0).w,
                        child: Text(
                          errorMessage,
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: AppColors.negativeLight,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12.0.sp,
                                  ),
                        ))
                    : Container();
              })
        ],
      ),
      actions: <Widget>[
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8).w,
            child: Row(
              children: [
                if (widget.secondaryButtonText != null &&
                    widget.onSecondaryButtonPressed != null)
                  GestureDetector(
                      onTap: widget.onSecondaryButtonPressed,
                      child: Container(
                          width: 0.27.sw,
                          alignment: Alignment.center,
                          padding:
                              EdgeInsets.symmetric(vertical: 12, horizontal: 4)
                                  .w,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primaryBlue),
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.w)),
                          ),
                          child: Text(
                            widget.secondaryButtonText!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12.sp,
                                ),
                          ))),
                Spacer(),
                GestureDetector(
                    onTap: () {
                      String linkText = linkController.text;
                      if (isValidUrl(linkText)) {
                        _errorMessage.value = '';
                        widget.onPrimaryButtonPressed(linkText);
                      } else {
                        _errorMessage.value = widget.errorMessage;
                      }
                    },
                    child: Container(
                        margin: EdgeInsets.only(left: 8),
                        width: 0.27.sw,
                        alignment: Alignment.center,
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 4).w,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          border: Border.all(color: AppColors.primaryBlue),
                          borderRadius: BorderRadius.all(Radius.circular(12.w)),
                        ),
                        child: Text(
                          widget.primaryButtonText,
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: AppColors.appBarBackground,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12.sp,
                                  ),
                        ))),
              ],
            ),
          ),
        )
      ],
    );
  }
}
