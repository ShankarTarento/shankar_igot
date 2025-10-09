import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/model/profile_model.dart';
import 'package:karmayogi_mobile/models/_models/verifiable_details_model.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/edit_page_appbar.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/field_name_v2_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/_common/button_widget_v2.dart';
import 'package:karmayogi_mobile/util/edit_profile_mandatory_helper.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../../../constants/index.dart';
import '../../../../../../util/index.dart';
import '../../../../../widgets/index.dart';
import '../../model/profile_field_status_model.dart';
import '../../view_model/profile_primary_details_view_model.dart';
import '../widgets/dropdown_with_search.dart';

class EditPrimaryDetailsSection extends StatefulWidget {
  final bool isMandatory;
  final bool isDesignationMasterEnabled;
  final Profile? profileDetails;

  final ValueChanged<String>? groupDetails;
  final ValueChanged<String>? designationDetails;

  const EditPrimaryDetailsSection(
      {Key? key,
      this.isMandatory = false,
      this.isDesignationMasterEnabled = false,
      this.designationDetails,
      this.groupDetails,
      this.profileDetails})
      : super(key: key);

  @override
  State<EditPrimaryDetailsSection> createState() =>
      _EditPrimaryDetailsSectionState();
}

class _EditPrimaryDetailsSectionState extends State<EditPrimaryDetailsSection> {
  final storage = FlutterSecureStorage();
  Future<List<String>>? futureGroupList;
  Future<List<String>>? futureDesignationList;
  final TextEditingController _groupController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  ValueNotifier<String> hintText = ValueNotifier('');
  Locale? locale;
  String selectedGroup = '';
  String selectedDesignation = '';
  String designationQuery = '';
  ValueNotifier<bool> _savePressed = ValueNotifier(false);
  int pageNo = 0;
  @override
  void initState() {
    super.initState();
    _populateFields();
    fetchData();
  }

  @override
  void dispose() {
    super.dispose();
    _positionController.dispose();
    _groupController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _hasFieldUpdated();
    return Scaffold(
      backgroundColor: AppColors.appBarBackground,
      appBar: EditPageAppbar(
        title: AppLocalizations.of(context)!.mProfilePrimaryDetails,
      ),
      body: _buildLayout(),
      bottomSheet: _bottomView(),
      resizeToAvoidBottomInset: false,
    );
  }

