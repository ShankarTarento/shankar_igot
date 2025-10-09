import 'package:flutter/material.dart';

import '../../../constants/index.dart';

class GradientLine extends StatefulWidget {
  final List<Color> colors;
  final double opacity;

  const GradientLine({
    super.key,
    this.colors = const [
      AppColors.disabledTextGrey0,
      AppColors.greys,
      AppColors.disabledTextGrey0
    ],
    this.opacity = 0.1,
  });

  @override
  _GradientLineState createState() => _GradientLineState();
}

class _GradientLineState extends State<GradientLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _animation;

  @override
  void initState() {
    super.initState();

    // Set up the AnimationController
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Create an alignment animation that shifts from left to right
    _animation = Tween<Alignment>(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Start the animation once
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: 2.0,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: _animation.value,
              end: _animation.value == Alignment.centerLeft
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              colors: widget.colors
                  .map((color) => color.withValues(alpha: widget.opacity))
                  .toList(),
            ),
          ),
        );
      },
    );
  }
}
