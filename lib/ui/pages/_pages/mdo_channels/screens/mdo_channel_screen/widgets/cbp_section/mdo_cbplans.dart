import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/mdo_channels/screens/mdo_channel_screen/widgets/cbp_section/widgets/mdo_cbp_widget.dart';
import '../../../../../../../../constants/_constants/color_constants.dart';
import '../../../../../../../../util/hexcolor.dart';
import '../../../../model/mdo_cbp_section_data_model.dart';
import '../top_learner/widget/mdo_learner_widget_skeleton.dart';

class MdoCBPlans extends StatefulWidget {
  final String orgId;
  final MdoCBPSectionDataModel cbpPlanSection;

  MdoCBPlans({
    required this.orgId,
    required this.cbpPlanSection,
    Key? key,
  }) : super(key: key);

  @override
  _MdoMdoCBPlansState createState() {
    return _MdoMdoCBPlansState();
  }
}

class _MdoMdoCBPlansState extends State<MdoCBPlans>
    with SingleTickerProviderStateMixin {
  Future<CBPSectionData>? cbpDataModelFuture;
  @override
  void initState() {
    super.initState();
    getCBPData();
  }

  Future<void> getCBPData() async {
    CBPSectionData? responseData = widget.cbpPlanSection.data;
    try {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          cbpDataModelFuture = Future.value(Future.value(responseData));
        });
      });
    } catch (e) {
      debugPrint("get cbp data error $e");
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildLayout();
  }

  Widget _buildLayout() {
    return FutureBuilder(
      future: cbpDataModelFuture,
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          CBPSectionData cbpSectionData = snapshot.data;
          return Container(
            margin: EdgeInsets.only(top: 8, bottom: 16, left: 16, right: 16).w,
            child: Stack(
              children: [
                Container(
                    width: double.maxFinite,
                    margin: EdgeInsets.only(top: 18).w,
                    padding: EdgeInsets.all(8).w,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10.w)),
                        border: Border.all(
                          color: ((cbpSectionData.panelborder != null) ||
                                  (cbpSectionData.panelborder != ''))
                              ? HexColor(cbpSectionData.panelborder!)
                              : AppColors.darkBlue,
                        ),
                        color: AppColors.appBarBackground),
                    child: MdoCBPWidget(
                      cbpSectionData: cbpSectionData,
                    )),
                Center(
                    child: Container(
                  width: 260.w,
                  height: 36.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: ((cbpSectionData.header!.background != null) ||
                            (cbpSectionData.header!.background != ''))
                        ? HexColor(cbpSectionData.header!.background!)
                        : AppColors.darkBlue,
                    borderRadius: BorderRadius.all(Radius.circular(100.w)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: 8).w,
                    child: Text(
                      cbpSectionData.title ?? '',
                      style: GoogleFonts.montserrat(
                        color: ((cbpSectionData.header!.color != null) ||
                                (cbpSectionData.header!.color != ''))
                            ? HexColor(cbpSectionData.header!.color!)
                            : AppColors.appBarBackground,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )),
              ],
            ),
          );
        } else {
          return MdoLearnerWidgetSkeleton(
            itemWidth: 0.83.sw,
            itemHeight: 148.w,
          );
        }
      },
    );
  }
}
