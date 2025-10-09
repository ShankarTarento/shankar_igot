import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:igot_ui_components/models/microsite_insight_data_model.dart';
import 'package:igot_ui_components/ui/widgets/microsite_insight/microsite_insight_skeleton.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/mdo_channels/screens/mdo_channel_screen/widgets/state_learning_week/slw_repository/slw_repository.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/mdo_channels/screens/mdo_channel_screen/widgets/top_section/mdo_insight.dart';

class SlwInsightView extends StatefulWidget {
  final String orgId;

  SlwInsightView({
    required this.orgId,
    Key? key,
  }) : super(key: key);

  @override
  _SlwInsightViewState createState() {
    return _SlwInsightViewState();
  }
}

class _SlwInsightViewState extends State<SlwInsightView> {
  Future<List<MicroSiteInsightsData>>? insightDataModel;

  @override
  void initState() {
    super.initState();
    getInsightData();
  }

  Future<void> getInsightData() async {
    insightDataModel =
        SlwRepository().getSlwWeekInsights(mdoOrgId: widget.orgId);
  }

  @override
  Widget build(BuildContext context) {
    return _buildLayout();
  }

  Widget _buildLayout() {
    return FutureBuilder(
      future: insightDataModel,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          if (snapshot.data!.isNotEmpty) {
            return Container(
              height: 75.w,
              margin: EdgeInsets.only(top: 16, bottom: 16).w,
              child: MDOInsight(
                itemWidth: 249.w,
                itemHeight: 75.w,
                itemBackground: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.darkBlue, AppColors.darkBlue],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(12.w)),
                ),
                insightDataList: snapshot.data!,
              ),
            );
          } else {
            return SizedBox.shrink();
          }
        } else {
          return MicroSiteInsightSkeleton(
            itemHeight: 75.w,
            itemWidth: 249.w,
          );
        }
      },
    );
  }
}
