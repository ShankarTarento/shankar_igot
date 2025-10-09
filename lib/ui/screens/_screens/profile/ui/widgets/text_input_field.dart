import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';

class TextInputField extends StatelessWidget {
  final String? Function(String?)? validatorFuntion;
  final FocusNode? focusNode;
  final Function()? onTap;
  final void Function(String)? onFieldSubmitted;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? hintText;
  final bool readOnly;
  final bool isDate;
  final int? maxLength;
  final Widget? suffix;
  final Widget? suffixIcon;
  final int? minLines;
  final int? maxLines;
  final String? counterText;
  final String? initialValue;
  final Function(String)? onChanged;
  final double? enabledBorderRadius;
  final TextStyle? textStyle;

  const TextInputField(
      {Key? key,
      this.validatorFuntion,
      this.focusNode,
      this.onFieldSubmitted,
      required this.controller,
      required this.keyboardType,
      this.hintText,
      this.onTap,
      this.readOnly = false,
      this.isDate = false,
      this.maxLength,
      this.suffix,
      this.minLines,
      this.maxLines,
      this.counterText,
      this.onChanged,
      this.initialValue,
      this.suffixIcon,
      this.enabledBorderRadius,
      this.textStyle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8).r,
      child: TextFormField(
        maxLength: maxLength,
        initialValue: initialValue,
        textInputAction: TextInputAction.next,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: validatorFuntion,
        focusNode: focusNode,
        onTap: onTap,
        onFieldSubmitted: onFieldSubmitted,
        controller: controller,
        style:
            textStyle != null ? textStyle : GoogleFonts.lato(fontSize: 14.0.sp),
        keyboardType: keyboardType,
        readOnly: readOnly,
        maxLines: maxLength,
        minLines: minLines,
        onChanged: onChanged,
        decoration: InputDecoration(
          filled: true,
          fillColor: (readOnly && !isDate)
              ? AppColors.grey04
              : AppColors.appBarBackground,
          contentPadding: EdgeInsets.fromLTRB(16.0, 10.0, 0.0, 10.0).r,
          border: const OutlineInputBorder(),
          disabledBorder: const OutlineInputBorder(borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
              borderRadius: enabledBorderRadius != null
                  ? BorderRadius.circular(enabledBorderRadius!).r
                  : BorderRadius.zero,
              borderSide: BorderSide(color: AppColors.grey16)),
          hintText: hintText,
          hintStyle:
              GoogleFonts.lato(fontSize: 14.sp, fontWeight: FontWeight.w400),
          focusedBorder: OutlineInputBorder(
            borderRadius: enabledBorderRadius != null
                ? BorderRadius.circular(enabledBorderRadius!).r
                : BorderRadius.zero,
            borderSide: BorderSide(
                color: (readOnly && !isDate)
                    ? AppColors.grey16
                    : AppColors.darkBlue,
                width: 1.0.w),
          ),
          suffix: suffix != null ? suffix : SizedBox(),
          suffixIcon: suffixIcon != null ? suffixIcon : SizedBox(),
          counterText: counterText,
        ),
      ),
    );
  }
}
