import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_models/community_member_model.dart';
import 'package:karmayogi_mobile/ui/widgets/comment_section/pages/widgets/comment_profile_image_widget.dart';

class CommunityMembersItem extends StatefulWidget {
  final MemberDetails memberDetails;

  const CommunityMembersItem({
    Key? key,
    required this.memberDetails,
  }) : super(key: key);

  @override
  State<CommunityMembersItem> createState() => CommunityMembersItemState();
}

class CommunityMembersItemState extends State<CommunityMembersItem> {
  @override
  void initState() {
    randomNumber = Random().nextInt(AppColors.networkBg.length);
    super.initState();
  }

  int randomNumber = 0;
  @override
  Widget build(BuildContext context) {
    return InkWell(
        // onTap: () => Navigator.push(
        //   context,
        //   FadeRoute(
        //     page: ChangeNotifierProvider<NetworkRespository>(
        //       create: (context) => NetworkRespository(),
        //       child: NetworkProfile(widget.memberDetails.userId),
        //     ),
        //   ),
        // ),
        child: Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        Container(
            margin: EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 32).r,
            width: 161.0.w,
            height: 140.w,
            decoration: BoxDecoration(
              color: AppColors.appBarBackground,
              boxShadow: [
                BoxShadow(
                  color: AppColors.grey08,
                  blurRadius: 6.0.r,
                  spreadRadius: 0.r,
                  offset: Offset(3, 3),
                ),
              ],
              border: Border.all(color: AppColors.grey16),
              borderRadius: BorderRadius.circular(12).r,
            ),
            child: Column(children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16, 60, 16, 0).r,
                child: Text(
                  widget.memberDetails.firstName ?? '',
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.displayLarge!.copyWith(
                        height: 1.0.w,
                        letterSpacing: 0.25.r,
                      ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 0).r,
                child: Text(
                  widget.memberDetails.department ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        fontWeight: FontWeight.w400,
                        fontSize: 12.sp,
                        height: 1.429.w,
                        letterSpacing: 0.25.r,
                      ),
                ),
              ),
            ])),
        Positioned(
            top: 10.w,
            child: Center(
                child: CommentProfileImageWidget(
                    profilePic: widget.memberDetails.userProfileImgUrl ?? '',
                    name: widget.memberDetails.firstName ?? '',
                    errorImageColor: AppColors.networkBg[randomNumber],
                    iconSize: 60.w))),
      ],
    ));
  }
}
