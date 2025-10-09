import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/national_learning_week/widgets/highlights_of_the_week/widgets/video_player_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/content_info.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HighlightsOfTheWeek extends StatefulWidget {
  final Map<String, dynamic> highlightsData;

  const HighlightsOfTheWeek({Key? key, required this.highlightsData})
      : super(key: key);

  @override
  _HighlightsOfTheWeekState createState() => _HighlightsOfTheWeekState();
}

class _HighlightsOfTheWeekState extends State<HighlightsOfTheWeek> {
  final PageController _controller = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    // _controller.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    // _controller.removeListener(_onPageChanged);
    _controller.dispose();
    super.dispose();
  }

  // void _onPageChanged() {
  //   setState(() {
  //     _currentPageIndex = _controller.page?.round() ?? 0;
  //   });
  // }

  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final List<dynamic> highlightsList = widget.highlightsData['list'] ?? [];

    return Container(
      color: AppColors.blue209,
      padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 8.r),
      child: ExpansionTile(
        textColor: AppColors.greys,
        iconColor: AppColors.greys,
        trailing:
            Icon(_isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down),
        onExpansionChanged: (bool expanding) => setState(() {
          _isExpanded = expanding;
        }),
        title: Row(
          children: [
            Text(
              widget.highlightsData['title'] ?? '',
              style: GoogleFonts.lato(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (widget.highlightsData['infoText'] != null)
              ContentInfo(infoMessage: widget.highlightsData['infoText']),
          ],
        ),
        children: <Widget>[
          if (highlightsList.isNotEmpty) ...[
            SizedBox(
              height: 330.w,
              child: PageView.builder(
                controller: _controller,
                itemCount: highlightsList.length,
                itemBuilder: (context, index) {
                  final videoData = highlightsList[index];
                  return VideoPlayerWidget(
                    videoUrl: videoData['videoUrl'],
                    title: videoData['title'] ?? '',
                    description: videoData['description'] ?? '',
                  );
                },
                // onPageChanged: (index) {
                //   setState(() {
                //     _currentPageIndex = index;
                //   });
                // },
              ),
            ),
            SizedBox(height: 8.w),
            SmoothPageIndicator(
              controller: _controller,
              count: highlightsList.length,
              effect: ExpandingDotsEffect(
                activeDotColor: AppColors.orangeTourText,
                dotColor: AppColors.profilebgGrey20,
                dotHeight: 4.w,
                dotWidth: 4.w,
                spacing: 4.w,
              ),
            ),
          ] else
            Padding(
              padding: EdgeInsets.all(16.0).r,
              child: Text(AppLocalizations.of(context)!.mMsgNoDataFound,
                  style: TextStyle(fontSize: 16.sp)),
            ),
        ],
      ),
    );
  }
}
