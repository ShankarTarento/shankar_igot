import 'dart:convert';
import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/landing_page.dart';
import 'package:karmayogi_mobile/respositories/_respositories/chatbot_repository.dart';
import 'package:provider/provider.dart';

class LanguageDropdown extends StatefulWidget {
  final bool isHomePage;

  const LanguageDropdown({Key? key, required this.isHomePage})
      : super(key: key);

  @override
  State<LanguageDropdown> createState() => _LanguageDropdownState();
}

class _LanguageDropdownState extends State<LanguageDropdown> {
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  List<Map<String, String>> dropdownItems = [
    {"value": "en", "viewValue": "English"},
    {"value": "hi", "viewValue": "हिंदी"},
  ];

  Map<String, String>? dropdownValue;

  @override
  void initState() {
    super.initState();
    _getLanguages();
  }

  Future<void> _getLanguages() async {
    try {
      final String deviceLocale = Platform.localeName.split('_').first;
      final String? selectedLanguage =
          await _storage.read(key: Storage.selectedAppLanguage);
      Map<String, String> selected;

      if (selectedLanguage == null) {
        selected = _defaultLanguageForLocale(deviceLocale);
      } else {
        selected = Map<String, String>.from(jsonDecode(selectedLanguage));
      }

      dropdownValue = dropdownItems.firstWhere(
        (item) => item['value'] == selected['value'],
        orElse: () => dropdownItems.first,
      );
      setState(() {});
    } catch (e) {
      print('Error fetching languages: $e');
    }
  }

  Map<String, String> _defaultLanguageForLocale(String locale) {
    switch (locale) {
      case AppLocale.hindi:
        return {"value": "hi", "viewValue": "हिंदी"};
      // case AppLocale.marathi:
      //   return {"value": "mr", "viewValue": "मराठी"};
      // case AppLocale.tamil:
      //   return {"value": "ta", "viewValue": "தமிழ்"};
      // case AppLocale.assamese:
      //   return {"value": "as", "viewValue": "অসমীয়া"};
      // case AppLocale.bengali:
      //   return {"value": "bn", "viewValue": "বাংলা"};
      // case AppLocale.telugu:
      //   return {"value": "te", "viewValue": "తెలుగు"};
      // case AppLocale.kannada:
      //   return {"value": "kn", "viewValue": "ಕನ್ನಡ"};
      // case AppLocale.malaylam:
      //   return {"value": "ml", "viewValue": "മലയാളം"};
      // case AppLocale.gujarati:
      //   return {"value": "gu", "viewValue": "ગુજરાતી"};
      // case AppLocale.oriya:
      //   return {"value": "or", "viewValue": "ଓଡିଆ"};
      // case AppLocale.punjabi:
      //   return {"value": "pa", "viewValue": "ਪੰਜਾਬੀ"};
      default:
        return {"value": "en", "viewValue": "English"};
    }
  }

  Future<void> _setLanguage(Map<String, String> newValue) async {
    try {
      await Provider.of<ChatbotRepository>(context, listen: false)
          .setAppLanguageDropDownValue(newValue);

      await LandingPage().setLocale(
        context,
        Locale(newValue['value']!),
      );

      setState(() {
        dropdownValue = newValue;
      });
    } catch (e) {
      print('Error setting language: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.isHomePage ? _iconDropdown() : _regularDropdown();
  }

  Widget _regularDropdown() {
    return SizedBox(
      height: 32.w,
      width: widget.isHomePage ? 134.w : 126.w,
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<Map<String, String>>(
          selectedItemBuilder: (context) => dropdownItems
              .map((item) => DropdownMenuItem<Map<String, String>>(
                    value: item,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/img/translate_icon2.svg',
                          colorFilter: ColorFilter.mode(
                              AppColors.greys87, BlendMode.srcIn),
                          height: 20.w,
                          width: 20.w,
                        ),
                        SizedBox(width: 10.w),
                        Flexible(
                          child: Text(
                            item["viewValue"]!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(fontSize: 14.sp),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
          isExpanded: true,
          items: dropdownItems
              .map((item) => DropdownMenuItem<Map<String, String>>(
                    value: item,
                    child: Row(
                      children: [
                        Icon(
                          Icons.check,
                          color: dropdownValue == item
                              ? AppColors.darkBlue
                              : Colors.transparent,
                          size: 20.sp,
                        ),
                        SizedBox(width: 10.w),
                        Flexible(
                          child: Text(
                            item["viewValue"]!,
                            style: dropdownValue == item
                                ? GoogleFonts.lato(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.darkBlue,
                                  )
                                : GoogleFonts.lato(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.greys,
                                  ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
          value: dropdownValue,
          onChanged: (value) {
            if (value != null) {
              _setLanguage(value);
            }
          },
          buttonStyleData: ButtonStyleData(
            height: 50.w,
            width: 135.w,
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.isHomePage ? 14 : 4).r,
              border: Border.all(color: AppColors.grey16),
              color: AppColors.appBarBackground,
              boxShadow: [BoxShadow(color: Colors.transparent)],
            ),
            elevation: 2,
          ),
          iconStyleData: IconStyleData(
            icon: Icon(Icons.arrow_drop_down),
            iconSize: 14.w,
            iconEnabledColor: AppColors.greys,
            iconDisabledColor: AppColors.greys,
          ),
          dropdownStyleData: DropdownStyleData(
            width: 135.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4).r,
              color: AppColors.appBarBackground,
            ),
            offset: Offset(0, -5),
            scrollbarTheme: ScrollbarThemeData(
              radius: Radius.circular(40).r,
              thickness: WidgetStateProperty.all(6),
              thumbVisibility: WidgetStateProperty.all(true),
            ),
          ),
          menuItemStyleData: MenuItemStyleData(),
        ),
      ),
    );
  }

  Widget _iconDropdown() {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<Map<String, String>>(
        customButton: SvgPicture.asset(
          'assets/img/translate_icon2.svg',
          colorFilter: ColorFilter.mode(AppColors.greys87, BlendMode.srcIn),
          height: 24.w,
          width: 24.w,
          fit: BoxFit.fill,
        ),
        items: dropdownItems
            .map((item) => DropdownMenuItem<Map<String, String>>(
                  value: item,
                  child: Row(
                    children: [
                      Icon(
                        Icons.check,
                        color: dropdownValue == item
                            ? AppColors.darkBlue
                            : Colors.transparent,
                        size: 20.sp,
                      ),
                      SizedBox(width: 10.w),
                      Flexible(
                        child: Text(
                          item["viewValue"]!,
                          style: dropdownValue == item
                              ? GoogleFonts.lato(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.darkBlue,
                                )
                              : GoogleFonts.lato(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.greys,
                                ),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
        value: dropdownValue,
        onChanged: (value) {
          if (value != null) {
            _setLanguage(value);
          }
        },
        dropdownStyleData: DropdownStyleData(
          width: 135.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4).r,
            color: AppColors.appBarBackground,
          ),
          offset: Offset(0, -5),
          scrollbarTheme: ScrollbarThemeData(
            radius: Radius.circular(40).r,
            thickness: WidgetStateProperty.all(6),
            thumbVisibility: WidgetStateProperty.all(true),
          ),
        ),
        menuItemStyleData: MenuItemStyleData(),
      ),
    );
  }
}
