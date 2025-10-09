import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/ui/widgets/_common/button_widget_v2.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/field_name_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../../../services/_services/profile_service.dart';
import '../../model/cadre_details_data_model.dart';
import 'dropdown_selection_key_value.dart';

class RequestForServicePopup extends StatefulWidget {
  final BuildContext parentContext;
  final List<CivilServiceTypeListData> civilServiceTypeList;
  const RequestForServicePopup(
      {Key? key,
      required this.parentContext,
      required this.civilServiceTypeList})
      : super(key: key);

  @override
  State<RequestForServicePopup> createState() => _RequestForServicePopupState();
}

class _RequestForServicePopupState extends State<RequestForServicePopup> {
  final ProfileService profileService = ProfileService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ValueNotifier<String> _service = ValueNotifier('');
  ValueNotifier<String> _cadreControllingAuthority = ValueNotifier('');
  ValueNotifier<CivilServiceTypeListData?> _selectedCivilServiceType =
      ValueNotifier(null);
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.only(left: 16, right: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
              color: AppColors.appBarBackground,
              borderRadius: BorderRadius.circular(12)),
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    AppLocalizations.of(widget.parentContext)!
                        .mStaticRequestToAddService,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                        fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
                SizedBox(height: 8),
                ValueListenableBuilder<CivilServiceTypeListData?>(
                    valueListenable: _selectedCivilServiceType,
                    builder: (BuildContext context,
                        CivilServiceTypeListData? selectedCivilServiceType,
                        Widget? child) {
                      return Column(
                        children: [
                          FieldNameWidget(
                              fieldName:
                                  AppLocalizations.of(widget.parentContext)!
                                      .mStaticTypeOfCivilService,
                              isMandatory: true),
                          DropDownSelectionKeyValue(
                              text: AppLocalizations.of(widget.parentContext)!
                                  .mStaticSelectFromDropdown,
                              options: widget.civilServiceTypeList,
                              selectedValue: selectedCivilServiceType,
                              onChanged: (value) {
                                _selectedCivilServiceType.value = value;
                              })
                        ],
                      );
                    }),
                FieldNameWidget(
                    fieldName: AppLocalizations.of(widget.parentContext)!
                        .mStaticService,
                    isMandatory: true),
                Container(
                    margin: EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      style: GoogleFonts.lato(fontSize: 14.0),
                      keyboardType: TextInputType.text,
                      onChanged: (value) => _service.value = value,
                      validator: (String? value) {
                        if ((value ?? '').isEmpty) {
                          return AppLocalizations.of(widget.parentContext)!
                              .mProfileServiceMandatory;
                        } else
                          return null;
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.appBarBackground,
                        contentPadding:
                            EdgeInsets.fromLTRB(16.0, 0.0, 20.0, 0.0),
                        border: const OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.grey16)),
                        hintText: AppLocalizations.of(widget.parentContext)!
                            .mCommonTypeHere,
                        hintStyle: GoogleFonts.lato(
                            color: AppColors.grey40,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: AppColors.darkBlue, width: 1.0),
                        ),
                      ),
                    )),
                FieldNameWidget(
                    fieldName: AppLocalizations.of(widget.parentContext)!
                        .mProfileCadreControllingAuthority),
                Container(
                    margin: EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      style: GoogleFonts.lato(fontSize: 14.0),
                      keyboardType: TextInputType.text,
                      onChanged: (value) =>
                          _cadreControllingAuthority.value = value,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.appBarBackground,
                        contentPadding:
                            EdgeInsets.fromLTRB(16.0, 0.0, 20.0, 0.0),
                        border: const OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.grey16)),
                        hintText: AppLocalizations.of(widget.parentContext)!
                            .mCommonTypeHere,
                        hintStyle: GoogleFonts.lato(
                            color: AppColors.grey40,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: AppColors.darkBlue, width: 1.0),
                        ),
                      ),
                    )),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ButtonWidgetV2(
                      text: AppLocalizations.of(widget.parentContext)!
                          .mStaticCancel,
                      textColor: AppColors.darkBlue,
                      borderColor: AppColors.darkBlue,
                      bgColor: Colors.transparent,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    ValueListenableBuilder(
                        valueListenable: _selectedCivilServiceType,
                        builder: (BuildContext ctx,
                            CivilServiceTypeListData? civilServiceType,
                            Widget? child) {
                          return ButtonWidgetV2(
                            text: AppLocalizations.of(widget.parentContext)!
                                .mStaticSubmit,
                            textColor: AppColors.appBarBackground,
                            bgColor: (civilServiceType != null)
                                ? AppColors.darkBlue
                                : AppColors.grey40,
                            onTap: (civilServiceType != null)
                                ? () => _submitRequest(ctx)
                                : null,
                          );
                        })
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _submitRequest(BuildContext ctx) async {
    if (_formKey.currentState!.validate()) {
      try {
        await Provider.of<ProfileRepository>(widget.parentContext,
                listen: false)
            .requestForService(
                context: widget.parentContext,
                typeOfCivilService: _selectedCivilServiceType.value?.id ?? '',
                service: _service.value,
                cadreControllingAuthority: _cadreControllingAuthority.value);
      } catch (e) {
      } finally {
        Navigator.of(context).pop();
      }
    }
  }
}
