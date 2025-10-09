import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/events_details/events_details_screenv2.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/content_info.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:karmayogi_mobile/util/index.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class SlwSpeakerOfTheDay extends StatefulWidget {
  final Map<String, dynamic> speakerData;

  const SlwSpeakerOfTheDay({Key? key, required this.speakerData})
      : super(key: key);

  @override
  _SlwSpeakerOfTheDayState createState() => _SlwSpeakerOfTheDayState();
}

class _SlwSpeakerOfTheDayState extends State<SlwSpeakerOfTheDay> {
  late final PageController _controller;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_controller.hasClients) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_controller.hasClients) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final speakerList = widget.speakerData['list'] as List<dynamic>? ?? [];

    if (speakerList.isEmpty) {
      return const SizedBox();
    }

    return Container(
      color: AppColors.blue209,
      padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 8.r),
      child: ExpansionTile(
        textColor: AppColors.greys,
        iconColor: AppColors.greys,
        trailing: Icon(
          _isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
        ),
        title: _buildTitle(),
        onExpansionChanged: (bool expanding) => setState(() {
          _isExpanded = expanding;
        }),
        children: [
          if (speakerList.isNotEmpty) ...[
            _buildSpeakerPageView(speakerList),
            _buildPageIndicator(speakerList.length),
          ],
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        Text(
          widget.speakerData['title'] ?? '',
          style: GoogleFonts.lato(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (widget.speakerData['infoText'] != null)
          ContentInfo(infoMessage: widget.speakerData['infoText']),
      ],
    );
  }

  Widget _buildSpeakerPageView(List<dynamic> speakerList) {
    return Container(
      height: 250.w,
      decoration: BoxDecoration(
        color: AppColors.seaShell,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: _previousPage,
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: speakerList.length,
              itemBuilder: (context, index) {
                final speaker = speakerList[index];
                return _buildSpeakerCard(speaker);
              },
            ),
          ),
          IconButton(
            onPressed: _nextPage,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int itemCount) {
    return Padding(
      padding: EdgeInsets.only(top: 16.h, bottom: 24.h),
      child: SmoothPageIndicator(
        controller: _controller,
        count: itemCount,
        effect: ExpandingDotsEffect(
          activeDotColor: AppColors.orangeTourText,
          dotColor: AppColors.profilebgGrey20,
          dotHeight: 4.w,
          dotWidth: 4.w,
          spacing: 4.w,
        ),
      ),
    );
  }

  Widget _buildSpeakerCard(Map<String, dynamic> speaker) {
    return Column(
      children: [
        SizedBox(height: 8.w),
        speaker['profileImage'] == null || speaker['profileImage'] == ''
            ? CircleAvatar(
                radius: 40.r,
                backgroundColor: AppColors.darkBlue,
                child: Text(
                  Helper.getInitials(speaker['title'] ?? ""),
                  style: GoogleFonts.lato(
                    color: AppColors.appBarBackground,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : CircleAvatar(
                radius: 40.r,
                backgroundImage: NetworkImage(speaker['profileImage']),
              ),
        SizedBox(height: 8.w),
        Text(
          speaker['title'] ?? '',
          style: GoogleFonts.lato(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 8.w),
        Text(
          speaker['description'] ?? '',
          style: GoogleFonts.lato(
            fontSize: 13.sp,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(
          height: 8.w,
        ),
        speaker['identifier'] != null && speaker['identifier'] != ''
            ? SizedBox(
                height: 35.w,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        FadeRoute(
                            page: EventsDetailsScreenv2(
                          eventId: speaker['identifier'],
                        )));
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all(AppColors.darkBlue),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0).r,
                      ),
                    ),
                  ),
                  child: Text(
                    'View event',
                    style: GoogleFonts.lato(fontSize: 12.sp),
                  ),
                ))
            : SizedBox(),
        SizedBox(
          height: 6.w,
        )
      ],
    );
  }
}
