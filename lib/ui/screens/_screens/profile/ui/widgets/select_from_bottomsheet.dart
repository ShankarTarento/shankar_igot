import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_models/language_model.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/sign_up/field_request_page.dart';
import 'package:karmayogi_mobile/util/edit_profile_mandatory_helper.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SelectFromBottomSheet extends StatefulWidget {
  final TextEditingController controller;
  final String fieldName;
  final bool isInReview;
  final String? selected;
  final String? degreeType;
  final Function(String value)? onSelected;
  final String? Function(String?)? validator;
  final VoidCallback callBack;
  final BuildContext parentContext;
  final bool showDefaultTextStyle;
  final bool isOrgBasedDesignation;
  final bool isFocused;
  final ValueChanged<String>? changeFocus;
  final bool isCadreProgram;
  final OutlineInputBorder? customBorder;
  final double? customFieldHeight;
  final Color? suffixIconColor;
  const SelectFromBottomSheet(
      {Key? key,
      required this.controller,
      required this.fieldName,
      this.isInReview = false,
      this.selected,
      this.onSelected,
      this.degreeType,
      this.validator,
      required this.callBack,
      required this.parentContext,
      this.showDefaultTextStyle = false,
      this.isOrgBasedDesignation = false,
      this.isFocused = false,
      this.isCadreProgram = false,
      this.changeFocus,
      this.customBorder,
      this.customFieldHeight,
      this.suffixIconColor})
      : super(key: key);

  @override
  State<SelectFromBottomSheet> createState() => SelectFromBottomSheetState();
}

