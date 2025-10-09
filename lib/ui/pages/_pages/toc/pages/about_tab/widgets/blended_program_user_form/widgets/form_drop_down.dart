import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FormDropDown<T> extends StatefulWidget {
  final List<T> options;
  final T? selectedValue;
  final Function(T?) onChanged;
  final FormFieldValidator<String>? validator;

  FormDropDown({
    Key? key,
    required this.options,
    this.selectedValue,
    required this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  State<FormDropDown<T>> createState() => _FormDropDownState<T>();
}

class _FormDropDownState<T> extends State<FormDropDown<T>> {
  final TextEditingController _controller = TextEditingController();
  bool _isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.selectedValue?.toString() ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    setState(() {
      _isDropdownOpen = !_isDropdownOpen;
    });
    if (_isDropdownOpen) {
      FocusScope.of(context).unfocus();
    }
  }

  void _onOptionSelected(T value) {
    setState(() {
      widget.onChanged(value);
      _controller.text = value.toString();
      _isDropdownOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8.w),
        TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onTap: _toggleDropdown,
          readOnly: true,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(left: 12).r,
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.darkBlue),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.mandatoryRed),
            ),
            suffixIcon: Icon(Icons.keyboard_arrow_down),
            hintText: AppLocalizations.of(context)!.mStaticSelectHere,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.grey16),
            ),
          ),
          controller: _controller,
          validator: (value) {
            return widget.validator?.call(value);
          },
        ),
        if (_isDropdownOpen)
          Container(
            padding: EdgeInsets.all(8).r,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey08),
              color: AppColors.appBarBackground,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: AppColors.greys.withValues(alpha: 0.1),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: widget.options.map((option) {
                return ListTile(
                  title: Text(
                    option.toString(),
                    style: GoogleFonts.lato(
                        fontWeight: FontWeight.w500,
                        fontSize: 14.sp,
                        color: option == _controller.text
                            ? AppColors.darkBlue
                            : AppColors.greys),
                  ),
                  onTap: () => _onOptionSelected(option),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
