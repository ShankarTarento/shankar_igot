import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../constants/index.dart';
import '../model/language_map_model.dart';

class LanguageCountWidget extends StatelessWidget {
  final Map<String, LanguageContent> languages;
  final EdgeInsets? padding;

  const LanguageCountWidget({super.key, required this.languages, this.padding});
  @override
  Widget build(BuildContext context) {
    return languages.entries.length > 1
        ? InkWell(
            onTap: () {
              showLanguageList(context);
            },
            child: Padding(
              padding: padding ?? EdgeInsets.only(top: 16).r,
              child: Row(
                children: [
                  Icon(Icons.language, size: 20.sp, color: AppColors.black),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                        AppLocalizations.of(context)!
                            .mTocAvailableInLanguages(languages.entries.length),
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ),
                  SizedBox(width: 4.w),
                  Icon(Icons.arrow_forward_ios_outlined,
                      size: 12.sp, color: AppColors.black),
                ],
              ),
            ),
          )
        : SizedBox(
            height: 16.w,
          );
  }

  void showLanguageList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)).r,
      ),
      builder: (context) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 0.7.sh,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8).r,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.mTocAvailableLanguages,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(color: AppColors.deepBlue),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.greys60,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0).r,
                  child: const Divider(
                    height: 1,
                    color: AppColors.grey24,
                  ),
                ),

                // Scrollable List
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0).r,
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 8).r,
                      itemCount: languages.entries.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0).r,
                          child: Text(languages.entries.elementAt(index).key,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(color: AppColors.deepBlue)),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
