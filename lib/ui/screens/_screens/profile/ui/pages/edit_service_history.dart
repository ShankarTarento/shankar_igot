import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../constants/index.dart';
import '../../../../../../models/_models/register_organisation_model.dart';
import '../../../../../../respositories/index.dart';
import '../../../../../pages/_pages/search/utils/search_helper.dart';
import '../../../../../widgets/_common/button_widget_v2.dart';
import '../widgets/field_name_widget.dart';
import '../../../../../widgets/index.dart';
import '../../model/district_model.dart';
import '../../model/state_model.dart';
import '../../view_model/profile_service_history_view_model.dart';
import '../../view_model/profile_top_section_view_model.dart';
import '../../utils/profile_helper.dart';
import '../widgets/date_widget.dart';
import '../widgets/profile_edit_hearder.dart';
import '../widgets/selectable_field.dart';

class EditServiceHistory extends StatefulWidget {
  final String? orgName;
  final String? designation;
  final String? state;
  final String? district;
  final String? uuid;
  final String startDate;
  final String endDate;
  final String? description;
  final String? orgLogo;
  final ProfileRepository profileRepository;
  final bool isUpdate;
  final bool currentlyWorking;
  final VoidCallback updateCallback;

  EditServiceHistory(
      {super.key,
      this.orgName,
      this.designation,
      this.state,
      this.district,
      this.uuid,
      required this.startDate,
      required this.endDate,
      this.description,
      this.orgLogo,
      this.isUpdate = false,
      this.currentlyWorking = false,
      ProfileRepository? profileRepository,
      required this.updateCallback})
      : profileRepository = profileRepository ?? ProfileRepository();
  @override
  State<EditServiceHistory> createState() => _EditServiceHistoryState();
}

