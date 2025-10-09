import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/models/_arguments/course_toc_model.dart';
import 'package:karmayogi_mobile/models/_models/course_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_home/course_card.dart';
import 'package:karmayogi_mobile/ui/widgets/title_widget/title_widget.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:karmayogi_mobile/util/telemetry_repository.dart';
import '../../../../../constants/_constants/app_routes.dart';

class CourseCardStrip extends StatelessWidget {
  final List<Course>? courses;
  final Function()? showAllCallBack;
  final String? toolTipMessage;
  final String? title;
  final bool showFullLength;
  final String telemetryEnv;
  final String telemetrySubType;
  final String telemetryPageIdentifier;

  const CourseCardStrip({
    super.key,
    this.courses,
    this.title,
    this.showFullLength = false,
    this.showAllCallBack,
    this.toolTipMessage,
    this.telemetryEnv = TelemetryEnv.learn,
    this.telemetryPageIdentifier = TelemetryPageIdentifier.learnPageId,
    this.telemetrySubType = TelemetrySubType.courseCard,
  });
  void _generateInteractTelemetryData(
      String contentId, String primaryCategory) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: telemetryPageIdentifier,
        contentId: contentId,
        subType: telemetrySubType,
        env: telemetryEnv,
        clickId: TelemetryIdentifier.cardContent,
        // ignore: unnecessary_null_comparison
        objectType:
            primaryCategory.isNotEmpty ? primaryCategory : telemetrySubType);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  @override
  Widget build(BuildContext context) {
    return courses != null && courses!.isNotEmpty
        ? Column(
            children: [
              title != null
                  ? Container(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 15).r,
                      child: TitleWidget(
                          title: Helper.capitalize(title!),
                          showAllCallBack: showAllCallBack,
                          toolTipMessage: toolTipMessage),
                    )
                  : SizedBox(),
              Container(
                height: 310.w,
                width: double.infinity.w,
                margin: const EdgeInsets.only(top: 5, bottom: 15).r,
                child: AnimationLimiter(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: showFullLength
                        ? courses!.length
                        : courses!.length < 10
                            ? courses!.length
                            : 10,
                    itemBuilder: (context, index) {
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: InkWell(
                                onTap: () async {
                                  _generateInteractTelemetryData(
                                      courses![index].id,
                                      courses![index].courseCategory);
                                  Navigator.pushNamed(
                                      context, AppUrl.courseTocPage,
                                      arguments: CourseTocModel.fromJson({
                                        'courseId': courses![index].id,
                                      }));
                                },
                                child: CourseCard(
                                  course: courses![index],
                                )),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          )
        : SizedBox.shrink();
  }
}
