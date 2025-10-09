import 'package:flutter/material.dart';
import 'package:igot_ui_components/ui/widgets/resource_card/resource_card.dart';
import 'package:igot_ui_components/ui/widgets/skeleton_loading/card_skeleton_loading.dart';
import 'package:igot_ui_components/ui/widgets/skeleton_loading/title_skeleton_loading.dart';
import 'package:igot_ui_components/utils/fade_route.dart';
import 'package:igot_ui_components/utils/module_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/models/_arguments/course_toc_model.dart';
import 'package:karmayogi_mobile/models/_models/gyaan_karmayogi_resource_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/gyaan_karmayogi_v2/pages/details_screen/details_screen.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/gyaan_karmayogi_v2/pages/view_all_page/view_all_pages.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/gyaan_karmayogi_v2/services/gyaan_karma_yogi_helper.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/gyaan_karmayogi_v2/services/gyaan_karmayogi_services.dart';
import 'package:karmayogi_mobile/ui/widgets/title_widget/title_widget.dart';
import 'package:karmayogi_mobile/util/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../../constants/index.dart';

class GyaanKarmayogiCarouselV2 extends StatefulWidget {
  final String? courseIdentifier;
  final String title;
  final String? sectorFilter;
  final String? subSectorFilter;
  final String? searchQuery;
  final List<String>? createdFor;
  const GyaanKarmayogiCarouselV2(
      {super.key,
      this.searchQuery,
      this.courseIdentifier,
      required this.title,
      this.sectorFilter,
      this.subSectorFilter,
      this.createdFor});

  @override
  State<GyaanKarmayogiCarouselV2> createState() =>
      _GyaanKarmayogiCarouselState();
}

class _GyaanKarmayogiCarouselState extends State<GyaanKarmayogiCarouselV2> {
  int currentIndex = 0;
  final int maxCountToShowNavIcon = 1;
  late Future<List<GyaanKarmayogiResource>>? karmayogiResources;
  final PageController _controller = PageController();

  @override
  void initState() {
    getResources();
    super.initState();
  }

