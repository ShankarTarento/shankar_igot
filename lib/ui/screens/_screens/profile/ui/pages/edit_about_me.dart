import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/edit_page_appbar.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/view_model/profile_other_details_view_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_common/button_widget_v2.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/field_name_widget.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/text_input_field.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../constants/index.dart';

class EditAboutMe extends StatefulWidget {
  final String? aboutMe;
  final VoidCallback updateBasicProfile;
  const EditAboutMe({Key? key, this.aboutMe, required this.updateBasicProfile})
      : super(key: key);

  @override
  State<EditAboutMe> createState() => EditAboutMeState();
}

class EditAboutMeState extends State<EditAboutMe> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _aboutController = TextEditingController();
  final FocusNode _aboutFocus = FocusNode();
  String _errorMessage = '';
  ValueNotifier<bool> _savePressed = ValueNotifier(false);
  ValueNotifier<bool> _isChanged = ValueNotifier(false);
  ValueNotifier<String?> aboutError = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _populateFields();
  }

  @override
  void dispose() {
    _aboutController.dispose();
    _aboutFocus.dispose();
    aboutError.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBarBackground,
      appBar: EditPageAppbar(
        title: AppLocalizations.of(context)!.mProfileAboutMe,
      ),
      body: _buildLayout(),
      bottomSheet: _bottomView(),
      resizeToAvoidBottomInset: false,
    );
  }

  Widget _buildLayout() {
    return SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16).r,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FieldNameWidget(
                    fieldName:
                        AppLocalizations.of(context)!.mProfileAboutHelperText,
                    fieldTheme: Theme.of(context)
                        .textTheme
                        .headlineMedium!
                        .copyWith(color: AppColors.blackLegend)),
                TextInputField(
                  maxLength: 2000,
                  minLines: 15,
                  focusNode: _aboutFocus,
                  keyboardType: TextInputType.text,
                  controller: _aboutController,
                  hintText: AppLocalizations.of(context)!.mStaticTypeHere,
                  enabledBorderRadius: 4.r,
                  textStyle: Theme.of(context)
                      .textTheme
                      .labelLarge!
                      .copyWith(color: AppColors.greys),
                  onChanged: (value) {
                    if (!(RegExpressions.alphaNumWithDotCommaBracketHyphen
                        .hasMatch(value))) {
                      aboutError.value = AppLocalizations.of(context)!
                          .mProfileSpecialCharacterNotApplowed;
                      _isChanged.value = false;
                    } else {
                      aboutError.value = null;
                      _checkForChanges();
                    }
                  },
                  validatorFuntion: (String? value) {
                    final textValue = value?.trim() ?? '';
                    if (textValue.isEmpty) return null;
                    if (textValue.length > 2000) {
                      return AppLocalizations.of(context)!
                          .mProfileAboutMaxLengthText;
                    }
                    return null;
                  },
                  onFieldSubmitted: (String value) {
                    _aboutFocus.unfocus();
                  },
                ),
                ValueListenableBuilder(
                    valueListenable: aboutError,
                    builder: (context, errMsg, _) {
                      return Visibility(
                        visible: errMsg != null,
                        child: Text(errMsg ?? '',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(color: AppColors.negativeLight)),
                      );
                    }),
                SizedBox(
                  height: 96.w,
                ),
              ],
            ),
          ),
        ));
  }

  Widget _bottomView() {
    return Container(
      height: 80.w,
      width: 1.sw,
      padding: EdgeInsets.fromLTRB(16, 16, 16, 24).r,
      color: AppColors.appBarBackground,
      child: Align(
          alignment: Alignment.center,
          child: ValueListenableBuilder(
              valueListenable: _savePressed,
              builder: (BuildContext context, bool savePressed, Widget? child) {
                return ValueListenableBuilder(
                    valueListenable: _isChanged,
                    builder:
                        (BuildContext context, bool isChanged, Widget? child) {
                      return ButtonWidgetV2(
                        text: AppLocalizations.of(context)!.mProfileSaveChanges,
                        textColor: AppColors.appBarBackground,
                        isLoading: savePressed,
                        bgColor:
                            isChanged ? AppColors.darkBlue : AppColors.grey40,
                        onTap: isChanged && !savePressed
                            ? () => _saveProfile()
                            : null,
                      );
                    });
              })),
    );
  }

  void _populateFields() async {
    if ((widget.aboutMe ?? '').isNotEmpty) {
      _aboutController.text = widget.aboutMe ?? '';
    }
  }

  Future<void> _saveProfile() async {
    FocusScope.of(context).unfocus();
    _errorMessage = AppLocalizations.of(context)!.mProfileProvideValidDetails;
    if (_formKey.currentState!.validate()) {
      try {
        _savePressed.value = true;
        await ProfileOtherDetailsViewModel.saveAboutDetails(
            context: context,
            aboutMe: _aboutController.text,
            callback: () {
              if ((_aboutController.text.isEmpty &&
                      widget.aboutMe != null &&
                      widget.aboutMe!.isNotEmpty) ||
                  ((widget.aboutMe == null || widget.aboutMe!.isEmpty) &&
                      _aboutController.text.isNotEmpty)) {
                widget.updateBasicProfile();
              }
              Navigator.pop(context);
            });
        _savePressed.value = false;
      } catch (e) {
        _savePressed.value = false;
        print(e);
      }
    } else {
      Helper.showSnackBarMessage(
          context: context, text: _errorMessage, bgColor: AppColors.greys87);
    }
  }

  _checkForChanges() {
    _isChanged.value = false;
    if ((_aboutController.text != (widget.aboutMe ?? '') &&
        _aboutController.text.isNotEmpty)) {
      _isChanged.value = true;
    }
    return _isChanged.value;
  }
}
