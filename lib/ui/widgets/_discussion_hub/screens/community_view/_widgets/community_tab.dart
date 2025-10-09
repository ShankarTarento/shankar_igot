import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CommunityTab {
  final String title;

  CommunityTab({
    required this.title,
  });

  static List<CommunityTab> items({required BuildContext context}) => [
    CommunityTab(
                title: AppLocalizations.of(context)!.mStaticAbout,
              ),
    CommunityTab(
                title: AppLocalizations.of(context)!.mDiscussPosts,
              ),
      ];

  static List<CommunityTab> communityViewItems({required BuildContext context}) => [
    CommunityTab(
      title: AppLocalizations.of(context)!.mDiscussionFeeds,
    ),
    CommunityTab(
      title: AppLocalizations.of(context)!.mDiscussionAllCommunities,
    ),
    CommunityTab(
      title: AppLocalizations.of(context)!.mDiscussionMyCommunities,
    ),
  ];

  static List<CommunityTab> communityDetailItems({required BuildContext context}) => [
    CommunityTab(
      title: AppLocalizations.of(context)!.mDiscussionFeeds,
    ),
    CommunityTab(
      title: AppLocalizations.of(context)!.mStaticAbout,
    ),
    // CommunityTab(
    //   title: AppLocalizations.of(context)!.mDiscussionPinned,
    // ),
    // CommunityTab(
    //   title: AppLocalizations.of(context)!.mDiscussionLinks,
    // ),
    CommunityTab(
      title: AppLocalizations.of(context)!.mDiscussionDocs,
    ),
    CommunityTab(
      title: AppLocalizations.of(context)!.mDiscussionMembers,
    ),
    CommunityTab(
      title: AppLocalizations.of(context)!.mDiscussionYourPost,
    ),
    CommunityTab(
      title: AppLocalizations.of(context)!.mDiscussionBookmarked,
    ),
  ];
}
