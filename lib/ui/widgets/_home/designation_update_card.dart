import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' show Client;

import '../../../constants/index.dart';
import '../../../localization/index.dart';
import '../../../models/_models/verifiable_details_model.dart';
import '../../../models/index.dart';
import '../../../respositories/index.dart';
import '../../../util/edit_profile_mandatory_helper.dart';
import '../../../util/index.dart';
import '../../../util/validations.dart';
import '../../screens/_screens/profile/ui/widgets/select_from_bottomsheet.dart';

class DesignationUpdateCard extends StatefulWidget {
  final Map<String, dynamic> designationConfig;
  final bool isupdated;
  final ProfileRepository profileRepository;
  final FlutterSecureStorage storage;
  final Client? client;

  DesignationUpdateCard(
      {super.key,
      required this.designationConfig,
      this.isupdated = false,
      ProfileRepository? profileRepository,
      FlutterSecureStorage? storage,
      Client? client})
      : profileRepository = profileRepository ?? ProfileRepository(),
        storage = storage ?? FlutterSecureStorage(),
        client = client;
  @override
  State<DesignationUpdateCard> createState() => DesignationUpdateCardState();
}

class DesignationUpdateCardState extends State<DesignationUpdateCard> {
  TextEditingController designationController = TextEditingController();

  String? firstName;
  String? lastName;
  String? orgId;
  String designationKey = 'designation';

  List<dynamic> orgLevelDesignationsList = [];
  List<dynamic> designationList = [];
  List<dynamic> rejectedDesignationFields = [];
  List<dynamic> approvedDesignationFields = [];
  List<dynamic> inReviewList = [];

  bool showReminderCard = false;

  Locale? locale;

  @override
  void initState() {
    super.initState();
    setLocale();
    fetchData();
  }

  @override
  void didChangeDependencies() {
    setLocale();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(DesignationUpdateCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isupdated) {
      designationController.text = '';
      updateDesignationCard();
    }
  }

