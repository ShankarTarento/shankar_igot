import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';
import 'package:igot_ui_components/utils/module_colors.dart';
import 'package:karmayogi_mobile/constants/_constants/api_endpoints.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/helper/discussion_const.dart';

class CommunityBannerImageWidget extends StatelessWidget {
  final String? imgUrl;
  final double height;
  final double width;
  final BoxFit fit;
  final double radius;
  final BorderRadiusGeometry? borderRadius;

  const CommunityBannerImageWidget(
      {this.imgUrl,
        this.height = 24,
        this.width = 24,
        this.fit = BoxFit.fill,
        this.radius = 0,
        this.borderRadius,
        super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: height,
        width: width,
        child: _microSiteImageView()
    );
  }

  Widget _microSiteImageView() {
    final bool isSvg = (imgUrl??'${ApiUrl.baseUrl}${communityDefaultBannerImage}').endsWith('.svg');
    if (isSvg) {
      return ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.all(
              Radius.circular(radius),
            ),
        child: SvgPicture.network(
          imgUrl??'${ApiUrl.baseUrl}${communityDefaultBannerImage}',
          height: height,
          width: width,
          fit: fit,
          placeholderBuilder: (context) => Container(
            decoration: BoxDecoration(
                color: ModuleColors.grey08,
                borderRadius: borderRadius ?? BorderRadius.circular(radius)),
            child: ContainerSkeleton(
              width: width,
              height: height,
              radius: radius,
            ),
          ),
        ),
      );
    } else {
      return _imageView(imgUrl??"", '${ApiUrl.baseUrl}${communityDefaultBannerImage}');
    }
  }
  Widget _imageView(String url, String defaultBanner) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.all(Radius.circular(radius)),
      child: CachedNetworkImage(
        height: height,
        width: width,
        fit: fit,
        imageUrl: url,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => CachedNetworkImage(
          height: height,
          width: width,
          fit: fit,
          imageUrl: defaultBanner,
          placeholder: (context, url) => _buildPlaceholder(),
          errorWidget: (context, url, error) => _buildPlaceholder(),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: ModuleColors.grey04,
        borderRadius: borderRadius ?? BorderRadius.circular(radius),
      ),
      child: ContainerSkeleton(
        width: width,
        height: height,
        radius: radius,
      ),
    );
  }
}
