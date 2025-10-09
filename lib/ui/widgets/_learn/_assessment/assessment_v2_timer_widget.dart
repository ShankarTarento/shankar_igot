import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../constants/index.dart';

class AssessmentV2TimerWidget extends StatefulWidget {
  final List microSurvey;
  final int start;
  final int assessmentSectionLength;
  final int selectedSection;
  final submitSurvey;
  final sectionalDuration;

  AssessmentV2TimerWidget(
      {required this.microSurvey,
      required this.start,
      required this.assessmentSectionLength,
      required this.selectedSection,
      this.submitSurvey,
      this.sectionalDuration});
  @override
  State<AssessmentV2TimerWidget> createState() =>
      _AssessmentV2TimerWidgetState();
}

class _AssessmentV2TimerWidgetState extends State<AssessmentV2TimerWidget> {
  String? _timeFormat;
  late int _questionIndex = 0, _start;
  Timer? _timer;
  bool isFiftyPercentReached = false, isLessThanTwentyPercent = false;
  Color color = AppColors.positiveLight;
  @override
  void initState() {
    super.initState();
    _start = widget.start;
    checkTimerStatus();
    if (widget.start > 0) {
      startTimer();
    }
  }

  @override
  void dispose() async {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _timeFormat != null && _questionIndex < widget.microSurvey.length
            ? Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 90,
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: color, width: 1)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 2),
                        child: Icon(
                          Icons.timer_outlined,
                          color: color,
                          size: 16.sp,
                        ),
                      ),
                      Text(
                        '$_timeFormat' + ' ',
                        style: GoogleFonts.montserrat(
                          color: color,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    ],
                  ),
                ),
              )
            : SizedBox.shrink(),
      ],
    );
  }

  void startTimer() {
    _timeFormat = formatHHMMSS(_start);
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer? timer) {
        if (_start == 0) {
          setState(() {
            timer?.cancel();
            _questionIndex = widget.microSurvey.length;
            if (widget.assessmentSectionLength > 1) {
              for (var i = 0;
                  i <
                      (widget.assessmentSectionLength -
                          (widget.selectedSection + 1));
                  i++) {
                // Navigator.of(context).pop();
              }
            } else {
              widget.submitSurvey();
            }
          });
        } else {
          if (mounted) {
            setState(() {
              _start--;
              checkTimerStatus();
            });
          }
        }
        _timeFormat = formatHHMMSS(_start);
      },
    );
  }

  String formatHHMMSS(int seconds) {
    int hours = (seconds / 3600).truncate();
    seconds = (seconds % 3600).truncate();
    int minutes = (seconds / 60).truncate();

    String hoursStr = (hours).toString().padLeft(2, '0');
    String minutesStr = (minutes).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    if (hours == 0) {
      return '$minutesStr:$secondsStr';
    }

    return '$hoursStr:$minutesStr:$secondsStr';
  }

  void checkTimerStatus() {
    if (widget.sectionalDuration != null) {
      if (_start <
              (double.parse('${widget.sectionalDuration}').round() * 0.5) &&
          _start >=
              (double.parse('${widget.sectionalDuration}').round() * 0.2)) {
        color = AppColors.orangeBackground;
      } else if (_start <
          (double.parse('${widget.sectionalDuration}').round() * 0.2)) {
        color = AppColors.negativeLight;
      }
    } else {
      if (_start < widget.start * 0.5 && _start >= widget.start * 0.2) {
        color = AppColors.orangeBackground;
      } else if (_start < widget.start * 0.2) {
        color = AppColors.negativeLight;
      }
    }
  }
}
