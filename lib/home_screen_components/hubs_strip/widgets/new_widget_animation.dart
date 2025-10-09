import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NewWidgetAnimation extends StatefulWidget {
  const NewWidgetAnimation({super.key});

  @override
  State<NewWidgetAnimation> createState() => _NewWidgetAnimationState();
}

class _NewWidgetAnimationState extends State<NewWidgetAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2).w,
        margin: EdgeInsets.only(right: 2).w,
        decoration: BoxDecoration(
          color: AppColors.negativeLight,
          borderRadius: BorderRadius.circular(2),
        ),
        alignment: Alignment.center,
        child: Text(
          AppLocalizations.of(context)!.mStaticNew,
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontSize: 8.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.appBarBackground,
              ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
