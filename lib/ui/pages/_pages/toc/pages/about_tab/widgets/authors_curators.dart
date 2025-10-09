import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/models/_models/creator_model.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../../constants/index.dart';

class AuthorsCurators extends StatelessWidget {
  final List<CreatorModel> curators;
  final List<CreatorModel> authors;
  const AuthorsCurators(
      {Key? key, required this.curators, required this.authors})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.mStaticAuthorsAndCurators,
          style: GoogleFonts.lato(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(
          height: 10.w,
        ),
        authors.isEmpty && curators.isEmpty
            ? Text(
                AppLocalizations.of(context)!.mMsgNoDataFound,
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: 16.sp,
                      height: 1.5.w,
                    ),
              )
            : SizedBox(),
        if (authors.isNotEmpty)
          ...List.generate(authors.length, (index) {
            return displayCard(
              initial: Helper.getInitials(authors[index].name!),
              title: authors[index].name!,
              subtitle: AppLocalizations.of(context)!.mLearnCourseAuthor,
              context: context,
            );
          }),
        if (curators.isNotEmpty)
          ...List.generate(curators.length, (index) {
            return displayCard(
              initial: Helper.getInitials(curators[index].name!),
              title: curators[index].name!,
              subtitle: AppLocalizations.of(context)!.mLearnCourseCurator,
              context: context,
            );
          })
      ],
    );
  }

  Widget displayCard(
      {required String initial,
      required String title,
      required String subtitle,
      required BuildContext context}) {
    return Padding(
      padding: const EdgeInsets.only(top: 16).r,
      child: Row(
        children: [
          CircleAvatar(
            radius: 16.r,
            backgroundColor: AppColors.greys,
            child: Text(
              initial,
              style: Theme.of(context).textTheme.displaySmall!.copyWith(
                    fontSize: 16.sp,
                    color: AppColors.appBarBackground,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          SizedBox(
            width: 16.w,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 0.75.sw,
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.lato(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.greys,
                  ),
                ),
              ),
              Text(
                subtitle,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                    ),
              )
            ],
          )
        ],
      ),
    );
  }
}
