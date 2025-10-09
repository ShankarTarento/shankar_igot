import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../constants/_constants/color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../data_models/tips_model.dart';
import '../widgets/tips_card.dart';

class ViewAllTips extends StatefulWidget {
  final List<TipsModel> tips;
  const ViewAllTips({Key? key, required this.tips}) : super(key: key);

  @override
  State<ViewAllTips> createState() => _ViewAllTipsState();
}

class _ViewAllTipsState extends State<ViewAllTips> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        shadowColor: Colors.transparent,
        backgroundColor: AppColors.appBarBackground,
        leading: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Icon(Icons.arrow_back, size: 24.sp)),
        toolbarHeight: kToolbarHeight.w,
        title: Text(
          AppLocalizations.of(context)!.mTipsForLearners,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 30).r,
          child: Column(
              children: List.generate(
                  widget.tips.length,
                  (index) => TipsCard(
                        tip: widget.tips[index],
                      ))),
        ),
      ),
    );
  }
}
