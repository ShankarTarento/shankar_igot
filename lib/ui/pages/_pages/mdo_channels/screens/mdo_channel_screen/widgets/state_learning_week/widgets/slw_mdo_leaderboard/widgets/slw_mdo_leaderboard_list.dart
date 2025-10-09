import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_models/mdo_leaderboard.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/mdo_channels/screens/mdo_channel_screen/widgets/state_learning_week/widgets/slw_mdo_leaderboard/widgets/slw_leaderboard_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SlwMdoLeaderboardList extends StatefulWidget {
  final List<MDOLeaderboardData> mdoLeaderBoardData;
  final String? searchHintText;
  const SlwMdoLeaderboardList(
      {super.key, required this.mdoLeaderBoardData, this.searchHintText});

  @override
  State<SlwMdoLeaderboardList> createState() => _SlwMdoLeaderboardListState();
}

class _SlwMdoLeaderboardListState extends State<SlwMdoLeaderboardList> {
  String searchQuery = '';
  List<MDOLeaderboardData> filteredData = [];

  @override
  void initState() {
    super.initState();
    filteredData = widget.mdoLeaderBoardData;
  }

  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query;
      filteredData = widget.mdoLeaderBoardData
          .where((data) =>
              data.orgName!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.only(left: 16.0, right: 16, top: 16, bottom: 4)
                  .r,
          child: SizedBox(
            height: 40.w,
            child: TextFormField(
              onChanged: (value) {
                updateSearchQuery(value);
              },
              decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.appBarBackground,
                  contentPadding:
                      EdgeInsets.only(left: 12, top: 6, bottom: 6).r,
                  hintText: widget.searchHintText ??
                      AppLocalizations.of(context)!.mStaticSearchMDOs,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40.0).r,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.grey24, width: 1.0),
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: AppColors.darkBlue, width: 2.0),
                    borderRadius: BorderRadius.circular(40.0).r,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.darkBlue,
                  )),
            ),
          ),
        ),
        filteredData.isNotEmpty
            ? Expanded(
                child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount:
                        // filteredData.length,
                        filteredData.length > 6 ? 5 : filteredData.length,
                    itemBuilder: (context, index) {
                      return SlwMdoLeaderboardCard(
                        leaderboardData: filteredData[index],
                      );
                    }),
              )
            : Center(
                child: Padding(
                padding: const EdgeInsets.only(top: 150.0).r,
                child: Text(AppLocalizations.of(context)!.mMsgNoDataFound),
              ))
      ],
    );
  }
}
