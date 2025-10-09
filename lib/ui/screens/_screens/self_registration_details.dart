import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../constants/index.dart';
import '../../../env/env.dart';
import '../../../localization/index.dart';
import '../../../models/_models/register_organisation_model.dart';
import '../../../models/index.dart';
import '../../../respositories/index.dart';
import '../../../util/app_navigator_observer.dart';
import '../../../util/deeplinks/deeplink_service.dart';
import '../../../util/index.dart';
import '../../../util/load_webview_page.dart';
import '../../../util/validations.dart';
import 'profile/ui/widgets/field_name_widget.dart';
import 'profile/ui/widgets/select_from_bottomsheet.dart';
import '../../widgets/index.dart';

class SelfRegistrationDetails extends StatefulWidget {
  final RegistrationLinkModel arguments;

  const SelfRegistrationDetails({super.key, required this.arguments});

  @override
  State<SelfRegistrationDetails> createState() =>
      SelfRegistrationDetailsState();
}

class SelfRegistrationDetailsState extends State<SelfRegistrationDetails> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController designationController = TextEditingController();
  final TextEditingController groupController = TextEditingController();
  final ProfileRepository profileRepository = ProfileRepository();
  String? fullName, _email, _mobileNumber, orgName;
  bool focusEmail = false,
      focusMobile = false,
      isAgreePolicy = true,
      focusDesignation = false,
      focusGroup = false,
      isAllowWhatsappMessages = false,
      focusWhatsappConsent = false;
  bool isEmailVerified = false, isMobileVerified = false;
  OrganisationModel? orgatnizationData;
  RegistrationLinkModel? orgInfo;
  final groupKey = new GlobalKey();
  final designationKey = new GlobalKey();
  final mobileKey = new GlobalKey();
  final FocusNode whatsappFocusNode = FocusNode();
  int _start = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    fetchData();
    DeeplinkService().deleteDeeplinkPayload();
    if (_start == 0) {
      _startTimer();
    }
    generateTelemetryStartData();
    _generateTelemetryData();
  }

  void generateTelemetryStartData() async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getStartTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.appHomeUri,
        telemetryType: TelemetryType.public,
        pageUri: TelemetryPageIdentifier.appHomeUri,
        env: TelemetryEnv.selfRegistration,
        isPublic: true);
    await telemetryRepository.insertEvent(eventData: eventData, isPublic: true);
  }

  void _generateTelemetryData() async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getImpressionTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.appHomeUri,
        telemetryType: TelemetryType.viewer,
        pageUri: TelemetryPageIdentifier.appHomeUri,
        env: TelemetryEnv.selfRegistration,
        isPublic: true);
    await telemetryRepository.insertEvent(eventData: eventData, isPublic: true);
  }

  void _generateInteractTelemetryData() async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.appHomePagePageId,
        contentId: '',
        env: TelemetryEnv.selfRegistration,
        clickId: TelemetryClickId.signUp,
        isPublic: true);
    await telemetryRepository.insertEvent(eventData: eventData, isPublic: true);
  }

  triggerEndTelemetryEvent() async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getEndTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.appHomeUri,
        duration: _start,
        telemetryType: TelemetryType.public,
        pageUri: TelemetryPageIdentifier.appHomeUri,
        rollup: {},
        env: TelemetryEnv.selfRegistration,
        isPublic: true);
    await telemetryRepository.insertEvent(eventData: eventData, isPublic: true);
    _timer.cancel();
  }

  Future<void> fetchData() async {
    String orgId = widget.arguments.orgId!;
    orgInfo = await Provider.of<ProfileRepository>(context, listen: false)
        .getOrgFrameworkId(orgId: orgId);
    if (orgInfo != null) {
      if (orgInfo!.orgId != null) {
        await getDesignations(orgInfo!.orgId!);
      }
      setState(() {
        orgName = orgInfo!.orgName;
      });
    }
    orgatnizationData =
        await Provider.of<ProfileRepository>(context, listen: false)
            .getOrganizationData(orgId);
  }

  @override
  void dispose() {
    triggerEndTelemetryEvent();
    designationController.dispose();
    groupController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        final previousRoute = AppNavigatorObserver.instance.getLastRouteName();
        if (previousRoute == '/') {
          Navigator.pushReplacementNamed(context, AppUrl.onboardingScreen);
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.appBarBackground,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(70.0.w),
          child: SelfRegisterAppbar(),
        ),
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowIndicator();
            return true;
          },
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16).r,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          SizedBox(
                              height: 0.62.sh,
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 16),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: orgInfo != null &&
                                                    orgInfo!.orgLogo != null
                                                ? 1.0.sw - 155.w
                                                : 1.0.sw - 80.w,
                                            child: RichText(
                                              text: TextSpan(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .mRegisterRegisterFor,
                                                style: GoogleFonts.montserrat(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 20.sp,
                                                  color: AppColors.greys,
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text: ' ' + (orgName ?? ''),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge!
                                                        .copyWith(
                                                            fontSize: 20.sp),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          orgInfo != null &&
                                                  orgInfo!.orgLogo != null
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(63)
                                                          .r,
                                                  child: Image(
                                                    height: 70.w,
                                                    width: 70.w,
                                                    fit: BoxFit.fitWidth,
                                                    image: NetworkImage(Helper
                                                        .convertGCPImageUrl(
                                                            orgInfo!.orgLogo!)),
                                                    errorBuilder: (context,
                                                            error,
                                                            stackTrace) =>
                                                        SizedBox.shrink(),
                                                  ))
                                              : SizedBox.shrink()
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 24),

                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: FullnameWidget(
                                        onSaved: (String? value) {
                                          fullName = value;
                                        },
                                        formKey: formKey,
                                        changeFocus: (String value) {
                                          fieldFocusChange(value);
                                        },
                                      ),
                                    ),
                                    EmailWidget(
                                      isFocused: focusEmail,
                                      onSaved: (String? value) {
                                        _email = value;
                                      },
                                      formKey: formKey,
                                      changeFocus: (String value) {
                                        fieldFocusChange(value);
                                      },
                                      emailVerified: (bool value) {
                                        setState(() {
                                          isEmailVerified = value;
                                        });
                                      },
                                      name: fullName,
                                      mobileNumber: _mobileNumber,
                                      isMobileNumberVerified: isMobileVerified,
                                      getMobileNumber: _updateMobile,
                                    ),
                                    SizedBox(height: 32),
                                    Container(
                                      key: mobileKey,
                                      child: PhoneNumberWidget(
                                        isFocused: focusMobile,
                                        onSaved: (String? value) {
                                          _mobileNumber = value;
                                        },
                                        formKey: formKey,
                                        mobileVerified: (value) {
                                          setState(() {
                                            isMobileVerified = value;
                                          });
                                        },
                                        changeFocus: (String value) {
                                          fieldFocusChange(value);
                                        },
                                        mobileNumber: _mobileNumber,
                                        isMobileVerified: isMobileVerified,
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Checkbox(
                                          focusNode: whatsappFocusNode,
                                          key: Key('WhatsappConsent'),
                                          side: BorderSide(
                                              width: 2,
                                              color: whatsappFocusNode.hasFocus
                                                  ? AppColors.darkBlue
                                                  : AppColors.greys60),
                                          value: isAllowWhatsappMessages,
                                          onChanged: (value) {
                                            if (value !=
                                                isAllowWhatsappMessages) {
                                              setState(() {
                                                isAllowWhatsappMessages =
                                                    value ?? true;
                                              });
                                              fieldFocusChange(
                                                  EnglishLang.designation);
                                            }
                                          },
                                          fillColor: WidgetStatePropertyAll(
                                            isAllowWhatsappMessages
                                                ? AppColors.darkBlue
                                                : AppColors.appBarBackground,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                              AppLocalizations.of(context)!
                                                  .mRegisterRecieveMessageOnWhatsapp,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                      color: AppColors.greys)),
                                        ),
                                      ],
                                    ),
                                    // Designation field
                                    Padding(
                                      key: designationKey,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: FieldNameWidget(
                                        fieldName: AppLocalizations.of(context)!
                                            .mStaticDesignation,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: SelectFromBottomSheet(
                                        isFocused: focusDesignation,
                                        fieldName: EnglishLang.designation,
                                        controller: designationController,
                                        validator: (value) =>
                                            Validations.validateGroup(
                                                context: context,
                                                value: value ?? ''),
                                        parentContext: context,
                                        isOrgBasedDesignation: true,
                                        callBack: () {
                                          setState(() {});
                                        },
                                        changeFocus: (String value) {
                                          fieldFocusChange(value);
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    // Group field
                                    Padding(
                                      key: groupKey,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: FieldNameWidget(
                                        fieldName: AppLocalizations.of(context)!
                                            .mStaticGroup,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: SelectFromBottomSheet(
                                          isFocused: focusGroup,
                                          fieldName: EnglishLang.group,
                                          controller: groupController,
                                          callBack: () {
                                            setState(() {});
                                          },
                                          parentContext: context,
                                          validator: (value) =>
                                              Validations.validateGroup(
                                                  context: context,
                                                  value: value ?? '')),
                                    ),
                                    SizedBox(height: 120.w)
                                  ],
                                ),
                              )),
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Container(
                              color: AppColors
                                  .appBarBackground, // Optional: Add background to separate
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Checkbox(
                                        key: Key('AgreePolicy'),
                                        value: isAgreePolicy,
                                        onChanged: (value) {
                                          if (value != isAgreePolicy) {
                                            setState(() {
                                              isAgreePolicy = value ?? true;
                                            });
                                          }
                                        },
                                        fillColor: WidgetStatePropertyAll(
                                          isAgreePolicy
                                              ? AppColors.darkBlue
                                              : AppColors.appBarBackground,
                                        ),
                                      ),
                                      Expanded(
                                        child: RichText(
                                          text: TextSpan(
                                            text: AppLocalizations.of(context)!
                                                .mRegisterConfirmationMessage,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    color: AppColors.greys),
                                            children: [
                                              TextSpan(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .mRegisterterms,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .displayLarge!
                                                    .copyWith(
                                                        color:
                                                            AppColors.darkBlue),
                                                recognizer:
                                                    TapGestureRecognizer()
                                                      ..onTap = () {
                                                        Navigator.of(context)
                                                            .push(
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                LoadWebViewPage(
                                                              title: AppLocalizations
                                                                      .of(context)!
                                                                  .mRegisterterms,
                                                              url: Env
                                                                  .termsOfServiceUrl,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                              ),
                                              TextSpan(
                                                text:
                                                    ' & ${AppLocalizations.of(context)!.mStaticPrivacyPolicy}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .displayLarge!
                                                    .copyWith(
                                                        color:
                                                            AppColors.darkBlue),
                                                recognizer:
                                                    TapGestureRecognizer()
                                                      ..onTap = () {
                                                        Navigator.of(context)
                                                            .push(
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                LoadWebViewPage(
                                                              title: AppLocalizations
                                                                      .of(context)!
                                                                  .mStaticPrivacyPolicy,
                                                              url: ApiUrl
                                                                      .baseUrl +
                                                                  ApiUrl
                                                                      .privacyPolicy,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  SizedBox(
                                    width: 0.8.sw,
                                    child: ElevatedButton(
                                      key: Key('SignUp'),
                                      onPressed:
                                          !isAgreePolicy || !isSignUpEnabled()
                                              ? null
                                              : _submitForm,
                                      style: ButtonStyle(
                                          backgroundColor: WidgetStateProperty
                                              .resolveWith<Color>((states) {
                                            if (states.contains(
                                                WidgetState.disabled)) {
                                              return AppColors.darkBlue.withValues(
                                                  alpha:
                                                      0.5); // Custom disabled color
                                            }
                                            return AppColors
                                                .darkBlue; // Enabled color
                                          }),
                                          padding:
                                              WidgetStateProperty.all<EdgeInsets>(
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 24,
                                                      vertical: 16)),
                                          shape: WidgetStateProperty.all<
                                                  RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          63)))),
                                      child: Text(
                                          AppLocalizations.of(context)!
                                              .mStaticSignUp,
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayLarge!
                                              .copyWith(
                                                  color: AppColors
                                                      .appBarBackground)),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  InkWell(
                                    onTap: () => Navigator.of(context)
                                        .pushNamedAndRemoveUntil(
                                      AppUrl.loginPage,
                                      (Route<dynamic> route) => false,
                                    ),
                                    child: RichText(
                                      text: TextSpan(
                                        text: AppLocalizations.of(context)!
                                            .mRegisterhaveAccount,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(color: AppColors.greys),
                                        children: [
                                          TextSpan(
                                              text: ' ' +
                                                  AppLocalizations.of(context)!
                                                      .mRegisterSignInHere,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displayLarge!
                                                  .copyWith(
                                                      color:
                                                          AppColors.darkBlue)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void fieldFocusChange(String value) {
    setState(() {
      if (value == EnglishLang.email) {
        focusEmail = true;
        focusMobile = false;
        focusDesignation = false;
        focusGroup = false;
        focusWhatsappConsent = false;
      } else if (value == EnglishLang.mobileNumber) {
        focusEmail = false;
        focusMobile = true;
        focusDesignation = false;
        focusGroup = false;
        focusWhatsappConsent = false;
      } else if (value == EnglishLang.designation) {
        focusEmail = false;
        focusMobile = false;
        focusDesignation = true;
        focusGroup = false;
        focusWhatsappConsent = false;
      } else if (value == EnglishLang.group) {
        focusEmail = false;
        focusMobile = false;
        focusDesignation = false;
        focusGroup = true;
        focusWhatsappConsent = false;
      } else if (value == EnglishLang.whatsappConsent) {
        focusEmail = false;
        focusMobile = false;
        focusDesignation = false;
        focusGroup = false;
        focusWhatsappConsent = true;
      } else {
        focusEmail = false;
        focusMobile = false;
        focusDesignation = false;
        focusGroup = false;
        focusWhatsappConsent = false;
      }

      if (focusWhatsappConsent) {
        if (!whatsappFocusNode.hasFocus) {
          whatsappFocusNode.requestFocus();
        }
      } else {
        if (whatsappFocusNode.hasFocus) {
          whatsappFocusNode.unfocus();
        }
      }
    });
    doAutoScroll();
  }

  Future<void> getDesignations(String frameworkId) async {
    await Provider.of<ProfileRepository>(context, listen: false)
        .getOrgBasedDesignations(frameworkId);
  }

  void _submitForm() {
    if (formKey.currentState!.validate()) {
      _registerAccount();
    }
  }

  Future _registerAccount() async {
    String response;
    try {
      if (orgatnizationData != null &&
          widget.arguments.link != null &&
          _mobileNumber != null &&
          fullName != null &&
          _email != null) {
        response = await profileRepository.getSelfRegister(
            fullName: fullName!,
            email: _email!,
            group: groupController.text,
            mobileNumber: _mobileNumber!,
            designation: designationController.text,
            organisation: orgatnizationData!,
            isWhatsappConsent: isAllowWhatsappMessages,
            registrationLink: widget.arguments.link!);
        if (response == EnglishLang.success) {
          _generateInteractTelemetryData();
          await _showPopupForSuccessfulRegister();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response),
              backgroundColor: AppColors.primaryTwo,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.mCSRRegistrationFailed),
            backgroundColor: AppColors.primaryTwo,
          ),
        );
      }
    } catch (err) {
      return err;
    }
  }

  Future<void> _showPopupForSuccessfulRegister() async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.mStaticThanksForRegistering,
            key: Key('SignUpSuccessThanksMsgDialog'),
            style: Theme.of(context)
                .textTheme
                .headlineSmall!
                .copyWith(color: AppColors.greys87)),
        content: Text(
          AppLocalizations.of(context)!.mStaticPostRegisterInfo,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8).r,
        actions: <Widget>[
          Container(
            width: 87.w,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkBlue,
                minimumSize: const Size.fromHeight(40),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pushReplacementNamed(AppUrl.loginPage);
              },
              child: Text(
                AppLocalizations.of(context)!.mStaticOk.toUpperCase(),
                style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.appBarBackground,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool isSignUpEnabled() {
    return isAgreePolicy &&
        isEmailVerified &&
        isMobileVerified &&
        designationController.text.isNotEmpty &&
        groupController.text.isNotEmpty &&
        fullName != null;
  }

  _updateMobile(String mobileNumber, bool isVerified) {
    setState(() {
      _mobileNumber = mobileNumber;
      isMobileVerified = isVerified;
    });
  }

  void doAutoScroll() {
    if (focusGroup) {
      Future.delayed(Duration.zero, () {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          Scrollable.ensureVisible(groupKey.currentContext!,
              curve: Curves.easeInOutBack);
        });
      });
    } else if (focusDesignation) {
      Future.delayed(Duration.zero, () {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          Scrollable.ensureVisible(designationKey.currentContext!,
              curve: Curves.easeInOutBack);
        });
      });
    } else if (focusMobile) {
      Future.delayed(Duration.zero, () {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          Scrollable.ensureVisible(mobileKey.currentContext!,
              curve: Curves.easeInOutBack);
        });
      });
    }
  }

  void _startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        _start++;
      },
    );
  }
}
