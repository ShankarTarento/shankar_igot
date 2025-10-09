import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/mdo_channels/screens/mdo_channel_screen/widgets/state_learning_week/slw_repository/slw_repository.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/mdo_channels/screens/mdo_channel_screen/widgets/top_learner/widget/mdo_learner_widget.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/microsites/model/ati_cti_microsite_data_model.dart';
import 'package:provider/provider.dart';
import '../../../../../../../../constants/_constants/color_constants.dart';
import '../../../../../../../../constants/index.dart';
import '../../../../../../../../respositories/_respositories/learn_repository.dart';
import '../../../../../../../../util/hexcolor.dart';
import '../../../../model/mdo_learner_data_model.dart';
import 'widget/mdo_learner_widget_skeleton.dart';

class MdoTopLearner extends StatefulWidget {
  final GlobalKey? containerKey;
  final String providerName;
  final String orgId;
  final ColumnData columnData;
  final Map<String, dynamic>? slwConfig;

  const MdoTopLearner({
    this.containerKey,
    this.slwConfig,
    required this.providerName,
    required this.orgId,
    required this.columnData,
    Key? key,
  }) : super(key: key);

  @override
  _MdoTopLearnerState createState() => _MdoTopLearnerState();
}

class _MdoTopLearnerState extends State<MdoTopLearner> {
  Future<List<MdoLearnerData>>? topLearnerDataModelFuture;
  MdoLearnerDataModel? mdoLearnerConfigData;
  bool showKarmaPoints = true;

  @override
  void initState() {
    super.initState();
    showKarmaPoints = widget.columnData.data['hideEle'] != null &&
            widget.columnData.data['hideEle'].isNotEmpty
        ? !widget.columnData.data['hideEle'].contains('karma-points')
        : true;
    getTopLearnerData();
  }

  Future<void> getTopLearnerData() async {
    try {
      mdoLearnerConfigData =
          MdoLearnerDataModel.fromJson(widget.columnData.data);
      if (widget.slwConfig != null && widget.slwConfig!['enabled']) {
        topLearnerDataModelFuture =
            SlwRepository().getSlwTopLearner(mdoId: widget.orgId);
      } else {
        final responseData =
            await Provider.of<LearnRepository>(context, listen: false)
                .getMDOTopLearnerData(orgId: widget.orgId);

        if (responseData.isNotEmpty) {
          topLearnerDataModelFuture = Future.value(
            responseData
                .map<MdoLearnerData>((data) => MdoLearnerData.fromJson(data))
                .toList(),
          );
        } else {
          topLearnerDataModelFuture = Future.value([]);
        }
      }
    } catch (e) {
      print("Error fetching or parsing top learner data: $e");

      topLearnerDataModelFuture = Future.value([]);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _buildLayout();
  }

  Widget _buildLayout() {
    return FutureBuilder<List<MdoLearnerData>>(
      future: topLearnerDataModelFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MdoLearnerWidgetSkeleton(
            itemWidth: 0.83.sw,
            itemHeight: 148.w,
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          List<MdoLearnerData> topLearnerList = snapshot.data ?? [];
          if (topLearnerList.isNotEmpty) {
            return Column(
              children: [
                _topLearnerHeading(
                  '${mdoLearnerConfigData?.title ?? ''} (${DateFormat('MMMM').format(DateTime(0, int.parse(topLearnerList[0].month ?? '${DateTime.now().month}')))})',
                  mdoLearnerConfigData?.titleFontColor,
                ),
                Container(
                  margin: EdgeInsets.only(top: 16, bottom: 16).w,
                  child: MdoLearnerWidget(
                    itemWidth: 0.83.sw,
                    itemHeight: showKarmaPoints ? 148.w : 105.w,
                    learnerDataList: topLearnerList,
                    showKarmaPoints: showKarmaPoints,
                  ),
                )
              ],
            );
          } else {
            return const SizedBox.shrink();
          }
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _topLearnerHeading(String title, String? titleFontColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _headingDivider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16).w,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              color: (titleFontColor != null && titleFontColor.isNotEmpty)
                  ? HexColor(titleFontColor).withValues(alpha: 0.87)
                  : AppColors.greys87,
              fontWeight: FontWeight.w600,
              fontSize: 16.sp,
              letterSpacing: 0.25.w,
            ),
          ),
        ),
        _headingDivider(),
      ],
    );
  }

  Widget _headingDivider() {
    return Container(
      height: 2.w,
      margin: EdgeInsets.symmetric(horizontal: 48).r,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.orangeTourText.withValues(alpha: 0.1),
            AppColors.orangeTourText.withValues(alpha: 0.8),
            AppColors.orangeTourText.withValues(alpha: 0.8),
            AppColors.orangeTourText.withValues(alpha: 0.1),
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
      ),
    );
  }
}
