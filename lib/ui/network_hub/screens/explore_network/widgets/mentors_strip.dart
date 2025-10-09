import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/ui/network_hub/models/recommended_user.dart';
import 'package:karmayogi_mobile/ui/network_hub/network_hub.dart';
import 'package:karmayogi_mobile/ui/network_hub/network_hub_repository/network_hub_repository.dart';
import 'package:karmayogi_mobile/ui/network_hub/widgets/network_card/network_card.dart';
import 'package:karmayogi_mobile/ui/network_hub/widgets/network_card/widgets/network_card_skeleton.dart';
import 'package:karmayogi_mobile/ui/widgets/title_widget/title_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MentorsStrip extends StatefulWidget {
  const MentorsStrip({super.key});

  @override
  State<MentorsStrip> createState() => _MentorsStripState();
}

class _MentorsStripState extends State<MentorsStrip> {
  @override
  void initState() {
    mentorsFuture =
        NetworkHubRepository().getRecommendedMentors(offset: 0, size: 20);
    super.initState();
  }

  late Future<List<RecommendedUser>> mentorsFuture;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder<List<RecommendedUser>>(
            future: mentorsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0).r,
                      child: TitleWidget(
                        title: AppLocalizations.of(context)!.mMentors,
                        showAllCallBack: () {
                          NetworkHubV2.setTabItem(context: context, index: 3);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 8.w,
                    ),
                    SizedBox(
                      height: 200.w,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 16.0).r,
                            child: NetworkCardSkeleton(),
                          );
                        },
                        itemCount: 5,
                        shrinkWrap: true,
                      ),
                    ),
                  ],
                );
              }
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0).r,
                      child: TitleWidget(
                        title: AppLocalizations.of(context)!.mMentors,
                        showAllCallBack: () {
                          NetworkHubV2.setTabItem(context: context, index: 3);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 8.w,
                    ),
                    SizedBox(
                      height: 200.w,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 16.0).r,
                            child: NetworkCard(
                              user: snapshot.data![index],
                              telemetrySubType:
                                  TelemetrySubType.networkHubMentors,
                            ),
                          );
                        },
                        itemCount: 5,
                        shrinkWrap: true,
                      ),
                    ),
                  ],
                );
              } else {
                return SizedBox();
              }
            }),
      ],
    );
  }
}