  Widget _buildLayout() {
    return SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Selector<ProfileRepository, List<ProfileFieldStatusModel>>(
            selector: (context, repo) => repo.approvedFields,
            builder: (BuildContext context,
                List<ProfileFieldStatusModel> approvedFields, Widget? child) {
              return Selector<ProfileRepository, List<ProfileFieldStatusModel>>(
                  selector: (context, repo) => repo.inReview,
                  builder: (BuildContext context,
                      List<ProfileFieldStatusModel> inReviewFields,
                      Widget? child) {
                    final approvedGroupField = approvedFields
                        .where((element) => element.group != null)
                        .toList()
                      ..sort(
                          (a, b) => b.lastUpdatedOn.compareTo(a.lastUpdatedOn));

                    selectedGroup = approvedGroupField.isNotEmpty
                        ? approvedGroupField.first.group ?? ''
                        : _groupController.text;

                    final inReviewGroupField = inReviewFields
                        .where((element) => element.group != null)
                        .toList();

                    final approvedDesignationField = approvedFields
                        .where((element) => element.designation != null)
                        .toList()
                      ..sort(
                          (a, b) => b.lastUpdatedOn.compareTo(a.lastUpdatedOn));

                    selectedDesignation = approvedDesignationField.isNotEmpty
                        ? approvedDesignationField.first.designation ?? ''
                        : _positionController.text;

                    final inReviewDesignationField = inReviewFields
                        .where((element) => element.designation != null)
                        .toList();

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0).r,
                      child: Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: 8.0, top: 16).r,
                            child: Text(
                                AppLocalizations.of(context)!
                                    .mProfilePrimaryDetailsEditDescription,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(color: AppColors.greys)),
                          ),

                          /// Group field
                          FieldNameV2Widget(
                            isMandatory: widget.isMandatory,
                            fieldName:
                                AppLocalizations.of(context)!.mStaticGroup,
                            isApprovalField: true,
                            isApproved: _groupController.text.isNotEmpty &&
                                _groupController.text ==
                                    (approvedGroupField.isNotEmpty
                                        ? approvedGroupField.first.group
                                        : widget.profileDetails?.group),
                            isInReview: inReviewFields.isNotEmpty &&
                                inReviewGroupField.isNotEmpty,
                          ),
                          FutureBuilder(
                              future: futureGroupList,
                              builder: (contxt, snapshot) {
                                return DropdownWithSearch(
                                  hintText: '',
                                  query: '',
                                  parentContext: context,
                                  optionList:
                                      snapshot.hasData && snapshot.data != null
                                          ? snapshot.data ?? []
                                          : [],
                                  selectedOption: selectedGroup,
                                  callback: (String group) {
                                    _groupController.text = group;
                                    widget.groupDetails != null
                                        ? widget.groupDetails!(
                                            _groupController.text)
                                        : null;
                                    setState(() {});
                                  },
                                );
                              }),
                          SizedBox(
                            height: 8.w,
                          ),

                          /// Designation field
                          ValueListenableBuilder(
                              valueListenable: hintText,
                              builder: (BuildContext contxt, String hintText,
                                  Widget? child) {
                                return Column(
                                  children: [
                                    FieldNameV2Widget(
                                      isMandatory: widget.isMandatory,
                                      fieldName: EnglishLang.designation,
                                      isApprovalField: true,
                                      isApproved:
                                          _positionController.text.isNotEmpty &&
                                              _positionController.text ==
                                                  (approvedDesignationField
                                                          .isNotEmpty
                                                      ? approvedDesignationField
                                                          .first.designation
                                                      : widget.profileDetails
                                                          ?.designation),
                                      isInReview: inReviewFields.isNotEmpty &&
                                          inReviewDesignationField.isNotEmpty,
                                    ),
                                    FutureBuilder(
                                        future: futureDesignationList,
                                        builder: (contxt, snapshot) {
                                          return DropdownWithSearch(
                                            hintText: '',
                                            query: designationQuery,
                                            isPaginated: true,
                                            parentContext: context,
                                            optionList: snapshot.hasData &&
                                                    snapshot.data != null
                                                ? snapshot.data ?? []
                                                : [],
                                            selectedOption: selectedDesignation,
                                            callback: (String designation) {
                                              _positionController.text =
                                                  designation;
                                              widget.designationDetails != null
                                                  ? widget.designationDetails!(
                                                      _positionController.text)
                                                  : null;
                                              setState(() {});
                                            },
                                            onSearchChanged:
                                                (String query) async {
                                              if (designationQuery == query) {
                                                pageNo++;
                                              } else {
                                                pageNo = 0;
                                              }
                                              return await ProfilePrimaryDetailsViewModel()
                                                  .getDesignations(
                                                      context: context,
                                                      isOrgBasedDesignation: widget
                                                          .isDesignationMasterEnabled,
                                                      offset: pageNo,
                                                      query: query);
                                            },
                                          );
                                        }),
                                    Visibility(
                                        visible: hintText.isNotEmpty &&
                                            widget.isDesignationMasterEnabled,
                                        child: Container(
                                          margin: EdgeInsets.only(top: 8),
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: AppColors.greys),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8).r),
                                              color:
                                                  AppColors.scaffoldBackground),
                                          child: HtmlWidget(
                                            hintText,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .labelMedium!
                                                .copyWith(
                                                    color:
                                                        AppColors.blackLegend),
                                            onTapUrl: (url) async {
                                              return await Helper.mailTo(url);
                                            },
                                            customStylesBuilder: (element) {
                                              if (element.localName == 'a') {
                                                return {'color': '#1B4CA1'};
                                              }
                                              return null;
                                            },
                                          ),
                                        ))
                                  ],
                                );
                              }),
                          Container(
                              margin:
                                  const EdgeInsets.symmetric(vertical: 8.0).r,
                              padding: const EdgeInsets.all(8.0).r,
                              decoration: BoxDecoration(
                                  color: AppColors.grey08,
                                  border: Border.all(color: AppColors.grey16),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(6)).r),
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TooltipWidget(
                                      message: 'designation',
                                      icon: Icons.info,
                                      iconColor: AppColors.blackLegend,
                                    ),
                                    SizedBox(width: 4.w),
                                    Container(
                                      width: 0.8.sw,
                                      child: HtmlWidget(
                                        AppLocalizations.of(context)!
                                            .mProfileNotAbleToFindDesignation(
                                                EnglishLang.htmlEmailLink),
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                                color: AppColors.blackLegend,
                                                letterSpacing: 0.25.r,
                                                height: 1.5.w),
                                      ),
                                    ),
                                  ])),
                          SizedBox(
                            height: 96.w,
                          ),
                        ],
                      ),
                    );
                  });
            }));
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
                return ButtonWidgetV2(
                  text: AppLocalizations.of(context)!.mProfileSendForApproval,
                  textColor: AppColors.appBarBackground,
                  isLoading: savePressed,
                  bgColor: _hasFieldUpdated()
                      ? AppColors.darkBlue
                      : AppColors.grey40,
                  onTap: _hasFieldUpdated() ? () => _saveProfile() : null,
                );
              })),
    );
  }

  void _populateFields() async {
    List<dynamic> inReviewFields =
        Provider.of<ProfileRepository>(context, listen: false).inReview;
    dynamic inReviewDesignation =
        inReviewFields.where((element) => element.designation != null);
    dynamic inReviewGroup =
        inReviewFields.where((element) => element.group != null);

    _positionController.text =
        (inReviewFields.isNotEmpty && inReviewDesignation.isNotEmpty)
            ? inReviewDesignation.first.designation
            : (widget.profileDetails?.designation ?? '');
    _groupController.text =
        (inReviewFields.isNotEmpty && inReviewGroup.isNotEmpty)
            ? inReviewGroup.first.group
            : (widget.profileDetails?.group ?? '');

    setState(() {});
  }

  Future<void> _saveProfile() async {
    try {
      _savePressed.value = true;
      String response =
          await EditProfileMandatoryHelper.saveVerifiableProfileDetails(
              context: context,
              verifiableDetails: VerifiableDetails(
                  group: _groupController.text,
                  position: _positionController.text));
      if (response == EnglishLang.success) {
        generateInteractTelemetryData();
        Provider.of<ProfileRepository>(context, listen: false)
            .designationStatus(true);
        Navigator.pop(context);
      }
      _savePressed.value = false;
    } catch (e) {
      _savePressed.value = false;
    }
  }

  bool _hasFieldUpdated() {
    List<dynamic> inReviewFields =
        Provider.of<ProfileRepository>(context, listen: false).inReview;
    List<dynamic> approvedFields =
        Provider.of<ProfileRepository>(context, listen: false).approvedFields;
    bool isUpdated = false;
    final inReviewDesignation =
        inReviewFields.where((element) => element.designation != null).toList();

    final inReviewGroup =
        inReviewFields.where((element) => element.group != null).toList();

    final approvedDesignation =
        approvedFields.where((element) => element.designation != null).toList();

    final approvedGroup =
        approvedFields.where((element) => element.group != null).toList();
    if ((_positionController.text !=
                ((inReviewFields.isNotEmpty && inReviewDesignation.isNotEmpty)
                    ? inReviewDesignation.first.designation
                    : (approvedDesignation.isNotEmpty
                        ? approvedDesignation.first.designation
                        : widget.profileDetails?.designation)) ||
            (_groupController.text !=
                ((inReviewFields.isNotEmpty && inReviewGroup.isNotEmpty)
                    ? inReviewGroup.first.group
                    : (approvedGroup.isNotEmpty
                        ? approvedGroup.first.group
                        : widget.profileDetails?.group)))) &&
        (_groupController.text.isNotEmpty &&
            _positionController.text.isNotEmpty)) {
      isUpdated = true;
    }
    return isUpdated;
  }

  Future<void> fetchData() async {
    await setLocale();
    if (locale != null) {
      hintText.value = await getLocaleBasedText();
      futureGroupList = Future.value(
          await ProfilePrimaryDetailsViewModel().getGroups(context));
      futureDesignationList = ProfilePrimaryDetailsViewModel()
          .getDesignations(
        context: context,
        isOrgBasedDesignation: widget.isDesignationMasterEnabled,
        offset: pageNo,
      )
          .then((list) {
        return list;
      });
      Future.delayed(Duration.zero, () => setState(() {}));
    }
  }

  Future setLocale() async {
    locale = await Helper.getLocale();
  }

  Future<String> getLocaleBasedText() async {
    String? config = await storage.read(key: Storage.designationConfig);
    if (config != null) {
      Map<String, dynamic> designationConfig = await jsonDecode(config);
      return locale!.languageCode != 'en'
          ? designationConfig[
              'hintTextMobile${Helper.capitalize(locale!.languageCode)}']
          : designationConfig['hintTextMobile'];
    } else {
      return '';
    }
  }

  void generateInteractTelemetryData() async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.appHomePagePageId,
        contentId: TelemetryIdentifier.designationMasterImport,
        env: TelemetryEnv.profile,
        clickId: '',
        subType: _positionController.text);
    await telemetryRepository.insertEvent(eventData: eventData);
  }
}
