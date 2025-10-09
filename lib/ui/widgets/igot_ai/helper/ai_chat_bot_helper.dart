import 'package:flutter/material.dart';

class AiChatBotHelper {
  static String getDurationRange(int startTimeInSec, int endTimeInSec) {
    final durationInSec = (endTimeInSec - startTimeInSec).abs();

    if (durationInSec < 3600) {
      final startMin = startTimeInSec ~/ 60;
      final endMin = (endTimeInSec / 60).ceil();
      return '$startMin - $endMin mins';
    } else {
      final startHr = startTimeInSec / 3600;
      final endHr = endTimeInSec / 3600;
      final roundedStart = double.parse(startHr.toStringAsFixed(1));
      final roundedEnd = double.parse(endHr.toStringAsFixed(1));
      return '$roundedStart - $roundedEnd hrs';
    }
  }

  static List<TextSpan> parseMarkdownLite(String markdown) {
    final lines = markdown.split('\n');
    final spans = <TextSpan>[];

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trimRight();

      bool isBullet = line.startsWith('* ');
      if (isBullet) {
        line = '• ${line.substring(2)}';
      }

      final inlineSpans = <TextSpan>[];

      final regex = RegExp(r'(\*\*|__)(.*?)\1|(\*|_)(.*?)\3');

      int currentIndex = 0;
      for (final match in regex.allMatches(line)) {
        if (match.start > currentIndex) {
          inlineSpans.add(TextSpan(
            text: line.substring(currentIndex, match.start),
          ));
        }

        final isBold = match.group(1) != null;
        final text = isBold ? match.group(2) : match.group(4);

        inlineSpans.add(TextSpan(
          text: text,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontStyle: !isBold ? FontStyle.italic : FontStyle.normal,
          ),
        ));

        currentIndex = match.end;
      }

      if (currentIndex < line.length) {
        inlineSpans.add(TextSpan(
          text: line.substring(currentIndex),
        ));
      }

      spans.add(TextSpan(children: inlineSpans));

      if (i != lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }

    return spans;
  }
}
