import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';

class HubsBanner extends StatelessWidget {
  final String imageUrl;
  const HubsBanner({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Image(
        height: 150.w,
        width: 1.sw,
        image: NetworkImage(imageUrl),
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return ContainerSkeleton(
            height: 150.w,
            width: 1.sw,
            padding: 0,
          );
        },
        errorBuilder: (context, url, error) => SizedBox.shrink(),
      ),
    );
  }
}
