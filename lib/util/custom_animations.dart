import 'package:flutter/material.dart';

mixin CustomAnimations<T extends StatefulWidget> on State<T> {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    /// Animation controller
    _animationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this as TickerProvider,
    )..repeat(reverse: true);

    /// Scale animation for zoom in and out
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Animation<double> get scaleAnimation => _scaleAnimation;
}
