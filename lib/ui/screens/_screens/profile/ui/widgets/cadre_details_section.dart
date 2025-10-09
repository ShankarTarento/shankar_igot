import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/request_for_service_popup.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/dropdown_selection.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/utils/profile_constants.dart';
import 'package:karmayogi_mobile/util/edit_profile_mandatory_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../../../constants/_constants/color_constants.dart';
import '../../../../../../localization/_langs/english_lang.dart';
import '../../model/profile_model.dart';
import '../../../../../../respositories/_respositories/profile_repository.dart';
import '../../../../../../util/helper.dart';
import '../../model/cadre_details_data_model.dart';
import 'field_name_widget.dart';
import 'dropdown_selection_key_value.dart';

class CadreDetailsSection extends StatefulWidget {
  final CivilServiceTypeData? civilServiceType;
  final ValueNotifier<dynamic>? cadreSectionValueNotifier;
  final Function checkForChangesCallback;
  final bool isMandatory;
  final TextStyle? fieldTheme;
  final IconData icon;
  final Color iconColor;
  const CadreDetailsSection(
      {Key? key,
      this.civilServiceType,
      this.isMandatory = false,
      this.cadreSectionValueNotifier,
      required this.checkForChangesCallback,
      this.fieldTheme,
      this.icon = Icons.keyboard_arrow_down_sharp,
      this.iconColor = AppColors.grey40})
      : super(key: key);

  @override
  State<CadreDetailsSection> createState() => _CadreDetailsSectionState();
}

class _CadreDetailsSectionState extends State<CadreDetailsSection> {
  ValueNotifier<String> _selectedCadreType = ValueNotifier('');

  CivilServiceTypeData? _civilServiceType;
  ValueNotifier<CivilServiceTypeListData?> _selectedCivilServiceType =
      ValueNotifier(null);
  ValueNotifier<ServiceListData?> _selectedServiceType = ValueNotifier(null);
  ValueNotifier<CadreListData?> _selectedCadre = ValueNotifier(null);
  ValueNotifier<String?> _selectedBatch = ValueNotifier(null);

  String _cadreControllingAuthority = '';

  Map<dynamic, dynamic> cadreData = {};

  ValueNotifier<bool> _selectedCentralDeputation = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() {
    _civilServiceType = widget.civilServiceType;
    _populateFields();
  }