  void getResources() {
    karmayogiResources = GyaanKarmayogiServicesV2.getGyaanKarmaYogiResources(
        createdFor: widget.createdFor,
        resourceCategoryFilter: [widget.title],
        searchQuery: widget.searchQuery,
        sectorsFilter:
            widget.sectorFilter != null ? [widget.sectorFilter!] : [],
        subSectorFilter:
            widget.subSectorFilter != null ? [widget.subSectorFilter!] : []);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<GyaanKarmayogiResource>>(
        future: karmayogiResources,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Padding(
              padding: const EdgeInsets.all(16.0).r,
              child: CardSkeletonLoading(),
            );
          }

          if (snapshot.data != null) {
            List<GyaanKarmayogiResource> resources = snapshot.data!;
            int resourcesLength = resources.length > 5 ? 4 : resources.length;

            return resources.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16.0).r,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TitleWidget(
                          title: Helper.capitalizeEachWordFirstCharacter(
                              widget.title),
                          buttonText:
                              AppLocalizations.of(context)!.mStaticViewAll,
                          showAllCallBack: () {
                            Navigator.push(
                                context,
                                FadeRoute(
                                    page: ViewAllScreenV2(
                                  index: widget.createdFor != null ? 1 : 0,
                                  category: widget.title,
                                  sector: widget.sectorFilter,
                                  subSector: widget.subSectorFilter,
                                )));
                          },
                        ),
                        SizedBox(
                          height: 20.w,
                        ),
                        Stack(
                          children: [
                            Container(
                              height: 390.w,
                              margin: const EdgeInsets.only(
                                      left: 0, top: 0, bottom: 15)
                                  .r,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: PageView.builder(
                                      onPageChanged: (value) {
                                        currentIndex = value;

                                        setState(() {});
                                      },
                                      controller: _controller,
                                      itemCount: resourcesLength,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                                  left: 16, right: 16, top: 8)
                                              .r,
                                          child: ResourceCard(
                                            creatorLogo: Image.asset(
                                              "assets/img/igot_creator_icon.png",
                                              fit: BoxFit.fill,
                                            ),
                                            creator:
                                                resources[index].source ?? '',
                                            mimeType: GyaanKarmaYogiHelper()
                                                .checkContentType(
                                                    mimeType: resources[index]
                                                        .mimeType),
                                            mimeTypeIcon: GyaanKarmaYogiHelper()
                                                .checkContentTypeIcon(
                                                    mimeType: resources[index]
                                                        .mimeType),
                                            onTapCallBack: () {
                                              if (GyaanKarmaYogiHelper()
                                                      .checkContentType(
                                                          mimeType:
                                                              resources[index]
                                                                  .mimeType) ==
                                                  "Collection") {
                                                Navigator.pushNamed(context,
                                                    AppUrl.courseTocPage,
                                                    arguments: CourseTocModel
                                                        .fromJson({
                                                      'courseId':
                                                          resources[index]
                                                              .identifier,
                                                    }));
                                              } else {
                                                Navigator.push(
                                                    context,
                                                    FadeRoute(
                                                        page:
                                                            ResourceDetailsScreenV2(
                                                      resourceId:
                                                          resources[index]
                                                              .identifier,
                                                    )));
                                              }
                                            },
                                            posterImage:
                                                resources[index].posterImage ??
                                                    '',
                                            resourceDescription:
                                                resources[index].description ??
                                                    '',
                                            resourceName:
                                                resources[index].name ?? '',
                                            tags: getSectorNames(
                                                resources[index]),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: 16.w,
                                  ),
                                  SmoothPageIndicator(
                                    controller: _controller,
                                    count: resourcesLength,
                                    effect: const ExpandingDotsEffect(
                                      activeDotColor:
                                          ModuleColors.orangeTourText,
                                      dotColor: ModuleColors.profilebgGrey20,
                                      dotHeight: 4,
                                      dotWidth: 4,
                                      spacing: 4,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Visibility(
                                visible: currentIndex > 0 &&
                                    resourcesLength > maxCountToShowNavIcon,
                                child: Positioned(
                                  top: 160.w,
                                  left: 0,
                                  child: InkWell(
                                    onTap: () {
                                      if (currentIndex > 0) {
                                        _controller.animateToPage(
                                          currentIndex - 1,
                                          duration:
                                              const Duration(milliseconds: 500),
                                          curve: Curves.ease,
                                        );
                                      }
                                    },
                                    child: CircleAvatar(
                                      backgroundColor: AppColors.greys,
                                      radius: 16.r,
                                      child: const Icon(
                                        Icons.chevron_left,
                                        color: AppColors.appBarBackground,
                                      ),
                                    ),
                                  ),
                                )),
                            Visibility(
                                visible: resourcesLength - 1 > currentIndex &&
                                    resourcesLength > maxCountToShowNavIcon,
                                child: Positioned(
                                  top: 160.w,
                                  right: 0,
                                  child: InkWell(
                                    onTap: () {
                                      if (currentIndex < 3) {
                                        _controller.animateToPage(
                                          currentIndex + 1,
                                          duration:
                                              const Duration(milliseconds: 500),
                                          curve: Curves.ease,
                                        );
                                      }
                                    },
                                    child: CircleAvatar(
                                      backgroundColor: AppColors.greys,
                                      radius: 16.r,
                                      child: const Icon(
                                        Icons.chevron_right,
                                        color: AppColors.appBarBackground,
                                      ),
                                    ),
                                  ),
                                )),
                          ],
                        )
                      ],
                    ),
                  )
                : const SizedBox();
          } else if (snapshot.data == null) {
            return const SizedBox();
          } else {
            return Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8).r,
              child: Column(
                children: [
                  SizedBox(
                    height: 30.w,
                  ),
                  const TitleSkeletonLoading(),
                  const CardSkeletonLoading(),
                ],
              ),
            );
          }
        });
  }

  List<String> getSectorNames(GyaanKarmayogiResource sectorDetails) {
    if (sectorDetails.sector == null) return [];

    final Set<String> uniqueSectorNames = {};

    for (var item in sectorDetails.sector!) {
      if (item.sectorName.isNotEmpty) {
        uniqueSectorNames.add(item.sectorName);
      }
    }

    return uniqueSectorNames.toList();
  }
}
