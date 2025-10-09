import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/ai_widgets/ai_bot_icon.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AiLoadingWidget extends StatefulWidget {
  final bool isloading;
  const AiLoadingWidget({super.key, this.isloading = false});

  @override
  State<AiLoadingWidget> createState() => _AiLoadingWidgetState();
}

class _AiLoadingWidgetState extends State<AiLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildBar(int index) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          double value = (index * 0.15 + _controller.value) % 1.0;
          double heightFactor = 0.5 + 0.5 * (1 - (2 * (value - 0.5)).abs());

          return Container(
            width: 2.5.w,
            height: 5.w * heightFactor,
            margin: EdgeInsets.symmetric(horizontal: 2.w),
            decoration: BoxDecoration(
              color: AppColors.darkBlue,
              borderRadius: BorderRadius.circular(2.w),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          const AiBotIcon(),
          widget.isloading
              ? Row(
                  children: [
                    SizedBox(width: 12.w),
                    Text(AppLocalizations.of(context)!.mRetrievingResult,
                        style: GoogleFonts.lato(
                            fontSize: 14.sp,
                            color: AppColors.darkBlue,
                            fontWeight: FontWeight.w600)),
                    SizedBox(width: 4.w),
                    ...List.generate(8, _buildBar)
                  ],
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
