import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';
import 'package:karmayogi_mobile/models/_models/support_section_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/microsites/model/ati_cti_microsite_data_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_signup/video_conference.dart';

class SlwSupportSection extends StatelessWidget {
  final SupportSectionModel? supportSectionModel;
  final SectionListModel element;
  const SlwSupportSection(
      {super.key, this.supportSectionModel, required this.element});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.delayed(Duration(seconds: 1)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ContainerSkeleton(
              height: 80.w,
              width: double.infinity,
            );
          }
          return Column(
            children: [
              SizedBox(
                height: 16.w,
              ),
              SizedBox(
                height: 180.w,
                child: CachedNetworkImage(
                  fit: BoxFit.fill,
                  imageUrl: element.column[0].data['thumbnail'] ?? "",
                  errorWidget: (context, url, error) {
                    return SizedBox();
                  },
                  progressIndicatorBuilder: (context, url, progress) {
                    return Center(
                        child: ContainerSkeleton(
                      height: 150.w,
                      width: 80.w,
                    ));
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 16, right: 16, bottom: 100).r,
                child: VideoConferenceWidget(
                  data: supportSectionModel,
                  borderRadius: 4,
                ),
              ),
            ],
          );
        });
  }
}
