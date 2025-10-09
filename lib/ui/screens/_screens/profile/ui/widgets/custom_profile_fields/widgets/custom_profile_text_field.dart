import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/custom_profile_fields/models/custom_profile_field_model.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../../../constants/index.dart';

class CustomProfileTextField extends StatefulWidget {
  final CustomField customField;
  final ValueChanged<String>? onChanged;
  final TextEditingController controller;

  const CustomProfileTextField({
    super.key,
    required this.customField,
    required this.controller,
    this.onChanged,
  });

  @override
  State<CustomProfileTextField> createState() => _CustomProfileTextFieldState();
}

class _CustomProfileTextFieldState extends State<CustomProfileTextField> {
  String? _errorText;

  String? _validate(String? value) {
    final field = widget.customField;
    if (field.isMandatory && (value == null || value.trim().isEmpty)) {
      return '${field.name} ${AppLocalizations.of(context)!.mIsRequired}';
    }
    if (field.validation != null && value != null && value.isNotEmpty) {
      final regExp = RegExp(field.validation!);
      if (!regExp.hasMatch(value)) {
        return AppLocalizations.of(context)!.mInvalidValue;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final field = widget.customField;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10.w),
        Row(
          children: [
            Text(
              Helper.capitalize(field.name),
              style: GoogleFonts.lato(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.greys),
            ),
            if (field.isMandatory)
              Text(
                '*',
                style: GoogleFonts.lato(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.mandatoryRed,
                ),
              ),
          ],
        ),
        SizedBox(height: 10.w),
        TextFormField(
          controller: widget.controller,
          enabled: field.isEnabled,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(16.0, 10.0, 0.0, 10.0).r,
            border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(50))),
            errorText: _errorText,
            hintText: field.description,
          ),
          onChanged: (value) {
            setState(() {
              _errorText = _validate(value);
            });
            if (widget.onChanged != null) {
              widget.onChanged!(value);
            }
          },
          validator: _validate,
        ),
      ],
    );
  }
}
