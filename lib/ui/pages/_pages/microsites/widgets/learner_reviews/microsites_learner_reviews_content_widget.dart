import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';
import '../../../../../../constants/_constants/app_routes.dart';
import '../../../../../../constants/_constants/color_constants.dart';
import '../../../../../../constants/_constants/telemetry_constants.dart';
import '../../../../../../localization/_langs/english_lang.dart';
import '../../../../../../models/_arguments/course_toc_model.dart';
import '../../../../../../util/telemetry_repository.dart';
import '../../../../../widgets/primary_category_widget.dart';
import '../../../../../widgets/title_bold_widget.dart';
import '../../model/microsites_learner_reviews_data_model.dart';

class MicroSiteLearnerReviewsContentWidget extends StatelessWidget {
  final ContentInfo? contentInfo;
  final bool isFeatured;

  MicroSiteLearnerReviewsContentWidget({
    this.contentInfo,
    this.isFeatured = false,
  });

  void _generateInteractTelemetryData(
      {String? contentId,
      String? objectType,
      String? clickId,
      required BuildContext context}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.browseByProviderAllCbpPageId,
        contentId: contentId ?? "",
        subType: TelemetrySubType.courseCard,
        env: EnglishLang.explore,
        objectType: objectType,
        clickId: clickId ?? "");
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  @override
  Widget build(BuildContext context) {
    var imageExtension;
    if (contentInfo!.posterImage != null) {
      imageExtension = contentInfo!.posterImage!
          .substring(contentInfo!.posterImage!.length - 3);
    }
    return InkWell(
        onTap: () {
          _generateInteractTelemetryData(
              contentId: contentInfo!.identifier ?? "",
              objectType: contentInfo!.primaryCategory ?? "",
              clickId: TelemetryIdentifier.whatOurLearnersAreSayingCardContent,
              context: context);
          Navigator.pushNamed(context, AppUrl.courseTocPage,
              arguments: CourseTocModel.fromJson(
                  {'courseId': contentInfo!.identifier}));
        },
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4).w,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: AppColors.appBarBackground,
              borderRadius: BorderRadius.circular(12).w,
              border: Border.all(color: AppColors.grey08)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                  child: Stack(fit: StackFit.passthrough, children: <Widget>[
                ClipRRect(
                    borderRadius: BorderRadius.circular(8.w),
                    child: Container(
                        height: 100.w,
                        width: 149.w,
                        child: ((contentInfo!.posterImage != null) &&
                                imageExtension != 'svg')
                            ? CachedNetworkImage(
                                fit: BoxFit.fill,
                                imageUrl: contentInfo!.posterImage!,
                                placeholder: (context, url) =>
                                    ContainerSkeleton(
                                      height: 100.w,
                                      width: 149.w,
                                      radius: 0.w,
                                    ),
                                errorWidget: (context, url, error) =>
                                    Image.asset(
                                      'assets/img/image_placeholder.jpg',
                                      fit: BoxFit.fill,
                                    ))
                            : Image.asset(
                                'assets/img/image_placeholder.jpg',
                                fit: BoxFit.fill,
                              ))),
              ])),
              SizedBox(width: 8.w),
              Container(
                width: 0.42.sw,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PrimaryCategoryWidget(
                        contentType: contentInfo!.primaryCategory,
                        addedMargin: true),
                    SizedBox(
                      height: 6.w,
                    ),
                    TitleBoldWidget(
                      contentInfo!.name != null ? contentInfo!.name! : '',
                      fontSize: 14.sp,
                      maxLines: 3,
                    ),
                    SizedBox(height: 8.w),
                    Container(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          (contentInfo!.creatorLogo != null && !isFeatured)
                              ? Container(
                                  height: 24.w,
                                  width: 24.w,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: AppColors.appBarBackground,
                                      border: Border.all(
                                          color: AppColors.grey16, width: 1),
                                      borderRadius: BorderRadius.all(
                                          const Radius.circular(4.0))),
                                  child: CachedNetworkImage(
                                    height: 20.w,
                                    width: 20.w,
                                    fit: BoxFit.fill,
                                    imageUrl: contentInfo!.creatorLogo ?? '',
                                    placeholder: (context, url) =>
                                        ContainerSkeleton(
                                      height: 20.w,
                                      width: 20.w,
                                      radius: 0,
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(),
                                  ),
                                )
                              : !isFeatured
                                  ? Container(
                                      decoration: BoxDecoration(
                                          color: AppColors.appBarBackground,
                                          border: Border.all(
                                              color: AppColors.grey16,
                                              width: 1),
                                          borderRadius: BorderRadius.all(
                                              const Radius.circular(4.0))),
                                      child: Container(
                                        height: 16.w,
                                        width: 17.w,
                                        margin: EdgeInsets.all(2).w,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: contentInfo!.creatorLogo ==
                                                    ''
                                                ? NetworkImage(
                                                    contentInfo!.creatorLogo!)
                                                : AssetImage(
                                                        'assets/img/igot_creator_icon.png')
                                                    as ImageProvider,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Center(),
                          Container(
                            width: 0.3.sw,
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.only(left: 8, right: 16).w,
                            child: Text(
                              contentInfo!.organisation != null
                                  ? contentInfo!.organisation![0] != ''
                                      ? 'By ' + contentInfo!.organisation![0]
                                      : ''
                                  : '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.lato(
                                color: AppColors.greys87,
                                fontWeight: FontWeight.w400,
                                fontSize: 12.0.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
