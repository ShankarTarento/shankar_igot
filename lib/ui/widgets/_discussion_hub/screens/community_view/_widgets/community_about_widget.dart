import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/ui/components/view_more_text.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_models/competency_passbook_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_models/community_detail_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/community_competencies.dart';


class CommunityAboutWidget extends StatefulWidget {

  final String communityId;
  final CommunityDetailModel? communityResponseData;

  CommunityAboutWidget({Key? key, required this.communityId, required this.communityResponseData}) : super(key: key);

  @override
  CommunityAboutWidgetState createState() => CommunityAboutWidgetState();
}

class CommunityAboutWidgetState extends State<CommunityAboutWidget> {

  @override
  void initState() {
    super.initState();
  }

  List<CompetencyPassbook> getCompetencies() {
    List<CompetencyPassbook> competencies = [];
    if (widget.communityResponseData?.competenciesV5 != null) {
      competencies = widget.communityResponseData!.competenciesV5!;
    }
    return competencies;
  }

  @override
  void dispose() async {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _aboutView(widget.communityResponseData?.description??''),
          if ((widget.communityResponseData?.communityGuideLines??'').isNotEmpty)
            _communityGuidelinesView(widget.communityResponseData?.communityGuideLines??''),
          if (widget.communityResponseData?.countOfPeopleJoined != null)
            _communityStatsView(widget.communityResponseData),
          if ((widget.communityResponseData?.competenciesV5??[]).isNotEmpty)
            _communityCompetencyView(),
        ],
      ),
    );
  }

  Widget _aboutView(String description) {
    return Padding(
      padding: const EdgeInsets.all(16).r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.mDiscussionAboutTheCommunity,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: AppColors.greys,
              fontWeight: FontWeight.w600,
              fontSize: 16.sp,
            ),
          ),
          SizedBox(height: 8.w,),
          ViewMoreText(
            text: description,
            viewLessText:
            AppLocalizations.of(context)!.mStaticReadLess,
            viewMoreText:
            AppLocalizations.of(context)!.mStaticReadMore,
            maxLines: 5,
            style: GoogleFonts.lato(
              color: AppColors.disabledGrey,
              fontWeight: FontWeight.w400,
              fontSize: 16.sp,
              height: 1.5.h,
            ),
            moreLessStyle: GoogleFonts.lato(
              color: AppColors.darkBlue,
              fontWeight: FontWeight.w700,
              fontSize: 14.sp,
              height: 1.5.h,
            ),
          ),
        ],
      ),
    );
  }

  Widget _communityGuidelinesView(String communityGuideLines) {
    return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8).r,
        decoration: BoxDecoration(
          color: AppColors.appBarBackground,
          borderRadius: BorderRadius.all(Radius.circular(12).r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.mDiscussionCommunityGuidelines,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 16.w,),
            HtmlWidget(
              communityGuideLines,
              textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w400,
                fontSize: 14.sp,
              ),
            )
          ],
        )
    );
  }

  Widget _communityStatsView(CommunityDetailModel? communityResponseData) {
    return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8).r,
        decoration: BoxDecoration(
          color: AppColors.appBarBackground,
          borderRadius: BorderRadius.all(Radius.circular(12).r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.mDiscussionCommunityStats,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 16.w,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (communityResponseData?.countOfPeopleLiked != null)
                  statsView(text: '${communityResponseData?.countOfPeopleLiked} '
                      '${(communityResponseData?.countOfPeopleLiked == 1)
                      ? AppLocalizations.of(context)!.mStaticLike
                      : AppLocalizations.of(context)!.mStaticLikes}',
                      icon: Icons.thumb_up
                  ),
                if (communityResponseData?.countOfAnswerPost != null)
                  statsView(text: '${communityResponseData?.countOfAnswerPost} '
                      '${(communityResponseData?.countOfAnswerPost == 1)
                      ? AppLocalizations.of(context)!.mStaticComment
                      : AppLocalizations.of(context)!.mStaticComments}',
                      icon: Icons.mode_comment
                  ),
                if (communityResponseData?.countOfPeopleJoined != null)
                  statsView(text: '${communityResponseData?.countOfPeopleJoined} '
                      '${(communityResponseData?.countOfPeopleJoined == 1)
                      ? AppLocalizations.of(context)!.mDiscussionMember
                      : AppLocalizations.of(context)!.mDiscussionMembers}',
                      icon: Icons.people
                  ),
                if (communityResponseData?.countOfPostCreated != null)
                  statsView(text: '${communityResponseData?.countOfPostCreated} '
                      '${AppLocalizations.of(context)!.mDiscussPost}',
                      icon: Icons.list_alt_outlined
                  ),
              ],
            )
          ],
        )
    );
  }

  Widget statsView({required String text, IconData? icon}) {
    return Padding(
      padding: EdgeInsets.only(top: 4, bottom: 4).r,
      child: Wrap(
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (icon != null)
            Icon(icon, size: 12.w, color: AppColors.disabledTextGrey),
          SizedBox(width: 4.w),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: AppColors.disabledTextGrey,
              fontWeight: FontWeight.w400,
              fontSize: 12.sp,
            ),
          )
        ],
      ),
    );
  }

  Widget _communityCompetencyView() {
    return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        margin: EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 16).r,
        decoration: BoxDecoration(
          color: AppColors.appBarBackground,
          borderRadius: BorderRadius.all(Radius.circular(12).r),
        ),
        child: CommunityCompetencies(
          competencies: widget.communityResponseData?.competenciesV5??[],
        )
    );
  }

}
