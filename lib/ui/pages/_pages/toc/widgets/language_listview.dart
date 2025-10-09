import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/view_model/course_toc_view_model.dart';
import 'package:provider/provider.dart';

import '../../../../../constants/index.dart';
import '../../../../../models/index.dart';
import '../../../../../respositories/index.dart';
import '../../../index.dart';
import '../model/language_map_model.dart';
import 'PostEnrollLanguageChange.dart';
import 'language_selection_sheet.dart';

class LanguageListView extends StatefulWidget {
  final Course course;
  const LanguageListView({super.key, required this.course});

  @override
  State<LanguageListView> createState() => _LanguageListViewState();
}

class _LanguageListViewState extends State<LanguageListView> {
  late LanguageMapV1 mergedLanguages;
  late TocServices tocServiceProvider;

  @override
  void initState() {
    super.initState();
    mergedLanguages = widget.course.languageMap;
  }

  @override
  Widget build(BuildContext context) {
    return Selector<CourseTocViewModel, String?>(
        selector: (context, courseTocViewModel) =>
            courseTocViewModel.overallCourseLanguage,
        builder: (context, overallCourseLanguage, _) {
          // How many items can fit on screen?
          int visibleItemCount = getVisibleItemCount(context);

          bool needsViewMore =
              mergedLanguages.languages.length > visibleItemCount;

          if (overallCourseLanguage != null) {
            reorderLanguageMap(overallCourseLanguage, needsViewMore);
          }

          Map<String, LanguageContent> visibleItems = needsViewMore
              ? Map.fromEntries(
                  mergedLanguages.languages.entries.take(visibleItemCount - 1))
              : mergedLanguages.languages;

          return Row(
            children: [
              ...visibleItems.entries.map((item) => InkWell(
                    onTap: overallCourseLanguage != item.key
                        ? () async =>
                            await updateCourseLanguage(context, item.key)
                        : null,
                    child: Container(
                      margin:
                          const EdgeInsets.symmetric(horizontal: 6, vertical: 8)
                              .r,
                      padding:
                          EdgeInsets.symmetric(vertical: 6, horizontal: 8).r,
                      decoration: BoxDecoration(
                        color: item.value.selectedLanguage
                            ? AppColors.appBarBackground
                            : null,
                        border: Border.all(
                            color: AppColors.appBarBackground, width: 1.5),
                        borderRadius: BorderRadius.circular(70).r,
                      ),
                      child: Center(
                          child: Text(
                        item.key,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(
                                color: item.value.selectedLanguage
                                    ? AppColors.darkBlue
                                    : AppColors.appBarBackground),
                      )),
                    ),
                  )),
              if (needsViewMore)
                GestureDetector(
                  onTap: () => _onViewMoreTap(visibleItemCount),
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8)
                            .r,
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8).r,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: AppColors.appBarBackground, width: 1.5),
                      borderRadius: BorderRadius.circular(70).r,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppLocalizations.of(context)!.mCardMore,
                            style: Theme.of(context).textTheme.displaySmall),
                        Icon(
                          Icons.keyboard_arrow_down_outlined,
                          color: AppColors.appBarBackground,
                        )
                      ],
                    ),
                  ),
                ),
            ],
          );
        });
  }

  Future<void> updateCourseLanguage(BuildContext context, String language,
      {VoidCallback? doPop}) async {
    await showLanguageSwitchingBtmSheet(language,
        changeSelectionCallback: () async {
      Provider.of<TocServices>(context, listen: false).clearCourseProgress();
      await Provider.of<CourseTocViewModel>(context, listen: false)
          .setOverallCourseLanguage(language, context);
      doPop?.call();
    });
  }

  int getVisibleItemCount(BuildContext context) {
    int count = 0;
    final textStyle = Theme.of(context).textTheme.headlineMedium!;
    double totalTextWidth = 0;
    for (final entry in mergedLanguages.languages.entries) {
      final textWidth = calculateTextWidth(entry.key, textStyle);
      final itemWidth = textWidth + 24.r;

      if (totalTextWidth + itemWidth + 65 > 1.0.sw) break;

      count++;
      totalTextWidth += itemWidth;
    }
    return count;
  }

  double calculateTextWidth(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    return textPainter.width;
  }

  void _onViewMoreTap(int visibleItemCount) {
    LanguageMapV1 currentLanguages = LanguageMapV1(
      languages: Map<String, LanguageContent>.from(mergedLanguages.languages),
    );
    currentLanguages = LanguageMapV1(
      languages: Map.fromEntries(
        mergedLanguages.languages.entries.skip(visibleItemCount - 1),
      ),
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)).r,
      ),
      builder: (context) {
        return LanguageSelectionSheet(
            languageList: currentLanguages,
            changeSelectionCallback: (selectedKey) async {
              await updateCourseLanguage(context, selectedKey,
                  doPop: () => Navigator.of(context).pop());
            });
      },
    );
  }

  void reorderLanguageMap(String selectedKey, bool needsViewMore) {
    // Update the actual data first
    Map<String, LanguageContent> originalMap =
        Map<String, LanguageContent>.from(mergedLanguages.languages);
    mergedLanguages.languages.forEach((key, item) {
      item.selectedLanguage = (key == selectedKey);
    });
    if (needsViewMore) {
      // 2. Move selected entry to top
      final selectedEntry = MapEntry(
        selectedKey,
        originalMap[selectedKey]!,
      );

      final reorderedMap = {
        selectedEntry.key: selectedEntry.value,
        ...originalMap..remove(selectedKey),
      };

      // 3. Update mergedLanguages with new order
      mergedLanguages = LanguageMapV1(languages: reorderedMap);
    } else {
      mergedLanguages = LanguageMapV1(languages: originalMap);
    }
  }

  Future<void> showLanguageSwitchingBtmSheet(String language,
      {required VoidCallback changeSelectionCallback}) async {
    Map<String, dynamic> languageProgress =
        Provider.of<LearnRepository>(context, listen: false).languageProgress;
    String? selectedLanguage = LanguageMapV1.getValueFromDisplayName(language);
    ValueNotifier<Course?> enrolledCourse =
        Provider.of<CourseTocViewModel>(context, listen: false).enrolledCourse;
    double? courseProgress =
        Provider.of<TocServices>(context, listen: false).courseProgress;
    if (selectedLanguage != null &&
        enrolledCourse.value != null &&
        courseProgress != 1.0) {
      await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)).r,
          ),
          builder: (context) {
            return PostEnrollLanguageChangeWidget(
              course: widget.course,
              changeSelectionCallback: changeSelectionCallback,
              title: languageProgress[selectedLanguage.toLowerCase()] == 0
                  ? AppLocalizations.of(context)!.mTocWantToChangeLanguage
                  : AppLocalizations.of(context)!
                      .mTocContinueWhereyouLeftOff(language),
              description1: languageProgress[selectedLanguage.toLowerCase()] > 0
                  ? AppLocalizations.of(context)!.mTocYouHaveMadeProgress
                  : AppLocalizations.of(context)!
                      .mTocSwitchingLangWillResetProgress,
              description2: languageProgress[selectedLanguage.toLowerCase()] ==
                      0
                  ? AppLocalizations.of(context)!.mTocCourseRestartFromBeginning
                  : AppLocalizations.of(context)!.mTocContinueFromLeftOff,
              button1: AppLocalizations.of(context)!.mStaticBack,
              button2: languageProgress[selectedLanguage.toLowerCase()] == 0
                  ? AppLocalizations.of(context)!.mTocChangeLanguage
                  : AppLocalizations.of(context)!.mLearnResume,
            );
          });
    } else if (selectedLanguage != null) {
      changeSelectionCallback.call();
    }
  }
}
