import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/mdo_channels/screens/mdo_channel_screen/widgets/main_section/content/certificate/mdo_certificate_strip_view_skeleton.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/mdo_channels/screens/mdo_channel_screen/widgets/main_section/content/course/mdo_course_strip_view_skeleton.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/mdo_channels/screens/mdo_channel_screen/widgets/top_section/mdo_top_section_view_skeleton.dart';

class MdoChannelScreenSkeleton extends StatelessWidget {
  final AppBar appBarWidget;

  MdoChannelScreenSkeleton({required this.appBarWidget});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget,
      body: _buildLayout(),
    );
  }

  Widget _buildLayout() {
    return SafeArea(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          margin: EdgeInsets.only(bottom: 100).w,
          child: Column(children: [
            MdoTopSectionViewSkeleton(),
            SizedBox(
              height: 16.w,
            ),
            keyAnnouncements(),
            SizedBox(
              height: 16.w,
            ),
            _tabItem(),
            SizedBox(
              height: 16.w,
            ),
            MdoCertificateStripViewSkeleton(),
            SizedBox(
              height: 16.w,
            ),
            MdoCourseStripViewSkeleton(),
            SizedBox(
              height: 16.w,
            ),
            MdoCourseStripViewSkeleton(),
          ]),
        ),
      ),
    );
  }

  Widget keyAnnouncements() {
    return Container(
        width: double.maxFinite,
        alignment: Alignment.center,
        margin: EdgeInsets.only(left: 4, right: 4).w,
        child: ContainerSkeleton(
          width: 220.w,
          height: 38.w,
          radius: 18.w,
        ));
  }

  Widget _tabItem() {
    return Container(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.only(left: 16, right: 16).w,
        child: Row(
          children: [
            ...List.generate(
                2,
                (index) => Padding(
                      padding: EdgeInsets.only(right: 4).w,
                      child: ContainerSkeleton(
                        width: 120.w,
                        height: 38.w,
                        radius: 8.w,
                      ),
                    ))
          ],
        ));
  }
}
