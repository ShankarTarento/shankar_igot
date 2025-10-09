import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/respositories/_respositories/chatbot_repository.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../util/telemetry_repository.dart';

class LanguagePickerWidget extends StatefulWidget {
  final parentAction;
  final String loggedInStatus;
  final ValueChanged onChanged;

  LanguagePickerWidget(
      {Key? key,
      this.parentAction,
      required this.loggedInStatus,
      required this.onChanged})
      : super(key: key);
  @override
  LanguagePickerWidgetState createState() => LanguagePickerWidgetState();
}

class LanguagePickerWidgetState extends State<LanguagePickerWidget>
    with WidgetsBindingObserver {
  List<dynamic> dropdownItems = [];
  dynamic _dropdownValue;

  @override
  void initState() {
    super.initState();
    _getLanguages();
  }

  _getLanguages() async {
    final _storage = FlutterSecureStorage();
    final res = await Provider.of<ChatbotRepository>(context, listen: false)
        .getFaqAvailableLanguages();
    final String deviceLocale = Platform.localeName.split('_').first.toString();
    String? selectedLanguage =
        await _storage.read(key: Storage.faqSelectedLanguage);
    dynamic selected;

    if (selectedLanguage == null) {
      if (deviceLocale == ChatBotLocale.hindi) {
        selected = {"value": "hi", "viewValue": "हिंदी"};
      } else {
        selected = {"value": "en", "viewValue": "English"};
      }
    } else {
      selected = jsonDecode(selectedLanguage);
    }
    setState(() {
      dropdownItems = res;
      dropdownItems.forEach((element) {
        if (element.toString() == selected.toString()) {
          _dropdownValue = element;
        } else {
          _dropdownValue = dropdownItems[0];
        }
      });
    });
  }

  Future<void> _generateInteractTelemetryData(
      String contentId, String subtype) async {
    var telemetryRepository = TelemetryRepository();
    bool isPublic = widget.loggedInStatus == EnglishLang.NotLoggedIn;
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.homePageId,
        contentId: contentId,
        subType: subtype,
        env: TelemetryEnv.home,
        objectType: subtype,
        isPublic: isPublic);
    await telemetryRepository.insertEvent(
        eventData: eventData, isPublic: isPublic);
  }

  _setLanguage(dynamic newValue) async {
    await Provider.of<ChatbotRepository>(context, listen: false)
        .setLanguageDropDownValue(newValue);
    await Provider.of<ChatbotRepository>(context, listen: false).getFaqData(
        isLoggedIn: widget.loggedInStatus != EnglishLang.NotLoggedIn);
    // await LandingPage().setLocale(
    //     context,
    //     Locale(
    //       newValue['value'],
    //     ));
    //  await LandingPage().setChatBotLocale(context);

    await _generateInteractTelemetryData(
        newValue['value'], TelemetrySubType.languageDropdown);

    setState(() {
      _dropdownValue = newValue;
    });

    widget.parentAction();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      margin: EdgeInsets.only(right: 4, top: 10, bottom: 10).r,
      padding: EdgeInsets.only(left: 8).w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.appBarBackground,
        border: Border.all(color: AppColors.grey16),
        borderRadius: BorderRadius.all(Radius.circular(4)).r,
      ),
      child: dropdownItems.isNotEmpty
          ? DropdownButton<dynamic>(
              value: _dropdownValue != null ? _dropdownValue : null,
              icon: Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10).r,
                  child: Icon(Icons.arrow_drop_down_outlined),
                ),
              ),
              iconSize: 26.w,
              elevation: 16,
              style: TextStyle(color: AppColors.greys87),
              underline: Container(
                // height: 2,
                color: AppColors.lightGrey,
              ),
              borderRadius: BorderRadius.circular(4).r,
              selectedItemBuilder: (BuildContext context) {
                return dropdownItems.map<Widget>((dynamic item) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item['viewValue'],
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(letterSpacing: 0.25.r),
                    ),
                  );
                }).toList();
              },
              onChanged: (dynamic newValue) {
                _setLanguage(newValue);
                widget.onChanged(newValue);
              },
              items:
                  dropdownItems.map<DropdownMenuItem<dynamic>>((dynamic value) {
                return DropdownMenuItem<dynamic>(
                  value: value,
                  child: Text(value['viewValue']),
                );
              }).toList(),
            )
          : Text(AppLocalizations.of(context)!.mStaticSelect),
    );
  }
}
