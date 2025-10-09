import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/feedback/pages/_pages/_cbpSurvey/survey_page_v2/survey_form_v2.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/feedback/constants.dart';
import 'package:karmayogi_mobile/models/_models/course_hierarchy_model.dart';
import 'package:karmayogi_mobile/services/_services/learn_service.dart';

import '../../../../../../ui/pages/_pages/toc/view_model/toc_player_view_model.dart';

class SurveyPageV2 extends StatefulWidget {
  final Map microSurvey;
  final String surveyName;
  final CourseHierarchyModel course;
  final String identifier;
  final String? batchId;
  final updateContentProgress;
  final String parentCourseId;
  final ValueChanged<bool> playNextResource;
  final bool? isPreRequisite;final String language;

  const SurveyPageV2({
    super.key,
    required this.microSurvey,
    required this.surveyName,
    required this.course,
    required this.identifier,
    this.batchId,
    this.updateContentProgress,
    required this.parentCourseId,
    required this.playNextResource,
    this.isPreRequisite = false,required this.language
  });

  @override
  State<SurveyPageV2> createState() => _SurveyPageV2State();
}

class _SurveyPageV2State extends State<SurveyPageV2> {
  LearnService learnService = LearnService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBarBackground,
      appBar: _getAppbar(),
      body: SingleChildScrollView(
        child: SurveyFormV2(
          surveyFormData: widget.microSurvey,
          courseId: widget.parentCourseId,
          enrollParentAction: (result) async {
            if (result == "Confirm") {
              await _updateContentProgress();
            }
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _getAppbar() {
    return AppBar(
      titleSpacing: 0,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.clear, color: FeedbackColors.black60),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(children: [
        Icon(Icons.book, color: FeedbackColors.black60),
        Container(
          width: 0.6.sw,
          padding: const EdgeInsets.only(left: 10).r,
          child: Text(
            widget.surveyName,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                ),
          ),
        ),
      ]),
    );
  }

  Future<void> _updateContentProgress() async {
    List<String> current = [];

    if (widget.batchId != null) {
      try {
        current.add(widget.microSurvey['fields'].length.toString());
        String courseId = TocPlayerViewModel()
            .getEnrolledCourseId(context, widget.parentCourseId);
        String batchId = widget.batchId!;
        String contentId = widget.identifier;
        int status = 2;
        String contentType = EMimeTypes.survey;
        var maxSize = widget.course.duration;

        double completionPercentage = 100.0;

        await learnService.updateContentProgress(
          courseId,
          batchId,
          contentId,
          status,
          contentType,
          current,
          maxSize,
          completionPercentage,
          isAssessment: true,
          isPreRequisite: widget.isPreRequisite, language: widget.language
        );

        Map<String, dynamic> data = {
          'identifier': contentId,
          'mimeType': EMimeTypes.survey,
          'current': 100,
          'completionPercentage': completionPercentage / 100,
        };

        await widget.updateContentProgress(data);
        widget.playNextResource(true);
      } catch (e, stacktrace) {
        debugPrint('Error in _updateContentProgress: $e');
        debugPrint('$stacktrace');
      }
    }
  }
}
