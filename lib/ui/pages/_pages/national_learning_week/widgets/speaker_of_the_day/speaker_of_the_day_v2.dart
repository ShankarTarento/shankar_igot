import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/events_details/events_details_screenv2.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/content_info.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:karmayogi_mobile/util/index.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class SpeakerOfTheDayV2 extends StatefulWidget {
  final Map<String, dynamic> speakerData;

  const SpeakerOfTheDayV2({Key? key, required this.speakerData})
      : super(key: key);

  @override
  _SpeakerOfTheDayV2State createState() => _SpeakerOfTheDayV2State();
}

class _SpeakerOfTheDayV2State extends State<SpeakerOfTheDayV2> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0);
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

    return speakerList.isNotEmpty
        ? Column(
            children: [
              SizedBox(
                height: 8.w,
              ),
              _buildTitle(),
              SizedBox(
                height: 24.w,
              ),
              Container(
                height: 235.w,
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
              ),
              Padding(
                padding: EdgeInsets.only(top: 16.h, bottom: 16.h),
                child: SmoothPageIndicator(
                  controller: _controller,
                  count: speakerList.length,
                  effect: ExpandingDotsEffect(
                    activeDotColor: AppColors.orangeTourText,
                    dotColor: AppColors.profilebgGrey20,
                    dotHeight: 4.w,
                    dotWidth: 4.w,
                    spacing: 4.w,
                  ),
                ),
              ),
            ],
          )
        : SizedBox();
  }

  Widget _buildTitle() {
    return Row(
      children: [
        SizedBox(
          width: 16.w,
        ),
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
          //  speaker['description'] ??
          'he meaning of DESCRIPTION is an act of describing; specifically : discourse intended to give a mental image of something experienced. How to use description in a sentence. Synonym Discussion of Description.',
          style: GoogleFonts.lato(
            fontSize: 13.sp,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
          maxLines: 3,
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
