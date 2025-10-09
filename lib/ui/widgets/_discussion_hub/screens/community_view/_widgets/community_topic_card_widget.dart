import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_models/community_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_screens/community_list_view.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';

class CommunityTopicCardWidget extends StatefulWidget {
  final TopicFacet communityTopicItemData;

  CommunityTopicCardWidget({Key? key, required this.communityTopicItemData})
      : super(key: key);
  CommunityTopicCardWidgetState createState() =>
      CommunityTopicCardWidgetState();
}

class CommunityTopicCardWidgetState extends State<CommunityTopicCardWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _communityListItemView(
        communityTopicItemModel: widget.communityTopicItemData);
  }

  Widget _communityListItemView({required TopicFacet communityTopicItemModel}) {
    return InkWell(
        onTap: () {
          Navigator.push(
              context,
              FadeRoute(
                  page: CommunityListView(
                title: communityTopicItemModel.value,
                topicName: communityTopicItemModel.value,
              )));
        },
        child: ClipRRect(
          borderRadius: BorderRadius.all(
            Radius.circular(12.w),
          ),
          child: Container(
              width: 172.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12.w)),
                color: AppColors.verifiedBadgeIconColor,
              ),
              child: Container(
                margin: EdgeInsets.only(left: 4, top: 4, right: 1, bottom: 1).r,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(12.w)),
                  color: AppColors.appBarBackground,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16).r,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 24.w,
                        width: 27.w,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image:
                                  AssetImage('assets/img/igot_creator_icon.png')
                                      as ImageProvider),
                        ),
                      ),
                      SizedBox(
                        height: 8.w,
                      ),
                      Text(
                        communityTopicItemModel.value ?? '',
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(
                                fontSize: 14.0.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkBlue),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(
                        height: 8.w,
                      ),
                      Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "${communityTopicItemModel.count ?? 0} ${((communityTopicItemModel.count ?? 0) == 1) ? AppLocalizations.of(context)!.mDiscussionCommunity : AppLocalizations.of(context)!.mDiscussionCommunities}",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                    fontSize: 10.0.sp,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.disabledTextGrey),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              )),
        ));
  }
}
