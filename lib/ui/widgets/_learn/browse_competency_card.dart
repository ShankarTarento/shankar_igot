import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/competency/competency_details.dart';
import 'package:karmayogi_mobile/ui/pages/index.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:karmayogi_mobile/util/index.dart';
import './../../../constants/_constants/color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BrowseCompetencyCard extends StatelessWidget {
  final BrowseCompetencyCardModel browseCompetencyCardModel;
  final isCompetencyDetails;

  BrowseCompetencyCard(
      {required this.browseCompetencyCardModel, this.isCompetencyDetails});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.appBarBackground,
      child: Wrap(
        children: [
          Padding(
            padding: const EdgeInsets.all(16).r,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 1.sw / 3,
                            child: Text(
                              browseCompetencyCardModel.name,
                              // "Name of the competency",

                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4).r,
                            child: Text(
                              Helper.capitalizeFirstLetter(
                                  browseCompetencyCardModel.competencyType),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12.sp),
                            ),
                          ),
                        ],
                      ),
                      browseCompetencyCardModel.count != null
                          ? Padding(
                              padding: const EdgeInsets.only(top: 8).r,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                            bottom: 2, right: 4)
                                        .r,
                                    child: SvgPicture.asset(
                                      'assets/img/school.svg',
                                      colorFilter: ColorFilter.mode(
                                          AppColors.greys60, BlendMode.srcIn),
                                      width: 16.w,
                                      height: 16.w,
                                      alignment: Alignment.center,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 2).r,
                                    child: Text(
                                      browseCompetencyCardModel.count
                                              .toString() +
                                          ' CBP\'s',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall!
                                          .copyWith(
                                              fontWeight: FontWeight.w400,
                                              letterSpacing: 0.5.r,
                                              height: 1.2.w,
                                              fontSize: 10.sp),
                                    ),
                                  )
                                ],
                              ),
                            )
                          : Center()
                    ],
                  ),
                  VerticalDivider(
                    thickness: 1.w,
                    width: 20.w,
                    color: AppColors.grey16,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 1.sw / 2,
                        child: Text(
                          browseCompetencyCardModel.description != null
                              ? browseCompetencyCardModel.description!
                              : '',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(
                                fontWeight: FontWeight.w400,
                                fontSize: 14.sp,
                              ),
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        height: 8.w,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            FadeRoute(
                                page: isCompetencyDetails == true
                                    ? CompetencyDetailsPage(
                                        browseCompetencyCardModel)
                                    : CoursesInCompetency(
                                        browseCompetencyCardModel)),
                          );
                        },
                        child: Text(
                          AppLocalizations.of(context)!.mStaticReadMore,
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
