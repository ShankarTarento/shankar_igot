import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../../constants/index.dart';
import '../../../../../models/index.dart';
import '../../../../widgets/buttons/button_with_border.dart';
import '../model/language_map_model.dart';
import '../view_model/course_toc_view_model.dart';
import 'language_selection_sheet.dart';

class PreEnrollanguageSelectorWidget extends StatefulWidget {
  final Course course;
  final ValueChanged<String> changeSelectionCallback;
  const PreEnrollanguageSelectorWidget(
      {super.key, required this.course, required this.changeSelectionCallback});

  @override
  State<PreEnrollanguageSelectorWidget> createState() =>
      _PreEnrollanguageSelectorWidgetState();
}

class _PreEnrollanguageSelectorWidgetState
    extends State<PreEnrollanguageSelectorWidget> {
  ValueNotifier<String?> languageSelected = ValueNotifier(null);
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<CourseTocViewModel, String?>(
        selector: (context, courseTocViewModel) =>
            courseTocViewModel.overallCourseLanguage,
        builder: (context, overallCourseLanguage, _) {
          languageSelected.value = overallCourseLanguage;
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 48).r,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.mTocChoosPreferredLanguage,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(color: AppColors.deepBlue),
                    ),
                    SizedBox(height: 8.w),
                    Text(
                      AppLocalizations.of(context)!
                          .mTocChoosPreferredLanguageDescription,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(color: AppColors.greys60),
                    ),
                  ],
                ),
                ValueListenableBuilder<String?>(
                    valueListenable: languageSelected,
                    builder: (context, language, child) {
                      return Column(
                        children: [
                          InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.white,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(16)),
                                    ),
                                    builder: (context) {
                                      return LanguageSelectionSheet(
                                          languageList:
                                              LanguageMapV1.copyLanguageMap(
                                                  widget.course.languageMap),
                                          changeSelectionCallback: (value) {
                                            languageSelected.value = value;
                                            Navigator.of(context).pop();
                                          });
                                    });
                              },
                              child: Container(
                                  padding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8)
                                      .r,
                                  margin: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 24)
                                      .r,
                                  decoration: BoxDecoration(
                                      border:
                                          Border.all(color: AppColors.grey40)),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(language ?? widget.course.language,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .copyWith(
                                                    color: AppColors.deepBlue)),
                                        Icon(Icons.arrow_drop_down,
                                            color: AppColors.greys60)
                                      ]))),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ButtonWithBorder(
                                  onPressCallback: () {
                                    Navigator.of(context).pop();
                                  },
                                  text: AppLocalizations.of(context)!
                                      .mStaticCancel,
                                  borderRadius: 4,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 24).r),
                              SizedBox(width: 8.w),
                              ButtonWithBorder(
                                  onPressCallback: () async {
                                    widget.course.languageMap.languages
                                        .forEach((key, val) {
                                      val.selectedLanguage =
                                          (key == languageSelected.value);
                                    });

                                    await Provider.of<CourseTocViewModel>(
                                            context,
                                            listen: false)
                                        .setOverallCourseLanguage(
                                            language ?? widget.course.language,
                                            context);
                                    widget.changeSelectionCallback(
                                        language ?? widget.course.language);
                                    Navigator.of(context).pop();
                                  },
                                  text: AppLocalizations.of(context)!
                                      .mTocConfirmStartCourse,
                                  bgColor: AppColors.darkBlue,
                                  textStyle:
                                      Theme.of(context).textTheme.displaySmall,
                                  borderRadius: 4),
                            ],
                          ),
                        ],
                      );
                    })
              ],
            ),
          );
        });
  }
}
