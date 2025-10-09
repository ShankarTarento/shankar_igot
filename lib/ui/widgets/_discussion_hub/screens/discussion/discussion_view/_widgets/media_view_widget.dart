
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/discussion/discussion_view/_models/media_view_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/discussion/discussion_view/_widgets/media_slider_widget.dart';

class DiscussionMediaViewWidget extends StatefulWidget {
  final List<String> mediaUrls;
  final String contentType;

  DiscussionMediaViewWidget({Key? key, required this.mediaUrls, required this.contentType}) : super(key: key);
  _DiscussionMediaViewWidgetState createState() => _DiscussionMediaViewWidgetState();
}

class _DiscussionMediaViewWidgetState extends State<DiscussionMediaViewWidget> {

  late List<MediaViewModel> sliderList;

  @override
  void initState() {
    super.initState();
    _getMediaData();
  }

  void _getMediaData() async {
    try {
      sliderList = [];
      widget.mediaUrls.forEach((url) {
        sliderList.add(MediaViewModel(
          mediaUrl: url,
          type: widget.contentType,
        ));
      });
    } catch (err) {}
  }

  @override
  Widget build(BuildContext context) {
    return buildUI();
  }

  @override
  void didUpdateWidget(DiscussionMediaViewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mediaUrls != widget.mediaUrls) {
      _getMediaData();
    }
  }

  Widget buildUI() {
    return Container(
      padding: EdgeInsets.only(top: 8, bottom: 8).r,
      child: MediaSliderWidget(
        width: 1.sw,
        height: 0.5.sw,
        mediaList: sliderList,
        contentType: widget.contentType,
        defaultView: Container(),
        showDefaultView: false,
        showNavigationButtonAboveBanner: true,
        showIndicatorAtBottomCenterInBanner: true,
        autoSlide: false,
      ),
    );
  }

}
