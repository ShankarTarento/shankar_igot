import 'package:flutter/material.dart';

import '../constants/index.dart';

class FadeRouteSlide extends PageRouteBuilder {
  final Widget page;
  final int? transitionDurationInMilliseconds;
  FadeRouteSlide(
      {required this.page,
      this.transitionDurationInMilliseconds,
      String? routeName})
      : super(
            settings: RouteSettings(name: routeName),
            transitionDuration: transitionDurationInMilliseconds != null
                ? Duration(milliseconds: transitionDurationInMilliseconds)
                : Duration(milliseconds: 10),
            reverseTransitionDuration: transitionDurationInMilliseconds != null
                ? Duration(milliseconds: transitionDurationInMilliseconds)
                : Duration(milliseconds: 10),
            barrierColor: AppColors.appBarBackground,
            pageBuilder: (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) {
              return page;
            },
            transitionsBuilder: (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child,
            ) {
              /** Slide Transition **/
              return new SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            });
}
