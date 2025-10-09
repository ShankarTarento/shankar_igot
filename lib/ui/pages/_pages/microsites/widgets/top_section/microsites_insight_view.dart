import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:igot_ui_components/ui/widgets/microsite_insight/microsite_insight_skeleton.dart';
import 'package:provider/provider.dart';
import '../../../../../../constants/index.dart';
import '../../../../../../respositories/_respositories/learn_repository.dart';
import '../../generic/model/microsite_insight_data_model.dart';
import '../../generic/widgets/microsite_insight.dart';

class MicroSitesInsightView extends StatefulWidget {
  final String? orgId;

  MicroSitesInsightView({
    this.orgId,
    Key? key,
  }) : super(key: key);

  @override
  _MicroSitesInsightViewState createState() {
    return _MicroSitesInsightViewState();
  }
}

class _MicroSitesInsightViewState extends State<MicroSitesInsightView> {
  Future<MicroSiteInsightsDataModel>? insightDataModel;

  @override
  void initState() {
    super.initState();
    getInsightData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getInsightData() async {
    var responseData =
        await Provider.of<LearnRepository>(context, listen: false)
            .getInsightData(orgId: widget.orgId);
    if (responseData != null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          insightDataModel =
              Future.value(MicroSiteInsightsDataModel.fromJson(responseData));
        });
      });
    } else {
      insightDataModel = Future.value(MicroSiteInsightsDataModel.fromJson({}));
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildLayout();
  }

  Widget _buildLayout() {
    return FutureBuilder(
      future: insightDataModel,
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          List<MicroSiteInsightsData> insightDataList =
              snapshot.data.data ?? [];
          if (insightDataList.isNotEmpty) {
            return Container(
              height: 75.w,
              margin: EdgeInsets.only(top: 16, bottom: 16).w,
              child: MicroSiteInsight(
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
                insightDataList: insightDataList,
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