class _EditServiceHistoryState extends State<EditServiceHistory> {
  List<String> organizationList = [];
  List<String> designationList = [];
  ValueNotifier<String> selectedOrg = ValueNotifier('');
  ValueNotifier<String> selectedDesignation = ValueNotifier('');
  ValueNotifier<String> selectedState = ValueNotifier('');
  ValueNotifier<String> selectedDistrict = ValueNotifier('');
  ValueNotifier<bool> isChanged = ValueNotifier(false);
  TextEditingController descriptionController = TextEditingController();
  bool isCurrentlyWorking = false;
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  final FocusNode currentlyWorkingFocusNode = FocusNode();
  Future<List<StateModel>>? futureStateList;
  Future<List<DistrictModel>>? futureDistrictList;
  List<OrganisationModel> orgDataList = [];
  int orgOffset = 0;
  int designationOffset = 0;
  String orgQueryText = '';
  String designationQueryText = '';
  String orgLogo = '';
  ValueNotifier<String?> descriptionError = ValueNotifier(null);
  ValueNotifier<String?> orgError = ValueNotifier(null);
  ValueNotifier<String?> designationError = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    selectedOrg.value = widget.orgName ?? '';
    selectedDesignation.value = widget.designation ?? '';
    selectedState.value = widget.state ?? '';
    selectedDistrict.value = widget.district ?? '';
    selectedStartDate = widget.startDate.isNotEmpty
        ? DateTime.parse(widget.startDate).toLocal()
        : null;
    selectedEndDate = widget.endDate.isNotEmpty
        ? DateTime.parse(widget.endDate).toLocal()
        : null;
    isCurrentlyWorking = widget.currentlyWorking;
    orgLogo = widget.orgLogo ?? '';
    descriptionController.text = widget.description ?? '';
    fetchData();
  }

  @override
  void dispose() {
    selectedOrg.dispose();
    selectedDesignation.dispose();
    selectedState.dispose();
    selectedDistrict.dispose();
    descriptionController.dispose();
    currentlyWorkingFocusNode.dispose();
    isChanged.dispose();
    descriptionError.dispose();
    orgError.dispose();
    designationError.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 32).r,
          child: GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0).r,
              child: Column(
                children: [
                  ProfileEditHeader(
                      title:
                          AppLocalizations.of(context)!.mProfileServiceHistory,
                      callback: () => Navigator.pop(context)),
                  Expanded(
                      child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Oragnization/ministry
                        FieldNameWidget(
                          isMandatory: true,
                          fieldName:
                              '${AppLocalizations.of(context)!.mStaticOrganisation}/${AppLocalizations.of(context)!.mStaticMinistry}',
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ValueListenableBuilder(
                                valueListenable: selectedOrg,
                                builder: (BuildContext context,
                                    String organization, Widget? child) {
                                  return SelectableField(
                                      value: organization,
                                      color: widget.currentlyWorking
                                          ? AppColors.grey08
                                          : null,
                                      placeholder: AppLocalizations.of(context)!
                                          .mProfielSelectOrganizatinMinistry,
                                      onTap: () => widget.currentlyWorking
                                          ? null
                                          : ProfileHelper()
                                              .showSearchableBottomSheet(
                                                  context: context,
                                                  items: organizationList,
                                                  onFetchMore:
                                                      (String query) async {
                                                    if (query == orgQueryText) {
                                                      orgOffset++;
                                                    } else {
                                                      orgQueryText = query;
                                                      orgOffset = 0;
                                                    }
                                                    return await getOrgMasterList(
                                                        orgOffset, query);
                                                  },
                                                  onItemSelected:
                                                      (String value) async {
                                                    selectedOrg.value = value;
                                                    designationList = [];
                                                    selectedDesignation.value =
                                                        '';
                                                    orgError.value = null;
                                                    designationList =
                                                        await fetchDesignationWithOrgName(
                                                            orgName: value,
                                                            offset: 0,
                                                            query: '');
                                                    if (mounted) {
                                                      setState(() {});
                                                    }
                                                    checkChanges();
                                                  }));
                                }),
                            ValueListenableBuilder(
                                valueListenable: orgError,
                                builder: (context, errMsg, _) {
                                  return Visibility(
                                    visible: errMsg != null,
                                    child: Text(errMsg ?? '',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall!
                                            .copyWith(
                                                color:
                                                    AppColors.negativeLight)),
                                  );
                                })
                          ],
                        ),
                        // Designation
                        FieldNameWidget(
                          isMandatory: true,
                          fieldName:
                              AppLocalizations.of(context)!.mProfileDesignation,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ValueListenableBuilder(
                                valueListenable: selectedDesignation,
                                builder: (BuildContext context,
                                    String designation, Widget? child) {
                                  return SelectableField(
                                      value: designation,
                                      placeholder: AppLocalizations.of(context)!
                                          .mProfileSelectDesignation,
                                      color: designationList.isEmpty
                                          ? AppColors.grey08
                                          : null,
                                      onTap: () => selectedOrg.value.isEmpty
                                          ? SearchHelper().showOverlayMessage(
                                              AppLocalizations.of(context)!
                                                  .mProfileDistrictDisable,
                                              context,
                                              duration: 3)
                                          : designationList.isEmpty
                                              ? null
                                              : ProfileHelper()
                                                  .showSearchableBottomSheet(
                                                      context: context,
                                                      items: designationList,
                                                      onFetchMore:
                                                          (String query) async {
                                                        if (query ==
                                                            designationQueryText) {
                                                          designationOffset++;
                                                        } else {
                                                          designationQueryText =
                                                              query;
                                                          designationOffset = 0;
                                                        }
                                                        return await getOrgMasterList(
                                                            designationOffset,
                                                            query);
                                                      },
                                                      onItemSelected:
                                                          (String value) {
                                                        selectedDesignation
                                                            .value = value;
                                                        designationError.value =
                                                            null;
                                                        checkChanges();
                                                      }));
                                }),
                            ValueListenableBuilder(
                                valueListenable: designationError,
                                builder: (context, errMsg, _) {
                                  return Visibility(
                                    visible: errMsg != null,
                                    child: Text(errMsg ?? '',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall!
                                            .copyWith(
                                                color:
                                                    AppColors.negativeLight)),
                                  );
                                })
                          ],
                        ),
                        // State
                        FieldNameWidget(
                          fieldName: AppLocalizations.of(context)!.mStaticState,
                        ),
                        FutureBuilder(
                            future: futureStateList,
                            builder: (context, snapshot) {
                              List<String> stateList = snapshot.data != null &&
                                      snapshot.data!.isNotEmpty
                                  ? ProfileTopSectionViewModel()
                                      .getStateNames(snapshot.data!)
                                  : [];
                              return ValueListenableBuilder(
                                  valueListenable: selectedState,
                                  builder: (BuildContext context, String state,
                                      Widget? child) {
                                    return SelectableField(
                                        value: state,
                                        placeholder:
                                            AppLocalizations.of(context)!
                                                .mProfileSelectState,
                                        onTap: () => ProfileHelper()
                                            .showSearchableBottomSheet(
                                                context: context,
                                                items: stateList,
                                                onItemSelected:
                                                    (String value) async {
                                                  selectedState.value = value;
                                                  checkChanges();
                                                  selectedDistrict.value = '';
                                                  futureDistrictList =
                                                      Future.value(
                                                          await fetchDistricts(
                                                              value));

                                                  if (mounted) {
                                                    setState(() {});
                                                  }
                                                }));
                                  });
                            }),
                        // District
                        Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8).r,
                              child: Text(
                                AppLocalizations.of(context)!.mProfileDistrict,
                                style: Theme.of(context).textTheme.displayLarge,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            TooltipWidget(
                              message: AppLocalizations.of(context)!
                                  .mProfileSelectStateFirst,
                            )
                          ],
                        ),
                        FutureBuilder(
                            future: futureDistrictList,
                            builder: (context, snapshot) {
                              List<String> districtList = snapshot.data !=
                                          null &&
                                      snapshot.data!.isNotEmpty &&
                                      selectedState.value.isNotEmpty
                                  ? ProfileTopSectionViewModel()
                                      .getDistrictNames(
                                          snapshot.data!, selectedState.value)
                                  : [];
                              return ValueListenableBuilder(
                                  valueListenable: selectedDistrict,
                                  builder: (BuildContext context,
                                      String district, Widget? child) {
                                    return SelectableField(
                                        value: district,
                                        placeholder:
                                            AppLocalizations.of(context)!
                                                .mProfileSelectDistrict,
                                        color: districtList.isEmpty
                                            ? AppColors.grey08
                                            : null,
                                        onTap: () => selectedState.value.isEmpty
                                            ? SearchHelper().showOverlayMessage(
                                                AppLocalizations.of(context)!
                                                    .mProfileDistrictDisable,
                                                context,
                                                duration: 3)
                                            : ProfileHelper()
                                                .showSearchableBottomSheet(
                                                    context: context,
                                                    items: districtList,
                                                    onItemSelected:
                                                        (String value) {
                                                      selectedDistrict.value =
                                                          value;
                                                      checkChanges();
                                                    }));
                                  });
                            }),
                        // Start Date
                        FieldNameWidget(
                          fieldName:
                              AppLocalizations.of(context)!.mProfileStartDate,
                        ),
                        DateWidget(
                            date: selectedStartDate,
                            endDate: selectedEndDate ?? DateTime.now(),
                            updateDate: (picked) => setState(() {
                                  selectedStartDate = picked;
                                  checkChanges();
                                })),
                        SizedBox(height: 8.w),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Checkbox(
                              focusNode: currentlyWorkingFocusNode,
                              side: BorderSide(
                                  width: 2,
                                  color: currentlyWorkingFocusNode.hasFocus
                                      ? AppColors.darkBlue
                                      : AppColors.greys60),
                              value: isCurrentlyWorking,
                              onChanged: (value) {
                                if (value != isCurrentlyWorking) {
                                  setState(() {
                                    isCurrentlyWorking = value ?? true;
                                    if (isCurrentlyWorking) {
                                      selectedEndDate = null;
                                    }
                                  });
                                  checkChanges();
                                }
                              },
                              fillColor: WidgetStatePropertyAll(
                                isCurrentlyWorking
                                    ? AppColors.darkBlue
                                    : AppColors.appBarBackground,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                  AppLocalizations.of(context)!
                                      .mProfileCurrentlyWorking,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(color: AppColors.greys)),
                            ),
                          ],
                        ),

                        // End Date
                        FieldNameWidget(
                          fieldName:
                              AppLocalizations.of(context)!.mProfileEndDate,
                        ),
                        DateWidget(
                            date: selectedEndDate,
                            startDate: selectedStartDate,
                            isDisabled: isCurrentlyWorking,
                            updateDate: (picked) => setState(() {
                                  selectedEndDate = picked;
                                  checkChanges();
                                })),
                        // Description
                        Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8).r,
                              child: Text(
                                AppLocalizations.of(context)!
                                    .mProfileDescription,
                                style: Theme.of(context).textTheme.displayLarge,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            TooltipWidget(
                              message: AppLocalizations.of(context)!
                                  .mProfileServiceDescriptionMsg,
                            )
                          ],
                        ),
                        SizedBox(height: 8.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              minLines: 8,
                              maxLines: 8,
                              maxLength: 1000,
                              controller: descriptionController,
                              onChanged: (value) {
                                if (value.isNotEmpty &&
                                    !(RegExpressions.alphabetWithDotCommaBracket
                                        .hasMatch(value))) {
                                  descriptionError.value =
                                      AppLocalizations.of(context)!
                                          .mProfileSpecialCharacterNotApplowed;
                                } else {
                                  descriptionError.value = null;
                                  checkChanges();
                                }
                              },
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge!
                                  .copyWith(color: AppColors.greys),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 2)
                                    .r,
                                hintText: AppLocalizations.of(context)!
                                    .mProfielAddYourDescription,
                                hintStyle:
                                    Theme.of(context).textTheme.labelLarge,
                                counterStyle: Theme.of(context)
                                    .textTheme
                                    .labelSmall!
                                    .copyWith(color: AppColors.grey40),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8).r,
                                  borderSide:
                                      BorderSide(color: AppColors.grey24),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8).r,
                                  borderSide:
                                      BorderSide(color: AppColors.grey24),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8).r,
                                  borderSide:
                                      BorderSide(color: AppColors.darkBlue),
                                ),
                              ),
                            ),
                            ValueListenableBuilder(
                                valueListenable: descriptionError,
                                builder: (context, errMsg, _) {
                                  return Visibility(
                                    visible: errMsg != null,
                                    child: Text(errMsg ?? '',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall!
                                            .copyWith(
                                                color:
                                                    AppColors.negativeLight)),
                                  );
                                })
                          ],
                        ),
                        SizedBox(
                          height: 50.w,
                        ),
                      ],
                    ),
                  )),
                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                        width: 0.8.sw,
                        child: ValueListenableBuilder(
                            valueListenable: isChanged,
                            builder: (BuildContext context, bool isChanged,
                                Widget? child) {
                              return ButtonWidgetV2(
                                text: widget.isUpdate
                                    ? AppLocalizations.of(context)!
                                        .mCommonupdate
                                    : AppLocalizations.of(context)!
                                        .mEditProfileAdd,
                                textColor: AppColors.appBarBackground,
                                // isLoading: savePressed,
                                bgColor: isChanged
                                    ? AppColors.darkBlue
                                    : AppColors.grey40,
                                onTap: isChanged
                                    ? () async {
                                        if (selectedOrg.value.isEmpty ||
                                            selectedDesignation.value.isEmpty) {
                                          if (selectedOrg.value.isEmpty) {
                                            orgError.value =
                                                AppLocalizations.of(context)!
                                                    .mProfilePleaseSelectOrg;
                                          }
                                          if (selectedDesignation
                                              .value.isEmpty) {
                                            designationError
                                                .value = AppLocalizations.of(
                                                    context)!
                                                .mProfileDesignationRequired;
                                          }
                                        } else if (descriptionError.value ==
                                                null &&
                                            orgError.value == null &&
                                            designationError.value == null) {
                                          widget.isUpdate
                                              ? await ProfileServiceHistoryViewModel().updateServiceHistory(
                                                  context,
                                                  orgName: selectedOrg.value != widget.orgName
                                                      ? selectedOrg.value
                                                      : '',
                                                  designation:
                                                      selectedDesignation.value !=
                                                              widget.designation
                                                          ? selectedDesignation
                                                              .value
                                                          : '',
                                                  state: selectedState.value != widget.state
                                                      ? selectedState.value
                                                      : '',
                                                  district: selectedDistrict.value != widget.district
                                                      ? selectedDistrict.value
                                                      : '',
                                                  startDate: ProfileServiceHistoryViewModel().isDateChanged(selectedStartDate, widget.startDate)
                                                      ? selectedStartDate!
                                                          .toIso8601String()
                                                      : '',
                                                  endDate: isCurrentlyWorking ||
                                                          selectedEndDate == null ||
                                                          (!isCurrentlyWorking && !ProfileServiceHistoryViewModel().isDateChanged(selectedEndDate, widget.endDate))
                                                      ? null
                                                      : selectedEndDate!.toIso8601String(),
                                                  currentlyWorking: isCurrentlyWorking != widget.currentlyWorking ? isCurrentlyWorking.toString() : null,
                                                  description: widget.description != descriptionController.text ? descriptionController.text : null,
                                                  uuid: widget.uuid ?? '',
                                                  orgLogo: orgLogo.isNotEmpty && orgLogo != widget.orgLogo ? orgLogo : '')
                                              : await ProfileServiceHistoryViewModel().addServiceHistory(context, orgName: selectedOrg.value, designation: selectedDesignation.value, state: selectedState.value, district: selectedDistrict.value, startDate: selectedStartDate != null ? selectedStartDate!.toIso8601String() : '', endDate: isCurrentlyWorking || selectedEndDate == null ? null : selectedEndDate!.toIso8601String(), currentlyWorking: isCurrentlyWorking.toString(), description: descriptionController.text, orgLogo: orgLogo);
                                          widget.updateCallback();
                                        }
                                      }
                                    : null,
                              );
                            })),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<List<String>> fetchDesignationWithOrgName(
      {required String orgName,
      required int offset,
      required String query}) async {
    OrganisationModel? orgData =
        ProfileServiceHistoryViewModel().getOrgByName(orgDataList, orgName);
    if (orgData != null && orgData.rootOrgId != null) {
      orgLogo = orgData.logo ?? '';
      return await ProfileServiceHistoryViewModel()
          .getDesignationByOrgName([orgData.rootOrgId!], designationOffset);
    } else {
      return [];
    }
  }

  Future<void> fetchData() async {
    if (!widget.currentlyWorking) {
      organizationList =
          await getOrgMasterList(orgOffset, widget.orgName ?? '');
      if (widget.orgName != null) {
        designationList = await fetchDesignationWithOrgName(
            orgName: widget.orgName!,
            offset: designationOffset,
            query: designationQueryText);
      }
    }
    futureStateList =
        Future.value(await widget.profileRepository.getStateList());
    if (widget.state != null && widget.state!.isNotEmpty) {
      futureDistrictList = Future.value(await fetchDistricts(widget.state!));
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<List<String>> getOrgMasterList(int orgOffset, String query) async {
    orgDataList = await ProfileServiceHistoryViewModel()
        .getOrganizationsList(offset: orgOffset, query: query);

    return ProfileServiceHistoryViewModel().getOrgNames(orgDataList);
  }

  void checkChanges() {
    isChanged.value = ((selectedOrg.value.isNotEmpty &&
            selectedOrg.value != widget.orgName) ||
        (selectedDesignation.value.isNotEmpty &&
            selectedDesignation.value != widget.designation) ||
        (selectedState.value.isNotEmpty &&
            selectedState.value != widget.state) ||
        (selectedDistrict.value.isNotEmpty &&
            selectedDistrict.value != widget.district) ||
        ProfileServiceHistoryViewModel()
            .isDateChanged(selectedStartDate, widget.startDate) ||
        ProfileServiceHistoryViewModel()
            .isDateChanged(selectedEndDate, widget.endDate) ||
        (descriptionController.text.isNotEmpty &&
            descriptionController.text != widget.description) ||
        isCurrentlyWorking != widget.currentlyWorking);
  }

  Future<List<DistrictModel>> fetchDistricts(String state) async {
    return await widget.profileRepository.getDistrictList(state);
  }
}
