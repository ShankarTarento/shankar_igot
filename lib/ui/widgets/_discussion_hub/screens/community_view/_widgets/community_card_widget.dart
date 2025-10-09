import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:igot_ui_components/ui/components/microsite_image_view.dart';
import 'package:karmayogi_mobile/constants/_constants/app_routes.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_models/community_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/pills_button_widget.dart';
import 'package:karmayogi_mobile/util/helper.dart';

class CommunityCardWidget extends StatefulWidget {
  final CommunityItemData communityItemModel;
  final AdditionalInfo? additionalInfo;
  final VoidCallback? doCallTelemetry;

  CommunityCardWidget(
      {Key? key,
      required this.communityItemModel,
      this.additionalInfo,
      this.doCallTelemetry})
      : super(key: key);
  CommunityCardWidgetState createState() => CommunityCardWidgetState();
}

class CommunityCardWidgetState extends State<CommunityCardWidget> {
  Color? errorImageColor =
      AppColors.networkBg[Random().nextInt(AppColors.networkBg.length)];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _communityListItemView(
        communityItemModel: widget.communityItemModel);
  }

  Widget _communityListItemView(
      {required CommunityItemData communityItemModel}) {
    return InkWell(
        onTap: () {
          if (widget.doCallTelemetry != null) {
            widget.doCallTelemetry!();
          }
          Navigator.pushNamed(
            context,
            AppUrl.communityPage,
            arguments: communityItemModel.communityId ?? '',
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(12.w)),
            border: Border.all(
              color: AppColors.disabledGrey,
              width: 1.0.w,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.all(
              Radius.circular(12.w),
            ),
            child: Container(
                width: 178.w,
                height: 242.w,
                decoration: BoxDecoration(
                  color: AppColors.appBarBackground,
                ),
                child: Column(
                  children: [
                    Container(
                      height: 98.w,
                      width: double.maxFinite,
                      child: Stack(
                        children: [
                          Center(
                            child: (communityItemModel.imageUrl != null)
                                ? MicroSiteImageView(
                                    imgUrl: communityItemModel.imageUrl ?? '',
                                    height: 98,
                                    width: double.maxFinite,
                                    fit: BoxFit.fill,
                                  )
                                : Container(
                                    child: Container(
                                      height: 98.w,
                                      width: double.maxFinite,
                                      decoration: BoxDecoration(
                                        color: errorImageColor,
                                      ),
                                      child: Center(
                                        child: Text(
                                          Helper.getInitialsNew(
                                              communityItemModel
                                                      .communityName ??
                                                  ''),
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayMedium!
                                              .copyWith(
                                                  color: AppColors.avatarText,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12.0.sp),
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                          // if ((communityItemModel.communityAccessLevel??'').isNotEmpty)
                          //   Positioned(
                          //     top: 0,
                          //     left: 1,
                          //     child: Container(
                          //       decoration: BoxDecoration(
                          //         color: AppColors.yellowShade,
                          //         border: Border.all(color: AppColors.grey16),
                          //         borderRadius: BorderRadius.all(const Radius.circular(4.0).r),
                          //       ),
                          //       margin: EdgeInsets.only(left: 8, top: 8).r,
                          //       padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4).r,
                          //       child: Wrap(
                          //         children: [
                          //           Icon(
                          //             Icons.public,
                          //             size: 12.w,
                          //             color: AppColors.greys,
                          //           ),
                          //           Padding(
                          //             padding: const EdgeInsets.only(left: 4.0).r,
                          //             child: Text(
                          //               Helper.capitalizeEachWordFirstCharacter(communityItemModel.communityAccessLevel??''),
                          //               style: Theme.of(context).textTheme.displaySmall!.copyWith(
                          //                   color: AppColors.greys,
                          //                   fontWeight: FontWeight.w400,
                          //                   fontSize: 10.0.sp
                          //               ),
                          //             ),
                          //           ),
                          //         ],
                          //       ),
                          //     ),
                          //   ),
                        ],
                      ),
                    ),
                    Padding(
                        padding:
                            EdgeInsets.only(left: 8, right: 8, bottom: 4).w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              communityItemModel.communityName ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(
                                      fontSize: 14.0.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.greys),
                              textAlign: TextAlign.left,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 12,
                                bottom: 12,
                              ).w,
                              child: Row(
                                children: [
                                  Container(
                                    width: 70.w,
                                    child: Text(
                                      "${communityItemModel.countOfPeopleJoined} ${(communityItemModel.countOfPeopleJoined == 1) ? AppLocalizations.of(context)!.mDiscussionMember : AppLocalizations.of(context)!.mDiscussionMembers}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayMedium!
                                          .copyWith(
                                              color: AppColors.disabledTextGrey,
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.w400),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  Spacer(),
                                  if (communityItemModel.countOfPostCreated !=
                                      null)
                                    Container(
                                      width: 8.w,
                                      child: Text(
                                        "\u2022",
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayMedium!
                                            .copyWith(
                                                color:
                                                    AppColors.disabledTextGrey,
                                                fontSize: 8.sp,
                                                fontWeight: FontWeight.w400),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        textAlign: TextAlign.end,
                                      ),
                                    ),
                                  if (communityItemModel.countOfPostCreated !=
                                      null)
                                    Spacer(),
                                  if (communityItemModel.countOfPostCreated !=
                                      null)
                                    Container(
                                      width: 70.w,
                                      child: Text(
                                        "${communityItemModel.countOfPostCreated} ${(communityItemModel.countOfPostCreated == 1) ? AppLocalizations.of(context)!.mDiscussionPost : AppLocalizations.of(context)!.mDiscussionPosts}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayMedium!
                                            .copyWith(
                                                color:
                                                    AppColors.disabledTextGrey,
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.w400),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        textAlign: TextAlign.end,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (widget.additionalInfo != null)
                              Row(
                                children: [
                                  Container(
                                      margin:
                                          EdgeInsets.only(left: 1, top: 4).r,
                                      decoration: BoxDecoration(
                                          color: AppColors.appBarBackground,
                                          border: Border.all(
                                              color: AppColors.grey16,
                                              width: 1),
                                          borderRadius: BorderRadius.all(
                                                  const Radius.circular(4.0))
                                              .r),
                                      child: ((widget.additionalInfo?.logo ??
                                                  '')
                                              .isNotEmpty)
                                          ? MicroSiteImageView(
                                              imgUrl: Helper.convertImageUrl(
                                                  widget.additionalInfo?.logo ??
                                                      ''),
                                              height: 16,
                                              width: 16,
                                              fit: BoxFit.fill,
                                            )
                                          : Image(
                                              image: AssetImage(
                                                  'assets/img/igot_creator_icon.png'),
                                              height: 16.w,
                                              width: 16.w,
                                            )),
                                  Flexible(
                                    child: Container(
                                      alignment: Alignment.topLeft,
                                      padding: EdgeInsets.only(left: 4).r,
                                      child: Text(
                                        "By ${widget.additionalInfo?.orgname ?? ''}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .displaySmall!
                                            .copyWith(
                                              color: AppColors.greys60,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12.0.sp,
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            Container(
                              height: 40.w,
                              padding: const EdgeInsets.only(top: 8).r,
                              child: PillsButtonWidget(
                                title: AppLocalizations.of(context)!
                                    .mDiscussionViewCommunity,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppUrl.communityPage,
                                    arguments:
                                        communityItemModel.communityId ?? '',
                                  );
                                },
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.darkBlue),
                                  borderRadius: BorderRadius.all(
                                      const Radius.circular(50.0).r),
                                ),
                                textColor: AppColors.darkBlue,
                                textFontSize: 14.sp,
                                isLightTheme: true,
                                verticalPadding: 2.w,
                                horizontalPadding: 8.w,
                              ),
                            ),
                          ],
                        ))
                  ],
                )),
          ),
        ));
  }
}
