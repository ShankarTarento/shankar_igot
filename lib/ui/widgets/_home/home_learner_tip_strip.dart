import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/ui/widgets/_tips_for_learning/data_models/tips_model.dart';

import '../../../constants/index.dart';
import '../../../util/faderoute.dart';
import '../_tips_for_learning/pages/view_all_tips.dart';
import '../_tips_for_learning/widgets/disable_learner_tips.dart';
import '../_tips_for_learning/widgets/tips_display_card.dart';

class HomeLearnerTipStrip extends StatefulWidget {
  final VoidCallback generateShowAllTelemetry;
  final List<TipsModel> tips;

  const HomeLearnerTipStrip(
      {super.key, required this.generateShowAllTelemetry, required this.tips});
  @override
  State<HomeLearnerTipStrip> createState() => _HomeLearnerTipStripState();
}

class _HomeLearnerTipStripState extends State<HomeLearnerTipStrip> {
  bool enableLearnerTip = true;

  final _storage = FlutterSecureStorage();
  ValueNotifier<bool> showLearnerTips = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
    getVisibility();
  }

  Future<void> getVisibility() async {
    try {
      // Read visibility status from storage
      final value = await _storage.read(key: Storage.enableLearnerTip);
      if (value != null) {
        setState(() {
          enableLearnerTip = jsonDecode(value);
        });
      }
    } catch (e) {
      print("Error fetching visibility status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return enableLearnerTip && widget.tips.isNotEmpty
        ? ValueListenableBuilder(
            valueListenable: showLearnerTips,
            builder: (BuildContext context, bool displayTips, Widget? child) {
              return displayTips
                  ? Column(children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 8,
                        ).r,
                        child: Row(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.mTipsForLearners,
                              style: GoogleFonts.montserrat(
                                  fontSize: 16.sp, fontWeight: FontWeight.w600),
                            ),
                            Spacer(),
                            // TextButton(
                            //   onPressed: () {
                            //     showLearnerTips.value = false;
                            //   },
                            //   child: Text(
                            //     AppLocalizations.of(context)!.mStaticHide,
                            //     style: GoogleFonts.lato(
                            //         color: AppColors.grey40,
                            //         fontSize: 14.sp,
                            //         fontWeight: FontWeight.w400),
                            //   ),
                            // ),
                            TextButton(
                                onPressed: () {
                                  widget.generateShowAllTelemetry();
                                  Navigator.push(
                                    context,
                                    FadeRoute(
                                      page: ViewAllTips(
                                        tips: widget.tips,
                                      ),
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!
                                          .mStaticShowAll,
                                      style: GoogleFonts.lato(
                                          fontSize: 14.sp,
                                          color: AppColors.darkBlue,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    Icon(
                                      Icons.chevron_right,
                                      color: AppColors.darkBlue,
                                      size: 16.sp,
                                    )
                                  ],
                                ))
                          ],
                        ),
                      ),
                      TipsDisplayCard(
                        tips: widget.tips,
                        closeFunction: () {
                          showLearnerTips.value = false;
                        },
                      ),
                    ])
                  : DisableLearnerTips();
            })
        : SizedBox();
  }
}