  @override
  void dispose() {
    designationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: showReminderCard,
      child: Material(
        child: Container(
          width: 1.0.sw,
          padding: EdgeInsets.all(16.0.w),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0.w),
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.pastelPink, AppColors.darkPink])),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                SvgPicture.network(
                    ApiUrl.baseUrl + widget.designationConfig['imageUrlMobile'],
                    height: 90.w,
                    width: 130.w,
                    httpClient: widget.client,
                    placeholderBuilder: (context) => Image.asset(
                        'assets/img/image_placeholder.jpg',
                        width: 80,
                        fit: BoxFit.fill)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8).r,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RichText(
                            text: TextSpan(
                                text:
                                    '${AppLocalizations.of(context)!.mStaticHello} ',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(
                                        color: AppColors.appBarBackground),
                                children: [
                              TextSpan(text: firstName ?? ''),
                              TextSpan(text: lastName ?? ''),
                              TextSpan(text: '!')
                            ])),
                        Container(
                          padding: EdgeInsets.only(top: 8),
                          width: 1.0.sw - 200.w,
                          child: Wrap(
                            children: [
                              Text(getLocaleBasedText('header'),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                          color: AppColors.appBarBackground)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ]),
              SizedBox(height: 16),
              Divider(height: 1, color: AppColors.appBarBackground),
              SizedBox(height: 16),
              Text(AppLocalizations.of(context)!.mProfileSelectDesignation,
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium!
                      .copyWith(color: AppColors.appBarBackground)),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SizedBox(
                      width: 0.6.sw,
                      child: SelectFromBottomSheet(
                          fieldName: EnglishLang.designation,
                          controller: designationController,
                          validator: (value) => Validations.validateDesignation(
                              context: context, value: value ?? ''),
                          parentContext: context,
                          isOrgBasedDesignation: true,
                          customBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColors.appBarBackground),
                              borderRadius: BorderRadius.circular(63)),
                          customFieldHeight: 45.w,
                          callBack: () {
                            setState(() {});
                          }),
                    ),
                  ),
                  Container(
                    height: 50.w,
                    margin: EdgeInsets.only(left: 8).r,
                    padding: EdgeInsets.only(top: 8).r,
                    child: ElevatedButton(
                        key: Key(KeyConstants.homeDesignationUpdateBtn),
                        onPressed: designationController.text.isNotEmpty
                            ? () {
                                saveProfile();
                              }
                            : null,
                        style: ButtonStyle(
                            backgroundColor:
                                designationController.text.isNotEmpty
                                    ? WidgetStatePropertyAll(AppColors.darkBlue)
                                    : WidgetStatePropertyAll(
                                        AppColors.darkBlue.withValues(alpha: 0.5)),
                            shape:
                                WidgetStatePropertyAll<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(63)))),
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 6, vertical: 6)
                                  .r,
                          child: Text(getLocaleBasedText('buttonText'),
                              style: Theme.of(context).textTheme.displaySmall),
                        )),
                  )
                ],
              ),
              SizedBox(height: 8),
              HtmlWidget(
                getLocaleBasedText('hintTextMobile'),
                textStyle: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(color: AppColors.appBarBackground),
                onTapUrl: (url) async {
                  return await Helper.mailTo(url);
                },
                customStylesBuilder: (element) {
                  if (element.localName == 'a') {
                    return {'color': '#FFFFFF'};
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getLocaleBasedText(String text) {
    return locale != null && locale!.languageCode != 'en'
        ? widget.designationConfig[
            '$text${Helper.capitalize(locale!.languageCode)}']
        : widget.designationConfig[text];
  }

  Future<void> checkDesignationCardVisibility() async {
    showReminderCard = await checkDesignationIsInMasterAndVerified();
  }

  Future<void> fetchData() async {
    await fetchProfileData();
    RegistrationLinkModel? orgInfo =
        await widget.profileRepository.getOrgFrameworkId();
    if (orgInfo != null) {
      if (orgInfo.orgId != null) {
        showReminderCard = await getDesignations(orgInfo.orgId!);
        if (mounted) {
          await Future.delayed(Duration(milliseconds: 500), () {
            setState(() {});
          });
        }
      }
    }
  }

  Future<bool> getDesignations(String frameworkId) async {
    orgLevelDesignationsList =
        await Provider.of<ProfileRepository>(context, listen: false)
            .getOrgBasedDesignations(frameworkId);
    return orgLevelDesignationsList.isNotEmpty
        ? await checkDesignationIsInMasterAndVerified()
        : false;
  }

  Future<bool> checkDesignationIsInMasterAndVerified() async {
    bool showCard = true;
    if (verifyApprovedDesignationInMaster()) {
      showCard = false;
    }
    if (showCard) {
      if (checkDesignationSendForApproval()) {
        showCard = false;
      }
    }
    return showCard;
  }

  bool checkDesignationSendForApproval() {
    inReviewList = context.read<ProfileRepository>().inReview;
    inReviewList = retrieveDesignationObject(inReviewList);
    inReviewList
        .sort((a, b) => b['lastUpdatedOn'].compareTo(a['lastUpdatedOn']));

    return inReviewList.isNotEmpty &&
        inReviewList.first.containsKey(designationKey) &&
        inReviewList.first[designationKey] != null &&
        inReviewList.first[designationKey].isNotEmpty;
  }

  Future<void> fetchProfileData() async {
    firstName = await widget.storage.read(key: Storage.firstName);
    lastName = await widget.storage.read(key: Storage.lastName);
    orgId = await widget.storage.read(key: Storage.deptId);
  }

  Future<void> saveProfile() async {
    try {
      String response = EnglishLang.success;
      if (response == EnglishLang.success) {
        String result =
            await EditProfileMandatoryHelper.saveVerifiableProfileDetails(
                context: context,
                verifiableDetails:
                    VerifiableDetails(position: designationController.text),
                isUpdateDesignation: true,
                profileRepository: widget.profileRepository);
        if (result == EnglishLang.success) {
          generateInteractTelemetryData();
          setState(() {
            showReminderCard = false;
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateDesignationCard() async {
    await checkDesignationCardVisibility();
    Future.delayed(Duration(milliseconds: 500), () {
      Provider.of<ProfileRepository>(context, listen: false)
          .designationStatus(false);
    });
  }

  Future setLocale() async {
    locale = await Helper.getLocale();
  }

  void generateInteractTelemetryData() async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.appHomePagePageId,
        contentId: TelemetryIdentifier.designationMasterImport,
        env: TelemetryEnv.home,
        clickId: '',
        subType: designationController.text);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  bool verifyApprovedDesignationInMaster() {
    // To get approved designation list
    List<dynamic> approvedDesignationFields =
        context.read<ProfileRepository>().approvedFields;
    approvedDesignationFields =
        retrieveDesignationObject(approvedDesignationFields);
    if (approvedDesignationFields.isNotEmpty) {
      approvedDesignationFields
          .sort((a, b) => b['lastUpdatedOn'].compareTo(a['lastUpdatedOn']));
      return isMatchFound(approvedDesignationFields.first[designationKey]);
    } else {
      return false;
    }
  }

  bool isMatchFound(String? designationValue) {
    return designationValue != null &&
        orgLevelDesignationsList.contains(designationValue);
  }

  List<dynamic> retrieveDesignationObject(List<dynamic> list) {
    list.removeWhere((field) => field[designationKey] == null);
    return list;
  }
}
