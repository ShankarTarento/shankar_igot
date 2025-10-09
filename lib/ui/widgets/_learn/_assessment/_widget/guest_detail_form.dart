import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/respositories/index.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/field_name_widget.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/text_input_field.dart';
import 'package:karmayogi_mobile/ui/widgets/_common/button_widget_v2.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/_assessment/_models/guest_data_model.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:karmayogi_mobile/util/validations.dart';

class GuestDetailForm extends StatefulWidget {
  final Function(GuestDataModel) submitCallback;
  final Function closeCallback;

  const GuestDetailForm(
      {super.key, required this.submitCallback, required this.closeCallback});

  @override
  _GuestDetailFormState createState() => _GuestDetailFormState();
}

class _GuestDetailFormState extends State<GuestDetailForm> {
  final ProfileRepository profileRepository = ProfileRepository();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  ValueNotifier<bool> _savePressed = ValueNotifier(false);
  ValueNotifier<bool> _isChanged = ValueNotifier(false);
  String _errorMessage = '';

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.mRegisterEmailMandatory;
    }
    if (!RegExpressions.validEmail.hasMatch(value)) {
      return AppLocalizations.of(context)!.mRegistervalidEmail;
    }
    return null;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pop(context);
          widget.closeCallback();
        }
      },
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(
                    top: 56,
                    bottom:
                        (MediaQuery.of(context).viewInsets.bottom > 0) ? 2 : 56,
                    left: 8,
                    right: 8)
                .w,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12).r,
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: AppColors.grey16),
                    borderRadius:
                        BorderRadius.all(const Radius.circular(12.0).r),
                    color: AppColors.appBarBackground),
                child: _buildLayout(),
              ),
            ),
          ),
          _appbarView(),
        ],
      ),
    );
  }

  Widget _buildLayout() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          _formLayout(), // Your main content
          Positioned(
            bottom: 0, // Adjust position
            left: 0,
            right: 0,
            child: _bottomView(), // Your bottom view
          ),
        ],
      ),
    );
  }

  Widget _appbarView() {
    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 8).r,
      child: Align(
          alignment: Alignment.topRight,
          child: InkWell(
            onTap: () async {
              Navigator.of(context).pop();
              widget.closeCallback();
            },
            child: Container(
              alignment: Alignment.center,
              height: 36.w,
              width: 36.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.grey40,
              ),
              child: Icon(
                Icons.close,
                color: AppColors.whiteGradientOne,
                size: 16.sp,
              ),
            ),
          )),
    );
  }

  Widget _formLayout() {
    return Container(
      height: 1.sh,
      margin: EdgeInsets.only(top: 16).r,
      decoration: BoxDecoration(color: AppColors.appBarBackground),
      child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16).r,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 16, top: 16, bottom: 16).r,
                    child: Text(
                      AppLocalizations.of(context)!.mStaticFillUpTheDetails,
                      style:
                          Theme.of(context).textTheme.headlineSmall!.copyWith(
                                color: AppColors.greys60,
                                fontWeight: FontWeight.w600,
                                fontSize: 16.sp,
                              ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  FieldNameWidget(
                    fieldName:
                        AppLocalizations.of(context)!.mEditProfileFullName,
                    isMandatory: true,
                  ),
                  TextInputField(
                      focusNode: _nameFocus,
                      keyboardType: TextInputType.text,
                      controller: _nameController,
                      hintText: AppLocalizations.of(context)!
                          .mEditProfileEnterYourFullname,
                      onChanged: (p0) => _checkForChanges(),
                      validatorFuntion: (String? value) {
                        return Validations.validateFullName(
                            context: context, value: value ?? '');
                      },
                      onFieldSubmitted: (String value) {
                        _nameFocus.unfocus();
                      }),
                  SizedBox(height: 8),
                  FieldNameWidget(
                    fieldName: AppLocalizations.of(context)!.mContactEmail,
                    isMandatory: true,
                  ),
                  TextInputField(
                      focusNode: _emailFocus,
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                      hintText: AppLocalizations.of(context)!
                          .mRegisterenterYourEmailAddress,
                      onChanged: (p0) => _checkForChanges(),
                      validatorFuntion: (String? value) {
                        return _validateEmail(value ?? '');
                      },
                      onFieldSubmitted: (String value) {
                        _emailFocus.unfocus();
                      }),
                  SizedBox(
                    height: 96.w,
                  ),
                ],
              ),
            ),
          )),
    );
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
                        text: AppLocalizations.of(context)!.mStaticSubmit,
                        textColor: AppColors.appBarBackground,
                        isLoading: savePressed,
                        bgColor:
                            isChanged ? AppColors.darkBlue : AppColors.grey40,
                        onTap: isChanged && !savePressed
                            ? () => _saveDetails()
                            : null,
                      );
                    });
              })),
    );
  }

  _checkForChanges() {
    _isChanged.value = false;
    if ((Validations.validateFullName(
                context: context, value: _nameController.text) ==
            null) &&
        (_validateEmail(_emailController.text) == null)) {
      _isChanged.value = true;
    }
    return _isChanged.value;
  }

  Future<void> _saveDetails() async {
    FocusScope.of(context).unfocus();
    _errorMessage = AppLocalizations.of(context)!.mProfileProvideValidDetails;
    if (_formKey.currentState!.validate()) {
      try {
        _savePressed.value = true;
        widget.submitCallback(GuestDataModel(
            name: _nameController.text, email: _emailController.text));
        _savePressed.value = false;
        Navigator.pop(context);
      } catch (e) {
        _savePressed.value = false;
        print(e);
      }
    } else {
      Helper.showSnackBarMessage(
          context: context, text: _errorMessage, bgColor: AppColors.greys87);
    }
  }
}
