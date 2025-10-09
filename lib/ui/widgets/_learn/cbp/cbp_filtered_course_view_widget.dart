import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../constants/index.dart';
import '../../../../models/_arguments/index.dart';
import '../../../../models/index.dart';
import '../../../../util/telemetry_repository.dart';
import '../../index.dart';

class FilteredCourseViewWidget extends StatelessWidget {
  FilteredCourseViewWidget({Key? key, required this.filteredListOfCourses})
      : super(key: key);

  final List<Course> filteredListOfCourses;

  void _generateInteractTelemetryData(String contentId, String env,
      {String? subType = '',
      String? primaryCategory,
      required BuildContext context}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.homePageId,
        contentId: contentId,
        subType: subType ?? "",
        env: TelemetryEnv.home,
        objectType: primaryCategory != null ? primaryCategory : subType);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  @override
  Widget build(BuildContext context) {
    return filteredListOfCourses.length > 0
        ? ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: filteredListOfCourses.length,
            itemBuilder: (context, index) {
              return InkWell(
                  onTap: () async {
                    _generateInteractTelemetryData(
                        filteredListOfCourses[index].id,
                        filteredListOfCourses[index].courseCategory,
                        context: context);
                    Navigator.pushNamed(context, AppUrl.courseTocPage,
                        arguments: CourseTocModel(
                            courseId: filteredListOfCourses[index].id));
                  },
                  child: CbpCourseCard(course: filteredListOfCourses[index]));
            })
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16).r,
                child: SvgPicture.asset(
                  'assets/img/search-empty.svg',
                  height: 100.w,
                  width: 180.w,
                ),
              ),
              Text(
                '${AppLocalizations.of(context)!.mStaticAdjustSearch}',
                style: Theme.of(context).textTheme.displayLarge,
                maxLines: 2,
                textAlign: TextAlign.center,
              )
            ],
          );
  }
}
