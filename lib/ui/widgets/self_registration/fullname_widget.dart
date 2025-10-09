import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';

import '../../../constants/index.dart';

class FullnameWidget extends StatefulWidget {
  final ValueChanged<String?>? onSaved;
  final ValueChanged<String>? changeFocus;
  final GlobalKey<FormState> formKey;

  const FullnameWidget(
      {super.key, this.onSaved, required this.formKey, this.changeFocus});

  @override
  State<FullnameWidget> createState() => _FullnameWidgetState();
}

class _FullnameWidgetState extends State<FullnameWidget> {
  final TextEditingController _fullNameController = TextEditingController();
  final FocusNode _fullNameFocus = FocusNode();

  @override
  void dispose() {
    _fullNameController.dispose();
    _fullNameFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
              text: AppLocalizations.of(context)!.mRegisterfullName,
              style: Theme.of(context).textTheme.displayLarge,
              children: [
                TextSpan(
                    text: ' *',
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge!
                        .copyWith(color: AppColors.negativeLight))
              ]),
        ),
        Container(
          padding: EdgeInsets.only(top: 8).r,
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4).r,
          ),
          child: Focus(
            child: TextFormField(
              key: Key('fullNameField'),
              autofocus: true,
              textInputAction: TextInputAction.next,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (String? value) {
                if (value != null) {
                  if (value.isEmpty) {
                    return AppLocalizations.of(context)!
                        .mRegisterfullNameMandatory;
                  } else if (!RegExpressions.alphabetsWithDot.hasMatch(value)) {
                    return AppLocalizations.of(context)!
                        .mRegisterfullNameWitoutSp;
                  } else
                    return null;
                } else {
                  return null;
                }
              },
              focusNode: _fullNameFocus,
              maxLength: 100,
              controller: _fullNameController,
              onSaved: (String? value) {
                if (widget.onSaved != null) {
                  widget.onSaved!(value);
                }
              },
              onChanged: (value) {
                if (widget.onSaved != null) {
                  widget.onSaved!(value);
                }
              },
              onFieldSubmitted: (value) {
                if (value.isEmpty && !widget.formKey.currentState!.validate()) {
                  return;
                }
                if (widget.changeFocus != null) {
                  _fullNameFocus.unfocus();
                  widget.changeFocus!(EnglishLang.email);
                }
              },
              style: Theme.of(context).textTheme.bodyMedium,
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                errorMaxLines: 3,
                filled: true,
                errorStyle: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: AppColors.negativeLight),
                fillColor: AppColors.appBarBackground,
                contentPadding: EdgeInsets.fromLTRB(16.0, 14.0, 0.0, 14.0),
                border: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: AppColors.grey16, width: 1.0)),
                hintText:
                    AppLocalizations.of(context)!.mRegisterenterYourFullName,
                hintStyle: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: AppColors.grey40),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: AppColors.darkBlue, width: 1.0),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 24.w,
        )
      ],
    );
  }
}
