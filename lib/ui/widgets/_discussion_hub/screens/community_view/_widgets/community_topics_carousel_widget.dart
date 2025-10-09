
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/helper/discussion_const.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_models/community_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/community_topic_card_widget.dart';

class CommunityTopicsCarouselWidget extends StatefulWidget {
  final List<TopicFacet> communityTopicList;
  final String? heading;
  final Function? onClickShowAll;

  CommunityTopicsCarouselWidget({Key? key, required this.communityTopicList, this.heading, this.onClickShowAll}) : super(key: key);
  CommunityTopicsCarouselWidgetState createState() => CommunityTopicsCarouselWidgetState();
}

class CommunityTopicsCarouselWidgetState extends State<CommunityTopicsCarouselWidget> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return buildUI();
  }

  Widget buildUI() {
    return Container(
      margin: EdgeInsets.only(bottom: 8).r,
      child: Column(
        children: [
          if (widget.heading != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 16).r,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.heading??'',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                    ),
                  ),
                  if (widget.onClickShowAll != null)
                    InkWell(
                        onTap: () {
                          widget.onClickShowAll!();
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 2.0).r,
                          child: Row(
                            children: [
                              Text(
                                AppLocalizations.of(context)!.mCommonShowAll,
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: AppColors.darkBlue,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14.sp,
                                  letterSpacing: 0.12,
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: AppColors.darkBlue,
                                size: 18.sp,
                              )
                            ],
                          ),
                        ))
                ],
              ),
            ),
          _communityListView(widget.communityTopicList),
        ],
      ),
    );
  }

  Widget _communityListView(List<TopicFacet> communityTopicItemList) {
    return Container(
      height: 182.w,
      alignment: Alignment.centerLeft,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        itemCount: ((communityTopicItemList.length > COMMUNITY_TOPIC_CARD_DISPLAY_LIMIT) ? COMMUNITY_TOPIC_CARD_DISPLAY_LIMIT : communityTopicItemList.length),
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 475),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: (index == 0) ? 16 : 8, right: (index < (communityTopicItemList.length - 1)) ? 0 : 16),
                      child: CommunityTopicCardWidget(
                        communityTopicItemData: communityTopicItemList[index],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