class SelectFromBottomSheetState extends State<SelectFromBottomSheet> {
  TextEditingController? _searchController = TextEditingController();
  ValueNotifier<List<dynamic>> _filteredItems = ValueNotifier([]);
  ValueNotifier<bool> _isLoading = ValueNotifier(false);
  final FocusNode fieldFocus = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.isFocused) {
      FocusScope.of(context).requestFocus(fieldFocus);
    }
  }

  @override
  void didUpdateWidget(SelectFromBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFocused != widget.isFocused) {
      if (widget.isFocused) {
        FocusScope.of(context).requestFocus(fieldFocus);
      } else {
        fieldFocus.unfocus();
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _searchController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Tooltip(
          message: widget.isInReview
              ? AppLocalizations.of(widget.parentContext)!
                  .mProfileUnderReviewInfo
              : '',
          triggerMode: TooltipTriggerMode.tap,
          child: Container(
            padding: EdgeInsets.only(top: 8).r,
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4).r,
            ),
            child: widget.fieldName == EnglishLang.degres
                ? InkWell(
                    onTap: _isLoading.value
                        ? null
                        : () async {
                            _searchController?.clear();
                            _isLoading.value = true;
                            await _showListOfOptions(context, widget.fieldName);
                          },
                    child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.appBarBackground,
                          borderRadius:
                              BorderRadius.all(const Radius.circular(4.0)).r,
                          border: Border.all(color: AppColors.grey16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                                  left: 16, top: 16, bottom: 16)
                              .r,
                          child: Text(
                            widget.selected ?? "",
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14.sp,
                                ),
                          ),
                        )),
                  )
                : Focus(
                    child: Container(
                      height: widget.customFieldHeight,
                      child: TextFormField(
                        key: Key('FormField${widget.fieldName}'),
                        focusNode: fieldFocus,
                        readOnly: true,
                        scrollController: ScrollController(),
                        onTap: widget.isInReview || _isLoading.value
                            ? null
                            : () async {
                                _searchController?.clear();
                                _isLoading.value = true;
                                await _showListOfOptions(
                                    context, widget.fieldName);
                              },
                        textInputAction: TextInputAction.next,
                        controller: widget.controller,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          String? data = widget.validator != null
                              ? widget.validator!(value)
                              : null;
                          return data;
                        },
                        style: widget.showDefaultTextStyle
                            ? TextStyle(fontSize: 14.0.sp)
                            : Theme.of(context).textTheme.bodyMedium,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.appBarBackground,
                          contentPadding:
                              EdgeInsets.fromLTRB(16.0, 14.0, 0.0, 14.0).r,
                          border:
                              widget.customBorder ?? const OutlineInputBorder(),
                          enabled: !widget.isInReview,
                          enabledBorder: widget.customBorder ??
                              OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: AppColors.grey16)),
                          hintText: AppLocalizations.of(widget.parentContext)!
                              .mStaticSelectHere,
                          hintStyle: TextStyle(
                              color: AppColors.grey40,
                              fontSize: 14.0.sp,
                              fontWeight: FontWeight.w400),
                          suffixIcon: Icon(Icons.arrow_drop_down,
                              color: widget.isFocused
                                  ? AppColors.darkBlue
                                  : widget.suffixIconColor ?? AppColors.grey40),
                          disabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.grey16)),
                          focusedBorder: widget.customBorder ??
                              OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: AppColors.darkBlue, width: 1.0),
                              ),
                        ),
                      ),
                    ),
                  ),
          ),
        ),
        ValueListenableBuilder(
            valueListenable: _isLoading,
            builder: (BuildContext context, bool isLoading, Widget? child) {
              return isLoading
                  ? Padding(
                      padding: const EdgeInsets.all(2).r,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(10).r,
                          child: LinearProgressIndicator()),
                    )
                  : SizedBox();
            }),
      ],
    );
  }

  Widget _options(String listType, dynamic item) {
    Color _color;
    switch (listType) {
      case EnglishLang.group:
        _color = widget.controller.text == item.name
            ? AppColors.lightSelected
            : AppColors.appBarBackground;
        break;
      case EnglishLang.nationality:
        _color = widget.controller.text == item.country
            ? AppColors.lightSelected
            : AppColors.appBarBackground;
        break;
      case EnglishLang.location:
        _color = widget.controller.text == item.country
            ? AppColors.lightSelected
            : AppColors.appBarBackground;
        break;
      default:
        _color = widget.controller.text == item
            ? AppColors.lightSelected
            : AppColors.appBarBackground;
    }
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16).r,
      child: Container(
          decoration: BoxDecoration(
            color: _color,
            borderRadius: BorderRadius.all(Radius.circular(4)).r,
          ),
          // height: 52,
          child: Padding(
            padding:
                const EdgeInsets.only(top: 7, bottom: 7, left: 12, right: 4).r,
            child: Text(
              listType == EnglishLang.group
                  ? item.name
                  : (listType == EnglishLang.nationality ||
                          listType == EnglishLang.location)
                      ? item.country
                      : item,
              style: widget.showDefaultTextStyle
                  ? TextStyle(
                      color: AppColors.greys87,
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp,
                      letterSpacing: 0.25,
                      height: 1.5.w,
                    )
                  : GoogleFonts.lato(
                      color: AppColors.greys87,
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp,
                      letterSpacing: 0.25,
                      height: 1.5.w,
                    ),
            ),
          )),
    );
  }

  void setListItem(String listType, dynamic item) {
    switch (listType) {
      case EnglishLang.group:
        widget.controller.text = item.name;
        break;
      case EnglishLang.nationality:
        widget.controller.text = item.country;
        break;
      case EnglishLang.location:
        widget.controller.text = item.country;
        break;
      case EnglishLang.degres:
        widget.onSelected!(item);
        break;
      default:
        widget.controller.text = item;
        break;
    }
    widget.callBack();
  }

  void _filterItems(List items, String value,
      {bool isGroup = false, bool isNationalities = false}) {
    _filteredItems.value = items
        .where((item) => (isGroup
                ? item.name
                : isNationalities
                    ? item.country
                    : item)
            .toLowerCase()
            .contains(value.toLowerCase()))
        .toList();
  }

  Future _showListOfOptions(contextMain, String listType,
      {int offset = 0, String query = ''}) async {
    List<dynamic> items = [];
    switch (listType) {
      case EnglishLang.group:
        items =
            await EditProfileMandatoryHelper().getGroups(widget.parentContext);
        break;
      case EnglishLang.designation:
        if (widget.isOrgBasedDesignation) {
          items = Provider.of<ProfileRepository>(context, listen: false)
              .orgLevelDesignationsList;
        } else {
          items = await EditProfileMandatoryHelper()
              .getDesignations(widget.parentContext, offset, query);
        }
        if (widget.isCadreProgram && !items.contains('OTHERS')) {
          items.add('OTHERS');
        }
        break;
      case EnglishLang.nationality:
        items = Provider.of<ProfileRepository>(context, listen: false)
            .nationalities;
        break;
      case EnglishLang.location:
        items = Provider.of<ProfileRepository>(context, listen: false)
            .nationalities;
        break;
      case EnglishLang.organisationName:
        items = await Provider.of<ProfileRepository>(widget.parentContext,
                listen: false)
            .getOrganisations();
        items = items.map((item) => item.toString()).toList();
        items.sort((a, b) => a.toUpperCase().compareTo(b.toUpperCase()));
        break;
      case EnglishLang.industry:
        items = await Provider.of<ProfileRepository>(context, listen: false)
            .getIndustries();
        break;
      case EnglishLang.payBand:
        items = await Provider.of<ProfileRepository>(context, listen: false)
            .getGradePay();
        items.sort(((a, b) => int.parse(a).compareTo(int.parse(b))));
        break;
      case EnglishLang.service:
        items = await Provider.of<ProfileRepository>(context, listen: false)
            .getServices();
        break;
      case EnglishLang.cadre:
        items = await Provider.of<ProfileRepository>(context, listen: false)
            .getCadre();
        break;
      case EnglishLang.degres:
        items = await Provider.of<ProfileRepository>(context, listen: false)
            .getDegrees(widget.degreeType);
        break;
      case EnglishLang.languages:
        List<Language> languages =
            await Provider.of<ProfileRepository>(context, listen: false)
                .getLanguages();
        items = languages.map((item) => item.language).toList();
        break;
    }
    _filterItems(items, '',
        isGroup: listType == EnglishLang.group,
        isNationalities: listType == EnglishLang.nationality ||
            listType == EnglishLang.location);
    _isLoading.value = false;
    return showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8), topRight: Radius.circular(8))
              .r,
          side: BorderSide(
            color: AppColors.grey08,
          ),
        ),
        context: context,
        builder: (context) => StatefulBuilder(builder: (context, setState) {
              return SingleChildScrollView(
                child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.appBarBackground,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ).r,
                    ),
                    width: double.infinity.w,
                    child: Container(
                      margin: EdgeInsets.only(top: 10).r,
                      color: AppColors.appBarBackground,
                      child: Material(
                          color: AppColors.appBarBackground,
                          child: Column(children: [
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                margin: EdgeInsets.only(bottom: 16).r,
                                height: 6.w,
                                width: 0.25.sw,
                                decoration: BoxDecoration(
                                  color: AppColors.grey16,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16)).r,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(left: 20).r,
                              color: AppColors.appBarBackground,
                              child: Row(
                                children: [
                                  Container(
                                    color: AppColors.appBarBackground,
                                    width: 0.65.sw,
                                    height: 48.w,
                                    child: TextFormField(
                                        onChanged: (value) {
                                          _filterItems(items, value,
                                              isGroup:
                                                  listType == EnglishLang.group,
                                              isNationalities: listType ==
                                                      EnglishLang.nationality ||
                                                  listType ==
                                                      EnglishLang.nationality);
                                        },
                                        controller: _searchController,
                                        keyboardType: TextInputType.text,
                                        textInputAction: TextInputAction.done,
                                        style:
                                            GoogleFonts.lato(fontSize: 14.0.sp),
                                        decoration: InputDecoration(
                                          prefixIcon: Icon(Icons.search),
                                          contentPadding: EdgeInsets.fromLTRB(
                                                  16.0, 14.0, 0.0, 10.0)
                                              .r,
                                          hintText: AppLocalizations.of(
                                                  widget.parentContext)!
                                              .mStaticSearch,
                                          hintStyle: Theme.of(context)
                                              .textTheme
                                              .headlineSmall!
                                              .copyWith(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14.sp,
                                              ),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.transparent),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: AppColors.darkBlue,
                                                width: 1.0),
                                          ),
                                          counterStyle: TextStyle(
                                            height: double.minPositive,
                                          ),
                                          counterText: '',
                                        )),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16).r,
                                    child: Container(
                                        width: 48.w,
                                        height: 48.w,
                                        decoration: BoxDecoration(
                                          color: AppColors.appBarBackground,
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.of(context).pop(false);
                                            _searchController?.text = '';
                                            SystemChannels.textInput
                                                .invokeMethod('TextInput.hide');
                                          },
                                          child: Icon(
                                            Icons.clear,
                                            color: AppColors.greys60,
                                            size: 24.sp,
                                          ),
                                        )),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              color: AppColors.appBarBackground,
                              height: 8.w,
                            ),
                            Divider(
                              height: 1.w,
                              thickness: 1.w,
                              color: AppColors.grey08,
                            ),
                            ValueListenableBuilder(
                                valueListenable: _filteredItems,
                                builder: (BuildContext context,
                                    List<dynamic> filteredItems,
                                    Widget? child) {
                                  return Container(
                                      color: AppColors.appBarBackground,
                                      padding: const EdgeInsets.only(top: 10).r,
                                      height: 1.sh *
                                          (filteredItems.length > 0
                                              ? 0.685
                                              : 0.6),
                                      child: filteredItems.length > 0
                                          ? ListView.builder(
                                              key: Key(
                                                  'OptionListView${widget.fieldName}'),
                                              shrinkWrap: true,
                                              itemCount: filteredItems.length,
                                              itemBuilder: (BuildContext
                                                          context,
                                                      index) =>
                                                  InkWell(
                                                      key: Key('OptionList'),
                                                      onTap: () {
                                                        setListItem(
                                                            listType,
                                                            filteredItems[
                                                                index]);

                                                        if (widget
                                                                .changeFocus !=
                                                            null) {
                                                          fieldFocus.unfocus();
                                                          if (widget
                                                                  .fieldName ==
                                                              EnglishLang
                                                                  .designation) {
                                                            widget.changeFocus!(
                                                                EnglishLang
                                                                    .group);
                                                          }
                                                        }
                                                        Navigator.of(context)
                                                            .pop(false);
                                                      },
                                                      child: _options(
                                                          listType,
                                                          filteredItems[
                                                              index])))
                                          : Padding(
                                              padding:
                                                  const EdgeInsets.all(32.0).r,
                                              child: Column(
                                                children: [
                                                  Text(
                                                    EnglishLang
                                                        .noResultFromSearch,
                                                    textAlign: TextAlign.center,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headlineSmall!
                                                        .copyWith(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          height: 1.5.w,
                                                          letterSpacing: 0.25.r,
                                                        ),
                                                  ),
                                                  Visibility(
                                                    // Make it true to request for designation option if there are no results found for designation
                                                    visible: false,
                                                    child: TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                          Navigator.of(context).push(
                                                              MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      Consumer<
                                                                          ProfileRepository>(builder: (BuildContext
                                                                              context,
                                                                          ProfileRepository
                                                                              profileRepository,
                                                                          Widget?
                                                                              child) {
                                                                        dynamic
                                                                            personalData =
                                                                            profileRepository.profileDetails?.personalDetails;
                                                                        return FieldRequestPage(
                                                                          fullName: profileRepository
                                                                              .profileDetails
                                                                              ?.firstName,
                                                                          mobile:
                                                                              personalData['mobile'].toString(),
                                                                          email: profileRepository
                                                                              .profileDetails
                                                                              ?.primaryEmail,
                                                                          phoneVerified:
                                                                              personalData['phoneVerified'],
                                                                          isEmailVerified:
                                                                              false,
                                                                          fieldValue:
                                                                              _searchController?.text,
                                                                          parentAction:
                                                                              () {},
                                                                          fieldName:
                                                                              EnglishLang.position,
                                                                        );
                                                                      })));
                                                        },
                                                        child: Text(EnglishLang
                                                            .requestForHelp)),
                                                  )
                                                ],
                                              ),
                                            ));
                                }),
                          ])),
                    )),
              );
            }));
  }

  // _showDesignationRequestPopup() {
  //   return showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (BuildContext ctx) {
  //         return DesignationRequestPopup(
  //           parentContext: ctx,
  //         );
  //       });
  // }
}
