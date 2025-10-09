import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../constants/index.dart';

class ArcPainter extends CustomPainter {
  final double percentage;
  ArcPainter({this.percentage = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint paint = Paint()
      ..color = AppColors.positiveLight
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0.sp
      ..style = PaintingStyle.stroke;

    // Define the gap size in radians
    const double gapInRadians = 1;

    // Start angle (bottom center + half gap)
    const double startAngle = (pi / 2) + (gapInRadians / 1.7);

    // Calculate maximum possible sweep (full circle minus gap)
    const double maxSweepAngle = (2 * pi) - gapInRadians;

    // Calculate sweep based on percentage of maximum possible sweep
    double sweepAngle = maxSweepAngle * (percentage / 100);

    // Draw the arc
    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant ArcPainter oldDelegate) {
    return oldDelegate.percentage != percentage;
  }
}
