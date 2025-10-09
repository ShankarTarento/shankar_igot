import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/models/_models/batch_model.dart';
import 'package:karmayogi_mobile/services/_services/learn_service.dart';
import '../../../../../../../constants/_constants/color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BlendedProgramDetails extends StatefulWidget {
  final Batch batch;

  const BlendedProgramDetails({
    Key? key,
    required this.batch,
  }) : super(key: key);

  @override
  State<BlendedProgramDetails> createState() => _BlendedProgramDetailsState();
}

class _BlendedProgramDetailsState extends State<BlendedProgramDetails> {
  List? countStatus;

  Batch? batch;

  @override
  void initState() {
    batch = widget.batch;
    getCountStatus();
    super.initState();
  }

  @override
  void didUpdateWidget(BlendedProgramDetails oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.batch.batchId != widget.batch.batchId) {
      getCountStatus();
    }
  }

  Future getCountStatus() async {
    try {
      countStatus = await LearnService()
          .getBlendedProgramBatchCount(widget.batch.batchId);
      batch = widget.batch;
      setState(() {});
      print(countStatus);
    } catch (error) {
      print("Error fetching count status: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 20.0).r,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          detailsCard(
            count: batch?.batchAttributes?.currentBatchSize ?? "0",
            title: AppLocalizations.of(context)!.mLearnBatchSize,
          ),
          detailsCard(
            count:
                countStatus != null ? "${getTotal(count: countStatus!)}" : "0",
            title: AppLocalizations.of(context)!.mCommonTotalApplied,
          ),
          detailsCard(
            count: countStatus != null ? "${getTotalEnrolled()}" : "0",
            title: AppLocalizations.of(context)!.mLearnTotalEnrolled,
          ),
        ],
      ),
    );
  }

  int getTotal({required List count}) {
    return count.fold<int>(0, (previousValue, element) {
      if (element["currentStatus"] != "WITHDRAWN") {
        return previousValue + (element["statusCount"] as int);
      }
      return previousValue;
    });
  }

  int getTotalEnrolled() {
    final approvedStatus = countStatus?.firstWhere(
      (element) => element["currentStatus"] == "APPROVED",
      orElse: () => {"statusCount": 0},
    );
    return approvedStatus?["statusCount"] ?? 0;
  }

  Widget detailsCard({required String title, required String count}) {
    return Container(
      height: 74.w,
      width: 84.w,
      padding: EdgeInsets.all(2).r,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4).r,
        color: AppColors.darkBlueGradient8,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            count,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontSize: 16.sp,
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.w),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
