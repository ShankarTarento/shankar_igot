import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/model/profile_model.dart';
import 'package:karmayogi_mobile/models/_models/verifiable_details_model.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/dropdown_with_search.dart';
import 'package:karmayogi_mobile/ui/widgets/_common/button_widget_v2.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/field_name_widget.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/select_from_bottomsheet.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/util/edit_profile_mandatory_helper.dart';
import 'package:provider/provider.dart';

import '../../view_model/profile_primary_details_view_model.dart';

class ProfileTransferRequestPopup extends StatefulWidget {
  final BuildContext parentContext;
  final bool isDesignationMasterEnabled;
  const ProfileTransferRequestPopup(
      {Key? key,
      required this.parentContext,
      this.isDesignationMasterEnabled = false})
      : super(key: key);

  @override
  State<ProfileTransferRequestPopup> createState() =>
      _ProfileTransferRequestPopupState();
}

class _ProfileTransferRequestPopupState
    extends State<ProfileTransferRequestPopup> {
  TextEditingController _organizationController = TextEditingController();
  TextEditingController _groupController = TextEditingController();
  String _designation = '';
  ValueNotifier<bool> _isLoading = ValueNotifier(false);
  ValueNotifier<List<String>> designationList = ValueNotifier([]);
  String designationQuery = '';
  int pageNo = 0;

  @override
  void initState() {
    super.initState();
    _populateFields();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.only(left: 16, right: 16).r,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0).r),
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
              color: AppColors.grey08,
              borderRadius: BorderRadius.circular(12).r),
          padding: EdgeInsets.all(16).r,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8).r,
                child: Center(
                  child: SizedBox(
                    width: 0.5.sw,
                    child: Text(
                      AppLocalizations.of(widget.parentContext)!
                          .mProfileSelectAllFieldsTransferRequest,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                          fontWeight: FontWeight.w600, fontSize: 16.sp),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 4.w),
              FieldNameWidget(
                fieldName: AppLocalizations.of(widget.parentContext)!
                    .mProfileOrganisation,
              ),
              SelectFromBottomSheet(
                  fieldName: EnglishLang.organisationName,
                  controller: _organizationController,
                  parentContext: widget.parentContext,
                  callBack: () {
                    setState(() {});
                  }),
              Visibility(
                visible:
                    _organizationController.text.isNotEmpty && _hasOrgChanged(),
                child: Column(
                  children: [
                    FieldNameWidget(
                      fieldName: AppLocalizations.of(widget.parentContext)!
                          .mStaticGroup,
                    ),
                    SelectFromBottomSheet(
                        fieldName: EnglishLang.group,
                        controller: _groupController,
                        parentContext: widget.parentContext,
                        callBack: () {
                          setState(() {});
                        }),
                    FieldNameWidget(
                      fieldName: AppLocalizations.of(widget.parentContext)!
                          .mStaticDesignation,
                    ),
                    SizedBox(height: 8.w),
                    ValueListenableBuilder(
                        valueListenable: designationList,
                        builder: (context, designations, _) {
                          return Container(
                            decoration: BoxDecoration(
                                color: AppColors.appBarBackground,
                                borderRadius: BorderRadius.circular(4).r),
                            child: DropdownWithSearch(
                              hintText:
                                  AppLocalizations.of(widget.parentContext)!
                                      .mStaticSelectHere,
                              query: designationQuery,
                              isPaginated: true,
                              parentContext: widget.parentContext,
                              optionList: designations,
                              selectedOption: _designation,
                              borderRadius: 4,
                              borderColor: AppColors.grey16,
                              callback: (String designation) {
                                _designation = designation;
                                setState(() {});
                              },
                              onSearchChanged: (String query) async {
                                if (designationQuery == query) {
                                  pageNo++;
                                } else {
                                  pageNo = 0;
                                }
                                return await ProfilePrimaryDetailsViewModel()
                                    .getDesignations(
                                        context: context,
                                        isOrgBasedDesignation:
                                            widget.isDesignationMasterEnabled,
                                        offset: pageNo,
                                        query: query);
                              },
                            ),
                          );
                        })
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 24).r,
                padding: EdgeInsets.all(8).r,
                decoration: BoxDecoration(
                    color: AppColors.grey04,
                    borderRadius: BorderRadius.circular(4).r,
                    border: Border.all(color: AppColors.grey08)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info, size: 16.sp),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Text(
                        AppLocalizations.of(widget.parentContext)!
                            .mProfileTransferRequestInstruction,
                        style: GoogleFonts.lato(fontSize: 12.sp),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              ValueListenableBuilder<bool>(
                  valueListenable: _isLoading,
                  builder:
                      (BuildContext context, bool isLoading, Widget? child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ButtonWidgetV2(
                          text: AppLocalizations.of(widget.parentContext)!
                              .mStaticCancel,
                          textColor: AppColors.darkBlue,
                          borderColor: AppColors.darkBlue,
                          bgColor: Colors.transparent,
                          onTap: !isLoading
                              ? () => Navigator.of(context).pop()
                              : null,
                        ),
                        ButtonWidgetV2(
                          text: AppLocalizations.of(widget.parentContext)!
                              .mProfileSubmitRequest,
                          isLoading: isLoading,
                          textColor: AppColors.appBarBackground,
                          bgColor: _checkAllFieldsFilled()
                              ? AppColors.darkBlue
                              : AppColors.grey40,
                          onTap: _checkAllFieldsFilled() && !isLoading
                              ? () async {
                                  _isLoading.value = true;
                                  await _submitRequest();
                                  _isLoading.value = false;
                                }
                              : null,
                        )
                      ],
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _populateFields() async {
    Profile? profile =
        Provider.of<ProfileRepository>(widget.parentContext, listen: false)
            .profileDetails;
    dynamic employmentDetails = profile?.employmentDetails;
    _organizationController.text = employmentDetails['departmentName'];
    _groupController.text = profile?.group ?? '';
    _designation = profile?.designation ?? '';
    designationList.value = await fetchDesignations();
  }

  bool _hasOrgChanged() {
    Profile? profile =
        Provider.of<ProfileRepository>(widget.parentContext, listen: false)
            .profileDetails;
    dynamic employmentDetails = profile?.employmentDetails;
    return _organizationController.text != employmentDetails['departmentName'];
  }

  bool _checkAllFieldsFilled() {
    return _organizationController.text.isNotEmpty &&
        _hasOrgChanged() &&
        _groupController.text.isNotEmpty &&
        _designation.isNotEmpty;
  }

  Future<void> _submitRequest() async {
    try {
      await EditProfileMandatoryHelper.submitProfileTransferRequest(
          context: widget.parentContext,
          currentContext: context,
          verifiableDetails: VerifiableDetails(
              group: _groupController.text,
              position: _designation,
              organisation: _organizationController.text));
    } catch (e) {}
  }

  Future<List<String>> fetchDesignations(
      {String query = '', int offset = 0}) async {
    if (designationQuery != query) {
      designationQuery = query;
      pageNo = 0;
      offset = 0;
    }
    List<String> newDesignations =
        await ProfilePrimaryDetailsViewModel().getDesignations(
      context: context,
      isOrgBasedDesignation: widget.isDesignationMasterEnabled,
      offset: offset,
      query: query,
    );

    if (newDesignations.isEmpty) {
      return [];
    } else {
      return newDesignations;
    }
  }
}
