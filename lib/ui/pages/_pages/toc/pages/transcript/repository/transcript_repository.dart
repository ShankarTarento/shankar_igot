import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:karmayogi_mobile/models/_models/transcription_data_model.dart';
import 'package:karmayogi_mobile/services/_services/learn_service.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/transcript/model/transcript_model.dart';

class TranscriptRepository with ChangeNotifier {
  int _currentSecond = 0;

  int get currentSecond => _currentSecond;

  void updatePosition(Duration position) {
    final newSecond = position.inSeconds;
    if (newSecond != _currentSecond) {
      _currentSecond = newSecond;
      notifyListeners();
    }
  }

  Future<List<VttCaption>> fetchAndParseWebVtt(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      return [];
    }

    return parseWebVtt(response.body);
  }

  List<VttCaption> parseWebVtt(String vttContent) {
    try {
      final lines = vttContent.split('\n');
      final captions = <VttCaption>[];

      String? timeLine;
      String textBuffer = '';
      int? index;

      for (var line in lines) {
        line = line.trim();

        if (int.tryParse(line) != null && timeLine == null) {
          index = int.parse(line);
        } else if (line.contains('-->')) {
          timeLine = line;
        } else if (line.isEmpty) {
          if (timeLine != null && textBuffer.isNotEmpty && index != null) {
            final times = timeLine.split('-->');
            final start = _parseVttTime(times[0].trim());
            final end = _parseVttTime(times[1].trim());

            if (start != null && end != null) {
              captions.add(VttCaption(
                index: index,
                start: start,
                end: end,
                text: textBuffer,
              ));
            }
          }

          index = null;
          timeLine = null;
          textBuffer = '';
        } else {
          textBuffer += (textBuffer.isEmpty ? '' : '\n') + line;
        }
      }

      if (timeLine != null && textBuffer.isNotEmpty && index != null) {
        final times = timeLine.split('-->');
        final start = _parseVttTime(times[0].trim());
        final end = _parseVttTime(times[1].trim());

        if (start != null && end != null) {
          captions.add(VttCaption(
            index: index,
            start: start,
            end: end,
            text: textBuffer,
          ));
        }
      }

      return captions;
    } catch (e) {
      return [];
    }
  }

  Duration? _parseVttTime(String time) {
    try {
      final parts = time.split(':');
      if (parts.length < 2 || parts.length > 3) return null;

      final secParts = parts.last.split('.');
      if (secParts.length != 2) return null;

      final hours = parts.length == 3 ? int.parse(parts[0]) : 0;
      final minutes = int.parse(parts.length == 3 ? parts[1] : parts[0]);
      final seconds = int.parse(secParts[0]);
      final milliseconds = int.parse(secParts[1].padRight(3, '0'));

      return Duration(
        hours: hours,
        minutes: minutes,
        seconds: seconds,
        milliseconds: milliseconds,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<TranscriptionResponse?> getSubtitleAndTranscriptionData(
      {required String resourceId}) async {
    List<TranscriptionResponse> transcriptionDataList = [];

    try {
      final response = await LearnService.getSubtitleAndTranscriptionData(
          resourceId: resourceId);
      if (response.statusCode == 200) {
        var contents = jsonDecode(utf8.decode(response.bodyBytes));
        List data = contents['data'];
        data.forEach((item) {
          transcriptionDataList.add(TranscriptionResponse.fromJson(item));
        });
      }
    } catch (e) {
      debugPrint('Error fetching subtitle and transcription data: $e');
    }
    if (transcriptionDataList.isNotEmpty) {
      return transcriptionDataList.first;
    }
    return null;
  }
}
