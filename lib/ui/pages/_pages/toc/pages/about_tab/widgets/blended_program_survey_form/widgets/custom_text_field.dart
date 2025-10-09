import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/field_name_widget.dart';

class CustomTextField extends StatefulWidget {
  final String title;
  final TextEditingController controller;
  final TextInputType inputType;
  final String? Function(String?)? validator;
  final bool isMandatory;
  final bool isTextArea;
  final bool showNA;
  final int? maxLength;

  CustomTextField({
    required this.isMandatory,
    required this.title,
    this.maxLength,
    required this.controller,
    this.isTextArea = false,
    required this.inputType,
    this.showNA = false,
    this.validator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool enableNA = false;
  String? errorMessage;

  String? _validateField(String value) {
    if (widget.isMandatory || widget.controller.text.isNotEmpty) {
      if (enableNA) {
        return null;
      }
      return widget.validator?.call(value);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldNameWidget(
            isMandatory: widget.isMandatory, fieldName: widget.title),
        SizedBox(
          height: 8.w,
        ),
        SizedBox(
          child: TextFormField(
            controller: widget.controller,
            keyboardType: widget.inputType,
            maxLines: null,
            enabled: true,
            maxLength: widget.maxLength,
            decoration: InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0).r,
              filled: true,
              fillColor: AppColors.appBarBackground,
              border: OutlineInputBorder(
                  borderSide: BorderSide(width: 1, color: AppColors.grey16)),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 1, color: AppColors.grey16)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                width: 1,
                color: AppColors.darkBlue,
              )),
              errorText: errorMessage,
            ),
            style: GoogleFonts.lato(fontSize: 14.sp),
            onChanged: (value) => setState(() {
              errorMessage = _validateField(value);

              if (enableNA) {
                enableNA = !enableNA;
              }
            }),
          ),
        ),
        widget.showNA
            ? Column(
                children: [
                  SizedBox(
                    height: 12.w,
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        enableNA = !enableNA;
                        widget.controller.clear();
                      });
                    },
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: Container(
                      height: 20.w,
                      child: Row(
                        children: [
                          Radio(
                            value: true,
                            toggleable: true,
                            groupValue: enableNA,
                            onChanged: (bool? value) {
                              setState(() {
                                enableNA = !enableNA;
                                widget.controller.clear();
                              });
                            },
                            fillColor: WidgetStateProperty.resolveWith<Color>(
                              (Set<WidgetState> states) {
                                if (states.contains(WidgetState.selected)) {
                                  return AppColors.darkBlue;
                                }
                                return AppColors.black40;
                              },
                            ),
                          ),
                          Text(
                            "N/A",
                            style: GoogleFonts.lato(
                              fontSize: 14.0.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.greys60,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              )
            : SizedBox(),
      ],
    );
  }
}
