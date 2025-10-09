import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../constants/index.dart';
import '../skeleton/index.dart';

class AiCourseLoaderWidget extends StatefulWidget {
  @override
  State<AiCourseLoaderWidget> createState() => _AiCourseLoaderWidgetState();
}

class _AiCourseLoaderWidgetState extends State<AiCourseLoaderWidget> {
  Timer? _timer;

  Future<bool> showRecommendationCuratingMessage() async {
    Completer<bool> completer = Completer<bool>();

    _timer = Timer(Duration(seconds: 5), () {
      completer.complete(true);
    });

    _timer?.cancel();
    return completer.future;
  }

  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: showRecommendationCuratingMessage(),
        builder: (context, delaySnapshot) {
          if (delaySnapshot.connectionState == ConnectionState.waiting) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16).r,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CachedNetworkImage(
                    imageUrl: ApiUrl.baseUrl +
                        '/assets/images/sakshamAI/saksham_ai_loader-2.gif',
                    placeholder: (context, url) => Container(),
                    errorWidget: (context, url, error) => Container(),
                    height: 120.sp,
                    width: 120.sp,
                  ),
                  SizedBox(height: 40.w),
                  Container(
                    width: 0.9.sw,
                    child: Text(
                        AppLocalizations.of(context)!
                            .mIgotAICuratingSuitableLearningCourse,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        style: Theme.of(context).textTheme.bodyMedium),
                  )
                ],
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 0, 16),
              child: CourseCardSkeletonPage(),
            );
          }
        });
  }
}
