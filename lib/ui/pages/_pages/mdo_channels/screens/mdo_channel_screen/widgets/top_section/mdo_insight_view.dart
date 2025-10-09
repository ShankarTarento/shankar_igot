import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:igot_ui_components/models/microsite_insight_data_model.dart';
import 'package:igot_ui_components/ui/widgets/microsite_insight/microsite_insight_skeleton.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:provider/provider.dart';

import '../../../../../../../../respositories/_respositories/learn_repository.dart';
import 'mdo_insight.dart';

class MdoInsightView extends StatefulWidget {
  final String orgId;

  MdoInsightView({
    required this.orgId,
    Key? key,
  }) : super(key: key);

  @override
  _MdoInsightViewState createState() {
    return _MdoInsightViewState();
  }
}

class _MdoInsightViewState extends State<MdoInsightView> {
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
            .getChannelInsightData(orgId: widget.orgId);
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