  void _populateFields() async {
    Profile? profileDetails =
        Provider.of<ProfileRepository>(context, listen: false).profileDetails;
    dynamic cadreDetails = profileDetails?.cadreDetails;
    if (cadreDetails != null) {
      if (cadreDetails['civilServiceTypeId'] != null &&
          (cadreDetails['civilServiceTypeId'] ?? '') != '') {
        _selectedCadreType.value = Helper.capitalize(EnglishLang.yes);

        CivilServiceTypeListData? civilServiceTypeListData;
        try {
          civilServiceTypeListData = _civilServiceType?.civilServiceTypeList?.firstWhere(
                (service) => service.id == cadreDetails['civilServiceTypeId'],
          );
        } catch (e) {civilServiceTypeListData = null;}
        if (civilServiceTypeListData == null) return;

        ServiceListData? service;
        try {
          service = civilServiceTypeListData.serviceList?.firstWhere(
                (service) => service.id == cadreDetails['civilServiceId'],
          );
        } catch (e) {service = null;}
        if (service == null) return;

        _selectedCivilServiceType.value = civilServiceTypeListData;
        _selectedServiceType.value = service;

        if ((service.cadreList ?? []).isNotEmpty) {
          final cadre = service.cadreList
              ?.firstWhere((cadre) => cadre.id == cadreDetails['cadreId']);
          _selectedCadre.value = cadre;
        }

        _selectedBatch.value = cadreDetails['cadreBatch'].toString();
        _cadreControllingAuthority =
            cadreDetails['cadreControllingAuthorityName'];

        _selectedCentralDeputation.value = (cadreDetails['isOnCentralDeputation'] is bool)
            ? cadreDetails['isOnCentralDeputation']
            : false;

        cadreData = {};
        cadreData['cadreEmployee'] = _selectedCadreType.value;
        cadreData['civilServiceTypeId'] = _selectedCivilServiceType.value?.id;
        cadreData['civilServiceType'] = _selectedCivilServiceType.value?.name;
        cadreData['civilServiceId'] = _selectedServiceType.value?.id;
        cadreData['civilServiceName'] = _selectedServiceType.value?.name;
        cadreData['cadreId'] = _selectedCadre.value?.id;
        cadreData['cadreName'] = _selectedCadre.value?.name;
        cadreData['cadreBatch'] = int.parse(_selectedBatch.value ?? '0');
        if (_cadreControllingAuthority != '')
          cadreData['cadreControllingAuthorityName'] =
              _cadreControllingAuthority;
        cadreData['isOnCentralDeputation'] = _selectedCentralDeputation.value;
        widget.cadreSectionValueNotifier?.value = cadreData;
      } else {
        _selectedCadreType.value = Helper.capitalize(EnglishLang.no);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8).w,
      child: Column(
        children: [
          FieldNameWidget(
              isMandatory: widget.isMandatory,
              fieldName:
                  AppLocalizations.of(context)!.mAreYouFromOrganizedService,
              fieldTheme: widget.fieldTheme),
          ValueListenableBuilder(
              valueListenable: _selectedCadreType,
              builder: (BuildContext context, String selectedCategory,
                  Widget? child) {
                return Container(
                  margin: EdgeInsets.only(top: 8.0, bottom: 8).r,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(63).r,
                      border: Border.all(color: AppColors.grey24)),
                  child: DropDownSelection(
                      options: EditProfileMandatoryHelper.cadreRadio,
                      selectedValue: selectedCategory,
                      icon: widget.icon,
                      iconColor: widget.iconColor,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.r),
                          borderSide: BorderSide(color: Colors.transparent)),
                      padding: EdgeInsets.zero,
                      onChanged: (value) {
                        _selectedCadreType.value = value!;
                        _selectedCivilServiceType.value = null;
                        _selectedServiceType.value = null;
                        _selectedCadre.value = null;
                        _selectedBatch.value = null;
                        _cadreControllingAuthority = '';
                        _selectedCentralDeputation.value = false;

                        cadreData = {};
                        cadreData['cadreEmployee'] = _selectedCadreType.value;
                        widget.cadreSectionValueNotifier?.value = cadreData;
                        widget.checkForChangesCallback();
                      }),
                );
              }),

          ///civil Service Type
          ValueListenableBuilder<String>(
            valueListenable: _selectedCadreType,
            builder: (context, selectedCadreValue, child) {
              if (selectedCadreValue.toString().toLowerCase() !=
                  EnglishLang.yes.toString().toLowerCase()) return Container();

              return ValueListenableBuilder<CivilServiceTypeListData?>(
                  valueListenable: _selectedCivilServiceType,
                  builder: (BuildContext context,
                      CivilServiceTypeListData? selectedCivilServiceType,
                      Widget? child) {
                    return Column(
                      children: [
                        FieldNameWidget(
                            fieldName: AppLocalizations.of(context)!
                                .mStaticTypeOfCivilService,
                            isMandatory: true),
                        DropDownSelectionKeyValue(
                            text: AppLocalizations.of(context)!
                                .mStaticSelectFromDropdown,
                            options:
                                _civilServiceType?.civilServiceTypeList ?? [],
                            selectedValue: selectedCivilServiceType,
                            icon: widget.icon,
                            iconColor: widget.iconColor,
                            borderRadius: 64,
                            onChanged: (value) {
                              _selectedCivilServiceType.value = value;
                              _selectedServiceType.value = null;
                              _selectedCadre.value = null;
                              _selectedBatch.value = null;
                              _cadreControllingAuthority = '';
                              _selectedCentralDeputation.value = false;

                              cadreData = {};
                              cadreData['cadreEmployee'] =
                                  _selectedCadreType.value;
                              cadreData['civilServiceTypeId'] =
                                  _selectedCivilServiceType.value?.id;
                              cadreData['civilServiceType'] =
                                  _selectedCivilServiceType.value?.name;
                              widget.cadreSectionValueNotifier?.value =
                                  cadreData;
                              widget.checkForChangesCallback();
                            })
                      ],
                    );
                  });
            },
          ),

          ///Service Type
          ValueListenableBuilder<CivilServiceTypeListData?>(
            valueListenable: _selectedCivilServiceType,
            builder: (context, selectedCivilServiceType, child) {
              if (selectedCivilServiceType == null) return Container();

              return ValueListenableBuilder<ServiceListData?>(
                  valueListenable: _selectedServiceType,
                  builder: (BuildContext context,
                      ServiceListData? serviceListData, Widget? child) {
                    return Column(
                      children: [
                        FieldNameWidget(
                            fieldName:
                                AppLocalizations.of(context)!.mStaticService,
                            isMandatory: true),
                        DropDownSelectionKeyValue(
                            text: AppLocalizations.of(context)!
                                .mStaticSelectFromDropdown,
                            options:
                                _selectedCivilServiceType.value?.serviceList ??
                                    [],
                            selectedValue: serviceListData,
                            icon: widget.icon,
                            iconColor: widget.iconColor,
                            borderRadius: 64,
                            onChanged: (value) {
                              _selectedServiceType.value = value;
                              _cadreControllingAuthority = _selectedServiceType
                                      .value?.cadreControllingAuthority ??
                                  '';
                              _selectedCadre.value = null;
                              _selectedBatch.value = null;
                              _selectedCentralDeputation.value = false;

                              cadreData = {};
                              cadreData['cadreEmployee'] =
                                  _selectedCadreType.value;
                              cadreData['civilServiceTypeId'] =
                                  _selectedCivilServiceType.value?.id;
                              cadreData['civilServiceType'] =
                                  _selectedCivilServiceType.value?.name;
                              cadreData['civilServiceId'] =
                                  _selectedServiceType.value?.id;
                              cadreData['civilServiceName'] =
                                  _selectedServiceType.value?.name;
                              widget.cadreSectionValueNotifier?.value =
                                  cadreData;
                              widget.checkForChangesCallback();
                            }),
                        // requestForService()
                      ],
                    );
                  });
            },
          ),

          ///cadre
          ValueListenableBuilder<ServiceListData?>(
            valueListenable: _selectedServiceType,
            builder: (context, selectedServiceType, child) {
              if (selectedServiceType == null ||
                  (_selectedServiceType.value?.cadreList ?? []).isEmpty)
                return Container();

              return ValueListenableBuilder<CadreListData?>(
                  valueListenable: _selectedCadre,
                  builder: (BuildContext context, CadreListData? cadreListData,
                      Widget? child) {
                    return Column(
                      children: [
                        FieldNameWidget(
                            fieldName:
                                AppLocalizations.of(context)!.mProfileCadre,
                            isMandatory: true),
                        DropDownSelectionKeyValue(
                            text: AppLocalizations.of(context)!
                                .mStaticSelectFromDropdown,
                            options:
                                _selectedServiceType.value?.cadreList ?? [],
                            selectedValue: cadreListData,
                            icon: widget.icon,
                            iconColor: widget.iconColor,
                            borderRadius: 64,
                            onChanged: (value) {
                              _selectedCadre.value = value;
                              _selectedBatch.value = null;
                              _selectedCentralDeputation.value = false;

                              cadreData = {};
                              cadreData['cadreEmployee'] =
                                  _selectedCadreType.value;
                              cadreData['civilServiceTypeId'] =
                                  _selectedCivilServiceType.value?.id;
                              cadreData['civilServiceType'] =
                                  _selectedCivilServiceType.value?.name;
                              cadreData['civilServiceId'] =
                                  _selectedServiceType.value?.id;
                              cadreData['civilServiceName'] =
                                  _selectedServiceType.value?.name;
                              cadreData['cadreId'] = _selectedCadre.value?.id;
                              cadreData['cadreName'] =
                                  _selectedCadre.value?.name;
                              widget.cadreSectionValueNotifier?.value =
                                  cadreData;
                              widget.checkForChangesCallback();
                            })
                      ],
                    );
                  });
            },
          ),

          ///Batch
          ValueListenableBuilder<ServiceListData?>(
            valueListenable: _selectedServiceType,
            builder: (context, selectedServiceType, child) {
              if (selectedServiceType == null ||
                  (_selectedServiceType.value?.cadreList ?? []).isNotEmpty)
                return Container();
              return ValueListenableBuilder<dynamic>(
                valueListenable: _selectedServiceType,
                builder: (context, selectedCadre, child) {
                  if (selectedCadre == null) return Container();
                  List<int> allBatch = List<int>.generate(
                      (_selectedServiceType.value!.endBatchYear!) -
                          (_selectedServiceType.value!.startBatchYear!) +
                          1,
                      (index) =>
                          _selectedServiceType.value!.startBatchYear! + index);
                  List<int> filteredBatch = allBatch
                      .where((year) =>
                          !(_selectedServiceType.value?.exclusionYearList ?? [])
                              .contains(year))
                      .toList();
                  List<String> cadreBatchList =
                      filteredBatch.map((year) => year.toString()).toList();

                  return batchWidget(cadreBatchList);
                },
              );
            },
          ),

          ValueListenableBuilder<dynamic>(
            valueListenable: _selectedCadre,
            builder: (context, selectedCadre, child) {
              if (selectedCadre == null ||
                  (_selectedServiceType.value?.cadreList ?? []).isEmpty)
                return Container();
              List<int> allBatch = List<int>.generate(
                  (_selectedCadre.value!.endBatchYear!) -
                      (_selectedCadre.value!.startBatchYear!) +
                      1,
                  (index) => _selectedCadre.value!.startBatchYear! + index);
              List<int> filteredBatch = allBatch
                  .where((year) =>
                      !(_selectedCadre.value?.exclusionYearList ?? [])
                          .contains(year))
                  .toList();
              List<String> cadreBatchList =
                  filteredBatch.map((year) => year.toString()).toList();
              return batchWidget(cadreBatchList);
            },
          ),

          ///Cadre Controlling Authority
          ValueListenableBuilder<String?>(
            valueListenable: _selectedBatch,
            builder: (context, selectedExclusionYear, child) {
              if (selectedExclusionYear == null) return Container();

              return (_cadreControllingAuthority != '')
                  ? Column(
                      children: [
                        FieldNameWidget(
                            fieldName: AppLocalizations.of(context)!
                                .mProfileCadreControllingAuthority,
                            isMandatory: true),
                        valueWidget(_cadreControllingAuthority),
                      ],
                    )
                  : SizedBox.shrink();
            },
          ),

          ///Central Deputation
          ValueListenableBuilder<String?>(
            valueListenable: _selectedBatch,
            builder: (context, selectedExclusionYear, child) {
              if (selectedExclusionYear == null ||
                  !CadreConstants.centralDeputationCivilServicesId.contains((_selectedCivilServiceType.value?.id ?? '').trim()) ||
                  (_selectedCadre.value == null)) {
                return SizedBox.shrink();
              }
              return ValueListenableBuilder<bool?>(
                  valueListenable: _selectedCentralDeputation,
                  builder: (BuildContext context, bool? isOnCentralDeputation, Widget? child) {
                    return Column(
                      children: [
                        FieldNameWidget(
                            fieldName:
                            AppLocalizations.of(context)!.mProfileCentralDeputation,
                            isMandatory: true),
                        Container(
                          margin: EdgeInsets.only(top: 8.0, bottom: 8).r,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(63).r,
                              border: Border.all(color: AppColors.grey24)),
                          child: DropDownSelection(
                              options: EditProfileMandatoryHelper.cadreRadio,
                              selectedValue: isOnCentralDeputation ?? false ?
                              Helper.capitalize(EnglishLang.yes) :
                              Helper.capitalize(EnglishLang.no),
                              icon: widget.icon,
                              iconColor: widget.iconColor,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.r),
                                  borderSide: BorderSide(color: Colors.transparent)),
                              padding: EdgeInsets.zero,
                              onChanged: (value) {
                                _selectedCentralDeputation.value = value.toString().toLowerCase() == EnglishLang.yes.toLowerCase();
                                cadreData = {};
                                cadreData['cadreEmployee'] = _selectedCadreType.value;
                                cadreData['civilServiceTypeId'] =
                                    _selectedCivilServiceType.value?.id;
                                cadreData['civilServiceType'] =
                                    _selectedCivilServiceType.value?.name;
                                cadreData['civilServiceId'] =
                                    _selectedServiceType.value?.id;
                                cadreData['civilServiceName'] =
                                    _selectedServiceType.value?.name;
                                cadreData['cadreId'] = _selectedCadre.value?.id;
                                cadreData['cadreName'] = _selectedCadre.value?.name;
                                cadreData['cadreBatch'] = int.parse(_selectedBatch.value ?? '0');
                                if (_cadreControllingAuthority != '')
                                  cadreData['cadreControllingAuthorityName'] = _cadreControllingAuthority;
                                cadreData['isOnCentralDeputation'] = _selectedCentralDeputation.value;
                                widget.cadreSectionValueNotifier?.value = cadreData;
                                widget.checkForChangesCallback();

                              }),
                        )
                      ],
                    );
                  });
            },
          ),
        ],
      ),
    );
  }

  Widget batchWidget(List<String> cadreBatchList) {
    return ValueListenableBuilder<String?>(
        valueListenable: _selectedBatch,
        builder: (BuildContext context, String? batch, Widget? child) {
          return Column(
            children: [
              FieldNameWidget(
                  fieldName: AppLocalizations.of(context)!.mStaticBatch,
                  isMandatory: true),
              Container(
                margin: EdgeInsets.only(top: 8.0, bottom: 8).r,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(63).r,
                    border: Border.all(color: AppColors.grey24)),
                child: DropDownSelection(
                    options: cadreBatchList,
                    selectedValue: batch,
                    icon: widget.icon,
                    iconColor: widget.iconColor,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.r),
                        borderSide: BorderSide(color: Colors.transparent)),
                    padding: EdgeInsets.zero,
                    onChanged: (value) {
                      _selectedBatch.value = value;
                      _selectedCentralDeputation.value = false;

                      cadreData = {};
                      cadreData['cadreEmployee'] = _selectedCadreType.value;
                      cadreData['civilServiceTypeId'] =
                          _selectedCivilServiceType.value?.id;
                      cadreData['civilServiceType'] =
                          _selectedCivilServiceType.value?.name;
                      cadreData['civilServiceId'] =
                          _selectedServiceType.value?.id;
                      cadreData['civilServiceName'] =
                          _selectedServiceType.value?.name;
                      cadreData['cadreId'] = _selectedCadre.value?.id;
                      cadreData['cadreName'] = _selectedCadre.value?.name;
                      cadreData['cadreBatch'] =
                          int.parse(_selectedBatch.value ?? '0');
                      if (_cadreControllingAuthority != '')
                        cadreData['cadreControllingAuthorityName'] =
                            _cadreControllingAuthority;
                      widget.cadreSectionValueNotifier?.value = cadreData;
                      widget.checkForChangesCallback();
                    }),
              )
            ],
          );
        });
  }

  Widget valueWidget(String value) {
    return Container(
        width: double.maxFinite,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16).r,
        margin: EdgeInsets.only(top: 8).r,
        decoration: BoxDecoration(
            color: AppColors.grey16,
            borderRadius: BorderRadius.all(Radius.circular(4).r)),
        child: Text(
          value,
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(fontWeight: FontWeight.w400, fontSize: 14.sp),
        ));
  }

  Widget requestForService() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8).w,
      alignment: Alignment.centerRight,
      child: InkWell(
        onTap: () => showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext ctx) {
              return RequestForServicePopup(
                parentContext: context,
                civilServiceTypeList:
                    _civilServiceType?.civilServiceTypeList ?? [],
              );
            }),
        child: Text(
          AppLocalizations.of(context)!.mStaticRequestForService,
          style: GoogleFonts.lato(
            color: AppColors.darkBlue,
            fontWeight: FontWeight.w700,
            fontSize: 12.sp,
          ),
        ),
      ),
    );
  }
}
