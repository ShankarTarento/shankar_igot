import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';
import 'package:karmayogi_mobile/common_components/content_strips/service/course_strip_service.dart';
import 'package:karmayogi_mobile/common_components/models/content_strip_model.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/browse_card.dart';
import 'package:karmayogi_mobile/ui/widgets/_signup/contact_us.dart';
import 'package:karmayogi_mobile/ui/widgets/title_bold_widget.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';

import '../../constants/index.dart';
import '../constants/widget_constants.dart';

class ViewAllCourses extends StatefulWidget {
  final ContentStripModel courseStripData;
  final String type;

  const ViewAllCourses(
      {super.key, required this.courseStripData, this.type = ''});

  @override
  State<ViewAllCourses> createState() => _ViewAllCoursesState();
}

class _ViewAllCoursesState extends State<ViewAllCourses> {
  ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int offset = 0;
  List<Course> allCourses = [];

  @override
  void initState() {
    super.initState();
    if (widget.courseStripData.request?["request"]?["offset"] != null) {
      _scrollController.addListener(_loadMoreData);
    }
    _getCourses();
  }

  void _loadMoreData() {
    if (widget.courseStripData.request?["request"]?["offset"] != null &&
        _scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore &&
        _hasMoreData) {
      _isLoadingMore = true;
      _getCourses();
    }
  }

  void _getCourses() async {
    if (widget.courseStripData.request?["request"]?["offset"] == null) {
      offset = 0;
    }

    List<Course> courses = await ContentStripService.getCourseData(
      stripData: widget.courseStripData,
      offset: widget.courseStripData.request?["request"]?["offset"] != null
          ? offset
          : null,
    );

    if (widget.type == WidgetConstants.featuredCourseStrip) {
      courses.removeWhere((course) =>
          course.primaryCategory.toLowerCase() ==
          PrimaryCategory.landingPageResource.toLowerCase());
    }

    if (mounted) {
      setState(() {
        if (courses.isEmpty) {
          _hasMoreData = false;
        } else {
          allCourses.addAll(courses);
          if (widget.courseStripData.request?["request"]?["offset"] != null) {
            offset += 20;
          }
        }
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteGradientOne,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Text(""),
            Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  FadeRoute(page: ContactUs()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 0, 8).r,
                child: SvgPicture.asset(
                  'assets/img/help_icon.svg',
                  width: 56.0.w,
                  height: 56.0.w,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        controller:
            widget.courseStripData.request?["request"]?["offset"] != null
                ? _scrollController
                : null,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.courseStripData.title != null
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8).r,
                    child: TitleBoldWidget(
                        widget.courseStripData.title!.getText(context)),
                  )
                : SizedBox(),
            !_isLoadingMore && allCourses.isEmpty
                ? _buildEmptyState(context)
                : _buildCourseList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(Duration(seconds: 2)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: 5,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(
                        left: 16.0, right: 16, top: 8, bottom: 8)
                    .r,
                child: ContainerSkeleton(
                  height: 150.w,
                  width: 1.sw,
                  radius: 4.r,
                ),
              );
            },
          );
        }
        return _noResultsFound(context);
      },
    );
  }

  Widget _buildCourseList() {
    return Container(
      width: double.infinity.w,
      padding: const EdgeInsets.only(top: 8).r,
      color: AppColors.whiteGradientOne,
      child: AnimationLimiter(
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: allCourses.length + (_isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < allCourses.length) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8).r,
                      child: BrowseCard(course: allCourses[index]),
                    ),
                  ),
                ),
              );
            } else if (_isLoadingMore) {
              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(
                            left: 16.0, right: 16, top: 8, bottom: 8)
                        .r,
                    child: ContainerSkeleton(
                      height: 150.w,
                      width: 1.sw,
                      radius: 4,
                    ),
                  );
                },
              );
            }
            return SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _noResultsFound(BuildContext context) {
    return Column(
      children: [
        Container(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 125).r,
              child: SvgPicture.asset(
                'assets/img/empty_search.svg',
                alignment: Alignment.center,
                width: 0.2.sw,
                height: 0.2.sh,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Container(
          width: 0.75.sw,
          child: Padding(
            padding: const EdgeInsets.only(top: 20).r,
            child: Text(
              AppLocalizations.of(context)!.mStaticNoResultsFound,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(height: 1.5.w, letterSpacing: 0.25),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ),
        ),
      ],
    );
  }
}
